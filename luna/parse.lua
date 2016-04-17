local insert = table.insert
local concat = table.concat
local format = string.format


return function(tokens)
  local current = 1

  local function walk()
    local token = tokens[current]

    -- if expression
    if token.type == 'if' then
      current = current + 1 -- skip 'if'

      local clauses = {}

      local condition = walk()
      token = tokens[current]
      if condition and token and token.type == 'then' then
        current = current + 1 -- skip 'then'

        local body = {}
        repeat
          insert(body, walk())
          token = tokens[current]
        until token and token.type == 'end'

        current = current + 1 -- skip 'end'
        insert(clauses, { type = 'if-clause', condition = condition, body = body })

      end

      return { type = 'if-expression', clauses = clauses }
    end

    -- do expression
    if token.type == 'do' then
      current = current + 1 -- skip 'do'

      local body = {}
      token = tokens[current]
      while token and token.type ~= 'end' do
        insert(body, walk())
        token = tokens[current]
      end

      current = current + 1 -- skip 'end'
      return { type = 'do-expression', body = body }
    end

    -- infix expression
    if token.type == 'infix-open' then
      current = current + 1
      local exp = walk()
      if exp then
        local close = tokens[current]
        if close.type == 'infix-close' then
          current = current + 1
          return { type = 'infix', value = exp }
        end
      end
    end

    -- literals
    if token.type == 'literal-name'
    or token.type == 'literal-number'
    or token.type == 'literal-string'
    or token.type == 'literal-constant'
    or token.type == 'literal-vararg' then
      current = current + 1
      return { type = token.type, value = token.value }
    end
  end

  local tree = { type = 'block', body = {} }

  while current <= #tokens do
    local node = walk()
    if node then
      insert(tree.body, node)
    else
      local token = tokens[current] or { type = 'eof', value = '<eof>' }
      error(format('unexpected token %q at position %d', token.value, current))
    end
  end

  return tree
end
