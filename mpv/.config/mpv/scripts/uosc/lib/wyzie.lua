-- Wyzie Subs (sub.wyzie.io): subtitle search by IMDb/TMDB id, for the subtitle downloader menu.
-- Finds what's playing in reel's library.json first; anything else is guessed from its file
-- name and looked up on TMDB (reel's token). The key lives in ~~/wyzie_key, out of git.

local wyzie = {}

local API = 'https://sub.wyzie.io/search'
local TMDB = 'https://api.themoviedb.org/3'
local LIBRARY_FILE = '~/.cache/reel/library.json'
local KEY_FILE = '~~/wyzie_key'
local TMDB_TOKEN_FILE = '~/.config/reel/tmdb_token'

local function read_file(path)
	local file = io.open(mp.command_native({'expand-path', path}), 'r')
	if not file then return nil end
	local content = file:read('*a')
	file:close()
	return content
end

local function read_secret(path)
	local content = read_file(path)
	content = content and content:match('^%s*(.-)%s*$')
	return content ~= '' and content or nil
end

local function url_encode(str)
	return (tostring(str):gsub('[^%w%-%._~]', function(c) return string.format('%%%02X', c:byte()) end))
end

local function query_string(params)
	local parts = {}
	for k, v in pairs(params) do
		if v ~= nil and v ~= '' then parts[#parts + 1] = k .. '=' .. url_encode(v) end
	end
	table.sort(parts)
	return table.concat(parts, '&')
end

local function curl_quote(str) return '"' .. str:gsub('[\\"]', '\\%0') .. '"' end

-- curl, async. Calls back with (error, body); error is set on non-2xx or network failure.
-- URL and headers go through stdin (curl -K -), not argv; mpv's verbose log still shows them.
-- `query_files` adds name=<file's content> query params, read by curl itself, so those never show.
---@param opts {url: string, headers?: string[], query_files?: table<string, string>, output?: string}
---@param callback fun(error: string|nil, body: string|nil)
local function curl(opts, callback)
	local config = {'url = ' .. curl_quote(opts.url)}
	for _, header in ipairs(opts.headers or {}) do config[#config + 1] = 'header = ' .. curl_quote(header) end
	local args = {'curl', '-sS', '-L', '--max-time', '20', '-w', '\n%{http_code}', '-K', '-'}
	if opts.output then itable_append(args, {'--create-dirs', '-o', opts.output}) end
	for name, file in pairs(opts.query_files or {}) do itable_append(args, {'--url-query', name .. '@' .. file}) end
	mp.command_native_async({
		name = 'subprocess',
		capture_stdout = true,
		capture_stderr = true,
		playback_only = false,
		stdin_data = table.concat(config, '\n') .. '\n',
		args = args,
	}, function(success, result, error)
		if not success or not result or result.status ~= 0 then
			callback('curl failed: ' .. tostring(error or (result and result.stderr)), nil)
			return
		end
		local body, code = result.stdout:match('^(.*)\n(%d+)$')
		code = tonumber(code)
		if not code or code < 200 or code >= 300 then
			local data = body and utils.parse_json(body)
			local message = type(data) == 'table' and data.message or body
			callback('HTTP ' .. tostring(code) .. ': ' .. tostring(message), body)
			return
		end
		callback(nil, body)
	end)
end

---@alias WyzieMedia {id: string|number, title: string, season?: integer, episode?: integer}

-- The playing file's entry in reel's library, if it's there.
---@param path string
---@return WyzieMedia|nil
local function from_library(path)
	local content = read_file(LIBRARY_FILE)
	local library = content and utils.parse_json(content)
	if type(library) ~= 'table' or type(library.items) ~= 'table' then return nil end
	path = normalize_path_lite(path)
	for _, item in ipairs(library.items) do
		local id = item.imdb_id or item.tmdb_id
		if id then
			if item.kind == 'movie' and item.path and normalize_path_lite(item.path) == path then
				return {id = id, title = item.title .. (item.year and ' (' .. item.year .. ')' or '')}
			end
			for _, ep in ipairs(item.episodes or {}) do
				if ep.path and normalize_path_lite(ep.path) == path and ep.season and ep.episode then
					return {id = id, title = item.title, season = ep.season, episode = ep.episode}
				end
			end
		end
	end
end

-- Title, year, season and episode from a release name like Show.Name.S01E02.1080p.WEB-DL.
---@param name string
---@return {title: string, year?: string, season?: integer, episode?: integer}
function wyzie.parse_name(name)
	local text = name:gsub('^%b[]%s*', ''):gsub('[._]', ' ')
	local result = {}

	local s_start, _, season, episode = text:find('[Ss](%d%d?)%s?[Ee](%d%d?%d?)')
	if not s_start then s_start, _, season, episode = text:find('%f[%d](%d%d?)x(%d%d%d?)%f[%D]') end
	if s_start then
		result.season, result.episode = tonumber(season), tonumber(episode)
		text = text:sub(1, s_start - 1)
	end

	-- The last year-like number: "Blade Runner 2049 2017" is from 2017
	local y_start, year
	local init = 1
	while true do
		local s, e, y = text:find('[%(%[%s](%d%d%d%d)[%)%]]?%f[%D]', init)
		if not s then break end
		if tonumber(y) >= 1900 and tonumber(y) <= 2100 then y_start, year = s, y end
		init = e
	end
	if y_start then
		result.year = year
		text = text:sub(1, y_start - 1)
	else
		-- No year: cut at the first release tag
		local tag = text:lower():find('%f[%w]%d%d%d%d?p%f[%W]')
			or text:lower():find('%f[%w]bluray%f[%W]') or text:lower():find('%f[%w]web')
		if tag then text = text:sub(1, tag - 1) end
	end

	result.title = text:gsub('[%(%[%-%s]+$', ''):gsub('%s+', ' '):match('^%s*(.-)%s*$')
	return result
end

-- Looks a parsed title up on TMDB.
---@param parsed {title: string, year?: string, season?: integer, episode?: integer}
---@param callback fun(error: string|nil, media: WyzieMedia|nil)
local function from_tmdb(parsed, callback)
	local token = read_secret(TMDB_TOKEN_FILE) or os.getenv('TMDB_TOKEN')
	if not token then
		callback('No TMDB token (' .. TMDB_TOKEN_FILE .. ') to identify "' .. parsed.title .. '"')
		return
	end
	local is_tv = parsed.season ~= nil
	local url = TMDB .. '/search/' .. (is_tv and 'tv' or 'movie') .. '?' .. query_string({
		query = parsed.title,
		[is_tv and 'first_air_date_year' or 'year'] = parsed.year,
	})
	curl({url = url, headers = {'Authorization: Bearer ' .. token}}, function(error, body)
		if error then return callback('TMDB: ' .. error) end
		local data = utils.parse_json(body or '')
		local hit = type(data) == 'table' and type(data.results) == 'table' and data.results[1]
		if not hit then return callback(nil, nil) end
		local title = hit.title or hit.name or parsed.title
		local date = hit.release_date or hit.first_air_date
		if not is_tv and date and #date >= 4 then title = title .. ' (' .. date:sub(1, 4) .. ')' end
		callback(nil, {id = hit.id, title = title, season = parsed.season, episode = parsed.episode})
	end)
end

-- What's playing, or what the typed query names.
---@param opts {path?: string, query?: string}
---@param callback fun(error: string|nil, media: WyzieMedia|nil)
function wyzie.identify(opts, callback)
	if not opts.query and opts.path and not is_protocol(opts.path) then
		local media = from_library(opts.path)
		if media then return callback(nil, media) end
	end
	local name = opts.query
	if not name and opts.path then
		local serialized = serialize_path(opts.path)
		name = serialized and serialized.filename
	end
	if not name or name == '' then return callback(nil, nil) end
	local parsed = wyzie.parse_name(name)
	if parsed.title == '' then return callback(nil, nil) end
	from_tmdb(parsed, callback)
end

---@param media WyzieMedia
---@param opts {languages: string[], video?: string}
---@param callback fun(error: string|nil, subs: table[]|nil)
function wyzie.search(media, opts, callback)
	local key_path = mp.command_native({'expand-path', KEY_FILE})
	local raw_key = read_file(KEY_FILE)
	local key = read_secret(KEY_FILE) or os.getenv('WYZIE_KEY')
	if not key then return callback('No Wyzie API key; put it in ' .. KEY_FILE) end
	-- curl reads the key from the file when it's exactly the key (an editor's trailing newline would go in too)
	local key_from_file = raw_key == key
	local url = API .. '?' .. query_string({
		id = media.id,
		season = media.season,
		episode = media.episode,
		language = table.concat(opts.languages, ','),
		video = opts.video,
		key = not key_from_file and key or nil,
	})
	curl({url = url, query_files = key_from_file and {key = key_path} or nil}, function(error, body)
		if error and error:match('^HTTP 404') then return callback(nil, {}) end -- "No subtitles found"
		if error then return callback('Wyzie: ' .. error) end
		local data = utils.parse_json(body or '')
		if type(data) ~= 'table' then return callback('Wyzie: invalid response') end
		callback(nil, data)
	end)
end

---@param url string
---@param destination string
---@param callback fun(error: string|nil)
function wyzie.download(url, destination, callback)
	curl({url = url, output = destination}, function(error) callback(error and 'Wyzie: ' .. error) end)
end

-- ISO 639-1 codes from mpv's language list (slang has en,eng; Wyzie wants en).
---@param languages string[]
---@return string[]
function wyzie.languages(languages)
	local result, seen = {}, {}
	for _, lang in ipairs(languages) do
		lang = lang:lower()
		if #lang == 2 and not seen[lang] then
			seen[lang] = true
			result[#result + 1] = lang
		end
	end
	if #result == 0 then result[1] = 'en' end
	return result
end

return wyzie
