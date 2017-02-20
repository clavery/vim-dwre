if ( exists('g:loaded_dwre') && g:loaded_dwre ) || v:version < 700 || &cp
	fini
en
let g:loaded_dwre = 1

function! AddDwreBreakpoint()
  if !exists("g:DWREBreakpoints")
    let g:DWREBreakpoints = []
  end  
  let key = expand("%").":".line(".")
  if index(g:DWREBreakpoints, key) == -1
    call add(g:DWREBreakpoints, key)
  end
  execute ":sign define dwre text=●"
  execute ":sign place 1 line=" . line(".") . " name=dwre file=" . expand("%") 
endfunction
function! DelDwreBreakpoint()
  if !exists("g:DWREBreakpoints")
    let g:DWREBreakpoints = []
  end  
  let key = expand("%").":".line(".")
  if index(g:DWREBreakpoints, key) != -1
    call remove(g:DWREBreakpoints, key)
  end
  execute ":sign define dwre text=>"
  execute ":sign unplace"
endfunction
function! DwreReset()
  let g:DWREBreakpoints = []
  execute ":sign define dwre text=>"
  execute ":sign unplace *"
endfunction
function! DwreDebug()
  execute ":silent !dwre debug " . join(g:DWREBreakpoints)
  execute ":redraw!"
endfunction

command! DWREAdd :call AddDwreBreakpoint()
command! DWREDel :call DelDwreBreakpoint()
command! DWREReset :call DwreReset()
command! DWREDebug :call DwreDebug()

