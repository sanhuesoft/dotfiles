return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<C-e>", "<cmd>Neotree filesystem reveal left<cr>", desc = "Neotree reveal in explorer" },
  },
  -- Usamos 'config' en lugar de 'opts' para ASEGURARNOS de pisar todo lo demás
  config = function()
    require("neo-tree").setup({
      popup_border_style = "single", -- Borde doble en ventanas emergentes
      window = {
        width = 30,
      },
      enable_git_status = true,
      refresh_notifiers = {
        git_status = true,
      },
      filesystem = {
        use_libuv_file_watcher = true,
        -- preview_border_style = "double", -- Borde doble en preview

        commands = {
          delete = function(state)
            local node = state.tree:get_node()
            local name = node.name
            if #name > 25 then
              name = string.sub(name, 1, 22) .. "..."
            end

            local fs_actions = require("neo-tree.sources.filesystem.lib.fs_actions")
            local NuiInput = require("nui.input")
            local popups = require("neo-tree.ui.popups")

            local popup_options = popups.popup_options("Delete '" .. name .. "'?", 40, {
              size = { width = 40 },
              border = {
                style = "double", -- Borde doble en confirmación de borrado
              },
            })

            local input = NuiInput(popup_options, {
              prompt = " y/n: ",
              default_value = "y",
              on_submit = function(value)
                if value == "y" or value == "Y" then
                  local utils = require("neo-tree.utils")
                  local refresh = function()
                    require("neo-tree.sources.filesystem")._navigate_internal(state, nil, nil, nil, false)
                  end
                  fs_actions.delete_node(node.path, utils.wrap(refresh, state), true)
                end
              end,
            })

            input:mount()
            input:map("i", "<esc>", function()
              input:unmount()
            end, { noremap = true })
            input:map("n", "<esc>", function()
              input:unmount()
            end, { noremap = true })
            input:map("n", "q", function()
              input:unmount()
            end, { noremap = true })
          end,
        },
      },
    })
  end,
}
