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

  local function skip(...)
    pass(...)
    return true
  end

  local function panic(format, ...)
    if format then
      error(format:format(...), 0)
    else
      local default = 'unexpected token %q (%s) at %d'
      local message = default:format(tokens[current].value, tokens[current].type, current)
      error(message)
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


  local parseExpression

  local function parseLiteralValue()
    return pass 'number' or pass 'string' or pass 'name' or pass 'vararg'
  end

  local function parseBinaryOperator()
    return pass 'plus'
    or pass 'minus'
    or pass 'multiply'
    or pass 'divide'
    or pass 'modulo'
    or pass 'power'
    or pass 'equality'
    or pass 'inequality'
    or pass 'greater'
    or pass 'less'
    or pass 'greater-equal'
    or pass 'less-equal'
    or pass 'concat'
    or pass 'floor-divide'
    or pass 'and'
    or pass 'or'
  end

  local function parseUnaryOperator()
    return pass 'minus'
    or pass 'len'
    or pass 'not'
  end

  local function parseUnaryExpression()
    local op = try(parseUnaryOperator)
    local value = op and try(parseExpression)
    return value and { type = 'unary-expression', op = op, value = value }
  end

  local function parseBinaryExpression()
    local left = try(parseUnaryExpression) or try(parseLiteralValue)
    local op = left and skip 'space' and try(parseBinaryOperator)
    local right = op and skip 'space' and try(parseExpression)
    return right and { type = 'binary-expression', left = left, op = op, right = right }
  end

  function parseExpression()
    return try(parseUnaryExpression)
    or try(parseBinaryExpression)
    or try(parseLiteralValue)
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

  local function parseAssign()
    local namelist = try(parseNameList)
    pass 'space'
    local assign = namelist and pass 'assign'
    pass 'space'
    local explist = assign and try(parseExpressionList)
    pass 'space'
    pass 'line-break'
    return explist and { type = 'assign', namelist = namelist, assign = assign, explist = explist }
  end

  local function parseLetAssign()
    local let = pass 'let'
    pass 'space'
    local assign = let and try(parseAssign)
    if assign then
      assign.type = 'let-assign'
      return assign
    end
  end

  local function parseStatement()
    return try(parseLetAssign) or try(parseAssign)
  end

  local tree = { type = 'block', body = {} }

  while current <= #tokens do
    table.insert(tree.body, try(parseStatement) or panic())
  end
  return tree
end

return parse
