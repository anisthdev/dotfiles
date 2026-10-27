local Element = require('elements/Element')

-- Fill color for volume boosted past 100%
local BOOST_COLOR = serialize_rgba('ffb020').color

-- Material 3 slider geometry in unscaled pixels: a thick track split by a thin handle,
-- with a gap on each side of the handle. Faint stop dots mark every STOP_EVERY percent;
-- dragging and the wheel snap to `volume_step`.
local TRACK_WIDTH = 16
local HANDLE_THICKNESS = 4
local HANDLE_THICKNESS_PRESSED = 2
local HANDLE_GAP = 4
local TRACK_INNER_RADIUS = 2
local STOP_RADIUS = 1.5
local STOP_EVERY = 20

--[[ VolumeSlider ]]

---@class VolumeSlider : Element
local VolumeSlider = class(Element)
---@param props? ElementProps
function VolumeSlider:new(props) return Class.new(self, props) --[[@as VolumeSlider]] end
function VolumeSlider:init(props)
	Element.init(self, 'volume_slider', props)
	self.pressed = false
	-- Track bounds, and the range the handle's center moves in; set in on_coordinates
	self.track_ay = 0
	self.track_by = 0
	self.handle_min_y = 0
	self.handle_max_y = 0
	self.font_size = 0
end

function VolumeSlider:get_visibility() return Elements.volume:get_visibility(self) end

function VolumeSlider:set_volume(volume)
	volume = round(volume / options.volume_step) * options.volume_step
	if state.volume == volume then return end
	mp.commandv('set', 'volume', clamp(0, volume, state.volume_max))
end

function VolumeSlider:set_from_cursor()
	local fraction = (self.handle_max_y - cursor.y) / math.max(1, self.handle_max_y - self.handle_min_y)
	self:set_volume(clamp(0, fraction, 1) * state.volume_max)
end

function VolumeSlider:on_coordinates()
	local width = self.bx - self.ax
	self.font_size = round(width * 0.45 * options.font_scale)
	-- The value sits in a square cell at the top, the track runs below it
	self.track_ay = self.ay + round(width * 0.95)
	self.track_by = self.by - round(width * 0.4)
	-- The handle stays within the track
	local half_handle = HANDLE_THICKNESS * state.scale / 2
	self.handle_min_y, self.handle_max_y = self.track_ay + half_handle, self.track_by - half_handle
end
function VolumeSlider:on_global_mouse_move()
	if self.pressed then self:set_from_cursor() end
end
function VolumeSlider:handle_wheel_up() self:set_volume(state.volume + options.volume_step) end
function VolumeSlider:handle_wheel_down() self:set_volume(state.volume - options.volume_step) end

function VolumeSlider:render()
	local visibility = self:get_visibility()
	local width = self.bx - self.ax
	local track_ay, track_by = self.track_ay, self.track_by

	if width <= 0 or track_by <= track_ay or visibility <= 0 then return end
	if type(state.volume_max) ~= 'number' or state.volume_max <= 0 then return end

	cursor:zone('primary_down', self, function()
		self.pressed = true
		self:set_from_cursor()
		cursor:once('primary_up', function() self.pressed = false end)
	end)
	cursor:zone('wheel_down', self, function() self:handle_wheel_down() end)
	cursor:zone('wheel_up', self, function() self:handle_wheel_up() end)

	local ass = assdraw.ass_new()
	local is_active = self.pressed or self.proximity_raw <= 0

	-- Segment background: top of the vertical group with the mute button, fully round when active
	local outer, inner = round(UI_RADIUS * state.scale), round(UI_RADIUS_INNER * state.scale)
	local bottom = is_active and outer or inner
	local corners = {outer, outer, bottom, bottom}
	ass:rect(self.ax, self.ay, self.bx, self.by, {
		color = bg, opacity = visibility * config.opacity.controls, corners = corners,
	})
	if is_active then
		ass:rect(self.ax, self.ay, self.bx, self.by, {color = fg, opacity = visibility * 0.15, corners = corners})
	end

	local cx = self.ax + width / 2
	local track_width = math.min(round(TRACK_WIDTH * state.scale), width - round(8 * state.scale))
	local tax, tbx = cx - track_width / 2, cx + track_width / 2
	local outer_radius, inner_radius = track_width / 2, round(TRACK_INNER_RADIUS * state.scale)
	local function volume_to_y(volume)
		local fraction = clamp(0, volume / state.volume_max, 1)
		return self.handle_max_y - (self.handle_max_y - self.handle_min_y) * fraction
	end

	local is_dim = state.mute or not state.has_audio
	local opacity = (is_dim and 0.45 or 1) * visibility
	local accent = is_dim and fg or (config.color.position or fg)
	local boost = is_dim and fg or BOOST_COLOR
	local handle_y = volume_to_y(state.volume)
	local handle_thickness = round((self.pressed and HANDLE_THICKNESS_PRESSED or HANDLE_THICKNESS) * state.scale)
	local gap = round(HANDLE_GAP * state.scale) + handle_thickness / 2
	local mark_y = state.volume_max > 100 and volume_to_y(100) or nil

	-- Inactive track above the handle: round at the top, tight corners facing the handle
	local inactive_by = handle_y - gap
	if inactive_by - track_ay >= 1 then
		local corners = {outer_radius, outer_radius, inner_radius, inner_radius}
		ass:rect(tax, track_ay, tbx, inactive_by, {color = bg, opacity = config.opacity.timeline * visibility, corners = corners})
		ass:rect(tax, track_ay, tbx, inactive_by, {color = fg, opacity = 0.25 * visibility, corners = corners})
	end

	-- Active track below the handle, in BOOST_COLOR past 100%
	local active_ay = handle_y + gap
	if track_by - active_ay >= 1 then
		if mark_y and active_ay < mark_y then
			ass:rect(tax, active_ay, tbx, mark_y, {color = boost, opacity = opacity, corners = {inner_radius, inner_radius, 0, 0}})
			ass:rect(tax, mark_y, tbx, track_by, {color = accent, opacity = opacity, corners = {0, 0, outer_radius, outer_radius}})
		else
			local corners = {inner_radius, inner_radius, outer_radius, outer_radius}
			ass:rect(tax, active_ay, tbx, track_by, {color = accent, opacity = opacity, corners = corners})
		end
	end

	-- Stop dots, skipped next to the handle; 100% gets a bigger one
	local step = STOP_EVERY
	local stop_spacing = step > 0 and (self.handle_max_y - self.handle_min_y) * step / state.volume_max or 0
	local stop_radius = math.max(1, STOP_RADIUS * state.scale)
	if stop_spacing >= stop_radius * 4 then
		for volume = step, state.volume_max - step / 2, step do
			local y = volume_to_y(volume)
			local is_mark = volume == 100 and mark_y ~= nil
			local radius = is_mark and stop_radius * 1.6 or stop_radius
			if math.abs(y - handle_y) > gap + radius then
				local on_active = y > handle_y
				-- Dark on the light active track, light on the grey inactive one
				ass:circle(cx, y, radius, {
					color = on_active and bg or fg, opacity = visibility * (is_mark and 0.45 or (on_active and 0.3 or 0.2)),
				})
			end
		end
	end

	-- Handle: a thin bar wider than the track, thinner while dragging
	local handle_length = math.min(track_width + round(10 * state.scale), width - round(6 * state.scale))
	ass:rect(cx - handle_length / 2, handle_y - handle_thickness / 2, cx + handle_length / 2, handle_y + handle_thickness / 2, {
		color = state.volume > 100 and boost or accent, opacity = opacity, radius = handle_thickness / 2,
	})

	-- Value, in the speed label's weight
	ass:txt(cx, self.ay + width * 0.5, 5, tostring(round(state.volume)), {
		size = self.font_size, weight = 600, color = fg, opacity = visibility * (is_active and 1 or 0.8),
	})

	return ass
end

--[[ Volume ]]

---@class Volume : Element
local Volume = class(Element)

function Volume:new() return Class.new(self) --[[@as Volume]] end
function Volume:init()
	Element.init(self, 'volume', {render_order = 7})
	self.size = 0
	self.mute_ay = 0 -- top of the mute button segment
	self.gap = 0 -- between the slider and mute segments
	self.slider = VolumeSlider:new({anchor_id = 'volume', render_order = self.render_order})
	self:update_dimensions()
end

function Volume:destroy()
	self.slider:destroy()
	Element.destroy(self)
end

function Volume:get_visibility()
	if not state.is_idle and not state.has_audio then return 0 end
	return self.slider.pressed and 1 or Elements:maybe('timeline', 'get_is_hovered') and -1
		or Element.get_visibility(self)
end

function Volume:update_dimensions()
	self.size = round(options.volume_size * state.scale)
	local min_y = Elements:v('top_bar', 'by') or Elements:v('window_border', 'size', 0)
	local max_y = Elements:v('timeline', 'ay') or Elements:v('controls', 'ay')
		or display.height - Elements:v('window_border', 'size', 0)
	local available_height = max_y - min_y
	local max_height = available_height * 0.85
	local height = round(math.min(self.size * 11, max_height))
	self.enabled = height > self.size * 2 -- don't render if too small
	-- Lines up with the controls row's edge
	local margin = round(options.controls_margin * state.scale) + Elements:v('window_border', 'size', 0)
	self.ax = round(options.volume == 'left' and margin or display.width - margin - self.size)
	self.ay = min_y + round((available_height - height) / 2)
	self.bx = round(self.ax + self.size)
	self.by = round(self.ay + height)
	self.mute_ay = self.by - self.size
	self.gap = round(2 * state.scale)
	self.slider.enabled = self.enabled
	self.slider:set_coordinates(self.ax, self.ay, self.bx, self.mute_ay - self.gap)
end

function Volume:on_display() self:update_dimensions() end
function Volume:on_prop_border() self:update_dimensions() end
function Volume:on_prop_title_bar() self:update_dimensions() end
function Volume:on_prop_volume_max() self:update_dimensions() end
function Volume:on_controls_reflow() self:update_dimensions() end
function Volume:on_options() self:update_dimensions() end

function Volume:render()
	local visibility = self:get_visibility()
	if visibility <= 0 then return end

	-- Reset volume on secondary click
	cursor:zone('secondary_click', self, function()
		mp.set_property_native('mute', false)
		mp.set_property_native('volume', 100)
	end)

	-- Mute button
	local mute_rect = {ax = self.ax, ay = self.mute_ay, bx = self.bx, by = self.by}
	cursor:zone('primary_down', mute_rect, function() mp.commandv('cycle', 'mute') end)
	local ass = assdraw.ass_new()
	local width_half = (mute_rect.bx - mute_rect.ax) / 2
	local height_half = (mute_rect.by - mute_rect.ay) / 2
	local icon_size = round(math.min(width_half, height_half) * 2 * 0.66)

	-- Segment background: bottom of the vertical group, fully round when hovered
	local is_hover = get_point_to_rectangle_proximity(cursor, mute_rect) <= 0
	local outer, inner = round(UI_RADIUS * state.scale), round(UI_RADIUS_INNER * state.scale)
	local top = is_hover and outer or inner
	local corners = {top, top, outer, outer}
	ass:rect(mute_rect.ax, mute_rect.ay, mute_rect.bx, mute_rect.by, {
		color = bg, opacity = visibility * config.opacity.controls, corners = corners,
	})
	if is_hover then
		ass:rect(mute_rect.ax, mute_rect.ay, mute_rect.bx, mute_rect.by, {
			color = fg, opacity = visibility * 0.15, corners = corners,
		})
	end

	local icon_name = 'volume_up'
	if state.mute then
		icon_name = 'volume_off'
	elseif state.volume <= 0 then
		icon_name = 'volume_mute'
	elseif state.volume <= 60 then
		icon_name = 'volume_down'
	end
	ass:icon(mute_rect.ax + width_half, mute_rect.ay + height_half, icon_size, icon_name, {
		color = fg, opacity = visibility, align = 5,
	})
	return ass
end

return Volume
