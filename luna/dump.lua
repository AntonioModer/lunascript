return function(node, indent)
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
