{ config, pkgs, hostName, ... }:

let
	palette = config.theme.palette;
in
{
	# ── NEOVIM CONFIGURATION (NIXVIM) ─────────────────────────────────────────────
	programs.nixvim = {
		enable = true;

		# ── EDITOR OPTIONS ────────────────────────────────────────────────────────────
		opts = {
			number = true;
			relativenumber = true;
			tabstop = 4;
			shiftwidth = 4;
			expandtab = false;
			smartindent = true;
			wrap = false;
			ignorecase = true;
			smartcase = true;
			termguicolors = true;
			scrolloff = 8;
			signcolumn = "yes";
			updatetime = 50;
			cursorline = true;
			splitright = true;
			splitbelow = true;
			colorcolumn = "80"; # Visual guide for blocky headers
		};

		# ── COLORSCHEME & HIGHLIGHTS ──────────────────────────────────────────────────
		colorschemes.oxocarbon.enable = true;

		# --- Carbon g100 Strict Rules ---
		highlight = {
			String.fg = palette.syntaxString;
			Character.fg = palette.syntaxString;
			Operator.fg = palette.syntaxOp;
			Delimiter.fg = palette.syntaxPunct;
			Comment.fg = palette.syntaxComment;
			Keyword.fg = palette.syntaxKeyword;
			Conditional.fg = palette.syntaxControl;
			Repeat.fg = palette.syntaxControl;
			Exception.fg = palette.syntaxControl;
			Identifier.fg = palette.syntaxVariable;
			Function.fg = palette.syntaxFunction;
			Type.fg = palette.syntaxType;
			Structure.fg = palette.syntaxType;
			Special.fg = palette.syntaxTag;
			Number.fg = palette.syntaxNumber;
			Boolean.fg = palette.syntaxNumber;
			Float.fg = palette.syntaxNumber;

			# TreeSitter Overrides
			"@variable".fg = palette.syntaxVariable;
			"@function.call".fg = palette.syntaxFunction;
			"@keyword".fg = palette.syntaxKeyword;
			"@keyword.control".fg = palette.syntaxControl;
			"@punctuation.bracket".fg = palette.syntaxPunct;
			"@punctuation.delimiter".fg = palette.syntaxPunct;
			"@operator".fg = palette.syntaxOp;
			"@string".fg = palette.syntaxString;
			"@attribute".fg = palette.syntaxAttribute;
			"@type".fg = palette.syntaxType;
			"@tag".fg = palette.syntaxTag;
		};

		# ── KEYMAPS ───────────────────────────────────────────────────────────────────
		globals.mapleader = " ";
		keymaps = [
			{ mode = "n"; key = "<leader>e"; action = "<cmd>Oil<CR>"; options.desc = "Open Oil file manager"; }
			{ mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; options.desc = "Find files"; }
			{ mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>"; options.desc = "Live grep"; }
			{ mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>"; options.desc = "Buffers"; }
			{ mode = "n"; key = "<C-h>"; action = "<C-w>h"; }
			{ mode = "n"; key = "<C-j>"; action = "<C-w>j"; }
			{ mode = "n"; key = "<C-k>"; action = "<C-w>k"; }
			{ mode = "n"; key = "<C-l>"; action = "<C-w>l"; }
			{ mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move selection down"; }
			{ mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move selection up"; }

			# --- Typst Preview ---
			{
				mode = "n";
				key = "<leader>tp";
				action.__raw = ''
				function()
				local pdf = vim.fn.expand("%:p:r") .. ".pdf"
				os.execute("zathura " .. pdf .. " &")
				end
				'';
				options.desc = "Open Typst PDF Preview in Zathura";
			}
		];

		# ── PLUGINS ───────────────────────────────────────────────────────────────────
		plugins = {
			lualine = {
				enable = true;
				settings = {
					options = {
						theme = "oxocarbon";
						component_separators = { left = ""; right = ""; };
						section_separators = { left = ""; right = ""; };
					};
					sections = {
						lualine_a = [ "mode" ];
						lualine_b = [ "branch" "diff" ];
						lualine_c = [ "filename" ];
						lualine_x = [ "diagnostics" "fileformat" "filetype" ];
						lualine_y = [ "progress" ];
						lualine_z = [ "location" ];
					};
				};
			};
			telescope.enable = true;
			treesitter = {
				enable = true;
				settings.highlight.enable = true;
			};
			oil = {
				enable = true;
				settings.default_file_explorer = true;
			};

			# --- LSP Servers ---
			lsp = {
				enable = true;
				servers = {
					nixd = {
						enable = true;
						settings = {
							nixos.expr = "(builtins.getFlake \"\${workspaceFolder}\").nixosConfigurations.\"${hostName}\".options";
							options.home_manager.expr = "(builtins.getFlake \"\${workspaceFolder}\").nixosConfigurations.\"${hostName}\".options.home-manager.users.type.getSubOptions []";
						};
					};
					lua_ls.enable = true;
					ts_ls.enable = true;
					pyright.enable = true;
					tinymist = {
						enable = true;
						settings = {
							exportPdf = "onSave";
							outputPath = "$dir/$name.pdf";
						};
					};
				};
			};

			# --- Completion ---
			nvim-cmp = {
				enable = true;
				sources = [
					{ name = "nvim_lsp"; }
					{ name = "buffer"; }
					{ name = "path"; }
				];
			};

			# --- Essentials ---
			luasnip.enable = true;
			gitsigns.enable = true;
			comment.enable = true;
			which-key.enable = true;
			indent-blankline.enable = true;
			autopairs.enable = true;
			web-devicons.enable = true;
			flash.enable = true;
			direnv.enable = true;

			# --- UI ---
			noice = {
				enable = true;
				settings = {
					lsp.override = {
						"vim.lsp.util.convert_input_to_markdown_lines" = true;
						"vim.lsp.util.extract_stack_trace" = true;
						"nvim-cmp" = true;
					};
					presets = {
						bottom_search = true;
						command_palette = true;
						long_message_to_split = true;
					};
				};
			};
			notify = {
				enable = true;
				settings = {
					background_colour = palette.background;
					fps = 60;
					render = "compact";
					stages = "fade";
					timeout = 2000;
				};
			};

			# --- Formatting (Auto-fix on Save) ---
			conform-nvim = {
				enable = true;
				settings = {
					format_on_save = {
						lsp_fallback = true;
						timeout_ms = 500;
					};
					formatters_by_ft = {
						nix = [ "alejandra" ];
						lua = [ "stylua" ];
						python = [ "black" ];
					};
				};
			};
		};
		# --- Elastic Tabstops ---
		extraPlugins = [
			(pkgs.vimUtils.buildVimPlugin {
				pname = "elastictabstops.nvim";
				version = "2024-04-09";
				src = pkgs.fetchFromGitHub {
					owner = "lsvmello";
					repo = "elastictabstops.nvim";
					rev = "e305e63821734958ce769741a3182b86e08aba9f"; # Latest stable commit
					hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # DUMMY HASH - replace with actual hash on build failure
				};
			})
		];

		extraConfigLua = ''
		require('elastictabstops').setup({})
		'';
	};
}
