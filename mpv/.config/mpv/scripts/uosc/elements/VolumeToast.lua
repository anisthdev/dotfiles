local Element = require('elements/Element')

-- Volume level as a number in the top right corner, for keyboard volume changes while
-- the controls are hidden (`volume=inline`). Shows for HOLD_SECONDS after the last change,
-- then fades out.

local HOLD_SECONDS = 1
local FADE_DURATION = 200 -- ms

---@class VolumeToast : Element
local VolumeToast = class(Element)

function VolumeToast:new() return Class.new(self) --[[@as VolumeToast]] end
function VolumeToast:init()
	Element.init(self, 'volume_toast', {render_order = 8})
	self.opacity = 0
	self.fade_timer = mp.add_timeout(HOLD_SECONDS, function() self:tween_property('opacity', self.opacity, 0, FADE_DURATION) end)
	self.fade_timer:kill()
end

function VolumeToast:destroy()
	self.fade_timer:kill()
	Element.destroy(self)
end

function VolumeToast:show()
	self:tween_stop()
	self.opacity = 1
	self.fade_timer:kill()
	self.fade_timer:resume()
	request_render()
end

function VolumeToast:render()
	if self.opacity <= 0 or type(state.volume_max) ~= 'number' or state.volume_max <= 0 then return end

	local ass = assdraw.ass_new()
	local height = round(options.controls_size * state.scale)
	local padding = round(height * 0.4)
	local margin = round(options.controls_margin * state.scale) + Elements:v('window_border', 'size', 0)
	local text_opts = {size = round(height * 0.45 * options.font_scale), weight = 600, color = fg, opacity = self.opacity}
	local text = state.mute and t('Muted') or tostring(round(state.volume))

	-- A pill only as wide as the number, so it reads on bright video
	local bx = display.width - margin
	local ax = bx - math.max(height, text_width(text, text_opts) + padding * 2)
	local ay = Elements:v('top_bar', 'by', 0) + margin
	ass:rect(ax, ay, bx, ay + height, {
		color = bg, opacity = self.opacity * config.opacity.controls, radius = round(UI_RADIUS * state.scale),
	})
	ass:txt(ax + (bx - ax) / 2, ay + height / 2, 5, text, text_opts)
	return ass
end

return VolumeToast
