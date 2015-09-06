" File: plugin/cscope.vim
" Description: a simple ctrlp.vim extension provides integration with CScope and GNU Global
" Author: Ivan Cukic <ivan.cukic___kde.org>
" License: The MIT License

command! CtrlPCScopeAll        let g:ctrlp_cscope_mode="all"        | call ctrlp#init(ctrlp#cscope#id())
command! CtrlPCScopeSymbol     let g:ctrlp_cscope_mode="symbol"     | call ctrlp#init(ctrlp#cscope#id())
command! CtrlPCScopeUsage      let g:ctrlp_cscope_mode="usage"      | call ctrlp#init(ctrlp#cscope#id())
command! CtrlPCScopeDefinition let g:ctrlp_cscope_mode="definition" | call ctrlp#init(ctrlp#cscope#id())

