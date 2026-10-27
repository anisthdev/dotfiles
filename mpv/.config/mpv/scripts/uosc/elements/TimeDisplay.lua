local Element = require('elements/Element')

-- "elapsed / duration" in a pill in the controls row. Its width is measured from the
-- longest time the file can show, so the row doesn't shift as the seconds tick.

---@class TimeDisplay : Element
local TimeDisplay = class(Element)

---@param id string
---@param props? ElementProps
function TimeDisplay:new(id, props) return Class.new(self, id, props) --[[@as TimeDisplay]] end
---@param id string
---@param props? ElementProps
function TimeDisplay:init(id, props) Element.init(self, id, props) end

---@param height number
function TimeDisplay:get_text_opts(height)
	return {size = round(height * 0.45 * options.font_scale), color = fg}
end

function TimeDisplay:get_duration_human()
	return state.duration and format_time(state.duration, state.duration) or '0:00'
end

---Width the pill needs at a given row height.
---@param height number
function TimeDisplay:measure(height)
	local opts = self:get_text_opts(height)
	local duration_human = self:get_duration_human()
	local padding = round(height * 0.4)
	return timestamp_width(duration_human, opts) * 2 + round(opts.size * 0.15) + text_width('/ ', opts) + padding * 2
end

function TimeDisplay:on_prop_duration() Elements:maybe('controls', 'update_dimensions') end

function TimeDisplay:render()
	local visibility = self:get_visibility()
	local height = self.by - self.ay
	if visibility <= 0 or not state.time_human or height <= 0 then return end

	local ass = assdraw.ass_new()
	local opts = self:get_text_opts(height)
	local duration_human = self:get_duration_human()
	local cy = self.ay + height / 2
	local padding = round(height * 0.4)

	ass:rect(self.ax, self.ay, self.bx, self.by, {
		color = bg, opacity = visibility * config.opacity.controls, radius = round(UI_RADIUS * state.scale),
	})

	-- Elapsed sits in a slot as wide as the duration, right aligned, so it never moves
	local elapsed_bx = self.ax + padding + timestamp_width(duration_human, opts)
	opts.opacity = visibility
	ass:timestamp(elapsed_bx, cy, 6, state.time_human, opts)
	-- libass drops leading spaces, so the gap before the slash is explicit
	opts.opacity = visibility * 0.7
	ass:txt(elapsed_bx + round(opts.size * 0.15), cy, 4, '/ ' .. duration_human, opts)
	return ass
end

return TimeDisplay
