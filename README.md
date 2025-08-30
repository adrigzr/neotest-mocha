# neotest-mocha

[![build](https://github.com/adrigzr/neotest-mocha/actions/workflows/workflow.yaml/badge.svg)](https://github.com/adrigzr/neotest-mocha/actions/workflows/workflow.yaml)

This plugin provides a [Mocha](https://github.com/mochajs/mocha) adapter for the [Neotest](https://github.com/rcarriga/neotest) framework.

**It is currently a work in progress**. It will be transferred to the official neotest organisation (once it's been created).

## Requirements

* At least Neotest version 4.0.0 which in turn requires at least neovim version 0.9.0.
* At least mocha v9.1.0.

## Installation

Using packer:

```lua
use({
  'nvim-neotest/neotest',
  requires = {
    ...,
    'adrigzr/neotest-mocha',
  }
  config = function()
    require('neotest').setup({
      ...,
      adapters = {
        require('neotest-mocha')({
          command = "npm test --",
          command_args = function(context)
            -- The context contains:
            --   results_path: The file that json results are written to
            --   test_name: The exact name of the test; is empty for `file` and `dir` position tests.
            --   test_name_pattern: The generated pattern for the test
            --   path: The path to the test file
            --
            -- It should return a string array of arguments
            --
            -- Not specifying 'command_args' will use the defaults below
            return {
                "--full-trace",
                "--reporter=json",
                "--reporter-options=output=" .. context.results_path,
                "--grep=" .. context.test_name_pattern,
                context.path,
            }
          end,
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        }),
      }
    })
  end
})
```

## Usage

See neotest's documentation for more information on how to run tests.

## :gift: Contributing

Please raise a PR if you are interested in adding new functionality or fixing any bugs. When submitting a bug, please include an example spec that can be tested.

To trigger the tests for the adapter, run:

```sh
./scripts/test
```

## Bug Reports

Please file any bug reports and I _might_ take a look if time permits otherwise please submit a PR, this plugin is intended to be by the community for the community.

## Inspiration

Thanks to [haydenmeade](https://github.com/haydenmeade) and all the contributors from [neotest-jest](https://github.com/haydenmeade/neotest-jest) for doing the hard work.
