local insert = table.insert
local concat = table.concat
local format = string.format

return function(tree)
  local translated = {}

  local varid = 0

  local translateExpression
  local translateBlock
  local translateCondition
  local translateAssign
  local translateLiteral
  local localizeScope

  function translateExpression(node, block)
    return translateBlock(node, block)
    or translateCondition(node, block)
    or translateAssign(node, block)
    or translateLiteral(node, block)
  end

  function translateBlock(node, parent)
    if node.type == 'block' then
      local block = { type = 'block' }

      for i, sub in ipairs(node) do
        if translateExpression(sub, block) then end
      end

      localizeScope(block)

      insert(parent, block)
      return block
    end
  end

  function translateCondition(expression, block)
    if expression.type == 'if-expression' then
      local statement = { type = 'if-statement' }


      for i, clause in ipairs(expression) do
        if clause.type == 'if-clause' then
          local translated = { type = 'if-clause' }
          local condition, clauseBlock = unpack(clause)

          local conditionExpression = translateExpression(condition, block)
          insert(translated, conditionExpression)
          translateBlock(clauseBlock, translated)
          insert(statement, translated)

        elseif clause.type == 'elseif-clause' then
          local nestedClause = { type = 'if-clause', unpack(clause) }
          local nestedExpression = { type = 'if-expression', nestedClause, unpack(expression, 3) }
          local nestedBlock = { type = 'block' }

          translateExpression(nestedExpression, nestedBlock)
          localizeScope(nestedBlock)

          local elseClause = { type = 'else-clause', nestedBlock }
          insert(statement, elseClause)

          break

        elseif clause.type == 'else-clause' then
          local translated = { type = 'else-clause' }
          local clauseBlock = clause[1]
          translateBlock(clauseBlock, translated)
          insert(statement, translated)
        end
      end

      insert(block, statement)
      return statement
    end
  end

  function translateAssign(node, block)
    if node.type == 'assign-expression' then
      local left, op, right = unpack(node)

      if translateAssign(right, block) then
        right = right[1]
      end

      local assign = { type = 'assign-statement', left, right }
      insert(block, assign)
      return left
    end
  end

  function translateLiteral(node, block)
    if node.type == 'name'
    or node.type == 'constant' then
      local assign = { type = 'assign-expression', { type = 'name', '_exp' .. varid }, '=', node }
      varid = varid + 1
      return translateAssign(assign, block)
    end
  end

  function localizeScope(block)
    local scope = {}
    for i, sub in ipairs(block) do
      if sub.type == 'assign-statement' then
        local left = sub[1]
        local name = left[1]

        if not scope[name] then
          insert(scope, name)
          scope[name] = true
        end
      end
    end

    if scope[1] then
      insert(block, 1, {
        type = 'local-assign-statement',
        {
          type = 'names', unpack(scope)
        },
      })
    end
  end

  return translateBlock(tree, {})
end