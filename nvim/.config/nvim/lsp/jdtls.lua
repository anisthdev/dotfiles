-- Overrides nvim-lspconfig's jdtls root detection. The stock markers put `.git` in the
-- highest-priority group, so a stray ~/.git made $HOME the project root and jdtls tried to
-- import the whole home directory instead of the Java project.
local markers = {
	{ "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" }, -- multi-module wrappers
	{ "pom.xml", "build.gradle", "build.gradle.kts", "build.xml" }, -- single module
	".git", -- last resort
}

return {
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, markers)
		if root and root ~= vim.uv.os_homedir() then
			on_dir(root)
		end
	end,
}
