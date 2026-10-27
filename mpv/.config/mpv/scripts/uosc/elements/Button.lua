local Element = require('elements/Element')

---@alias ButtonProps {icon?: string; label?: string; on_click?: function; is_clickable?: boolean; anchor_id?: string; active?: boolean; badge?: string|number; foreground?: string; background?: string; tooltip?: string}

---@class Button : Element
local Button = class(Element)

---@param id string
---@param props ButtonProps
function Button:new(id, props) return Class.new(self, id, props) --[[@as Button]] end
---@param id string
---@param props ButtonProps
function Button:init(id, props)
	self.icon = props.icon
	---@type string|nil Text drawn in place of the icon
	self.label = props.label
	self.label_dim = false
	self.active = props.active
	self.tooltip = props.tooltip
	self.badge = props.badge
	self.foreground = props.foreground or fg
	self.background = props.background or bg
	self.is_clickable = true
	-- Position in its group of buttons, set by Controls; the group's ends get the round corners
	self.group_first = true
	self.group_last = true
	---@type fun()|nil
	self.on_click = props.on_click
	Element.init(self, id, props)
end

function Button:on_coordinates() self.font_size = round((self.by - self.ay) * 0.66) end
function Button:handle_cursor_click()
	if not self.on_click or not self.is_clickable then return end
	-- We delay the callback to next tick, otherwise we are risking race
	-- conditions as we are in the middle of event dispatching.
	-- For example, handler might add a menu to the end of the element stack, and that
	-- than picks up this click event we are in right now, and instantly closes itself.
	mp.add_timeout(0.01, self.on_click)
end

function Button:render()
	local visibility = self:get_visibility()
	if visibility <= 0 then return end
	cursor:zone('primary_down', self, function() self:handle_cursor_click() end)

	local ass = assdraw.ass_new()
	local is_clickable = self.is_clickable and self.on_click ~= nil
	local is_hover = self.proximity_raw <= 0
	local foreground, background = self.foreground, self.background
	local cx, cy = self.ax + (self.bx - self.ax) / 2, self.ay + (self.by - self.ay) / 2

	-- Segment background: round outer corners, tight inner ones, fully round when hovered
	local is_highlighted = is_hover and is_clickable
	local outer, inner = round(UI_RADIUS * state.scale), round(UI_RADIUS_INNER * state.scale)
	local corners = {
		(self.group_first or is_highlighted) and outer or inner,
		(self.group_last or is_highlighted) and outer or inner,
	}
	if config.opacity.controls > 0 then
		ass:rect(self.ax, self.ay, self.bx, self.by, {
			color = background, opacity = visibility * config.opacity.controls, corners = corners,
		})
	end
	if is_highlighted then
		ass:rect(self.ax, self.ay, self.bx, self.by, {color = foreground, opacity = visibility * 0.15, corners = corners})
	end

	-- Active: accent dot under the icon
	if self.active then
		local dot_radius = math.max(1.5, 2 * state.scale)
		ass:circle(cx, self.by - dot_radius * 1.5, dot_radius, {
			color = config.color.position or foreground, opacity = visibility,
		})
	end

	-- Tooltip on hover
	if is_hover and self.tooltip then ass:tooltip(self, self.tooltip) end

	-- Badge
	local icon_clip
	if self.badge then
		local badge_font_size = self.font_size * 0.6
		local badge_opts = {size = badge_font_size, color = background, opacity = visibility}
		local badge_width = text_width(self.badge, badge_opts)
		local width, height = math.ceil(badge_width + (badge_font_size / 7) * 2), math.ceil(badge_font_size * 0.93)
		local bx, by = self.bx - 1, self.by - 1
		ass:rect(bx - width, by - height, bx, by, {
			color = foreground,
			radius = state.radius,
			opacity = visibility,
			border = 1,
			border_color = background,
		})
		ass:txt(bx - width / 2, by - height / 2, 5, self.badge, badge_opts)

		local clip_border = math.max(self.font_size / 20, 1)
		local clip_path = assdraw.ass_new()
		clip_path:round_rect_cw(
			math.floor((bx - width) - clip_border), math.floor((by - height) - clip_border), bx, by, 3
		)
		icon_clip = '\\iclip(' .. clip_path.scale .. ', ' .. clip_path.text .. ')'
	end

	-- Icon or label, lifted slightly when active to make room for the dot
	local y = round(cy - (self.active and 2 * state.scale or 0))
	if self.label then
		local opts = {
			size = round((self.by - self.ay) * 0.5 * options.font_scale),
			weight = 600,
			color = foreground,
			opacity = visibility * (self.label_dim and 0.65 or 1),
		}
		-- Shrink long labels to fit the button with a little padding
		local max_width = (self.bx - self.ax) * 0.84
		local width = text_width(self.label, opts)
		if width > max_width then opts.size = math.floor(opts.size * max_width / width) end
		ass:txt(round(cx), y, 5, self.label, opts)
	elseif self.icon then
		ass:icon(round(cx), y, self.font_size, self.icon, {color = foreground, opacity = visibility, clip = icon_clip})
	end

	return ass
end

return Button
