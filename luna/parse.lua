local parse = {}

local function escape(str)
  return str:gsub('([%%%^%$%(%)%.%[%]%*%+%-%?])', '%%%1')
end

function parse.lex(source, identity)
  identity = identity or 'luna'

  local lines = {}
  local linenum = 1

  for line in source:gmatch('[^\r\n]+') do
    if line:match('%s+') ~= line then
      local indentation = #line:match('^%s*')
      local tokens = {}
      local current = indentation + 1

      local function match(pattern)
        local position, value, capture = line:match('()(' .. pattern .. ')', current)
        if position == current then
          return capture or value
        end
      end

      local function pass(pattern)
        local value = match(pattern)
        if value then
          current = current + #value
          return value
        end
      end

      local function matchToken(pattern, tokentype)
        local value = pass(pattern)
        if value then
          table.insert(tokens, { type = tokentype, value = value })
          return true
        end
      end

      local function matchString()
        local head = pass('"') or pass("'") or pass('%[%[')
        if head then
          local tail = head == '[[' and ']]' or head
          local content = {}
          while not pass(escape(tail)) do
            table.insert(content, pass('\\.') or pass('.'))
          end
          table.insert(tokens, { type = 'literal-string', value = head .. table.concat(content) .. tail })
          return true
        end
      end

      while current <= #line do
        -- white space
        if pass('%s+')

        -- hex numbers
        or matchToken('0x[%da-fA-F]+', 'literal-number')

        -- scientific notation
        or matchToken('%d*%.?%d+e%d+', 'literal-number')
        or matchToken('%d*%.?%d+E[%+%-]%d+', 'literal-number')

        -- decimal numbers
        or matchToken('%d*%.?%d+', 'literal-number')

        -- string
        or matchString()

        -- name
        or matchToken('[%a_][%w_]*', 'literal-name')

        then
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
