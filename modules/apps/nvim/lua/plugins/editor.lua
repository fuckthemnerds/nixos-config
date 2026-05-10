return {
  {
    "telescope-nvim",
    cmd = "Telescope",
    keys = { "<leader>ff", "<leader>fg", "<leader>fb" },
    load = function(name)
      vim.cmd.packadd("telescope-fzf-native-nvim")
      vim.cmd.packadd(name)
    end,
    after = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  {
    "oil-nvim",
    cmd = "Oil",
    keys = { "<leader>e" },
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      require("oil").setup({
        default_file_explorer = true,
        view_options = { show_hidden = true },
        keymaps = {
          ["<C-c>"] = "actions.close",
          ["q"]     = "actions.close",
        },
      })
    end,
  },

  {
    "flash-nvim",
    event = { "BufReadPre", "BufNewFile" },
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      require("flash").setup({})
      -- s/S for jump
      vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end,   { desc = "Flash jump" })
      vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash treesitter" })
    end,
  },

  {
    "nvim-autopairs",
    event = "InsertEnter",
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      require("nvim-autopairs").setup({ check_ts = true })
      local ok_cmp, cmp = pcall(require, "cmp")
      local ok_ap,  ap  = pcall(require, "nvim-autopairs.completion.cmp")
      if ok_cmp and ok_ap then
        cmp.event:on("confirm_done", ap.on_confirm_done())
      end
    end,
  },

  {
    "gitsigns-nvim",
    event = { "BufReadPre", "BufNewFile" },
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end
          map("n", "]h", gs.next_hunk,         "Next hunk")
          map("n", "[h", gs.prev_hunk,          "Prev hunk")
          map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
          map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
          map("n", "<leader>hd", gs.diffthis,   "Diff this")
        end,
      })
    end,
  },

  {
    "comment-nvim",
    event = { "BufReadPre", "BufNewFile" },
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      require("Comment").setup()
    end,
  },

  {
    "which-key-nvim",
    event = "VeryLazy",
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      require("which-key").setup({
        plugins = { spelling = { enabled = true } },
      })
      require("which-key").add({
        { "<leader>h", group = "Git hunks" },
        { "<leader>f", group = "Find (telescope)" },
        { "<leader>t", group = "Typst" },
      })
    end,
  },

  {
    "conform-nvim",
    event = "BufWritePre",
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      require("conform").setup({
        format_on_save = {
          lsp_fallback = true,
          timeout_ms   = 500,
        },
        formatters_by_ft = {
          nix    = { "alejandra" },
          lua    = { "stylua" },
          python = { "black" },
        },
      })
    end,
  },

  {
    "direnv-vim",
    event = "VeryLazy",
    load = function(name) vim.cmd.packadd(name) end,
    after = function() end,
  },
}
