local insert = table.insert
local concat = table.concat
local format = string.format

local inspect = require 'inspect'

return function(tokens)
  local current = 1

  local walk
  local parseSingleExpression
  local parseNameIndex

  local function advance()
    current = current + 1
  end

  local function checkToken(...)
    local token = tokens[current]
    if not token then return false end
    for i=1, select('#', ...) do
      if token.type == select(i, ...) then
        return token
      end
    end
  end

  local function skipToken(...)
    local token = checkToken(...)
    if token then
      advance()
      return token
    end
  end

  local function parseBodyUntil(func, ...)
    local body = {}
    while not func(...) do
      local exp = walk()
      if exp then
        insert(body, exp)
      end
    end
    return body
  end

  local function parseConditional()
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

  local function parseBlock()
    if skipToken('do') then
      local body = parseBodyUntil(checkToken, 'end')
      if skipToken('end') then
        return { type = 'block-expression', body = body }
      end
    end
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
      'literal-name',
      'literal-number',
      'literal-string',
      'literal-constant',
      'literal-vararg')

      -- literals
    if literal then
      return { type = literal.type, value = literal.value }
    end
  end

  local function parseUnary()
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

  local function parseExpressionPrefix()
    return parseInfix()
    or skipToken('literal-name')
  end

  local function parseNameIndex()
    local index = skipToken('index-name') and skipToken('literal-name')
    if index then
      return index
    end
  end

  local function parseVariable()
    local node = parseExpressionPrefix()
    local index = parseNameIndex()
    while index do
      node = { type = 'index-name', prefix = node, index = index }
      index = parseNameIndex()
    end
    return node
  end

  local function parseList(nodetype, func, ...)
    local node = func(...)
    if node then
      local list = {}
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
      return { type = nodetype, values = list }
    end
  end

  local function parseVariableList()
    return parseList('variable-list', parseVariable)
  end

  local function parseExpressionList()
    return parseList('expression-list', walk)
  end

  local function parseAssign()
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
