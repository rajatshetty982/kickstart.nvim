return {
  'yetone/avante.nvim',
  lazy = false,
  version = false,
  opts = {
    provider = 'ollama',
    mode = 'legacy',
    providers = {
      ollama = {
        endpoint = 'http://127.0.0.1:11434',
        model = 'gemma4:e4b-it-q4_K_M',
        timeout = 60000,
        disable_tools = true,
        is_env_set = function()
          -- deferred require: avante is loaded by the time this runs
          return require('avante.providers.ollama').check_endpoint_alive()
        end,
        extra_request_body = {
          options = {
            -- temperature = 0.7, -- this is taken care in dev-gemma mod
            -- num_ctx = 8192,
            keep_alive = '5m',
          },
        },
      },
    },
    behaviour = {
      enable_token_counting = false,
    },
    hints = { enabled = true },
  },

  keys = {
    -- Ask mode: opens sidebar with pre-filled question
    {
      '<leader>af',
      function()
        require('avante.api').ask { question = 'Fix the bugs in the following code if any' }
      end,
      desc = 'Avante: Fix bugs',
      mode = { 'n', 'v' },
    },
    {
      '<leader>at',
      function()
        require('avante.api').ask { question = 'Implement tests for the following code' }
      end,
      desc = 'Avante: Add tests',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ax',
      function()
        require('avante.api').ask { question = 'Explain the following code concisely' }
      end,
      desc = 'Avante: Explain',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ad',
      function()
        require('avante.api').ask { question = 'Add docstrings/comments to the following code' }
      end,
      desc = 'Avante: Docstring',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ao',
      function()
        require('avante.api').ask { question = 'Optimize the following code for readability and performance' }
      end,
      desc = 'Avante: Optimize',
      mode = { 'n', 'v' },
    },
  },
  build = 'make',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
