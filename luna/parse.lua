local parse = {}

function parse.lex(source, identity)
  identity = identity or 'luna'

  local lines = {}
  local linenum = 1

  for line in source:gmatch('[^\r\n]+') do
    if line:match('%s+') ~= line then
      local indentation = #line:match('^%s*')
      local tokens = {}
      local current = indentation + 1

      local function match(pattern, tokentype)
        local position, value, capture = line:match('()(' .. pattern .. ')', current)
        if position == current then
          value = capture or value
          return { type = tokentype, value = value }
        end
      end

      while current <= #line do
        local token = match('%d+', 'number')
        if token then
          table.insert(tokens, token)
          current = current + #token.value
        else
          local errformat = "[%s] Syntax error: unknown character %q (line %d col %d)"
          local errmsg = errformat:format(identity, line:sub(current, current), linenum, current)
          error(errmsg, 0)
        end
      end

      local lineinfo = { tokens = tokens, indentation = indentation, num = linenum }
      table.insert(lines, lineinfo)
      linenum = linenum + 1
    end
  end

  return lines
end

return parse
