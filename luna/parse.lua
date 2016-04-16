local insert = table.insert
local concat = table.concat
local format = string.format


return function(tokens)
  local parseExpression
  local parseLiteral
  local parseInfixedExpression
  local parseBlock

  function parseLiteral(tokentype, token)
    if token.type == tokentype then
      return { type = tokentype, token.value }, 1
    end
  end

  function parseInfixedExpression(open, ...)
    if open.type == 'infix-open' then
      local exp, advance = parseExpression(...)
      if exp then
        local close = select(advance + 1, ...)
        if close.type == 'infix-close' then
          return { type = 'infix-expression', exp }, advance + 2
        end
      end
    end
  end

  function parseExpression(...)
    local node, advance
    if not node then node, advance = parseInfixedExpression(...) end
    if not node then node, advance = parseLiteral('literal-number', ...) end
    if not node then node, advance = parseLiteral('literal-string', ...) end
    if not node then node, advance = parseLiteral('literal-vararg', ...) end
    if not node then node, advance = parseLiteral('literal-constant', ...) end
    if not node then node, advance = parseLiteral('literal-name', ...) end
    return node, advance
  end

  function parseBlock(...)
    local tokens = {...}
    local block = { type = 'block' }
    local current = 1

    while current <= #tokens do
      local node, advance = parseExpression(unpack(tokens, current))
      if node then
        table.insert(block, node)
        current = current + advance
      else
        return block
        -- error(format('unexpected token %q at %d', tokens[current].value, current))
      end
    end

    return block, current
  end

  return parseBlock(unpack(tokens)), nil
end
