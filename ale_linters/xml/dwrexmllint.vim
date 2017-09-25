" Author: q12321q <q12321q@gmail.com>
" Description: This file adds support for checking XML code with xmllint.
" Author: Charles Lavery <charles.lavery@gmail.com>
" Description: Extended from default xmllint checker to validate against XSDs

" CLI options
let g:ale_xml_xmllint_executable = get(g:, 'ale_xml_xmllint_executable', 'xmllint')
let g:ale_xml_xmllint_options = get(g:, 'ale_xml_xmllint_options', '')
" MUST SET THIS TO A VALID PATH TO THE demandware SCHEMAS
let g:ale_xml_dwrexmllint_schema_path = get(g:, 'ale_xml_dwrexmllint_schema_path', '')

let s:xsd_map =  {'http://www.demandware.com/xml/impex/abtest/2010-04-01' : 'abtest.xsd',
\'http://www.demandware.com/xml/bmmodules/2007-12-11' : 'bmext.xsd',
\'http://www.demandware.com/xml/impex/cachesettings/2013-08-15' : 'cachesettings.xsd',
\'http://www.demandware.com/xml/impex/catalog/2006-10-31' : 'catalog.xsd',
\'http://www.demandware.com/xml/impex/coupon/2008-06-17' : 'coupon.xsd',
\'http://www.demandware.com/xml/impex/couponredemption/2008-06-17' : 'couponredemption.xsd',
\'http://www.demandware.com/xml/impex/csrfwhitelists/2017-02-09' : 'csrfwhitelists.xsd',
\'http://www.demandware.com/xml/impex/customer/2006-10-31' : 'customer.xsd',
\'http://www.demandware.com/xml/impex/customercdnsettings/2015-06-30' : 'customercdnsettings.xsd',
\'http://www.demandware.com/xml/impex/customergroup/2007-06-30' : 'customergroup.xsd',
\'http://www.demandware.com/xml/impex/customerlist/2010-06-30' : 'customerlist.xsd',
\'http://www.demandware.com/xml/impex/customerpaymentinstrument/2014-03-31' : 'customerpaymentinstrument.xsd',
\'http://www.demandware.com/xml/impex/customobject/2006-10-31' : 'customobject.xsd',
\'http://www.demandware.com/xml/impex/dcext/2016-04-05' : 'dcext.xsd',
\'http://www.demandware.com/xml/impex/feed/2009-01-01' : 'feed.xsd',
\'http://www.demandware.com/xml/form/2008-04-19' : 'form.xsd',
\'http://www.demandware.com/xml/impex/geolocation/2007-05-01' : 'geolocation.xsd',
\'http://www.demandware.com/xml/impex/giftcertificate/2007-02-28' : 'giftcertificate.xsd',
\'http://www.demandware.com/xml/impex/inventory/2007-05-31' : 'inventory.xsd',
\'http://www.demandware.com/xml/impex/jobs/2015-07-01' : 'jobs.xsd',
\'http://www.demandware.com/xml/impex/library/2006-10-31' : 'library.xsd',
\'http://www.demandware.com/xml/impex/metadata/2006-10-31' : 'metadata.xsd',
\'http://www.demandware.com/xml/impex/oauthprovider/2013-07-16' : 'oauth.xsd',
\'http://www.demandware.com/xml/impex/order/2006-10-31' : 'order.xsd',
\'http://www.demandware.com/xml/impex/pagemetatag/2016-08-22' : 'pagemetatag.xsd',
\'http://www.demandware.com/xml/impex/paymentsettings/2009-09-15' : 'paymentmethod.xsd',
\'http://www.demandware.com/xml/impex/paymentprocessor/2007-03-31' : 'paymentprocessor.xsd',
\'http://www.demandware.com/xml/impex/preferences/2007-03-31' : 'preferences.xsd',
\'http://www.demandware.com/xml/impex/priceadjustmentlimits/2017-01-01' : 'priceadjustmentlimits.xsd',
\'http://www.demandware.com/xml/impex/pricebook/2006-10-31' : 'pricebook.xsd',
\'http://www.demandware.com/xml/impex/productlist/2009-10-28' : 'productlist.xsd',
\'http://www.demandware.com/xml/impex/promotion/2008-01-31' : 'promotion.xsd',
\'http://www.demandware.com/xml/impex/redirecturl/2011-09-01' : 'redirecturl.xsd',
\'http://www.demandware.com/xml/impex/schedules/2007-03-31' : 'schedules.xsd',
\'http://www.demandware.com/xml/impex/search/2007-02-28' : 'search.xsd',
\'http://www.demandware.com/xml/impex/search2/2010-02-19' : 'search2.xsd',
\'http://www.demandware.com/xml/impex/services/2014-09-26' : 'services.xsd',
\'http://www.demandware.com/xml/impex/shipping/2007-03-31' : 'shipping.xsd',
\'http://www.demandware.com/xml/impex/site/2007-04-30' : 'site.xsd',
\'http://www.demandware.com/xml/impex/sitemapconfiguration/2016-08-30' : 'sitemapconfiguration.xsd',
\'http://www.demandware.com/xml/impex/slot/2008-09-08' : 'slot.xsd',
\'http://www.demandware.com/xml/impex/sort/2009-05-15' : 'sort.xsd',
\'http://www.demandware.com/xml/impex/sourcecode/2007-03-31' : 'sourcecode.xsd',
\'http://www.demandware.com/xml/impex/store/2007-04-30' : 'store.xsd',
\'http://www.demandware.com/xml/impex/tax/2007-02-14' : 'tax.xsd',
\'http://www.demandware.com/xml/impex/urlrules/2012-12-01' : 'urlrules.xsd'}

function! ale_linters#xml#dwrexmllint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'xml_xmllint_executable')
endfunction

function! ale_linters#xml#dwrexmllint#GetCommand(buffer) abort
  for l:i in [1,2,3,4,5]
    let l:matches = matchlist(getline(l:i), 'xmlns="\(.\{-}\)"')
    if len(l:matches) > 0
      break
    endif
  endfor 
  if len(l:matches) > 0 && has_key(s:xsd_map, l:matches[1])
    return ale#Escape(ale_linters#xml#dwrexmllint#GetExecutable(a:buffer))
          \   . ' --schema ' . g:ale_xml_dwrexmllint_schema_path . s:xsd_map[l:matches[1]] . ' ' . ale#Var(a:buffer, 'xml_xmllint_options')
          \   . ' --noout -'
  else
    return ale#Escape(ale_linters#xml#dwrexmllint#GetExecutable(a:buffer))
          \   . ' ' . ale#Var(a:buffer, 'xml_xmllint_options')
          \   . ' --noout -'
  endif
endfunction

function! ale_linters#xml#dwrexmllint#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    " file/path:123: error level : error message
    let l:pattern_message = '\v^([^:]+):(\d+):\s*(([^:]+)\s*:\s+.*)$'

    " parse column token line like that:
    " file/path:123: parser error : Opening and ending tag mismatch: foo line 1 and bar
    " </bar>
    "       ^
    let l:pattern_column_token = '\v^\s*\^$'

    let l:output = []

    for l:line in a:lines

        " Parse error/warning lines
        let l:match_message = matchlist(l:line, l:pattern_message)
        if !empty(l:match_message)
          let l:line = l:match_message[2] + 0
          let l:type = l:match_message[4] =~? 'warning' ? 'W' : 'E'
          let l:text = l:match_message[3]

          call add(l:output, {
          \   'lnum': l:line,
          \   'text': l:text,
          \   'type': l:type,
          \})

          continue
        endif

        " Parse column position
        let l:match_column_token = matchlist(l:line, l:pattern_column_token)
        if !empty(l:output) && !empty(l:match_column_token)
          let l:previous = l:output[len(l:output) - 1]
          let l:previous['col'] = len(l:match_column_token[0])

          continue
        endif

    endfor

    return l:output
endfunction

call ale#linter#Define('xml', {
\   'name': 'dwrexmllint',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#xml#dwrexmllint#GetExecutable',
\   'command_callback': 'ale_linters#xml#dwrexmllint#GetCommand',
\   'callback': 'ale_linters#xml#dwrexmllint#Handle',
\ })
