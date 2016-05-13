local function Compiler()
  return {
    Number = function (self, node)
      return node.type == 'Number' and node.value
    end,

    Name = function (self, node)
      return node.type == 'Name' and node.value
    end,

    String = function (self, node)
      return node.type == 'String' and node.value
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
      return table.concat { self:Name(node.target), ' = ', self:Expression(node.value) }
    end,

    Statement = function (self, node)
      return self:Assignment(node)
    end,

    Body = function (self, nodelist)
      local output = {}
      for i, node in ipairs(nodelist) do
        table.insert(output, self:Statement(node))
      end
      return table.concat(output, '\n')
    end,
  }
end

local function compile(luatree)
  return Compiler():Body(luatree.body)
end

return { compile = compile }
