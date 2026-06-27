return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Ajustes generales
      opts.bigfile = { enabled = true }
      opts.indent = { enabled = false }
      opts.notifier = { width = { min = 40, max = 60 } }
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
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
        { icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
        { icon = " ", key = "c", desc = "Config", action = ":FzfLua files cwd=~/.config/nvim" },
        { icon = " ", key = "s", desc = "Restore Session", action = [[lua require("persistence").load()]] },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
        { icon = "", key = "z", desc = "Zettelkasten", action = ":cd ~/Mesh" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      }
      opts.dashboard.sections = {
        { section = "header" },
        { section = "keys", padding = 1 },
        { section = "recent_files", limit = 5, width = 40, padding = 1 },
      }

      -- CRÍTICO: Retorna las opts en Lazy.nvim
      return opts
    end,
  },
}
