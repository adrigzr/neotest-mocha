set runtimepath+=.
set runtimepath+=../plenary.nvim
set runtimepath+=../neotest
set runtimepath+=../nvim-treesitter
runtime! plugin/plenary.vim
lua require("nvim-treesitter").setup { ensure_installed = { "javascript", "typescript" } }
