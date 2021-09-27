local cmp = require("cmp")
-- Unfortunately the Eclim completion result doesn't support many item kinds
local kinds_mapping = {
  v = cmp.lsp.CompletionItemKind.Variable,
  f = cmp.lsp.CompletionItemKind.Method,
  t = cmp.lsp.CompletionItemKind.Class,
  k = cmp.lsp.CompletionItemKind.Keyword
}
local source = {}

source.new = function()
  return setmetatable({}, { __index = source })
end

function source:is_available()
  return vim.fn['eclim#PingEclim'](0) ~= 0
end

function source:get_debug_name()
  return 'eclim'
end

function source:get_trigger_characters(_)
  -- TODO: no clue how this works atm..
  -- I thought completion would only trigger after a dot if I do this?
  return { '.' }
end

function source:get_keyword_pattern(_)
  return [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w\{2,}\%(-\w*\)*\)]]
end

function source:complete(params, callback)
  local offset = vim.fn['eclim#java#complete#CodeComplete'](1, '') + 1
  local input = string.sub(params.context.cursor_before_line, offset)

  -- TODO: ugly workaround to make eclim use the right column offset when retrieving completions
  -- ( col('.') behaves differently between 2 CodeComplete calls for some reason when using <C-x><C-u>)
  -- Set cursor to the column where completion starts
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_win_set_cursor(0, {row, col - string.len(input)})
  local results = vim.fn['eclim#java#complete#CodeComplete'](0, input)
  -- Restore original cursor location
  vim.api.nvim_win_set_cursor(0, {row, col})

  local items = {}
  -- TODO: CodeComplete returns -1 when completing imports
  if type(results) == "table" then
    for _, item in ipairs(results) do
      table.insert(items, {
        label = item.word,
        dup = item.dup,
        insertText = item.word,
        kind = kinds_mapping[item.kind],
        labelDetails = {
          description = item.menu,
        },
        documentation = item.info,
      })
    end
  end

  callback({
    items = items,
    isIncomplete = true
  })
end

return source
