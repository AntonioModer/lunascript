local parse = {}

function parse.lex(source)
  local lines = {}
  local linenum = 1

  for line in source:gmatch('[^\r\n]+') do
    if line:match('%s+') ~= line then
      local indentation = #line:match('^%s+')
      local tokens = {}
      local current = level

      -- local function match(pattern, tokentype)
      --   local position, value, capture = line:match('()(' .. pattern .. ')', current)
      --   if position == current then
      --     value = capture or value
      --     local token = { type = tokentype, value = value }
      --     table.insert(tokens, token)
      --     current = current + #value
      --     return token
      --   end
      -- end

      -- while current <= #line do
      --   if true then
      --   else
      --     local errformat = "[%s] Syntax error: unknown character %q (line %d col %d)"
      --     local errmsg = errformat:format(identity, line:sub(current, current), linenum, current)
      --     error(errmsg, 0)
      --   end
      -- end

      local lineinfo = { tokens = tokens, indentation = indentation, num = linenum }
      table.insert(lines, lineinfo)
      linenum = linenum + 1
    end
  end

  return lines
end

return parse
