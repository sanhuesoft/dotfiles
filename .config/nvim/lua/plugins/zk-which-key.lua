return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    local spec = opts.spec or {}
    table.insert(spec, {
      -- GRUPO: Zettelkasten
      { "<leader>z", group = "zettelkasten", icon = " " },
      -- Zk New Bibnote
      {
        "<leader>zB",
        function()
          local title = vim.fn.input("Bibnote Title (AuthorYear): ")
          if title ~= "" then
            require("zk").new({ group = "bibliography", dir = "Bibliografía", title = title, extension = "md" })
          end
        end,
        desc = "New Bibnote",
        icon = "󱚖 ",
      },
      -- Zk New Note
      {
        "<leader>zN",
        function()
          local title = vim.fn.input("Note Title: ")
          if title ~= "" then
            require("zk").new({ title = title })
          end
        end,
        desc = "New Note",
        icon = "󱈀 ",
      },
      -- Zk Today's Daily Note
      {
        "<leader>zd",
        function()
          local vault_path = "/Users/fabsanh/Mesh"
          local date_str = os.date("%Y%m%d")
          local daily_note_path = vault_path .. "/Journal/" .. date_str .. ".md"

          if vim.fn.filereadable(daily_note_path) == 1 then
            -- Si ya existe, lo abrimos directamente
            vim.cmd("edit " .. vim.fn.fnameescape(daily_note_path))
            vim.notify("Abriendo nota diaria existente", vim.log.levels.INFO)
          else
            -- Si no existe, dejamos que zk lo cree usando el grupo y plantilla del config.toml
            require("zk").new({
              group = "journal",
              title = os.date("%Y%m%d"),
            })
          end
        end,
        desc = "Today's Daily Note",
        icon = "󱈀 ",
      },
      -- Zk New Daily Note
      {
        "<leader>zD",
        function()
          local title = vim.fn.input("Date (yyyymmdd): ")
          if title ~= "" then
            require("zk").new({
              group = "journal",
              title = title,
            })
          end
        end,
        desc = "New Daily Note",
        icon = "󱈀 ",
      },
      -- Zk Search Notes
      {
        "<leader>zs",
        function()
          local search = vim.fn.input("Search: ")
          if search ~= "" then
            require("zk").edit({ match = { search } })
          end
        end,
        desc = "Search Notes",
        icon = "󰍉 ",
      },
      -- Zk Match Selection
      {
        "<leader>zs",
        ":'<,'>ZkMatch<CR>",
        mode = "v",
        desc = "Match Selection",
        icon = "󰍉 ",
      },
      -- Zk Find by Tag
      {
        "<leader>zf",
        function()
          local tag = vim.fn.input("Tag: ")
          if tag ~= "" then
            require("zk").edit({ tags = { tag } })
          end
        end,
        desc = "Find by Tag",
        icon = "󱤈 ",
      },
      -- Zk Orphans
      {
        "<leader>zo",
        "<Cmd>ZkOrphans<CR>",
        desc = "Find Orphans",
        icon = " ",
      },
      -- Zk Browse Notes
      {
        "<leader>zn",
        "<Cmd>ZkNotes<CR>",
        desc = "Browse Notes",
        icon = "󱁵 ",
      },
      -- Zk Browse Tags
      {
        "<leader>zt",
        "<Cmd>ZkTags<CR>",
        desc = "Browse Tags",
        icon = "󱤈 ",
      },
      -- Zk Insert Link
      {
        "<leader>zi",
        "<Cmd>ZkInsertLink { sort = { 'modified' } }<CR>",
        desc = "Insert Link",
        icon = "󰌷 ",
      },
      -- Zk Index
      {
        "<leader>zI",
        "<Cmd>ZkIndex<CR>",
        desc = "Update Index",
        icon = "󰙅 ",
      },
    })

    opts.spec = spec
  end,
}
