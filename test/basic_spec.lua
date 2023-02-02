local async = require "plenary.async.tests"
local neotest_async = require "neotest.async"
local basic_test_positions = require "test.fixtures.basic_test_positions"
local MockTree = require "test.helpers.mock_tree"
local plugin = require "neotest-mocha" {
  mochaCommand = "mocha",
}
local util = require "neotest-mocha.util"

describe("is_test_file", function()
  local supported_extensions = { "js", "mjs", "cjs", "jsx", "coffee", "ts", "tsx" }

  it("matches mocha test files", function()
    -- by folder name.
    for _, extension in ipairs(supported_extensions) do
      assert.True(plugin.is_test_file("./test/basic." .. extension))
    end

    -- by file name.
    for _, extension in ipairs(supported_extensions) do
      assert.True(plugin.is_test_file("./src/basic.test." .. extension))
    end
  end)

  it("does not match non-test files", function()
    assert.False(plugin.is_test_file "./src/index.js")
  end)

  it("matches mocha test files with configurable test patterns", function()
    local intermediate_extensions = { "spec", "test", "lollipop" }
    local is_test_file = util.create_test_file_extensions_matcher(intermediate_extensions, supported_extensions)

    -- by folder name.
    for _, extension in ipairs(supported_extensions) do
      assert.True(is_test_file("./test/basic." .. extension))
    end

    -- by file name.
    for _, extension1 in ipairs(intermediate_extensions) do
      for _, extension2 in ipairs(supported_extensions) do
        assert.True(is_test_file("./src/basic." .. extension1 .. "." .. extension2))
      end
    end
  end)
end)

describe("discover_positions", function()
  async.it("provides meaningful names from a basic spec", function()
    local expected_output = basic_test_positions
    local positions = plugin.discover_positions("./test/specs/basic.test.js"):to_list()

    assert.equal(vim.inspect(expected_output), vim.inspect(positions))
  end)
end)

describe("build_spec", function()
  local tempname = neotest_async.fn.tempname

  before_each(function()
    neotest_async.fn.tempname = function()
      return "tempname"
    end
  end)

  after_each(function()
    neotest_async.fn.tempname = tempname
  end)

  async.it("builds command for a file", function()
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
      "--full-trace",
      "--reporter=json",
      "--reporter-options=output=tempname.json",
      "--grep='should pass$'",
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
