return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          {
            "K",
            function()
              if vim.bo.filetype == "markdown" then
                local line = vim.api.nvim_get_current_line()
                local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-based index
                local start_idx = 1
                local target_citekey = nil

                while true do
                  local s, e, full = string.find(line, "{{([%w%-_.:]+)}}", start_idx)
                  if not s then
                    break
                  end
                  if col >= s and col <= e then
                    target_citekey = full:match("^([^:]+)")
                    break
                  end
                  start_idx = e + 1
                end

                if target_citekey then
                  local bib_paths = {
                    "/Users/fabsanh/Mesh/Bibliografía/" .. target_citekey .. ".md",
                    "/Users/fabsanh/Mesh/Bibliografía/" .. target_citekey .. ".md",
                  }

                  local bib_path = nil
                  for _, path in ipairs(bib_paths) do
                    if vim.fn.filereadable(path) == 1 then
                      bib_path = path
                      break
                    end
                  end

                  if bib_path then
                    local f = io.open(bib_path, "r")
                    if f then
                      local title, author, year
                      local in_frontmatter = false
                      local current_key = nil
                      for _ = 1, 20 do
                        local file_line = f:read("*line")
                        if not file_line then
                          break
                        end
                        if file_line == "---" then
                          in_frontmatter = not in_frontmatter
                        elseif in_frontmatter then
                          local k, v = file_line:match("^([%w%-_]+):%s*(.-)%s*$")
                          if k and v then
                            current_key = k
                            v = v:gsub("^[\"'](.-)[\"']$", "%1")
                            if k == "title" then
                              title = v
                            elseif k == "author" or k == "authors" then
                              author = v
                            elseif k == "year" or k == "date" then
                              year = v
                            end
                          elseif current_key then
                            local list_item = file_line:match("^%s*-%s*(.-)%s*$")
                            if list_item then
                              list_item = list_item:gsub("^[\"'](.-)[\"']$", "%1")
                              if current_key == "author" or current_key == "authors" then
                                if not author or author == "" then
                                  author = list_item
                                else
                                  author = author .. ", " .. list_item
                                end
                              elseif current_key == "title" then
                                if not title or title == "" then
                                  title = list_item
                                else
                                  title = title .. " " .. list_item
                                end
                              end
                            end
                          end
                        end
                      end
                      f:close()

                      if (title and title ~= "") or (author and author ~= "") or (year and year ~= "") then
                        -- Función local para dividir el texto a un ancho máximo determinado
                        local function wrap_text(text, max_width)
                          local lines = {}
                          local current_line = ""
                          for word in text:gmatch("%S+") do
                            if #current_line + #word + 1 > max_width then
                              table.insert(lines, current_line)
                              current_line = word
                            else
                              if current_line == "" then
                                current_line = word
                              else
                                current_line = current_line .. " " .. word
                              end
                            end
                          end
                          if current_line ~= "" then
                            table.insert(lines, current_line)
                          end
                          return lines
                        end

                        local lines = {}
                        local max_width = 50
                        if title and title ~= "" then
                          local title_lines = wrap_text(title, max_width - 8) -- prefix is 8 columns
                          if #title_lines > 0 then
                            table.insert(lines, "Título: " .. title_lines[1])
                            for i = 2, #title_lines do
                              table.insert(lines, "        " .. title_lines[i])
                            end
                          end
                        end
                        if author and author ~= "" then
                          local author_lines = wrap_text(author, max_width - 8) -- prefix is 8 columns
                          if #author_lines > 0 then
                            table.insert(lines, "Autor:  " .. author_lines[1])
                            for i = 2, #author_lines do
                              table.insert(lines, "        " .. author_lines[i])
                            end
                          end
                        end
                        if year and year ~= "" then
                          table.insert(lines, "Año:    " .. year)
                        end
                        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
                          title = "Bibliografía (" .. target_citekey .. ")",
                        })
                        return
                      end
                    end
                  end
                  vim.notify("La referencia '" .. target_citekey .. "' no existe en Bibliografía.", vim.log.levels.WARN)
                  return
                end
              end

              -- Fallback a LSP hover normal
              vim.lsp.buf.hover()
            end,
            desc = "Hover or Citation details",
          },
        },
      },
    },
  },
}
