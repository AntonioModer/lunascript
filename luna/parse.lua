local insert = table.insert
local concat = table.concat
local format = string.format


return function(tokens)
  local parseExpression
  local parseLiteral
  local parseInfixedExpression
  local parseBlock

  function parseLiteral(tokentype, current, token)
    if token.type == tokentype then
      return current + 1, { type = tokentype, token.value }
    end
  end

  function parseInfixedExpression(open, ...)
    -- if open.type == 'infix-open' or open.type == 'infix-close' then
    --   return { type = 'infix', open.value }
    -- end
  end

  function parseExpression(...)
    local pos, node = parseLiteral('literal-number', ...)
    if not node then pos, node = parseLiteral('literal-string', ...) end
    if not node then pos, node = parseLiteral('literal-vararg', ...) end
    if not node then pos, node = parseLiteral('literal-constant', ...) end
    if not node then pos, node = parseLiteral('literal-name', ...) end
    return pos, node
  end

  function parseBlock(current, ...)
    local tokens = {...}
    local result = { type = 'block' }
    local pos, node

    while current <= #tokens do
      pos, node = parseExpression(current, unpack(tokens, current))
      if node then
        table.insert(result, node)
        current = pos
      else
        error(format('unexpected token %q at %d', tokens[current].value, current))
      end
    end

    return current, result
  end

  local _, ast = parseBlock(1, unpack(tokens))
  return ast
end
