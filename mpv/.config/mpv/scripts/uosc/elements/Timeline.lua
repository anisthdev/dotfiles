local Element = require('elements/Element')

-- Track geometry in unscaled pixels. The track sits in a zone at the bottom of the
-- timeline, with the heatmap filling the space above it. The timeline sits CONTROLS_GAP
-- above the controls row.
local TRACK_SIZE = 4
local TRACK_HOVER_SIZE = 7
local TRACK_ZONE = 20
local PLAYHEAD_RADIUS = 7
local CONTROLS_GAP = 4

---@class Timeline : Element
local Timeline = class(Element)

function Timeline:new() return Class.new(self) --[[@as Timeline]] end
function Timeline:init()
	Element.init(self, 'timeline', {render_order = 5})
	---@type false|{pause: boolean, distance: number, last: {x: number, y: number}}
	self.pressed = false
	self.obstructed = false
	self.size = 0
	self.progress_size = 0
	self.min_progress_size = 0 -- used for `flash-progress`
	self.font_size = 0
	self.track_ax = 0 -- track bounds from the last render, used to map cursor to time
	self.track_bx = 0
	self.rest_by = 0 -- the window's bottom edge, where the collapsed progress line sits
	self.is_hovered = false
	self.has_thumbnail = false
	self.heatmap = nil

	self:decide_progress_size()
	self:update_dimensions()

	-- Load Youtube heatmap data if available
	self:register_mp_event('file-loaded', function()
		self.heatmap = load_youtube_heatmap()
	end)
	-- Release any dragging and clear heatmap when file gets unloaded
	self:register_mp_event('end-file', function()
		self.pressed = false
		self.heatmap = nil
	end)
end

function Timeline:get_visibility()
	return math.max(Elements:maybe('controls', 'get_visibility') or 0, Element.get_visibility(self))
end

function Timeline:decide_enabled()
	local previous = self.enabled
	self.enabled = not self.obstructed and state.duration ~= nil and state.duration > 0 and state.time ~= nil
	if self.enabled ~= previous then Elements:trigger('timeline_enabled', self.enabled) end
end

function Timeline:get_effective_size()
	local progress_size = math.max(self.min_progress_size, self.progress_size)
	return progress_size + math.ceil((self.size - self.progress_size) * self:get_visibility())
end

function Timeline:get_is_hovered() return self.enabled and self.is_hovered end

function Timeline:update_dimensions()
	self.size = round(options.timeline_size * state.scale)
	self.font_size = math.floor(math.min((self.size + 60 * state.scale) * 0.2, self.size * 0.96) * options.font_scale)
	local window_border_size = Elements:v('window_border', 'size', 0)
	local controls_ay = Elements:v('controls', 'enabled') and Elements:v('controls', 'ay')
	self.rest_by = display.height - window_border_size
	self.ax = window_border_size
	self.bx = display.width - window_border_size
	self.by = controls_ay and controls_ay - round(CONTROLS_GAP * state.scale) or self.rest_by
	self.ay = self.by - self.size
	self.width = self.bx - self.ax
	self.track_ax, self.track_bx = self.ax, self.bx

	-- Disable if not enough space
	local available_space = display.height - window_border_size * 2 - Elements:v('top_bar', 'size', 0)
	self.obstructed = available_space < self.size + 10
	self:decide_enabled()
end

function Timeline:decide_progress_size()
	local show = options.progress == 'always'
		or (options.progress == 'fullscreen' and state.fullormaxed)
		or (options.progress == 'windowed' and not state.fullormaxed)
	self.progress_size = show and options.progress_size or 0
end

function Timeline:toggle_progress()
	local current = self.progress_size
	self:tween_property('progress_size', current, current > 0 and 0 or options.progress_size)
	request_render()
end

function Timeline:flash_progress()
	if self.enabled and options.flash_duration > 0 then
		if not self._flash_progress_timer then
			self._flash_progress_timer = mp.add_timeout(options.flash_duration / 1000, function()
				self:tween_property('min_progress_size', options.progress_size, 0)
			end)
			self._flash_progress_timer:kill()
		end

		self:tween_stop()
		self.min_progress_size = options.progress_size
		request_render()
		self._flash_progress_timer.timeout = options.flash_duration / 1000
		self._flash_progress_timer:kill()
		self._flash_progress_timer:resume()
	end
end

function Timeline:get_time_at_x(x)
	local width = self.track_bx - self.track_ax
	if width <= 0 then return 0 end
	return state.duration * clamp(0, (x - self.track_ax) / width, 1)
end

---@param fast? boolean
function Timeline:set_from_cursor(fast)
	if state.time and state.duration then
		mp.commandv('seek', self:get_time_at_x(cursor.x), fast and 'absolute+keyframes' or 'absolute+exact')
	end
end

function Timeline:clear_thumbnail()
	if self.has_thumbnail then
		mp.commandv('script-message-to', 'thumbfast', 'clear')
		self.has_thumbnail = false
	end
end

function Timeline:handle_cursor_down()
	self.pressed = {pause = state.pause, distance = 0, last = {x = cursor.x, y = cursor.y}}
	mp.set_property_native('pause', true)
	self:set_from_cursor()
end
function Timeline:on_prop_duration() self:decide_enabled() end
function Timeline:on_prop_time() self:decide_enabled() end
function Timeline:on_prop_border() self:update_dimensions() end
function Timeline:on_prop_title_bar() self:update_dimensions() end
function Timeline:on_prop_fullormaxed()
	self:decide_progress_size()
	self:update_dimensions()
end
function Timeline:on_display() self:update_dimensions() end
function Timeline:on_controls_reflow() self:update_dimensions() end
function Timeline:on_options()
	self:decide_progress_size()
	self:update_dimensions()
end
function Timeline:handle_cursor_up()
	if self.pressed then
		mp.set_property_native('pause', self.pressed.pause)
		self.pressed = false
	end
end
function Timeline:on_global_mouse_leave()
	self.pressed = false
end

function Timeline:on_global_mouse_move()
	if self.pressed then
		self.pressed.distance = self.pressed.distance + get_point_to_point_proximity(self.pressed.last, cursor)
		self.pressed.last.x, self.pressed.last.y = cursor.x, cursor.y
		if state.is_video and math.abs(cursor:get_velocity().x) / self.width * state.duration > 30 then
			self:set_from_cursor(true)
		else
			self:set_from_cursor()
		end
	end
end

function Timeline:render()
	if self.size == 0 then
		self:clear_thumbnail()
		return
	end

	local size = self:get_effective_size()
	local visibility = self:get_visibility()
	self.is_hovered = false

	if size < 1 then
		self:clear_thumbnail()
		return
	end

	if self.proximity_raw <= 0 then
		self.is_hovered = true
	end
	if visibility > 0 then
		cursor:zone('primary_down', self, function()
			self:handle_cursor_down()
			cursor:once('primary_up', function() self:handle_cursor_up() end)
		end)
		if config.timeline_step ~= 0 then
			cursor:zone('wheel_down', self, function()
				mp.commandv('seek', -config.timeline_step, config.timeline_step_flag)
			end)
			cursor:zone('wheel_up', self, function()
				mp.commandv('seek', config.timeline_step, config.timeline_step_flag)
			end)
		end
	end

	local ass = assdraw.ass_new()
	local progress_size = math.max(self.min_progress_size, self.progress_size)
	local accent = config.color.position or fg
	local is_active = self.is_hovered or self.pressed ~= false

	-- 0 when collapsed to the progress line, 1 when fully revealed
	local reveal = self.size > progress_size and clamp(0, (size - progress_size) / (self.size - progress_size), 1) or 1

	-- Revealed, the track lines up with the controls row's edges and sits above it.
	-- Collapsed, it's a full width line on the window's bottom edge.
	local inset = round(options.controls_margin * state.scale) * reveal
	local tax, tbx = self.ax + inset, self.bx - inset
	local base_by = self.by + (self.rest_by - self.by) * (1 - reveal)
	local track_width = tbx - tax
	self.track_ax, self.track_bx = tax, tbx

	local track_max = TRACK_HOVER_SIZE * state.scale
	local track_size = progress_size
		+ ((is_active and track_max or TRACK_SIZE * state.scale) - progress_size) * reveal
	local cy = base_by - math.min(size, round(TRACK_ZONE * state.scale)) / 2
	local tay, tby = cy - track_size / 2, cy + track_size / 2

	local function t2x(time) return tax + track_width * clamp(0, time / state.duration, 1) end
	local progress_x = t2x(state.time)

	-- Chapter gaps cut the track into segments
	local chapter_gap_width = math.max(1, round(2 * state.scale))
	local chapter_gaps = {}
	if state.chapters then
		local half_gap = chapter_gap_width / 2
		for _, chapter in ipairs(state.chapters) do
			if chapter.time > 0.1 and chapter.time < state.duration - 0.1 then
				local chapter_x = t2x(chapter.time)
				chapter_gaps[#chapter_gaps + 1] = {ax = chapter_x - half_gap, bx = chapter_x + half_gap}
			end
		end
		table.sort(chapter_gaps, function(a, b) return a.ax < b.ax end)
		for i = #chapter_gaps, 2, -1 do
			local previous, current = chapter_gaps[i - 1], chapter_gaps[i]
			if current.ax <= previous.bx then
				previous.bx = math.max(previous.bx, current.bx)
				table.remove(chapter_gaps, i)
			end
		end
	end

	-- Every track layer is clipped to the rounded track shape, so only the ends are round
	local shape = assdraw.ass_new()
	shape:round_rect_cw(tax, tay, tbx, tby, track_size / 2)
	local track_clip = '\\clip(' .. shape.scale .. ',' .. shape.text .. ')'

	local function draw_track_range(ax, bx, opts)
		if bx <= ax then return end
		opts.clip = track_clip
		local segment_ax = ax
		for _, gap in ipairs(chapter_gaps) do
			local gap_ax = clamp(ax, gap.ax, bx)
			local gap_bx = clamp(ax, gap.bx, bx)
			if gap_bx > segment_ax then
				if gap_ax > segment_ax then ass:rect(segment_ax, tay, gap_ax, tby, opts) end
				segment_ax = gap_bx
			end
		end
		if bx > segment_ax then ass:rect(segment_ax, tay, bx, tby, opts) end
	end

	-- Track: a dark base under a light wash reads as the same grey on dark and bright video
	draw_track_range(tax, tbx, {color = bg, opacity = config.opacity.timeline})
	draw_track_range(tax, tbx, {color = fg, opacity = 0.18})

	-- Buffered: solid band over every cached range
	if state.uncached_ranges and options.timeline_cache then
		local buffered_opts = {color = fg, opacity = 0.32}
		local from = 0
		for _, range in ipairs(state.uncached_ranges) do
			if range[1] > from then draw_track_range(t2x(from), t2x(range[1]), buffered_opts) end
			from = range[2]
		end
		if from < state.duration - 0.5 then draw_track_range(t2x(from), tbx, buffered_opts) end
	end

	-- Hovered time preview between the playhead and the cursor
	local hover_x = (self.proximity_raw <= 0 or self.pressed) and clamp(tax, cursor.x, tbx) or nil
	if hover_x and reveal > 0 and not self.pressed then
		draw_track_range(math.min(progress_x, hover_x), math.max(progress_x, hover_x), {color = fg, opacity = 0.25})
	end

	-- Played
	draw_track_range(tax, progress_x, {color = accent, opacity = config.opacity.position})

	-- Custom ranges (SponsorBlock etc.)
	for _, chapter_range in ipairs(state.chapter_ranges) do
		local rax = chapter_range.start < 0.1 and tax or t2x(chapter_range.start)
		local rbx = chapter_range['end'] > state.duration - 0.1 and tbx or t2x(chapter_range['end'])
		draw_track_range(rax, rbx, {color = chapter_range.color, opacity = chapter_range.opacity})
	end

	-- Heatmap: area graph above the track, shaded with a vertical gradient that fades
	-- toward the track. ASS has no gradient fill, so the curve is drawn once per band of
	-- rows, each clipped to its band with its own opacity.
	local heatmap_ay = round(base_by - size)
	local heatmap_by = round(cy - track_max / 2 - 3 * state.scale)
	local has_heatmap = options.timeline_heatmap ~= 'no' and self.heatmap and config.opacity.heatmap > 0
		and reveal > 0 and heatmap_by - heatmap_ay > 4
	if has_heatmap then
		local opacity = config.opacity.heatmap * reveal
		local height = heatmap_by - heatmap_ay
		local band = math.max(1, round(2 * state.scale))
		for band_ay = heatmap_ay, heatmap_by - 1, band do
			local band_by = math.min(band_ay + band, heatmap_by)
			local depth = (band_ay + band_by) / 2 - heatmap_ay -- distance from the top of the strip
			ass:smooth_curve(tax, heatmap_ay, tbx, heatmap_by, self.heatmap, {
				color = fg,
				opacity = opacity * (1 - 0.75 * depth / height),
				clip = string.format('\\clip(%d,%d,%d,%d)', tax, band_ay, tbx, band_by),
			})
		end
	end

	-- Chapter hover targets
	local hovered_chapter = nil
	if config.opacity.chapters > 0 and #state.chapters > 0 and visibility > 0 then
		local hit_radius = round(8 * state.scale)
		local closest_delta = math.huge
		if self.proximity_raw < hit_radius then
			for _, chapter in ipairs(state.chapters) do
				local delta = math.sqrt((cursor.x - t2x(chapter.time)) ^ 2 + (cursor.y - cy) ^ 2)
				if delta <= hit_radius and delta < closest_delta then
					hovered_chapter, closest_delta = chapter, delta
					self.is_hovered = true
				end
			end
		end
		if hovered_chapter then
			local circle = {point = {x = t2x(hovered_chapter.time), y = cy}, r = hit_radius}
			cursor:zone('primary_down', circle, function()
				mp.commandv('seek', hovered_chapter.time, 'absolute+exact')
			end)
		end
	end

	-- A-B loop markers: ticks rising above the track
	local tick_width = math.max(1, round(2 * state.scale))
	for _, time in ipairs({state.ab_loop_a or -1, state.ab_loop_b or -1}) do
		if time >= 0 and reveal > 0 then
			local x = t2x(time)
			ass:rect(x - tick_width / 2, tay - round(5 * state.scale) * reveal, x + tick_width / 2, tby, {
				color = fg, opacity = config.opacity.chapters,
			})
		end
	end

	-- Playhead
	if is_active and reveal > 0 then
		ass:circle(progress_x, cy, PLAYHEAD_RADIUS * state.scale * reveal, {color = accent})
	end

	-- Hovered time and chapter
	local rendered_thumbnail = false
	if hover_x or hovered_chapter then
		local cursor_x = hovered_chapter and t2x(hovered_chapter.time) or hover_x
		local hovered_seconds = hovered_chapter and hovered_chapter.time or self:get_time_at_x(cursor_x)
		local tooltip_gap = round(4 * state.scale)
		local anchor_ay = has_heatmap and heatmap_ay or tay - track_max / 2
		local tooltip_anchor = {ax = cursor_x - 0.5, ay = anchor_ay, bx = cursor_x + 0.5, by = tby}

		-- Timestamp
		local opts = {
			size = self.font_size, offset = tooltip_gap, margin = tooltip_gap, timestamp = options.time_precision > 0,
		}
		local hovered_time_human = format_time(hovered_seconds, state.duration)
		opts.width_overwrite = timestamp_width(hovered_time_human, opts)
		tooltip_anchor = ass:tooltip(tooltip_anchor, hovered_time_human, opts)

		-- Thumbnail
		if not thumbnail.disabled
			and (not self.pressed or self.pressed.distance < 5)
			and thumbnail.width ~= 0
			and thumbnail.height ~= 0
		then
			local border = math.ceil(math.max(2, state.radius / 2) * state.scale)
			local thumb_x_margin, thumb_y_margin = border + tooltip_gap + self.ax, border + tooltip_gap
			local thumb_width, thumb_height = thumbnail.width, thumbnail.height
			local thumb_x = round(clamp(
				thumb_x_margin,
				cursor_x - thumb_width / 2,
				display.width - thumb_width - thumb_x_margin
			))
			local thumb_y = round(tooltip_anchor.ay - thumb_y_margin - thumb_height)
			local ax, ay = (thumb_x - border), (thumb_y - border)
			local bx, by = (thumb_x + thumb_width + border), (thumb_y + thumb_height + border)
			ass:rect(ax, ay, bx, by, {
				color = bg,
				border = 1,
				opacity = {main = config.opacity.thumbnail, border = 0.08 * config.opacity.thumbnail},
				border_color = fg,
				radius = state.radius,
			})
			local thumb_seconds = (state.rebase_start_time == false and state.start_time) and
				(hovered_seconds - state.start_time) or hovered_seconds
			mp.commandv('script-message-to', 'thumbfast', 'thumb', thumb_seconds, thumb_x, thumb_y)
			self.has_thumbnail, rendered_thumbnail = true, true
			tooltip_anchor.ay = ay
		end

		-- Chapter title
		if config.opacity.chapters > 0 and #state.chapters > 0 then
			local _, chapter = itable_find(state.chapters, function(c) return hovered_seconds >= c.time end,
				#state.chapters, 1)
			if chapter and not chapter.is_end_only then
				ass:tooltip(tooltip_anchor, chapter.title_wrapped, {
					size = self.font_size,
					offset = tooltip_gap,
					responsive = false,
					bold = true,
					width_overwrite = chapter.title_wrapped_width * self.font_size,
					lines = chapter.title_lines,
					margin = tooltip_gap,
				})
			end
		end
	end

	-- Clear thumbnail
	if not rendered_thumbnail then self:clear_thumbnail() end

	return ass
end

return Timeline
