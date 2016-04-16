local insert = table.insert
local concat = table.concat
local format = string.format

local function getIndent(level)
  return string.rep('   ', level)
end

local function dump(node, indent)
  local buffer = {}
  indent = indent or 0
  insert(buffer, format('%s%s:\n', getIndent(indent), node.type))
  for i=1, #node do
    if type(node[i]) == 'table' then
      insert(buffer, dump(node[i], indent + 1))
    else
      insert(buffer, format('%s%s\n', getIndent(indent + 1), tostring(node[i])))
    end
  end
  return concat(buffer)
end

return dump
