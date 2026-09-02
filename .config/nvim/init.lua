-- Acknowledgements:
--
-- - [justinmk](https://github.com/justinmk/config/tree/master/.config/nvim)
-- - [LazyVim](https://github.com/LazyVim/LazyVim/tree/main/lua/lazyvim/config)

vim.cmd [[
" Don't load the plugin and autoload portions of netrw.
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

let g:sneak#label = 1
let g:sneak#use_ic_scs = 1
let g:sneak#absolute_dir = 1

set completeopt+=fuzzy,noselect
set expandtab shiftwidth=2 softtabstop=-1
set foldlevelstart=99 foldmethod=indent
set ignorecase smartcase
set linebreak breakindent
set list listchars+=tab:»\ ,trail:⣿,nbsp:␣
set winborder=rounded pumborder=rounded

nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
xnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
xnoremap <expr> k (v:count == 0 ? 'gk' : 'k')

nnoremap <Down> <C-D>
nnoremap <Up>   <C-U>

nnoremap <expr> n 'Nn'[v:searchforward]
xnoremap <expr> n 'Nn'[v:searchforward]
onoremap <expr> n 'Nn'[v:searchforward]
nnoremap <expr> N 'nN'[v:searchforward]
xnoremap <expr> N 'nN'[v:searchforward]
onoremap <expr> N 'nN'[v:searchforward]

cnoremap <expr> / (getcmdtype() =~ '[/?]' && getcmdline() == '') ? "\<C-C>\<Esc>/\\%V" : '/'

nnoremap <silent> <M-]> gt
nnoremap <silent> <M-[> gT
nnoremap <silent><expr> ZT (v:count == 0 ? '<Cmd>tabclose<CR>' : ':<C-U>tabclose '.v:count.'<CR>')
nnoremap <silent><expr> <M-}> ':<C-U>tabmove '.(v:count ? v:count : '+1').'<CR>'
nnoremap <silent><expr> <M-{> ':<C-U>tabmove '.(v:count ? (v:count - 1) : '-1').'<CR>'

nnoremap <silent><expr> <Tab>   (v:count > 0 ? '<C-W>w' : '<C-W>p')
nnoremap <silent>       <S-Tab> <C-^>

nnoremap <M-h> <C-W>h
inoremap <M-h> <C-\><C-N><C-W>h
tnoremap <M-h> <C-\><C-N><C-W>h
nnoremap <M-j> <C-W>j
inoremap <M-j> <C-\><C-N><C-W>j
tnoremap <M-j> <C-\><C-N><C-W>j
nnoremap <M-k> <C-W>k
inoremap <M-k> <C-\><C-N><C-W>k
tnoremap <M-k> <C-\><C-N><C-W>k
nnoremap <M-l> <C-W>l
inoremap <M-l> <C-\><C-N><C-W>l
tnoremap <M-l> <C-\><C-N><C-W>l

nnoremap <C-Left>  <Cmd>vertical resize -2<CR>
nnoremap <C-Down>  <Cmd>resize -2<CR>
nnoremap <C-Up>    <Cmd>resize +2<CR>
nnoremap <C-Right> <Cmd>vertical resize +2<CR>

xnoremap Y "+y
xnoremap D "+d

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

augroup my.config
  autocmd!

  " Auto-create parent directories (except for URIs).
  autocmd BufWritePre,FileWritePre * if @% !~# '\(://\)' | call mkdir(expand('<afile>:p:h'), 'p') | endif

  autocmd BufWritePost * lua require('lint').try_lint()
  autocmd TextYankPost * silent! lua vim.hl.on_yank { higroup = 'Visual', timeout = 300 }
augroup END
]]

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

vim.pack.add {
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/justinmk/vim-dirvish',
  'https://github.com/justinmk/vim-sneak',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/michaeljsmith/vim-indent-object',
  'https://github.com/miikanissi/modus-themes.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/stevearc/quicker.nvim',
  'https://github.com/tpope/vim-eunuch',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/tpope/vim-repeat',
  'https://github.com/tpope/vim-rsi',
  'https://github.com/tpope/vim-surround',
  'https://github.com/tpope/vim-unimpaired',
}

require('fzf-lua').setup {
  fzf_colors = true,
  lsp = { -- false=disable; 1=icon+kind; 2=icon only; 3=kind only
    symbols = { symbol_style = 3 },
  },
}

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
    nmap('Up', gitsigns.preview_hunk_inline)
    nmap('Ur', gitsigns.reset_hunk)
    nmap('Us', gitsigns.stage_hunk)
  end,
}

require('lint').linters_by_ft = {
  markdown = { 'markdownlint-cli2' },
  sh = { 'shellcheck' },
}

vim.cmd.colorscheme 'modus'

vim.lsp.enable {
  'clangd',
  'emmylua_ls',
  'jdtls',
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
      vim.keymap.set('n', 'gr/', '<Cmd>FzfLua lsp_workspace_symbols<CR>', { buffer = buf })
    end
    if client:supports_method 'textDocument/foldingRange' then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldmethod = 'expr'
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

require('quicker').setup {
  type_icons = { E = 'E ', W = 'W ', I = 'I ', N = 'N ', H = 'H ' },
}
