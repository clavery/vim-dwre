# vim-dwre

Vim syntax, indenting and support files for editing Demandware ISML and DSscripts.

## Ale Linter For XSDs

```vim
let g:ale_linters = {
\   'xml': ['dwrexmllint'],
\}
let g:ale_xml_dwrexmllint_schema_path = '/path/to/dwre/xsds'
```
