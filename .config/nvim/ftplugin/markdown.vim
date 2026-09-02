lua << EOF
-- https://github.com/neovim/neovim/blob/master/runtime/ftplugin/markdown.vim
vim.g.markdown_recommended_style = 0

if vim.fn.executable 'prettier' == 1 then
  vim.bo.formatprg = 'prettier --stdin-filepath %'
end

vim.cmd 'setlocal textwidth=80'
EOF
