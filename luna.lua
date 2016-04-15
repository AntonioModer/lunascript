local inspect = require 'inspect'

local insert = table.insert
local concat = table.concat
local format = string.format

local function dump(node, indent)
  indent = indent or 0
  print(string.rep('   ', indent) .. node.type .. ':')
  for i=1, #node do
    if type(node[i]) == 'table' then
      dump(node[i], indent + 1)
    else
      print(string.rep('   ', indent + 1) .. tostring(node[i]))
    end
  end
end

local function tokenize(content)
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
      or match('[%w_][%a_]*', 'name')

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


local function parse(tokens)
  local pos = 1

  local function current()
    return unpack(tokens, pos)
  end

  local parseName
  local parseConstant
  local parseLiteral
  local parseUnary
  local parseAssign
  local parseBinary
  local parseBlock
  local parseExpression
  local parseEOF

  function parseName()
    local token = current()
    if token.type == 'name' then
      pos = pos + 1
      return { type = 'name', token.value }
    end
  end

  function parseConstant()
    local token = current()
    if token.type == 'constant' then
      pos = pos + 1
      return { type = 'constant', token.value }
    end
  end

  function parseLiteral()
    return parseName() or parseConstant()
  end

  function parseUnary()
    local op = current()
    if op.type == 'unary' then
      pos = pos + 1
      return { type = 'unary-expression', op.value, parseLiteral() }
    end
  end

  function parseAssign()
    local name = parseName()
    if name then
      local op = current()
      if op.type == 'assign' then
        pos = pos + 1
        return { type = 'assign-expression', name, op.value, parseExpression() }
      else
        return name
      end
    end
  end

  function parseBinary()
    local left = parseUnary() or parseLiteral()
    local op = current()

    if op.type == 'binary' then
      pos = pos + 1
      return { type = 'binary-expression', left, op.value, parseExpression() }
    else
      return left
    end
  end

  function parseBlock()
    local token = current()
    if token.type == 'do' then
      local node = { type = 'block' }
      pos = pos + 1

      local sub = current()
      while sub.type ~= 'end' do
        insert(node, parseExpression())
        sub = current()
        if not sub then
          error('expected "end" to "do" at position ' .. token.position, 0)
        end
      end

      pos = pos + 1
      return node
    end
  end

  function parseCondition()
    local token = current()
    if token.type == 'if' then
      local node = { type = 'if-expression' }

      pos = pos + 1

      local condition = { type = 'if-clause', parseExpression() }
      local block = { type = 'block' }
      insert(condition, block)
      insert(node, condition)

      local sub = current()
      while sub.type ~= 'end' do
        insert(block, parseExpression())

        sub = current()
        if sub then
          if sub.type == 'elseif' or sub.type == 'else' then
            pos = pos + 1
            condition = { type = sub.type .. '-clause', sub.type == 'elseif' and parseExpression() or nil }
            block = { type = 'block' }
            insert(node, condition)
            insert(condition, block)
          end
        else
          error('expected "end" to "if" at position ' .. token.position, 0)
        end
      end

      pos = pos + 1
      return node
    end
  end

  function parseExpression()
    local token = current()

    return parseBlock()
    or parseCondition()
    or parseAssign()
    or parseBinary()
    or parseEOF()
    or error(('unexpected token %q at char %d'):format(token.value, token.position), 0)
  end

  function parseEOF()
    local token = current()
    if token.type == 'eof' then
      pos = pos + 1
      return { type = 'eof' }
    end
  end

  local tree = { type = 'block' }

  while pos <= #tokens do
    insert(tree, parseExpression())
  end

  return tree
end


local function translate(tree)
  local translated = {}

  local varid = 0

  local translateExpression
  local translateBlock
  local translateCondition
  local translateAssign
  local translateLiteral
  local localizeScope

  function translateExpression(node, block)
    return translateBlock(node, block)
    or translateCondition(node, block)
    or translateAssign(node, block)
    or translateLiteral(node, block)
  end

  function translateBlock(node, parent)
    if node.type == 'block' then
      local block = { type = 'block' }

      for i, sub in ipairs(node) do
        if translateExpression(sub, block) then end
      end

      localizeScope(block)

      insert(parent, block)
      return block
    end
  end

  function translateCondition(expression, block)
    if expression.type == 'if-expression' then
      local statement = { type = 'if-statement' }

      for i, node in ipairs(expression) do
        local case = { type = node.type, translateExpression(node[1], block) }

        for i=2, #node do
          translateExpression(node[i], case)
        end

        insert(statement, case)
        -- localizeScope(case)
      end

      insert(block, statement)

      return statement
    end
  end

  function translateAssign(node, block)
    if node.type == 'assign-expression' then
      local left, op, right = unpack(node)

      if translateAssign(right, block) then
        right = right[1]
      end

      local assign = { type = 'assign-statement', left, right }
      insert(block, assign)
      return left
    end
  end

  function translateLiteral(node, block)
    if node.type == 'name'
    or node.type == 'constant' then
      local assign = { type = 'assign-expression', { type = 'name', '_exp' .. varid }, '=', node }
      varid = varid + 1
      return translateAssign(assign, block)
    end
  end

  function localizeScope(block)
    local scope = {}
    for i, sub in ipairs(block) do
      if sub.type == 'assign-statement' then
        local left = sub[1]
        local name = left[1]

        if not scope[name] then
          insert(scope, name)
          scope[name] = true
        end
      end
    end

    if scope[1] then
      insert(block, 1, {
        type = 'local-assign-statement',
        {
          type = 'names', unpack(scope)
        },
      })
    end
  end

  return translateBlock(tree, {})
end


local function compile(translated)
  local source = {}

  local function compileBlock(block)
    for i, node in ipairs(block) do
      if node.type == 'local-assign-statement' then
        local names = node[1]
        insert(source, format('local %s', concat(names, ', ')))
        insert(source, '\n')
      elseif node.type == 'assign-statement' then
        local names, expressions = unpack(node)
        insert(source, format('%s', concat(names, ', ')))
        insert(source, ' = ')
        insert(source, format('%s', concat(expressions, ', ')))
        insert(source, '\n')
      end
    end
  end

  compileBlock(translated)
  return concat(source)
end


local path = ...
local _, content = io.input(path), io.read('*a'), io.close(), io.input()

local tokens = tokenize(content)
local tree = parse(tokens)
local translated = translate(tree)
local output = compile(translated)

-- print(content)
-- print(inspect(tokens))
dump(tree)
-- dump(translated)
-- print(output)
