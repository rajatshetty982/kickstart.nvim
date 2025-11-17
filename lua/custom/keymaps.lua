return {

  -- Exit insert mode
  vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Exit insert mode with jk', noremap = true, silent = true }),

  -- to go to folder structure
  vim.keymap.set('n', '<leader>pv', vim.cmd.Ex),

  -- Markdown Preview keymaps

  vim.keymap.set('n', '<leader>mbp', '<cmd>MarkdownPreviewToggle<CR>', { desc = 'Markdown Browser Preview' }),

  vim.keymap.set('n', '<leader>mp', '<cmd>Markview<CR>', { desc = 'Toggle Markview' }),
}
