require("mocha");

const assert = require("assert");

describe("describe suite", () => {
  it("should pass", () => {
    console.log("it should pass");
    assert.ok(true);
  });

  it("should fail", () => {
    console.log("it should fail");
    assert.ok(false);
  });

  it.skip("should skip", () => {
    // noop
  });

  describe("nested suite", () => {
    it("should pass", () => {
      assert.ok(true);
    });
  })
});


context("context suite", () => {
  specify("should pass", () => {
    console.log("it should pass");
    assert.ok(true);
  });

  specify("should fail", () => {
    console.log("it should fail");
    assert.ok(false);
  });

  specify.skip("should skip", () => {
    // noop
  });

  context("nested suite", () => {
    specify("should pass", () => {
      assert.ok(true);
    });
  })
});
