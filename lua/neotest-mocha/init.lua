local async = require "neotest.async"
local lib = require "neotest.lib"
local logger = require "neotest.logging"
local util = require "neotest-mocha.util"

---@class neotest.MochaOptions
---@field command? string|fun(path:string): string
---@field env? table<string, string>|fun(): table<string, string>
---@field cwd? string|fun(): string
---@field is_test_file? fun(path:string): boolean

---@type fun(path:string):string
local get_mocha_command = util.get_mocha_command

---@type fun():table<string, string>|nil
local get_env = util.get_env

---@type fun(path:string):string|nil
local get_cwd = util.get_cwd

---@type neotest.Adapter
local Adapter = { name = "neotest-mocha" }

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
Adapter.root = lib.files.match_root_pattern "package.json"

---@async
---@param file_path string
---@return boolean
local default_is_test_file = util.create_test_file_extensions_matcher(
  { "spec", "test" },
  { "js", "mjs", "cjs", "jsx", "coffee", "ts", "tsx" }
)

local is_test_file = default_is_test_file

---@async
---@param file_path string
---@return boolean
function Adapter.is_test_file(file_path)
  return is_test_file(file_path)
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function Adapter.discover_positions(file_path)
  local query = [[
    ; -- Namespaces --
    ; Matches: `describe('context')`
    ((call_expression
      function: (identifier) @func_name (#any-of? @func_name "describe" "context")
      arguments: (arguments (string (string_fragment) @namespace.name) (arrow_function))
    )) @namespace.definition
    ; Matches: `describe.only('context')`
    ((call_expression
      function: (member_expression
        object: (identifier) @func_name (#any-of? @func_name "describe" "context")
      )
      arguments: (arguments (string (string_fragment) @namespace.name) (arrow_function))
    )) @namespace.definition

    ; -- Tests --
    ; Matches: `it('test') / specify('test')`
    ((call_expression
      function: (identifier) @func_name (#any-of? @func_name "it" "specify")
      arguments: (arguments (string (string_fragment) @test.name) (arrow_function))
    )) @test.definition
    ; Matches: `it.only('test') / specify.only('test')`
    ((call_expression
      function: (member_expression
        object: (identifier) @func_name (#any-of? @func_name "it" "specify")
      )
      arguments: (arguments (string (string_fragment) @test.name) (arrow_function))
    )) @test.definition
  ]]

  return lib.treesitter.parse_positions(file_path, query, { nested_tests = true })
end

---@param args neotest.RunArgs
---@return neotest.RunSpec
function Adapter.build_spec(args)
  local results_path = async.fn.tempname() .. ".json"
  local tree = args.tree

  if not tree then
    return {}
  end

  local pos = tree:data()
  local testNamePattern = "'.*'"

  if pos.type == "test" then
    testNamePattern = "'" .. util.escape_test_pattern(pos.name) .. "$'"
  end

  if pos.type == "namespace" then
    testNamePattern = "'^" .. util.escape_test_pattern(pos.name) .. "'"
  end

  local binary = get_mocha_command(pos.path)
  local command = vim.split(binary, "%s+")

  vim.list_extend(command, {
    "--full-trace",
    "--reporter=json",
    "--reporter-options=output=" .. results_path,
    "--grep=" .. testNamePattern,
    pos.path,
  })

  return {
    command = command,
    cwd = get_cwd(pos.path),
    context = {
      results_path = results_path,
      file = pos.path,
    },
    strategy = util.get_strategy_config(args.strategy, command),
    env = get_env(args[2] and args[2].env or {}),
  }
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function Adapter.results(spec, result, tree)
  local output_file = spec.context.results_path
  local success, data = pcall(lib.files.read, output_file)

  if not success then
    logger.error("No test output file found ", output_file)
    return {}
  end

  local ok, parsed = pcall(vim.json.decode, data, { luanil = { object = true } })

  if not ok then
    logger.error("Failed to parse test output json ", output_file)
    return {}
  end

  local results = util.parsed_json_to_results(parsed, tree, result.output)

  return results
end

local is_callable = function(obj)
  return type(obj) == "function" or (type(obj) == "table" and obj.__call)
end

setmetatable(Adapter, {
  ---@param opts neotest.MochaOptions
  __call = function(_, opts)
    is_test_file = opts.is_test_file or is_test_file

    if is_callable(opts.command) then
      get_mocha_command = opts.command
    elseif opts.command then
      get_mocha_command = function()
        return opts.command
      end
    end
    if is_callable(opts.env) then
      get_env = opts.env
    elseif opts.env then
      get_env = function(env)
        return vim.tbl_extend("force", opts.env, env)
      end
    end
    if is_callable(opts.cwd) then
      get_cwd = opts.cwd
    elseif opts.cwd then
      get_cwd = function()
        return opts.cwd
      end
    end
    return Adapter
  end,
})

return Adapter
