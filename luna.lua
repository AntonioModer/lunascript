local inspect = require 'inspect'

local insert = table.insert
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
      pos = pos + 1

      local node = { type = 'if-expression' }

      local condition = { type = 'if', parseExpression() }
      insert(node, condition)

      local sub = current()
      while sub.type ~= 'end' do
        insert(condition, parseExpression())

        sub = current()
        if sub then
          if sub.type == 'elseif' then
            pos = pos + 1
            condition = { type = 'if', parseExpression() }
            insert(node, condition)
          elseif sub.type == 'else' then
            pos = pos + 1
            condition = { type = 'else' }
            insert(node, condition)
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

local function compile(tree)
  local indent = 0

  local function getIndent()
    return ('  '):rep(indent)
  end

  local function append(to, content, ...)
    if indent > 0 then
      insert(to, getIndent())
    end
    insert(to, format(content, ...))
  end


  local function compileExpression(node)
    if node.type == 'name' or node.type == 'constant' then
      return node[1]
    elseif node.type == 'binary-expression' then
      local left, op, right = unpack(node)
      return format('%s %s %s', compileExpression(left), op:gsub('%s', ''), compileExpression(right))
    end
  end

  local function compileAssign(node)
    local left, op, right = unpack(node)
    return format('%s %s %s\n', left[1], op, compileExpression(right)), left
  end

  local function compileBlock(block)
    local source = {}
    local scope = {}

    for i, node in ipairs(block) do
      if node.type == 'assign-expression' then
        local content, names = compileAssign(node)

        for i, name in ipairs(names) do
          if not scope[name] then
            insert(scope, name)
            scope[name] = true
          end
        end

        append(source, content)
      elseif node.type == 'block' then
        append(source, 'do\n')

        indent = indent + 1
        append(source, compileBlock(node))
        indent = indent - 1

        append(source, 'end\n')
      end
    end

    insert(source, 1, format('local %s\n', table.concat(scope, ', ')))
    return table.concat(source)
  end

  return compileBlock(tree, 0)
end


local path = ...
local _, content = io.input(path), io.read('*a'), io.close(), io.input()

local tokens = tokenize(content)
local tree = parse(tokens)
local out = compile(tree)

-- print(inspect(tokens))
dump(tree)
print(out)
