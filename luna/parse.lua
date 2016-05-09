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
      local token = tokens[current]
      local char = token.value:gsub('\n', '\\n')
      local default = 'unexpected token "%s" (%s) at %d'
      local message = default:format(char, token.type, current)
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
  local parseBlock

  local function parseNumber()
    local number = pass 'number'
    return number and { type = 'number', value = number }
  end

  local function parseName()
    local name = pass 'name'
    return name and { type = 'name', value = name }
  end

  local function parseVararg()
    return pass 'vararg' and { type = 'vararg' }
  end

  local function parseString()
    local head = pass 'string-head'
    if head then
      local content = {}
      local tail = pass 'string-tail'
      while not tail do
        if pass 'string-infix-open' then
          table.insert(content, parseExpression())
          local _ = pass 'string-infix-close' or panic()
        end

        local text = pass 'string-content'
        if text then
          table.insert(content, { type = 'string-content', value = text })
        end

        tail = pass 'string-tail'
      end
      return { type = 'string', head = head, tail = tail, content = content }
    end
  end

  local function parseLiteral()
    return try(parseString)
    or try(parseNumber)
    or try(parseName)
    or try(parseVararg)
  end

  local function parseUnaryOperator()
    return pass 'minus'
    or pass 'len'
    or pass 'not'
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

  local function parseUnaryExpression()
    local op = try(parseUnaryOperator)
    local value = op and (try(parseLiteral) or try(parseUnaryExpression))
    return value and { type = 'unary-expression', op = op, value = value }
  end

  local function parseBinaryExpression()
    local left = try(parseUnaryExpression) or try(parseLiteral)

    local op = left and skip 'space' and try(parseBinaryOperator)

    -- if we found a binary operator but can't parse an expression after that,
    -- panic, because there can only be an expression in this case.
    -- if not, that's most definitely an error.
    local right = op and skip 'space' and (try(parseExpression) or panic())

    return right and { type = 'binary-expression', left = left, op = op, right = right }
  end

  function parseExpression()
    return try(parseUnaryExpression)
    or try(parseBinaryExpression)
    or try(parseLiteral)
  end

  local function parseList(parse, ...)
    local list = { parse(...) }
    while skip 'space' and pass 'comma' do
      table.insert(list, skip 'space' and parse(...))
    end
    return list[1] and list
  end

  local function parseNameList()
    return parseList(parseName)
  end

  local function parseExpressionList()
    return parseList(try, parseExpression)
  end

  local function parseAssign()
    local names = try(parseNameList)
    local op = names and skip 'space' and pass 'assign'
    local values = op and skip 'space' and try(parseExpressionList)
    return values
      and skip 'space'
      and { type = 'assign', names = names, op = op, values = values }
  end

  local function parseLetAssign()
    local let = pass 'let'
    local assign = let and skip 'space' and try(parseAssign)
    return assign and { type = 'let-assign', names = assign.names, op = assign.op, values = assign.values }
  end

  local function parseDoStatement()
    return pass 'do' and skip 'line-break' and parseBlock()
  end

  local function parseStatement()
    return try(parseDoStatement)
    or try(parseLetAssign)
    or try(parseAssign)
    or nil
  end

  function parseBlock()
    local block = { type = 'block', body = {} }
    local space = pass 'space'
    local indent = #(space or '')

    local function getNode()
      return try(parseStatement)
    end

    for node in getNode do
      table.insert(block.body, node)

      skip 'line-break'
      local space = pass 'space'
      if #(space or '') ~= indent then
        break
      end
    end

    return block
  end

  local block = parseBlock(tokens)
  if current <= #tokens then panic() end
  return block
end

return parse
