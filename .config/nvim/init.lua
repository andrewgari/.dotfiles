require'packer'.startup(function()
    use 'wbthomason/packer.nvim'
    use {
        'neovim/nvim-lspconfig',
        config = function()
            require'lspconfig'.tsserver.setup{}
            require'lspconfig'.gopls.setup{}
            require'lspconfig'.rust_analyzer.setup{}
            require'lspconfig'.jdtls.setup{}
            require'lspconfig'.kotlin_language_server.setup{}
            require'lspconfig'.pyright.setup{}
            require'lspconfig'.dockerls.setup{}
            require'lspconfig'.bashls.setup{}
            require'lspconfig'.jsonls.setup{}
            require'lspconfig'.yamlls.setup{}
            require'lspconfig'.taplo.setup{}
            require'lspconfig'.lemminx.setup{}
        end
    }
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use 'ThePrimeagen/harpoon'
    use 'nvim-lua/plenary.nvim'
end)

require'telescope'.setup{}
require'treesitter'.setup{}
