call plug#begin()
	Plug 'L3MON4D3/LuaSnip'
	Plug 'Xuyuanp/nerdtree-git-plugin'
	Plug 'chentoast/marks.nvim'
	Plug 'gioele/vim-autoswap'
	Plug 'hrsh7th/cmp-buffer'
	Plug 'hrsh7th/cmp-nvim-lsp'
	Plug 'hrsh7th/cmp-nvim-lua'
	Plug 'hrsh7th/cmp-path'
	Plug 'hrsh7th/nvim-cmp'
	Plug 'jlanzarotta/bufexplorer'
	Plug 'junnplus/lsp-setup.nvim'
	Plug 'mbbill/undotree'
	Plug 'morhetz/gruvbox'
	Plug 'neovim/nvim-lspconfig'
	Plug 'nvim-telescope/telescope.nvim'
	Plug 'nvim-treesitter/nvim-treesitter'
	Plug 'preservim/nerdtree'
	Plug 'rafamadriz/friendly-snippets'
	Plug 'ray-x/lsp_signature.nvim'
	Plug 'rust-lang/rust.vim'
	Plug 'saadparwaiz1/cmp_luasnip'
	Plug 'simrat39/inlay-hints.nvim'
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-surround'
	Plug 'williamboman/mason-lspconfig.nvim'
	Plug 'williamboman/mason.nvim'
	Plug 'ziglang/zig.vim'
  	Plug 'nvim-lua/plenary.nvim'
  	Plug 'nvim-lua/popup.nvim'
call plug#end()
set shell=/bin/bash

nmap ; :
autocmd BufNewFile * if wordcount()['chars'] == 0 | startinsert | endif
autocmd BufNewFile,BufRead *.avsc set filetype=json
set encoding=UTF-8
set cursorline
set number
set nobackup
let mapleader = " "

"TODO find a replacement for ; for F, T commands


map <leader>j :BufExplorer<CR><ESC>
nnoremap <leader>f :NERDTreeToggle<CR>
nnoremap <leader>c :e $MYVIMRC<CR>
nnoremap <leader>g :NERDTreeFind<CR>
nnoremap <leader>h :NERDTreeCWD<CR>
nnoremap <leader>b :Git blame<CR>
nnoremap <leader>k :Telescope lsp_document_symbols ignore_symbols=module,enummember,typeparameter<CR>
nnoremap <leader>d :Telescope diagnostics<CR>
nnoremap <leader>s :Git<CR>

"nnoremap <leader>h :tabnext<CR>
"nnoremap <leader>l :tabprevious<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k

map <c-P> :Telescope find_files hidden=true<CR>
map <c-G> :Telescope git_status<CR>
map <F1> :Telescope live_grep glob_pattern=!*.{py,lock,ini} hidden=true<CR>
map <F2> :Telescope live_grep hidden=true<CR>
map <c-B> :Telescope buffers<CR>
map('n', '<leader>gd', '<cmd>lua require"telescope.builtin".lsp_definitions({jump_type="vsplit"})<CR>', {noremap=true, silent=true})
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

require("mason").setup()

-- LSP_SIGNATURE
local cfg = {}
require "lsp_signature".setup(cfg)

-- LSP CONFIG
local lspconfig = require('lspconfig')
lspconfig.pyright.setup {}
lspconfig.tsserver.setup {}
lspconfig.zls.setup {}
lspconfig.yamlls.setup({
  settings = {
	yaml = {
		keyOrdering = false
		}
	}
  })
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

require'lspconfig'.yamlls.setup{
    on_attach=on_attach,
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    settings = {
        yaml = {
            schemas = {
		["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.json"] = "*.yaml"
            }
        }
    }
}

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
--    ["k"] = cmp.mapping.select_prev_item(),
 --   ["j"] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = {
    -- TODO: currently snippets from lsp end up getting prioritized -- stop that!
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
  },   experimental = {
    ghost_text = true,
  },
})
cmp.setup({
    enabled = function()
      -- disable completion in comments
      local context = require 'cmp.config.context'
      -- keep command mode completion enabled when cursor is in a comment
      if vim.api.nvim_get_mode().mode == 'c' then
        return true
      else
        return not context.in_treesitter_capture("comment") 
          and not context.in_syntax_group("Comment")
      end
    end
})


-- Enable completing paths in :
-- cmp.setup.cmdline(':', {
  -- sources = cmp.config.sources({
    -- { name = 'path' }
  -- })
-- })

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration

local keymap_opts = { buffer = buffer }
-- Code navigation and shortcuts
-- vim.keymap.set("n", "<c-]>", vim.lsp.buf.definition, keymap_opts)
vim.keymap.set("n", "K", vim.lsp.buf.hover, keymap_opts)
vim.keymap.set("n", "gD", vim.lsp.buf.implementation, keymap_opts)
vim.keymap.set("n", "gS", vim.lsp.buf.signature_help, keymap_opts)
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

--LINTING

function Bundle()
	local filename = vim.fn.expand('%')
	local bundle_command = "!swagger-cli bundle -r -t yaml " .. filename .. " --o _build/toto.yaml"
	local ret = vim.cmd(bundle_command)
	local open_command = "!open-swagger-ui _build/toto2.yaml --open"
	--vim.cmd("!sed 's/openapi: 3.1.0/openapi: 3.0.0/g' -i _build/toto.yaml")
	vim.cmd("!sed 's/openapi: 3.1.0/openapi: 3.0.0/g' < _build/toto.yaml > _build/toto2.yaml")
	vim.cmd(open_command)
end

	
function FormatMyFile()
    local filetype = vim.bo.filetype
    if filetype == "rust" then
	    vim.cmd(":RustFmt")
    elseif filetype == "json" or filetype == "avsc" then
	    vim.cmd(":%!python3 -m json.tool --no-ensure-ascii")
    elseif filetype == "sql" then
	    SqlFormat()
    elseif filetype == "yml" or filetype == "yaml" then
	    vim.cmd(":!spectral lint % --ruleset .dev_spectral.yaml")
    else 
	print("no formatters for this format!")
    end
end

function SqlFormat()
	local exit_code = vim.fn.system(cmd)
end

EOF
"au Filetype rust noremap <leader>r :RustFmt<CR>
"au Filetype json noremap <leader>r :%!python3 -m json.tool<CR>
"au Filetype sql noremap <leader>r :%!python3 -m sql-formatter<CR>

nnoremap <leader>r :lua FormatMyFile()<CR>
nnoremap <leader>p :lua Bundle(FormatMyFile)<CR>

hi Normal guibg=none ctermbg=none
hi LineNr guibg=none ctermbg=none
hi Folded guibg=none ctermbg=none
hi NonText guibg=none ctermbg=none
hi SpecialKey guibg=none ctermbg=none
hi VertSplit guibg=none ctermbg=none
hi SignColumn guibg=none ctermbg=none
hi EndOfBuffer guibg=none ctermbg=none
