local source = {}

-- Blink exige estrictamente este constructor para instanciar la fuente
function source.new(opts, config)
  local self = setmetatable({}, { __index = source })
  return self
end

-- Define los caracteres que despiertan a la fuente
function source:get_trigger_characters()
  return { "{", ":" }
end

-- Función principal que procesa el autocompletado
function source:get_completions(context, callback)
  local line = context.line
  local col = context.cursor[2] -- Columna basada en 0
  local before_cursor = string.sub(line, 1, col)

  -- Identificar el método de entrada escrito por el usuario
  local match_start_brackets, match_end_brackets = string.find(before_cursor, "{{[^}]*$")
  local match_start_keyword, match_end_keyword = string.find(before_cursor, "bib:[^%s]*$")

  if not match_start_brackets and not match_start_keyword then
    callback({ items = {} })
    return
  end

  local bib_path = "/Users/fabsanh/Mesh/Bibliografía"
  local items = {}

  local loop = vim.uv or vim.loop
  local handle = loop.fs_scandir(bib_path)

  if handle then
    -- Analizar si a la derecha del cursor existen llaves de cierre automáticas
    local after_cursor = string.sub(line, col + 1)
    local has_closing_brackets = string.match(after_cursor, "^}}") ~= nil

    while true do
      local name, type = loop.fs_scandir_next(handle)
      if not name then
        break
      end

      if (type == "file" or type == "link") and name:match("%.md$") then
        local citekey = name:gsub("%.md$", "")

        local final_text = "{{" .. citekey .. "}}"
        local start_col
        local end_col

        if match_start_brackets then
          start_col = match_start_brackets - 1
          if has_closing_brackets then
            end_col = col + 2
          else
            end_col = col
          end
        else -- match_start_keyword
          start_col = match_start_keyword - 1
          end_col = col
        end

        table.insert(items, {
          label = citekey,
          textEdit = {
            range = {
              start = { line = context.cursor[1] - 1, character = start_col },
              ["end"] = { line = context.cursor[1] - 1, character = end_col },
            },
            newText = final_text,
          },
          kind = 16, -- Equivale a 'Reference' en el protocolo LSP estándar
          label_details = {
            description = "Referencia insertada",
          },
        })
      end
    end
  end

  -- Retornamos la lista de items encontrados al callback de Blink
  callback({ items = items })
end

return source
