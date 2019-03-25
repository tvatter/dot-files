" ============================================================================
" ======== STARTERS
" ============================================================================

filetype indent plugin on
set encoding=utf-8
scriptencoding utf-8
packadd vimball

if !exists('g:syntax_on')
  syntax enable
endif

if has('termguicolors')
    set termguicolors
endif

" Define leader and local leader
let mapleader = " "
let maplocalleader = ","

" ============================================================================
" ======== PLUGINS
" ============================================================================

call plug#begin('~/.local/share/nvim/plugged')

" Color theme
Plug 'iCyMind/NeoSolarized'

" A tree explorer 
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Status bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Autocomplete brackets, parentheses, etc.
Plug 'Raimondi/delimitMate'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Git
Plug 'tpope/vim-fugitive'

" Latex
Plug 'vim-latex/vim-latex'

" R
Plug 'jalvesaq/Nvim-R'

" Markdown and RMarkdown
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-rmarkdown'

" Python
Plug 'vim-python/python-syntax'
Plug 'python-mode/python-mode'

" Autocompletion
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2'
Plug 'ncm2/ncm2-ultisnips'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-pyclang'
Plug 'ncm2/ncm2-jedi'
Plug 'gaalcaras/ncm-R'

" Asynchronous linting/fixing
Plug 'w0rp/ale'

" Initialize plugin system
call plug#end()

" ============================================================================
" ======== General options
" ============================================================================

" Color theme 
colorscheme NeoSolarized

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+0
set formatoptions-=t " remove if you want auto-wrap

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
set autoindent    " apply the indentation of the current line to the next
set smartindent   " reacts to the syntax/style of the code you are editing (especially for C)
" set autoread      " Automatically read again a file that has been changed outside of Vim

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Disable paste mode when leaving insert mode
autocmd InsertLeave * set nopaste

" Change between apste and nopaste modes easily
set pastetoggle=<F3>

" ============================================================================
" ======== Options per filetypes
" ============================================================================

augroup FileOptions
  autocmd!
  " indentation
  " (for comments moving to BOL): https://stackoverflow.com/questions/2063175/comments-go-to-start-of-line-in-the-insert-mode-in-vim
  autocmd Filetype cpp,python setlocal sts=4 sw=4  
  autocmd BufRead,BufNewFile *.Rmd,*.md set wrap
  autocmd FileType markdown,latex,rmarkdown,text setlocal spell
  autocmd BufRead,BufNewFile *.md,*.tex,*.Rmd,*.txt setlocal spell
augroup END

" ============================================================================
" ======== Key-mappings
" ============================================================================

" Easy switch between buffers
nnoremap <F5> :buffers<CR>:buffer<Space>

" To keep the content of register when pasting over selected text
vnoremap <leader>p "_dP

" " Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
nnoremap  <leader>y  "+y
nnoremap  <leader>yy  "+yy

" " Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

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

" ============================================================================
" ======== NERDTree
" ============================================================================

" Let nerdree see hidden files and start with vim
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" ============================================================================
" ======== airline
" ============================================================================

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme= 'deus'
" Disable the whitespace extension to speed things up
let g:airline#extensions#whitespace#enabled = 0
" Don't show buffer numbers in the tab line
let g:airline#extensions#tabline#buffer_nr_show = 0
" enable/disable showing a summary of changed hunks under source control
let g:airline#extensions#hunks#enabled = 1
" Disable the wordcount (gives weird results for latex anyway)
let g:airline#extensions#wordcount#enabled = 0

" ============================================================================
" ======== vim-latex
" ============================================================================

let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats='pdf,bib,pdf'
let g:Tex_GotoError = 0
imap <C-v> <Plug>Tex_InsertItemOnThisLine
imap <C-b> <Plug>Tex_MathBF
imap <C-c> <Plug>Tex_MathCal
imap <C-l> <Plug>Tex_LeftRight

" ============================================================================
" ======== snippets
" ============================================================================

" Snipet and popup menu
" enter to trigger snippet expansion 
" c-j c-k for moving in snippet
inoremap <silent> <expr> <CR> ncm2_ultisnips#expand_or("\<CR>", 'n')
let g:UltiSnipsJumpForwardTrigger	= "<c-j>"
let g:UltiSnipsJumpBackwardTrigger	= "<c-k>"
"let g:UltiSnipsRemoveSelectModeMappings = 0

" ============================================================================
" ======== NCM2 (autocomplete)
" ============================================================================

" enable ncm2 for all buffers
augroup NCM
    autocmd!
    autocmd BufEnter * call ncm2#enable_for_buffer()
    " remap goto to gd
    autocmd FileType c,cpp nnoremap <buffer> gd :<c-u>call ncm2_pyclang#goto_declaration()<cr>
augroup END

" enable popupopen
set completeopt=noinsert,menuone,noselect

" path to the llvm library
let g:ncm2_pyclang#library_path = '/usr/lib/llvm-6.0/lib' "  '/usr/local/Cellar/llvm/7.0.1/lib'  

" where to look for compile_commands.json
let g:ncm2_pyclang#database_path = [
      \ 'compile_commands.json',
      \ 'build/compile_commands.json'
      \ ]

" setup that feels a little more like the completion menu of other IDEs 
inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
" inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"

" ============================================================================
" ======== NVIM-R
" ============================================================================

" vim-R
" autocmd VimResized * let R_rconsole_width = winwidth(0) " because the default sucks
let R_assign = 2 " two '_' inserts ' <- '
let R_buffer_opts = "nobuflisted" " remove winfixwidth to allow for automatic resizing
" Press the space bar to send lines and selection to R:
vmap <Space> <Plug>RDSendSelection
nmap <Space> <Plug>RDSendLine
" R output is highlighted with current colorscheme
let g:rout_follow_colorscheme = 1
" R commands in R output are highlighted
let g:Rout_more_colors = 1

" ============================================================================
" ======== Python (python-syntax and python-mode)
" ============================================================================

" python-syntax
let g:python_highlight_builtins = 1
let g:python_highlight_builtin_objs = 1
let g:python_highlight_builtin_funcs = 1
let g:python_highlight_builtin_funcs_kwarg = 1
let g:python_highlight_exceptions = 1
let g:python_highlight_string_formatting = 1
let g:python_highlight_string_format = 1
let g:python_highlight_string_templates = 1
let g:python_highlight_indent_errors = 1
let g:python_highlight_space_errors = 1
let g:python_highlight_doctests = 1
let g:python_highlight_class_vars = 1
let g:python_highlight_operators = 1
let g:python_highlight_file_headers_as_comments = 1


" pymode
let g:pymode_python='python3'
" let g:pymode_paths = ['/usr/local/bin/python3.6']
let g:pymode_trim_whitespaces = 1
let g:pymode_indent = 1                     " PEP-8 compatible indent
let g:pymode_options_colorcolumn = 0
let g:pymode_lint = 0
let g:pymode_lint_on_write = 0
let g:pymode_rope = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_virtualenv = 1

" ============================================================================
" ======== ALE
" ============================================================================

let g:ale_enabled = 1
let g:ale_sign_error = '✖︎'
let g:ale_sign_warning = '✔︎'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_c_parse_compile_commands = 1 " parse automatically `compile_commands.json`
" Use linters available by default
" let g:ale_linters = {
"      \   'cpp': ['clang', 'clangcheck'],
"      \}
let g:ale_fixers = {
      \   'cpp': ['clang-format', 'remove_trailing_lines', 'trim_whitespace'],
      \}

