return {
  -- bufferline — VS Code-style open-file tabs with visible close controls
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        buffer_close_icon = "×",
        close_icon = "×",
        separator_style = "thin",
        diagnostics = "nvim_lsp",
        close_command = function(bufnr)
          Snacks.bufdelete(bufnr)
        end,
        right_mouse_command = function(bufnr)
          Snacks.bufdelete(bufnr)
        end,
      })
      opts.highlights = vim.tbl_deep_extend("force", opts.highlights or {}, {
        close_button = { fg = "#56d6c8", bg = "NONE", bold = true },
        close_button_visible = { fg = "#56d6c8", bg = "NONE", bold = true },
        close_button_selected = { fg = "#56d6c8", bg = "NONE", bold = true },
        buffer_selected = { fg = "#e4f2f4", bg = "#18313b", bold = true },
      })
      return opts
    end,
    keys = {
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
      { "<leader>bc", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Other Buffers" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close Buffers to the Left" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close Buffers to the Right" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
  },

  -- lualine — retain LazyVim's statusline and add useful workspace context
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.globalstatus = true
      opts.sections = opts.sections or {}
      opts.sections.lualine_c = opts.sections.lualine_c or {}
      table.insert(opts.sections.lualine_x, {
        function()
          local ok, autosave = pcall(require, "auto-save")
          if not ok then
            return "AUTO SAVE ?"
          end
          return autosave.enabled() and "AUTO SAVE ON" or "AUTO SAVE OFF"
        end,
        color = function()
          local ok, autosave = pcall(require, "auto-save")
          if not ok then
            return { fg = "#8294aa" }
          end
          return autosave.enabled() and { fg = "#a4d66d", gui = "bold" }
            or { fg = "#ff6b6b", gui = "bold" }
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = { "AutoSaveEnable", "AutoSaveDisable" },
        callback = function()
          local ok, lualine = pcall(require, "lualine")
          if ok then
            lualine.refresh()
          end
        end,
      })
      table.insert(opts.sections.lualine_c, {
        function()
          local ok, navic = pcall(require, "nvim-navic")
          if ok and navic.is_available() then
            return navic.get_location()
          end
          return ""
        end,
        cond = function()
          local ok, navic = pcall(require, "nvim-navic")
          return ok and navic.is_available()
        end,
      })
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, {
        function()
          local names = {}
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            table.insert(names, client.name)
          end
          return #names > 0 and "LSP " .. table.concat(names, ",") or ""
        end,
        cond = function()
          return #vim.lsp.get_clients({ bufnr = 0 }) > 0
        end,
      })
      table.insert(opts.sections.lualine_x, {
        function()
          local recording = vim.fn.reg_recording()
          return recording ~= "" and "REC @" .. recording or ""
        end,
        cond = function()
          return vim.fn.reg_recording() ~= ""
        end,
      })
      table.insert(opts.sections.lualine_x, function()
        return os.date("%a %b %d")
      end)
      table.insert(opts.sections.lualine_x, {
        function()
          local command = vim.fn.histget("cmd", -1)
          if command == "" then
            return ""
          end
          command = command:gsub("[%c]", " ")
          return "CMD " .. vim.fn.strcharpart(command, 0, 28)
        end,
        cond = function()
          return vim.fn.histget("cmd", -1) ~= ""
        end,
      })
      return opts
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- Catppuccin remains available as an alternate colorscheme.
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha", -- latte | frappe | macchiato | mocha
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      term_colors = true,
      color_overrides = {
        latte = { blue = "#126a9f", green = "#39734d", teal = "#087f87" },
      },
      dim_inactive = { enabled = true, shade = "dark", percentage = 0.12 },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        keywords = { "italic" },
        functions = { "bold" },
        types = { "bold" },
      },
      custom_highlights = function(c)
        return {
          CursorLineNr = { fg = c.lavender, style = { "bold" } },
          FloatBorder = { fg = c.blue, bg = c.mantle },
          NormalFloat = { bg = c.mantle },
          TelescopeBorder = { fg = c.blue, bg = c.mantle },
          TelescopeSelection = { bg = c.surface0, style = { "bold" } },
          WinSeparator = { fg = c.surface1 },
          LspInlayHint = { fg = c.overlay0, bg = c.base, style = { "italic" } },
          TreesitterContextBottom = { sp = c.surface1, style = { "underline" } },
        }
      end,
      integrations = {
        aerial = true,
        barbecue = { dim_dirname = true, bold_basename = true },
        blink_cmp = true,
        cmp = true,
        diffview = true,
        flash = true,
        gitsigns = true,
        grug_far = true,
        harpoon = true,
        illuminate = { enabled = true, lsp = true },
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        mini = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "NONE" },
        neotree = true,
        noice = true,
        notify = true,
        nvimtree = false,
        octo = true,
        snacks = { enabled = true },
        telescope = { enabled = true },
        treesitter = true,
        treesitter_context = true,
        which_key = true,
        neotest = true,
        dap = true,
        dap_ui = true,
      },
    },
  },

  -- Alternate themes; preview/switch live with <leader>uC
  { "folke/tokyonight.nvim", lazy = true, opts = { style = "night" } },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        cursorline = true,
        transparency = true,
        lualine_transparency = true,
        terminal_colors = true,
        highlight_inactive_windows = true,
      },
      colors = {
        onedark = {
          bg = "#10161d",
          blue = "#65b9ff",
          cyan = "#56d6c8",
          green = "#a4d66d",
        },
        onelight = {
          bg = "#f3f7f8",
          blue = "#126a9f",
          cyan = "#087f87",
          green = "#39734d",
        },
      },
      highlights = {
        Normal = { fg = "#eaf0f6" },
        NormalNC = { fg = "#cfdae6" },
        Comment = { fg = "#a9bbd1", italic = true },
        ["@comment"] = { fg = "#a9bbd1", italic = true },
        Cursor = { fg = "#10161d", bg = "#50fa7b", bold = true },
        lCursor = { fg = "#10161d", bg = "#50fa7b", bold = true },
        TermCursor = { fg = "#10161d", bg = "#50fa7b", bold = true },
        CursorLineNr = { fg = "#8be9fd", bold = true },
        LineNr = { fg = "#8294aa" },
        NormalFloat = { bg = "NONE" },
        FloatBorder = { fg = "#56d6c8", bg = "NONE" },
        Pmenu = { fg = "#dce7ed", bg = "#15212b" },
        PmenuSel = { fg = "#10161d", bg = "#65b9ff", bold = true },
        Visual = { bg = "#214253" },
        CursorLine = { bg = "#141f29" },
      },
      styles = {
        comments = "italic",
        keywords = "italic",
        functions = "bold",
        types = "bold",
      },
    },
  },
  { "projekt0n/github-nvim-theme", name = "github-theme", lazy = true },

  -- Snacks dashboard header
  {
    "folke/snacks.nvim",
    init = function()
      local function open_dashboard_if_empty(buffer)
        if vim.bo[buffer].buftype ~= "" or vim.api.nvim_buf_get_name(buffer) ~= "" then
          return
        end

        local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
        if #lines ~= 1 or lines[1] ~= "" then
          return
        end

        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buffer) or vim.api.nvim_get_current_buf() ~= buffer then
            return
          end
          local current_lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
          if vim.bo[buffer].buftype == "" and vim.api.nvim_buf_get_name(buffer) == ""
            and #current_lines == 1 and current_lines[1] == "" then
            -- Reuse the empty buffer and window instead of a floating dashboard, so `:terminal`
            -- doesn't leave a [No Name] buffer behind and the explorer sidebar doesn't sit under it.
            require("snacks").dashboard.open({ buf = buffer, win = vim.api.nvim_get_current_win() })
          end
        end)
      end

      local group = vim.api.nvim_create_augroup("DashboardOnEmptyBuffer", { clear = true })
      vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function(event)
          open_dashboard_if_empty(event.buf)
        end,
      })
      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        callback = function()
          open_dashboard_if_empty(vim.api.nvim_get_current_buf())
        end,
      })
    end,
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            exclude = { "**/.git" },
          },
        },
      },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
 ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
 ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
      },
    },
  },

  -- VS Code-like scrollbar with git, diagnostic, and search marks
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      handle = { blend = 25 },
      excluded_filetypes = { "neo-tree", "snacks_dashboard", "toggleterm", "lazy", "mason", "noice", "aerial" },
      handlers = { gitsigns = true, search = false },
    },
  },

  -- Tell LazyVim to use catppuccin
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "onedark" },
    keys = {
      { "<leader>uD", "<cmd>colorscheme onedark<cr>", desc = "Dark Transparent Theme" },
      { "<leader>uL", "<cmd>colorscheme catppuccin-latte<cr>", desc = "Light Theme" },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- noice.nvim — VS Code–style command line, messages & notifications popup
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = true },
      },
      presets = {
        bottom_search = true,          -- use a classic bottom cmdline for search
        command_palette = true,        -- position the cmdline and popupmenu together
        long_message_to_split = true,  -- long messages go to a split
        inc_rename = true,             -- enables the inc-rename UI
        lsp_doc_border = true,         -- add a border to hover docs and signature help
      },
      routes = {
        -- suppress common noisy messages
        { filter = { event = "msg_show", find = "%d+L, %d+B" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "; after #%d+" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "; before #%d+" }, opts = { skip = true } },
        { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
      },
    },
    keys = {
      { "<leader>nl", function() require("noice").cmd("last") end,    desc = "Noice: Last Message" },
      { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice: Message History" },
      { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Noice: Dismiss All" },
    },
  },

  -- nvim-notify — better notification popups (noice uses this automatically)
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
      render = "wrapped-compact",
      stages = "fade",
      top_down = false,
    },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- aerial.nvim — VS Code Outline panel: symbols sidebar (functions, classes)
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>",    desc = "Symbol Outline (Aerial)" },
      { "<leader>cS", "<cmd>AerialNavToggle<cr>", desc = "Symbol Nav Float (Aerial)" },
      { "{",          "<cmd>AerialPrev<cr>",       desc = "Prev Symbol" },
      { "}",          "<cmd>AerialNext<cr>",       desc = "Next Symbol" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        max_width = { 40, 0.2 },
        min_width = 20,
        default_direction = "prefer_right",
        placement = "edge",
      },
      attach_mode = "global",
      show_guides = true,
      filter_kind = {
        "Class", "Constructor", "Enum", "Function",
        "Interface", "Module", "Method", "Struct", "Type",
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- barbecue.nvim — VS Code–style breadcrumb bar at the top of each window
  -- Shows: filename > module > Class > method
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      attach_navic = false,  -- LazyVim already attaches navic via lspconfig
      create_autocmd = true,
      include_buftypes = { "" },
      exclude_filetypes = { "netrw", "toggleterm", "aerial", "oil", "lazy", "mason" },
      modifiers = {
        dirname = ":~:.",
        basename = "",
      },
      show_dirname = true,
      show_basename = true,
      show_modified = true,
      modified_sign = "●",
      show_navic = true,
      context_follow_icon_color = false,
      -- theme auto-detected from colorscheme
    },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- incline.nvim — floating filename label on each split (helpful with splits)
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "b0o/incline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      hide = { cursorline = false, focused_win = false, only_win = true },
      highlight = {
        groups = {
          InclineNormal = { guibg = "#313244", guifg = "#cdd6f4" },
          InclineNormalNC = { guibg = "#1e1e2e", guifg = "#6c7086" },
        },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        local modified = vim.bo[props.buf].modified
        local icon, color = require("nvim-web-devicons").get_icon_color(filename)
        return {
          { icon or "",  guifg = color },
          { " " },
          { filename,    gui = modified and "bold,italic" or "bold" },
          { modified and " ●" or "", guifg = "#f38ba8" },
        }
      end,
    },
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- mini.animate — smooth cursor movement, scrolling & window animations
  -- Cursor glides to its destination instead of teleporting
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "nvim-mini/mini.animate",
    version = false,
    event = "VeryLazy",
    opts = function()
      local animate = require("mini.animate")
      -- Exponential ease-out: snappy start, smoothly decelerates into position
      local timing = animate.gen_timing.exponential({ easing = "out", duration = 150, unit = "total" })
      return {
        cursor = {
          enable = true,
          timing = timing,
          -- "walls" path: cursor travels along row first then column (L-shaped),
          -- giving a distinct directional feel instead of a straight diagonal line
          path = animate.gen_path.walls(),
        },
        scroll = { enable = false }, -- disabled: causes scroll jitter
        resize = { enable = false },
        open   = { enable = false },
        close  = { enable = false },
      }
    end,
  },
}
