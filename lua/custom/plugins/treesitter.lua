return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master', -- classic API (`.configs.setup{...}`); `main` is a rewrite with a different API
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
        'rust',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'python',
        'lua',
        'vim',
        'vimdoc',
        'query',
        'bash',
        'markdown',
        'markdown_inline',
        'toml',
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
