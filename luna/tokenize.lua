local insert = table.insert
local concat = table.concat
local format = string.format

return function(content)
  local pos = 1
  local tokens = {}

  local singleops = ('[ + - * / % ^ # & ~ | < > = ( ) { } [ ] : ; , .]'):gsub(' ', '%%') -- just to make things readable

  local function match(pattern, tokenType)
    local start, value = content:match('()(' .. pattern .. ')', pos)
    if start == pos then
      if tokenType then
        insert(tokens, { type = tokenType, value = value, position = pos })
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
      or match('0x[0-9a-fA-F]+', 'constant') -- hex
      or match('%d*%.?%d+', 'constant') -- decimal

      -- strings
      or match('%b""', 'constant') --TODO: account for quote escapes
      or match("%b''", 'constant')
      or match('%[%[.-%]%]', 'constant')

      -- keywords
      or match('true%s', 'constant')
      or match('false%s', 'constant')
      or match('nil%s', 'constant')

      or match('and%s', 'binary')
      or match('or%s', 'binary')
      or match('not%s', 'unary')

      or match('do%s', 'do')
      or match('end%s', 'end')
      or match('goto%s', 'goto')
      or match('local%s', 'local')
      or match('if%s', 'if')
      or match('else%s', 'else')
      or match('elseif%s', 'elseif')
      or match('then%s', 'then')
      or match('for%s', 'for')
      or match('in%s', 'in')
      or match('while%s', 'while')
      or match('repeat%s', 'repeat')
      or match('until%s', 'until')
      or match('break%s', 'break')
      or match('function%s', 'function')
      or match('return%s', 'return')

      -- names
      or match('[A-Za-z_][A-Za-z0-9_]*', 'name')

      -- symbols
      or match('>>', 'binary')
      or match('<<', 'binary')
      or match('//', 'binary')

      or match('==', 'binary')
      or match('~=', 'binary')
      or match('<=', 'binary')
      or match('>=', 'binary')

      or match('%.%.%.', 'constant')
      or match('%.%.', 'binary')

      or match('%-%s+', 'binary')
      or match('[%+%*%/%%%^%&%|%<%>]', 'binary')
      or match('[%~%-%#]', 'unary')

      or match('=', 'assign')

    -- lol short circuit abuse
    ) then
      error(('unexpected character %q at position %d'):format(content:sub(pos, pos), pos), 0)
    end
  end

  insert(tokens, { type = 'eof', value = '(eof)', position = #content })

  return tokens
end
