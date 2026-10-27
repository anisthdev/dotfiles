local Button = require('elements/Button')

-- Playback speed as a compact label in the controls row. Click opens a speed menu,
-- the wheel steps by `speed_step`, right click resets to 1×.

local SPEEDS = {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 3}

local function format_speed(speed) return (round(speed * 100) / 100) .. '×' end

---@class SpeedButton : Button
local SpeedButton = class(Button)

---@param id string
---@param props ButtonProps
function SpeedButton:new(id, props) return Class.new(self, id, props) --[[@as SpeedButton]] end
---@param id string
---@param props ButtonProps
function SpeedButton:init(id, props)
	props.tooltip = props.tooltip or t('Speed')
	props.on_click = function() self:toggle_menu() end
	Button.init(self, id, props)
	self:observe_mp_property('speed', function() self:update_label() end)
end

function SpeedButton:update_label()
	self.label = format_speed(state.speed)
	self.label_dim = math.abs(state.speed - 1) < 0.001
	request_render()
end

function SpeedButton:step(up)
	local speed = state.speed
	if options.speed_step_is_factor then
		speed = up and speed * options.speed_step or speed / options.speed_step
	else
		speed = speed + (up and options.speed_step or -options.speed_step)
	end
	mp.set_property_native('speed', clamp(0.01, round(speed * 100) / 100, 100))
end

function SpeedButton:toggle_menu()
	if Menu:is_open('speed') then
		Menu:close()
		return
	end

	local items = {}
	for _, speed in ipairs(SPEEDS) do
		items[#items + 1] = {title = format_speed(speed), value = speed, active = math.abs(state.speed - speed) < 0.001}
	end

	local menu
	menu = Menu:open({type = 'speed', title = t('Speed'), items = items}, function(event)
		if event.type == 'activate' then
			mp.set_property_native('speed', event.value)
			menu:close()
		end
	end)
end

function SpeedButton:render()
	if self:get_visibility() > 0 then
		cursor:zone('wheel_up', self, function() self:step(true) end)
		cursor:zone('wheel_down', self, function() self:step(false) end)
		cursor:zone('secondary_click', self, function() mp.set_property_native('speed', 1) end)
	end
	return Button.render(self)
end

return SpeedButton
