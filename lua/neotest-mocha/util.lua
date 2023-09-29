local vim = vim
local validate = vim.validate
local uv = vim.loop
local lib = require "neotest.lib"

local M = {}

-- Some path utilities
M.path = (function()
  local is_windows = uv.os_uname().version:match "Windows"

  local function sanitize(path)
    if is_windows then
      path = path:sub(1, 1):upper() .. path:sub(2)
      path = path:gsub("\\", "/")
    end
    return path
  end

  local function exists(filename)
    local stat = uv.fs_stat(filename)
    return stat and stat.type or false
  end

  local function is_dir(filename)
    return exists(filename) == "directory"
  end

  local function is_file(filename)
    return exists(filename) == "file"
  end

  local function is_fs_root(path)
    if is_windows then
      return path:match "^%a:$"
    else
      return path == "/"
    end
  end

  local function is_absolute(filename)
    if is_windows then
      return filename:match "^%a:" or filename:match "^\\\\"
    else
      return filename:match "^/"
    end
  end

  local function dirname(path)
    local strip_dir_pat = "/([^/]+)$"
    local strip_sep_pat = "/$"
    if not path or #path == 0 then
      return
    end
    local result = path:gsub(strip_sep_pat, ""):gsub(strip_dir_pat, "")
    if #result == 0 then
      if is_windows then
        return path:sub(1, 2):upper()
      else
        return "/"
      end
    end
    return result
  end

  local function path_join(...)
    return table.concat(vim.tbl_flatten { ... }, "/")
  end

  -- Traverse the path calling cb along the way.
  local function traverse_parents(path, cb)
    path = uv.fs_realpath(path)
    local dir = path
    -- Just in case our algo is buggy, don't infinite loop.
    for _ = 1, 100 do
      dir = dirname(dir)
      if not dir then
        return
      end
      -- If we can't ascend further, then stop looking.
      if cb(dir, path) then
        return dir, path
      end
      if is_fs_root(dir) then
        break
      end
    end
  end

  -- Iterate the path until we find the rootdir.
  local function iterate_parents(path)
    local function it(_, v)
      if v and not is_fs_root(v) then
        v = dirname(v)
      else
        return
      end
      if v and uv.fs_realpath(v) then
        return v, path
      else
        return
      end
    end
    return it, path, path
  end

  local function is_descendant(root, path)
    if not path then
      return false
    end

    local function cb(dir, _)
      return dir == root
    end

    local dir, _ = traverse_parents(path, cb)

    return dir == root
  end

  local path_separator = is_windows and ";" or ":"

  return {
    is_dir = is_dir,
    is_file = is_file,
    is_absolute = is_absolute,
    exists = exists,
    dirname = dirname,
    join = path_join,
    sanitize = sanitize,
    traverse_parents = traverse_parents,
    iterate_parents = iterate_parents,
    is_descendant = is_descendant,
    path_separator = path_separator,
  }
end)()

function M.search_ancestors(startpath, func)
  validate { func = { func, "f" } }
  if func(startpath) then
    return startpath
  end
  local guard = 100
  for path in M.path.iterate_parents(startpath) do
    -- Prevent infinite recursion if our algorithm breaks
    guard = guard - 1
    if guard == 0 then
      return
    end

    if func(path) then
      return path
    end
  end
end

function M.root_pattern(...)
  local patterns = vim.tbl_flatten { ... }
  local function matcher(path)
    for _, pattern in ipairs(patterns) do
      for _, p in ipairs(vim.fn.glob(M.path.join(path, pattern), true, true)) do
        if M.path.exists(p) then
          return path
        end
      end
    end
  end
  return function(startpath)
    return M.search_ancestors(startpath, matcher)
  end
end

function M.find_node_modules_ancestor(startpath)
  return M.search_ancestors(startpath, function(path)
    if M.path.is_dir(M.path.join(path, "node_modules")) then
      return path
    end
  end)
end

function M.find_package_json_ancestor(startpath)
  return M.search_ancestors(startpath, function(path)
    if M.path.is_file(M.path.join(path, "package.json")) then
      return path
    end
  end)
end

---@param path string
---@return string
function M.get_mocha_command(path)
  local rootPath = M.find_node_modules_ancestor(path)
  local mochaBinary = M.path.join(rootPath, "node_modules", ".bin", "mocha")

  if M.path.exists(mochaBinary) then
    return mochaBinary
  end

  return "mocha"
end

---@param s string
---@return string
function M.escape_test_pattern(s)
  return (
    s:gsub("%(", "%\\(")
      :gsub("%)", "%\\)")
      :gsub("%]", "%\\]")
      :gsub("%[", "%\\[")
      :gsub("%*", "%\\*")
      :gsub("%+", "%\\+")
      :gsub("%-", "%\\-")
      :gsub("%?", "%\\?")
      :gsub("%$", "%\\$")
      :gsub("%^", "%\\^")
      :gsub("%/", "%\\/")
  )
end

---@param strategy string
---@param command string[]
---@return table|nil
function M.get_strategy_config(strategy, command)
  local config = {
    dap = function()
      return {
        name = "Debug Mocha Tests",
        type = "pwa-node",
        request = "launch",
        args = { unpack(command, 2) },
        runtimeExecutable = command[1],
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      }
    end,
  }

  if config[strategy] then
    return config[strategy]()
  end

  return nil
end

---@param env any
---@return any
function M.get_env(env)
  return env
end

---@param path string
---@return string|nil
function M.get_cwd(path)
  return nil
end

---@param s string
---@return string
function M.clean_ansi(s)
  return s:gsub("\x1b%[%d+;%d+;%d+;%d+;%d+m", "")
    :gsub("\x1b%[%d+;%d+;%d+;%d+m", "")
    :gsub("\x1b%[%d+;%d+;%d+m", "")
    :gsub("\x1b%[%d+;%d+m", "")
    :gsub("\x1b%[%d+m", "")
end

---@param file string
---@param errStr string
---@return string,string
function M.find_error_position(file, errStr)
  -- Look for: /path/to/file.js:123:987
  local regexp = file:gsub("([^%w])", "%%%1") .. "%:(%d+)%:(%d+)"
  local _, _, errLine, errColumn = string.find(errStr, regexp)

  return errLine, errColumn
end

---@param data table
---@param tree neotest.Tree
---@param consoleOut string
---@return table<string, neotest.Result>
function M.parsed_json_to_results(data, tree, consoleOut)
  local tests = {}

  for _, test in pairs(data.tests) do
    local testKey = test.file .. " " .. test.fullTitle
    local name = test.title
    local status
    local errors = {}
    local testNode

    -- This is needed due to mocha not providing a way to get all the namespaces
    -- of a test. We need to find the test node in the tree by replacing the tokens
    -- with spaces and matching with the full title.
    for _, node in tree:iter() do
      local nodeKey = node.id:gsub("::", " ")

      if testKey == nodeKey then
        testNode = node
        break
      end
    end

    if not testNode then
      break
    end

    if not vim.tbl_isempty(test.err) then
      status = "failed"
    elseif test.duration ~= nil then
      status = "passed"
    else
      status = "skipped"
    end

    local keyid = testNode.id
    local short = name .. ": " .. status

    if status == "failed" then
      local msg = M.clean_ansi(test.err.message)
      local errorLine, errorColumn = M.find_error_position(test.file, test.err.stack)

      table.insert(errors, {
        line = errorLine and errorLine - 1 or testNode.range[1],
        column = errorColumn and errorColumn - 1 or testNode.range[2],
        message = msg,
      })

      short = short .. "\n" .. msg
    end

    tests[keyid] = {
      status = status,
      output = consoleOut,
      short = short,
      errors = errors,
    }
  end

  return tests
end

---@param intermediate_extensions string[]
---@param end_extensions string[]
---@return fun(file_path: string): boolean
function M.create_test_file_extensions_matcher(intermediate_extensions, end_extensions)
  return function(file_path)
    if file_path == nil then
      return false
    end

    for _, iext in ipairs(intermediate_extensions) do
      for _, eext in ipairs(end_extensions) do
        if string.match(file_path, iext .. "%." .. eext .. "$") then
          return true
        end
      end
    end

    return false
  end
end

---@param dependencies table<string, string>?
---@param packageName string
---@return boolean
local function _has_package_dependency(dependencies, packageName)
  for key, _ in pairs(dependencies or {}) do
    if key == packageName then
      return true
    end
  end

  return false
end

---@param path string
---@param packageName string
---@return boolean
function M.has_package_dependency(path, packageName)
  local fullPath = path .. "/package.json"

  if not lib.files.exists(fullPath) then
    return false
  end

  local ok, packageJsonContent = pcall(lib.files.read, fullPath)

  if not ok then
    print("cannot read package.json")
    return false
  end

  local parsedPackageJson = vim.json.decode(packageJsonContent)

  if not parsedPackageJson then
    return false
  end

  if _has_package_dependency(parsedPackageJson["dependencies"], packageName) then
    return true
  end

  if _has_package_dependency(parsedPackageJson["devDependencies"], packageName) then
    return true
  end

  return false
end

return M
