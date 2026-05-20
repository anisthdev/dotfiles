local Element = require('elements/Element')

---@class SkipChapterButton : Element
local SkipChapterButton = class(Element)

function SkipChapterButton:new() return Class.new(self) --[[@as SkipChapterButton]] end
function SkipChapterButton:init()
	Element.init(self, 'skip_chapter_button', {render_order = 8})
	self.height = 0
	self.font_size = 0
	self.icon_size = 0
	self.padding_x = 0
	self.gap = 0
	self.margin = 0
	self.label = ''
	self:update_dimensions()
end

function SkipChapterButton:on_display() self:update_dimensions() end
function SkipChapterButton:on_options() self:update_dimensions() end
function SkipChapterButton:on_controls_reflow() self:update_dimensions() end
function SkipChapterButton:on_prop_skippable_chapter_range() self:update_dimensions() end
function SkipChapterButton:on_prop_border() self:update_dimensions() end
function SkipChapterButton:on_prop_title_bar() self:update_dimensions() end

function SkipChapterButton:get_visibility()
	return self.enabled and Elements.curtain.opacity == 0 and 1 or 0
end

function SkipChapterButton:update_dimensions()
	local range = state.skippable_chapter_range
	self.enabled = range ~= nil and state.duration ~= nil and state.duration > 0
	if not self.enabled then
		self:set_coordinates(0, 0, 0, 0)
		return
	end

	self.label = range.title or t('Skip')
	self.font_size = round(18 * state.scale * options.font_scale)
	self.icon_size = round(self.font_size * 1.15)
	self.padding_x = round(14 * state.scale)
	self.gap = round(6 * state.scale)
	self.margin = round(10 * state.scale)
	self.height = round(34 * state.scale)

	local label_width = text_width(self.label, {size = self.font_size, bold = options.font_bold})
	local width = math.ceil(self.padding_x * 2 + label_width + self.gap + self.icon_size)
	local x = display.width - Elements:v('window_border', 'size', 0) - self.margin - width
	local anchor_y = Elements:v('controls', 'ay') or Elements:v('timeline', 'ay')
		or (display.height - Elements:v('window_border', 'size', 0))
	local y = anchor_y - self.margin - self.height

	self:set_coordinates(x, y, x + width, y + self.height)
end

function SkipChapterButton:render()
	if not self.enabled or not state.skippable_chapter_range then return end
	self:update_dimensions()

	local visibility = self:get_visibility()
	if visibility <= 0 then return end

	cursor:zone('primary_down', self, skip_active_chapter_range)

	local ass = assdraw.ass_new()
	local is_hover = self.proximity_raw <= 0
	local background_opacity = math.max(config.opacity.controls, is_hover and 0.45 or 0.35)
	local foreground = is_hover and bg or fg
	local background = is_hover and fg or bg
	local cy = self.ay + self.height / 2

	ass:rect(self.ax, self.ay, self.bx, self.by, {
		color = background,
		opacity = visibility * background_opacity,
		radius = state.radius,
		border = 1,
		border_color = fg,
	})
	ass:txt(self.ax + self.padding_x, cy, 4, self.label, {
		size = self.font_size,
		color = foreground,
		border = options.text_border * state.scale,
		border_color = background,
		opacity = visibility,
	})
	ass:icon(self.bx - self.padding_x - self.icon_size / 2, cy, self.icon_size, 'skip_next', {
		color = foreground,
		border = options.text_border * state.scale,
		border_color = background,
		opacity = visibility,
	})

	return ass
end

return SkipChapterButton
