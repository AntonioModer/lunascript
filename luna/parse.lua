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

  local function panic(errpos)
    errpos = errpos or current
    local errformat = 'unexpected token %q (%s) at %d'
    local errmsg = errformat:format(tokens[errpos].value, tokens[errpos].type, errpos)
    error(errmsg, 0)
  end

  local function try(parse, ...)
    local start = current
    local token = parse(...)
    if token then return token end
    local errpos = current
    current = start
    return nil, errpos
  end


  local function parseLiteralValue()
    return pass 'number' or pass 'string' or pass 'name' or pass 'vararg'
  end

  local function parseExpression()
    return try(parseLiteralValue)
  end

  local function parseNameList()
    local names = { pass 'name' }
    pass 'space'
    while pass 'comma' do
      pass 'space'
      table.insert(names, pass 'name' or panic())
      pass 'space'
    end
    return names[1] and names
  end

  local function parseExpressionList()
    local explist = { try(parseExpression) }
    pass 'space'
    while pass 'comma' do
      pass 'space'
      table.insert(explist, try(parseLiteralValue) or panic())
      pass 'space'
    end
    return explist[1] and explist
  end

  local function parseLetAssign()
    local let = pass 'let'
    pass 'space'
    local names = try(parseNameList)
    pass 'space'
    local assign = names and pass 'assign'
    pass 'space'
    local explist = assign and try(parseExpressionList)
    pass 'space'
    pass 'line-break'
    return explist and { type = 'let-assign', names = names, assign = assign, explist = explist }
  end


  local function parseStatement()
    return parseLetAssign()
  end

  local tree = { type = 'script', body = {} }

  while current <= #tokens do
    local token, errpos = try(parseStatement)
    if token then
      table.insert(tree.body, token)
    else
      panic()
    end
  end
  return tree
end

return parse
