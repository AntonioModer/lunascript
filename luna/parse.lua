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
      return { type = tokentype, size = 1, token.value }
    end
  end

  function parseInfixedExpression(open, ...)
    if open.type == 'infix-open' then
      local exp = parseExpression(...)
      if exp then
        local close = select(exp.size + 1, ...)
        if close and close.type == 'infix-close' then
          return { type = 'infix-expression', size = exp.size + 2, exp }
        end
      end
    end
  end

  function parseExpression(...)
    return parseInfixedExpression(...)
    or parseLiteral('literal-number', ...)
    or parseLiteral('literal-string', ...)
    or parseLiteral('literal-vararg', ...)
    or parseLiteral('literal-constant', ...)
    or parseLiteral('literal-name', ...)
  end

  function parseBlock(...)
    local tokens = {...}
    local block = { type = 'block' }
    local stepped = 1

    while stepped <= #tokens do
      local node = parseExpression(unpack(tokens, stepped))
      if node then
        table.insert(block, node)
        stepped = stepped + node.size
      else
        break
      end
    end

    block.size = stepped
    return block
  end

  return parseBlock(unpack(tokens))
end
