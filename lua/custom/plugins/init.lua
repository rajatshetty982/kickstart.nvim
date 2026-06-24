return {
  ------------------------------------------------------------------------------
  -- 1. DEBUG ADAPTER PROTOCOL (SYSTEMS & GAME ENGINE DEBUGGING)
  ------------------------------------------------------------------------------
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

          if #variable.value > 20 then
            return '  ' .. string.sub(variable.value, 1, 20) .. '... '
          end
          return '  ' .. variable.value
        end,
      }

      local function get_mason_binary(binary_name)
        return vim.fn.stdpath 'data' .. '/mason/bin/' .. binary_name
      end

      -- C / C++ (CodeLLDB)
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
          name = 'Launch Executable w/ Arguments',
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
          name = 'Attach to Process',
          type = 'codelldb',
          request = 'attach',
          pid = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- Go (Delve)
      require('dap-go').setup()

      -- C# (NetCoreDbg)
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

      local map = vim.keymap.set
      map('n', '<F1>', dap.continue, { desc = 'DAP: Continue/Start' })
      map('n', '<F2>', dap.step_into, { desc = 'DAP: Step Into' })
      map('n', '<F3>', dap.step_over, { desc = 'DAP: Step Over' })
      map('n', '<F4>', dap.step_out, { desc = 'DAP: Step Out' })
      map('n', '<F5>', dap.step_back, { desc = 'DAP: Step Back' })
      map('n', '<S-F1>', dap.restart, { desc = 'DAP: Restart Session' })
      map('n', '<S-F2>', dap.terminate, { desc = 'DAP: Terminate Session' })
      map('n', '<leader>b', dap.toggle_breakpoint, { desc = 'DAP: Toggle Breakpoint' })
      map('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint Condition: ')
      end, { desc = 'DAP: Conditional Breakpoint' })
      map('n', '<leader>gb', dap.run_to_cursor, { desc = 'DAP: Run to Cursor' })
      map('n', '<leader>ui', ui.toggle, { desc = 'DAP: Toggle Debugging UI' })
      map('n', '<leader>?', function()
        ui.eval(nil, { enter = true })
      end, { desc = 'DAP: Evaluate Symbol Under Cursor' })

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

  ------------------------------------------------------------------------------
  -- 2. HIGH-PERFORMANCE CODE FOLDING (NEATLY CONDENSE STRUCTURES)
  ------------------------------------------------------------------------------
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'BufReadPost',
    config = function()
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'UFO: Open All Folds' })
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'UFO: Close All Folds' })
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'UFO: Open Folds Except Kinds' })
      vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'UFO: Close Folds Level' })

      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰁂 %d lines folded '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0

        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            table.insert(newVirtText, { chunkText, chunk[2] })
            curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'Folded' })
        return newVirtText
      end

      require('ufo').setup {
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },

  ------------------------------------------------------------------------------
  -- 3. RIGID SCOPE VISUALIZATION (TRACK DEEP NESTING FLUIDLY)
  ------------------------------------------------------------------------------
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
      },
      scope = {
        enabled = true,
        char = '│',
        show_start = false,
        show_end = false,
        injected_languages = true,
        highlight = { 'IblScope' },
      },
      exclude = {
        filetypes = {
          'help',
          'dashboard',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'DapUIFloat',
          'dapui_scopes',
          'dapui_breakpoints',
          'dapui_stacks',
          'dapui_watches',
        },
        buftypes = { 'terminal', 'nofile' },
      },
    },

    ------------------------------------------------------------------------------
    -- 4. OPTIMIZED GRUVBOX COLOR THEME
    ------------------------------------------------------------------------------
    --
    {
      'neanias/everforest-nvim',
      priority = 1000,
      config = function()
        require('everforest').setup {
          background = 'hard', -- hard | medium | soft
          ui_contrast = 'high',

          dim_inactive_windows = true,
          diagnostic_text_highlight = true,
          italic_comments = true,

          overrides = function(c)
            return {
              --------------------------------------------------------------------
              -- Syntax
              --------------------------------------------------------------------
              ['@variable.member'] = {
                fg = c.purple,
              },

              ['@property'] = {
                fg = c.purple,
              },

              ['@type.qualifier'] = {
                fg = c.orange,
                bold = true,
              },

              ['@keyword.directive'] = {
                fg = c.red,
                bold = true,
              },

              ['@constructor'] = {
                fg = c.yellow,
              },

              ['@function.method'] = {
                fg = c.aqua,
              },

              ['@namespace'] = {
                fg = c.red,
                bold = true,
              },

              --------------------------------------------------------------------
              -- Editor
              --------------------------------------------------------------------
              CursorLine = {
                bg = c.bg2,
              },

              CursorLineNr = {
                fg = c.orange,
                bold = true,
              },

              Visual = {
                bg = c.bg_visual,
              },

              ColorColumn = {
                bg = c.bg2,
              },

              MatchParen = {
                fg = c.red,
                bold = true,
                underline = true,
              },

              Search = {
                fg = c.bg0,
                bg = c.orange,
                bold = true,
              },

              IncSearch = {
                fg = c.bg0,
                bg = c.red,
                bold = true,
              },

              --------------------------------------------------------------------
              -- Indent guides
              --------------------------------------------------------------------
              IblIndent = {
                fg = c.bg3,
              },

              IblScope = {
                fg = c.yellow,
                bold = true,
              },

              --------------------------------------------------------------------
              -- Folding
              --------------------------------------------------------------------
              Folded = {
                fg = c.grey1,
                bg = c.bg_dim,
                italic = true,
              },

              FoldColumn = {
                fg = c.red,
                bg = c.bg0,
              },

              --------------------------------------------------------------------
              -- Popup/Menu
              --------------------------------------------------------------------
              Pmenu = {
                bg = c.bg1,
              },

              PmenuSel = {
                bg = c.bg3,
                fg = c.red,
                bold = true,
              },

              FloatBorder = {
                -- fg = c.grey2,
                fg = c.grey2,
                bg = '#35312f',
              },

              NormalFloat = {
                -- bg = c.bg1,
                bg = '#35312f',
              },

              --------------------------------------------------------------------
              -- Diagnostics
              --------------------------------------------------------------------
              DiagnosticVirtualTextError = {
                fg = c.red,
                italic = true,
              },

              DiagnosticVirtualTextWarn = {
                fg = c.orange,
                italic = true,
              },

              DiagnosticUnderlineError = {
                undercurl = true,
                sp = c.red,
              },

              --------------------------------------------------------------------
              -- Git
              --------------------------------------------------------------------
              GitSignsAdd = {
                fg = c.green,
              },

              GitSignsChange = {
                fg = c.orange,
              },

              GitSignsDelete = {
                fg = c.red,
              },

              --------------------------------------------------------------------
              -- Window/UI
              --------------------------------------------------------------------
              WinSeparator = {
                fg = c.bg4,
              },

              StatusLine = {
                bg = c.bg1,
              },

              StatusLineNC = {
                bg = c.bg_dim,
              },
            }
          end,
        }

        vim.cmd.colorscheme 'everforest'
      end,
    },
    -- {
    --   'ellisonleao/gruvbox.nvim',
    --   priority = 1000,
    --   config = function()
    --     vim.o.background = 'dark'
    --
    --     require('gruvbox').setup {
    --       contrast = 'soft',
    --       dim_inactive = true,
    --       transparent_mode = false,
    --       inverse = false,
    --       palette_overrides = {
    --         bright_red = '#fb4934',
    --         bright_green = '#b8bb26',
    --         bright_yellow = '#fabd2f',
    --         bright_blue = '#83a598',
    --         bright_purple = '#d3869b',
    --         bright_aqua = '#8ec07c',
    --         bright_orange = '#fe8019',
    --       },
    --       overrides = {
    --         Comment = { fg = '#7c6f64', italic = true },
    --         Keyword = { fg = '#fb4934', bold = true },
    --         Statement = { fg = '#fb4934', bold = true },
    --         Conditional = { fg = '#fb4934', bold = true },
    --         Repeat = { fg = '#fb4934', bold = true },
    --         Function = { fg = '#b8bb26', bold = true },
    --         Identifier = { fg = '#ebdbb2' },
    --         Type = { fg = '#83a598', bold = true },
    --         Structure = { fg = '#83a598', bold = true },
    --         StorageClass = { fg = '#fe8019', bold = true },
    --         Constant = { fg = '#fabd2f', bold = true },
    --         String = { fg = '#8ec07c' },
    --         Character = { fg = '#8ec07c' },
    --         Number = { fg = '#d3869b' },
    --         Boolean = { fg = '#d3869b', bold = true },
    --         Float = { fg = '#d3869b' },
    --         Operator = { fg = '#fe8019' },
    --         PreProc = { fg = '#fe8019', bold = true },
    --         Include = { fg = '#fe8019' },
    --         Macro = { fg = '#fe8019', bold = true },
    --
    --         ['@comment'] = { fg = '#7c6f64', italic = true },
    --         ['@keyword'] = { fg = '#fb4934', bold = true },
    --         ['@keyword.directive'] = { fg = '#fe8019', bold = true },
    --         ['@function'] = { fg = '#b8bb26', bold = true },
    --         ['@function.method'] = { fg = '#b8bb26', bold = true },
    --         ['@type'] = { fg = '#83a598', bold = true },
    --         ['@type.definition'] = { fg = '#83a598', bold = true },
    --         ['@string'] = { fg = '#8ec07c' },
    --         ['@constant'] = { fg = '#fabd2f', bold = true },
    --         ['@constant.builtin'] = { fg = '#fabd2f', bold = true },
    --         ['@variable.member'] = { fg = '#d3869b' },
    --         ['@property'] = { fg = '#d3869b' },
    --         ['@namespace'] = { fg = '#fabd2f', italic = true },
    --         ['@type.qualifier'] = { fg = '#fe8019', bold = true },
    --
    --         CursorLine = { bg = '#32302f' },
    --         Visual = { bg = '#45403d', bold = true },
    --         VisualNOS = { bg = '#3c3836' },
    --         LineNr = { fg = '#5a524c' },
    --         CursorLineNr = { fg = '#fabd2f', bold = true },
    --         Search = { bg = '#fabd2f', fg = '#282828' },
    --         IncSearch = { bg = '#fe8019', fg = '#282828' },
    --         NormalFloat = { bg = '#1d2021' },
    --         FloatBorder = { fg = '#3c3836', bg = '#1d2021' },
    --         IblScope = { fg = '#83a598' },
    --         IblIndent = { fg = '#3c3836' },
    --         Folded = { fg = '#7c6f64', bg = '#282828', italic = true },
    --         FoldColumn = { fg = '#fe8019', bg = '#1d2021' },
    --       },
    --     }
    --
    --     vim.cmd 'colorscheme gruvbox'
    --   end,
    -- },
  },

  -- jira.nvim configuration
  {
    'kid-icarus/jira.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'folke/snacks.nvim',
    },
    opts = {}, -- The `opts` table is used for the setup configuration
    config = function()
      require('jira').setup {
        jira_api = {
          domain = vim.env.JIRA_DOMAIN,
          username = vim.env.JIRA_USER,
          token = vim.env.JIRA_API_TOKEN,
        },
        use_git_branch_issue_id = true,
        git_trunk_branch = 'main', -- The main branch of your project
        git_branch_prefix = 'feature/', -- The prefix for your feature branches
      }
      vim.keymap.set('n', '<leader>jv', '<cmd>Jira issue view<cr>', {})
      vim.keymap.set('n', '<leader>jc', '<cmd>Jira issue create<cr>', {})
      vim.keymap.set('n', '<leader>jt', require('jira.pickers.telescope').transitions, {}) -- Telescope
      -- vim.keymap.set('n', '<leader>jt', require('jira.pickers.snacks').transitions, {}) -- Snacks
    end,
  },

  {
    -- this is for 'in browser complete view'
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    build = 'cd app && npm install',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    -- a cool markdown preview in nvim itself, live!
    'OXY2DEV/markview.nvim',
    ft = { 'markdown' },
    lazy = false,

    -- For `nvim-treesitter` users.
    priority = 49,

    -- For blink.cmp's completion
    dependencies = {
      'saghen/blink.cmp',
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
