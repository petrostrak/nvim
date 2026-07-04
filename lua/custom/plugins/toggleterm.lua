return {
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = {
    { '<c-\\>', desc = 'Toggle floating terminal' },
    { '<leader>Tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Terminal: float' },
    { '<leader>Th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Terminal: horizontal' },
    { '<leader>Tv', '<cmd>ToggleTerm direction=vertical size=80<cr>', desc = 'Terminal: vertical' },
  },
  opts = {
    open_mapping = [[<c-\>]],
    direction = 'float',
    float_opts = {
      border = 'curved',
    },
  },
}
