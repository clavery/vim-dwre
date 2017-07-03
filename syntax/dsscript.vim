if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'dsscript'
endif

" pull in javascript syntax
runtime! syntax/javascript.vim
runtime! indent/javascript.vim

" if ultisnips is present ensure javascript snippets are loaded
if exists(":UltiSnipsAddFiletypes")
  execute "silent UltiSnipsAddFiletypes javascript.dsscript"
end
