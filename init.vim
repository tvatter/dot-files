set encoding=utf-8
filetype plugin on
packadd vimball

call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes

" For the snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" A tree explorer 
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Status bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Git/alignments/latex
Plug 'tpope/vim-fugitive'
Plug 'junegunn/vim-easy-align'
Plug 'vim-latex/vim-latex'

" Autocompletion
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'jalvesaq/Nvim-R'
Plug 'gaalcaras/ncm-R'
Plug 'ncm2/ncm2-ultisnips'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-pyclang'

" Initialize plugin system
call plug#end()

" Let nerdree see hidden files and start with vim
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Numbers
set number
set numberwidth=5

set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands
" set autoread      " Automatically read again a file that has been changed outside of Vim

" Useful stuff for buffers
nnoremap <F5> :buffers<CR>:buffer<Space>

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Quicker window movement
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" To map <Esc> to exit terminal-mode
tnoremap <Esc> <C-\><C-n>

" To simulate |i_CTRL-R| in terminal-mode
tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme= 'deus'
" Disable the whitespace extension to speed things up
let g:airline#extensions#whitespace#enabled = 0
" Don't show buffer numbers in the tab line
let g:airline#extensions#tabline#buffer_nr_show = 0
" enable/disable showing a summary of changed hunks under source control
let g:airline#extensions#hunks#enabled = 1

" vim latex stuff
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats='pdf,bib,pdf'
let g:Tex_GotoError = 0
imap <C-v> <Plug>Tex_InsertItemOnThisLine
imap <C-b> <Plug>Tex_MathBF
imap <C-c> <Plug>Tex_MathCal
imap <C-l> <Plug>Tex_LeftRight

" ncm2 autocomplete
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect
autocmd FileType c,cpp nnoremap <buffer> gd :<c-u>call ncm2_pyclang#goto_declaration()<cr>
let g:ncm2_pyclang#library_path = '/usr/local/Cellar/llvm/7.0.1/lib' " '/usr/lib/llvm-6.0/lib'
let g:ncm2_pyclang#database_path = [
            \ 'compile_commands.json',
            \ 'build/compile_commands.json'
            \ ]

" Snipet and popup menu
" enter to trigger snippet expansion 
" c-j c-k for moving in snippet
inoremap <silent> <expr> <CR> ncm2_ultisnips#expand_or("\<CR>", 'n')
" let g:UltiSnipsExpandTrigger		= "<Plug>(ultisnips_expand)"
let g:UltiSnipsJumpForwardTrigger	= "<c-j>"
let g:UltiSnipsJumpBackwardTrigger	= "<c-k>"
let g:UltiSnipsRemoveSelectModeMappings = 0
