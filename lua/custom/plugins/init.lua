-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      vim.o.background = 'dark' -- or "light" if you prefer
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
        dim_inactive = false,
        transparent_mode = true,
      }
      vim.cmd 'colorscheme gruvbox'
    end,
  },
}
