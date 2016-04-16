local concat = table.concat
local insert = table.insert
local format = string.format

return function(content)
  local tokens = {}
  local current = 1

  while current < #content do
    repeat
      -- white space
      local location, space = content:match('()(%s+)', current)
      if location == current then
        current = current + #space
        break
      end

      -- comments
      local location, comment = content:match('()(%-%-[^\r\n]*)', current)
      if location == current then
        current = current + #comment
        break
      end

      -- hex numbers
      local location, hex = content:match('()(0x[%dA-Fa-f]+)', current)
      if location == current then
        current = current + #hex
        insert(tokens, { type = 'literal-number', value = hex })
        break
      end

      -- numbers
      local location, number = content:match('()(%d*%.?%d+)', current)
      if location == current then
        current = current + #number
        insert(tokens, { type = 'literal-number', value = number })
        break
      end

      -- names
      local location, name = content:match('()([%a_][%w_]*)', current)
      if location == current then
        current = current + #name
        insert(tokens, { type = 'literal-name', value = name })
        break
      end

      -- strings
      local location, str = content:match('()(%b"")')
      if location == current then
        current = current + #str
        insert(tokens, { type = 'literal-string', value = str })
        break
      end

      error(format('unexpected character %q at %d', content:sub(current, current), current), 0)
    until true
  end

  return tokens
end
