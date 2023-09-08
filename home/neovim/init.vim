" Settings
"""""""""""""""""""""""""""

" Leave boomer mode
set nocompatible

set history=1000

" Backspace in insert mode
set backspace=indent,eol,start

" Hide buffer when abandoned (you can gd away, etc)
set hid

" Searching
" NOTE: ignorecase and smartcase must be used together (see :h 'smartcase')
set incsearch gdefault ignorecase smartcase nohlsearch

" Only auto-continue comments when i_<cr> is pressed (not n_o)
" Must be set after :filetype-plugin-on
filetype plugin indent on
au FileType * setlocal fo-=o fo+=r

" Enable syntax highlighting
syn on

" Colorscheme
au VimEnter * ++nested colorscheme ansi_linus

" Persistent undo
set undofile

" Line numbers
set number relativenumber

" Improve macro performance
set lazyredraw

" Show matching brackets
set showmatch
set matchtime=2

set listchars=tab:>-,eol:$,space:.,trail:@,nbsp:%

" Enable mouse input
set mouse=a

" sussy sus the sussy sus
set nowrap

" Mappings
"""""""""""""""""""""""""""

let g:mapleader = "\<space>"

" Some keys are hard to press with the Danish layout. Luckily, we have some
" spare keys! Note that ctrl and esc are swapped at the OS level.
nnoremap æ $
nnoremap Æ 0

" Switching windows
" TODO: make this work with iTerm2 panes
nnoremap <c-h> <c-w><c-h>
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
tnoremap <c-h> <c-\><c-n><c-w><c-h>
tnoremap <c-j> <c-\><c-n><c-w><c-j>
tnoremap <c-k> <c-\><c-n><c-w><c-k>
tnoremap <c-l> <c-\><c-n><c-w><c-l>

" Resize windows
nnoremap + <c-w>+
nnoremap - <c-w>-

" Switching tabs
nnoremap <silent> <leader>tt     :tabnext<CR>
nnoremap <silent> <leader>tn     :tabnew<CR>
nnoremap <silent> <leader>to     :tabonly<CR>
nnoremap <silent> <leader>tc     :tabclose<CR>
nnoremap <silent> <leader>tm     :tabmove
" Just use gt and gT
" nnoremap <silent> <leader>tl     :tabn<CR>
" nnoremap <silent> <leader>th     :tabN<CR>
nnoremap <silent> <leader>t<S-L> :tabl<CR>
nnoremap <silent> <leader>t<S-H> :tabr<CR>

" Fast macros (qq to record)
nnoremap Q @q
vnoremap Q :norm! @q<cr>

" Make Y act like C and D
nnoremap <s-y> y$
vnoremap <s-y> $y

" Indent using tab key
nnoremap <Tab>   >l
nnoremap <S-Tab> <l
vnoremap <Tab>   >gv
vnoremap <S-Tab> <gv

noremap! <C-j> <down>
noremap! <C-k> <up>
noremap! <C-h> <left>
noremap! <C-l> <right>

" Toggle showing 'listchars'
nnoremap <silent> <leader>l :set list!<cr>

" Escape in terminal mode
tnoremap <esc><esc> <c-\><c-n>

" Replace f and t with vim-sneak's version
let g:sneak#s_next = 1
let g:sneak#use_ic_scs = 1
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" Join to end of line below
" This is already used by the window switching mappings
" nnoremap <c-j> ddpkJ

" Commands
"""""""""""""""""""""""""""

" Create a temporary buffer
" NOTE: relied on by other commands
command Temp       new | setlocal buftype=nofile bufhidden=wipe noswapfile nomodified nobuflisted
command TempTab tabnew | setlocal buftype=nofile bufhidden=wipe noswapfile nomodified nobuflisted

" Reverse lines
command! -bar -range=% Reverse <line1>,<line2>g/^/m<line1>-1|nohl

" Redraw screen
" CTRL-L mapping is used in other thing
command Redraw norm! 

" Run buffer contents as vimscript
command! -bar -range=% Run execute 'silent!' . <line1> . ',' . <line2> . 'y|@"'

" Output the result of a command to the buf
command! -nargs=+ -complete=command Output
			\ redir => output               |
			\ silent execute <q-args>       |
			\ redir END                     |
			\ tabnew                        |
			\ setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified |
			\ silent put=output             |
			\ if <q-args> =~ ':!'           |
			\ 	silent 1,2delete _      |
			\ else                          |
			\ 	silent 1,4delete _      |
			\ endif

" Copy buffer to system clipboard
command! Copy silent w !pbcopy

" Copy the location of the current file
command! CopyDir !echo %:r | pbcopy

" View in-memory changes before writing to disk
command! DiffOnDisk
	\ let orig_filetype=&ft                         |
	\ vert new                                      |
	\ read ++edit # | 0d_                           |
	\ setlocal bt=nofile bh=wipe nobl noswf ro      |
	\ let &l:filetype = orig_filetype               |
	\ diffthis                                      |
	\ wincmd p                                      |
	\ diffthis

" Miscellaneous
"""""""""""""""""""""""""""

" Show the color column only if insert mode (and only if cc is set)
augroup ShowCCInInsertMode
        au!
	au InsertEnter * if &tw != 0 | let &cc = &tw + 1 | endif
	au InsertLeave * let &cc = 0
augroup END

" Auto-refresh vim config
" au BufWritePost $XDG_CONFIG_HOME/*.{vim,lua} so %

" Enter insert mode when entering terminals
au BufEnter term://* norm! i

" Jump to last editing location when opening files
au BufReadPost *
	\ if line("'\"") > 0 && line("'\"") <= line("$") |
	\ 	exe "normal! g'\"" |
	\ endif

" FIXME: disable in insertmode
augroup HighlightSusWhitespace
	au!
	" Whenever a colorscheme clears the highlighting, re-add our own rule
	au ColorScheme * hi SusWhitespace ctermbg=red guibg=red
	" Whenever a new window is created, create our matches
	au VimEnter,WinNew * match SusWhitespace /\s\+$/
	                \ | 2match SusWhitespace /\%u00A0/
augroup END
