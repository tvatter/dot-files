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
Plug 'mllg/vim-devtools-plugin'

" Markdown and RMarkdown
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-rmarkdown'

" Python
Plug 'vim-python/python-syntax'
Plug 'python-mode/python-mode'
" Plug 'jupyter-vim/jupyter-vim'
" Plug 'szymonmaszke/vimpyter'

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
Plug 'dense-analysis/ale'

" Find and replace
Plug 'brooth/far.vim'

" Comment/uncomment easily
Plug 'scrooloose/nerdcommenter'

" Improved terminal
Plug 'kassio/neoterm'

" Initialize plugin system
call plug#end()

" ============================================================================
" ======== General options
" ============================================================================

" Color theme 
silent! colorscheme NeoSolarized

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
  " autocmd BufRead,BufNewFile *.Rmd set filetype=rmarkdown 
  autocmd FileType markdown,latex,rmarkdown,text setlocal spell
  autocmd BufRead,BufNewFile *.md,*.tex,*.Rmd,*.txt setlocal spell
augroup END

" ============================================================================
" ======== Key-mappings
" ============================================================================

" Easy switch between buffers
nnoremap <F4> :buffers<CR>:buffer<Space>

" To keep the content of register when pasting over selected text
vnoremap <leader>p "_dP

" " Copy to clipboard
vnoremap  <A-y>  "+y
nnoremap  <A-y>  "+y
" nnoremap  <A-Y>  "+yg_
" nnoremap  <A-y>y  "+yy

" " Paste from clipboard
nnoremap <A-p> "+p
nnoremap <A-P> "+P
vnoremap <A-p> "+p
vnoremap <A-P> "+P

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

" To clean up most syntax highlighting problems
noremap <F12> <Esc>:syntax sync fromstart<CR>
inoremap <F12> <C-o>:syntax sync fromstart<CR>

" ============================================================================
" ======== neoterm
" ============================================================================

" To send stuff to the terminal
nnoremap <silent> <leader>tl :TREPLSendLine<cr>
vnoremap <silent> <leader>ts :TREPLSendSelection<cr>
vmap <tab> <Plug>(neoterm-repl-send)
nmap <tab> <Plug>(neoterm-repl-send-line)

" To clear the terminal
nnoremap <leader>tc :<c-u>exec v:count.'Tclear'<cr>

" To open a terminal in a new vertical split
nnoremap <leader>tn :vert Tnew<cr>

" Some filetypes aren't properly detected by vim
au VimEnter,BufRead,BufNewFile *.jl set filetype=julia
au VimEnter,BufRead,BufNewFile *.idr set filetype=idris
au VimEnter,BufRead,BufNewFile *.lidr set filetype=lidris
au VimEnter,BufRead,BufNewFile *.lfe, set filetype=lfe

" ============================================================================
" ======== NERDTree
" ============================================================================

" Let nerdree see hidden files and start with vim
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd BufWritePost * NERDTreeFocus | execute 'normal R' | wincmd p
map <C-n> :NERDTreeToggle<CR>

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

let g:tex_flavor = "latex"
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats ='pdf,bib,pdf'
let g:Tex_GotoError = 0
" let g:Tex_AutoFolding = 0
augroup vimlatex
    autocmd!
    " Special commands
    autocmd FileType tex imap <C-v> <Plug>Tex_InsertItemOnThisLine
    autocmd FileType tex imap <C-b> <Plug>Tex_MathBF
    autocmd FileType tex imap <C-c> <Plug>Tex_MathCal
    autocmd FileType tex imap <C-l> <Plug>Tex_LeftRight
augroup END

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
    autocmd FileType c,cpp nnoremap <buffer> gs :<c-u>call ncm2_pyclang#goto_declaration_split()<cr>
    autocmd FileType c,cpp nnoremap <buffer> gv :<c-u>call ncm2_pyclang#goto_declaration_vsplit()<cr>
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
" R output is highlighted with current colorscheme
let g:rout_follow_colorscheme = 1
" R commands in R output are highlighted
let g:Rout_more_colors = 1

augroup nvimr
    autocmd!
    " To activate the plugin when opening .Rproj files
    autocmd BufNewFile,BufRead *.Rproj set ft=r
    autocmd BufNewFile,BufRead *.Rproj set syntax=yaml
    " Press the space bar to send lines and selection to R:
    autocmd FileType R,r,Rmd,rmd nnoremap <buffer> <Space> :<c-u>call SendLineToR("down")<cr>
    autocmd FileType R,r,Rmd,rmd vnoremap <buffer> <Space> :<c-u>call SendSelectionToR("echo", "down")<cr>
augroup END

" ============================================================================
" ======== Python (python-syntax and python-mode)
" ============================================================================

" autocmd Filetype ipynb nmap <silent><Leader>b :VimpyterInsertPythonBlock<CR>
" autocmd Filetype ipynb nmap <silent><Leader>j :VimpyterStartJupyter<CR>

let g:conda_env = '/home/tvatter/miniconda/envs/vim'
let g:python3_host_prog = join([conda_env, '/bin/python3'], "")
set pyxversion=3

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

let g:ale_python_autopep8_executable = join([conda_env, '/bin/autopep8'], "")
let g:ale_python_isort_executable = join([conda_env, '/bin/isort'], "")
let g:ale_python_flake8_executable = join([conda_env, '/bin/flake8'], "")
let g:ale_python_pylint_executable = join([conda_env, '/bin/pylint'], "")
let g:ale_enabled = 1
let g:ale_sign_error = '✖︎'
let g:ale_sign_warning = '✔︎'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_fix_on_save = 1
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_c_parse_compile_commands = 1 " parse automatically `compile_commands.json`
" Otherwise, all linters are used and it kills the battery available by default
     " \   'cpp': ['clang', 'clangcheck'],
let g:ale_linters = {
     \   'cpp': ['clangtidy'],
     \   'python': ['flake8', 'pylint'],
     \}
let g:ale_fixers = {
      \   'cpp': ['clang-format', 'remove_trailing_lines', 'trim_whitespace'],
      \   'python':  ['trim_whitespace', 'remove_trailing_lines', 'add_blank_lines_for_python_control_statements', 'autopep8', 'isort'],
      \   'r':  ['trim_whitespace', 'remove_trailing_lines', 'styler'],
      \   'rmarkdown':  ['trim_whitespace', 'remove_trailing_lines', 'styler']
      \}

" ============================================================================
" ======== nerdcommenter
" ============================================================================

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1


