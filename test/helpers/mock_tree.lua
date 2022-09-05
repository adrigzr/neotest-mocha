local MockTree = {}

function MockTree:new(data)
  local tree = { _data = data }

  setmetatable(tree, self)
  self.__index = self

  return tree
end

function MockTree:data()
  return self._data[1]
end

function MockTree:iter()
  return ipairs(self._data)
end

return MockTree
