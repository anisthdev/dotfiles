local jdtls = require("jdtls")

-- Define workspace directory per project
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name
vim.fn.mkdir(workspace_dir, "p")

local config = {
  cmd = {
    vim.fn.stdpath("data") .. "/mason/bin/jdtls",
    "-data", workspace_dir,
  },

  root_dir = require("jdtls.setup").find_root({
    ".git", "mvnw", "gradlew", "pom.xml", "build.gradle",
  }),

  settings = {
    java = {},
  },

  init_options = {
    bundles = {},
  },
}

jdtls.start_or_attach(config)

