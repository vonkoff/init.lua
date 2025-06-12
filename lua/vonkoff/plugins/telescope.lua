return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "truncate " },
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-d>"] = actions.results_scrolling_down,
						["<C-u>"] = actions.results_scrolling_up,
					},
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("ui-select")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		local builtin = require("telescope.builtin")
		-- Find
		keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
		keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
		keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
		keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
		keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
		keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
		keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
		keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
		keymap.set("n", "<leader>fb", builtin.builtin, { desc = "[F]ind [B]uiltin Telescope" })

		-- Buffers
		keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		-- Find Todo (also warning and errors)
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "[F]ind [T]odos" })

		-- Advanced & customized finders
		keymap.set("n", "<leader>f/", function()
			-- Fuzzily search in the current buffer with a dropdown theme
			builtin.current_buffer_fuzzy_find(themes.get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[F]ind [/] in current buffer" })

		keymap.set("n", "<leader>fo", function()
			-- Grep specifically in files that are currently open
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[F]ind in [O]pen files" })

		keymap.set("n", "<leader>fn", function()
			-- Shortcut for searching your Neovim configuration files
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[F]ind [N]eovim files" })
	end,
}
