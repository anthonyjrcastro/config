-- Acknowledgements:
--
-- - [justinmk](https://github.com/justinmk/config/tree/master/.config/nvim)
-- - [LazyVim](https://github.com/LazyVim/LazyVim/tree/main/lua/lazyvim/config)

vim.cmd [[
" Don't load the plugin and autoload portions of netrw.
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

set completeopt+=fuzzy,noselect
set expandtab shiftwidth=2 softtabstop=-1
set foldlevelstart=99
set formatexpr=v:lua.require('conform').formatexpr()
set ignorecase smartcase
set linebreak breakindent
set list

cnoremap <expr> / (getcmdtype() =~ '[/?]' && getcmdline() == '') ? "\<C-C>\<Esc>/\\%V" : '/'

nnoremap <silent> <M-]> gt
nnoremap <silent> <M-[> gT

nnoremap <silent><expr> ZT (v:count == 0 ? '<Cmd>tabclose<CR>' : ':<C-U>tabclose '.v:count.'<CR>')

nnoremap <silent><expr> <M-}> ':<C-U>tabmove '.(v:count ? v:count : '+1').'<CR>'
nnoremap <silent><expr> <M-{> ':<C-U>tabmove '.(v:count ? (v:count - 1) : '-1').'<CR>'

nnoremap <M-Left>  <Cmd>vertical resize -2<CR>
nnoremap <M-Down>  <Cmd>resize -2<CR>
nnoremap <M-Up>    <Cmd>resize +2<CR>
nnoremap <M-Right> <Cmd>vertical resize +2<CR>

tnoremap <Esc> <C-\><C-N>

nnoremap <M-p> <Cmd>FzfLua files<CR>
nnoremap <M-/> <Cmd>FzfLua live_grep<CR>

nnoremap <silent><expr> Uh (v:count == 0 ? '<Cmd>Git<CR>' : ':<C-U>tab Git<CR>')
nnoremap <silent><expr> Ul (v:count == 0 ? '<Cmd>Git log<CR>' : ':<C-U>tab Git log<CR>')

nmap UH Uh
nmap UL Ul
nmap UB Ub
nmap UP Up
nmap UR Ur
nmap US Us

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
xnoremap <expr>   al <SID>line_outer_movement()
onoremap <silent> al :normal Val<CR>

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
xnoremap <expr>   il <SID>line_inner_movement()
onoremap <silent> il :normal vil<CR>

func! s:restart_session() abort
  mksession! Session.vim
  \| restart source Session.vim
  \| lua vim.defer_fn(function() vim.notify('restarted at: ' .. vim.fn.localtime()) vim.fs.rm 'Session.vim' end, 1000)
endf
nnoremap ZS :call <SID>restart_session()<CR>

augroup my.config
  autocmd!

  " Auto-create parent directories (except for URIs).
  autocmd BufWritePre,FileWritePre * if @% !~# '\(://\)' | call mkdir(expand('<afile>:p:h'), 'p') | endif

  autocmd BufWritePost * lua require('lint').try_lint()
  autocmd TextYankPost * silent! lua vim.hl.on_yank { higroup = 'Visual', timeout = 300 }
augroup END
]]

vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

vim.keymap.set({ 'n', 'x' }, '<Down>', '<C-D>')
vim.keymap.set({ 'n', 'x' }, '<Up>', '<C-U>')

vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true })
vim.keymap.set({ 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { expr = true })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true })
vim.keymap.set({ 'x', 'o' }, 'N', "'nN'[v:searchforward]", { expr = true })

vim.keymap.set({ 'n', 'i', 't' }, '<M-h>', [[<C-\><C-N><C-W><C-H>]], { silent = true })
vim.keymap.set({ 'n', 'i', 't' }, '<M-j>', [[<C-\><C-N><C-W><C-J>]], { silent = true })
vim.keymap.set({ 'n', 'i', 't' }, '<M-k>', [[<C-\><C-N><C-W><C-K>]], { silent = true })
vim.keymap.set({ 'n', 'i', 't' }, '<M-l>', [[<C-\><C-N><C-W><C-L>]], { silent = true })

vim.keymap.set({ 'n', 'x' }, 'gs', '"+')

local augroup = vim.api.nvim_create_augroup('my.config', { clear = false })

vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  desc = 'Restore position when opening a buffer',
  callback = function(ev)
    local exclude = { 'gitcommit', 'xxd', 'gitrebase' }
    local buf = ev.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.wo.diff then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      vim.cmd 'normal! g`"'
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  desc = 'Close some file types with `q`',
  pattern = {
    'checkhealth',
    'help',
    'qf',
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, { buffer = ev.buf, silent = true })
    end)
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  desc = 'Store yanked text in registers 1-9',
  callback = function()
    if vim.v.event.operator == 'y' then
      for i = 9, 1, -1 do
        vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
      end
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

require('vim._core.ui2').enable()

vim.g.diffs = {
  integrations = { fugitive = true, gitsigns = true },
}

vim.g['sneak#label'] = 1
vim.g['sneak#absolute_dir'] = 1
vim.g['sneak#use_ic_scs'] = 1

vim.pack.add {
  'https://github.com/barrettruth/diffs.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/justinmk/vim-dirvish',
  'https://github.com/justinmk/vim-sneak',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/michaeljsmith/vim-indent-object',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/stevearc/quicker.nvim',
  'https://github.com/tpope/vim-eunuch',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/tpope/vim-repeat',
  'https://github.com/tpope/vim-rsi',
  'https://github.com/tpope/vim-surround',
  'https://github.com/tpope/vim-unimpaired',
}

require('fzf-lua').setup { fzf_colors = true }

local gitsigns = require 'gitsigns'
gitsigns.setup {
  signs_staged_enable = false,
  current_line_blame = true,
  on_attach = function(bufnr)
    ---@param lhs string
    ---@param rhs function
    local function nmap(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { buffer = bufnr })
    end

    nmap(']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end)

    nmap('[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end)

    nmap('Ub', function()
      gitsigns.blame_line { full = true }
    end)

    nmap('Up', gitsigns.preview_hunk)
    nmap('Ur', gitsigns.reset_hunk)
    nmap('Us', gitsigns.stage_hunk)
  end,
}

require('lint').linters_by_ft = {
  markdown = { 'markdownlint-cli2' },
  sh = { 'shellcheck' },
}

vim.lsp.enable {
  'clangd',
  'emmylua_ls',
  'tinymist',
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local buf = ev.buf
    if client:supports_method 'textDocument/completion' then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end
    if client:supports_method 'textDocument/inlayHint' then
      vim.keymap.set('n', '<BS>', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { buffer = buf })
    end
    if client:supports_method 'textDocument/documentSymbol' then
      vim.keymap.set('n', 'gO', '<Cmd>FzfLua lsp_document_symbols<CR>', { buffer = buf })
    end
    if client:supports_method 'workspace/symbol' then
      vim.keymap.set('n', 'gW', '<Cmd>FzfLua lsp_workspace_symbols<CR>', { buffer = buf })
    end
    if client:supports_method 'textDocument/foldingRange' then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldmethod = 'expr'
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

require('conform').setup {
  formatters_by_ft = {
    c = { lsp_format = 'prefer' },
    cpp = { lsp_format = 'prefer' },
    lua = { 'stylua' },
    markdown = { 'prettier' },
    sh = { 'shfmt' },
    typst = { lsp_format = 'prefer' },
  },
}

require('quicker').setup {
  type_icons = { E = 'E ', W = 'W ', I = 'I ', N = 'N ', H = 'H ' },
}
