return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- 1. Corrección del find: expand necesita ser exacto o usar coincidencia de patrones.
      -- Si solo quieres saber si el directorio actual contiene "Mesh", eliminamos el '*' y el true del final.
      local is_zk_dir = vim.fn.getcwd():find(vim.fn.expand("~/Mesh"), 1, true)
        ~= nil

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
          { icon = "󱪝 ", key = "N", desc = "New Note", action = ":ZkNew" },
          { icon = " ", key = "n", desc = "Find Note", action = ":ZkNotes" },
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
      end
      -- Define aquí solo los botones que tú quieras ver y en el orden que prefieras:
      opts.dashboard.preset.keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":LazyFiles" },
        {
          icon = " ",
          key = "n",
          desc = "New File",
          action = ":ene | startinsert",
        },
        { icon = " ", key = "g", desc = "Find Text", action = ":LiveGrep" },
        {
          icon = " ",
          key = "r",
          desc = "Recent Files",
          action = ":RecentFiles",
        },
        { icon = " ", key = "c", desc = "Config", action = ":LazyConfig" },
        {
          icon = " ",
          key = "s",
          desc = "Restore Session",
          action = [[lua require("persistence").load()]],
        },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      }
      opts.dashboard.sections = {
        { section = "header" },
        { section = "keys", padding = 1 },
        { section = "recent_files", limit = 5, width = 40, padding = 1 },
      }
      -- AQUÍ CREAMOS EL ALIAS: Crea el comando personalizado :Dash
      vim.api.nvim_create_user_command("Dash", function()
        Snacks.dashboard.open()
      end, {})

      -- 3. CRÍTICO: Siempre debes retornar las opts en Lazy.nvim
      return opts
    end,
  },
  { "goolord/alpha-nvim", enabled = false },
}
