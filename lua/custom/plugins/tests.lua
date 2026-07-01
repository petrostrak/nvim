return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui', -- DAP UI
    'jay-babu/mason-nvim-dap.nvim',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
  },
  config = function()
    local dap = require 'dap'
    local ui = require 'dapui'

    -- Ensure the C/C++ debug adapter (codelldb) is installed via Mason.
    require('mason-nvim-dap').setup {
      automatic_installation = true,
      ensure_installed = { 'codelldb' },
    }

    -- codelldb adapter (also drives the `c` and `cpp` filetypes below).
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = 'codelldb',
        args = { '--port', '${port}' },
      },
    }

    -- Launch configuration shared by C and C++.
    local cpp_config = {
      {
        name = 'Launch executable',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
      },
      {
        name = 'Attach to process',
        type = 'codelldb',
        request = 'attach',
        pid = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
      },
    }

    dap.configurations.c = cpp_config
    dap.configurations.cpp = cpp_config

    -- Show variable values inline while debugging.
    require('nvim-dap-virtual-text').setup {}

    -- Custom highlight groups with better colors
    vim.api.nvim_set_hl(0, 'DapBreakpointText', { fg = '#e06c75', bold = true }) -- Red
    vim.api.nvim_set_hl(0, 'DapStoppedText', { fg = '#98c379', bold = true }) -- Green
    vim.api.nvim_set_hl(0, 'DapBreakpointLine', { bg = '#2d1b21' }) -- Subtle red background
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#1e2718' }) -- Subtle green background
    vim.api.nvim_set_hl(0, 'DapBreakpointNum', { fg = '#e06c75', bold = true })
    vim.api.nvim_set_hl(0, 'DapStoppedNum', { fg = '#98c379', bold = true })

    -- Sign definitions with better icons
    vim.fn.sign_define('DapBreakpoint', {
      text = '●',
      texthl = 'DapBreakpointText',
      linehl = 'DapBreakpointLine',
      numhl = 'DapBreakpointNum',
    })
    vim.fn.sign_define('DapStopped', {
      text = '▶',
      texthl = 'DapStoppedText',
      linehl = 'DapStoppedLine',
      numhl = 'DapStoppedNum',
    })
    vim.fn.sign_define('DapBreakpointCondition', {
      text = '◆',
      texthl = 'DapBreakpointText',
      linehl = 'DapBreakpointLine',
      numhl = 'DapBreakpointNum',
    })
    vim.fn.sign_define('DapLogPoint', {
      text = '◉',
      texthl = 'DapBreakpointText',
      linehl = 'DapBreakpointLine',
      numhl = 'DapBreakpointNum',
    })

    -- Debug keybindings
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle breakpoint' })
    vim.keymap.set('n', '<leader>dB', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set conditional breakpoint' })

    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue' })
    vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })
    vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug: Run last' })
    vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = 'Debug: Quit' })

    -- Function key bindings for stepping
    vim.keymap.set('n', '<F1>', dap.continue, { desc = 'Continue' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Step over' })
    vim.keymap.set('n', '<F3>', dap.step_into, { desc = 'Step into' })
    vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'Step out' })

    ui.setup {
      -- Better DAP UI layout
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 10,
          position = 'bottom',
        },
      },
    }

    -- Manual DAP UI toggle
    vim.keymap.set('n', '<leader>du', ui.toggle, { desc = 'Debug: Toggle UI' })

    -- Auto-open/close DAP UI
    dap.listeners.after.event_initialized['dapui_config'] = function()
      ui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      ui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      ui.close()
    end
  end,
}
