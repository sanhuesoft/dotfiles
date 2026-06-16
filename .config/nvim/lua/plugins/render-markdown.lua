return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    heading = {
      enabled = true,
      -- Habilita los signos a la izquierda
      sign = true,
      -- Reemplaza los '#' por tus iconos de Nerd Fonts favoritos para cada nivel (del 1 al 6)
      icons = { "󰬺 ", "󰬻 ", "󰬼 ", "󰬽 ", "󰬾 ", "󰬿 " },
      -- Evita el espaciado al comienzo de los niveles
      position = "inline",
      -- Clears all heading background highlights
      backgrounds = {},
    },
    link = {
      wiki = {
        icon = "󰈔 ",
        highlight = "Normal",
      },
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    local hl = vim.api.nvim_set_hl

    -- Configuramos solo los colores del texto (foreground) para los encabezados
    hl(0, "RenderMarkdownH1", { fg = "#ffb454", bold = true }) -- Letras amarillas
    hl(0, "RenderMarkdownH2", { fg = "#f07178", bold = true }) -- Letras coral
    hl(0, "RenderMarkdownH3", { fg = "#39bae6" })              -- Letras celestes
    hl(0, "RenderMarkdownH4", { fg = "#ffcc66" })              -- Letras naranja claro

    -- Vinculamos los grupos de Tree-sitter y markdown estándar para colorear también el texto del encabezado
    hl(0, "@markup.heading.1.markdown", { link = "RenderMarkdownH1" })
    hl(0, "@markup.heading.2.markdown", { link = "RenderMarkdownH2" })
    hl(0, "@markup.heading.3.markdown", { link = "RenderMarkdownH3" })
    hl(0, "@markup.heading.4.markdown", { link = "RenderMarkdownH4" })

    hl(0, "markdownH1", { link = "RenderMarkdownH1" })
    hl(0, "markdownH2", { link = "RenderMarkdownH2" })
    hl(0, "markdownH3", { link = "RenderMarkdownH3" })
    hl(0, "markdownH4", { link = "RenderMarkdownH4" })
  end,
}
