local lex = require 'luna.lex'
local parse = require 'luna.parse'
local transform = require 'luna.transform'
local compile = require 'luna.compile'

local function tolua(source)
  local tokens = lex(source)
  local lunatree = parse(tokens)
  local luatree = transform(lunatree)
  local output = compile(luatree)
  return output
end

local function loadlunastring(str)
  return loadstring(tolua(str))
end

local function dolunastring(str, ...)
  return loadlunastring(str)(...)
end

local function dolunafile(file)
  local file, err = io.open(file)
  if file then
    local content = file:read('*a'); file:close()
    return dolunastring(content)
  end
  return nil, err
end

return {
  tolua = tolua,
  dostring = dolunastring,
  dofile = dolunafile,
}
