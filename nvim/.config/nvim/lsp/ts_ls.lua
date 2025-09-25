return {
	settings = {
		typescript = {
			referencesCodeLens = {
				enabled = true,
				showOnAllFunctions = true, -- optional
			},
			implementationsCodeLens = {
				enabled = true,
			},
			suggest = {
				autoImports = true,
				completeFunctionCalls = true,
			},
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
			diagnostics = {
				ignoredCodes = { 80001 },
			},
		},
		javascript = {
			suggest = {
				autoImports = true,
				completeFunctionCalls = true,
			},
			referencesCodeLens = {
				enabled = true,
				showOnAllFunctions = true, -- optional
			},
			implementationsCodeLens = {
				enabled = true,
			},
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
			diagnostics = {
				ignoredCodes = { 80001 },
			},
		},
	},
}
