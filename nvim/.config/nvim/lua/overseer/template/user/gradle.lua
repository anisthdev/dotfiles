-- Common Gradle tasks for the nearest build file, preferring the ./gradlew wrapper.
local build_files = { "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts" }

local function find_build(opts)
	return vim.fs.find(build_files, { upward = true, type = "file", path = opts.dir })[1]
end

---@type overseer.TemplateFileProvider
return {
	generator = function(opts)
		local build = find_build(opts)
		if not build then
			return "No Gradle build file found"
		end
		local root = vim.fs.dirname(build)
		local gradle = vim.uv.fs_stat(vim.fs.joinpath(root, "gradlew")) and "./gradlew" or "gradle"
		if gradle == "gradle" and vim.fn.executable("gradle") == 0 then
			return 'Command "gradle" not found'
		end

		local tasks = { "build", "test", "run", "clean" }
		if table.concat(vim.fn.readfile(build), "\n"):find("org%.springframework%.boot") then
			table.insert(tasks, 1, "bootRun")
		end

		local ret = {}
		for _, task in ipairs(tasks) do
			table.insert(ret, {
				name = "gradle " .. task,
				builder = function()
					return { cmd = { gradle, task }, cwd = root }
				end,
			})
		end

		local file = vim.api.nvim_buf_get_name(0)
		if file:match("Test%.java$") or file:match("Test%.kt$") then
			local class = vim.fn.fnamemodify(file, ":t:r")
			table.insert(ret, 1, {
				name = "gradle test " .. class,
				builder = function()
					return { cmd = { gradle, "test", "--tests", class }, cwd = root }
				end,
			})
		end
		return ret
	end,
}
