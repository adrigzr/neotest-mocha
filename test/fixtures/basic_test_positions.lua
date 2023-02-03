return {
  {
    id = "./test/specs/basic.test.js",
    name = "basic.test.js",
    path = "./test/specs/basic.test.js",
    range = { 0, 0, 69, 0 },
    type = "file",
  },
  {
    {
      id = "./test/specs/basic.test.js::describe suite",
      name = "describe suite",
      path = "./test/specs/basic.test.js",
      range = { 4, 0, 24, 2 },
      type = "namespace",
    },
    {
      {
        id = "./test/specs/basic.test.js::describe suite::should pass",
        name = "should pass",
        path = "./test/specs/basic.test.js",
        range = { 5, 2, 8, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::describe suite::should fail",
        name = "should fail",
        path = "./test/specs/basic.test.js",
        range = { 10, 2, 13, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::describe suite::should skip",
        name = "should skip",
        path = "./test/specs/basic.test.js",
        range = { 15, 2, 17, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::describe suite::nested suite",
        name = "nested suite",
        path = "./test/specs/basic.test.js",
        range = { 19, 2, 23, 4 },
        type = "namespace",
      },
      {
        {
          id = "./test/specs/basic.test.js::describe suite::nested suite::should pass",
          name = "should pass",
          path = "./test/specs/basic.test.js",
          range = { 20, 4, 22, 6 },
          type = "test",
        },
      },
    },
  },
  {
    {
      id = "./test/specs/basic.test.js::function suite",
      name = "function suite",
      path = "./test/specs/basic.test.js",
      range = { 26, 0, 46, 2 },
      type = "namespace",
    },
    {
      {
        id = "./test/specs/basic.test.js::function suite::should pass",
        name = "should pass",
        path = "./test/specs/basic.test.js",
        range = { 27, 2, 30, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::function suite::should fail",
        name = "should fail",
        path = "./test/specs/basic.test.js",
        range = { 32, 2, 35, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::function suite::should skip",
        name = "should skip",
        path = "./test/specs/basic.test.js",
        range = { 37, 2, 39, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::function suite::nested suite",
        name = "nested suite",
        path = "./test/specs/basic.test.js",
        range = { 41, 2, 45, 4 },
        type = "namespace",
      },
      {
        {
          id = "./test/specs/basic.test.js::function suite::nested suite::should pass",
          name = "should pass",
          path = "./test/specs/basic.test.js",
          range = { 42, 4, 44, 6 },
          type = "test",
        },
      },
    },
  },
  {
    {
      id = "./test/specs/basic.test.js::context suite",
      name = "context suite",
      path = "./test/specs/basic.test.js",
      range = { 48, 0, 68, 2 },
      type = "namespace",
    },
    {
      {
        id = "./test/specs/basic.test.js::context suite::should pass",
        name = "should pass",
        path = "./test/specs/basic.test.js",
        range = { 49, 2, 52, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::context suite::should fail",
        name = "should fail",
        path = "./test/specs/basic.test.js",
        range = { 54, 2, 57, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::context suite::should skip",
        name = "should skip",
        path = "./test/specs/basic.test.js",
        range = { 59, 2, 61, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::context suite::nested suite",
        name = "nested suite",
        path = "./test/specs/basic.test.js",
        range = { 63, 2, 67, 4 },
        type = "namespace",
      },
      {
        {
          id = "./test/specs/basic.test.js::context suite::nested suite::should pass",
          name = "should pass",
          path = "./test/specs/basic.test.js",
          range = { 64, 4, 66, 6 },
          type = "test",
        },
      },
    },
  },
}
