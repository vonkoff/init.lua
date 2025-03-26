-- return {
--   "mfussenegger/nvim-lint",
--   lazy = true,
--   event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
--   config = function()
--     local lint = require("lint")
--
--     lint.linters_by_ft = {
--       javascript = { "eslint_d" },
--       typescript = { "eslint_d" },
--       javascriptreact = { "eslint_d" },
--       typescriptreact = { "eslint_d" },
--       svelte = { "eslint_d" },
--       python = { "pylint" },
--     }
--
--     local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
--
--     vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
--       group = lint_augroup,
--       callback = function()
--         lint.try_lint()
--       end,
--     })
--
--     vim.keymap.set("n", "<leader>l", function()
--       lint.try_lint()
--     end, { desc = "Trigger linting for current file" })
--   end,
-- }
return {
	"mfussenegger/nvim-lint",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
		}

		-- Force eslint_d to output JSON
		lint.linters.eslint_d.args = {
			"--format",
			"json",
		}

		-- Optional: Custom parser to suppress specific error
		lint.linters.eslint_d.parser = function(output)
			if output:match("Error %[ERR_REQUIRE_CYCLE_MODULE%]") then
				return {} -- Suppress the error by returning empty diagnostics
			end
			-- Default JSON parsing
			local ok, decoded = pcall(vim.json.decode, output)
			if not ok then
				return {}
			end
			local diagnostics = {}
			for _, item in ipairs(decoded) do
				table.insert(diagnostics, {
					lnum = item.line - 1,
					col = item.column - 1,
					end_lnum = item.endLine and (item.endLine - 1) or item.line - 1,
					end_col = item.endColumn and (item.endColumn - 1) or item.column - 1,
					message = item.message,
					severity = vim.diagnostic.severity.ERROR,
					source = "eslint",
				})
			end
			return diagnostics
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
