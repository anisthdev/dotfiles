local Button = require('elements/Button')

-- Inline volume for the controls row, used with `volume=inline`: a mute button and a
-- horizontal Material 3 slider, side by side in one segment group. Geometry matches the
-- side slider in Volume.lua. The slider stays tucked away until the speaker or slider is
-- hovered, or volume changes through the `flash-volume` binding.

local BOOST_COLOR = serialize_rgba('ffb020').color
local TRACK_HEIGHT = 12
local TRACK_PADDING = 12
local HANDLE_THICKNESS = 4
local HANDLE_THICKNESS_PRESSED = 2
local HANDLE_GAP = 4
local TRACK_INNER_RADIUS = 2
local STOP_RADIUS = 1.5
local STOP_EVERY = 20
local OPEN_DURATION = 150 -- ms the slider takes to slide out or in
local HOLD_SECONDS = 1.5 -- how long it stays out after a keyboard change

-- How far the slider is out, 0 to 1. Driven by the mute button, read by Controls to size it.
local expansion = 0
---@type InlineVolumeSlider|nil
local slider = nil

local function set_volume(volume)
	volume = round(volume / options.volume_step) * options.volume_step
	if state.volume == volume then return end
	mp.commandv('set', 'volume', clamp(0, volume, state.volume_max))
end

---@param element Element
local function add_volume_zones(element)
	cursor:zone('wheel_up', element, function() set_volume(state.volume + options.volume_step) end)
	cursor:zone('wheel_down', element, function() set_volume(state.volume - options.volume_step) end)
	cursor:zone('secondary_click', element, function()
		mp.set_property_native('mute', false)
		mp.set_property_native('volume', 100)
	end)
end

--[[ MuteButton ]]

---@class MuteButton : Button
local MuteButton = class(Button)

---@param id string
---@param props ButtonProps
function MuteButton:new(id, props) return Class.new(self, id, props) --[[@as MuteButton]] end
---@param id string
---@param props ButtonProps
function MuteButton:init(id, props)
	props.tooltip = props.tooltip or t('Mute')
	props.on_click = function() mp.commandv('cycle', 'mute') end
	Button.init(self, id, props)
	self.is_open = false
	self.hold_until = 0
	self.hold_timer = mp.add_timeout(HOLD_SECONDS, function() self:update_open() end)
	self.hold_timer:kill()
	self:update_icon()
end

function MuteButton:destroy()
	self.hold_timer:kill()
	Button.destroy(self)
end

function MuteButton:wants_open()
	local slider_hovered = slider and (slider.pressed or (slider.enabled and slider.proximity_raw <= 0))
	return self.proximity_raw <= 0 or slider_hovered or mp.get_time() < self.hold_until
end

function MuteButton:update_open()
	local open = self:wants_open() and true or false
	if open == self.is_open then return end
	self.is_open = open
	self:tween(expansion, open and 1 or 0, function(value)
		expansion = value
		Elements:maybe('controls', 'update_dimensions')
	end, OPEN_DURATION)
end

function MuteButton:on_global_mouse_move() self:update_open() end
function MuteButton:on_global_mouse_leave() self:update_open() end

-- Volume changed from the keyboard: slide out for a moment
function MuteButton:on_volume_flash()
	self.hold_until = mp.get_time() + HOLD_SECONDS
	self.hold_timer:kill()
	self.hold_timer:resume()
	self:update_open()
end

function MuteButton:update_icon()
	local volume = state.volume or 0
	if state.mute then
		self.icon = 'volume_off'
	elseif volume <= 0 then
		self.icon = 'volume_mute'
	elseif volume <= 60 then
		self.icon = 'volume_down'
	else
		self.icon = 'volume_up'
	end
end
function MuteButton:on_prop_volume() self:update_icon() end
function MuteButton:on_prop_mute() self:update_icon() end

function MuteButton:render()
	if self:get_visibility() > 0 then add_volume_zones(self) end
	return Button.render(self)
end

--[[ InlineVolumeSlider ]]

---@class InlineVolumeSlider : Button
local InlineVolumeSlider = class(Button)

---@param id string
---@param props ButtonProps
function InlineVolumeSlider:new(id, props) return Class.new(self, id, props) --[[@as InlineVolumeSlider]] end
---@param id string
---@param props ButtonProps
function InlineVolumeSlider:init(id, props)
	Button.init(self, id, props)
	self.pressed = false
	slider = self
end

function InlineVolumeSlider:destroy()
	if slider == self then slider = nil end
	Button.destroy(self)
end

-- Range the handle's center moves in, kept within the track
function InlineVolumeSlider:get_handle_range()
	local padding = round(TRACK_PADDING * state.scale)
	local half_handle = HANDLE_THICKNESS * state.scale / 2
	return self.ax + padding + half_handle, self.bx - padding - half_handle
end

function InlineVolumeSlider:set_from_cursor()
	local min_x, max_x = self:get_handle_range()
	set_volume(clamp(0, (cursor.x - min_x) / math.max(1, max_x - min_x), 1) * state.volume_max)
end

function InlineVolumeSlider:on_global_mouse_move()
	if self.pressed then self:set_from_cursor() end
end

function InlineVolumeSlider:render()
	local visibility = self:get_visibility()
	local width, height = self.bx - self.ax, self.by - self.ay
	if visibility <= 0 or width <= 0 or type(state.volume_max) ~= 'number' or state.volume_max <= 0 then return end

	cursor:zone('primary_down', self, function()
		self.pressed = true
		self:set_from_cursor()
		cursor:once('primary_up', function() self.pressed = false end)
	end)
	add_volume_zones(self)

	local ass = assdraw.ass_new()
	local is_active = self.pressed or self.proximity_raw <= 0
	self:render_segment(ass, visibility, is_active)

	-- Still sliding out: just the segment until the track fits
	local padding = round(TRACK_PADDING * state.scale)
	if width < padding * 2 + round(24 * state.scale) then return ass end

	local track_ax, track_bx = self.ax + padding, self.bx - padding
	local track_height = math.min(round(TRACK_HEIGHT * state.scale), height - round(12 * state.scale))
	local cy = self.ay + height / 2
	local tay, tby = cy - track_height / 2, cy + track_height / 2
	local outer_radius, inner_radius = track_height / 2, round(TRACK_INNER_RADIUS * state.scale)
	local min_x, max_x = self:get_handle_range()
	local function volume_to_x(volume) return min_x + (max_x - min_x) * clamp(0, volume / state.volume_max, 1) end

	local is_dim = state.mute or not state.has_audio
	local opacity = (is_dim and 0.45 or 1) * visibility
	local accent = is_dim and fg or (config.color.position or fg)
	local boost = is_dim and fg or BOOST_COLOR
	local handle_x = volume_to_x(state.volume)
	local handle_thickness = round((self.pressed and HANDLE_THICKNESS_PRESSED or HANDLE_THICKNESS) * state.scale)
	local gap = round(HANDLE_GAP * state.scale) + handle_thickness / 2
	local mark_x = state.volume_max > 100 and volume_to_x(100) or nil

	-- Active track left of the handle, in BOOST_COLOR past 100%
	local active_bx = handle_x - gap
	if active_bx - track_ax >= 1 then
		if mark_x and active_bx > mark_x then
			ass:rect(track_ax, tay, mark_x, tby, {color = accent, opacity = opacity, corners = {outer_radius, 0, 0, outer_radius}})
			ass:rect(mark_x, tay, active_bx, tby, {color = boost, opacity = opacity, corners = {0, inner_radius, inner_radius, 0}})
		else
			local corners = {outer_radius, inner_radius, inner_radius, outer_radius}
			ass:rect(track_ax, tay, active_bx, tby, {color = accent, opacity = opacity, corners = corners})
		end
	end

	-- Inactive track right of the handle
	local inactive_ax = handle_x + gap
	if track_bx - inactive_ax >= 1 then
		local corners = {inner_radius, outer_radius, outer_radius, inner_radius}
		ass:rect(inactive_ax, tay, track_bx, tby, {color = bg, opacity = config.opacity.timeline * visibility, corners = corners})
		ass:rect(inactive_ax, tay, track_bx, tby, {color = fg, opacity = 0.25 * visibility, corners = corners})
	end

	-- Faint stop dots, skipped next to the handle
	local stop_radius = math.max(1, STOP_RADIUS * state.scale)
	if (max_x - min_x) * STOP_EVERY / state.volume_max >= stop_radius * 4 then
		for volume = STOP_EVERY, state.volume_max - STOP_EVERY / 2, STOP_EVERY do
			local x = volume_to_x(volume)
			if math.abs(x - handle_x) > gap + stop_radius then
				local on_active = x < handle_x
				ass:circle(x, cy, stop_radius, {
					color = on_active and bg or fg, opacity = visibility * (on_active and 0.3 or 0.2),
				})
			end
		end
	end

	-- Handle: a thin bar taller than the track, thinner while dragging
	local handle_length = math.min(track_height + round(10 * state.scale), height - round(8 * state.scale))
	ass:rect(handle_x - handle_thickness / 2, cy - handle_length / 2, handle_x + handle_thickness / 2, cy + handle_length / 2, {
		color = state.volume > 100 and boost or accent, opacity = opacity, radius = handle_thickness / 2,
	})

	-- Value while hovered or dragged
	if is_active then ass:tooltip(self, tostring(round(state.volume))) end

	return ass
end

return {
	MuteButton = MuteButton,
	InlineVolumeSlider = InlineVolumeSlider,
	get_expansion = function() return expansion end,
}
