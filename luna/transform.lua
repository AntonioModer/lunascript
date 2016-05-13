local function Transformer()
  return {
    Number = function (self, node)
      return node.type == 'Number' and node
    end,

    Name = function (self, node)
      return node.type == 'Name' and node
    end,

    String = function (self, node)
      return node.type == 'String' and node
    end,

    Literal = function (self, node)
      return self:Number(node)
      or self:Name(node)
      or self:String(node)
    end,

    Expression = function (self, node)
      return self:Literal(node)
    end,

    Assignment = function (self, node)
      return node.type == 'Assignment'
      and {
        type = 'Assignment',
        target = self:Literal(node.target),
        value = self:Expression(node.value),
      }
    end,

    Statement = function (self, node)
      return self:Assignment(node)
    end,

    Body = function (self, nodelist)
      local body = {}
      for i, node in ipairs(nodelist) do
        table.insert(body, self:Statement(node))
      end
      return body
    end,
  }
end

local function transform(lunatree)
  local transformer = Transformer()
  local body = transformer:Body(lunatree.body)
  return { type = 'LuaScript', body = body }
end

return { transform = transform }
