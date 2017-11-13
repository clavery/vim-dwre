fun! s:SelectDSSCRIPT()
  let n = 1
  if expand('%:p') =~ '\(cartridge\/controllers\)\|\(cartridge\/scripts\)'
    set ft=dsscript
    return
  endif
  while n < 100 && n <= line("$")
    if getline(n) =~ '\(dw\/\w\{-\}\/\w*\)\|\(guard\.ensure\)\|\(cartridge\/scripts\)'
      set ft=dsscript
      return
    endif
    let n = n + 1
  endwhile
endfun
autocmd BufNewFile,BufRead *.js  call s:SelectDSSCRIPT()
autocmd BufNewFile,BufRead *.isml set ft=isml
autocmd BufNewFile,BufRead *.ds set ft=dsscript
