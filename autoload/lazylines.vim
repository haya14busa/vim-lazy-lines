"=============================================================================
" FILE: autoload/lazylines.vim
" AUTHOR: haya14busa
" Last Change: 22 Jan 2014.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" To load EasyMotion
call EasyMotion#reset()

function! lazylines#deletelines(direction) "{{{
    " Save {{{
    let save_pos = getpos('.')
    let save_enter_jump_first = g:EasyMotion_enter_jump_first
    let g:EasyMotion_enter_jump_first = 0
    let g:EasyMotion_ignore_exception = 1
    "}}}

    " Prepare {{{
    highlight LazyLines ctermbg=green guibg=green
    call EasyMotion#highlight#add_color_group({'LazyLines':1})
    let lazy_hl_lines = [] " Store highlight line regrex
    let lazy_lines = [] " Store line number
    "}}}

    " Get pos list {{{
    while 1
        let is_cancelled = EasyMotion#Sol(0,a:direction)
        if is_cancelled == 1
            break
        endif

        let selected_line = line('.')
        let duplicated_line_index = index(lazy_lines, selected_line)
        if duplicated_line_index >= 0
            call remove(lazy_lines, duplicated_line_index)
            call remove(lazy_hl_lines, duplicated_line_index)
        else
            call add(lazy_lines, selected_line)
            call add(lazy_hl_lines, '\%'. selected_line .'l')
        endif

        call EasyMotion#highlight#delete_highlight('LazyLines')
        call EasyMotion#highlight#add_highlight(join(lazy_hl_lines, '\|'), 'LazyLines')

        " Jump back to show save marker
        call setpos('.', save_pos)
    endwhile "}}}

    call EasyMotion#highlight#delete_highlight()

    " Do something for each pos {{{
    let line_compensation = 0
    for line_num in reverse(lazy_lines)
        call setpos('.', [save_pos[0],line_num,0,0])
        if line_num < save_pos[1]
            let line_compensation += 1
        endif
        normal! "_dd
    endfor "}}}

    echo 'Deleted ' . len(lazy_lines) . ' lines'

    " Restore {{{
    let g:EasyMotion_enter_jump_first = save_enter_jump_first
    let g:EasyMotion_ignore_exception = 0
    " Restore cursor
    let save_pos[1] -= line_compensation
    call setpos('.', save_pos)
    "}}}
endfunction "}}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
" }}}
