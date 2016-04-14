
local function parse(content)
  local pos = 1
  local tokens = {}

  local singleops = ('[ + - * / % ^ # & ~ | < > = ( ) { } [ ] : ; , .]'):gsub(' ', '%%') -- just to make things readable

  local function match(pattern, tokenType)
    local start, value = content:match('()(' .. pattern .. ')', pos)
    if start == pos then
      if tokenType then
        table.insert(tokens, { type = tokenType, value = value, position = pos })
      end
      pos = pos + #value
      return true
    end
    return false
  end

  while pos <= #content do
    if not (
      -- whitespace
      match('%s+')

      -- multiline comments
      or match('%-%-%[%[.-%]%]', 'comment')

      -- single line comments
      or match('%-%-[^\r\n]*', 'comment')

      -- numbers
      or match('0x[0-9a-fA-F]+', 'number') -- hex
      or match('%d*%.?%d+', 'number') -- decimal


      -- keywords
      or match('do', 'keyword')
      or match('end', 'keyword')
      or match('goto', 'keyword')
      or match('local', 'keyword')

      or match('true', 'keyword')
      or match('false', 'keyword')
      or match('nil', 'keyword')

      or match('and', 'keyword')
      or match('or', 'keyword')
      or match('not', 'keyword')

      or match('if', 'keyword')
      or match('else', 'keyword')
      or match('elseif', 'keyword')
      or match('then', 'keyword')

      or match('for', 'keyword')
      or match('in', 'keyword')
      or match('while', 'keyword')
      or match('repeat', 'keyword')
      or match('until', 'keyword')
      or match('break', 'keyword')

      or match('function', 'keyword')
      or match('return', 'keyword')


      -- strings
      or match('%b""', 'string')
      or match("%b''", 'string')
      or match('%[%[.-%]%]', 'string')

      -- identifiers
      or match('[%w_][%a_]*', 'identifier')


      -- symbols
      or match(singleops, 'symbol')

      or match('>>', 'symbol')
      or match('<<', 'symbol')
      or match('//', 'symbol')

      or match('==', 'symbol')
      or match('~=', 'symbol')
      or match('<=', 'symbol')
      or match('>=', 'symbol')

      or match('%.%.', 'symbol')
      or match('%.%.%.', 'symbol')

    -- lol short circuit abuse
    ) then
      error(('unexpected character %q at position %d'):format(content:sub(pos, pos), pos), 0)
    end
  end

  return tokens
end


local path = ...
local _, content = io.input(path), io.read('*a'), io.close(), io.input()

local tokens = parse(content)
for i=1, #tokens do
  print(tokens[i].type, tokens[i].value)
end
