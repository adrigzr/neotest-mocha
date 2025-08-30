local async = require("nio").tests
local neotest_async = require "neotest.async"
local basic_test_positions = require "test.fixtures.basic_test_positions"
local MockTree = require "test.helpers.mock_tree"
local util = require "neotest-mocha.util"
local stub = require "luassert.stub"

local function require_adapter(options)
  package.loaded["neotest-mocha"] = nil

  return require "neotest-mocha"(options)
end

describe("is_test_file", function()
  local plugin = require_adapter { command = "mocha" }
  local supported_extensions = { "js", "mjs", "cjs", "jsx", "coffee", "ts", "tsx" }
  local find_package_json_ancestor_stub
  local has_package_dependency_stub

  before_each(function()
    find_package_json_ancestor_stub = stub(util, "find_package_json_ancestor").returns "./root/"
    has_package_dependency_stub = stub(util, "has_package_dependency").returns(true)
  end)

  after_each(function()
    find_package_json_ancestor_stub:revert()
    has_package_dependency_stub:revert()
  end)

  it("matches mocha test files", function()
    for _, extension in ipairs(supported_extensions) do
      assert.True(plugin.is_test_file("./src/basic.test." .. extension))
    end
  end)

  it("does not match non-test files", function()
    assert.False(plugin.is_test_file "./src/index.js")
  end)

  it("does not mark a file as a test if mocha is not installed", function()
    has_package_dependency_stub.returns(false)

    assert.False(plugin.is_test_file "./src/basic.test.js")
  end)

  it("matches mocha test files with configurable test patterns", function()
    local intermediate_extensions = { "spec", "test", "lollipop" }
    local is_test_file = util.create_test_file_extensions_matcher(intermediate_extensions, supported_extensions)

    for _, extension1 in ipairs(intermediate_extensions) do
      for _, extension2 in ipairs(supported_extensions) do
        assert.True(is_test_file("./src/basic." .. extension1 .. "." .. extension2))
      end
    end
  end)
end)

describe("discover_positions", function()
  local plugin = require_adapter { command = "mocha" }

  async.it("provides meaningful names from a basic spec", function()
    local expected_output = basic_test_positions
    local positions = plugin.discover_positions("./test/specs/basic.test.js"):to_list()

    assert.equal(vim.inspect(expected_output), vim.inspect(positions))
  end)
end)

describe("build_spec", function()
  local tempname = neotest_async.fn.tempname

  before_each(function()
    ---@diagnostic disable-next-line: duplicate-set-field
    neotest_async.fn.tempname = function()
      return "tempname"
    end
  end)

  after_each(function()
    neotest_async.fn.tempname = tempname
  end)

  async.it("builds command for a file", function()
    local plugin = require_adapter { command = "mocha" }
    local tree = MockTree:new {
      {
        id = "./test/specs/basic.test.js",
        name = "basic.test.js",
        path = "./test/specs/basic.test.js",
        range = { 0, 0, 48, 0 },
        type = "file",
      },
    }
    local expected_command = {
      "mocha",
      "--full-trace",
      "--reporter=json",
      "--reporter-options=output=tempname.json",
      "--grep='.*'",
      "./test/specs/basic.test.js",
    }
    local expected_cwd = nil
    local expected_context = {
      results_path = "tempname.json",
      file = "./test/specs/basic.test.js",
    }
    local expected_strategy = nil
    local expected_env = {}

    local spec = plugin.build_spec { tree = tree }

    assert.is.truthy(spec)
    assert.equal(vim.inspect(expected_command), vim.inspect(spec.command))
    assert.equal(vim.inspect(expected_cwd), vim.inspect(spec.cwd))
    assert.equal(vim.inspect(expected_context), vim.inspect(spec.context))
    assert.equal(vim.inspect(expected_strategy), vim.inspect(spec.strategy))
    assert.equal(vim.inspect(expected_env), vim.inspect(spec.env))
  end)

  async.it("builds command for a namespace", function()
    local plugin = require_adapter { command = "mocha" }
    local tree = MockTree:new {
      {
        id = "./test/specs/basic.test.js::describe suite",
        name = "describe suite",
        path = "./test/specs/basic.test.js",
        range = { 4, 0, 24, 2 },
        type = "namespace",
      },
    }
    local expected_command = {
      "mocha",
      "--full-trace",
      "--reporter=json",
      "--reporter-options=output=tempname.json",
      "--grep='^describe suite'",
      "./test/specs/basic.test.js",
    }
    local expected_cwd = nil
    local expected_context = {
      results_path = "tempname.json",
      file = "./test/specs/basic.test.js",
    }
    local expected_strategy = nil
    local expected_env = {}

    local spec = plugin.build_spec { tree = tree }

    assert.is.truthy(spec)
    assert.equal(vim.inspect(expected_command), vim.inspect(spec.command))
    assert.equal(vim.inspect(expected_cwd), vim.inspect(spec.cwd))
    assert.equal(vim.inspect(expected_context), vim.inspect(spec.context))
    assert.equal(vim.inspect(expected_strategy), vim.inspect(spec.strategy))
    assert.equal(vim.inspect(expected_env), vim.inspect(spec.env))
  end)

  async.it("builds command for a test", function()
    local plugin = require_adapter { command = "mocha" }
    local tree = MockTree:new {
      {
        id = "./test/specs/basic.test.js::describe-suite::should pass",
        name = "should pass",
        path = "./test/specs/basic.test.js",
        range = { 5, 2, 8, 4 },
        type = "test",
      },
    }
    local expected_command = {
      "mocha",
      "--full-trace",
      "--reporter=json",
      "--reporter-options=output=tempname.json",
      "--grep='^describe\\-suite should pass$'",
      "./test/specs/basic.test.js",
    }
    local expected_cwd = nil
    local expected_context = {
      results_path = "tempname.json",
      file = "./test/specs/basic.test.js",
    }
    local expected_strategy = nil
    local expected_env = {}

    local spec = plugin.build_spec { tree = tree }

    assert.is.truthy(spec)
    assert.equal(vim.inspect(expected_command), vim.inspect(spec.command))
    assert.equal(vim.inspect(expected_cwd), vim.inspect(spec.cwd))
    assert.equal(vim.inspect(expected_context), vim.inspect(spec.context))
    assert.equal(vim.inspect(expected_strategy), vim.inspect(spec.strategy))
    assert.equal(vim.inspect(expected_env), vim.inspect(spec.env))
  end)

  async.it("builds command for a test with custom mocha arguments", function()
    local plugin = require_adapter {
      command = "mocha",
      command_args = function(context)
        return {
          "--bail",
          "--dry-run",
          "--reporter=spec",
          "--grep=" .. context.test_name_pattern,
          context.path,
        }
      end,
    }
    local tree = MockTree:new {
      {
        id = "./test/specs/basic.test.js::describe suite::should pass",
        name = "should pass",
        path = "./test/specs/basic.test.js",
        range = { 5, 2, 8, 4 },
        type = "test",
      },
    }
    local expected_command = {
      "mocha",
      "--bail",
      "--dry-run",
      "--reporter=spec",
      "--grep='^describe suite should pass$'",
      "./test/specs/basic.test.js",
    }
    local expected_cwd = nil
    local expected_context = {
      results_path = "tempname.json",
      file = "./test/specs/basic.test.js",
    }
    local expected_strategy = nil
    local expected_env = {}

    local spec = plugin.build_spec { tree = tree }

    assert.is.truthy(spec)
    assert.equal(vim.inspect(expected_command), vim.inspect(spec.command))
    assert.equal(vim.inspect(expected_cwd), vim.inspect(spec.cwd))
    assert.equal(vim.inspect(expected_context), vim.inspect(spec.context))
    assert.equal(vim.inspect(expected_strategy), vim.inspect(spec.strategy))
    assert.equal(vim.inspect(expected_env), vim.inspect(spec.env))
  end)

  async.it("builds command for a test with custom mocha arguments using test_name and fgrep", function()
    local plugin = require_adapter {
      command = "mocha",
      command_args = function(context)
        return {
          "--bail",
          "--dry-run",
          "--reporter=spec",
          "--fgrep=" .. context.test_name,
          context.path,
        }
      end,
    }
    local tree = MockTree:new {
      {
        id = "./test/specs/basic.test.js::describe suite::should pass",
        name = "should pass",
        path = "./test/specs/basic.test.js",
        range = { 5, 2, 8, 4 },
        type = "test",
      },
    }
    local expected_command = {
      "mocha",
      "--bail",
      "--dry-run",
      "--reporter=spec",
      "--fgrep='describe suite should pass'",
      "./test/specs/basic.test.js",
    }
    local expected_cwd = nil
    local expected_context = {
      results_path = "tempname.json",
      file = "./test/specs/basic.test.js",
    }
    local expected_strategy = nil
    local expected_env = {}

    local spec = plugin.build_spec { tree = tree }

    assert.is.truthy(spec)
    assert.equal(vim.inspect(expected_command), vim.inspect(spec.command))
    assert.equal(vim.inspect(expected_cwd), vim.inspect(spec.cwd))
    assert.equal(vim.inspect(expected_context), vim.inspect(spec.context))
    assert.equal(vim.inspect(expected_strategy), vim.inspect(spec.strategy))
    assert.equal(vim.inspect(expected_env), vim.inspect(spec.env))
  end)
end)

describe("results", function()
  async.it("return results from test output", function()
    local plugin = require_adapter { command = "mocha" }
    local spec = {
      context = {
        results_path = "./test/fixtures/basic_test_results.json",
      },
    }
    local result = { output = "output 1\noutput 2" }
    local tree = MockTree:new {
      {
        id = "./test/specs/basic.test.js::describe suite::should pass",
        name = "should pass",
        path = "./test/specs/basic.test.js",
        range = { 5, 2, 8, 4 },
        type = "test",
      },
      {
        id = "./test/specs/basic.test.js::describe suite::should fail",
        name = "should fail",
        path = "./test/specs/basic.test.js",
        range = { 10, 2, 13, 4 },
        type = "test",
      },
      {
        id = "./test/specs/basic.test.js::describe suite::should skip",
        name = "should skip",
        path = "./test/specs/basic.test.js",
        range = { 15, 2, 17, 4 },
        type = "test",
      },
    }
    local expected_results = {
      ["./test/specs/basic.test.js::describe suite::should fail"] = {
        errors = {
          {
            column = 11,
            line = 12,
            message = "The expression evaluated to a falsy value:\n\n  assert.ok(false)\n",
          },
        },
        output = "output 1\noutput 2",
        short = "should fail: failed\nThe expression evaluated to a falsy value:\n\n  assert.ok(false)\n",
        status = "failed",
      },
      ["./test/specs/basic.test.js::describe suite::should pass"] = {
        errors = {},
        output = "output 1\noutput 2",
        short = "should pass: passed",
        status = "passed",
      },
      ["./test/specs/basic.test.js::describe suite::should skip"] = {
        errors = {},
        output = "output 1\noutput 2",
        short = "should skip: skipped",
        status = "skipped",
      },
    }

    local results = plugin.results(spec, result, tree)

    assert.equal(vim.inspect(expected_results), vim.inspect(results))
  end)
end)
