local tokenize = require 'luna.tokenize'
local parse = require 'luna.parse'
local translate = require 'luna.translate'
local compile = require 'luna.compile'

local function dump(node, indent)
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

local path = ...
local _, content = io.input(path), io.read('*a'), io.close(), io.input()

local tokens = tokenize(content)
local tree = parse(tokens)
local translated = translate(tree)
local output = compile(translated)


local inspect = require 'inspect'

-- print(content)
-- print(inspect(tokens))
-- dump(tree)
-- dump(translated)
print(output)
