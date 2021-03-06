" File:       sublimemonokai.vim
" Maintainer: Mankit Pong (godmoves@github)
" URL:        https://github.com/godmoves/vim_settings
" License:    MIT

" For version 5.x: Clear all syntax items
" For versions greater than 6.x: Quit when a syntax file was already loaded
if v:version < 600
  syntax clear
elseif exists('b:current_syntax')
  finish
endif

"
" Commands
"

command! -buffer Python2Syntax let b:python_version_2 = 1 | let &syntax=&syntax
command! -buffer Python3Syntax let b:python_version_2 = 0 | let &syntax=&syntax

" Enable option if it's not defined
function! s:EnableByDefault(name)
  if !exists(a:name)
    let {a:name} = 1
  endif
endfunction

" Check if option is enabled
function! s:Enabled(name)
  return exists(a:name) && {a:name}
endfunction

" Is it Python 2 syntax?
function! s:Python2Syntax()
  if exists('b:python_version_2')
      return b:python_version_2
  endif
  return s:Enabled('g:python_version_2')
endfunction

"
" Default options
"

call s:EnableByDefault('g:python_highlight_builtin_funcs_kwarg')
call s:EnableByDefault('g:python_highlight_operators')
call s:EnableByDefault('g:python_highlight_file_headers_as_comments')
call s:EnableByDefault('g:python_highlight_builtin_objs')
call s:EnableByDefault('g:python_highlight_exceptions')
call s:EnableByDefault('g:python_highlight_string_format')
call s:EnableByDefault('g:python_highlight_string_formatting')
call s:EnableByDefault('g:python_highlight_class_vars')
call s:EnableByDefault('g:python_highlight_builtin_funcs')
call s:EnableByDefault('g:python_highlight_space_errors')
call s:EnableByDefault('g:python_highlight_indent_errors')

if s:Enabled('g:python_highlight_all')
  call s:EnableByDefault('g:python_highlight_string_templates')
  call s:EnableByDefault('g:python_highlight_doctests')
  call s:EnableByDefault('g:python_print_as_function')
endif

"
" Keywords
"
syn keyword pythonUnderline   _
syn match pythonBuiltinType '\v\.@<!\zs<%(type|object|str|basestring|unicode|buffer|bytearray|bytes|chr|dict|int|long|bool|float|complex|set|frozenset|list|tuple|unichr)>'

syn keyword pythonLambdaExpr    lambda nextgroup=pythonLambdaVarList skipwhite
" TODO: handle this smarter, deal with brackets
syn region pythonLambdaVarList  start='\(\<lambda\)\@<=\s' skip='\\$' end=':\|$' contained contains=pythonComment,pythonNumber,pythonStatement,pythonOperator,pythonLambdaVar transparent keepend
syn region pythonLambdaVarList  start='\(\<lambda\s*\)\@<=\s(' end=')' contained contains=pythonComment,pythonNumber,pythonStatement,pythonOperator,pythonLambdaVar transparent keepend
syn match pythonLambdaVar       '\h\w*' contained
syn keyword pythonStatement     break continue del return pass yield global assert with
syn keyword pythonStatement     raise nextgroup=pythonExClass skipwhite
syn keyword pythonFuncDef       def nextgroup=pythonNewFunc skipwhite
syn keyword pythonClassDef      class nextgroup=pythonNewClass skipwhite
if s:Enabled('g:python_highlight_class_vars')
  syn keyword pythonClassVar    self cls
endif
syn keyword pythonRepeat        for while
syn keyword pythonConditional   if elif else
syn keyword pythonException     try except finally
" The standard pyrex.vim unconditionally removes the pythonInclude group, so
" we provide a dummy group here to avoid crashing pyrex.vim.
syn keyword pythonInclude      import
syn keyword pythonImport       import
syn keyword pythonFrom         from
syn match pythonFromDot        '\(^\s*from\s*\)\@<=\.' display
syn match pythonImportAll      '\(import\s*\)\@<=\*'

if s:Python2Syntax()
  if !s:Enabled('g:python_print_as_function')
    syn keyword pythonStatement print
  endif
  syn keyword pythonStatement   exec
  syn keyword pythonImport      as
  syn match   pythonNewFunc     '[a-zA-Z_][a-zA-Z0-9_]*' display contained contains=pythonBuiltinMethod nextgroup=pythonNewFuncParamList
  syn match   pythonNewClass    '[a-zA-Z_][a-zA-Z0-9_]*' display contained nextgroup=pythonClassParamList
  syn match   pythonFunc        '[a-zA-Z_][a-zA-Z0-9_]*(\@=' display nextgroup=pythonFuncParamList
else
  syn keyword pythonStatement   as nonlocal
  syn match   pythonStatement   '\v\.@<!<await>'
  syn match   pythonNewFunc     '\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*' display contained contains=pythonBuiltinMethod nextgroup=pythonNewFuncParamList
  syn match   pythonNewClass    '\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*' display contained nextgroup=pythonClassParamList
  syn match   pythonFunc        '\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*(\@=' display nextgroup=pythonFuncParamList
  syn match   pythonStatement   'async\(\s\+def\>\)\@=' 
  syn match   pythonStatement   '\<async\s\+with\>'
  syn match   pythonStatement   '\<async\s\+for\>'
  syn cluster pythonExpression  contains=pythonStatement,pythonRepeat,pythonConditional,pythonOperator,pythonNumber,pythonHexNumber,pythonOctNumber,pythonBinNumber,pythonFloat,pythonString,pythonBytes,pythonBoolean,pythonBuiltinObj,pythonBuiltinFunc
endif

" TODO: maybe split this for python2/3 separately later.
syn region pythonNewFuncParamList start="(" skip=+\(".*"\|'.*'\)+ end=")\(\s\|:\|$\|->\)" contained contains=pythonNewFuncParam transparent keepend
syn match pythonNewFuncParam "[^,|^(|^)]*" contained contains=pythonConditional,pythonOperator,pythonLambdaExpr,pythonString,pythonNumber,pythonClassVar,pythonComment,pythonBoolean,pythonNewFuncParamLeft,pythonFuncBuiltinObj,pythonFuncBuiltinType,pythonClassDef,pythonFuncDef,pythonNone skipwhite
syn match pythonNewFuncParamLeft "\(=\s*\w*(\=\|\w\|\.\|:\s*\)\@<!\h\w*\(=\|,\|)\|:\|$\)\@=" contained
syn match pythonBrackets "{[(|)]}" contained skipwhite

syn region pythonClassParamList start="(" skip=+\(".*"\|'.*'\)+ end=")\|:" contained contains=pythonClassParam transparent keepend
syn match pythonClassParam "[^,|^(|^)|\\|:]*" contained contains=pythonComment,pythonClassParamKey,pythonOperator skipwhite
syn match pythonClassParamKey "\h\w*\s*=\@=" contained

syn region pythonFuncParamList start="(" skip=+\(".*"\|'.*'\)+ end=")\(\s\|$\|:\)\=" contained contains=pythonFuncParam transparent keepend
syn match pythonFuncParam "[^,|^(|^)]*" contained contains=pythonFunc,pythonRepeat,pythonConditional,pythonOperator,pythonLambdaExpr,pythonLambdaVarList,pythonString,pythonNumber,pythonClassVar,pythonComment,pythonBoolean,pythonFuncParamKey,pythonFuncBuiltinType,pythonFuncBuiltinObj,pythonFuncDef,pythonClassDef,pythonBuiltinMethod,pythonNone skipwhite
syn match pythonFuncParamKey "\h\w*\s*=\@=" contained
syn match pythonFuncBuiltinType "\.\@<!\<\(memoryview\|object\|str\|basestring\|unicode\|buffer\|bytearray\|bytes\|slice\|dict\|int\|long\|bool\|float\|complex\|set\|frozenset\|list\|tuple\|file\|super\)\(\s*=\)\@!" contained
syn match pythonFuncBuiltinObj "\.\@<!\<\(hex\|oct\|__import__\|abs\|all\|any\|bin\|callable\|classmethod\|compile\|complex\|delattr\|dir\|divmod\|enumerate\|eval\|filter\|format\|getattr\|globals\|hasattr\|hash\|help\|id\|input\|isinstance\|issubclass\|iter\|len\|locals\|map\|max\|chr\|min\|next\|open\|ord\|pow\|property\|range\|repr\|reversed\|round\|setattr\|type\|sorted\|staticmethod\|sum\|super\|type\|vars\|zip\|apply\|basestring\|buffer\|cmp\|coerce\|execfile\|file\|intern\|long\|raw_input\|reduce\|reload\|unichr\|unicode\|xrange\|ascii\|exec\|print\)\(\s*=\)\@!" contained


"
" Operators
"

syn keyword pythonOperator      and in is not or
if s:Enabled('g:python_highlight_operators')
    syn match pythonOperator    '\V=\|+\|@\|/\|%\|&\||\|^\|~\|<\|!='
    syn match pythonOperator    '\%(\<import\s\+\)\@<!\*'
    syn match pythonOperator    '->\@!\|-\@<!>'
endif
syn match pythonError           '[$?]\|\([-+@%&|^~]\)\1\{1,}\|\([=*/<>]\)\2\{2,}\|\([+@/%&|^~<>]\)\3\@![-+*@/%&|^~<>]\|\*\*[*@/%&|^<>]\|=[*@/%&|^<>]\|-[+*@/%&|^~<]\|[<!>]\+=\{2,}\|!\{2,}=\+' display

"
" Decorators (new in Python 2.4)
"
" TODO: there are some display errors, fix them laster
"       when the decorator is multiline, the highlight may be incorrect
syn match   pythonDecorator    '^\s*\zs@' display skipwhite
if s:Python2Syntax()
  syn match   pythonDottedName '\(@\s*\h\(\w\|\.\)*\.\|@\s*\)\@<=\h\w*\(\.\|\w\|\s*\\\)\@!' display 
else
  syn match   pythonDottedName '\(@\s*\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\(\%([^[:cntrl:][:punct:][:space:]]\|_\)\|\.\)*\.\|@\s*\)\@<=\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\(\.\|\%([^[:cntrl:][:punct:][:space:]]\|_\)\|\s*\\\)\@!' display 
endif

"
" Comments
"

syn match   pythonComment       '#.*$' display contains=pythonTodo,@Spell
if !s:Enabled('g:python_highlight_file_headers_as_comments')
  syn match   pythonRun         '\%^#!.*$'
  syn match   pythonCoding      '\%^.*\%(\n.*\)\?#.*coding[:=]\s*[0-9A-Za-z-_.]\+.*$'
endif
syn keyword pythonTodo          TODO FIXME XXX contained

"
" Errors
"

syn match pythonError           '\<\d\+[^0-9[:space:]]\+\>' display

" Mixing spaces and tabs also may be used for pretty formatting multiline
" statements
if s:Enabled('g:python_highlight_indent_errors')
  syn match pythonIndentError   '^\s*\%( \t\|\t \)\s*\S'me=e-1 display
endif

" Trailing space errors
if s:Enabled('g:python_highlight_space_errors')
  syn match pythonSpaceError    '\s\+$' display
endif

"
" Strings
"
" TODO: there are a lot of things to do to fix string highlight, but this is
" not quit urgent.
syn match pythonStringType "\<\(b\|B\|u\|U\|f\|F\)\=\(r\|R\)\=\(\"\|\'\)\@=" display

if s:Python2Syntax()
  " Python 2 strings
  syn region pythonString   start=+[bB]\='+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell
  syn region pythonString   start=+[bB]\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell
  syn region pythonString   start=+[bB]\="""+ skip=+\\"+ end=+"""+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest2,pythonSpaceError,@Spell
  syn region pythonString   start=+[bB]\='''+ skip=+\\'+ end=+'''+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest,pythonSpaceError,@Spell
else
  " Python 3 byte strings
  syn region pythonBytes    start=+[bB]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonBytesError,pythonBytesContent,@Spell
  syn region pythonBytes    start=+[bB]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonBytesError,pythonBytesContent,@Spell
  syn region pythonBytes    start=+[bB]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonBytesError,pythonBytesContent,pythonDocTest,pythonSpaceError,@Spell
  syn region pythonBytes    start=+[bB]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonBytesError,pythonBytesContent,pythonDocTest2,pythonSpaceError,@Spell

  syn match pythonBytesError    '.\+' display contained
  syn match pythonBytesContent  '[\u0000-\u00ff]\+' display contained contains=pythonBytesEscape,pythonBytesEscapeError
endif

syn match pythonBytesEscape       +\\[abfnrtv'"\\]+ display contained
syn match pythonBytesEscape       '\\\o\o\=\o\=' display contained
syn match pythonBytesEscapeError  '\\\o\{,2}[89]' display contained
syn match pythonBytesEscape       '\\x\x\{2}' display contained
syn match pythonBytesEscapeError  '\\x\x\=\X' display contained
"syn match pythonBytesEscape       '\\$'

syn match pythonUniEscape         '\\u\x\{4}' display contained
syn match pythonUniEscapeError    '\\u\x\{,3}\X' display contained
syn match pythonUniEscape         '\\U\x\{8}' display contained
syn match pythonUniEscapeError    '\\U\x\{,7}\X' display contained
syn match pythonUniEscape         '\\N{[A-Z ]\+}' display contained
syn match pythonUniEscapeError    '\\N{[^A-Z ]\+}' display contained

if s:Python2Syntax()
  " Python 2 Unicode strings
  syn region pythonUniString  start=+[uU]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell
  syn region pythonUniString  start=+[uU]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell
  syn region pythonUniString  start=+[uU]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest,pythonSpaceError,@Spell
  syn region pythonUniString  start=+[uU]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest2,pythonSpaceError,@Spell
else
  " Python 3 strings
  syn region pythonString   start=+'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell
  syn region pythonString   start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell
  syn region pythonString   start=+'''+ skip=+\\'+ end=+'''+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest,pythonSpaceError,@Spell
  syn region pythonString   start=+"""+ skip=+\\"+ end=+"""+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest2,pythonSpaceError,@Spell
  syn region pythonCommentString   start=+^\s*'''+ skip=+\\'+ end=+'''+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest,pythonSpaceError,@Spell
  syn region pythonCommentString   start=+^\s*"""+ skip=+\\"+ end=+"""+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest2,pythonSpaceError,@Spell

  syn region pythonFString   start=+[fF]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell
  syn region pythonFString   start=+[fF]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,@Spell
  syn region pythonFString   start=+[fF]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest,pythonSpaceError,@Spell
  syn region pythonFString   start=+[fF]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonBytesEscape,pythonBytesEscapeError,pythonUniEscape,pythonUniEscapeError,pythonDocTest2,pythonSpaceError,@Spell
endif

if s:Python2Syntax()
  " Python 2 Unicode raw strings
  syn region pythonUniRawString start=+[uU][rR]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonRawEscape,pythonUniRawEscape,pythonUniRawEscapeError,@Spell
  syn region pythonUniRawString start=+[uU][rR]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonRawEscape,pythonUniRawEscape,pythonUniRawEscapeError,@Spell
  syn region pythonUniRawString start=+[uU][rR]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonUniRawEscape,pythonUniRawEscapeError,pythonDocTest,pythonSpaceError,@Spell
  syn region pythonUniRawString start=+[uU][rR]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonUniRawEscape,pythonUniRawEscapeError,pythonDocTest2,pythonSpaceError,@Spell

  syn match  pythonUniRawEscape       '\%([^\\]\%(\\\\\)*\)\@<=\\u\x\{4}' display contained
  syn match  pythonUniRawEscapeError  '\%([^\\]\%(\\\\\)*\)\@<=\\u\x\{,3}\X' display contained
endif

" Python 2/3 raw strings
if s:Python2Syntax()
  syn region pythonRawString  start=+[bB]\=[rR]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonRawEscape,@Spell
  syn region pythonRawString  start=+[bB]\=[rR]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonRawEscape,@Spell
  syn region pythonRawString  start=+[bB]\=[rR]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonDocTest,pythonSpaceError,@Spell
  syn region pythonRawString  start=+[bB]\=[rR]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonDocTest2,pythonSpaceError,@Spell
else
  syn region pythonRawString  start=+[rR]'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonRawEscape,@Spell
  syn region pythonRawString  start=+[rR]"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonRawEscape,@Spell
  syn region pythonRawString  start=+[rR]'''+ skip=+\\'+ end=+'''+ keepend contains=pythonDocTest,pythonSpaceError,@Spell
  syn region pythonRawString  start=+[rR]"""+ skip=+\\"+ end=+"""+ keepend contains=pythonDocTest2,pythonSpaceError,@Spell

  syn region pythonRawFString   start=+\%([fF][rR]\|[rR][fF]\)'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonRawEscape,@Spell
  syn region pythonRawFString   start=+\%([fF][rR]\|[rR][fF]\)"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonRawEscape,@Spell
  syn region pythonRawFString   start=+\%([fF][rR]\|[rR][fF]\)'''+ skip=+\\'+ end=+'''+ keepend contains=pythonDocTest,pythonSpaceError,@Spell
  syn region pythonRawFString   start=+\%([fF][rR]\|[rR][fF]\)"""+ skip=+\\"+ end=+"""+ keepend contains=pythonDocTest,pythonSpaceError,@Spell

  syn region pythonRawBytes  start=+\%([bB][rR]\|[rR][bB]\)'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=pythonRawEscape,@Spell
  syn region pythonRawBytes  start=+\%([bB][rR]\|[rR][bB]\)"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=pythonRawEscape,@Spell
  syn region pythonRawBytes  start=+\%([bB][rR]\|[rR][bB]\)'''+ skip=+\\'+ end=+'''+ keepend contains=pythonDocTest,pythonSpaceError,@Spell
  syn region pythonRawBytes  start=+\%([bB][rR]\|[rR][bB]\)"""+ skip=+\\"+ end=+"""+ keepend contains=pythonDocTest2,pythonSpaceError,@Spell
endif

syn match pythonRawEscape +\\['"]+ display contained

if s:Enabled('g:python_highlight_string_formatting')
  " % operator string formatting
  if s:Python2Syntax()
    syn match pythonStrFormatting '%\%(([^)]\+)\)\=[-#0 +]*\d*\%(\.\d\+\)\=[hlL]\=[diouxXeEfFgGcrs%]' contained containedin=pythonString,pythonUniString,pythonUniRawString,pythonRawString,pythonBytesContent
    syn match pythonStrFormatting '%[-#0 +]*\%(\*\|\d\+\)\=\%(\.\%(\*\|\d\+\)\)\=[hlL]\=[diouxXeEfFgGcrs%]' contained containedin=pythonString,pythonUniString,pythonUniRawString,pythonRawString,pythonBytesContent
  else
    syn match pythonStrFormatting '%\%(([^)]\+)\)\=[-#0 +]*\d*\%(\.\d\+\)\=[hlL]\=[diouxXeEfFgGcrs%]' contained containedin=pythonString,pythonRawString,pythonBytesContent
    syn match pythonStrFormatting '%[-#0 +]*\%(\*\|\d\+\)\=\%(\.\%(\*\|\d\+\)\)\=[hlL]\=[diouxXeEfFgGcrs%]' contained containedin=pythonString,pythonRawString,pythonBytesContent
  endif
endif

if s:Enabled('g:python_highlight_string_format')
  " str.format syntax
  if s:Python2Syntax()
    syn match pythonStrFormat '{{\|}}' contained containedin=pythonString,pythonUniString,pythonUniRawString,pythonRawString
    syn match pythonStrFormat '{\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)\=\%(\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\[\%(\d\+\|[^!:\}]\+\)\]\)*\%(![rsa]\)\=\%(:\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}]\=[<>=^]\)\=[ +-]\=#\=0\=\d*,\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}' contained containedin=pythonString,pythonUniString,pythonUniRawString,pythonRawString
  else
    syn match pythonStrFormat "{\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)\=\%(\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\[\%(\d\+\|[^!:\}]\+\)\]\)*\%(![rsa]\)\=\%(:\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}]\=[<>=^]\)\=[ +-]\=#\=0\=\d*,\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}" contained containedin=pythonString,pythonRawString
    syn region pythonStrInterpRegion start="{"he=e+1,rs=e+1 end="\%(![rsa]\)\=\%(:\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}]\=[<>=^]\)\=[ +-]\=#\=0\=\d*,\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}"hs=s-1,re=s-1 extend contained containedin=pythonFString,pythonRawFString contains=pythonStrInterpRegion,@pythonExpression
    syn match pythonStrFormat "{{\|}}" contained containedin=pythonString,pythonRawString,pythonFString,pythonRawFString
  endif
endif

if s:Enabled('g:python_highlight_string_templates')
  " string.Template format
  if s:Python2Syntax()
    syn match pythonStrTemplate '\$\$' contained containedin=pythonString,pythonUniString,pythonUniRawString,pythonRawString
    syn match pythonStrTemplate '\${[a-zA-Z_][a-zA-Z0-9_]*}' contained containedin=pythonString,pythonUniString,pythonUniRawString,pythonRawString
    syn match pythonStrTemplate '\$[a-zA-Z_][a-zA-Z0-9_]*' contained containedin=pythonString,pythonUniString,pythonUniRawString,pythonRawString
  else
    syn match pythonStrTemplate '\$\$' contained containedin=pythonString,pythonRawString
    syn match pythonStrTemplate '\${[a-zA-Z_][a-zA-Z0-9_]*}' contained containedin=pythonString,pythonRawString
    syn match pythonStrTemplate '\$[a-zA-Z_][a-zA-Z0-9_]*' contained containedin=pythonString,pythonRawString
  endif
endif

if s:Enabled('g:python_highlight_doctests')
  " DocTests
  syn region pythonDocTest   start='^\s*>>>' skip=+\\'+ end=+'''+he=s-1 end='^\s*$' contained
  syn region pythonDocTest2  start='^\s*>>>' skip=+\\"+ end=+"""+he=s-1 end='^\s*$' contained
endif

"
" Numbers (ints, longs, floats, complex)
"

if s:Python2Syntax()
  syn match   pythonHexError    '\<0[xX]\x*[g-zG-Z]\+\x*[lL]\=\>' display
  syn match   pythonOctError    '\<0[oO]\=\o*\D\+\d*[lL]\=\>' display
  syn match   pythonBinError    '\<0[bB][01]*\D\+\d*[lL]\=\>' display

  syn match   pythonHexNumber   '\<0[xX]\x\+[lL]\=\>' display
  syn match   pythonOctNumber   '\<0[oO]\o\+[lL]\=\>' display
  syn match   pythonBinNumber   '\<0[bB][01]\+[lL]\=\>' display

  syn match   pythonNumberError '\<\d\+\D[lL]\=\>' display
  syn match   pythonNumber      '\<\d[lL]\=\>' display
  syn match   pythonNumber      '\<[0-9]\d\+[lL]\=\>' display
  syn match   pythonNumber      '\<\d\+[lL]\>' display
  syn match   pythonNumber      '\<\d\+\(j\>\|J\>\)\@=' display

  syn match   pythonOctError    '\<0[oO]\=\o*[8-9]\d*[lL]\=\>' display
  syn match   pythonBinError    '\<0[bB][01]*[2-9]\d*[lL]\=\>' display

  syn match   pythonFloat       '\.\d\+\%([eE][+-]\=\d\+\)\=\(j\=\>\|J\=\>\)\@=' display
  syn match   pythonFloat       '\<\d\+[eE][+-]\=\d\+\(j\=\>\|J\=\>\)\@=' display
  syn match   pythonFloat       '\<\d\+\.\d*\%([eE][+-]\=\d\+\)\=\(j\=\>\|J\=\>\)\@=' display
  syn match   pythonImgUnit     '\d\@<=\(j\|J\)'
else
  syn match   pythonOctError    '\<0[oO]\=\o*\D\+\d*\>' display
  " pythonHexError comes after pythonOctError so that 0xffffl is pythonHexError
  syn match   pythonHexError    '\<0[xX]\x*[g-zG-Z]\x*\>' display
  syn match   pythonBinError    '\<0[bB][01]*\D\+\d*\>' display

  syn match   pythonHexNumber   '\<0[xX][_0-9a-fA-F]*\x\>' display
  syn match   pythonOctNumber   '\<0[oO][_0-7]*\o\>' display
  syn match   pythonBinNumber   '\<0[bB][_01]*[01]\>' display

  syn match   pythonNumberError '\<\d[_0-9]*\D\>' display
  syn match   pythonNumberError '\<0[_0-9]\+\>' display
  syn match   pythonNumberError '\<0_x\S*\>' display
  syn match   pythonNumberError '\<0[bBxXoO][_0-9a-fA-F]*_\>' display
  syn match   pythonNumberError '\<\d[_0-9]*_\>' display
  syn match   pythonNumber      '\<\d\>' display
  syn match   pythonNumber      '\<[1-9][_0-9]*\d\>' display
  syn match   pythonNumber      '\d\(j\>\|J\>\)\@=' display
  syn match   pythonNumber      '\<[1-9][_0-9]*\d\(j\>\|J\>\)\@=' display

  syn match   pythonOctError    '\<0[oO]\=\o*[8-9]\d*\>' display
  syn match   pythonBinError    '\<0[bB][01]*[2-9]\d*\>' display

  syn match   pythonFloat       '\.\d\%([_0-9]*\d\)\=\%([eE][+-]\=\d\%([_0-9]*\d\)\=\)\=\(j\=\>\|J\=\>\)\@=' display
  syn match   pythonFloat       '\<\d\%([_0-9]*\d\)\=[eE][+-]\=\d\%([_0-9]*\d\)\=\(j\=\>\|J\=\>\)\@=' display
  syn match   pythonFloat       '\<\d\%([_0-9]*\d\)\=\.\%(\d\%([_0-9]*\d\)\=\%([eE][+-]\=\d\%([_0-9]*\d\)\=\)\=\(j\=\>\|J\=\>\)\@=\)\=' display
  syn match   pythonImgUnit     '\d\@<=\(j\|J\)'
endif

"
" Builtin objects and types
"

syn keyword pythonNone           None
syn keyword pythonBoolean        True False
syn keyword pythonBuiltinOthers  Ellipsis NotImplemented __debug__ 
syn match pythonBuiltinOthers    '\V...'

if s:Enabled('g:python_highlight_builtin_objs')
  syn match pythonBuiltinObj    '\v\.@<!<%(object|bool|int|float|tuple|str|list|dict|set|frozenset|bytearray|bytes)>'
  syn keyword pythonBuiltinObj  __doc__ __file__ __name__ __package__
  syn keyword pythonBuiltinObj  __loader__ __spec__ __path__ __cached__
endif

"
" Builtin method
"

syn keyword pythonBuiltinMethod __new__ __init__ __del__ __repr__ __str__ __bytes__ __format__
syn keyword pythonBuiltinMethod __le__ __lt__ __eq__ __ne__ __gt__ __ge__
syn keyword pythonBuiltinMethod __hash__ __bool__ __getattr__ __setattr__ __delattr__
syn keyword pythonBuiltinMethod __dir__ __get__ __set__ __delete__ __set_name__
syn keyword pythonBuiltinMethod __init_subclass__ __instancecheck__ __subclasscheck__
syn keyword pythonBuiltinMethod __call__ __len__ __length_hint__ __getitem__ __missing__
syn keyword pythonBuiltinMethod __setitem__ __delitem__ __iter__ __reversed__ __contains__
syn keyword pythonBuiltinMethod __add__ __sub__ __mul__ __truediv__ __floordiv__
syn keyword pythonBuiltinMethod __mod__ __divmod__ __pow__ __lshift__ __rshift__
syn keyword pythonBuiltinMethod __and__ __xor__ __or__ __radd__ __rsub__ __rmul__
syn keyword pythonBuiltinMethod __rtruediv__ __rfloordiv__ __rmod__ __rdivmod__
syn keyword pythonBuiltinMethod __rpow__ __rlshift__ __rrshift__ __rand__ __rxor__ __ror__
syn keyword pythonBuiltinMethod __iadd__ __isub__ __imul__ __itruediv__ __ifloordiv__
syn keyword pythonBuiltinMethod __imod__ __ipow__ __ilshift__ __irshift__ __iand__ __ixor__
syn keyword pythonBuiltinMethod __ior__  __neg__ __pos__ __abs__ __invert__ __complex__
syn keyword pythonBuiltinMethod __float__ __int__ __index__ __round__ __enter__ __exit__
syn keyword pythonBuiltinMethod __await__ __aiter__ __anext__ __aenter__ __aexit__
syn keyword pythonBuiltinMethod __div__ __rdiv__ __nonzero__ __long__ __hex__ __oct__
" TODO: these method are listed but not highlighted in sublime text 3
" syn keyword pythonBuiltinMethod __trunc__ __floor__ __ceil__ __matmul__ __imatmul__ __rmatmul__



"
" Builtin functions
"

if s:Enabled('g:python_highlight_builtin_funcs')
  let s:funcs_re = '__import__|abs|all|any|bin|callable|chr|classmethod|compile|complex|delattr|dir|divmod|enumerate|eval|filter|format|getattr|globals|hasattr|hash|help|hex|id|input|isinstance|issubclass|iter|len|locals|map|max|memoryview|min|next|oct|open|ord|pow|property|range|repr|reversed|round|setattr|slice|sorted|staticmethod|sum|super|type|vars|zip'

  if s:Python2Syntax()
    let s:funcs_re .= '|apply|basestring|buffer|cmp|coerce|execfile|file|intern|long|raw_input|reduce|reload|unichr|unicode|xrange'
    if s:Enabled('g:python_print_as_function')
      let s:funcs_re .= '|print'
    endif
  else
      let s:funcs_re .= '|ascii|exec|print'
  endif

  let s:funcs_re = 'syn match pythonBuiltinFunc ''\v\.@<!\zs<%(' . s:funcs_re . ')>'

  if !s:Enabled('g:python_highlight_builtin_funcs_kwarg')
      let s:funcs_re .= '\=@!'
  endif

  execute s:funcs_re . ''''
  unlet s:funcs_re
endif

"
" Builtin exceptions and warnings
"

if s:Enabled('g:python_highlight_exceptions')
    let s:exs_re = 'BaseException|Exception|ArithmeticError|LookupError|EnvironmentError|AssertionError|AttributeError|BufferError|EOFError|FloatingPointError|GeneratorExit|IOError|ImportError|IndexError|KeyError|KeyboardInterrupt|MemoryError|NameError|NotImplementedError|OSError|OverflowError|ReferenceError|RuntimeError|StopIteration|SyntaxError|IndentationError|TabError|SystemError|SystemExit|TypeError|UnboundLocalError|UnicodeError|UnicodeEncodeError|UnicodeDecodeError|UnicodeTranslateError|ValueError|VMSError|WindowsError|ZeroDivisionError|Warning|UserWarning|BytesWarning|DeprecationWarning|PendingDeprecationWarning|SyntaxWarning|RuntimeWarning|FutureWarning|ImportWarning|UnicodeWarning'

  if s:Python2Syntax()
      let s:exs_re .= '|StandardError'
  else
      let s:exs_re .= '|BlockingIOError|ChildProcessError|ConnectionError|BrokenPipeError|ConnectionAbortedError|ConnectionRefusedError|ConnectionResetError|FileExistsError|FileNotFoundError|InterruptedError|IsADirectoryError|NotADirectoryError|PermissionError|ProcessLookupError|TimeoutError|StopAsyncIteration|ResourceWarning'
  endif

  execute 'syn match pythonExClass ''\v\.@<!\zs<%(' . s:exs_re . ')>'''
  unlet s:exs_re
endif

if s:Enabled('g:python_slow_sync')
  syn sync minlines=2000
else
  " This is fast but code inside triple quoted strings screws it up. It
  " is impossible to fix because the only way to know if you are inside a
  " triple quoted string is to start from the beginning of the file.
  syn sync match pythonSync grouphere NONE '):$'
  syn sync maxlines=200
endif

if v:version >= 508 || !exists('did_python_syn_inits')
  if v:version <= 508
    let did_python_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink pythonStatement           Statement
  HiLink pythonImport              Include
  HiLink pythonFrom                Statement
  HiLink pythonFromDot             Statement
  HiLink pythonNewFunc             Function
  HiLink pythonConditional         Conditional
  HiLink pythonRepeat              Repeat
  HiLink pythonException           Exception
  HiLink pythonOperator            Operator

  HiLink pythonDecorator           Define
  HiLink pythonDottedName          Function

  HiLink pythonComment             Comment
  if !s:Enabled('g:python_highlight_file_headers_as_comments')
    HiLink pythonCoding            Special
    HiLink pythonRun               Special
  endif
  HiLink pythonTodo             Todo

  HiLink pythonError            Error
  HiLink pythonIndentError      Error
  HiLink pythonSpaceError       Error

  HiLink pythonString           String
  HiLink pythonCommentString    Comment
  HiLink pythonRawString        String
  HiLink pythonRawEscape        Special

  HiLink pythonUniEscape        Special
  HiLink pythonUniEscapeError   Error

  if s:Python2Syntax()
    HiLink pythonUniString          String
    HiLink pythonUniRawString       String
    HiLink pythonUniRawEscape       Special
    HiLink pythonUniRawEscapeError  Error
  else
    HiLink pythonBytes              String
    HiLink pythonRawBytes           String
    HiLink pythonBytesContent       String
    HiLink pythonBytesError         Error
    HiLink pythonBytesEscape        Special
    HiLink pythonBytesEscapeError   Error
    HiLink pythonFString            String
    HiLink pythonRawFString         String
    HiLink pythonStrInterpRegion    Special
  endif

  HiLink pythonStrFormatting    Special
  HiLink pythonStrFormat        Special
  HiLink pythonStrTemplate      Special

  HiLink pythonDocTest          Special
  HiLink pythonDocTest2         Special

  HiLink pythonNumber           Number
  HiLink pythonHexNumber        Number
  HiLink pythonOctNumber        Number
  HiLink pythonBinNumber        Number
  HiLink pythonFloat            Float
  HiLink pythonNumberError      Error
  HiLink pythonOctError         Error
  HiLink pythonHexError         Error
  HiLink pythonBinError         Error

  HiLink pythonBoolean          Boolean
  HiLink pythonNone             Constant

  HiLink pythonBuiltinObj       Structure
  HiLink pythonBuiltinFunc      Function

  HiLink pythonExClass          Structure
  HiLink pythonClassVar         Identifier

  delcommand HiLink
endif

let b:current_syntax = 'python'
