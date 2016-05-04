local parse = {}

function parse.lines(source)
  local lines = {}
  for line in source:gmatch('[^\r\n]+') do
    if line:match('%s+') ~= line then
      table.insert(lines, line)
    end
  end
  return lines
end

return parse
