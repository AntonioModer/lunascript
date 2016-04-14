
local function parse(content)
  local pos = 1
  local tokens = {}

  local singleops = ('[ + - * / % ^ # & ~ | < > = ( ) { } [ ] : ; , .]'):gsub(' ', '%%') -- just to make things readable

  local function match(pattern, tokenType)
    local start, value = content:match('()(' .. pattern .. ')', pos)
    if start == pos then
      if tokenType then
        table.insert(tokens, { type = tokenType, value = value })
      end
      print(pos, value)
      pos = pos + #value
      return true
    end
    return false
  end

  while pos <= #content do
    repeat
      -- whitespace
      if match('%s+')

      -- numbers
      or match('0x[0-9a-fA-F]+', 'number') -- hex
      or match('%d*%.?%d+', 'number') -- decimal

      -- symbols
      or match(singleops, 'symbol')
      or match('>>', 'symbol') or match('<<', 'symbol') or match('//', 'symbol')
      or match('==', 'symbol') or match('~=', 'symbol') or match('<=', 'symbol') or match('>=', 'symbol')
      or match('%.%.', 'symbol') or match('%.%.%.', 'symbol')

      -- that short circuit tho
      then break end

      error(('unexpected character %q at position %d'):format(content:sub(pos, pos), pos), 0)
    until true
  end

  return tokens
end


local path = ...
local _, content = io.input(path), io.read('*a'), io.close(), io.input()

local tokens = parse(content)
for i=1, #tokens do
  print(tokens[i].type, tokens[i].value)
end
