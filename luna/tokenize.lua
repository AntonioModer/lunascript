local concat = table.concat
local insert = table.insert
local format = string.format

local inspect = require 'inspect'

return function(content)
  local tokens = {}
  local current = 1

  local function pass(pattern)
    local location, value, capture = content:match('()(' .. pattern .. ')', current)
    if location == current then
      value = capture or value
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

  local function keyword(word, tokentype)
    local tokentype = tokentype or word -- the type of a keyword is the word itself by default
    local pos = current
    local capture = pass('%w+')
    if capture == word then
      insert(tokens, { type = tokentype, value = capture })
      return true
    else
      current = pos
    end
  end

  local function symbol(op, tokentype)
    local value = match('(' .. op:gsub('(.)', '%%%1') .. ')', tokentype)
    if value then return value end
  end

  while current <= #content do
    repeat
      -- comments (NOTE: match multiline first)
      if pass('%-%-%[%[.-%]%]') then break end
      if pass('%-%-[^\r\n]*') then break end

      -- parse newlines,
      -- then interpret as expression terminators to prevent ambiguity in some expressions
      -- mainly function calls
      -- if match('[\r\n]+', 'newline') then break end

      -- white space
      if pass('%s+') then break end

      -- vararg
      if match('(%.%.%.)[^%w%.]?', 'literal-vararg') then break end

      -- keywords
      -- NOTE: match keywords before names, or keywords will be matched _as_ names
      if keyword('if') then break end
      if keyword('then') then break end
      if keyword('elseif') then break end
      if keyword('else') then break end
      if keyword('end') then break end
      if keyword('for') then break end
      if keyword('in') then break end
      if keyword('do') then break end
      if keyword('while') then break end
      if keyword('function') then break end
      if keyword('break') then break end
      if keyword('return') then break end
      if keyword('repeat') then break end
      if keyword('until') then break end

      -- keyword assigns - these don't need non-alphanum characters after
      if match('and=', 'assign-operator') then break end
      if match('or=', 'assign-operator') then break end

      -- keyword operators
      if keyword('and', 'binary-operator') then break end
      if keyword('or', 'binary-operator') then break end
      if keyword('not', 'unary-operator') then break end

      -- keyword literals
      if keyword('true', 'literal-constant') then break end
      if keyword('false', 'literal-constant') then break end
      if keyword('nil', 'literal-constant') then break end

      -- names
      if match('[%a_][%w_]*', 'literal-name') then break end

      -- decimal & hex numbers (NOTE: match hex first)
      if match('0x[%dA-Fa-f]+', 'literal-number') then break end
      if match('%d*%.?%d+', 'literal-number') then break end

      -- strings (TODO: account for escapes)
      if match('%b""', 'literal-string') then break end
      if match("%b''", 'literal-string') then break end
      if match("%[%[.-%]%]", 'literal-string') then break end

      -- assign operator symbols (3 char)
      if symbol('..=', 'assign-operator') then break end

      -- assign operator symbols (2 char)
      if symbol('+=', 'assign-operator') then break end
      if symbol('-=', 'assign-operator') then break end
      if symbol('*=', 'assign-operator') then break end
      if symbol('/=', 'assign-operator') then break end

      -- binary operator symbols (2 char)
      if symbol('//', 'binary-operator') then break end
      if symbol('>>', 'binary-operator') then break end
      if symbol('<<', 'binary-operator') then break end
      if symbol('..', 'binary-operator') then break end
      if symbol('<=', 'binary-operator') then break end
      if symbol('>=', 'binary-operator') then break end
      if symbol('~=', 'binary-operator') then break end
      if symbol('==', 'binary-operator') then break end

      -- assign operator symbols (1 char)
      if symbol('=', 'assign-operator') then break end

      -- unary operator symbols
      -- NOTE: lua allows unary operators to have spaces before the operand
      -- but for an expression based language, this makes too many ambiguities
      -- we'll just require these to have no spaces after
      -- to parse them correctly
      if match('(#)%S', 'unary-operator') then break end
      if match('(%-)%S', 'unary-operator') then break end
      if match('(~)%S', 'unary-operator') then break end

      -- binary operator symbols (1 char)
      if symbol('+', 'binary-operator') then break end
      if symbol('*', 'binary-operator') then break end
      if symbol('/', 'binary-operator') then break end
      if symbol('^', 'binary-operator') then break end
      if symbol('%', 'binary-operator') then break end
      if symbol('&', 'binary-operator') then break end
      if symbol('|', 'binary-operator') then break end
      if symbol('<', 'binary-operator') then break end
      if symbol('>', 'binary-operator') then break end
      if symbol('-', 'binary-operator') then break end
      if symbol('~', 'binary-operator') then break end

      -- parens
      if symbol('(', 'infix-open') then break end
      if symbol(')', 'infix-close') then break end

      -- list separator
      if symbol(',', 'list-separator') then break end

      -- indexing
      if symbol('.', 'index-name') then break end
      if symbol(':', 'index-self') then break end
      if symbol('[', 'index-expression-open') then break end
      if symbol(']', 'index-expression-close') then break end

      -- this has a ton of meanings, so just parse it as itself
      -- we'll figure the details of it later
      if symbol(';', 'semicolon') then break end

      -- error on unknown characters
      -- TODO: add line position
      error(format('tokenizer: unexpected character %q at position %d', content:sub(current, current), current))
    until true
  end

  return tokens
end
