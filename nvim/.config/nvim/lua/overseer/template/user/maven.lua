-- Common Maven goals for the nearest pom.xml, preferring the ./mvnw wrapper.
local function find_pom(opts)
	return vim.fs.find("pom.xml", { upward = true, type = "file", path = opts.dir })[1]
end

---@type overseer.TemplateFileProvider
return {
	generator = function(opts)
		local pom = find_pom(opts)
		if not pom then
			return "No pom.xml found"
		end
		local root = vim.fs.dirname(pom)
		local mvn = vim.uv.fs_stat(vim.fs.joinpath(root, "mvnw")) and "./mvnw" or "mvn"
		if mvn == "mvn" and vim.fn.executable("mvn") == 0 then
			return 'Command "mvn" not found'
		end

		local goals = { "compile", "test", "package", "verify", "install", "clean" }
		local text = table.concat(vim.fn.readfile(pom), "\n")
		if text:find("spring%-boot%-maven%-plugin") then
			table.insert(goals, 1, "spring-boot:run")
		end

		local ret = {}
		for _, goal in ipairs(goals) do
			table.insert(ret, {
				name = "mvn " .. goal,
				builder = function()
					return { cmd = { mvn, goal }, cwd = root }
				end,
			})
		end

		-- run only the tests in the open class, e.g. while working on one solution
		local file = vim.api.nvim_buf_get_name(0)
		if file:match("Test%.java$") then
			local class = vim.fn.fnamemodify(file, ":t:r")
			table.insert(ret, 1, {
				name = "mvn test " .. class,
				builder = function()
					return { cmd = { mvn, "test", "-Dtest=" .. class }, cwd = root }
				end,
			})
		end
		return ret
	end,
}
