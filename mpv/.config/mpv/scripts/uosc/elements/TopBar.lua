local Element = require('elements/Element')

---@alias TopBarButtonProps {icon: string; hover_fg?: string; hover_bg?: string; command: (fun():string)}

---@class TopBar : Element
local TopBar = class(Element)

function TopBar:new() return Class.new(self) --[[@as TopBar]] end
function TopBar:init()
	Element.init(self, 'top_bar', {render_order = 4})
	self.size = 0
	self.alt_title_size = 0
	self.chapter_size = 0
	self.titles_spacing = 1
	self.icon_size, self.font_size, self.title_by = 1, 1, 1
	self.show_alt_as_main = false
	self.main_title, self.alt_title = nil, nil
	---@type table<string, string|nil>
	self.render_titles = {}
	---@type {index: number; title: string}|nil
	self.current_chapter = nil

	local function maximized_command()
		if state.platform == 'windows' then
			mp.command(state.border
				and (state.fullscreen and 'set fullscreen no;cycle window-maximized' or 'cycle window-maximized')
				or 'set window-maximized no;cycle fullscreen')
		else
			mp.command(state.fullormaxed and 'set fullscreen no;set window-maximized no' or 'set window-maximized yes')
		end
	end

	local close = {icon = 'close', hover_bg = '2311e8', hover_fg = 'ffffff', command = function() mp.command('quit') end}
	local max = {icon = 'check_box_outline_blank', command = maximized_command}
	local min = {icon = 'remove', command = function() mp.command('cycle window-minimized') end}
	self.buttons = options.top_bar_controls == 'left' and {close, max, min} or {min, max, close}

	self:register_observers()
	self:decide_enabled()
	self:update_dimensions()
end

---@return string|nil
local function expand_template(template)
	-- escape ASS, and strip newlines and trailing slashes and trim whitespace
	local tmp = mp.command_native({'expand-text', template}):gsub('\\n', ' '):gsub('[\\%s]+$', ''):gsub('^%s+', '')
	return tmp and tmp ~= '' and ass_escape(tmp) or nil
end

function TopBar:add_template_listener(template, callback)
	local props = get_expansion_props(template)
	for prop, _ in pairs(props) do
		self:observe_mp_property(prop, 'native', callback)
	end
	if not next(props) then callback() end
end

function TopBar:register_observers()
	-- Main title
	if #options.top_bar_title > 0 and options.top_bar_title ~= 'no' then
		if options.top_bar_title == 'yes' then
			local template = nil
			local function update_main_title()
				self.main_title = expand_template(template)
				self:update_render_titles()
			end
			local function remove_template_listener(callback) mp.unobserve_property(callback) end

			self:observe_mp_property('title', 'string', function(_, title)
				remove_template_listener(update_main_title)
				template = title
				if template then
					if template:sub(-6) == ' - mpv' then template = template:sub(1, -7) end
					self:add_template_listener(template, update_main_title)
				end
			end)
		elseif type(options.top_bar_title) == 'string' then
			self:add_template_listener(options.top_bar_title, function()
				self.main_title = expand_template(options.top_bar_title)
				self:update_render_titles()
			end)
		end
	end

	-- Alt title
	if #options.top_bar_alt_title > 0 and options.top_bar_alt_title ~= 'no' then
		self:add_template_listener(options.top_bar_alt_title, function()
			self.alt_title = expand_template(options.top_bar_alt_title)
			self:update_render_titles()
		end)
	end
end

function TopBar:decide_enabled()
	if options.top_bar == 'no-border' then
		self.enabled = not state.border or state.title_bar == false or state.fullscreen
	else
		self.enabled = options.top_bar == 'always'
	end
	self.enabled = self.enabled and (options.top_bar_controls or options.top_bar_title ~= 'no' or state.has_playlist)
end

-- Set titles. Both have to be passed at the same time so that they can be normalized & deduplicated.
function TopBar:update_render_titles()
	local main, alt = self.main_title, self.alt_title

	if main == 'No file' then
		main = t('No file')
	end

	-- Fall back to alt title if main is empty
	if not main or main == '' then
		main, alt = alt, nil
	end

	-- Deduplicate the main and alt titles by checking if one completely
	-- contains the other, and using only the longer one.
	if main and alt and not self.show_alt_as_main then
		local longer_title, shorter_title
		if #main < #alt then
			longer_title, shorter_title = alt, main
		else
			longer_title, shorter_title = main, alt
		end

		local escaped_shorter_title = regexp_escape(shorter_title --[[@as string]])
		if string.match(longer_title --[[@as string]], escaped_shorter_title) then
			main, alt = longer_title, nil
		end
	end

	if self.show_alt_as_main and alt and alt ~= '' then
		main, alt = alt, nil
	end

	self.render_titles.main, self.render_titles.alt = main, alt
	self:update_dimensions()
	request_render()
end

function TopBar:select_current_chapter()
	local current_chapter_index = self.current_chapter and self.current_chapter.index
	local current_chapter
	if state.time and state.chapters then
		_, current_chapter = itable_find(state.chapters, function(c) return state.time >= c.time end, #state.chapters, 1)
	end
	local new_chapter_index = current_chapter and current_chapter.index
	if current_chapter_index ~= new_chapter_index then
		self.current_chapter = current_chapter
		if itable_has(config.top_bar_flash_on, 'chapter') then
			self:flash()
		end
		self:update_dimensions()
	end
end

function TopBar:update_dimensions()
	-- Segments match the controls row: same height, margin and spacing
	self.segment = round(options.controls_size * state.scale)
	self.margin = round(options.controls_margin * state.scale)
	self.spacing = round(options.controls_spacing * state.scale)
	self.size = self.segment + self.margin
	self.title_spacing = self.spacing
	self.icon_size = round(self.segment * 0.66)
	self.font_size = round(self.segment * 0.45 * options.font_scale)
	self.alt_title_size = round(self.segment * 0.8)
	local window_border_size = Elements:v('window_border', 'size', 0)
	local min_hitbox_height = self.size
	if self.render_titles.alt and options.top_bar_alt_title_place == 'below' then
		min_hitbox_height = min_hitbox_height + self.spacing + self.alt_title_size
	end
	self.ax = window_border_size
	self.ay = window_border_size
	self.bx = display.width - window_border_size
	self.by = math.max(self.size + window_border_size, min_hitbox_height - options.proximity_in)
end

function TopBar:toggle_title()
	if options.top_bar_alt_title_place ~= 'toggle' then return end
	self.show_alt_as_main = not self.show_alt_as_main
	self:update_render_titles()
end

function TopBar:on_prop_time()
	self:select_current_chapter()
end

function TopBar:on_prop_chapters()
	self:select_current_chapter()
end

function TopBar:on_prop_border()
	self:decide_enabled()
	self:update_dimensions()
end

function TopBar:on_prop_title_bar()
	self:decide_enabled()
	self:update_dimensions()
end

function TopBar:on_prop_fullscreen()
	self:decide_enabled()
	self:update_dimensions()
end

function TopBar:on_prop_maximized()
	self:decide_enabled()
	self:update_dimensions()
end

function TopBar:on_prop_has_playlist()
	self:decide_enabled()
	self:update_dimensions()
end

function TopBar:on_display() self:update_dimensions() end

function TopBar:on_options()
	self:decide_enabled()
	self:update_dimensions()
end

-- Draws a segment like the controls row's: translucent background, quickbar corners, hover highlight
---@param corners number[]
local function segment(ass, rect, corners, visibility, hover_color)
	ass:rect(rect.ax, rect.ay, rect.bx, rect.by, {
		color = bg, opacity = visibility * config.opacity.controls, corners = corners,
	})
	if get_point_to_rectangle_proximity(cursor, rect) <= 0 then
		if hover_color then
			ass:rect(rect.ax, rect.ay, rect.bx, rect.by, {color = hover_color, opacity = visibility, corners = corners})
		else
			ass:rect(rect.ax, rect.ay, rect.bx, rect.by, {color = fg, opacity = visibility * 0.15, corners = corners})
		end
		return true
	end
	return false
end

function TopBar:render()
	local visibility = self:get_visibility()
	if visibility <= 0 then return end
	local ass = assdraw.ass_new()
	local outer, inner = round(UI_RADIUS * state.scale), round(UI_RADIUS_INNER * state.scale)
	local h, spacing = self.segment, self.spacing
	local ay = self.ay + self.margin
	local by = ay + h
	local ax, bx = self.ax + self.margin, self.bx - self.margin

	-- Window controls: one group of segments
	if options.top_bar_controls then
		local is_left = options.top_bar_controls == 'left'
		local count = #self.buttons
		local group_width = h * count + spacing * (count - 1)
		local x = is_left and ax or bx - group_width
		if is_left then ax = x + group_width + spacing * 4 else bx = x - spacing * 4 end

		for i, button in ipairs(self.buttons) do
			local rect = {ax = x, ay = ay, bx = x + h, by = by}
			local is_hover = get_point_to_rectangle_proximity(cursor, rect) <= 0
			local corners = {(i == 1 or is_hover) and outer or inner, (i == count or is_hover) and outer or inner}
			segment(ass, rect, corners, visibility, button.hover_bg)
			cursor:zone('primary_down', rect, button.command)
			ass:icon(rect.ax + h / 2, ay + h / 2, self.icon_size, button.icon, {
				color = is_hover and button.hover_fg or fg, opacity = visibility,
			})
			x = x + h + spacing
		end
	end

	-- Title group: playlist position, then the title, joined like grouped buttons
	local main_title, alt_title = self.render_titles.main, self.render_titles.alt
	local title_ay = by
	if (main_title or state.has_playlist) and bx - ax > h * 3 then
		local left_aligned = options.top_bar_controls == 'left'
		local padding = round(h * 0.4)
		local has_title = main_title and options.top_bar_title ~= 'no'
		local text_opts = {size = self.font_size, color = fg, opacity = visibility, wrap = 2}

		-- Lays out a run of segments from the aligned edge; returns their rects
		local x = left_aligned and bx or ax
		local function place(width)
			width = math.min(width, (left_aligned and x - ax) or (bx - x))
			local rect = left_aligned and {ax = x - width, ay = ay, bx = x, by = by} or {ax = x, ay = ay, bx = x + width, by = by}
			x = left_aligned and rect.ax - spacing or rect.bx + spacing
			return rect
		end

		if state.has_playlist then
			local text = state.playlist_pos .. '/' .. state.playlist_count
			local opts = {size = self.font_size, weight = 600, color = fg, opacity = visibility}
			local rect = place(round(text_width(text, opts) + padding * 2))
			local first, last = not left_aligned or not has_title, left_aligned or not has_title
			local hovered = get_point_to_rectangle_proximity(cursor, rect) <= 0
			segment(ass, rect, {(first or hovered) and outer or inner, (last or hovered) and outer or inner}, visibility)
			ass:txt(rect.ax + (rect.bx - rect.ax) / 2, ay + h / 2, 5, text, opts)
			cursor:zone('primary_down', rect, function() mp.command('script-binding uosc/playlist') end)
		end

		if has_title then
			local rect = place(round(text_width(main_title, text_opts) + padding * 2))
			local joined = state.has_playlist
			local corners = {
				(joined and not left_aligned) and inner or outer,
				(joined and left_aligned) and inner or outer,
			}
			ass:rect(rect.ax, rect.ay, rect.bx, rect.by, {
				color = bg, opacity = visibility * config.opacity.controls, corners = corners,
			})
			if options.top_bar_alt_title_place == 'toggle' then
				cursor:zone('primary_down', rect, function() self:toggle_title() end)
			end
			text_opts.clip = string.format('\\clip(%d, %d, %d, %d)', rect.ax + padding, rect.ay, rect.bx - padding, rect.by)
			ass:txt(rect.ax + padding, ay + h / 2, 4, main_title, text_opts)

			-- Alt title: a smaller pill under the title
			if alt_title and options.top_bar_alt_title_place == 'below' then
				local alt_ay, alt_h = by + spacing, self.alt_title_size
				local opts = {size = round(alt_h * 0.5 * options.font_scale), color = fg, opacity = visibility * 0.9, wrap = 2}
				local alt_padding = round(alt_h * 0.4)
				local width = math.min(round(text_width(alt_title, opts) + alt_padding * 2), bx - ax)
				local alt_ax = left_aligned and rect.bx - width or rect.ax
				ass:rect(alt_ax, alt_ay, alt_ax + width, alt_ay + alt_h, {
					color = bg, opacity = visibility * config.opacity.controls, radius = outer,
				})
				opts.clip = string.format('\\clip(%d, %d, %d, %d)', alt_ax, alt_ay, alt_ax + width - alt_padding, alt_ay + alt_h)
				ass:txt(alt_ax + alt_padding, alt_ay + alt_h / 2, 4, alt_title, opts)
				title_ay = alt_ay + alt_h
			end
		end
	end
	self.title_by = title_ay

	return ass
end

return TopBar
