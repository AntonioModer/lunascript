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


    Assignment = function (self)
      local name = self:walk('name')
      local equals = name and self:skip('space') and self:walk('equals')
      local value = equals and self:skip('space') and self:walk('number')
      return value and { type = 'Assignment', target = name, op = equals, value = value }
    end,

    Statement = function (self)
      return self:Assignment()
    end,

    Body = function (self)
      local body = {}
      local node = self:Statement()
      while node do
        table.insert(body, node)
        node = self:walk('line-break') and self:Statement()
      end
      return body
    end,
  }
end

local function parse(tokens)
  local parser = Parser(tokens)
  local body = parser:Body()
  return { type = 'LunaScript', body = body }
end

return { parse = parse }
