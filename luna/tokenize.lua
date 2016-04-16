local concat = table.concat
local insert = table.insert
local format = string.format

return function(content)
  local tokens = {}
  local current = 1

  local function pass(pattern)
    local location, value = content:match('()(' .. pattern .. ')', current)
    if location == current then
      current = current + #value
      return value
    end
  end

  local function match(pattern, tokentype)
    local value = pass(pattern)
    if value then
      insert(tokens, { type = tokentype, value = value })
      return true
    end
  end

  while current < #content do
    repeat
      -- white space
      if pass('%s+') then break end

      -- comments
      if pass('%-%-%[%[.-%]%]') then break end
      if pass('%-%-[^\r\n]*') then break end

      -- hex numbers
      if match('0x[%dA-Fa-f]+', 'literal-number') then break end

      -- numbers
      if match('%d*%.?%d+', 'literal-number') then break end

      -- names
      if match('[%a_][%w_]*', 'literal-name') then break end

      -- strings
      if match('%b""', 'literal-string') then break end

      error(format('unexpected character %q at %d', content:sub(current, current), current), 0)
    until true
  end

  return tokens
end
