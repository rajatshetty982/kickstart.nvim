-- debug.lua

-- gemini trials
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'leoluz/nvim-dap-go',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
    },
    config = function()
      local dap = require 'dap'
      local ui = require 'dapui'

      --------------------------------------------------------------------
      -- Elegant UI & Visual Refinements
      --------------------------------------------------------------------
      ui.setup {
        controls = {
          element = 'repl',
          enabled = true,
          icons = {
            disconnect = '',
            pause = '',
            play = '',
            run_last = '',
            step_back = '',
            step_into = '',
            step_out = '',
            step_over = '',
            terminate = '',
          },
        },
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.35 },
              { id = 'breakpoints', size = 0.20 },
              { id = 'stacks', size = 0.25 },
              { id = 'watches', size = 0.20 },
            },
            position = 'left',
            size = 40,
          },
          {
            elements = {
              { id = 'repl', size = 0.5 },
              { id = 'console', size = 0.5 },
            },
            position = 'bottom',
            size = 10,
          },
        },
      }

      -- High-definition Nerd Font signs for the gutter
      local x = vim.api.nvim_set_hl
      x(0, 'DapBreakpoint', { fg = '#e06c75', bg = 'NONE' })
      x(0, 'DapBreakpointCondition', { fg = '#e5c07b', bg = 'NONE' })
      x(0, 'DapLogPoint', { fg = '#61afef', bg = 'NONE' })
      x(0, 'DapStopped', { fg = '#98c379', bg = 'NONE', bold = true })
      x(0, 'DapBreakpointRejected', { fg = '#5c6370', bg = 'NONE' })

      vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '➔', texthl = 'DapStopped', linehl = 'Visual', numhl = 'DapStopped' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })

      --------------------------------------------------------------------
      -- Virtual Text Customization
      --------------------------------------------------------------------
      require('nvim-dap-virtual-text').setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = true,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)

          if name:match 'secret' or name:match 'api' or value:match 'secret' or value:match 'api' then
            return '*****'
          end

          -- Clean format handling for heavy data structures or long engine strings
          if #variable.value > 20 then
            return '  ' .. string.sub(variable.value, 1, 20) .. '... '
          end
          return '  ' .. variable.value
        end,
      }

      --------------------------------------------------------------------
      -- Helper Functions for Robust Path Resolution
      --------------------------------------------------------------------
      local function get_mason_binary(binary_name)
        return vim.fn.stdpath 'data' .. '/mason/bin/' .. binary_name
      end

      --------------------------------------------------------------------
      -- Language Adapter & Configuration Setup
      --------------------------------------------------------------------

      -- 1. C / C++ (CodeLLDB)
      -- Optimized for low-level systems, resource loading, and framework architectures.
      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = get_mason_binary 'codelldb',
          args = { '--port', '${port}' },
        },
      }

      dap.configurations.cpp = {
        {
          name = 'Launch Executable (Standard)',
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
          name = 'Launch Executable w/ Arguments (Engine Context/Asset Paths)',
          type = 'codelldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          args = function()
            local args_str = vim.fn.input 'Arguments: '
            return vim.split(args_str, ' +')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
        {
          name = 'Attach to Process (Running Engine/External Window)',
          type = 'codelldb',
          request = 'attach',
          pid = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- 2. Go (Delve)
      -- Handled natively via nvim-dap-go plugin
      require('dap-go').setup()

      -- 3. C# (NetCoreDbg)
      -- Fully optimized for modern .NET environments and game runtime debugging scripts.
      dap.adapters.netcoredbg = {
        type = 'executable',
        command = get_mason_binary 'netcoredbg',
        args = { '--interpreter=vsdap' },
      }

      dap.configurations.cs = {
        {
          name = 'Launch .NET Core Binary (C#)',
          type = 'netcoredbg',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to DLL: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
        },
        {
          name = 'Attach to .NET Process',
          type = 'netcoredbg',
          request = 'attach',
          processId = require('dap.utils').pick_process,
        },
      }

      --------------------------------------------------------------------
      -- Ergonomic, Ergonomic & High-Speed Keymaps
      --------------------------------------------------------------------
      local map = vim.keymap.set

      -- Operational controls
      map('n', '<F1>', dap.continue, { desc = 'DAP: Continue/Start' })
      map('n', '<F2>', dap.step_into, { desc = 'DAP: Step Into' })
      map('n', '<F3>', dap.step_over, { desc = 'DAP: Step Over' })
      map('n', '<F4>', dap.step_out, { desc = 'DAP: Step Out' })
      map('n', '<F5>', dap.step_back, { desc = 'DAP: Step Back' })
      map('n', '<S-F1>', dap.restart, { desc = 'DAP: Restart Session' })
      map('n', '<S-F2>', dap.terminate, { desc = 'DAP: Terminate Session' })

      -- Breakpoint and Inspection Mechanics
      map('n', '<leader>b', dap.toggle_breakpoint, { desc = 'DAP: Toggle Breakpoint' })
      map('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint Condition: ')
      end, { desc = 'DAP: Conditional Breakpoint' })
      map('n', '<leader>gb', dap.run_to_cursor, { desc = 'DAP: Run to Cursor' })

      -- UI and Data Inspection
      map('n', '<leader>ui', ui.toggle, { desc = 'DAP: Toggle Debugging UI' })
      map('n', '<leader>?', function()
        ui.eval(nil, { enter = true })
      end, { desc = 'DAP: Evaluate Symbol Under Cursor' })

      --------------------------------------------------------------------
      -- Event Listeners & Automated UI Transitions
      --------------------------------------------------------------------
      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
--

-- older
--
-- return {
--   {
--     'mfussenegger/nvim-dap',
--     dependencies = {
--       'leoluz/nvim-dap-go',
--       'rcarriga/nvim-dap-ui',
--       'theHamsta/nvim-dap-virtual-text',
--       'nvim-neotest/nvim-nio',
--       'williamboman/mason.nvim',
--     },
--     config = function()
--       local dap = require 'dap'
--       local ui = require 'dapui'
--
--       require('dapui').setup()
--       require('dap-go').setup()
--
--       require('nvim-dap-virtual-text').setup {
--         display_callback = function(variable)
--           local name = string.lower(variable.name)
--           local value = string.lower(variable.value)
--           if name:match 'secret' or name:match 'api' or value:match 'secret' or value:match 'api' then
--             return '*****'
--           end
--
--           if #variable.value > 15 then
--             return ' ' .. string.sub(variable.value, 1, 15) .. '... '
--           end
--
--           return ' ' .. variable.value
--         end,
--       }
--
--       --------------------------------------------------------------------
--       -- C++ DAP (CODELLDB)
--       --------------------------------------------------------------------
--       dap.adapters.codelldb = {
--         type = 'server',
--         port = '${port}',
--         executable = {
--           command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
--           args = { '--port', '${port}' },
--         },
--       }
--
--       dap.configurations.cpp = {
--         {
--           name = 'Launch C++',
--           type = 'codelldb',
--           request = 'launch',
--           program = function()
--             return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
--           end,
--           cwd = '${workspaceFolder}',
--           stopOnEntry = false,
--         },
--       }
--
--       dap.configurations.c = dap.configurations.cpp
--
--       --------------------------------------------------------------------
--       -- Keymaps
--       --------------------------------------------------------------------
--       vim.keymap.set('n', '<space>b', dap.toggle_breakpoint)
--       vim.keymap.set('n', '<space>gb', dap.run_to_cursor)
--
--       vim.keymap.set('n', '<space>?', function()
--         require('dapui').eval(nil, { enter = true })
--       end)
--
--       vim.keymap.set('n', '<F1>', dap.continue)
--       vim.keymap.set('n', '<F2>', dap.step_into)
--       vim.keymap.set('n', '<F3>', dap.step_over)
--       vim.keymap.set('n', '<F4>', dap.step_out)
--       vim.keymap.set('n', '<F5>', dap.step_back)
--       vim.keymap.set('n', '<S-F1>', dap.restart)
--
--       --------------------------------------------------------------------
--       -- Auto-open UI
--       --------------------------------------------------------------------
--       dap.listeners.before.attach.dapui_config = function()
--         ui.open()
--       end
--       dap.listeners.before.launch.dapui_config = function()
--         ui.open()
--       end
--       dap.listeners.before.event_terminated.dapui_config = function()
--         ui.close()
--       end
--       dap.listeners.before.event_exited.dapui_config = function()
--         ui.close()
--       end
--     end,
--   },
-- }
