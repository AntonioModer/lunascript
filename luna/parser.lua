local function Parser(tokens)
  return {
    pos = 1,

    current = function (self)
      return tokens[self.pos]
    end,

    check = function (self, tokentype)
      local token = self:current() or {}
      return token.type == tokentype and token
    end,

    advance = function (self, n)
      self.pos = self.pos + (n or 1)
    end,

    pass = function (self, ...)
      local token = self:check(...)
      if token then
        self:advance()
        return token
      end
    end,
  }
end

local function Statement(parser)
  local name = parser:pass('name')
  parser:pass('space')
  local equals = name and parser:pass('equals')
  parser:pass('space')
  local value = equals and parser:pass('number')
  return value and { type = 'Assign', target = name, op = equals, value = value }
end

local function Body(parser)
  local body = {}
  for node in Statement, parser do
    table.insert(body, node)
    parser:pass('line-break')
  end
  return body
end

local function parse(tokens)
  local parser = Parser(tokens)
  return { type = 'luna-script', body = Body(parser) }
end

return { parse = parse }
