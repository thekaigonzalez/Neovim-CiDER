-- [[ THE CIDER NEOVIM FRAMEWORK v1.0.0! ]]
-- An amazing yet lightweight framework for a multitude of development,
-- with everything inbetween coming fresh out the box!

-- Custom Commands:
--
-- *  Open - Opens a file/directory and checks if a README.md is in it,
--    if so then it'll read the file, to give a rundown on how the program works.
--

-- [[ Specify the edition here (for developers and edition designers) ]]
local cider_edition = "pythonium"

if cider_edition == nil then
	cider_edition = "average"
end

local configs = vim.api.nvim_list_runtime_paths()
local now     = configs[1]

package.path = package.path .. ";" .. now .. "/?.lua;" .. now .. "/editions/?.lua"

require("plugins")(cider_edition)

local edition = require(cider_edition)
local settings = require("settings")

local lsp = edition.enabled_languages

-- CIDER Settings for netrw, etc.
vim.opt.termguicolors = true
vim.opt.pumblend = 1

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- vscode colourscheme
if (not vim.g.cider_init) then
  vim.cmd("colorscheme " .. (edition.enabled_theme or ""))
end

local cmp = require("cmp")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local telescope_builtin = require("telescope.builtin")

local keyset = vim.keymap.set

-- Shift+F      - Find
-- CTRL+F       - Format
-- CTRL+SHIFT+K - Make a newline and move back up.
-- CTRL+T       - Open the Nvim Tree Plugin
-- CTRL+W       - Closes the current buffer
-- CTRL+A       - Copies the entire buffer to the clipboard register.
keyset("n", "<C-f>", ":lua format()<CR>", { noremap = true })
keyset("n", "<C-t>", ":NvimTreeOpen<CR>", { noremap = true })
keyset("i", "<C-K>", "\n<left><Up>", { noremap = true })
keyset("n", "F", telescope_builtin.find_files, { noremap = true })
keyset("n", "<C-w>", ":w!<CR>:BufferClose<CR>", { noremap = true })
keyset("n", "<C-q>", ":q!<CR>", { noremap = true })
keyset("n", "<C-a>", "ggVG", { noremap = true })
keyset("n", "<C-s>", ":silent w<CR>", { noremap = true })
-- keyset("n", "<C-c>", ":%+y<CR>", { noremap = true })
keyset("v", "<C-c>", "yy<CR>", { noremap = true })
keyset("n", "<C-v>", "p<CR>", { noremap = true })
keyset("n", "<C-,>", ":BufferMovePrevious<CR>", { noremap = true })
keyset("n", "<C-.>", ":BufferMoveNext<CR>", { noremap = true })

vim.api.nvim_exec2(
	[[
    set backspace=indent,eol,start
" Configuration options
	  set encoding=utf-8
	  set nobackup
	  set nowritebackup
	  set updatetime=300
	  set signcolumn=yes

	  set tabstop=2
	  set shiftwidth=2

	  set expandtab	
	  set number
	  set autoread
	  ]],
	{}
)

function _G.check_back_space()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

function format()
	vim.cmd("silent w")

	if vim.bo.filetype == "c" then
		vim.fn.system("clang-format --style=GNU -i " .. vim.fn.expand("%"))
	elseif vim.bo.filetype == "lua" then
		vim.fn.system("stylua " .. vim.fn.expand("%"))
	elseif vim.bo.filetype == "zig" then
		vim.fn.system("zig fmt " .. vim.fn.expand("%"))
	else
		local found = false

		if edition.formatters ~= nil then
			for k, _ in pairs(edition.formatters) do
				if k == vim.bo.filetype then
					found = true
					edition.formatters[k](vim.fn.expand("%"))
				end
			end
		end

		if not found then
			vim.notify("no formatters found for '" .. vim.bo.filetype .. "'", vim.log.levels.ERROR)
		end
	end

	vim.cmd("edit!")
end

local _border = "rounded"

local lsp_objs = {
	border = _border,
	winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
}

require("lspconfig.ui.windows").default_options = lsp_objs

vim.diagnostic.config({
	float = lsp_objs,
})

-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, lsp_objs)

-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lsp_objs)

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
		end,
	},
	window = {
		completion = lsp_objs,
		documentation = cmp.config.window.bordered(lsp_objs),
	},
	-- mappings for
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<Tab>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "vsnip" }, -- For vsnip users.
	}, {
		{ name = "buffer" },
	}),
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
	}, {
		{ name = "buffer" },
	}),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

local function ternary(cond, T, F)
	if cond then
		return T
	else
		return F
	end
end

require("neodev").setup({})
require("nvim-tree").setup()

for _, v in ipairs(lsp) do
	require("lspconfig")[v].setup({
		capabilities = ternary((type(v) == "string"), capabilities, v.capabilities),
	})
end

require("lspconfig")["lua_ls"].setup({
	capabilities = capabilities,
})

require("lspconfig")["lua_ls"].setup({
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
		},
	},
})

require("clangd_extensions").setup({
	inlay_hints = {
		inline = vim.fn.has("nvim-0.10") == 1,
		-- Options other than `highlight' and `priority' only work
		-- if `inline' is disabled
		-- Only show inlay hints for the current line
		only_current_line = false,
		-- Event which triggers a refresh of the inlay hints.
		-- You can make this { "CursorMoved" } or { "CursorMoved,CursorMovedI" } but
		-- not that this may cause  higher CPU usage.
		-- This option is only respected when only_current_line and
		-- autoSetHints both are true.
		only_current_line_autocmd = { "CursorHold" },
		-- whether to show parameter hints with the inlay hints or not
		show_parameter_hints = true,
		-- prefix for parameter hints
		parameter_hints_prefix = "<- ",
		-- prefix for all the other hints (type, chaining)
		other_hints_prefix = "=> ",
		-- whether to align to the length of the longest line in the file
		max_len_align = false,
		-- padding from the left if max_len_align is true
		max_len_align_padding = 1,
		-- whether to align to the extreme right or not
		right_align = false,
		-- padding from the right if right_align is true
		right_align_padding = 7,
		-- The color of the hints
		highlight = "Comment",
		-- The highlight group priority for extmark
		priority = 100,
	},
	ast = {
		role_icons = {
			type = "",
			declaration = "",
			expression = "",
			specifier = "",
			statement = "",
			["template argument"] = "",
		},

		kind_icons = {
			Compound = "",
			Recovery = "",
			TranslationUnit = "",
			PackExpansion = "",
			TemplateTypeParm = "",
			TemplateTemplateParm = "",
			TemplateParamObject = "",
		},

		highlights = {
			detail = "Comment",
		},
	},
	memory_usage = {
		border = "none",
	},
	symbol_info = {
		border = "none",
	},
})

function open(nargs)
	local arg = nargs.args
	print("CiDER: looking for a README.md in workspace `" .. arg .. "'")

	vim.cmd("cd " .. arg)

	if vim.fn.filereadable("README.md") then
		vim.cmd("edit README.md")
	end
end

vim.api.nvim_create_user_command("Open", open, { nargs = "?" })

if settings.auto_open and not vim.g.cider_init then
  local before = vim.fn.expand("%")

	-- configure default autoopen in settings.lua
	vim.cmd(":Open .")
  vim.cmd(":b#")
  -- vim.cmd(":sb[1]")
  vim.cmd(":edit " .. before)

	vim.cmd("NvimTreeOpen")
end

require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
	highlight = { enable = true },
	indent = { enable = true },
})

require("ibl").setup({})
require("lualine").setup({})
require("hoverhints").setup({})
require("nvim-ts-autotag").setup({})
require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
    
	},
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
	smart_move = {
		-- noice tries to move out of the way of existing floating windows.
		enabled = true, -- you can disable this behaviour here
		-- add any filetypes here, that shouldn't trigger smart move.
		excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
	},
})

if edition.hooks and not vim.g.cider_init then edition.hooks() end

if not vim.g.cider_init then
  vim.g.cider_init = true;
end

