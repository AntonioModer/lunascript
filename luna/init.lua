local lex = require 'luna.lex'
local parse = require 'luna.parse'
local transform = require 'luna.transform'
local compile = require 'luna.compile'

local function tree(source)
  return parse(lex(source))
end

local function luatree(source)
  return transform(tree(source))
end

local function tolua(source)
  return compile(luatree(source))
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
  tokenize = lex,
  tree = tree,
  luatree = luatree,
}
