if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'isml'
endif

let s:cpo_save = &cpo
set cpo&vim

runtime! syntax/html.vim syntax/html/*.vim


syn include @htmlJavaScript syntax/javascript.vim
syn region  javaScript start=+<isscript\_[^>]*>+ keepend end=+</isscript>+me=s-1 contains=@htmlJavaScript

syn region ismlExprBlock matchgroup=ismlExprDelim start=/${-\?/ end=/-\?}/ contains=@htmlJavaScript containedin=htmlString, htmlTag
hi link ismlExprDelim Constant

syn keyword ismlTagName contained isscript iscomment iscontent isinclude isloop isredirect
syn keyword ismlTagName contained isprint isset iscache isdecorate isif iselse iselseif
syn keyword ismlTagName contained isreplace isslot
syn match	ismlCustomTagName		contained "\<is[a-zA-Z0-9_]\+\>"
syn cluster	htmlTagNameCluster	add=ismlTagName 
syn cluster	htmlTagNameCluster	add=ismlCustomTagName
hi link ismlTagName Constant
hi link ismlCustomTagName Constant


let b:current_syntax = "isml"
if main_syntax == 'isml'
  unlet main_syntax
endif
let &cpo = s:cpo_save
unlet s:cpo_save
