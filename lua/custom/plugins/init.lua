-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {

  -- gruvbox colour theme configuration
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      vim.o.background = 'dark'
      require('gruvbox').setup {
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true,
        contrast = '', -- can be "hard", "soft", or ""
        palette_overrides = {},
        overrides = {},
        dim_inactive = true, -- was false
        transparent_mode = true, -- was false
      }
      vim.cmd 'colorscheme gruvbox'
    end,
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
  -- dont need this, as markview is much better, for now
  -- {
  --    -- Markdown preview plugins
  --    -- this is for 'in terminal view'
  --    'ellisonleao/glow.nvim',
  --    ft = { 'markdown' },
  --    config = function()
  --      require('glow').setup {
  --        style = 'dark',
  --        width = 120,
  --        border = 'rounded',
  --      }
  --    end,
  --  },
}
