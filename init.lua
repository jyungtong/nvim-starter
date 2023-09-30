-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --

vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false

-- Augroup for user created autocommands
vim.api.nvim_create_augroup('user_cmds', {clear = true})


-- ========================================================================== --
-- ==                               COMMANDS                               == --
-- ========================================================================== --

vim.api.nvim_create_user_command('ReloadConfig', 'source $MYVIMRC', {})

local group = vim.api.nvim_create_augroup('user_cmds', {clear = true})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'user_cmds',
  desc = 'Highlight on yank',
  callback = function()
    vim.highlight.on_yank({higroup = 'Visual', timeout = 200})
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'help', 'man'},
  group = 'user_cmds',
  command = 'nnoremap <buffer> q <cmd>quit<cr>'
})


-- ========================================================================== --
-- ==                               KEYMAPS                                == --
-- ========================================================================== --

-- Space as leader key
vim.g.mapleader = ' '

-- Basic clipboard interaction
vim.keymap.set({'n', 'x', 'o'}, 'gy', '"+y') -- copy
vim.keymap.set({'n', 'x', 'o'}, 'gp', '"+p') -- paste

-- Go to first character in line
vim.keymap.set('', '<Leader>h', '^')

-- Go to last character in line
vim.keymap.set('', '<Leader>l', 'g_')

-- Whatever you delete, make it go away
vim.keymap.set({'n', 'x'}, 'x', '"_x')

-- Select all text
vim.keymap.set('n', '<leader>a', '<cmd>keepjumps normal! ggVG<cr>')

-- Write file
vim.keymap.set('n', '<Leader>w', '<cmd>write<cr>')

-- Safe quit
vim.keymap.set('n', '<Leader>qq', '<cmd>quitall<cr>')

-- Force quit
vim.keymap.set('n', '<Leader>Q', '<cmd>quitall!<cr>')

-- Close buffer
vim.keymap.set('n', '<Leader>bc', '<cmd>bdelete<cr>')

-- Close window
vim.keymap.set('n', '<Leader>bq', '<cmd>q<cr>')

-- Move to last active buffer
vim.keymap.set('n', '<Leader>bl', '<cmd>buffer #<cr>')

-- Show diagnostic message
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

-- Go to previous diagnostic
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

-- Go to next diagnostic
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

-- Open file explorer
vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<CR>')
vim.keymap.set('n', '<leader>E', '<cmd>Lexplore %:p:h<CR>')

vim.api.nvim_create_autocmd('LspAttach', {
  group = 'user_cmds',
  desc = 'LSP actions',
  callback = function(ev)
    local bufmap = function(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, {buffer = ev.buf})
    end

    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
    bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
    bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')
    bufmap({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
    bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
    bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

    bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
  end
})

