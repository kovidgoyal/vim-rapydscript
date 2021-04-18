set noexpandtab
set tabstop=4
set softtabstop=4
set magic

" highlight modes
let rapydscript_highlight_builtins = 1

" Setup ALE integration
function! s:ale_linters_rapydscript_lint_handle(buffer, lines) abort
    let l:lines = type(a:lines) is v:t_list ? a:lines : [a:lines]
    let l:output = []
    for l:line in l:lines
        let l:parts = split(l:line, ':;:')
        let l:item = {
        \   'lnum': l:parts[1] + 0,
        \   'col': l:parts[2] + 0,
        \   'type': l:parts[3],
        \   'code': l:parts[5],
        \   'text': l:parts[6],
        \}
        call add(l:output, l:item)
    endfor
    return l:output
endfunction

if !exists("g:loaded_ale_rapydscript_rapydscript_checker")
    let g:loaded_ale_rapydscript_rapydscript_checker = 1
    call g:ale#linter#Define('rapydscript', {
        \ 'name': 'rapydscript',
        \ 'callback': function('s:ale_linters_rapydscript_lint_handle'),
        \ 'executable': 'rapydscript',
        \ 'command': 'rapydscript lint --errorformat vim --stdin-filename %s -',
        \})
endif

" jump to variable/function definition, also finds variables declared in groups (implicit tuples)
nnoremap ,d ?\(\(global\\|nonlocal\) (\{0,1\}[^=(]*.\\|def \)\><CR>

" jump to previous variable assignment (var= | var+= | var||= | etc)
nnoremap ,= ?\(\([ ]*,[ ]*$[a-z][a-z0-9]*[ ]*\)*)\)\{0,1\}\s*\([-+*/%.\|&x^]\\|\(\*\*\\|\|\|\\|>>\\|<<\)\)\{0,1\}=[^=]<CR>``0n<Right>

" comment/uncomment (already part of my main .vimrc)
"map ,# :s_^_#_<CR>:noh<CR>
"map ,* :s_#__<CR>:noh<CR>

set makeprg=echo\ 'Compiling\ %'\ &&\ rapydscript\ %\ &&\ echo\ 'Finished\ compiling'

" trigger Tabular automatically on :, but only when line looks like a legit
" hash
"inoremap <silent> : :<Esc>:call Align(':', '^\s\+[''"]\?[A-Za-z0-9_-]\+[''"]\?\s*:$')<CR>a

" dump current arg (in the future I should have this auto-prepend \ to hashes
" and arrays)
map ,D! viwoh"zy<F12>o<HOME>console.log('<ESC>"zpa:',<ESC>"zpa)<ESC>hh<F12>

" python style comments instead of the default C style
set commentstring=#\ %s
