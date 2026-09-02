" https://github.com/neovim/neovim/blob/master/runtime/ftplugin/markdown.vim
let g:markdown_recommended_style = 0

if executable('prettier')
  setlocal formatprg=prettier\ --stdin-filepath\ %
endif

setlocal textwidth=80
