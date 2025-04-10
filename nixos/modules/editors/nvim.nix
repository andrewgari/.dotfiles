# modules/editors/nvim.nix
{ config, pkgs, lib, ... }:

{
  # Install neovim and plugins
  environment.systemPackages = with pkgs; [
    neovim
    vimPlugins.LazyVim
    vimPlugins.nvim-treesitter
    vimPlugins.vim-git
    
    # Development tools needed for neovim plugins
    git
    ripgrep
    fd
    nodejs # for LSP servers
    python3 # for some plugins
  ];
  
  # Set default editor to neovim
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  
  # System-wide Neovim configuration - basic init.lua
  environment.etc."xdg/nvim/init.lua".text = ''
    -- Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- Basic options
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.mouse = 'a'
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.hlsearch = true
    vim.opt.wrap = false
    vim.opt.breakindent = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.signcolumn = 'yes'
    vim.opt.splitright = true
    vim.opt.splitbelow = true
    vim.opt.termguicolors = true
    vim.opt.cursorline = true
    vim.opt.clipboard = 'unnamedplus'
    vim.opt.undofile = true
    vim.opt.scrolloff = 8
    vim.opt.sidescrolloff = 8
    
    -- Plugins (via lazy.nvim)
    require("lazy").setup({
      -- Theme
      {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
          require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = false,
            integrations = {
              cmp = true,
              treesitter = true,
              telescope = true,
              which_key = true,
              notify = true,
            },
          })
          vim.cmd.colorscheme "catppuccin"
        end,
      },
      
      -- File explorer
      {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons",
          "MunifTanjim/nui.nvim",
        },
        config = function()
          require("neo-tree").setup()
          vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { silent = true })
        end,
      },
      
      -- Fuzzy finder
      {
        'nvim-telescope/telescope.nvim',
        dependencies = {
          'nvim-lua/plenary.nvim',
        },
        config = function()
          local telescope = require('telescope')
          telescope.setup()
          
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
          vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        end,
      },
      
      -- Improved syntax highlighting
      {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
          require("nvim-treesitter.configs").setup({
            ensure_installed = {
              "lua", "vim", "vimdoc", "javascript", "typescript", "python",
              "rust", "go", "c", "cpp", "bash", "html", "css", "json", "yaml", "toml",
              "markdown", "nix"
            },
            highlight = { enable = true },
            indent = { enable = true },
          })
        end,
      },
      
      -- LSP support
      {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
          {'neovim/nvim-lspconfig'},
          {'williamboman/mason.nvim'},
          {'williamboman/mason-lspconfig.nvim'},
          {'hrsh7th/nvim-cmp'},
          {'hrsh7th/cmp-nvim-lsp'},
          {'L3MON4D3/LuaSnip'},
        },
        config = function()
          local lsp = require('lsp-zero').preset({})
          
          lsp.on_attach(function(client, bufnr)
            lsp.default_keymaps({buffer = bufnr})
          end)
          
          -- Configure lua language server for neovim
          require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
          
          lsp.setup()
          
          -- Configure nvim-cmp
          local cmp = require('cmp')
          cmp.setup({
            mapping = {
              ['<CR>'] = cmp.mapping.confirm({select = false}),
              ['<Tab>'] = cmp.mapping.select_next_item(),
              ['<S-Tab>'] = cmp.mapping.select_prev_item(),
            }
          })
        end
      },
      
      -- Git integration
      {
        'lewis6991/gitsigns.nvim',
        config = function()
          require('gitsigns').setup()
        end
      },
      
      -- Status line
      {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
          require('lualine').setup({
            options = {
              theme = 'catppuccin',
              component_separators = '|',
              section_separators = ' ',
            },
          })
        end,
      },
    })
    
    -- Key mappings
    -- Save file
    vim.keymap.set('n', '<leader>w', ':w<CR>', { silent = true })
    
    -- Quit
    vim.keymap.set('n', '<leader>q', ':q<CR>', { silent = true })
    
    -- Better window navigation
    vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true })
    vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true })
    vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true })
    vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true })
    
    -- Resize windows
    vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', { silent = true })
    vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', { silent = true })
    vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { silent = true })
    vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { silent = true })
    
    -- Move lines
    vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { silent = true })
    vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { silent = true })
    vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true })
    vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true })
    
    -- Keep visual selection when indenting
    vim.keymap.set('v', '<', '<gv', { silent = true })
    vim.keymap.set('v', '>', '>gv', { silent = true })
    
    -- Disable search highlight on escape
    vim.keymap.set('n', '<Esc>', ':noh<CR>', { silent = true })
  '';
}