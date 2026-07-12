return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>mp',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(_)
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      rust = { 'rustfmt' },
      go = { 'goimports', 'gofumpt' },
      python = { 'isort', 'black' },
    },
    formatters = {
      -- Put the opening brace on its own line everywhere (Allman style),
      -- keeping the rest of the LLVM defaults.
      -- NOTE: this style is passed on the command line, so it overrides any
      -- project-local `.clang-format` file. Drop this override if you want
      -- per-project `.clang-format` files to win instead.
      ['clang-format'] = {
        prepend_args = { '--style={ BasedOnStyle: LLVM, BreakBeforeBraces: Allman }' },
      },
    },
  },
}
