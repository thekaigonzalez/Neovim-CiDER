local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

local lazy = require("lazy")

lazy.setup({
	-- Adds pairs for (  ), [  ], etc.
	"jiangmiao/auto-pairs",

	-- Installed themes in CiDER
	"embark-theme/vim",
	"Mofiqul/vscode.nvim",
	{ "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ... },
	"tomasiser/vim-code-dark",

	-- Language-specific things
	"neovim/nvim-lspconfig",
	"folke/neodev.nvim",
	"p00f/clangd_extensions.nvim",

  -- Nvim-Cmp
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-vsnip",
	"hrsh7th/vim-vsnip",
	"hrsh7th/cmp-nvim-lua",

  -- -line (tablines, lualine)
	"nvim-lualine/lualine.nvim",
	"romgrk/barbar.nvim",

  -- Treesitter for amazing syntax highlighting
	"nvim-treesitter/nvim-treesitter",

  -- sexy scrolling ;)
	"joeytwiddle/sexy_scroller.vim",

  -- File Tree stuff
	"nvim-tree/nvim-tree.lua",
	"nvim-tree/nvim-web-devicons",

  -- Hover hints for mouse error finding
	"soulis-1256/hoverhints.nvim",

  -- Telescope for file searching and 
  -- others for outlining
	"nvim-telescope/telescope.nvim",
	"ellisonleao/glow.nvim",

  -- notifications
	"rcarriga/nvim-notify",
	"nvim-lua/plenary.nvim",

	"lukas-reineke/indent-blankline.nvim",

	{
		"folke/noice.nvim",
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
		},
	},
})
