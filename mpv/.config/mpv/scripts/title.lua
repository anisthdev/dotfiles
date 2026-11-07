-- What's playing, from reel's library (~/.cache/reel/library.json, written by
-- reel-scan with TMDB details and logos as premultiplied BGRA):
--
-- Corner logo: the title's logo top-left, under the top bar, while uosc's
-- controls are up. "Up" is read from uosc's user-data/osc/margins, whose
-- bottom margin is non-zero exactly while the timeline or controls show
-- (paused, or on hover); hidden while a uosc menu is open, since overlays
-- draw above the OSD.
--
-- Pause screen: after `pause_delay` seconds paused without the mouse moving,
-- the video dims (darker on the left) under "You're watching", the big logo
-- (or the title), the episode or the film's year, runtime and genres, and the
-- overview, with "Paused" bottom-right; uosc's elements and subtitles are
-- hidden meanwhile.
-- Moving the mouse, seeking or playing brings the normal paused view back.
--
-- Files outside the library get no corner logo, and a pause screen with just
-- mpv's media title.
--
-- script-opts/title.conf (sizes are fractions of the window):
--   logo_width=0.22 logo_height=0.14     corner logo's largest size
--   margin_x=0.03 margin_y=0.025         corner logo, from the left / below the top bar
--   pause_screen=yes pause_delay=6       seconds paused before the pause screen
--   pause_logo_width=0.34 pause_logo_height=0.2

local utils = require('mp.utils')

local o = {
	library = '~/.cache/reel/library.json',
	logo_width = 0.22,
	logo_height = 0.14,
	margin_x = 0.03,
	margin_y = 0.025,
	pause_screen = true,
	pause_delay = 6,
	pause_logo_width = 0.34,
	pause_logo_height = 0.2,
}
require('mp.options').read_options(o, 'title')

-- mpv allows overlay ids 0-63; uosc's Library uses 1-63 (not 42, thumbfast's).
-- The corner and the pause screen never show together, so they share one.
local OVERLAY_ID = 0
local LIBRARY_FILE = mp.command_native({'expand-path', o.library})
-- uosc elements hidden under the pause screen
local UOSC_ELEMENTS = 'top_bar,timeline,controls,volume,volume_toast,skip_chapter_button,pause_indicator,buffering_indicator'
local FADE_SECONDS = 0.35

local by_path = {} -- video path -> {item, episode}
local library_mtime = nil
local current = nil -- {item, episode, logo} for the playing file
local margins, menu_open, osd = nil, false, nil
local paused = false
local shown_logo = nil -- signature of the overlay on screen

-- [[ library ]]

local function load_library()
	local info = utils.file_info(LIBRARY_FILE)
	if not info or info.mtime == library_mtime then return end
	local file = io.open(LIBRARY_FILE, 'r')
	if not file then return end
	local data = utils.parse_json(file:read('*a'))
	file:close()
	if type(data) ~= 'table' then return end
	library_mtime = info.mtime
	by_path = {}
	for _, item in ipairs(data.items or {}) do
		if item.path then by_path[item.path] = {item = item} end
		for _, ep in ipairs(item.episodes or {}) do by_path[ep.path] = {item = item, episode = ep} end
	end
end

local function playing_path()
	local path = mp.get_property('path')
	if not path or path:find('^%a[%w+.-]*://') then return nil end -- streams
	if path:sub(1, 1) ~= '/' then path = utils.join_path(mp.get_property('working-directory', ''), path) end
	return (path:gsub('/%./', '/'))
end

local function lookup()
	load_library()
	local path = playing_path()
	local entry = path and by_path[path]
	if not entry then return nil end
	local item = entry.item
	local logo = nil
	if item.logo and item.logo_size and utils.file_info(item.logo) then
		logo = {file = item.logo, w = item.logo_size[1], h = item.logo_size[2]}
	end
	return {item = item, episode = entry.episode, logo = logo}
end

-- [[ overlay ]]

-- Show the logo fitted into max_w x max_h at x, y (or nothing, with no logo)
local function show_logo(logo, x, y, max_w, max_h)
	if not logo then
		if shown_logo then
			mp.command_native_async({'overlay-remove', OVERLAY_ID}, function() end)
			shown_logo = nil
		end
		return 0
	end
	local scale = math.min(max_w / logo.w, max_h / logo.h)
	local w, h = math.floor(logo.w * scale + 0.5), math.floor(logo.h * scale + 0.5)
	x, y = math.floor(x + 0.5), math.floor(y + 0.5)
	local signature = table.concat({logo.file, x, y, w, h}, '|')
	if signature ~= shown_logo then
		mp.command_native_async({'overlay-add', OVERLAY_ID, x, y, logo.file, 0, 'bgra', logo.w, logo.h, logo.w * 4, w, h}, function() end)
		shown_logo = signature
	end
	return h
end

-- [[ pause screen ]]

local screen = mp.create_osd_overlay('ass-events')
local screen_on = false
local fade = 0 -- 0..1 while fading in
local fade_timer = nil
local delay_timer = nil
local subs_were_visible = nil -- sub-visibility to restore after the screen

local function ass_escape(text)
	return (tostring(text or ''):gsub('\\', '\\\226\129\160'):gsub('{', '\\{'):gsub('\n', ' '))
end

-- Hex alpha for ASS (00 opaque, FF clear) of `opacity` faded in by `fade`
local function alpha(opacity)
	return string.format('%02X', math.floor(255 - 255 * opacity * fade + 0.5))
end

local function color(rgb) return rgb:sub(5, 6) .. rgb:sub(3, 4) .. rgb:sub(1, 2) end

-- Text is measured by libass itself (a hidden overlay's bounds): fonts'
-- metrics vary too much to guess (Google Sans Flex draws small for its size).
local measurer = mp.create_osd_overlay('ass-events')
measurer.compute_bounds, measurer.hidden = true, true
local measured = {}

local function style(size, weight)
	return string.format('{\\fn%s\\fs%d\\b%d\\bord0\\shad0\\q2}', mp.get_property('osd-font', 'sans-serif'), size, weight)
end

-- Width and height in px of one line at `size`, `weight`
local function measure(text, size, weight)
	local key = size .. '|' .. weight .. '|' .. text
	if not measured[key] then
		measurer.res_x, measurer.res_y = osd.w, osd.h
		measurer.data = '{\\an7\\pos(0,0)}' .. style(size, weight) .. ass_escape(text)
		local bounds = measurer:update()
		measured[key] = bounds and {bounds.x1 - bounds.x0, bounds.y1 - bounds.y0} or {0, 0}
	end
	return measured[key][1], measured[key][2]
end

-- Wrap to lines at most `width` px wide (libass only wraps at the window
-- edge), at most `max_lines`, the last one shortened with an ellipsis.
local function wrap(text, size, weight, width, max_lines)
	local lines, line, cut = {}, '', false
	for word in tostring(text or ''):gmatch('%S+') do
		local candidate = line == '' and word or line .. ' ' .. word
		if line ~= '' and measure(candidate, size, weight) > width then
			lines[#lines + 1] = line
			line = word
			if #lines == max_lines then cut = true break end
		else
			line = candidate
		end
	end
	if not cut and line ~= '' then lines[#lines + 1] = line end
	if cut then
		local last = lines[max_lines]
		while last:find(' ') and measure(last .. '…', size, weight) > width do last = last:gsub('%s*%S+$', '') end
		lines[max_lines] = last:gsub('[%s%p]*$', '') .. '…'
	end
	return lines
end

-- Line height for `size`: a measured line plus a little leading
local function line_height(size, weight) return select(2, measure('Ag', size, weight)) * 1.25 end

local function runtime(seconds)
	if not seconds or seconds <= 0 then return nil end
	local minutes = math.floor(seconds / 60 + 0.5)
	if minutes < 60 then return minutes .. 'm' end
	return string.format('%dh %dm', math.floor(minutes / 60), minutes % 60)
end

local function render_screen()
	if not (screen_on and osd and osd.w > 0) then return end
	local W, H = osd.w, osd.h
	local ass = {}
	local function text(x, y, an, size, weight, rgb, opacity, body)
		ass[#ass + 1] = string.format('{\\an%d\\pos(%d,%d)\\1c&H%s&\\1a&H%s&}%s%s',
			an, x, y, color(rgb), alpha(opacity), style(size, weight), body)
	end

	-- Dim: strips getting lighter to the right, eased
	local strips = 48
	for i = 0, strips - 1 do
		local t = i / (strips - 1)
		local opacity = 0.88 - 0.38 * (t * t * (3 - 2 * t))
		local x1, x2 = math.floor(W * i / strips), math.floor(W * (i + 1) / strips)
		ass[#ass + 1] = string.format('{\\an7\\pos(0,0)\\bord0\\shad0\\1c&H000000&\\1a&H%s&\\p1}m %d 0 l %d 0 %d %d %d %d{\\p0}',
			alpha(opacity), x1, x2, x2, H, x1, H)
	end

	local x = math.floor(W * 0.08)
	local width = W * 0.4
	local small, body_size = math.floor(H * 0.026), math.floor(H * 0.028)
	local item = current and current.item or {}
	local episode = current and current.episode
	local y = H * 0.27

	text(x, y, 7, small, 500, 'b3b3b3', 1, "You're watching")
	y = y + line_height(small, 500) * 1.4

	-- The logo, once faded in (overlays can't fade); else the title as text
	local logo = current and current.logo
	if logo then
		local h = fade >= 1 and show_logo(logo, x, y, W * o.pause_logo_width, H * o.pause_logo_height)
			or math.min(W * o.pause_logo_width / logo.w, H * o.pause_logo_height / logo.h) * logo.h
		y = y + h + H * 0.035
	else
		local size = math.floor(H * 0.065)
		local title = item.title or mp.get_property('media-title', '')
		for _, line in ipairs(wrap(title, size, 700, width, 2)) do
			text(x, y, 7, size, 700, 'ffffff', 1, ass_escape(line))
			y = y + line_height(size, 700)
		end
		y = y + H * 0.02
	end

	if episode then
		local heading = string.format('Season %d: Ep. %d', episode.season, episode.episode)
		text(x, y, 7, body_size, 700, 'ffffff', 1, ass_escape(heading))
		y = y + line_height(body_size, 700)
		if episode.title and episode.title ~= '' then
			for _, line in ipairs(wrap(episode.title, body_size, 500, width, 2)) do
				text(x, y, 7, body_size, 500, 'ffffff', 1, ass_escape(line))
				y = y + line_height(body_size, 500)
			end
		end
	elseif item.title then
		local facts = {}
		if item.year and item.year > 0 then facts[#facts + 1] = tostring(item.year) end
		facts[#facts + 1] = runtime(item.duration or mp.get_property_number('duration'))
		if item.genres and #item.genres > 0 then facts[#facts + 1] = table.concat(item.genres, ', ', 1, math.min(3, #item.genres)) end
		if #facts > 0 then
			text(x, y, 7, body_size, 500, 'ffffff', 1, ass_escape(table.concat(facts, '  ·  ')))
			y = y + line_height(body_size, 500)
		end
	end

	local overview = episode and episode.overview ~= '' and episode.overview or item.overview
	if overview and overview ~= '' then
		y = y + line_height(small, 400) * 0.6
		for _, line in ipairs(wrap(overview, small, 400, width, 5)) do
			text(x, y, 7, small, 400, 'd2d2d2', 1, ass_escape(line))
			y = y + line_height(small, 400)
		end
	end

	text(math.floor(W * 0.92), math.floor(H * 0.9), 3, math.floor(H * 0.032), 500, 'ffffff', 0.85, 'Paused')

	screen.res_x, screen.res_y = W, H
	screen.data = table.concat(ass, '\n')
	screen:update()
end

local update_corner

local function hide_screen()
	if delay_timer then delay_timer:kill() end
	if not screen_on then return end
	screen_on = false
	if fade_timer then fade_timer:kill() end
	screen:remove()
	show_logo(nil)
	if subs_were_visible ~= nil then mp.set_property_bool('sub-visibility', subs_were_visible) end
	subs_were_visible = nil
	mp.commandv('script-message-to', 'uosc', 'disable-elements', mp.get_script_name(), '')
	update_corner()
end

local function show_screen()
	if screen_on or not paused or menu_open then return end
	-- Video only: not for music with cover art, or while nothing plays
	local video = mp.get_property_native('current-tracks/video')
	if not video or video.image or video.albumart then return end
	screen_on = true
	fade = 0
	mp.commandv('script-message-to', 'uosc', 'disable-elements', mp.get_script_name(), UOSC_ELEMENTS)
	show_logo(nil)
	subs_were_visible = mp.get_property_bool('sub-visibility')
	mp.set_property_bool('sub-visibility', false)
	local started = mp.get_time()
	fade_timer = mp.add_periodic_timer(1 / 60, function()
		fade = math.min(1, (mp.get_time() - started) / FADE_SECONDS)
		render_screen()
		if fade >= 1 then fade_timer:kill() end
	end)
	render_screen()
end

-- (Re)start the wait for the pause screen; any activity calls this
local function arm()
	hide_screen()
	if o.pause_screen and paused then
		delay_timer = mp.add_timeout(o.pause_delay, show_screen)
	end
end

-- [[ corner logo ]]

function update_corner()
	if screen_on then return end
	local visible = current and current.logo and osd and osd.w > 0 and not menu_open
		and margins and (margins.b or 0) > 0
	if not visible then
		show_logo(nil)
		return
	end
	show_logo(current.logo, osd.w * o.margin_x, osd.h * ((margins.t or 0) + o.margin_y),
		osd.w * o.logo_width, osd.h * o.logo_height)
end

-- [[ events ]]

mp.register_event('file-loaded', function()
	current = lookup()
	arm()
	update_corner()
end)
mp.register_event('end-file', function()
	current = nil
	hide_screen()
	update_corner()
end)
mp.observe_property('pause', 'bool', function(_, value)
	paused = value
	arm()
end)
mp.observe_property('seeking', 'bool', function(_, value) if value then arm() end end)
mp.observe_property('mouse-pos', 'native', function() if screen_on or paused then arm() end end)
mp.observe_property('user-data/osc/margins', 'native', function(_, value)
	margins = value
	update_corner()
end)
mp.observe_property('user-data/uosc/menu/type', 'native', function(_, value)
	menu_open = value ~= nil
	if menu_open then hide_screen() end
	update_corner()
end)
mp.observe_property('osd-dimensions', 'native', function(_, value)
	osd = value
	render_screen()
	update_corner()
end)
