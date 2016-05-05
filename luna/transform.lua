local function transform(ast)
  local function transformStatement(node)
    
  end

  local luatree = { type = 'lua-script', body = {} }
  for i, node in ipairs(ast.body) do
    table.insert(luatree, transformStatement(node))
  end
  return luatree
end

return transform
