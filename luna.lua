local inspect = require 'inspect'

local function tokenize(content)
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
      or match('%-%-%[%[.-%]%]')

      -- single line comments
      or match('%-%-[^\r\n]*')

      -- numbers
      or match('0x[0-9a-fA-F]+', 'literal') -- hex
      or match('%d*%.?%d+', 'literal') -- decimal


      -- keywords
      or match('true', 'literal')
      or match('false', 'literal')
      or match('nil', 'literal')

      or match('and', 'binary')
      or match('or', 'binary')
      or match('not', 'unary')

      or match('do', 'control')
      or match('end', 'control')
      or match('goto', 'control')
      or match('local', 'control')

      or match('if', 'control')
      or match('else', 'control')
      or match('elseif', 'control')
      or match('then', 'control')

      or match('for', 'control')
      or match('in', 'control')
      or match('while', 'control')
      or match('repeat', 'control')
      or match('until', 'control')
      or match('break', 'control')

      or match('function', 'control')
      or match('return', 'control')


      -- strings
      or match('%b""', 'literal') --TODO: account for quote escapes
      or match("%b''", 'literal')
      or match('%[%[.-%]%]', 'literal')

      -- identifiers
      or match('[%w_][%a_]*', 'identifier')

      -- symbols
      or match('>>', 'binary')
      or match('<<', 'binary')
      or match('//', 'binary')

      or match('==', 'binary')
      or match('~=', 'binary')
      or match('<=', 'binary')
      or match('>=', 'binary')

      or match('%.%.', 'binary')
      or match('%.%.%.', 'literal')

      or match('%-%s+', 'binary')
      or match('[%+%*%/%%%^%&%|%<%>%=]', 'binary')
      or match('[%~%-%#]', 'unary')

    -- lol short circuit abuse
    ) then
      error(('unexpected character %q at position %d'):format(content:sub(pos, pos), pos), 0)
    end
  end

  return tokens
end


local function parse(tokens)
  local pos = 1

  local function isValue(token)
    return token and (token.type == 'literal' or token.type == 'identifier')
  end

  local function walk()
    local token = tokens[pos]

    if token.type == 'unary' then
      local operator = token
      local value = tokens[pos + 1]

      if isValue(value) then
        pos = pos + 1
        return { type = 'unary-expression', operator.value, walk() }
      else
        error('expected literal or identifier after unary operator ' .. operator.value .. ' at position ' .. operator.position, 0)
      end
    end

    if isValue(token) then
      if tokens[pos + 1] and tokens[pos + 1].type == 'binary' then
        local left = token
        local operator = tokens[pos + 1]
        local right

        pos = pos + 2

        return { type = 'binary-expression', left.value, operator.value, walk() }
      end

      pos = pos + 1
      return token.value --{ type = 'value', token }
    end
  end

  local tree = {
    type = 'program',
  }

  while pos <= #tokens do
    table.insert(tree, walk())
  end

  return tree
end


local path = ...
local _, content = io.input(path), io.read('*a'), io.close(), io.input()

local tokens = tokenize(content)
local tree = parse(tokens)
