return {
  'mfussenegger/nvim-lint',
  lazy = true,
  event = 'VeryLazy', -- load after startup, not during the first file open
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      c = { 'clangtidy' },
      cpp = { 'clangtidy' },
      go = { 'golangcilint' },
      python = { 'ruff' },
      -- NOTE: Rust linting (clippy) is provided by rust_analyzer via LSP.
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set('n', '<leader>li', function()
      lint.try_lint()
    end, { desc = 'Trigger linting for current file' })
  end,
}
