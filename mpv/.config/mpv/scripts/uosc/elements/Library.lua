local Element = require('elements/Element')

-- Start screen: rows of cards for ~/Videos, built by ~~/library/scan.py.

local SCAN_SCRIPT = mp.command_native({'expand-path', '~~/library/scan.py'})
local LIBRARY_FILE = mp.command_native({'expand-path', '~/.cache/mpv-library/library.json'})
local WATCH_LATER_DIR = mp.command_native({'expand-path', '~~state/watch_later'})
local WATCH_HISTORY = mp.command_native({'expand-path', mp.get_property('watch-history-path', '~~state/watch_history.jsonl')})
-- Row order comes from library.json (library.toml); this is the fallback.
local DEFAULT_ROWS = {'Movies', 'TV', 'Anime'}

-- libass picks the matching face by weight; falls back to the OSD font if missing.
local FONT_FAMILY = 'SF Pro Display'
local WEIGHT = {bold = 700, semibold = 600, medium = 500, regular = 400}

-- mpv allows overlay ids 0-63; thumbfast uses 42.
local OVERLAY_IDS = {}
for id = 1, 63 do
	if id ~= 42 then OVERLAY_IDS[#OVERLAY_IDS + 1] = id end
end

local function format_runtime(seconds)
	if not seconds or seconds <= 0 then return nil end
	local minutes = math.floor(seconds / 60 + 0.5)
	if minutes < 60 then return minutes .. 'm' end
	return string.format('%dh %02dm', math.floor(minutes / 60), minutes % 60)
end

-- Quality label by width as well, so 1920x800 widescreen still reads 1080p.
local function quality(width, height)
	width, height = width or 0, height or 0
	if width >= 3200 or height >= 1800 then return '4K' end
	if width >= 1800 or height >= 1000 then return '1080p' end
	if width >= 1200 or height >= 700 then return '720p' end
	return height > 0 and (height .. 'p') or nil
end

local function episode_code(ep) return string.format('S%02dE%02d', ep.season, ep.episode) end

-- Shorten text with an ellipsis so it fits in `width` pixels.
local function fit_text(text, width, opts)
	if text_width(text, opts) <= width then return text end
	local chars = {}
	for _, char in utf8_iter(text) do chars[#chars + 1] = char end
	local low, high = 0, #chars
	while low < high do
		local mid = math.ceil((low + high) / 2)
		if text_width(table.concat(chars, '', 1, mid) .. '…', opts) <= width then low = mid else high = mid - 1 end
	end
	return table.concat(chars, '', 1, low) .. '…'
end

-- Wrap text to `width` pixels, keeping at most `max_lines` (the last one ellipsized).
local function wrap_lines(text, width, size, max_lines)
	-- A little slack: medium and regular weights differ slightly from the measured face.
	local wrapped = wrap_text(text or '', {size = size}, math.floor(width * 0.94 / (size * 0.5)))
	local lines = {}
	for line in (wrapped .. '\n'):gmatch('(.-)\n') do
		if #lines == max_lines then
			lines[max_lines] = lines[max_lines]:gsub('[%s%p]*$', '') .. '…'
			break
		end
		if line ~= '' or #lines > 0 then lines[#lines + 1] = line end
	end
	return lines
end

local function format_date(iso)
	local year, month, day = (iso or ''):match('^(%d+)-(%d+)-(%d+)')
	if not year then return nil end
	return os.date('%d %b %Y', os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 12}))
end

-- Text in FONT_FAMILY at one of the WEIGHT steps.
local function txt(ass, x, y, align, value, weight, size, opts)
	opts = opts or {}
	opts.font, opts.size, opts.weight = FONT_FAMILY, size, WEIGHT[weight]
	opts.color = opts.color or fg
	ass:txt(x, y, align, value, opts)
end

---@class Library : Element
local Library = class(Element)

function Library:new() return Class.new(self) --[[@as Library]] end
function Library:init()
	Element.init(self, 'library', {render_order = 1})
	self.enabled = false
	self.by_category = {}
	self.rows = {} -- categories that have items, in display order
	self.row = 1 -- selected row
	self.cols = {} -- selected item per row
	self.offsets = {} -- first visible item per row
	self.row_scroll = 1 -- first visible row
	self.view = 'home' -- 'home' or 'series'
	self.series = nil -- series shown on the series page
	self.overlays = {} -- overlay id -> signature of what it currently shows
	self.bound = nil -- view whose key bindings are active
	self.scanning = false
	self.last_cursor = nil

	mp.register_script_message('library-play', function(id, index) self:play(id, tonumber(index)) end)
	mp.register_script_message('library-rescan', function() self:scan() end)
	mp.register_event('shutdown', function() self:clear_overlays() end)

	self:load()
	self:scan()
end

function Library:destroy()
	self:clear_overlays()
	Element.destroy(self)
end

--[[ DATA ]]

function Library:scan()
	if self.scanning then return end
	self.scanning = true
	mp.command_native_async({
		name = 'subprocess',
		args = {'uv', 'run', '--quiet', '--script', SCAN_SCRIPT},
		playback_only = false,
		capture_stderr = true,
	}, function(success, result)
		self.scanning = false
		if success and result.status == 0 then
			self:load()
		else
			msg.warn('library scan failed: ' .. tostring(result and result.stderr or result))
		end
	end)
end

function Library:load()
	local file = io.open(LIBRARY_FILE, 'r')
	if not file then return end
	local data = utils.parse_json(file:read('*a'))
	file:close()
	if not data or not data.items then return end

	local categories = data.rows or DEFAULT_ROWS
	local by_category = {}
	for _, category in ipairs(categories) do by_category[category] = {} end
	for _, item in ipairs(data.items) do
		local list = by_category[item.category]
		if list then list[#list + 1] = item end
	end
	local selected_id = self:selected_item() and self:selected_item().id
	self.rows = {}
	for _, category in ipairs(categories) do
		if #by_category[category] > 0 then self.rows[#self.rows + 1] = category end
	end
	self.by_category = by_category
	self.card_size = data.card_size or {400, 225}
	self.still_size = data.still_size or {320, 180}

	self:refresh_progress()
	self:sort_rows(selected_id)
	if self.series then
		local series = self:find(self.series.id)
		if series then self:open_series(series) else self:close_series() end
	end
	self:decide_enabled()
	request_render()
end

-- Recently played first (newest at the front), then never played alphabetically.
function Library:sort_rows(selected_id)
	for _, category in ipairs(self.rows) do
		table.sort(self.by_category[category], function(a, b)
			local a_played, b_played = a.last_played or 0, b.last_played or 0
			if a_played ~= b_played then return a_played > b_played end
			return a.title:lower() < b.title:lower()
		end)
	end
	-- Keep the selection on the same title; otherwise start at the front of each row.
	self.cols, self.offsets = {}, {}
	for row, category in ipairs(self.rows) do
		self.cols[row], self.offsets[row] = 1, 1
		for col, item in ipairs(self.by_category[category]) do
			if item.id == selected_id then self.row, self.cols[row] = row, col end
		end
	end
	self.row = clamp(1, self.row, math.max(1, #self.rows))
	self:scroll_into_view()
end

function Library:read_resume(name)
	local path = WATCH_LATER_DIR .. '/' .. name
	local info = utils.file_info(path)
	if not info then return nil end
	local file = io.open(path, 'r')
	if not file then return nil end
	local position
	for line in file:lines() do
		local value = line:match('^start=([%d%.]+)')
		if value then
			position = tonumber(value)
			break
		end
	end
	file:close()
	return position and {position = position, mtime = info.mtime} or nil
end

-- Latest play time per path from mpv's watch history (save-watch-history).
function Library:read_history()
	local played = {}
	local file = io.open(WATCH_HISTORY, 'r')
	if not file then return played end
	for line in file:lines() do
		local entry = utils.parse_json(line)
		if entry and entry.path and entry.time and entry.time > (played[entry.path] or 0) then
			played[entry.path] = entry.time
		end
	end
	file:close()
	return played
end

-- Close enough to the end to count as watched: credits, an anime ED, a stop just before EOF.
local function is_finished(resume, duration)
	return resume and duration and (duration - resume.position) <= math.max(90, duration * 0.05)
end

-- Progress and recency come from mpv's own watch_later files and watch
-- history, so they're always current.
function Library:refresh_progress()
	local history = self:read_history()
	local function last_played(path, resume)
		return math.max(history[path] or 0, resume and resume.mtime or 0)
	end
	for _, items in pairs(self.by_category) do
		for _, item in ipairs(items) do
			if item.kind == 'movie' then
				item.resume = self:read_resume(item.watch_later)
				item.last_played = last_played(item.path, item.resume)
				if is_finished(item.resume, item.duration) then item.resume = nil end
			else
				-- Continue the most recently played episode, or the one after it if that's finished.
				local latest
				item.last_played = 0
				for index, ep in ipairs(item.episodes) do
					ep.resume = self:read_resume(ep.watch_later)
					ep.last_played = last_played(ep.path, ep.resume)
					if is_finished(ep.resume, ep.duration) then ep.resume = nil end
					if ep.last_played > item.last_played then item.last_played, latest = ep.last_played, index end
				end
				item.continue = nil
				if latest then
					local index = item.episodes[latest].resume and latest or latest + 1
					if item.episodes[index] then item.continue = {ep = item.episodes[index], index = index} end
				end
			end
		end
	end
end

function Library:row_items(row) return self.rows[row] and self.by_category[self.rows[row]] or {} end
function Library:selected_item() return self:row_items(self.row)[self.cols[self.row] or 1] end

function Library:find(id)
	for _, items in pairs(self.by_category) do
		for _, item in ipairs(items) do
			if item.id == id then return item end
		end
	end
end

--[[ STATE ]]

function Library:decide_enabled()
	local enabled = state.is_idle and #self.rows > 0
	if enabled == self.enabled then return end
	self.enabled = enabled
	if enabled then
		self:refresh_progress()
		self.view, self.series = 'home', nil
		self.row, self.row_scroll = 1, 1
		self:sort_rows()
	else
		self:clear_overlays()
		self:update_bindings()
	end
	request_render()
end

function Library:on_prop_is_idle() self:decide_enabled() end
function Library:on_display() request_render() end

-- Overlays and key bindings must step aside while a menu is open.
function Library:is_covered() return Elements:has('menu') or Elements:v('curtain', 'opacity', 0) > 0 end

function Library:update_bindings()
	local want = self.enabled and not self:is_covered() and self.view or nil
	if want == self.bound then return end
	self:remove_key_bindings()
	self.bound = want
	if not want then return end

	local bindings
	if want == 'series' then
		local function by(delta) return function() self:select_episode(self.ep_selected + delta) end end
		local function rows(delta) return function() self:select_episode(self.ep_selected + delta * self.ep_cols) end end
		local function page(delta) return function() self:select_episode(self.ep_selected + delta * self.ep_cols * self.ep_rows_visible) end end
		local function play() self:play_episode(self.ep_selected) end
		local function back() self:close_series() end
		bindings = {
			left = by(-1), right = by(1), h = by(-1), l = by(1),
			up = rows(-1), down = rows(1), k = rows(-1), j = rows(1),
			pgup = page(-1), pgdwn = page(1),
			home = function() self:select_episode(1) end,
			['end'] = function() self:select_episode(#self:season_episodes()) end,
			enter = play, kp_enter = play,
			tab = function() self:set_season(self.season_index + 1) end,
			['shift+tab'] = function() self:set_season(self.season_index - 1) end,
			esc = back, bs = back, mbtn_back = back,
		}
	else
		local function col_by(delta) return function() self:select(self.row, (self.cols[self.row] or 1) + delta) end end
		local function row_by(delta) return function() self:select(self.row + delta) end end
		local function page(delta) return function() self:select(self.row, (self.cols[self.row] or 1) + delta * (self.visible_cols or 1)) end end
		local function activate() self:activate(self:selected_item()) end
		bindings = {
			left = col_by(-1), right = col_by(1), h = col_by(-1), l = col_by(1),
			up = row_by(-1), down = row_by(1), k = row_by(-1), j = row_by(1),
			pgup = page(-1), pgdwn = page(1),
			home = function() self:select(self.row, 1) end,
			['end'] = function() self:select(self.row, #self:row_items(self.row)) end,
			enter = activate, kp_enter = activate,
		}
	end
	for key, fn in pairs(bindings) do self:add_key_binding(key, {fn, {repeatable = true}}) end
end

-- Select a row (keeping its remembered column) or a specific item, and scroll it into view.
function Library:select(row, col)
	if #self.rows == 0 then return end
	self.row = clamp(1, row, #self.rows)
	local count = #self:row_items(self.row)
	self.cols[self.row] = clamp(1, col or self.cols[self.row] or 1, math.max(1, count))
	self:scroll_into_view()
	request_render()
end

function Library:scroll_into_view()
	local visible_cols, visible_rows = self.visible_cols or 1, self.visible_rows or 1
	local col = self.cols[self.row] or 1
	local offset = self.offsets[self.row] or 1
	if col < offset then offset = col end
	if col >= offset + visible_cols then offset = col - visible_cols + 1 end
	self.offsets[self.row] = offset
	if self.row < self.row_scroll then self.row_scroll = self.row end
	if self.row >= self.row_scroll + visible_rows then self.row_scroll = self.row - visible_rows + 1 end
end

function Library:scroll_rows(delta)
	self.row_scroll = clamp(1, self.row_scroll + delta, math.max(1, #self.rows - (self.visible_rows or 1) + 1))
	request_render()
end

function Library:page_row(row, delta)
	local count = #self:row_items(row)
	local visible_cols = self.visible_cols or 1
	self.offsets[row] = clamp(1, (self.offsets[row] or 1) + delta * visible_cols, math.max(1, count - visible_cols + 1))
	request_render()
end

--[[ ACTIONS ]]

function Library:activate(item)
	if not item then return end
	if item.kind == 'movie' then
		mp.commandv('loadfile', item.path)
	else
		self:open_series(item)
	end
end

function Library:open_series(item)
	local same = self.series and self.series.id == item.id
	self.view, self.series = 'series', item
	self.seasons, self.season_eps = {}, {}
	for index, ep in ipairs(item.episodes) do
		if not self.season_eps[ep.season] then
			self.season_eps[ep.season] = {}
			self.seasons[#self.seasons + 1] = ep.season
		end
		local list = self.season_eps[ep.season]
		list[#list + 1] = index
	end
	if not same then
		-- Open on the episode to continue, else the first one.
		local target = item.continue and item.continue.index or 1
		self.season_index, self.ep_selected, self.ep_scroll = 1, 1, 0
		for si, season in ipairs(self.seasons) do
			for position, index in ipairs(self.season_eps[season]) do
				if index == target then self.season_index, self.ep_selected = si, position end
			end
		end
	end
	self.ep_scroll_pending = not same
	request_render()
end

function Library:close_series()
	self.view, self.series = 'home', nil
	request_render()
end

-- Indexes (into series.episodes) of the current season.
function Library:season_episodes()
	if not self.series then return {} end
	return self.season_eps[self.seasons[self.season_index]] or {}
end

function Library:set_season(index)
	if #self.seasons < 2 then return end
	self.season_index = ((index - 1) % #self.seasons) + 1
	self.ep_selected, self.ep_scroll = 1, 0
	request_render()
end

function Library:select_episode(position)
	local count = #self:season_episodes()
	if count == 0 then return end
	self.ep_selected = clamp(1, position, count)
	self:scroll_episode_into_view()
	request_render()
end

function Library:scroll_episode_into_view()
	local cols, rows = self.ep_cols or 1, self.ep_rows_visible or 1
	local row = math.floor((self.ep_selected - 1) / cols)
	if row < self.ep_scroll then self.ep_scroll = row end
	if row >= self.ep_scroll + rows then self.ep_scroll = row - rows + 1 end
end

function Library:scroll_episodes(delta)
	local total_rows = math.ceil(#self:season_episodes() / (self.ep_cols or 1))
	self.ep_scroll = clamp(0, self.ep_scroll + delta, math.max(0, total_rows - (self.ep_rows_visible or 1)))
	request_render()
end

function Library:play_episode(position)
	local index = self:season_episodes()[position]
	if index then self:play(self.series.id, index) end
end

-- Queue the whole series so next/prev and the skip-outro button move between episodes.
function Library:play(id, index)
	local item = self:find(id)
	if not item or not index then return end
	mp.commandv('playlist-clear')
	for _, ep in ipairs(item.episodes) do mp.commandv('loadfile', ep.path, 'append') end
	mp.commandv('playlist-play-index', tostring(index - 1))
end

--[[ OVERLAYS ]]

function Library:clear_overlays()
	for id in pairs(self.overlays) do mp.commandv('overlay-remove', tostring(id)) end
	self.overlays = {}
end

-- Show exactly the given images ({file, size, x, y, w, h}); only changed slots are touched.
function Library:set_overlays(images)
	local wanted = {}
	for i, image in ipairs(images) do
		local id = OVERLAY_IDS[i]
		if not id then break end
		local signature = table.concat({image.file, image.x, image.y, image.w, image.h}, '|')
		wanted[id] = true
		if self.overlays[id] ~= signature then
			local sw, sh = image.size[1], image.size[2]
			mp.command_native({'overlay-add', id, image.x, image.y, image.file, 0, 'bgra', sw, sh, sw * 4, image.w, image.h})
			self.overlays[id] = signature
		end
	end
	for id in pairs(self.overlays) do
		if not wanted[id] then
			mp.commandv('overlay-remove', tostring(id))
			self.overlays[id] = nil
		end
	end
end

--[[ RENDERING ]]

function Library:layout()
	local s = state.scale
	local L = {
		margin = round(64 * s),
		top = round(60 * s), -- clear of the top bar
		bottom = display.height - round(96 * s), -- clear of timeline and controls
		gap = round(16 * s),
		heading_h = round(32 * s),
		caption_h = round(42 * s),
		row_gap = round(18 * s),
		title_size = round(36 * s),
		meta_size = round(14 * s),
		body_size = round(15 * s),
	}
	L.line_h = round(L.body_size * 1.45)
	L.hero_h = L.title_size + round(10 * s) + L.meta_size + round(14 * s) + 2 * L.line_h + round(26 * s)
	L.rows_y = L.top + L.hero_h

	-- Biggest 16:9 card that still fits as many rows as possible (all three ideally).
	local available = L.bottom - L.rows_y + L.row_gap
	local fixed = L.heading_h + L.caption_h + L.row_gap
	local min_w, max_w = round(150 * s), round(320 * s)
	local card_w = max_w
	for rows = math.min(3, #self.rows), 1, -1 do
		local fit_w = math.floor((available / rows - fixed) * 16 / 9)
		if fit_w >= min_w or rows == 1 then
			card_w = clamp(min_w, fit_w, max_w)
			break
		end
	end
	L.card_w, L.card_h = card_w, round(card_w * 9 / 16)
	L.row_h = L.heading_h + L.card_h + L.caption_h + L.row_gap
	self.visible_rows = math.max(1, math.min(#self.rows, math.floor(available / L.row_h)))
	self.visible_cols = math.max(1, math.floor((display.width - L.margin * 2 + L.gap) / (L.card_w + L.gap)))
	return L
end

function Library:render_hero(ass, item, L)
	local s = state.scale
	local x, y = L.margin, L.top
	local width = display.width - L.margin * 2

	txt(ass, x, y, 7, ass_escape(fit_text(item.title, width, {size = L.title_size, bold = true})), 'bold', L.title_size)
	y = y + L.title_size + round(10 * s)

	local meta = {}
	if item.year and item.year ~= 0 then meta[#meta + 1] = tostring(item.year) end
	if item.rating then meta[#meta + 1] = string.format('★ %.1f', item.rating) end
	if item.kind == 'movie' then
		meta[#meta + 1] = format_runtime(item.duration)
		meta[#meta + 1] = quality(item.width, item.height)
	else
		local seasons = {}
		for _, ep in ipairs(item.episodes) do seasons[ep.season] = true end
		local season_count = #table_keys(seasons)
		meta[#meta + 1] = season_count .. ' ' .. t(season_count == 1 and 'Season' or 'Seasons')
		meta[#meta + 1] = #item.episodes .. ' ' .. t('Episodes')
	end
	if item.genres and #item.genres > 0 then meta[#meta + 1] = table.concat(item.genres, ', ', 1, math.min(3, #item.genres)) end
	txt(ass, x, y, 7, ass_escape(table.concat(meta, '   ·   ')), 'medium', L.meta_size, {opacity = 0.7})
	y = y + L.meta_size + round(14 * s)

	if item.overview and item.overview ~= '' then
		-- About 70 characters per line reads best; never wider than the window.
		local size = L.body_size
		local line_chars = math.min(78, math.floor(width / (size * 0.5)))
		local wrapped = wrap_text(item.overview, {size = size}, line_chars)
		local lines = {}
		for line in (wrapped .. '\n'):gmatch('(.-)\n') do
			if #lines == 2 then
				lines[2] = lines[2]:gsub('[%s%p]*$', '') .. '…'
				break
			end
			lines[#lines + 1] = line
		end
		for i, line in ipairs(lines) do
			txt(ass, x, y + (i - 1) * L.line_h, 7, ass_escape(line), 'regular', size, {opacity = 0.85})
		end
	end
end

function Library:render_cell(ass, item, row, col, cx, cy, L, images)
	local s = state.scale
	local w, h = L.card_w, L.card_h
	local is_selected = row == self.row and col == self.cols[row]
	local radius = round(6 * s)

	if is_selected then
		local pad = round(3 * s)
		ass:rect(cx - pad, cy - pad, cx + w + pad, cy + h + pad, {color = config.color.match, radius = radius + pad})
	end
	if item.card then
		images[#images + 1] = {file = item.card, size = self.card_size, x = cx, y = cy, w = w, h = h}
	else
		ass:rect(cx, cy, cx + w, cy + h, {color = fg, opacity = 0.08, radius = radius})
		txt(ass, cx + w / 2, cy + h / 2, 5, ass_escape(fit_text(item.title, w - 16 * s, {size = 15 * s})), 'semibold', round(15 * s))
	end

	-- Progress bar just under the card
	local fraction
	if item.kind == 'movie' and item.resume and item.duration then
		fraction = item.resume.position / item.duration
	elseif item.continue and item.continue.ep.resume and item.continue.ep.duration then
		fraction = item.continue.ep.resume.position / item.continue.ep.duration
	end
	local bar_y = cy + h + round(6 * s)
	if fraction then
		local bar_h = math.max(2, round(3 * s))
		ass:rect(cx, bar_y, cx + w, bar_y + bar_h, {color = fg, opacity = 0.15, radius = bar_h / 2})
		ass:rect(cx, bar_y, cx + math.max(bar_h, w * clamp(0, fraction, 1)), bar_y + bar_h, {color = config.color.match, radius = bar_h / 2})
	end

	-- Widths are measured with the OSD font, so leave slack and clip to the card edges.
	local caption_w = w * 0.85
	local clip = string.format('\\clip(%d,%d,%d,%d)', cx, bar_y, cx + w, bar_y + L.caption_h)
	local title_y = bar_y + round(8 * s)
	local title_size = round(14 * s)
	txt(ass, cx, title_y, 7, ass_escape(fit_text(item.title, caption_w, {size = title_size})), 'medium', title_size, {
		color = is_selected and config.color.match or fg, clip = clip,
	})
	local sub
	if item.kind == 'movie' then
		local parts = {}
		if item.year and item.year ~= 0 then parts[#parts + 1] = tostring(item.year) end
		parts[#parts + 1] = format_runtime(item.duration)
		sub = table.concat(parts, '  ·  ')
	elseif item.continue then
		sub = t('Continue') .. ' ' .. episode_code(item.continue.ep)
	else
		sub = #item.episodes .. ' ' .. t('episodes')
	end
	local sub_size = round(12 * s)
	txt(ass, cx, title_y + round(19 * s), 7, ass_escape(fit_text(sub, caption_w, {size = sub_size})), 'regular', sub_size, {
		opacity = 0.55, clip = clip,
	})

	return {ax = cx, ay = cy, bx = cx + w, by = title_y + round(34 * s)}
end

function Library:render_row(ass, row, ry, L, images, mouse_moved)
	local s = state.scale
	local category = self.rows[row]
	local items = self:row_items(row)
	local is_current = row == self.row

	-- Heading
	local heading_size = round(21 * s)
	local label = t(category)
	txt(ass, L.margin, ry, 7, label, 'semibold', heading_size, {opacity = is_current and 1 or 0.75})
	local label_w = text_width(label, {size = heading_size, bold = true})
	txt(ass, L.margin + label_w + round(10 * s), ry + round(4 * s), 7, tostring(#items), 'regular', round(15 * s), {opacity = 0.4})

	-- Posters
	local offset = clamp(1, self.offsets[row] or 1, math.max(1, #items - self.visible_cols + 1))
	self.offsets[row] = offset
	local py = ry + L.heading_h
	for col = offset, math.min(#items, offset + self.visible_cols - 1) do
		local cx = L.margin + (col - offset) * (L.card_w + L.gap)
		local cell = self:render_cell(ass, items[col], row, col, cx, py, L, images)
		cursor:zone('primary_down', cell, function()
			self:select(row, col)
			self:activate(items[col])
		end)
		if mouse_moved and get_point_to_rectangle_proximity(cursor, cell) == 0
			and not (row == self.row and col == self.cols[row]) then
			self.row, self.cols[row] = row, col
			request_render()
		end
	end

	-- Paging arrows beside the heading when the row is wider than the window
	if #items > self.visible_cols then
		local size = round(26 * s)
		local cy = ry + round(12 * s)
		local right_x = display.width - L.margin - size / 2
		local can_left, can_right = offset > 1, offset + self.visible_cols - 1 < #items
		local function arrow(x, icon, enabled, delta)
			ass:icon(x, cy, size, icon, {color = fg, opacity = enabled and 0.9 or 0.2})
			if enabled then
				local hit = {ax = x - size / 2, ay = cy - size / 2, bx = x + size / 2, by = cy + size / 2}
				cursor:zone('primary_down', hit, function() self:page_row(row, delta) end)
			end
		end
		arrow(right_x, 'chevron_right', can_right, 1)
		arrow(right_x - size - round(6 * s), 'chevron_left', can_left, -1)
	end
end

function Library:render()
	self:update_bindings()
	if self:is_covered() then
		self:clear_overlays()
		return
	end

	if self.view == 'series' and self.series then return self:render_series() end

	local L = self:layout()
	self.row_scroll = clamp(1, self.row_scroll, math.max(1, #self.rows - self.visible_rows + 1))

	-- Mouse hover selects, but only when the mouse actually moved (keyboard wins otherwise).
	local cursor_key = cursor.x .. ',' .. cursor.y
	local mouse_moved = cursor_key ~= self.last_cursor
	self.last_cursor = cursor_key

	local ass = assdraw.ass_new()
	local images = {}
	local last_row = math.min(#self.rows, self.row_scroll + self.visible_rows - 1)
	for row = self.row_scroll, last_row do
		local ry = L.rows_y + (row - self.row_scroll) * L.row_h
		self:render_row(ass, row, ry, L, images, mouse_moved)
	end

	-- More rows below/above: a quiet hint, and the wheel scrolls rows.
	if #self.rows > self.visible_rows then
		local s = state.scale
		local more_below = self.row_scroll + self.visible_rows - 1 < #self.rows
		ass:icon(display.width / 2, L.bottom - round(12 * s), round(28 * s), more_below and 'expand_more' or 'expand_less', {
			color = fg, opacity = 0.35,
		})
	end
	local area = {ax = 0, ay = L.rows_y, bx = display.width, by = L.bottom}
	cursor:zone('wheel_down', area, function() self:scroll_rows(1) end)
	cursor:zone('wheel_up', area, function() self:scroll_rows(-1) end)

	local item = self:selected_item()
	if item then self:render_hero(ass, item, L) end
	self:set_overlays(images)
	return ass
end

--[[ SERIES PAGE ]]

function Library:series_meta(item)
	local meta = {}
	if item.year and item.year ~= 0 then meta[#meta + 1] = tostring(item.year) end
	if item.rating then meta[#meta + 1] = string.format('★ %.1f', item.rating) end
	meta[#meta + 1] = #self.seasons .. ' ' .. t(#self.seasons == 1 and 'Season' or 'Seasons')
	meta[#meta + 1] = #item.episodes .. ' ' .. t('Episodes')
	if item.genres and #item.genres > 0 then meta[#meta + 1] = table.concat(item.genres, ', ', 1, math.min(3, #item.genres)) end
	return table.concat(meta, '   ·   ')
end

function Library:render_episode(ass, ep, position, x, y, w, still_w, still_h, images)
	local s = state.scale
	local selected = position == self.ep_selected
	local radius = round(5 * s)

	if selected then
		local pad = round(3 * s)
		ass:rect(x - pad, y - pad, x + still_w + pad, y + still_h + pad, {color = config.color.match, radius = radius + pad})
	end
	if ep.thumb then
		images[#images + 1] = {file = ep.thumb, size = self.still_size, x = x, y = y, w = still_w, h = still_h}
	else
		ass:rect(x, y, x + still_w, y + still_h, {color = fg, opacity = 0.08, radius = radius})
		txt(ass, x + still_w / 2, y + still_h / 2, 5, string.format('E%02d', ep.episode), 'semibold', round(18 * s), {opacity = 0.6})
	end
	if ep.resume and ep.duration then
		local bar_h = math.max(2, round(3 * s))
		local bar_y = y + still_h + round(5 * s)
		ass:rect(x, bar_y, x + still_w, bar_y + bar_h, {color = fg, opacity = 0.15, radius = bar_h / 2})
		ass:rect(x, bar_y, x + math.max(bar_h, still_w * clamp(0, ep.resume.position / ep.duration, 1)), bar_y + bar_h, {
			color = config.color.match, radius = bar_h / 2,
		})
	end

	local tx = x + still_w + round(18 * s)
	local text_w = w - still_w - round(18 * s)
	local clip = string.format('\\clip(%d,%d,%d,%d)', tx, y - round(4 * s), x + w, y + still_h + round(4 * s))
	local title_size = round(16 * s)
	local title = string.format('%d. %s', ep.episode, ep.title)
	txt(ass, tx, y, 7, ass_escape(fit_text(title, text_w * 0.97, {size = title_size, bold = true})), 'semibold', title_size, {
		color = selected and config.color.match or fg, clip = clip,
	})

	-- Status line: progress, watched, or runtime and air date
	local status_size = round(13 * s)
	local status_y = y + round(25 * s)
	local is_next = self.series.continue and self.series.continue.ep == ep
	if ep.resume and ep.duration then
		local label = (is_next and t('Continue') or t('In progress')) .. '  ·  '
			.. format_runtime(ep.duration - ep.resume.position) .. ' ' .. t('left')
		txt(ass, tx, status_y, 7, ass_escape(label), 'medium', status_size, {color = config.color.match, clip = clip})
	else
		local details = {}
		if is_next then
			details[#details + 1] = t('Up next')
		elseif (ep.last_played or 0) > 0 then
			details[#details + 1] = '✓ ' .. t('Watched')
		end
		details[#details + 1] = format_runtime(ep.duration)
		details[#details + 1] = format_date(ep.air_date)
		txt(ass, tx, status_y, 7, ass_escape(table.concat(details, '  ·  ')), is_next and 'medium' or 'regular', status_size, {
			color = is_next and config.color.match or fg, opacity = is_next and 1 or 0.6, clip = clip,
		})
	end

	local body_size = round(13.5 * s)
	local line_h = round(body_size * 1.4)
	for i, line in ipairs(wrap_lines(ep.overview, text_w, body_size, 2)) do
		txt(ass, tx, y + round(50 * s) + (i - 1) * line_h, 7, ass_escape(line), 'regular', body_size, {opacity = 0.8, clip = clip})
	end

	return {ax = x, ay = y, bx = x + w, by = y + still_h}
end

function Library:render_series()
	local item = self.series
	local s = state.scale
	local ass = assdraw.ass_new()
	local images = {}
	local margin, top = round(64 * s), round(52 * s)
	local bottom = display.height - round(96 * s)
	local content_w = display.width - margin * 2

	local cursor_key = cursor.x .. ',' .. cursor.y
	local mouse_moved = cursor_key ~= self.last_cursor
	self.last_cursor = cursor_key

	-- Back link
	local back_size = round(15 * s)
	local back_label = t('Library')
	ass:icon(margin + round(7 * s), top + back_size / 2 + round(1 * s), round(22 * s), 'chevron_left', {color = fg, opacity = 0.7})
	txt(ass, margin + round(20 * s), top, 7, back_label, 'medium', back_size, {opacity = 0.7})
	cursor:zone('primary_down', {
		ax = margin - round(4 * s), ay = top - round(6 * s),
		bx = margin + round(28 * s) + text_width(back_label, {size = back_size}), by = top + back_size + round(6 * s),
	}, function() self:close_series() end)

	-- Header, with the series artwork on the right when there's room
	local header_y = top + back_size + round(20 * s)
	local text_w, art_bottom = content_w, 0
	if item.card and content_w >= round(900 * s) then
		local art_w = math.min(round(300 * s), math.floor(content_w * 0.28))
		local art_h = round(art_w * 9 / 16)
		images[#images + 1] = {file = item.card, size = self.card_size, x = display.width - margin - art_w, y = header_y, w = art_w, h = art_h}
		text_w = content_w - art_w - round(48 * s)
		art_bottom = header_y + art_h
	end
	local title_size, meta_size, body_size = round(36 * s), round(14 * s), round(15 * s)
	local line_h = round(body_size * 1.45)
	txt(ass, margin, header_y, 7, ass_escape(fit_text(item.title, text_w, {size = title_size, bold = true})), 'bold', title_size)
	local y = header_y + title_size + round(10 * s)
	txt(ass, margin, y, 7, ass_escape(self:series_meta(item)), 'medium', meta_size, {opacity = 0.7})
	y = y + meta_size + round(14 * s)
	for i, line in ipairs(wrap_lines(item.overview, math.min(text_w, round(78 * body_size * 0.5)), body_size, 2)) do
		txt(ass, margin, y + (i - 1) * line_h, 7, ass_escape(line), 'regular', body_size, {opacity = 0.85})
	end
	y = math.max(y + 2 * line_h, art_bottom) + round(30 * s)

	-- Season tabs (or a plain heading), with the episode count
	local eps = self:season_episodes()
	local tab_size = round(19 * s)
	local x = margin
	if #self.seasons > 1 then
		for i, season in ipairs(self.seasons) do
			local label = t('Season') .. ' ' .. season
			local active = i == self.season_index
			local w = text_width(label, {size = tab_size, bold = true})
			txt(ass, x, y, 7, label, 'semibold', tab_size, {color = active and config.color.match or fg, opacity = active and 1 or 0.55})
			if active then
				ass:rect(x, y + tab_size + round(8 * s), x + w, y + tab_size + round(11 * s), {color = config.color.match, radius = round(1.5 * s)})
			end
			cursor:zone('primary_down', {ax = x, ay = y - round(4 * s), bx = x + w, by = y + tab_size + round(12 * s)}, function()
				self:set_season(i)
			end)
			x = x + w + round(30 * s)
		end
	else
		local label = t('Episodes')
		txt(ass, x, y, 7, label, 'semibold', tab_size)
		x = x + text_width(label, {size = tab_size, bold = true}) + round(10 * s)
	end
	txt(ass, x, y + round(4 * s), 7, tostring(#eps), 'regular', round(14 * s), {opacity = 0.4})
	local list_y = y + tab_size + round(32 * s)

	-- Episode grid
	local col_gap, row_gap = round(40 * s), round(24 * s)
	local still_w = round(200 * s)
	local still_h = round(still_w * 9 / 16)
	local cols = content_w >= round(1100 * s) and 2 or 1
	local tile_w = math.floor((content_w - (cols - 1) * col_gap) / cols)
	local row_h = still_h + row_gap
	self.ep_cols = cols
	self.ep_rows_visible = math.max(1, math.floor((bottom - list_y + row_gap) / row_h))
	if self.ep_scroll_pending then
		self:scroll_episode_into_view()
		self.ep_scroll_pending = false
	end
	local total_rows = math.ceil(#eps / cols)
	self.ep_scroll = clamp(0, self.ep_scroll, math.max(0, total_rows - self.ep_rows_visible))

	local first = self.ep_scroll * cols + 1
	local last = math.min(#eps, first + cols * self.ep_rows_visible - 1)
	for position = first, last do
		local rel = position - first
		local tx = margin + (rel % cols) * (tile_w + col_gap)
		local ty = list_y + math.floor(rel / cols) * row_h
		local tile = self:render_episode(ass, item.episodes[eps[position]], position, tx, ty, tile_w, still_w, still_h, images)
		cursor:zone('primary_down', tile, function()
			self.ep_selected = position
			self:play_episode(position)
		end)
		if mouse_moved and position ~= self.ep_selected and get_point_to_rectangle_proximity(cursor, tile) == 0 then
			self.ep_selected = position
			request_render()
		end
	end

	local area = {ax = 0, ay = list_y, bx = display.width, by = bottom}
	cursor:zone('wheel_down', area, function() self:scroll_episodes(1) end)
	cursor:zone('wheel_up', area, function() self:scroll_episodes(-1) end)
	if total_rows > self.ep_rows_visible then
		local more_below = self.ep_scroll + self.ep_rows_visible < total_rows
		ass:icon(display.width / 2, bottom - round(12 * s), round(28 * s), more_below and 'expand_more' or 'expand_less', {
			color = fg, opacity = 0.35,
		})
	end

	self:set_overlays(images)
	return ass
end

return Library
