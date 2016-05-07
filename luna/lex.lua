local function lex(source)
  local tokens = {}
  local current = 1

  local matchToken

  local function checkPattern(pattern)
    local position, value, capture = source:match('()(' .. pattern .. ')', current)
    if position == current then
      return value, capture
    end
  end

  local function advance(n)
    current = current + n
  end

  local function add(tokentype, value)
    table.insert(tokens, { type = tokentype, value = value })
    return true
  end

  local function pass(pattern)
    local value, capture = checkPattern(pattern)
    if value then
      advance(#value)
      return value, capture
    end
  end

  local function match(tokentype, pattern)
    local value, capture = pass(pattern)
    if value then
      table.insert(tokens, { type = tokentype, value = value })
      return value, capture
    end
  end

  local function keyword(word)
    local value, capture = checkPattern('%l+')
    if value == word then
      advance(#word)
      return add(word, word)
    end
  end

  local function matchString(head, tail, hasinfix)
    if match('string-head', head) then
      while not match('string-tail', tail) do
        if hasinfix and match('string-infix-open', '#{') then
          while not match('string-infix-close', '}') do
            matchToken()
          end
        else
          local content = {}
          while not checkPattern(tail) and (not hasinfix or not checkPattern('#{')) do
            table.insert(content, pass '\\.' or pass '.')
          end
          add('string-content', table.concat(content))
        end
      end
      return true
    end
  end


  function matchToken()
    -- comments
    return match('multi-comment', '%-%-%-(.-)%-%-%-[ \t]*')
    or match('comment', '%-%-[^\r\n]*')

    -- white space
    or match('space', '[ \t]+')
    or match('line-break', '[\r\n]+')
    or match('line-continue', '\\%s+')

    -- numbers
    or match('number', '0x%x+')               -- hexadecimal
    or match('number', '%d*%.?%d+e%d+')       -- sci notation, short form
    or match('number', '%d*%.?%d+E[%+%-]%d+') -- sci notation, long form
    or match('number', '%d*%.?%d+')           -- decimal number

    or matchString('"""', '"""', true)  -- multiline strings
    or matchString('"',   '"',   true)  -- double quote strings
    or matchString("'",   "'",   false) -- single quote strings

    -- symbols, grouped by char length
    or match('vararg', '%.%.%.')

    or match('floor-divide',  '//')
    or match('concat',        '%.%.')
    or match('equality',      '==')
    or match('inequality',    '~=')
    or match('greater-equal', '>=')
    or match('less-equal',    '<=')

    or match('plus',           '%+')
    or match('minus',          '%-')
    or match('multiply',       '%*')
    or match('divide',         '/' )
    or match('modulo',         '%%')
    or match('power',          '^' )
    or match('len',            '#' )
    or match('greater',        '>' )
    or match('less',           '<' )
    or match('dot',            '%.')
    or match('colon',          ':' )
    or match('assign',         '=' )
    or match('comma',          ',' )
    or match('open-bracket',   '%[')
    or match('closed-bracket', '%]')
    or match('open-paren',     '%(')
    or match('closed-paren',   '%)')
    or match('open-brace',     '{' )
    or match('closed-brace',   '}' )

    -- keywords
    or keyword('if')
    or keyword('elseif')
    or keyword('else')
    or keyword('then')
    or keyword('while')
    or keyword('do')
    or keyword('let')
    or keyword('switch')
    or keyword('when')
    or keyword('for')
    or keyword('in')
    or keyword('of')
    or keyword('to')
    or keyword('by')
    or keyword('every')
    or keyword('import')
    or keyword('continue')
    or keyword('break')
    or keyword('and')
    or keyword('or')
    or keyword('not')
    or keyword('true')
    or keyword('false')
    or keyword('is')
    or keyword('isnt')

    -- lua names
    or match('name', '[%a_][%w_]*')
  end


  local function panic()
    local char = source:sub(current, current):gsub('\n', '\\n')
    local format = 'unexpected character "%s" at %d'
    local err = format:format(char, current)
    error(err, 1)
  end

  while current <= #source do
    local _ = matchToken() or panic()
  end

  return tokens
end

return lex
