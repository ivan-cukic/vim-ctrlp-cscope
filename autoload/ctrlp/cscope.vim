" =============================================================================
" File:          autoload/ctrlp/cscope.vim
" Description:   CScope and GNU Global support
" =============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['cscope']

" Load guard
if ( exists('g:loaded_ctrlp_cscope') && g:loaded_ctrlp_cscope )
    \ || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlp_cscope = 1

let s:current_word = ''
" let s:current_path = ''

fu! s:syntax()
    if !ctrlp#nosy()
        cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')
        sy match CtrlPTabExtra '\t# .*'
    en
endf

python << endpython

import vim
import os
from subprocess import Popen, PIPE, STDOUT

def ctrlp_cscope_execute_cscope(arg):
    p = Popen(['gtags-cscope', '-q'], stdout=PIPE, stdin=PIPE, stderr=PIPE)
    result = p.communicate(input=arg)[0]
    p.stdin.close()

    return result.split('\n')

def ctrlp_cscope_find_symbol(s):
    return ctrlp_cscope_execute_cscope('0' + s)

def ctrlp_cscope_find_definition(s):
    return ctrlp_cscope_execute_cscope('1' + s)

def ctrlp_cscope_find_usage(s):
    return ctrlp_cscope_execute_cscope('3' + s)

endpython

call add(g:ctrlp_ext_vars, {
    \ 'init': 'ctrlp#cscope#init()',
    \ 'accept': 'ctrlp#cscope#accept',
    \ 'lname': 'file cscope',
    \ 'sname': 'cscope',
    \ 'type': 'path',
    \ 'enter': 'ctrlp#cscope#enter()',
    \ 'exit': 'ctrlp#cscope#exit()',
    \ 'opts': 'ctrlp#cscope#opts()',
    \ 'sort': 0,
    \ 'specinput': 0,
    \ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#cscope#init()
python << endpython

current_word = vim.eval('s:current_word')
current_mode = vim.eval('g:ctrlp_cscope_mode')

cscope_output = []

if current_mode == "all":
    cscope_output = ctrlp_cscope_find_definition(".*")

elif current_mode == "usage":
    cscope_output = ctrlp_cscope_find_usage(current_word)

elif current_mode == "definition":
    cscope_output = ctrlp_cscope_find_definition(current_word)

elif current_mode == "symbol":
    cscope_output = ctrlp_cscope_find_symbol(current_word)

else:
    cscope_output = ["Error Error 0 Error"]

if len(cscope_output) == 0:
    cscope_output = ["Nothing Found 0 Error"]


def process_cscope_result(line):
    components = line.split(" ", 3)

    if len(components) < 4:
        return ""
    else:
        if components[0] == ">>":
            return ""
        else:
            return \
                components[3] + "<=stop=>" + components[0] + \
                ":" + components[2] +\
                ""

results = filter(None, map(process_cscope_result, cscope_output))

vim.command("let a:results=" + str(results))

endpython
    call s:syntax()
    call map(a:results, 'substitute(v:val, "<=stop=>", "\t# ", "")')
    return a:results
endfunction


" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
" function! ctrlp#switcher#accept(mode, str)
"     " For this example, just exit ctrlp and run help
"     call ctrlp#exit()
"     help ctrlp-extensions
" endfunction

function! ctrlp#cscope#accept(mode, string)
python << endpython
mode   = vim.eval("a:mode")
string = vim.eval("a:string")

components = string.split("\t# ")
components = components[-1].split(":")

vim.command("call ctrlp#acceptfile(a:mode, \"" + components[0].replace('"', '\\"') + "\", " + components[1] + ")")
endpython
endf


" (optional) Do something before enterting ctrlp
function! ctrlp#cscope#enter()
    let s:current_word = expand("<cword>")
    " let s:current_path  = glob("`pwd`")
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#cscope#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#cscope#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#cscope#id()
  return s:id
endfunction

" vim:nofen:fdl=0:ts=4:sw=4:sts=4
