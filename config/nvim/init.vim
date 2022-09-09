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
call plug#end()

" Global Sets """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
"nnoremap <leader>fb <cmd>Telescope buffers<cr>
"nnoremap <leader>fh <cmd>Telescope help_tags<cr>

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
