return {
  {
    id = "./test/specs/basic.test.js",
    name = "basic.test.js",
    path = "./test/specs/basic.test.js",
    range = { 0, 0, 48, 0 },
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
      id = "./test/specs/basic.test.js::context suite",
      name = "context suite",
      path = "./test/specs/basic.test.js",
      range = { 27, 0, 47, 2 },
      type = "namespace",
    },
    {
      {
        id = "./test/specs/basic.test.js::context suite::should pass",
        name = "should pass",
        path = "./test/specs/basic.test.js",
        range = { 28, 2, 31, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::context suite::should fail",
        name = "should fail",
        path = "./test/specs/basic.test.js",
        range = { 33, 2, 36, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::context suite::should skip",
        name = "should skip",
        path = "./test/specs/basic.test.js",
        range = { 38, 2, 40, 4 },
        type = "test",
      },
    },
    {
      {
        id = "./test/specs/basic.test.js::context suite::nested suite",
        name = "nested suite",
        path = "./test/specs/basic.test.js",
        range = { 42, 2, 46, 4 },
        type = "namespace",
      },
      {
        {
          id = "./test/specs/basic.test.js::context suite::nested suite::should pass",
          name = "should pass",
          path = "./test/specs/basic.test.js",
          range = { 43, 4, 45, 6 },
          type = "test",
        },
      },
    },
  },
}
