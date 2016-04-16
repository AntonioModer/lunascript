local insert = table.insert
local concat = table.concat
local format = string.format

return function(tokens)
  local function parseExpression(token)
    return { type = 'expression', token.value }
  end

  local function parseBlock(tokens, current)
    local result = { type = 'block' }
    local node

    while current <= #tokens do
      node = parseExpression(tokens[current])
      if node then
        table.insert(result, node)
        current = current + #node
      else
        error(format('unexpected token %q at %d', tokens[current].value, current))
      end
    end

    return result, current
  end

  local tree = parseBlock(tokens, 1)
  return tree
end
