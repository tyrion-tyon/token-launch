const assert = require("assert");
const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");

const TYON_V1 = artifacts.require("TYON_V1");
//const TYON_V2 = artifacts.require("TYON_V2");

beforeEach(async () => {
  tyon = await TYON_V1.deployed();
});

contract("TYON_V1 TEST", () => {
  it("should return token initial call data", async () => {
    const name = await tyon.name();
    const symbol = await tyon.symbol();
    const decimal = await tyon.decimals();
    const totalSupply = await tyon.totalSupply();
    assert.equal(name, "TYON", "getting name failed");
    assert.equal(symbol, "TYON", "getting symbol failed");
    assert.equal(decimal, 9, "getting decimal failed");
    assert.equal(
      totalSupply,
      500000000 * 10 ** 6 * 10 ** 9,
      "getting total supply failed"
    );
  });
});
