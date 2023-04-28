call plug#begin()
	Plug 'preservim/nerdtree'
	Plug 'jlanzarotta/bufexplorer'
	Plug 'morhetz/gruvbox'
	Plug 'Xuyuanp/nerdtree-git-plugin'
	Plug 'nvim-telescope/telescope.nvim'
	Plug 'gioele/vim-autoswap'
	Plug 'junnplus/lsp-setup.nvim'
	Plug 'nvim-treesitter/nvim-treesitter'
	Plug 'rust-lang/rust.vim'
	Plug 'chentoast/marks.nvim'
	Plug 'ThePrimeagen/harpoon'
  	Plug 'nvim-lua/popup.nvim'
  	Plug 'nvim-lua/plenary.nvim'
  	Plug 'nvim-telescope/telescope.nvim'
	Plug 'mbbill/undotree'
	Plug 'neovim/nvim-lspconfig'
	Plug 'williamboman/mason.nvim'
	Plug 'williamboman/mason-lspconfig.nvim'
	Plug 'hrsh7th/nvim-cmp'
	Plug 'hrsh7th/cmp-buffer'
	Plug 'hrsh7th/cmp-path'
	Plug 'saadparwaiz1/cmp_luasnip'
	Plug 'hrsh7th/cmp-nvim-lsp'
	Plug 'hrsh7th/cmp-nvim-lua'
	Plug 'L3MON4D3/LuaSnip'
	Plug 'rafamadriz/friendly-snippets'
	Plug 'simrat39/inlay-hints.nvim'
call plug#end()
set shell=/bin/bash

nmap ; :
autocmd BufNewFile * if wordcount()['chars'] == 0 | startinsert | endif
set encoding=UTF-8
set cursorline
set number
set nobackup
let mapleader = " "

au Filetype rust noremap <leader>r :RustFmt<CR>
au Filetype json noremap <leader>r :%!python3 -m json.tool<CR>
au Filetype sql noremap <leader>r :%!python3 -m sql-formatter<CR>


nnoremap <leader>f :NERDTreeToggle<CR>
nnoremap <leader>c :e $MYVIMRC<CR>
nnoremap <leader>g :NERDTreeFind<CR>
nnoremap <leader>h :NERDTreeCWD<CR>
"nnoremap <leader>h :tabnext<CR>
"nnoremap <leader>l :tabprevious<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k

map <TAB> :BufExplorer<CR><ESC>
map <c-P> :Telescope find_files hidden=true<CR>
map <c-G> :Telescope git_status<CR>
map <F1> :Telescope live_grep glob_pattern=!*.{py,lock,ini}<CR>
map <F2> :Telescope live_grep<CR>
map <c-B> :Telescope buffers<CR>
syntax enable
filetype plugin indent on
"nnoremap <F1> <cmd>lua require('telescope.builtin').live_grep()<cr>

" jonhoo
nnoremap j gj
nnoremap k gk
set incsearch
set ignorecase
set smartcase
set gdefault

nnoremap <F5> :UndotreeToggle<CR>

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
"--jonhoo

colorscheme gruvbox
syntax on

lua << EOF

local lspconfig = require('lspconfig')
lspconfig.pyright.setup {}
lspconfig.tsserver.setup {}
lspconfig.rust_analyzer.setup {
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {
 	procMacro = {
        enable = false
        },
	    },
  },
}
local ih = require("inlay-hints")

require("rust-tools").setup({
  tools = {
    on_initialized = function()
      ih.set_all()
    end,
    inlay_hints = {
      auto = false,
    },
  },
  server = {
    on_attach = function(c, b)
      ih.on_attach(c, b)
    end,
  },
})

require("inlay-hints").setup()
-- CHARGEMENT DES PLUGINS

-- vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.completeopt = "menu,menuone,noselect"

-- Avoid showing extra messages when using completion
vim.opt.shortmess = vim.opt.shortmess + "c"

-- Configure LSP through rust-tools.nvim plugin.
-- rust-tools will configure and enable certain LSP features for us.
-- See https://github.com/simrat39/rust-tools.nvim#configuration
local opts = {
  tools = {
    runnables = {
      use_telescope = true,
    },
    -- inlay_hints = {
      -- auto = true,
      sh-- ow_parameter_hints = true,
    -- },
  },
}

local cmp = require("cmp")

cmp.setup({
  snippet = {
    -- REQUIRED by nvim-cmp. get rid of it once we can
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["k"] = cmp.mapping.select_prev_item(),
    ["j"] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    -- TODO: currently snippets from lsp end up getting prioritized -- stop that!
    { name = 'nvim_lsp' },
  }, {
    { name = 'path' },
  }),
  experimental = {
    ghost_text = true,
  },
})

-- Enable completing paths in :
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  })
})

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration

local keymap_opts = { buffer = buffer }
-- Code navigation and shortcuts
vim.keymap.set("n", "<c-]>", vim.lsp.buf.definition, keymap_opts)
vim.keymap.set("n", "K", vim.lsp.buf.hover, keymap_opts)
vim.keymap.set("n", "gD", vim.lsp.buf.implementation, keymap_opts)
-- vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, keymap_opts)
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, keymap_opts)
vim.keymap.set("n", "gr", vim.lsp.buf.references, keymap_opts)
vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, keymap_opts)
vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, keymap_opts)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, keymap_opts)
vim.keymap.set("n", "ga", vim.lsp.buf.code_action, keymap_opts)
vim.keymap.set("n", "gR", vim.lsp.buf.rename, keymap_opts)
vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, keymap_opts)
vim.keymap.set("n", "g]", vim.diagnostic.goto_next, keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>dd', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })

require'marks'.setup {
  -- whether to map keybinds or not. default true
  default_mappings = true,
  -- which builtin marks to show. default {}
  builtin_marks = { ".", "<", ">", "^" },
  -- whether movements cycle back to the beginning/end of buffer. default true
  cyclic = true,
  -- whether the shada file is updated after modifying uppercase marks. default false
  force_write_shada = false,
  -- how often (in ms) to redraw signs/recompute mark positions. 
  -- higher values will have better performance but may cause visual lag, 
  -- while lower values may cause performance penalties. default 150.
  refresh_interval = 250,
  -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
  -- marks, and bookmarks.
  -- can be either a table with all/none of the keys, or a single number, in which case
  -- the priority applies to all marks.
  -- default 10.
  sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
  -- disables mark tracking for specific filetypes. default {}
  excluded_filetypes = {},
  -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
  -- sign/virttext. Bookmarks can be used to group together positions and quickly move
  -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
  -- default virt_text is "".
  bookmark_0 = {
    sign = "⚑",
    virt_text = "hello world",
    -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
    -- defaults to false.
    annotate = false,
  },
  mappings = {}
}
EOF

hi Normal guibg=none ctermbg=none
hi LineNr guibg=none ctermbg=none
hi Folded guibg=none ctermbg=none
hi NonText guibg=none ctermbg=none
hi SpecialKey guibg=none ctermbg=none
hi VertSplit guibg=none ctermbg=none
hi SignColumn guibg=none ctermbg=none
hi EndOfBuffer guibg=none ctermbg=none
