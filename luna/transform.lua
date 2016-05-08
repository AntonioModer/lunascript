local transformExpression

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
  if node.type == 'literal-string' then
    local result
    for i, contentNode in ipairs(node.content) do
      local contentValue
      if contentNode.type == 'string-content' then
        contentValue = { type = 'literal', value = node.head .. contentNode.value .. node.tail }
      else
        contentValue = transformExpression(contentNode)
      end
      result = result and { type = 'binary-expression', left = result, op = '..', right = contentValue } or contentValue
    end
    return result
  end
end

local function transformLiteral(node)
  return (node.type == 'literal-name' or node.type == 'literal-number')
  and { type = 'literal', value = node.value }
end

function transformExpression(exp)
  return transformUnaryExpression(exp)
  or transformBinaryExpression(exp)
  or transformString(exp)
  or transformLiteral(exp)
end

local function transformVarList(names)
  return names
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
    vars = transformVarList(node.vars),
    values = transformExpressionList(node.values),
  }
end

local function transformLetAssign(node, scope)
  if node.type == 'let-assign' then
    local varlist = transformVarList(node.vars)
    local values = transformExpressionList(node.values)
    for i, var in ipairs(varlist) do
      if var.type == 'literal-name' then
        scope[var.value] = true
      end
    end
    return { type = 'assign', vars = varlist, values = values }
  end
end

local function transformStatement(node, scope)
  return transformLetAssign(node, scope) or transformAssign(node, scope)
end

local function transformBlock(node)
  if node.type == 'block' then
    local output = { type = 'block', body = {} }
    local scope = {}

    for i, statement in ipairs(node.body) do
      table.insert(output.body, transformStatement(statement, scope))
    end

    local locals = {}
    for name in pairs(scope) do
      table.insert(locals, name)
    end
    if #locals > 0 then
      table.sort(locals)
      table.insert(output.body, 1, { type = 'local', names = locals })
    end

    return output
  end
end

local function transform(ast)
  return transformBlock(ast)
end

return transform
