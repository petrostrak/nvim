return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- rewrite branch; classic `master` API is unmaintained and breaks on Neovim 0.11+
	event = "VeryLazy",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({
			"c",
			"cpp",
			"cmake",
			"make",
			"rust",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"python",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"bash",
			"markdown",
			"markdown_inline",
			"toml",
			"gitignore",
		})

		-- highlight + indent are enabled per-buffer now, not via .setup{}
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"c",
				"cpp",
				"cmake",
				"make",
				"rust",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"python",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"bash",
				"markdown",
				"markdown_inline",
				"toml",
				"gitignore",
			},
			callback = function()
				vim.treesitter.start()
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
