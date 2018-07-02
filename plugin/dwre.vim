if ( exists('g:loaded_dwre') && g:loaded_dwre ) || v:version < 800 || &cp
  fini
en
let g:loaded_dwre = 1

let g:DWREDebugStatus = get(g:, 'DWREDebugStatus', '')
let g:DWREExecLocation = get(g:, 'DWREExecLocation', 'dwre')
let g:DWREDebugVertical = get(g:, 'DWREDebugVertical', 0)

let s:DWREExecLocationID = 90005
let s:DWREExecBreakpointID = 80000
let s:dwreCurrentLocation = v:null
let s:dwreCurrentLine = v:null
let s:dwre_terminal_buf = v:null

function! Tapi_Dwre_Update_Location(bufnum, arglist)
  if a:arglist[0] != v:null
    execute ":silent! sign define DWRELocation text=» linehl=DWRELocation"
    execute ":silent! sign unplace " . s:DWREExecLocationID
    execute ":silent! sign place " . s:DWREExecLocationID . " line=" . a:arglist[1] . " name=DWRELocation file=" . a:arglist[0]
    let g:DWREDebugStatus = 'HALTED'
    let s:dwreCurrentLocation = a:arglist[0]
    let s:dwreCurrentLine = a:arglist[1]
    let &ro = &ro
  else
    execute ":silent! sign unplace " . s:DWREExecLocationID
    let g:DWREDebugStatus = 'RUNNING'
    let s:dwreCurrentLocation = v:null
    let s:dwreCurrentLine = v:null
    let &ro = &ro
  endif
endfunction

"" BREAKPOINTS

function! AddDwreBreakpoint()
  if !exists("g:DWREBreakpoints")
    let g:DWREBreakpoints = []
  end  
  let key = expand("%").":".line(".")
  if index(g:DWREBreakpoints, key) == -1
    call add(g:DWREBreakpoints, key)
  end
  execute ":sign define dwre text=○"
  execute ":sign place " . s:DWREExecBreakpointID . " line=" . line(".") . " name=dwre file=" . expand("%")
  let s:DWREExecBreakpointID = s:DWREExecBreakpointID + 1
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

function! DwreDebugJump()
  if s:dwreCurrentLocation != v:null
    execute ":silent! edit +" . s:dwreCurrentLine . " " . s:dwreCurrentLocation
  endif
endfunction

"" TERMINAL

function! s:dwre_debug_on_stop(...)
  execute ":silent! sign unplace " . s:DWREExecLocationID
  let s:dwreCurrentLocation = v:null
  let s:dwreCurrentLine = v:null
  let s:dwre_terminal_buf = v:null
  let g:DWREDebugStatus = ''
  " TODO: breakpoint update
  let &ro = &ro
  execute ":sign define dwre text=○"
endfunction

function! DwreDebug(...)
  let terminal_options = {
        \ "vertical" : g:DWREDebugVertical,
        \ "exit_cb" : function("s:dwre_debug_on_stop"),
        \ "norestore" : 1,
        \ "term_finish" : 'close',
        \ "stoponexit" : 1,
        \ "term_name" : "DWREDebug"
        \}
  if s:dwre_terminal_buf == v:null
    if a:0 == 1
      let s:dwre_terminal_buf = term_start(g:DWREExecLocation . " --env " . a:1 . " debug --vim ". join(g:DWREBreakpoints), terminal_options)
    elseif a:0 == 2
      let s:dwre_terminal_buf = term_start(g:DWREExecLocation . " --env " . a:2 . " --project " . a:1 . " debug --vim ". join(g:DWREBreakpoints), terminal_options)
    else
      let s:dwre_terminal_buf = term_start(g:DWREExecLocation . " debug --vim ". join(g:DWREBreakpoints), terminal_options)
    endif
    let g:DWREDebugStatus = 'RUNNING'
    let &ro = &ro
    execute ":sign define dwre text=●"
  else
    call term_sendkeys(s:dwre_terminal_buf, "continue\<cr>")
  endif
endfunction

function! DwreDebugPrint()
  if s:dwre_terminal_buf != v:null
    let undercursor = expand("<cexpr>")
    call term_sendkeys(s:dwre_terminal_buf, "print " . undercursor . "\<cr>")
  endif
endfunction

function! DwreDebugExec(cmd)
  if s:dwre_terminal_buf != v:null
    call term_sendkeys(s:dwre_terminal_buf, a:cmd . "\<cr>")
  endif
endfunction

"" LEGACY

function! DwreDebugLaunch(...)
  if !exists("g:DWREBreakpoints")
    let g:DWREBreakpoints = []
  end
  if a:0 == 1
    if has("gui_macvim") && has("gui_running")
      execute ":silent !osascript -e 'tell app \"Terminal\"\do script \"cd " . getcwd() . "; dwre --env " . a:1 . " debug ". join(g:DWREBreakpoints) ."\"\activate\end tell'"
    else
      execute ":silent !dwre --env " . a:1 . " debug " . join(g:DWREBreakpoints)
      execute ":redraw!"
    end
  elseif a:0 == 2
    if has("gui_macvim") && has("gui_running")
      execute ":silent !osascript -e 'tell app \"Terminal\"\do script \"cd " . getcwd() . "; dwre --project " . a:1 . " --env " . a:2 . " debug ". join(g:DWREBreakpoints) ."\"\activate\end tell'"
    else
      execute ":silent !dwre --project " . a:1 . " --env " . a:2 . " debug " . join(g:DWREBreakpoints)
      execute ":redraw!"
    end
  else
    if has("gui_macvim") && has("gui_running")
      execute ":silent !osascript -e 'tell app \"Terminal\"\do script \"cd " . getcwd() . "; dwre debug ". join(g:DWREBreakpoints) ."\"\activate\end tell'"
    else 
      execute ":silent !dwre debug " . join(g:DWREBreakpoints)
      execute ":redraw!"
    end
  end
endfunction

"" COMMANDS

command! DWREAdd :call AddDwreBreakpoint()
command! DWREDel :call DelDwreBreakpoint()
command! DWREReset :call DwreReset()
command! -nargs=* DWREDebugStartContinue :call DwreDebug(<f-args>)
command! DWREDebugPrint :silent call DwreDebugPrint()
command! DWREDebugNext :silent call DwreDebugExec("next")
command! DWREDebugInto :silent call DwreDebugExec("into")
command! DWREDebugOut :silent call DwreDebugExec("out")
command! DWREDebugStop :silent call DwreDebugExec("exit")
command! DWREDebugJump :silent call DwreDebugJump()
