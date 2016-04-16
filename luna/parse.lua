local insert = table.insert
local concat = table.concat
local format = string.format

local function parseLiteral(tokentype, token)
  if token.type == tokentype then
    return { type = tokentype, token.value }
  end
end

local function parseExpression(...)
  return parseLiteral('literal-number', ...)
  or parseLiteral('literal-string', ...)
  or parseLiteral('literal-vararg', ...)
  or parseLiteral('literal-constant', ...)
end

local function parseBlock(current, ...)
  local tokens = {...}
  local result = { type = 'block' }
  local node

  while current <= #tokens do
    node = parseExpression(unpack(tokens, current))
    if node then
      table.insert(result, node)
      current = current + #node
    else
      error(format('unexpected token %q at %d', tokens[current].value, current))
    end
  end

  return current, result
end


return function(tokens)
  local _, tree = parseBlock(1, unpack(tokens))
  return tree
end
