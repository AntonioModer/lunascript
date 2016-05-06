local function transformExpression(exp)
  if exp.type == 'binary-expression' then
    return exp
  else
    return exp
  end
end

local function transformNameList(namelist)
  return namelist
end

local function transformExpressionList(explist)
  local values = {}
  for i, exp in ipairs(explist) do
    table.insert(values, transformExpression(exp))
  end
  return values
end

local function transformAssign(node, scope)
  if node.type == 'assign' then
    local names = transformNameList(node.namelist)
    local values = transformExpressionList(node.explist)
    return { type = 'assign', namelist = names, explist = values }
  elseif node.type == 'let-assign' then
    local names = transformNameList(node.namelist)
    local values = transformExpressionList(node.explist)

    for i, name in ipairs(names) do
      scope[name] = true
    end

    return { type = 'assign', namelist = names, explist = values }
  end
end

local function transformStatement(node, scope)
  return transformAssign(node, scope)
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
      table.insert(output.body, 1, { type = 'local', namelist = locals })
    end

    return output
  end
end

local function transform(ast)
  return transformBlock(ast)
end

return transform