return {
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy', -- load shortly after startup instead of on first file open,
  -- so it doesn't load mid-way through nvim-tree's open (which caused the first-open double-press)
  build = ':TSUpdate',
  config = function()
    local treesitter = require 'nvim-treesitter.configs'

    treesitter.setup { -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      indent = { enable = true },
      ensure_installed = {
        'c',
        'cpp',
        'cmake',
        'make',
        'lua',
        'vim',
        'vimdoc',
        'query',
        'bash',
        'markdown',
        'markdown_inline',
        'gitignore',
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
    }
  end,
}
