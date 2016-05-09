local transformExpression
local transformBlock

local function transformUnaryExpression(exp)
  return exp.type == 'unary-expression'
  and { type = 'unary-expression', op = exp.op, value = transformExpression(exp.value) }
end

local function transformBinaryExpression(exp)
  return exp.type == 'binary-expression' and {
    type = 'binary-expression',
    left = transformExpression(exp.left),
    op = exp.op,
    right = transformExpression(exp.right),
  }
end

local function transformString(node)
  if node.type == 'string' then
    local result
    for i, contentNode in ipairs(node.content) do
      local contentValue
      if contentNode.type == 'string-content' then
        contentValue = { type = 'string', value = node.head .. contentNode.value .. node.tail }
      else
        contentValue = transformExpression(contentNode)
      end
      result = result and { type = 'binary-expression', left = result, op = '..', right = contentValue } or contentValue
    end
    return result
  end
end

local function transformLiteral(node)
  return (node.type == 'name' or node.type == 'number')
  and { type = node.type, value = node.value }
end

function transformExpression(exp)
  return transformUnaryExpression(exp)
  or transformBinaryExpression(exp)
  or transformString(exp)
  or transformLiteral(exp)
end

local function transformNameList(names)
  local result = {}
  for i, var in ipairs(names) do
    table.insert(result, transformLiteral(var))
  end
  return result
end

local function transformExpressionList(explist)
  local result = {}
  for i, exp in ipairs(explist) do
    table.insert(result, transformExpression(exp))
  end
  return result
end

local function transformAssign(node)
  return node.type == 'assign' and {
    type = 'assign',
    names = transformNameList(node.names),
    values = transformExpressionList(node.values),
  }
end

local function transformLetAssign(node, scope)
  if node.type == 'let-assign' then
    local names = transformNameList(node.names)
    local values = transformExpressionList(node.values)
    for i, name in ipairs(names) do
      if name.type == 'name' then
        scope[name.value] = name
      end
    end
    return { type = 'assign', names = names, values = values }
  end
end

local function transformStatement(node, scope)
  return transformBlock(node, scope) or transformLetAssign(node, scope) or transformAssign(node)
end

function transformBlock(node)
  if node.type == 'block' then
    local output = { type = 'block', body = {} }
    local scope = {}

    for i, statement in ipairs(node.body) do
      table.insert(output.body, transformStatement(statement, scope))
    end

    local locals = {}
    for name, nameNode in pairs(scope) do
      table.insert(locals, nameNode)
    end
    if #locals > 0 then
      table.sort(locals, function(a, b) return a.value < b.value end)
      table.insert(output.body, 1, { type = 'local', names = locals })
    end

    return output
  end
end

local function transform(ast)
  return transformBlock(ast)
end

return transform
