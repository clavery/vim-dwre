# vim-dwre

Vim syntax, indenting and support files for editing Demandware ISML and DSscripts.

## Ale Linter For XSDs

```vim
let g:ale_linters = {
\   'xml': ['dwrexmllint'],
\}
let g:ale_xml_dwrexmllint_schema_path = '/path/to/dwre/xsds'
```

## Debug

### Example Configuration

```viml
" DWRE
" override terminal open to be vertical split instead of horizontal
let g:DWREDebugVertical = 1

" add a breakpoint
autocmd FileType dsscript nnoremap <buffer> <leader>da :DWREAdd<cr>
" delete the breakpoint
autocmd FileType dsscript nnoremap <buffer> <leader>dd :DWREDel<cr>
" clear all breakpoints
autocmd FileType dsscript nnoremap <buffer> <leader>dr :DWREReset<cr>

" launch the debugger or continue execution
nnoremap <f5> :DWREDebugStartContinue<cr>
" next statement
nnoremap <f6> :DWREDebugNext<cr>
" jump into function
nnoremap <f7> :DWREDebugInto<cr>
" jump out of function
nnoremap <f8> :DWREDebugOut<cr>
" stop debugging and terminate debugger
nnoremap <f9> :DWREDebugStop<cr>
" Jump to current halted location, if halted
nnoremap <leader>dj :silent DWREDebugJump<cr>
" Print info on expression under cursor
autocmd FileType dsscript nnoremap <buffer> K :DWREDebugPrint<cr>

" highlight line of current location
highlight DWRELocation guibg=#666666
```
