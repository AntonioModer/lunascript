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


    Number = function (self)
      local number = self:walk('number')
      return number and { type = 'number', value = number.value }
    end,

    Name = function (self)
      local name = self:walk('name')
      return name and { type = 'name', value = name.value }
    end,

    String = function (self)
      local string = self:walk('string')
      return string and { type = 'string', value = string.value }
    end,

    Literal = function (self)
      return self:Number()
      or self:Name()
      or self:String()
    end,

    Expression = function (self)
      return self:Literal()
    end,

    AssignmentOp = function (self)
      local op = self:walk('equals')
      return op and { type = 'assign-equals', value = op.value }
    end,

    Assignment = function (self)
      local name = self:Name()
      local equals = name and self:skip('space') and self:AssignmentOp()
      local value = equals and self:skip('space') and self:Expression()
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
  local body = {}
  while parser.pos <= #tokens do
    local node = parser:Statement()
    if node then
      table.insert(body, node)
      parser:walk('line-break')
    else
      local token = parser:current()
      local errformat = '%d:%d: unexpected token "%s"'
      local errmsg = errformat:format(token.line, token.col, token.value)
      return nil, errmsg
    end
  end
  return { type = 'LunaScript', body = body }
end

return { parse = parse }
