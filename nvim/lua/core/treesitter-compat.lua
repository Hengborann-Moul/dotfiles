-- Compatibility shim for nvim-treesitter on Neovim 0.12+
--
-- In Neovim 0.12, Query:iter_matches() always returns a list of nodes per
-- capture (the `all` option was removed). nvim-treesitter's master branch
-- predicates/directives expect single nodes.
--
-- This module wraps add_predicate/add_directive so that any handler
-- registered *after* this shim runs receives a normalized match table where
-- each capture ID maps to a single node (the last one), matching the old
-- `all = false` behaviour.

local query = require('vim.treesitter.query')

local orig_add_predicate = query.add_predicate
local orig_add_directive = query.add_directive

--- Unwrap a list of nodes to the last node (old `all = false` behaviour).
--- Non-list values are returned unchanged.
local function last_node(nodes)
  if type(nodes) == 'table' and vim.islist(nodes) and #nodes > 0 then
    return nodes[#nodes]
  end
  return nodes
end

--- Create a proxy match table where integer keys (capture IDs) are unwrapped.
local function normalize_match(match)
  local normalized = {}
  for k, v in pairs(match) do
    if type(k) == 'number' then
      normalized[k] = last_node(v)
    else
      normalized[k] = v
    end
  end
  return normalized
end

query.add_predicate = function(name, handler, opts)
  local wrapped = function(match, pattern, bufnr, pred, metadata)
    return handler(normalize_match(match), pattern, bufnr, pred, metadata)
  end
  orig_add_predicate(name, wrapped, opts)
end

query.add_directive = function(name, handler, opts)
  local wrapped = function(match, pattern, bufnr, pred, metadata)
    handler(normalize_match(match), pattern, bufnr, pred, metadata)
  end
  orig_add_directive(name, wrapped, opts)
end
