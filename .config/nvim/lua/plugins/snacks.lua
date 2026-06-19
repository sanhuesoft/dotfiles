return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local is_zk_dir = vim.fn.getcwd():find(vim.fn.expand("~/Mesh"), 1, true) ~= nil

      -- Ajustes generales
      opts.bigfile = { enabled = true }

      -- Solo si es ZK
      if is_zk_dir then
        opts.dashboard = opts.dashboard or {}
        opts.dashboard.preset = opts.dashboard.preset or {}

        vim.api.nvim_set_hl(0, "MiHeaderColor", {
          fg = "#ffffff", -- Cambia este código HEX por el color que tú quieras
          bold = true,
        })

        opts.dashboard.preset.header = ""
          .. "░█████████ ░██     ░██ \n"
          .. "      ░██  ░██    ░██  \n"
          .. "     ░██   ░██   ░██   \n"
          .. "   ░███    ░███████    \n"
          .. "  ░██      ░██   ░██   \n"
          .. " ░██       ░██    ░██  \n"
          .. "░█████████ ░██     ░██ \n"
          .. "                       \n"
          .. "                       "

        opts.dashboard.preset.keys = {
          {
            icon = "󱪝 ",
            key = "N",
            desc = "New Note",
            action = ":ZkNew",
          },
          {
            icon = " ",
            key = "n",
            desc = "Find Note",
            action = ":ZkNotes",
          },
          {
            icon = " ",
            key = "o",
            desc = "Find orphans",
            action = ":ZkOrphans",
          },
          {
            icon = "󱓧 ",
            key = "d",
            desc = "Daily note",
            action = ":ZkNew { title = os.date('%Y-%m-%d'), dir = 'Journal', template = 'journal.md' }",
          },
          {
            icon = "󰓹 ",
            key = "t",
            desc = "Browse Tags",
            action = ":ZkTags",
          },
        }

        opts.dashboard.sections = {
          { section = "header" },
          { section = "keys", padding = 1 },
        }

      -- Ajustes para el resto de directorios
      else
        opts.dashboard.preset.header = "                                                                        \n"
          .. "                                                                        \n"
          .. "                                                                      \n"
          .. "        ████ ██████           █████      ██                     \n"
          .. "      ███████████             █████                            \n"
          .. "       █████████ ███████████████████ ███   ███████████   \n"
          .. "      █████████  ███    █████████████ █████ ██████████████   \n"
          .. "     █████████ ██████████ █████████ █████ █████ ████ █████   \n"
          .. "   ███████████ ███    ███ █████████ █████ █████ ████ █████  \n"
          .. "  ██████  █████████████████████ ████ █████ █████ ████ ██████ \n"
          .. "                                                                        \n"
          .. "                                                                        "
        -- Define aquí solo los botones que tú quieras ver y en el orden que prefieras:
        opts.dashboard.preset.keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
          { icon = " ", key = "c", desc = "Config", action = ":FzfLua files cwd=~/.config/nvim" },
          { icon = " ", key = "s", desc = "Restore Session", action = [[lua require("persistence").load()]] },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        }
        opts.dashboard.sections = {
          { section = "header" },
          { section = "keys", padding = 1 },
          { section = "recent_files", limit = 5, width = 40, padding = 1 },
        }
      end

      -- Crea el comando personalizado :Dash
      vim.api.nvim_create_user_command("Dash", function()
        Snacks.dashboard.open()
      end, {})

      -- CRÍTICO: Retorna las opts en Lazy.nvim
      return opts
    end,
  },
  { "goolord/alpha-nvim", enabled = false },
}
