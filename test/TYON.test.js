const assert = require("assert");
const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");
const { TYON_V1_CONFIG } = require("../config/config");

const TYON_V1 = artifacts.require("TYON_V1");
//const TYON_V2 = artifacts.require("TYON_V2");

beforeEach(async () => {
  tyon = await TYON_V1.deployed();
});

contract("TYON_V1 TEST", (accounts) => {
  it("intialize only once", async () => {
    try {
      await tyon.initialize(
        TYON_V1_CONFIG._growthX,
        TYON_V1_CONFIG._tyonShield,
        TYON_V1_CONFIG._fundMe,
        TYON_V1_CONFIG._ecosystemGrowth
      );
      assert.fail("contract initialised again");
    } catch (error) {
      assert.strictEqual(
        error.message,
        "VM Exception while processing transaction: revert Initializable: contract is already initialized",
        "re initialize error message mismatch "
      );
    }
  });
  it("should return token initial call data", async () => {
    const name = await tyon.name();
    const symbol = await tyon.symbol();
    const decimal = await tyon.decimals();
    const totalSupply = await tyon.totalSupply();
    const tyonGrowthX = await tyon.tyonGrowthX();
    const tyonShield = await tyon.tyonShield();
    const tyonFundMe = await tyon.tyonFundMe();
    const tyonEcosystemGrowth = await tyon.tyonEcosystemGrowth();
    const _transferTaxfee = await tyon._transferTaxfee();
    const _buySellTaxFee = await tyon._buySellTaxFee();
    const _buySellEcosystemFee = await tyon._buySellEcosystemFee();
    const _transferEcosystemFee = await tyon._transferEcosystemFee();
    const _maxTxAmount = await tyon._maxTxAmount();
    const _minBuysellAmount = await tyon._minBuysellAmount();
    const ownerBadge = await tyon.getUserBadge(accounts[0]);
    const walletBadge = await tyon.getUserBadge(TYON_V1_CONFIG._growthX);

    const totalFees = await tyon.totalFees();
    //test for token data
    assert.equal(name, "TYON", "getting name failed");
    assert.equal(symbol, "TYON", "getting symbol failed");
    assert.equal(decimal, 9, "getting decimal failed");
    assert.equal(
      totalSupply,
      500000000 * 10 ** 6 * 10 ** 9,
      "getting total supply failed"
    );

    // test for wallet address
    assert.equal(
      tyonGrowthX,
      TYON_V1_CONFIG._growthX,
      "tyonGrowthX account error"
    );
    assert.equal(
      tyonShield,
      TYON_V1_CONFIG._tyonShield,
      "tyonShield account error"
    );
    assert.equal(
      tyonFundMe,
      TYON_V1_CONFIG._fundMe,
      "tyonFundMe account error"
    );
    assert.equal(
      tyonEcosystemGrowth,
      TYON_V1_CONFIG._ecosystemGrowth,
      "tyonEcosystemGrowth account error"
    );

    // fee values
    assert.equal(_transferTaxfee, 0, "_transferTaxfee tax fee error");
    assert.equal(_buySellTaxFee, 15, "_buySellTaxFee tax fee error");
    assert.equal(
      _buySellEcosystemFee,
      10,
      "_buySellEcosystemFee tax fee error"
    );
    assert.equal(
      _transferEcosystemFee,
      5,
      "_transferEcosystemFee tax fee error"
    );

    // tx amounts
    assert.equal(
      _maxTxAmount,
      5000000 * 10 ** 6 * 10 ** 9,
      "_maxTxAmount tax fee error"
    );
    assert.equal(_minBuysellAmount, 500 * 10 ** 9, "_minBuysellAmount error");

    // badge test
    assert.equal(ownerBadge, "MasterOfCoins", "owner badge error");
    assert.equal(walletBadge, "not Applicable", "wallet badge error");

    //total fees
    assert.equal(totalFees, 0, "totalFees error");
  });
  it("should equally distribute total supply between owner and growtX", async () => {
    const ownerBalance = await tyon.balanceOf(accounts[0]);
    const growthXBalance = await tyon.balanceOf(TYON_V1_CONFIG._growthX);
    const totalSupply = await tyon.totalSupply();
    assert.equal(ownerBalance, totalSupply / 2, "ownerBalance error");
    assert.equal(growthXBalance, totalSupply / 2, "growthXBalance error");
  });
  it("is pausable", async () => {
    let paused = await tyon.paused();
    assert.strictEqual(false, paused);
    await tyon.pause();
    paused = await tyon.paused();
    assert.ok(paused);
  });
  it("is unpausable", async () => {
    let paused = await tyon.paused();
    assert.strictEqual(true, paused);
    await tyon.unpause();
    paused = await tyon.paused();
    assert.ok(!paused);
  });
  it("fail if paused by anyone other than owner", async () => {
    try {
      let paused = await tyon.paused();
      assert.strictEqual(false, paused);
      await tyon.pause({ from: accounts[1] });
      paused = await tyon.paused();
      assert.ok(paused);
      assert.fail("pause test failed");
    } catch (error) {
      assert.strictEqual(
        error.message,
        "VM Exception while processing transaction: revert Ownable: caller is not the owner"
      );
    }
  });
});
