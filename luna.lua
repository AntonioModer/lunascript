
local function parse(content)
  local pos = 1
  local tokens = {}

  while pos <= #content do
    repeat
      local char = content:sub(pos, pos)

      -- whitespace
      local space = char:match('%s')
      if space then
        pos = pos + 1
        break
      end

      -- decimals
      local start, number = content:match('()(%d*%.?%d+)')
      if number and start == pos then
        table.insert(tokens, { type = 'number', value = number })
        pos = pos + #number
        break
      end

      -- hex
      local start, number = content:match('()(0x[0-9a-fA-F]+)')
      if number and start == pos then
        table.insert(tokens, { type = 'number', value = number })
        pos = pos + #number
        break
      end

      error(('unexpected character %q at position %d'):format(char, pos), 0)
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
