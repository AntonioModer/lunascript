local function compileExpression(node)
  if node.type == 'binary-expression' then
    return table.concat({ node.left, node.op, node.right }, ' ')
  else
    return node
  end
end

local function compileNameList(namelist)
  local names = {}
  for i, name in ipairs(namelist) do
    table.insert(names, name)
  end
  return table.concat(names, ', ')
end

local function compileExpressionList(explist)
  local values = {}
  for i, node in ipairs(explist) do
    table.insert(values, compileExpression(node))
  end
  return table.concat(values, ', ')
end

local function compileLocal(node)
  if node.type == 'local' then
    return table.concat { 'local ', compileNameList(node.namelist) }
  end
end

local function compileAssign(node)
  if node.type == 'assign' then
    return table.concat {
      compileNameList(node.namelist), ' = ', compileExpressionList(node.explist)
    }
  end
end

local function compileStatement(node)
  return compileLocal(node) or compileAssign(node)
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
