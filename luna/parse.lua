local insert = table.insert
local concat = table.concat
local format = string.format

return function(tokens)
  local pos = 1

  local function current()
    return unpack(tokens, pos)
  end

  local parseName
  local parseConstant
  local parseLiteral
  local parseUnary
  local parseAssign
  local parseBinary
  local parseBlock
  local parseExpression
  local parseEOF

  function parseName()
    local token = current()
    if token.type == 'name' then
      pos = pos + 1
      return { type = 'name', token.value }
    end
  end

  function parseConstant()
    local token = current()
    if token.type == 'constant' then
      pos = pos + 1
      return { type = 'constant', token.value }
    end
  end

  function parseLiteral()
    return parseName() or parseConstant()
  end

  function parseUnary()
    local op = current()
    if op.type == 'unary' then
      pos = pos + 1
      return { type = 'unary-expression', op.value, parseLiteral() }
    end
  end

  function parseAssign()
    local name = parseName()
    if name then
      local op = current()
      if op.type == 'assign' then
        pos = pos + 1
        return { type = 'assign-expression', name, op.value, parseExpression() }
      else
        return name
      end
    end
  end

  function parseBinary()
    local left = parseUnary() or parseLiteral()
    local op = current()

    if op.type == 'binary' then
      pos = pos + 1
      return { type = 'binary-expression', left, op.value, parseExpression() }
    else
      return left
    end
  end

  function parseBlock()
    local token = current()
    if token.type == 'do' then
      local node = { type = 'block' }
      pos = pos + 1

      local sub = current()
      while sub.type ~= 'end' do
        insert(node, parseExpression())
        sub = current()
        if not sub then
          error('expected "end" to "do" at position ' .. token.position, 0)
        end
      end

      pos = pos + 1
      return node
    end
  end

  function parseCondition()
    local token = current()
    if token.type == 'if' then
      local node = { type = 'if-expression' }

      while true do
        local sub = current()

        if not sub then
          error('expected "end" to "if" (at position ' .. token.position .. ')', 0)
        end

        if sub.type == 'if' or sub.type == 'elseif' then
          pos = pos + 1
          local condition = parseExpression()
          local block = { type = 'block' }
          local clause = { type = sub.type .. '-clause', condition, block }

          while true do
            local sub = current()
            if not sub then break end
            if sub.type == 'elseif' then break end
            if sub.type == 'end' then break end
            insert(block, parseExpression())
          end

          insert(node, clause)
        elseif sub.type == 'end' then
          break
        end
      end

      pos = pos + 1
      return node
    end
  end

  function parseExpression()
    local token = current()

    return parseBlock()
    or parseCondition()
    or parseAssign()
    or parseBinary()
    or parseEOF()
    or error(('unexpected token %q at char %d'):format(token.value, token.position), 0)
  end

  function parseEOF()
    local token = current()
    if token.type == 'eof' then
      pos = pos + 1
      return { type = 'eof' }
    end
  end

  local tree = { type = 'block' }

  while pos <= #tokens do
    insert(tree, parseExpression())
  end

  return tree
end
