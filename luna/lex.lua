local tokendef = require 'luna.tokens'

local function lex(source)
  local current = 1

  local function match(pattern, find)
    local position, value = source:match('()(' .. pattern .. ')', current)
    if position == current and (find == nil or find == value) then
      current = current + #value
      return value
    end
  end

  return coroutine.wrap(function()
    while current <= #source do
      local token
      for _, info in ipairs(tokendef) do
        local head, tail = '', ''
        if info.head then
          local value = match(info.head)
          if value then
            head = value
          else
            head = nil
          end
        end

        if head then
          if info.pattern then
            local value = match(info.pattern, info.find)
            if value then
              token = { type = info.type, value = head .. value }
              break
            end
          elseif info.body then
            local tail = ''
            local content = {}

            while true do
              if info.tail then
                local value = match(info.tail)
                if value then
                  tail = value
                  break
                end
              end

              local matched = false
              for i, pattern in ipairs(info.body) do
                local value = match(pattern)
                if value then
                  table.insert(content, value)
                  matched = true
                  break
                end
              end

              if not matched and not info.tail then
                break
              end
            end

            token = { type = info.type, value = head .. table.concat(content) .. tail }
            break
          end
        end
      end

      if token then
        coroutine.yield(token)
      else
        error('unexpected character ' .. source:sub(current, current) .. ' at ' .. current, 0)
      end
    end
  end)
end

return function(source)
  local tokens = {}
  for token in lex(source) do
    table.insert(tokens, token)
  end
  return tokens
end
