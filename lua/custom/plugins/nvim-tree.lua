return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree documentation
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		local function my_on_attach(bufnr)
			local api = require("nvim-tree.api")

			local function opts(desc)
				return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
			end

			-- Load standard mappings
			api.config.mappings.default_on_attach(bufnr)

			-- FIX: Use a scheduled pcall to completely isolate the clang-tidy crash
			vim.keymap.set("n", "<CR>", function()
				local node = api.tree.get_node_under_cursor()
				if node and node.type == "file" then
					-- Drop out of the tree back to the main layout
					vim.cmd("wincmd p")

					-- Schedule the open execution asynchronously to prevent crashing the main thread loop
					vim.schedule(function()
						pcall(function()
							vim.cmd("edit " .. vim.fn.fnameescape(node.absolute_path))
						end)
					end)
				else
					api.node.open.edit()
				end
			end, opts("Safe Open File"))
		end

		nvimtree.setup({
			on_attach = my_on_attach,
			view = {
				width = 35,
				signcolumn = "no",
			},
			renderer = {
				indent_markers = {
					enable = true,
				},
			},
			update_focused_file = {
				enable = true,
				update_root = false,
				ignore_list = {},
			},
			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
				},
			},
			filters = {
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
		})

		-- global keymaps
		local keymap = vim.keymap
		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		keymap.set(
			"n",
			"<leader>ef",
			"<cmd>NvimTreeFindFileToggle<CR>",
			{ desc = "Toggle file explorer on current file" }
		)
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
	end,
}
