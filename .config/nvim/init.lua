-- Acknowledgements:
--
-- - [justinmk](https://github.com/justinmk/config/tree/master/.config/nvim)
-- - [LazyVim](https://github.com/LazyVim/LazyVim/tree/main/lua/lazyvim/config)

vim.cmd [[
" Text object: All lines
func! s:line_outer_movement() abort
  if empty(getline(1)) && 1 == line('$')
    return "\<Esc>"
  endif
  let [lopen, copen, lclose, cclose] = [1, 1, line('$'), 1]
  call setpos("'[", [0, lopen, copen, 0])
  call setpos("']", [0, lclose, cclose, 0])
  return "'[o']"
endf

xnoremap <expr> al <SID>line_outer_movement()
onoremap al <Cmd>normal Val<CR>

" Text object: Inner line
func! s:line_inner_movement() abort
  if empty(getline('.'))
    return "\<Esc>"
  endif
  let [lopen, copen, lclose, cclose] = [line('.'), match(getline('.'), '\S')+1, line('.'), col('$')-1]
  call setpos("'[", [0, lopen, copen, 0])
  call setpos("']", [0, lclose, cclose, 0])
  return "`[o`]"
endf

xnoremap <expr> il <SID>line_inner_movement()
onoremap il <Cmd>normal vil<CR>
]]

vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = -1

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.breakindent = true
vim.o.linebreak = true

vim.o.list = true
vim.opt.listchars:append { tab = '» ', trail = '⣿', nbsp = '␣' }

vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })

vim.keymap.set({ 'n', 'x' }, '<Down>', '<C-D>')
vim.keymap.set({ 'n', 'x' }, '<Up>', '<C-U>')

vim.keymap.set({ 'n', 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'N', "'nN'[v:searchforward]", { expr = true })

vim.keymap.set('n', '<M-]>', 'gt')
vim.keymap.set('n', '<M-[>', 'gT')

-- Go to previous (or any other) window.
local function switch_to_alt_win()
  local currwin = vim.fn.winnr()
  vim.cmd 'wincmd p'
  if vim.fn.winnr() == currwin then
    -- Force window-switch to anywhere.
    vim.cmd 'wincmd w'
  end
end

vim.keymap.set('n', '<Tab>', function()
  if vim.v.count == 0 then
    switch_to_alt_win()
  else
    vim.cmd(vim.v.count .. 'wincmd w')
  end
end, { desc = 'Go to previous (or any other) window' })

vim.keymap.set('n', '<S-Tab>', '<C-^>')

vim.keymap.set({ 'n', 'i', 't' }, '<M-h>', [[<C-\><C-N><C-W>h]])
vim.keymap.set({ 'n', 'i', 't' }, '<M-j>', [[<C-\><C-N><C-W>j]])
vim.keymap.set({ 'n', 'i', 't' }, '<M-k>', [[<C-\><C-N><C-W>k]])
vim.keymap.set({ 'n', 'i', 't' }, '<M-l>', [[<C-\><C-N><C-W>l]])

vim.keymap.set('x', 'Y', '"+y')
vim.keymap.set('x', 'D', '"+d')

vim.keymap.set('t', '<Esc>', [[<C-\><C-N>]])

local augroup = vim.api.nvim_create_augroup('my.config', {})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  desc = 'Restore position when opening buffer',
  callback = function(ev)
    local exclude = { 'gitcommit', 'xxd', 'gitrebase' }
    if vim.tbl_contains(exclude, vim.bo[ev.buf].filetype) or vim.wo.diff then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      vim.cmd 'normal! g`"'
    end
  end,
})

vim.api.nvim_create_autocmd('TermRequest', {
  group = augroup,
  desc = 'Handle OSC 7 dir change requests',
  callback = function(ev)
    local val, n = string.gsub(ev.data.sequence, '^\027]7;file://[^/]*', '')
    if n > 0 then
      -- OSC 7: dir-change
      local dir = val
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify('invalid dir: ' .. dir)
        return
      end
      vim.b[ev.buf].osc7_dir = dir
      if vim.api.nvim_get_current_buf() == ev.buf then
        vim.cmd.lcd(dir)
      end
    end
  end,
})

-- Don't load the plugin and autoload portions of netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add {
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/justinmk/vim-dirvish',
  'https://github.com/kylechui/nvim-surround',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/miikanissi/modus-themes.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/stevearc/quicker.nvim',
  'https://github.com/tpope/vim-fugitive',
}

require('fzf-lua').setup {
  fzf_colors = true,
  lsp = { -- false=disable; 1=icon+kind; 2=icon only; 3=kind only
    symbols = { symbol_style = 3 },
  },
}

vim.keymap.set('n', '<M-/>', function()
  if vim.v.count == 0 then
    vim.cmd 'FzfLua files'
  else
    vim.cmd 'FzfLua live_grep'
  end
end, { desc = 'FzfLua {files/live_grep}' })

local gitsigns = require 'gitsigns'

gitsigns.setup {
  signs_staged_enable = false,
  current_line_blame = true,
  on_attach = function(bufnr)
    ---@param lhs string
    ---@param rhs function
    ---@param desc string
    local function nnoremap(lhs, rhs, desc)
      local opts = { buffer = bufnr, desc = desc }
      vim.keymap.set('n', lhs, rhs, opts)
      -- Don't set uppercase aliases for lhs w/ non-alphanumeric chars.
      if not lhs:match '%W' then
        vim.keymap.set('n', lhs:upper(), rhs, opts)
      end
    end

    nnoremap(']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, 'Jump to the next hunk')

    nnoremap('[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, 'Jump to the previous hunk')

    nnoremap('Ub', function()
      gitsigns.blame_line { full = true }
    end, 'Run blame on current line')

    nnoremap('Up', gitsigns.preview_hunk_inline, 'Preview the hunk under cursor')
    nnoremap('Ur', gitsigns.reset_hunk, 'Reset the hunk under cursor')
    nnoremap('Us', gitsigns.stage_hunk, 'Stage the hunk under cursor')
  end,
}

local lint = require 'lint'

lint.linters_by_ft = {
  markdown = { 'markdownlint-cli2' },
  python = { 'ruff' },
  sh = { 'shellcheck' },
}

vim.api.nvim_create_autocmd('BufWritePost', {
  group = augroup,
  desc = 'Run linters by file type',
  callback = function()
    lint.try_lint()
  end,
})

vim.keymap.set('n', 'gK', function()
  vim.diagnostic.open_float()
end, { desc = 'Show diagnostics under the cursor' })

vim.keymap.set('n', 'grq', function()
  vim.diagnostic.setqflist()
end, { desc = 'vim.diagnostic.setqflist()' })

vim.cmd 'colorscheme modus'

vim.lsp.enable {
  'clangd',
  'emmylua_ls',
  'jdtls',
  'pyright',
  'tinymist',
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  desc = 'Enable various LSP features',
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if client:supports_method 'textDocument/inlayHint' then
      vim.keymap.set('n', '<BS>', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { buffer = ev.buf, desc = 'Toggle inlay hints' })
    end

    if client:supports_method 'textDocument/documentSymbol' then
      vim.keymap.set('n', 'gO', '<Cmd>FzfLua lsp_document_symbols<CR>', { buffer = ev.buf })
    end

    if client:supports_method 'workspace/symbol' then
      vim.keymap.set('n', 'gr/', '<Cmd>FzfLua lsp_workspace_symbols<CR>', { buffer = ev.buf })
    end
  end,
})

require('quicker').setup {
  type_icons = { E = 'E ', W = 'W ', I = 'I ', N = 'N ', H = 'H ' },
}
