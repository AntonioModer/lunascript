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

    walk = function (self, ...)
      local token = self:check(...)
      if token then
        self:advance()
        return token
      end
    end,

    skip = function (self, ...)
      self:walk(...)
      return true
    end,
  }
end

local function Assignment(parser)
  local name = parser:walk('name')
  local equals = name and parser:skip('space') and parser:walk('equals')
  local value = equals and parser:skip('space') and parser:walk('number')
  return value and { type = 'Assignment', target = name, op = equals, value = value }
end

local function Statement(parser)
  return Assignment(parser)
end

local function Body(parser)
  local body = {}
  for node in Statement, parser do
    table.insert(body, node)
    parser:walk('line-break')
  end
  return body
end

local function parse(tokens)
  local parser = Parser(tokens)
  local body = Body(parser)
  return { type = 'LunaScript', body = body }
end

return { parse = parse }
