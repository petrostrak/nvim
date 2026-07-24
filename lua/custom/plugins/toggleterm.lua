return {
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = {
    { '<c-\\>', desc = 'Toggle floating terminal' },
    { '<leader>Tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Terminal: float' },
    { '<leader>Th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Terminal: horizontal' },
    { '<leader>Tv', '<cmd>ToggleTerm direction=vertical size=80<cr>', desc = 'Terminal: vertical' },
    { '<leader>bb', '<cmd>TermExec cmd="make" direction=horizontal go_back=false<cr>', desc = 'Build: make' },
    { '<leader>bf', '<cmd>TermExec cmd="make flash" direction=horizontal go_back=false<cr>', desc = 'Build: make flash' },
  },
  opts = {
    open_mapping = [[<c-\>]],
    direction = 'float',
    float_opts = {
      border = 'curved',
    },
  },
}
