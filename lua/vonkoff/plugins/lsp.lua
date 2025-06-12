-- lua/vonkoff/plugins/lsp.lua

return {
	-- Main LSP Configuration
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- Mason handles LSP server installation
		{
			"mason-org/mason.nvim",
			-- This config function will run BEFORE the main lspconfig config
			config = function()
				local mason = require("mason")
				mason.setup({
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				})
			end,
		},
		-- This plugin bridges mason and lspconfig
		"mason-org/mason-lspconfig.nvim",
		-- This plugin handles installing formatters and linters
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			config = function()
				local mason_tool_installer = require("mason-tool-installer")
				mason_tool_installer.setup({
					ensure_installed = {
						-- LSPs
						"ts_ls",
						"html",
						"cssls",
						"tailwindcss",
						"svelte",
						"lua_ls",
						"graphql",
						"emmet_ls",
						"prismals",
						"pyright",
						-- Formatters & Linters
						"prettier",
						"stylua",
						"isort",
						"black",
						"pylint",
						"eslint_d",
					},
				})
			end,
		},

		-- Add other LSP-related plugins here
		{ "j-hui/fidget.nvim", opts = {} }, -- Nice UI for LSP progress
		{ "folke/neodev.nvim", opts = {} }, -- Helps with nvim-specific lua development
	},
	config = function()
		-- This is your main lspconfig setup, it will run AFTER all dependencies are loaded.
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local keymap = vim.keymap

		-- Your LspAttach autocommand (this is perfect, no changes needed)
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)
				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		-- Get capabilities from blink.cmp (or whatever completion engine you use)
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Your diagnostic signs (this is perfect, no changes needed)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local servers = {
			html = {},
			cssls = {},
			tailwindcss = {},
			svelte = {
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.js", "*.ts" },
						callback = function(ctx)
							client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
						end,
					})
				end,
			},
			graphql = {
				filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
			},
			emmet_ls = {
				filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
			},
			ts_ls = {
				settings = {
					tsserver = { plugins = { ["@typescript-eslint/eslint-plugin"] = { useESLint = false } } },
					typescript = { validate = { enable = true } },
					javascript = { validate = { enable = true } },
				},
			},
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						completion = { callSnippet = "Replace" },
					},
				},
			},
			elixirls = {
				cmd = { "/Users/vonkoff/.elixir-ls/release/language_server.sh", "--log-level", "debug" },
				root_dir = require("lspconfig.util").root_pattern("mix.exs"),
				settings = {
					elixirLS = {
						dialyzerEnabled = false,
						fetchDeps = false,
					},
				},
				on_attach = function(client, bufnr)
					print("ElixirLS attached to buffer " .. bufnr)
				end,
			},
		}

		-- The generic handler for setting up servers
		mason_lspconfig.setup_handlers({
			function(server_name)
				local server = servers[server_name] or {}
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				require("lspconfig")[server_name].setup(server)
			end,
			-- You can still have custom handlers here if needed, for example:
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							completion = { callSnippet = "Replace" },
						},
					},
				})
			end,
		})
	end,
}
