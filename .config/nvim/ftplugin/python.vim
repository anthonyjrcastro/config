if executable('ruff')
  let &l:formatprg = 'ruff check -s --select I --fix -'
        \ .. ' | ruff format -s -'
endif
