local concat = table.concat
local insert = table.insert
local format = string.format

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
    -- the type of a keyword is the word itself by default
    return match('(' .. word .. ')%W', tokentype or word)
  end

  while current < #content do
    repeat
      -- white space
      if pass('%s+') then break end

      -- comments (NOTE: match multiline first)
      if pass('%-%-%[%[.-%]%]') then break end
      if pass('%-%-[^\r\n]*') then break end

      -- decimal & hex numbers (NOTE: match hex first)
      if match('0x[%dA-Fa-f]+', 'literal-constant') then break end
      if match('%d*%.?%d+', 'literal-constant') then break end

      -- keywords
      -- NOTE: match before names, or keywords will be matched as names
      if keyword('if') then break end
      if keyword('then') then break end
      if keyword('elseif') then break end
      if keyword('else') then break end
      if keyword('end') then break end
      if keyword('for') then break end
      if keyword('in') then break end
      if keyword('do') then break end
      if keyword('while') then break end

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

      -- strings
      if match('%b""', 'literal-constant') then break end

      error(format('unexpected character %q at %d', content:sub(current, current), current), 0)
    until true
  end

  return tokens
end
