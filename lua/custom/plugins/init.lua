return {
  -- code fold like
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = function()
      vim.o.foldcolumn = '1' -- shows fold column (like arrows area)
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99

      require('ufo').setup()
    end,
  },
  --
  -- lines for func and stuff
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '│', -- clean vertical line
      },
      scope = {
        enabled = true,
        char = '│',
        show_start = false,
        show_end = false,
        highlight = { 'Function', 'Label' },
      },
      exclude = {
        filetypes = { 'help', 'dashboard', 'lazy', 'mason' },
      },
    },
  },
  --
  -- gruvbox colour theme configuration

  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      vim.o.background = 'dark'

      require('gruvbox').setup {
        contrast = 'soft', -- critical: reduces harshness while keeping clarity
        dim_inactive = true,
        transparent_mode = false,

        palette_overrides = {
          -- Slightly clearer, modernized palette
          bright_red = '#fb4934',
          bright_green = '#b8bb26',
          bright_yellow = '#fabd2f',
          bright_blue = '#83a598',
          bright_purple = '#d3869b',
          bright_aqua = '#8ec07c',
          bright_orange = '#fe8019',
        },

        overrides = {
          ----------------------------------------------------------------
          -- CORE TEXT HIERARCHY
          ----------------------------------------------------------------

          -- Comments: dim + italic → clearly “non-executable”
          Comment = { fg = '#7c6f64', italic = true },

          -- Keywords (if, else, return): strong signal
          Keyword = { fg = '#fb4934', bold = true },

          -- Functions: bright + bold → primary action units
          Function = { fg = '#b8bb26', bold = true },

          -- Variables: neutral (baseline)
          Identifier = { fg = '#ebdbb2' },

          -- Types (struct/class): cool distinct tone
          Type = { fg = '#83a598', bold = true },

          -- Constants: warm highlight
          Constant = { fg = '#fabd2f', bold = true },

          -- Strings: softer green (less aggressive than functions)
          String = { fg = '#8ec07c' },

          ----------------------------------------------------------------
          -- TREESITTER
          ----------------------------------------------------------------

          ['@comment'] = { fg = '#7c6f64', italic = true },
          ['@keyword'] = { fg = '#fb4934', bold = true },
          ['@function'] = { fg = '#b8bb26', bold = true },
          ['@type'] = { fg = '#83a598', bold = true },
          ['@string'] = { fg = '#8ec07c' },
          ['@constant'] = { fg = '#fabd2f', bold = true },

          -- Critical for gameplay code (member fields, ECS data)
          ['@variable.member'] = { fg = '#d3869b' },

          ----------------------------------------------------------------
          -- UI (calm, non-distracting)
          ----------------------------------------------------------------

          CursorLine = { bg = '#32302f' },
          Visual = { bg = '#617275', bold = true },

          -- (optional but recommended for consistency)
          VisualNOS = { bg = '#3c3836' },

          LineNr = { fg = '#5a524c' },
          CursorLineNr = { fg = '#fabd2f', bold = true },

          -- Search: visible but not jarring
          Search = { bg = '#fabd2f', fg = '#282828' },
          IncSearch = { bg = '#fe8019', fg = '#282828' },

          -- Floating windows (LSP, etc.)
          NormalFloat = { bg = '#1d2021' },
          FloatBorder = { fg = '#3c3836', bg = '#1d2021' },

          IblScope = { fg = '#83a598' }, -- soft blue, visible but not distracting
          IblIndent = { fg = '#3c3836' }, -- very subtle background guides
        },
      }

      vim.cmd 'colorscheme gruvbox'
    end,
  },
  -- tokyo night theme conf
  --
  -- {
  --   'folke/tokyonight.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   opts = {
  --     style = 'moon', -- Warmer than "night"
  --     transparent = false,
  --     dim_inactive = true, -- keeps your focus on the active buffer
  --     styles = {
  --       comments = { italic = true },
  --       keywords = { italic = true, bold = true }, -- Makes control flow (if/else) stand out
  --       functions = { bold = true }, -- Crucial for scanning C++/C# logic
  --       variables = {},
  --     },
  --
  --     -- "Palette": Mixing Gruvbox warmth with TokyoNight depth
  --     on_colors = function(colors)
  --       -- 1. Darken the background to a "Deep Forest/Industrial" grey-blue
  --       colors.bg = '#1a1b26'
  --       colors.bg_dark = '#16161e'
  --
  --       -- 2. Gruvbox-ify the Accents (Desaturating the "Neon")
  --       colors.orange = '#ff9e64' -- Keep this for warnings/important logic
  --       colors.yellow = '#e0af68' -- Warm Gruvbox yellow for constants
  --       colors.green = '#9ece6a' -- Sage green for strings
  --       colors.blue = '#7aa2f7' -- Steel blue (less "electric")
  --
  --       -- Use this for types and classes (important for ECS/C++ systems)
  --       colors.purple = '#bb9af7'
  --     end,
  --
  --     on_highlights = function(hl, c)
  --       -- "Smart" visibility for Game Dev:
  --
  --       -- Make C++/C# Member Variables distinct (easier to see 'this->' or 'm_')
  --       hl['@variable.member'] = { fg = '#73daca' }
  --
  --       -- Make Type definitions (Structs/Classes) stand out like a blueprint
  --       hl['@type'] = { fg = '#2ac3de', bold = true }
  --
  --       -- Gruvbox-style Search (the classic orange pop)
  --       hl.Search = { bg = '#af8700', fg = c.bg }
  --       hl.IncSearch = { bg = '#ff9e64', fg = c.bg }
  --
  --       -- Professional UI: Borderless, clean floats for LSPs and Telescope
  --       hl.FloatBorder = { fg = c.bg_dark, bg = c.bg_dark }
  --       hl.NormalFloat = { bg = c.bg_dark }
  --
  --       -- Subtle CursorLine (don't let it distract from the code)
  --       hl.CursorLine = { bg = '#292e42' }
  --
  --       -- Visual Mode (Gruvbox-inspired highlight)
  --       hl.Visual = { bg = '#3b4261' }
  --     end,
  --   },
  --   config = function(_, opts)
  --     require('tokyonight').setup(opts)
  --     vim.cmd [[colorscheme tokyonight]]
  --   end,
  -- },
  --
  --
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
