if exists('g:loaded_substitute')
  finish
endif
let g:loaded_substitute = 1

command! -range=% -nargs=1 PSub lua require('psub')({line1 = <line1>, line2 = <line2>, fargs = { <f-args> } })
