vim.pack.add { 'https://github.com/chomosuke/typst-preview.nvim' }

require('typst-preview').setup {
  dependencies_bin = { tinymist = 'tinymist', websocat = 'websocat' },
}

vim.cmd 'setlocal textwidth=120'
