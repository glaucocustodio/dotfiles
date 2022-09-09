call plug#begin()
 Plug 'scrooloose/nerdtree'
 Plug 'vim-airline/vim-airline'
 Plug 'sheerun/vim-polyglot'
 Plug 'nvim-lua/plenary.nvim'
 Plug 'nvim-telescope/telescope.nvim'
 Plug 'jiangmiao/auto-pairs'
 Plug 'tpope/vim-endwise'
 Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
 Plug 'lewis6991/gitsigns.nvim'
 Plug 'overcache/NeoSolarized'
 Plug 'mhinz/vim-startify'
 Plug 'Yggdroot/indentLine'
 Plug 'mg979/vim-visual-multi'
 Plug 'kyazdani42/nvim-web-devicons'
 Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
 Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" Global Sets """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"
syntax on            " Enable syntax highlight
set nu               " Enable line numbers
set tabstop=2        " Show existing tab with 4 spaces width
set softtabstop=2    " Show existing tab with 4 spaces width
set shiftwidth=2     " When indenting with '>', use 4 spaces width
set expandtab        " On pressing tab, insert 4 spaces
set smarttab         " insert tabs on the start of a line according to shiftwidth
set smartindent      " Automatically inserts one extra level of indentation in some cases
set hidden           " Hides the current buffer when a new file is openned
set incsearch        " Incremental search
set ignorecase       " Ingore case in search
set smartcase        " Consider case if there is a upper case character
set scrolloff=8      " Minimum number of lines to keep above and below the cursor
set colorcolumn=100  " Draws a line at the given line to keep aware of the line size
set signcolumn=yes   " Add a column on the left. Useful for linting
set cmdheight=2      " Give more space for displaying messages
set updatetime=100   " Time in miliseconds to consider the changes
set encoding=utf-8   " The encoding should be utf-8 to activate the font icons
set nobackup         " No backup files
set nowritebackup    " No backup files
set splitright       " Create the vertical splits to the right
set splitbelow       " Create the horizontal splits below
set autoread         " Update vim after file update from outside
set mouse=a          " Enable mouse support
set cursorline       " Highlight the current line
filetype on          " Detect and set the filetype option and trigger the FileType Event
filetype plugin on   " Load the plugin file for the file type, if any
filetype indent on   " Load the indent file for the file type, if any

" AirLine """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#enabled = 0

" Find files using Telescope command-line sugar.
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg <cmd>Telescope live_grep<cr>
nnoremap fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

nnoremap e w
nnoremap w b

nnoremap bd <cmd>:bd<cr> " close buffer

" nnoremap q :q<CR>  " Easier closing of buffers

au! BufWritePost $NEOVIM_CONFIG_FILE source %

inoremap jj <Esc> " jj to leave insert mode

nmap <C-a> :NERDTreeToggle<CR>
" Shortcuts for split navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" enable fzf within telescope (allow searches with whitespace for instance)
lua require('telescope').load_extension('fzf')

" display git changes
lua require('gitsigns').setup()

" required for theme as per https://github.com/overcache/NeoSolarized
set termguicolors
colorscheme NeoSolarized

" Tab let you go to the next buffer and a Shift-Tab to the previous
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

" Open nerd tree at the current file or close nerd tree if pressed again (Ctrl+s)
nnoremap <silent> <expr> <C-s> g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"

" Copy relative file path (Ctrl+c)
nmap <C-c> :let @+ = expand("%")<CR>

" Source neovim config file
map sv :source $NEOVIM_CONFIG_FILE<CR>

map pi :PlugInstall<CR>

lua << EOF
require("bufferline").setup{}
EOF

" Use Ctrl + hjkl to resize windows (alt doesn't work on mac+iterm2)
nnoremap <C-j>    :resize -2<CR>
nnoremap <C-k>    :resize +2<CR>
nnoremap <C-h>    :vertical resize -2<CR>
nnoremap <C-l>    :vertical resize +2<CR>

" Better tabbing (avoid unselecting after first tab)
vnoremap < <gv
vnoremap > >gv

" COC config
"
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_global_extensions = ['coc-solargraph']

" GoTo code navigation.
nmap <silent> gh <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap hg <C-o>

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
