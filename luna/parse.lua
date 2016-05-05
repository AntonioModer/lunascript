local function parse(tokens)
  local current = 1

  local function checkToken(tokentype)
    local token = tokens[current] or {}
    if token.type == tokentype then
      return token.value
    end
  end

  local function advance()
    current = current + 1
  end

  local function pass(...)
    local token = checkToken(...)
    if token then
      advance()
    end
    return token
  end

  local function panic(format, ...)
    if format then
      error(format:format(...), 0)
    else
      local default = 'unexpected token %q (%s) at %d'
      local message = default:format(tokens[current].value, tokens[current].type, current)
      error(message, 0)
    end
  end

  local function try(parse, ...)
    local start = current
    local token = parse(...)
    if token then return token end
    local errpos = current
    current = start
    return nil
  end


  local function parseLiteralValue()
    return pass 'number' or pass 'string' or pass 'name' or pass 'vararg'
  end

  local function parseExpression()
    return try(parseLiteralValue)
  end

  local function parseList(parse, ...)
    local list = { parse(...) }
    pass 'space'
    while pass 'comma' do
      pass 'space'
      table.insert(list, parse(...))
      pass 'space'
    end
    return list[1] and list
  end

  local function parseNameList()
    return parseList(pass, 'name')
  end

  local function parseExpressionList()
    return parseList(try, parseExpression)
  end

  local function parseLetAssign()
    local let = pass 'let'
    pass 'space'
    local namelist = try(parseNameList)
    pass 'space'
    local assign = namelist and pass 'assign'
    pass 'space'
    local explist = assign and try(parseExpressionList)
    pass 'space'
    pass 'line-break'
    return explist and { type = 'let-assign', namelist = namelist, assign = assign, explist = explist }
  end


  local function parseStatement()
    return parseLetAssign()
  end

  local tree = { type = 'block', body = {} }

  while current <= #tokens do
    table.insert(tree.body, try(parseStatement) or panic())
  end
  return tree
end

return parse
