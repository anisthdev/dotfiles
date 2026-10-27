local Element = require('elements/Element')

--[[ VolumeSlider ]]

---@class VolumeSlider : Element
local VolumeSlider = class(Element)
---@param props? ElementProps
function VolumeSlider:new(props) return Class.new(self, props) --[[@as VolumeSlider]] end
function VolumeSlider:init(props)
	Element.init(self, 'volume_slider', props)
	self.pressed = false
	-- Track bounds, set in on_coordinates
	self.track_ay = 0
	self.track_by = 0
	self.font_size = 0
end

function VolumeSlider:get_visibility() return Elements.volume:get_visibility(self) end

function VolumeSlider:set_volume(volume)
	volume = round(volume / options.volume_step) * options.volume_step
	if state.volume == volume then return end
	mp.commandv('set', 'volume', clamp(0, volume, state.volume_max))
end

function VolumeSlider:set_from_cursor()
	local fraction = (self.track_by - cursor.y) / math.max(1, self.track_by - self.track_ay)
	self:set_volume(clamp(0, fraction, 1) * state.volume_max)
end

function VolumeSlider:on_coordinates()
	local width = self.bx - self.ax
	self.font_size = round(width * 0.45 * options.font_scale)
	self.track_ay = self.ay + round(self.font_size * 1.5)
	self.track_by = self.by - round(width * 0.15)
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
	local cx = self.ax + width / 2
	local track_width = round((is_active and 7 or 4) * state.scale)
	local tax, tbx = cx - track_width / 2, cx + track_width / 2
	local radius = track_width / 2
	local function volume_to_y(volume)
		return track_by - (track_by - track_ay) * clamp(0, volume / state.volume_max, 1)
	end

	-- Track: same dark base under a light wash as the timeline
	ass:rect(tax, track_ay, tbx, track_by, {color = bg, opacity = config.opacity.timeline * visibility, radius = radius})
	ass:rect(tax, track_ay, tbx, track_by, {color = fg, opacity = 0.18 * visibility, radius = radius})

	-- Level, greyed out when muted or there's no audio
	local level_y = volume_to_y(state.volume)
	if track_by - level_y > 0.5 then
		local is_dim = state.mute or not state.has_audio
		ass:rect(tax, math.min(level_y, track_by - track_width), tbx, track_by, {
			color = is_dim and fg or (config.color.position or fg),
			opacity = (is_dim and 0.45 or 1) * visibility,
			radius = radius,
		})
	end

	-- 100% mark when the volume can be boosted past it
	if state.volume_max > 100 then
		local y = round(volume_to_y(100))
		local half = track_width / 2 + round(3 * state.scale)
		ass:rect(cx - half, y, cx + half, y + math.max(1, round(state.scale)), {color = fg, opacity = 0.6 * visibility})
	end

	-- Value
	ass:txt(cx, self.ay + (track_ay - self.ay) / 2, 5, tostring(round(state.volume)), {
		size = self.font_size,
		color = fg,
		border = options.text_border * state.scale,
		border_color = bg,
		opacity = visibility * (is_active and 1 or 0.7),
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
	self.mute_ay = 0
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
	local max_height = available_height * 0.8
	local height = round(math.min(self.size * 8, max_height))
	self.enabled = height > self.size * 2 -- don't render if too small
	local margin = (self.size / 2) + Elements:v('window_border', 'size', 0)
	self.ax = round(options.volume == 'left' and margin or display.width - margin - self.size)
	self.ay = min_y + round((available_height - height) / 2)
	self.bx = round(self.ax + self.size)
	self.by = round(self.ay + height)
	self.mute_ay = self.by - self.size
	self.slider.enabled = self.enabled
	self.slider:set_coordinates(self.ax, self.ay, self.bx, self.mute_ay)
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
	local icon_size = math.min(width_half, height_half) * 1.5
	local icon_name = 'volume_up'
	if state.mute then
		icon_name = 'volume_off'
	elseif state.volume <= 0 then
		icon_name = 'volume_mute'
	elseif state.volume <= 60 then
		icon_name = 'volume_down'
	end
	ass:icon(mute_rect.ax + width_half, mute_rect.ay + height_half, icon_size, icon_name, {
		color = fg, border = options.text_border * state.scale, border_color = bg, opacity = visibility, align = 5,
	})
	return ass
end

return Volume
