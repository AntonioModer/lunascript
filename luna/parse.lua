local insert = table.insert
local concat = table.concat
local format = string.format

local inspect = require 'inspect'

return function(tokens)
  local current = 1

  local advance
  local checkToken
  local skipToken
  local parseSingleExpression
  local parsePrefixExpression
  local parseNameIndex
  local parseVariableList
  local parseExpressionList
  local parseVariable
  local parseBodyUntil
  local parseList
  local parseConditional
  local parseBlock
  local parseFunctionName
  local parseFunctionParameters
  local parseFunction
  local parseUnary
  local parseNameIndex
  local parseExpressionIndex
  local parseAssign
  local walk

  function advance()
    current = current + 1
  end

  function checkToken(...)
    local token = tokens[current]
    if not token then return false end
    for i=1, select('#', ...) do
      if token.type == select(i, ...) then
        return token
      end
    end
  end

  function skipToken(...)
    local token = checkToken(...)
    if token then
      advance()
      return token
    end
  end

  function parseBodyUntil(func, ...)
    local body = {}
    while not func(...) do
      local exp = walk()
      if exp then
        insert(body, exp)
      end
    end
    return body
  end

  function parseList(nodetype, func, ...)
    local list = {}
    local node = func(...)
    if node then
      insert(list, node)
      while skipToken('list-separator') do
        node = func(...)
        if node then
          insert(list, node)
        else
          -- we've found either a missing expression in the list, or a double comma
          -- we need to return nil so we error out properly
          return
        end
      end
    end
    return { type = nodetype, values = list }
  end

  function parsePrefixExpression()
    return parseInfix()
    or skipToken('literal-name')
  end

  function parseVariableList()
    return parseList('variable-list', parseVariable)
  end

  function parseExpressionList()
    return parseList('expression-list', walk)
  end

  function parseNameIndex()
    local index = skipToken('index-name') and skipToken('literal-name')
    if index then
      return { type = 'index-name', value = index.value }
    end
  end

  function parseExpressionIndex()
    if skipToken('index-expression-open') then
      local exp = walk()
      if exp and skipToken('index-expression-close') then
        return { type = 'index-expression', value = exp }
      end
    end
  end

  function parseVariable()
    local node = parsePrefixExpression()
    local index = parseNameIndex() or parseExpressionIndex()
    while index do
      node = { type = 'index', prefix = node, index = index }
      index = parseNameIndex() or parseExpressionIndex()
    end
    return node
  end

  function parseConditional()
    if skipToken('if') then
      local cases = {}

      local condition = walk()
      if condition and skipToken('then') then
        insert(cases, {
          type = 'condition',
          condition = condition,
          body = parseBodyUntil(checkToken, 'elseif', 'else', 'end'),
        })
      end

      while skipToken('elseif') do
        local condition = walk()
        if condition and skipToken('then') then
          insert(cases, {
            type = 'condition',
            condition = condition,
            body = parseBodyUntil(checkToken, 'else', 'end'),
          })
        end
      end

      if skipToken('else') then
        insert(cases, {
          type = 'default',
          body = parseBodyUntil(checkToken, 'end')
        })
      end

      if skipToken('end') then
        return { type = 'conditional-expression', cases = cases }
      end
    end
  end

  function parseBlock()
    if skipToken('do') then
      local body = parseBodyUntil(checkToken, 'end')
      if skipToken('end') then
        return { type = 'block-expression', body = body }
      end
    end
  end

  function parseFunctionName()
    local token = skipToken('literal-name')
    local name

    while token do
      name = (name and name .. '.' or '') .. token.value
      token = skipToken('index-name') and skipToken('literal-name')
    end

    local index = skipToken('index-self') and skipToken('literal-name')
    if index then
      name = (name or '') .. ':' .. index.value
    end

    return { type = 'function-name', name = name }
  end

  function parseFunctionParameters()
    local params = {}
    if skipToken('infix-open') then
      local var = parseVariable()
      while var do
        insert(params, var)
        var = skipToken('list-separator') and parseVariable()
      end

      local vararg = skipToken('literal-vararg')
      if vararg then
        insert(params, vararg)
      end

      skipToken('infix-close')
    end
    return { node = 'variable-list', values = params }
  end

  function parseFunction()
    if skipToken('function') then
      local name = parseFunctionName()
      local params = parseFunctionParameters()
      local body = parseBodyUntil(skipToken, 'end')
      if body then
        return {
          type = 'function-expression',
          name = name,
          params = params,
          body = body,
        }
      end
    end
  end

  function parseFunctionCall()
    local pos = current
    local prefix = parseFunctionName() or parsePrefixExpression() or parseVariable()
    if prefix and checkToken('infix-open') then
      local node = prefix
      while skipToken('infix-open') do
        local args = parseExpressionList()
        if args and skipToken('infix-close') then
          node = { type = 'function-call', prefix = node, args = args }
        end
      end
      return node
    end
    current = pos
  end

  function parseInfix()
    if skipToken('infix-open') then
      local exp = walk()
      if exp and skipToken('infix-close') then
        return { type = 'infix', value = exp }
      end
    end
  end

  function parseLiteral()
    local literal = skipToken(
      'literal-number',
      'literal-string',
      'literal-constant',
      'literal-vararg')

      -- literals
    if literal then
      return { type = literal.type, value = literal.value }
    end
  end

  function parseUnary()
    local unaryop = skipToken('unary-operator')
    if unaryop then
      local value = parseSingleExpression()
      if value then
        return {
          type = 'unary-expression',
          op = unaryop.value,
          value = value,
        }
      end
    end
  end

  function parseAssign()
    local pos = current

    local varlist = parseVariableList()
    if varlist then
      local op = skipToken('assign-operator')
      if op then
        local exp = parseExpressionList()
        if exp then
          return {
            type = 'assign-expression',
            left = varlist,
            right = exp,
            op = op.value,
          }
        end
      end
    end

    current = pos
  end

  function parseSingleExpression()
    return parseUnary()
      or parseConditional()
      or parseBlock()
      or parseFunction()
      or parseFunctionCall()
      or parseAssign()
      or parseVariable()
      or parseInfix()
      or parseLiteral()
  end

  function walk()
    local node = parseSingleExpression()

    local binaryop = skipToken('binary-operator')
    if binaryop then
      return {
        type = 'binary-expression',
        left = node,
        op = binaryop.value,
        right = walk(),
      }
    else
      return node
    end
  end

  local tree = { type = 'block', body = {} }

  while current <= #tokens do
    local node = walk()
    if node then
      insert(tree.body, node)
    else
      local token = tokens[current] or { type = 'eof', value = '<eof>' }
      error(format('unexpected token %q (%s) at position %d', token.value, token.type, current))
    end
  end

  return tree
end
