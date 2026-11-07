-- Title logo in the top-left corner while the controls are up, as streaming
-- apps do on pause. Logos come from reel's library (reel-scan fetches them from
-- TMDB as premultiplied BGRA); files outside the library show nothing.
--
-- "Controls are up" is read from uosc's user-data/osc/margins: its bottom margin
-- is non-zero exactly while the timeline or controls are shown (paused, or on
-- hover). The logo sits under the top bar, and hides while a uosc menu is open,
-- since overlays draw above the OSD.
--
-- script-opts/logo.conf:
--   max_width=0.22    of the window width
--   max_height=0.14   of the window height
--   margin_x=0.03     from the left edge, of the window width
--   margin_y=0.025    below the top bar, of the window height

local utils = require('mp.utils')

local o = {
	library = '~/.cache/reel/library.json',
	max_width = 0.22,
	max_height = 0.14,
	margin_x = 0.03,
	margin_y = 0.025,
}
require('mp.options').read_options(o, 'logo')

-- mpv allows overlay ids 0-63; uosc's Library uses 1-63 (not 42, thumbfast's).
local OVERLAY_ID = 0
local LIBRARY_FILE = mp.command_native({'expand-path', o.library})

local logos = {} -- video path -> {file, size}
local library_mtime = nil
local current = nil -- logo of the playing file
local margins, menu_open, osd = nil, false, nil
local shown = nil -- signature of what's on screen

local function load_library()
	local info = utils.file_info(LIBRARY_FILE)
	if not info or info.mtime == library_mtime then return end
	local file = io.open(LIBRARY_FILE, 'r')
	if not file then return end
	local data = utils.parse_json(file:read('*a'))
	file:close()
	if type(data) ~= 'table' then return end
	library_mtime = info.mtime
	logos = {}
	for _, item in ipairs(data.items or {}) do
		if item.logo and item.logo_size then
			local logo = {file = item.logo, size = item.logo_size}
			if item.path then logos[item.path] = logo end
			for _, ep in ipairs(item.episodes or {}) do logos[ep.path] = logo end
		end
	end
end

local function playing_path()
	local path = mp.get_property('path')
	if not path or path:find('^%a[%w+.-]*://') then return nil end -- streams
	if path:sub(1, 1) ~= '/' then path = utils.join_path(mp.get_property('working-directory', ''), path) end
	return (path:gsub('/%./', '/'))
end

local function update()
	local visible = current and osd and osd.w > 0 and osd.h > 0 and not menu_open
		and margins and (margins.b or 0) > 0
	if not visible then
		if shown then
			mp.command_native_async({'overlay-remove', OVERLAY_ID}, function() end)
			shown = nil
		end
		return
	end
	local sw, sh = current.size[1], current.size[2]
	local scale = math.min(osd.w * o.max_width / sw, osd.h * o.max_height / sh)
	local w, h = math.floor(sw * scale + 0.5), math.floor(sh * scale + 0.5)
	local x = math.floor(osd.w * o.margin_x + 0.5)
	local y = math.floor(osd.h * ((margins.t or 0) + o.margin_y) + 0.5)
	local signature = table.concat({current.file, x, y, w, h}, '|')
	if signature == shown then return end
	mp.command_native_async({'overlay-add', OVERLAY_ID, x, y, current.file, 0, 'bgra', sw, sh, sw * 4, w, h}, function() end)
	shown = signature
end

mp.register_event('file-loaded', function()
	load_library()
	local path = playing_path()
	current = path and logos[path] or nil
	if current and not utils.file_info(current.file) then current = nil end
	update()
end)
mp.register_event('end-file', function()
	current = nil
	update()
end)
mp.observe_property('user-data/osc/margins', 'native', function(_, value)
	margins = value
	update()
end)
mp.observe_property('user-data/uosc/menu/type', 'native', function(_, value)
	menu_open = value ~= nil
	update()
end)
mp.observe_property('osd-dimensions', 'native', function(_, value)
	osd = value
	update()
end)
