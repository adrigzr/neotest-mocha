# neotest-mocha

[![build](https://github.com/adrigzr/neotest-mocha/actions/workflows/workflow.yaml/badge.svg)](https://github.com/adrigzr/neotest-mocha/actions/workflows/workflow.yaml)

This plugin provides a [Mocha](https://github.com/mochajs/mocha) adapter for the [Neotest](https://github.com/rcarriga/neotest) framework. Requires at least Neotest version 4.0.0 which in turn requires at least neovim version 0.9.0.

**It is currently a work in progress**. It will be transferred to the official neotest organisation (once it's been created).

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
