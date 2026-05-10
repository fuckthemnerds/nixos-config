return {
  {
    "lualine-nvim",
    event = "VeryLazy",
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      local p = vim.g.stylix_palette or {}
      require("lualine").setup({
        options = {
          theme = {
            normal = {
              a = { fg = p.base00 or "#161616", bg = p.base0D or "#4589ff", gui = "bold" },
              b = { fg = p.base05 or "#f4f4f4", bg = p.base02 or "#393939" },
              c = { fg = p.base04 or "#6f6f6f", bg = p.base01 or "#262626" },
            },
            insert  = { a = { fg = p.base00 or "#161616", bg = p.base0B or "#42be65", gui = "bold" } },
            visual  = { a = { fg = p.base00 or "#161616", bg = p.base0E or "#be95ff", gui = "bold" } },
            replace = { a = { fg = p.base00 or "#161616", bg = p.base08 or "#fa4d56", gui = "bold" } },
            command = { a = { fg = p.base00 or "#161616", bg = p.base0A or "#f1c21b", gui = "bold" } },
            inactive = {
              a = { fg = p.base03 or "#525252", bg = p.base01 or "#262626" },
              b = { fg = p.base03 or "#525252", bg = p.base01 or "#262626" },
              c = { fg = p.base03 or "#525252", bg = p.base01 or "#262626" },
            },
          },
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "diagnostics", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  {
    "nvim-notify",
    event = "VeryLazy",
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      local p = vim.g.stylix_palette or {}
      local notify = require("notify")
      notify.setup({
        fps = 60,
        render = "compact",
        stages = "fade",
        timeout = 2000,
        background_colour = p.base00 or "#161616",
      })
      vim.notify = notify
    end,
  },

  {
    "noice.nvim",
    event = "VeryLazy",
    load = function(name)
      vim.cmd.packadd("nui-nvim")
      vim.cmd.packadd(name)
    end,
    after = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search     = true,
          command_palette   = true,
          long_message_to_split = true,
        },
      })
    end,
  },

  {
    "indent-blankline-nvim",
    event = { "BufReadPre", "BufNewFile" },
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      local p = vim.g.stylix_palette or {}
      require("ibl").setup({
        indent = { char = "│" },
        scope  = { enabled = true },
      })
      vim.api.nvim_set_hl(0, "IblIndent", { fg = p.base02 or "#393939" })
      vim.api.nvim_set_hl(0, "IblScope",  { fg = p.base03 or "#525252" })
    end,
  },

  {
    "nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    load = function(name) vim.cmd.packadd(name) end,
    after = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },
}
