local function parse(tokens)
  print(require 'inspect' (tokens))

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

  local function try(parse)
    local start = current
    local token = parse()
    if token then return token end
    local errpos = current
    current = start
    return nil, errpos
  end


  local function parseStatement()
    local let = pass 'let'
    pass 'space'
    local name = let and pass 'name'
    pass 'space'
    local assign = name and pass 'assign'
    pass 'space'
    local value = assign and (pass 'number' or pass 'string' or pass 'name')
    return value and { type = 'let', target = name, assign = assign, value = value }
  end

  local tree = { type = 'script', body = {} }

  while current <= #tokens do
    local token, errpos = try(parseStatement)
    if token then
      table.insert(tree.body, token)
    else
      local errformat = 'unexpected token %q (%s) at %d'
      local errmsg = errformat:format(tokens[errpos].value, tokens[errpos].type, errpos)
      error(errmsg, 0)
    end
  end
  return tree
end

return parse
