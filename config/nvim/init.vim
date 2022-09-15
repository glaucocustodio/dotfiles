call plug#begin()
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
 Plug 'ludovicchabant/vim-gutentags'
 Plug 'MunifTanjim/nui.nvim'
 Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
 Plug 'nvim-neo-tree/neo-tree.nvim'
call plug#end()

" Global Sets """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"
syntax on                 " Enable syntax highlight
set nu                    " Enable line numbers
set tabstop=2             " Show existing tab with 4 spaces width
set softtabstop=2         " Show existing tab with 4 spaces width
set shiftwidth=2          " When indenting with '>', use 4 spaces width
set expandtab             " On pressing tab, insert 4 spaces
set smarttab              " insert tabs on the start of a line according to shiftwidth
set smartindent           " Automatically inserts one extra level of indentation in some cases
set hidden                " Hides the current buffer when a new file is openned
set incsearch             " Incremental search
set ignorecase            " Ingore case in search
set smartcase             " Consider case if there is a upper case character
set scrolloff=8           " Minimum number of lines to keep above and below the cursor
set colorcolumn=100       " Draws a line at the given line to keep aware of the line size
set signcolumn=yes        " Add a column on the left. Useful for linting
set cmdheight=2           " Give more space for displaying messages
set updatetime=100        " Time in miliseconds to consider the changes
set encoding=utf-8        " The encoding should be utf-8 to activate the font icons
set nobackup              " No backup files
set nowritebackup         " No backup files
set splitright            " Create the vertical splits to the right
set splitbelow            " Create the horizontal splits below
set autoread              " Update vim after file update from outside
set mouse=a               " Enable mouse support
set cursorline            " Highlight the current line
set clipboard=unnamedplus " Copy paste between vim and everything else
filetype on               " Detect and set the filetype option and trigger the FileType Event
filetype plugin on        " Load the plugin file for the file type, if any
filetype indent on        " Load the indent file for the file type, if any


let g:neo_tree_remove_legacy_commands = 1
let g:gutentags_ctags_tagfile = '.tags'
let loaded_netrwPlugin = 1

lua << EOF
  require("neo-tree").setup({
    close_if_last_window = false,
    window = {
      mappings = {
        ["<cr>"] = "open",
        ["o"] = "open",
        ["p"] = "toggle_preview",
        ["J"] = function(state)
          local tree = state.tree
          local node = tree:get_node()
          local siblings = tree:get_nodes(node:get_parent_id())
          local renderer = require('neo-tree.ui.renderer')
          renderer.focus_node(state, siblings[#siblings]:get_id())
        end,
        ["K"] = function(state)
          local tree = state.tree
          local node = tree:get_node()
          local siblings = tree:get_nodes(node:get_parent_id())
          local renderer = require('neo-tree.ui.renderer')
          renderer.focus_node(state, siblings[1]:get_id())
        end
      },
    },
    filesystem = {
      follow_current_file = true
    },
    event_handlers = {
      {
         event = "file_opened",
         handler = function()
           vim.cmd("Neotree filesystem toggle")
         end
      }
    }
  })
EOF

" reminder: `gf` keybinding in normal mode opens file path under cursor

" AirLine """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#enabled = 0

" Find files using Telescope command-line sugar.
nnoremap ff <cmd>lua require('telescope.builtin').find_files({ find_command = {'fd', '--type', 'f', '--hidden', '--no-ignore', '--follow', '--color=never', '--exclude=.git', '--exclude=tmp', '--exclude=node_modules', '--exclude', 'public/assets' }})<cr>
nnoremap ft <cmd>Telescope live_grep<cr>
nnoremap fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>gc <cmd>Telescope git_commits<cr>
nnoremap <leader>gs <cmd>Telescope git_status<cr>

vnoremap e w
nnoremap e w
vnoremap w b
nnoremap w b

nnoremap bd <cmd>:bd<cr> " close buffer
nnoremap bd! <cmd>:bd!<cr> " close buffer

" Select All
nnoremap <silent> <C-a> ggVG
inoremap <silent> <C-a> <Esc>ggVG
vnoremap <silent> <C-a> <Esc>ggVG

" Turn off highlight of last search and paste mode when hitting Esc
nnoremap <silent> <Esc> <Esc>:noh<CR>

" nnoremap q :q<CR>  " Easier closing of buffers

au! BufWritePost $NEOVIM_CONFIG_FILE source %

inoremap jj <Esc> " jj to leave insert mode

nmap <leader>s :Neotree filesystem toggle<CR>

" enable fzf within telescope (allow searches with whitespace for instance)
lua require('telescope').load_extension('fzf')

" display git changes
lua << EOF
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '<leader>hd', gs.diffthis)
  end
})
EOF

" required for theme as per https://github.com/overcache/NeoSolarized
set termguicolors
colorscheme NeoSolarized

" Tab let you go to the next buffer and a Shift-Tab to the previous
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

" nmap <C-a> :NERDTreeToggle<CR>

" Open nerd tree at the current file or close nerd tree if pressed again (Ctrl+s)
" nnoremap <silent> <expr> <C-s> g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"

" Copy relative file path (Ctrl+c)
nmap <C-c> :let @+ = expand("%")<CR>

nmap <C-q> :q!<CR>

" Source neovim config file
map sv :source $NEOVIM_CONFIG_FILE<CR>

map pi :PlugInstall<CR>

lua << EOF
require("bufferline").setup({})
EOF

lua << EOF
require'nvim-treesitter.configs'.setup {
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

" Use Ctrl + hjkl to resize windows
nnoremap <C-j>    :resize -2<CR>
nnoremap <C-k>    :resize +2<CR>
nnoremap <C-h>    :vertical resize -2<CR>
nnoremap <C-l>    :vertical resize +2<CR>

" M = Options on Mac+iTerm2, it requires enabling Esc+: go to Preferences > Profiles, select
" your current profile, go to the 'keys' tab for that profile and change the option
" that says 'Left ⌥ Key" to Esc+'.
noremap <M-j> :m+<CR>
noremap <M-k> :m .-2<CR>

vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv


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
" nmap <silent> gh <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap hg <C-o>

function! s:GoToDefinition()
  if CocAction('jumpDefinition')
    return v:true
  endif

  let ret = execute("silent! normal \<C-]>")
  if ret =~ "Error" || ret =~ "错误"
    call searchdecl(expand('<cword>'))
  endif
endfunction

" Try to use LSP to find the definition, if can't find, search using ctags
nmap <silent> gh :call <SID>GoToDefinition()<CR>

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
