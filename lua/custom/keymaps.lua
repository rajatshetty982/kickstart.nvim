return {

  -- Exit insert mode
  vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Exit insert mode with jk', noremap = true, silent = true }),

  -- My Extra keybinds
  vim.keymap.set('n', '<leader>pv', vim.cmd.Ex),
}
