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
      500000000 * 10 ** 9,
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
    assert.equal(_maxTxAmount, 5000000 * 10 ** 9, "_maxTxAmount tax fee error");
    assert.equal(_minBuysellAmount, 500 * 10 ** 9, "_minBuysellAmount error");

    // badge test
    assert.equal(ownerBadge, "MasterOfCoins", "owner badge error");
    assert.equal(walletBadge, "not Applicable", "wallet badge error");

    //total fees
    assert.equal(totalFees, 0, "totalFees error");
  });
  it("should equally distribute total supply between owner and growthX", async () => {
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
  it("allow owner to transfer token without deductinge cosystem fee", async () => {
    await tyon.transfer(accounts[1], web3.utils.toWei("1000", "gwei"));
    const ownerBalance = await tyon.balanceOf(accounts[0]);
    const user1Balance = await tyon.balanceOf(accounts[1]);
    assert.equal(web3.utils.fromWei(ownerBalance, "gwei"), 249999000);
    assert.equal(web3.utils.fromWei(user1Balance, "gwei"), 1000);
  });
  it("allows user to user transfer with deducting ecosystem fee", async () => {
    await tyon.transfer(accounts[2], web3.utils.toWei("100", "gwei"), {
      from: accounts[1],
    });
    await tyon.transfer(accounts[1], web3.utils.toWei("50", "gwei"), {
      from: accounts[2],
    });
    const user2Balance = await tyon.balanceOf(accounts[2]);
    const user1Balance = await tyon.balanceOf(accounts[1]);
    assert.equal(web3.utils.fromWei(user1Balance, "gwei"), 949.75);
    assert.equal(web3.utils.fromWei(user2Balance, "gwei"), 49.5);
  });
  it("transfers all deducted fees to Ecosystem wallets", async () => {
    const ecosystemGrowthBalance = await tyon.balanceOf(
      TYON_V1_CONFIG._ecosystemGrowth
    );
    const fundMeBalance = await tyon.balanceOf(TYON_V1_CONFIG._fundMe);
    const growthXBalance = await tyon.balanceOf(TYON_V1_CONFIG._growthX);
    const tyonShieldBalance = await tyon.balanceOf(TYON_V1_CONFIG._tyonShield);
    assert.equal(web3.utils.fromWei(ecosystemGrowthBalance, "gwei"), 0.1875);
    assert.equal(web3.utils.fromWei(fundMeBalance, "gwei"), 0.1875);
    assert.equal(web3.utils.fromWei(growthXBalance, "gwei"), 250000000.1875);
    assert.equal(web3.utils.fromWei(tyonShieldBalance, "gwei"), 0.1875);
  });
  it("allows user to transfer token to a fee excluded account without deducting ecosystem fee", async () => {
    await tyon.transfer(accounts[0], web3.utils.toWei("100", "gwei"), {
      from: accounts[1],
    });
    const ownerBalance = await tyon.balanceOf(accounts[0]);
    const user1Balance = await tyon.balanceOf(accounts[1]);
    assert.equal(web3.utils.fromWei(user1Balance, "gwei"), 849.75);
    assert.equal(web3.utils.fromWei(ownerBalance, "gwei"), 249999100);
  });
  it("allows ownerto set Liquid Pool address", async () => {
    await tyon.setLPAddress(accounts[9]);
    assert.ok(true);
  });
  it("allows user to transfer token to LP with deducting fee and tax", async () => {
    await tyon.transfer(accounts[9], web3.utils.toWei("600", "gwei"), {
      from: accounts[1],
    });
    const user1Balance = await tyon.balanceOf(accounts[1]);
    const LPBalance = await tyon.balanceOf(accounts[9]);

    assert.equal(web3.utils.fromWei(user1Balance, "gwei"), 252.277514231); // balance includes reflection
    assert.equal(web3.utils.fromWei(LPBalance, "gwei"), 590.920303605);
  });
  it("fail if transfer/sell amount is less than minBuysellAmount", async () => {
    try {
      await tyon.transfer(accounts[9], web3.utils.toWei("10", "gwei"), {
        from: accounts[1],
      });
      assert.fail("minBuysellAmount transfer test failed");
    } catch (error) {
      assert.strictEqual(
        error.message,
        "VM Exception while processing transaction: revert transfer amount should be greater than minBuysellAmount"
      );
    }
  });
  it("allows user to buy token from LP with deducting fee and tax", async () => {
    await tyon.transfer(accounts[2], web3.utils.toWei("550", "gwei"), {
      from: accounts[9],
    });
    const user2Balance = await tyon.balanceOf(accounts[2]);
    const LPBalance = await tyon.balanceOf(accounts[9]);
    assert.equal(web3.utils.fromWei(user2Balance, "gwei"), 591.693323422); // balance includes reflection
    assert.equal(web3.utils.fromWei(LPBalance, "gwei"), 41.300181239);
  });
  it("allows user to sell token to LP with deducting fee and tax", async () => {
    await tyon.transfer(accounts[9], web3.utils.toWei("500", "gwei"), {
      from: accounts[2],
    });
    const user2Balance = await tyon.balanceOf(accounts[2]);
    const LPBalance = await tyon.balanceOf(accounts[9]);
    assert.equal(web3.utils.fromWei(user2Balance, "gwei"), 92.467596789); // balance includes reflection
    assert.equal(web3.utils.fromWei(LPBalance, "gwei"), 533.265456149);
  });
  it("assign all holders with badge", async () => {
    const holdersBadge = await tyon.getUserBadge(accounts[2]);
    const nonHoldersBadge = await tyon.getUserBadge(accounts[4]);
    assert.equal(holdersBadge, "MasterOfCoins");
    assert.equal(nonHoldersBadge, "not Applicable");
  });
  it("allows owner to set sale phase", async () => {
    const phase = await tyon.setCurrentPhase(2);
    const event = phase.logs.find((obj) => obj.event == "SalePhaseUpdated");
    const { salePhase } = event.args;
    assert.equal(salePhase, 2);
  });
  it("assign all holders with badge according to sale phase", async () => {
    const holdersBadge = await tyon.getUserBadge(accounts[2]);
    const nonHoldersBadge = await tyon.getUserBadge(accounts[3]);
    await tyon.transfer(accounts[3], 1000);
    const updatedBadge = await tyon.getUserBadge(accounts[3]);
    assert.equal(holdersBadge, "MasterOfCoins");
    assert.equal(nonHoldersBadge, "not Applicable");
    assert.equal(updatedBadge, "Pods&Bronns");
  });
  it("allows owner to change holders badge", async () => {
    const holdersBadge = await tyon.getUserBadge(accounts[3]);
    await tyon.setBadge(accounts[3], 3);
    const updatedBadge = await tyon.getUserBadge(accounts[3]);
    assert.equal(holdersBadge, "Pods&Bronns");
    assert.equal(updatedBadge, "Sommeliers");
  });
  it("owner can grant new BADGE MANAGER role", async () => {
    const BADGE_MANAGER = await tyon.BADGE_MANAGER();
    const hasRoleFalse = await tyon.hasRole(BADGE_MANAGER, accounts[1]);
    await tyon.grantRole(BADGE_MANAGER, accounts[1]);
    const hasRoleTrue = await tyon.hasRole(BADGE_MANAGER, accounts[1]);
    assert.equal(hasRoleFalse, false);
    assert.equal(hasRoleTrue, true);
  });
  it("allows BADGE MANAGER to change holders badge", async () => {
    const holdersBadge = await tyon.getUserBadge(accounts[3]);
    await tyon.setBadge(accounts[3], 2, { from: accounts[1] });
    const updatedBadge = await tyon.getUserBadge(accounts[3]);
    assert.equal(updatedBadge, "Pods&Bronns");
    assert.equal(holdersBadge, "Sommeliers");
  });
  it("fail if setBadge by anyone other than BADGE MANAGER", async () => {
    const BADGE_MANAGER = await tyon.BADGE_MANAGER();
    try {
      await tyon.setBadge(accounts[3], 2, { from: accounts[2] });
      assert.fail("setBadge test failed");
    } catch (error) {
      assert.strictEqual(
        error.message,
        `VM Exception while processing transaction: revert AccessControl: account ${accounts[2].toLowerCase()} is missing role ${BADGE_MANAGER}`
      );
    }
  });
  it("fail if setCurrentPhase by anyone other than owner", async () => {
    try {
      await tyon.setCurrentPhase(2, { from: accounts[1] });
      assert.fail("setCurrentPhase test failed");
    } catch (error) {
      assert.strictEqual(
        error.message,
        "VM Exception while processing transaction: revert Ownable: caller is not the owner"
      );
    }
  });
  it("fail if owner set invalid phase", async () => {
    try {
      await tyon.setCurrentPhase(7);
      assert.fail("setCurrentPhase test failed");
    } catch (error) {
      assert.strictEqual(
        error.message,
        "VM Exception while processing transaction: revert invalid phase"
      );
    }
  });
  it("allows owner to set _maxTxAmount", async () => {
    await tyon.setMaxTxPercent(10);
    const _maxTxAmount = await tyon._maxTxAmount();
    assert.equal(web3.utils.fromWei(_maxTxAmount, "gwei"), 50000000);
  });
});
