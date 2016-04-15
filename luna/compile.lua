local insert = table.insert
local concat = table.concat
local format = string.format

return function(translated)
  local source = {}
  local depth = 0

  local function indent()
    if depth > 0 then
      insert(source, ('  '):rep(depth))
    end
  end

  local compileLocalAssign
  local compileAssign
  local compileConditional
  local compileBlock
  local compileExpression
  local compileStatement

  function compileStatement(node)
    return compileLocalAssign(node)
    or compileAssign(node)
    or compileConditional(node)
  end

  function compileExpression(node)
    if node.type == 'name'
    or node.type == 'constant' then
      insert(source, node[1])
      return true
    end
  end

  function compileLocalAssign(node)
    if node.type == 'local-assign-statement' then
      local names = node[1]
      indent()
      insert(source, format('local %s', concat(names, ', ')))
      insert(source, '\n')
      return true
    end
  end

  function compileAssign(node)
    if node.type == 'assign-statement' then
      local names, expressions = unpack(node)
      indent()
      insert(source, format('%s', concat(names, ', ')))
      insert(source, ' = ')
      compileExpression(expressions)
      insert(source, '\n')
      return true
    end
  end

  function compileConditional(node)
    if node.type == 'if-statement' then
      for i, clause in ipairs(node) do
        if clause.type == 'if-clause' then
          local condition, block = unpack(clause)

          indent()
          insert(source, 'if ')
          compileExpression(condition)
          insert(source, ' then\n')

          depth = depth + 1
          compileBlock(block)
          depth = depth - 1
        elseif clause.type == 'elseif-clause' then
          local condition, block = unpack(clause)

          indent()
          insert(source, 'elseif ')
          compileExpression(condition)
          insert(source, ' then\n')

          depth = depth + 1
          compileBlock(block)
          depth = depth - 1
        elseif clause.type == 'else-clause' then
          local block = unpack(clause)

          indent()
          insert(source, 'else\n')

          depth = depth + 1
          compileBlock(block)
          depth = depth - 1
        end
      end

      indent()
      insert(source, 'end\n')
      return true
    end
  end

  function compileBlock(block)
    for i, node in ipairs(block) do
      compileStatement(node)
    end
  end

  compileBlock(translated)
  return concat(source)
end
