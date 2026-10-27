local Element = require('elements/Element')

-- Current chapter title in a pill with a chevron, filling the free space in the controls
-- row. Clicking it opens the chapters menu.

---@class ChapterTitle : Element
local ChapterTitle = class(Element)

---@param id string
---@param props? ElementProps
function ChapterTitle:new(id, props) return Class.new(self, id, props) --[[@as ChapterTitle]] end
---@param id string
---@param props? ElementProps
function ChapterTitle:init(id, props) Element.init(self, id, props) end

function ChapterTitle:render()
	local visibility = self:get_visibility()
	local height = self.by - self.ay
	if visibility <= 0 or self.bx - self.ax < height or not state.time or #state.chapters == 0 then return end

	local _, chapter = itable_find(state.chapters, function(c) return state.time >= c.time end, #state.chapters, 1)
	if not chapter or not chapter.title or chapter.title == '' then return end

	local ass = assdraw.ass_new()
	local cy = self.ay + height / 2
	local text_opts = {size = round(height * 0.45 * options.font_scale), color = fg, opacity = visibility * 0.9}
	local padding = round(height * 0.4)
	local icon_size = round(height * 0.5)
	local text_ax = self.ax + padding
	local max_text_width = self.bx - self.ax - padding * 2 - icon_size
	local text_bx = text_ax + math.min(text_width(chapter.title, text_opts), max_text_width)
	local pill = {ax = self.ax, ay = self.ay, bx = round(text_bx + icon_size + padding * 0.6), by = self.by}
	local is_hover = get_point_to_rectangle_proximity(cursor, pill) <= 0

	-- Deferred like Button clicks, so the opening menu doesn't catch this same click
	cursor:zone('primary_down', pill, function()
		mp.add_timeout(0.01, function() mp.command('script-binding uosc/chapters') end)
	end)

	ass:rect(pill.ax, pill.ay, pill.bx, pill.by, {
		color = bg, opacity = visibility * config.opacity.controls, radius = round(UI_RADIUS * state.scale),
	})
	if is_hover then
		ass:rect(pill.ax, pill.ay, pill.bx, pill.by, {color = fg, opacity = visibility * 0.15, radius = round(UI_RADIUS * state.scale)})
	end

	text_opts.clip = string.format('\\clip(%d,%d,%d,%d)', self.ax, self.ay, round(text_bx), self.by)
	ass:txt(text_ax, cy, 4, chapter.title, text_opts)
	ass:icon(text_bx + icon_size / 2, cy, icon_size, 'chevron_right', {color = fg, opacity = visibility * 0.9})
	return ass
end

return ChapterTitle
