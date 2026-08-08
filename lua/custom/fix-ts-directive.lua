--- Fix for Neovim 0.12.x compatibility
---
--- In Neovim 0.12, match:captures() returns table<integer, TSNode[]>
--- (each capture ID maps to an array of TSNodes), but nvim-treesitter's
--- query_predicates.lua (master/archived) treats match[id] as a single TSNode.
---
--- This overrides the broken directive to handle both TSNode and TSNode[].
--- See: https://github.com/nvim-treesitter/nvim-treesitter (master archived)

local query = require("vim.treesitter.query")

local non_filetype_match_injection_language_aliases = {
  ex = "elixir",
  pl = "perl",
  sh = "bash",
  uxn = "uxntal",
  ts = "typescript",
}

--- Resolve an injection language alias to a treesitter parser language.
--- Replicates the local function from nvim-treesitter's query_predicates.lua
--- since it's not exported.
---@param injection_alias string
---@return string
local function get_parser_from_markdown_info_string(injection_alias)
  local match = vim.filetype.match { filename = "a." .. injection_alias }
  return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
end

--- Extract a single TSNode from a capture value that may be TSNode[] (Neovim 0.12+)
--- or TSNode (older Neovim).
---@param val any
---@return TSNode|nil
local function extract_node(val)
  if val == nil then
    return nil
  end
  -- Neovim 0.12+: match[id] = TSNode[] (table)
  if type(val) == "table" and type(val[1]) == "userdata" then
    return val[1]
  end
  -- Older Neovim: match[id] = TSNode (userdata)
  if type(val) == "userdata" then
    return val
  end
  return nil
end

-- Override set-lang-from-info-string! directive
-- Original in nvim-treesitter: query_predicates.lua:135-143
query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
  local capture_id = pred[2]
  local node = extract_node(match[capture_id])
  if not node then
    return
  end
  local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
  metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
end, { force = true, all = false })

-- Also fix set-lang-from-mimetype! which has the same pattern
-- Original in nvim-treesitter: query_predicates.lua:114-128
query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
  local capture_id = pred[2]
  local node = extract_node(match[capture_id])
  if not node then
    return
  end
  local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
  local configured = {
    ["importmap"] = "json",
    ["module"] = "javascript",
    ["application/ecmascript"] = "javascript",
    ["text/ecmascript"] = "javascript",
  }
  if configured[type_attr_value] then
    metadata["injection.language"] = configured[type_attr_value]
  else
    local parts = vim.split(type_attr_value, "/", {})
    metadata["injection.language"] = parts[#parts]
  end
end, { force = true, all = false })

-- Fix downcase! directive: same issue
-- Original in nvim-treesitter: query_predicates.lua:155-167
query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
  local id = pred[2]
  local node = extract_node(match[id])
  if not node then
    return
  end
  local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
  if not metadata[id] then
    metadata[id] = {}
  end
  metadata[id].text = string.lower(text)
end, { force = true, all = false })

return { fixed = true }
