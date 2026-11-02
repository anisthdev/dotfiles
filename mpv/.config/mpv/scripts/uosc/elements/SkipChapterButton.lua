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
	-- Sized like the chapter pill in the controls row
	self.height = round(options.controls_size * state.scale)
	self.font_size = round(self.height * 0.45 * options.font_scale)
	self.icon_size = round(self.font_size * 0.85)
	self.padding_x = round(self.height * 0.4)
	self.gap = round(self.height * 0.15)
	self.margin = round(options.controls_margin * state.scale)

	local label_width = text_width(self.label, {size = self.font_size, bold = true})
	local width = math.ceil(self.padding_x * 2 + label_width + self.gap + self.icon_size)
	local x = display.width - Elements:v('window_border', 'size', 0) - self.margin - width
	local anchor_y = Elements:v('timeline', 'ay') or Elements:v('controls', 'ay')
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
	local cy = self.ay + self.height / 2
	local radius = round(UI_RADIUS * state.scale)

	-- A solid accent pill with dark text: the one control that asks for attention.
	-- Hovered, it dims a little toward the background.
	local accent = config.color.position or fg
	ass:rect(self.ax, self.ay, self.bx, self.by, {color = accent, opacity = visibility, radius = radius})
	if is_hover then
		ass:rect(self.ax, self.ay, self.bx, self.by, {color = bg, opacity = visibility * 0.12, radius = radius})
	end
	ass:txt(self.ax + self.padding_x, cy, 4, self.label, {
		size = self.font_size, weight = 600, color = bg, opacity = visibility,
	})
	ass:icon(self.bx - self.padding_x - self.icon_size / 2, cy, self.icon_size, 'skip_next', {
		color = bg, opacity = visibility,
	})

	return ass
end

return SkipChapterButton
