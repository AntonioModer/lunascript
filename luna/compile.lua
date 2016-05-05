local function compileStatement(node)
  if node.type == 'local' then
    local output = {}
    table.insert(output, 'local ')
    table.insert(output, table.concat(node.namelist, ', '))
    return table.concat(output)
  elseif node.type == 'assign' then
    local output = {}
    table.insert(output, table.concat(node.namelist, ', '))
    table.insert(output, ' = ')
    table.insert(output, table.concat(node.explist, ', '))
    return table.concat(output)
  end
end

local function compileBlock(node, level)
  local output = {}
  if node.type == 'block' then
    for i, statement in ipairs(node.body) do
      table.insert(output, compileStatement(statement))
    end
  end

  local indent = string.rep('  ', level)
  return table.concat(output, '\n') .. '\n'
end

local function compile(tree)
  return compileBlock(tree, 0)
end

return compile
