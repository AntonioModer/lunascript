local compileBody

local function compileExpression(node)
  if node.type == 'name'
  or node.type == 'string'
  or node.type == 'number' then
    return node.value
  elseif node.type == 'binary-expression' then
    return table.concat{ compileExpression(node.left), ' ', node.op, ' ', compileExpression(node.right) }
  elseif node.type == 'unary-expression' then
    return table.concat{ node.op, compileExpression(node.value) }
  end
end

local function compileNameList(namelist)
  local names = {}
  for i, name in ipairs(namelist) do
    table.insert(names, name.value)
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
  return node.type == 'local'
  and table.concat{ 'local ', compileNameList(node.names) }
end

local function compileAssign(node)
  return node.type == 'assign'
  and table.concat{ compileNameList(node.names), ' = ', compileExpressionList(node.values) }
end

local function compileDo(node, level)
  return node.type == 'do'
  and table.concat { 'do\n', compileBody(node.body, level + 1), '\n', string.rep('  ', level), 'end' }
end

local function compileStatement(node, ...)
  return compileDo(node, ...)
  or compileLocal(node)
  or compileAssign(node)
end

function compileBody(body, level)
  local output = {}
  local indent = string.rep('  ', level)
  for i, statement in ipairs(body) do
    table.insert(output, indent .. compileStatement(statement, level))
  end
  return table.concat(output, '\n')
end

local function compile(tree)
  return compileBody(tree.body, 0) .. '\n'
end

return compile
