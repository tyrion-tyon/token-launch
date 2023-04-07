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
        TYON_V1_CONFIG._tyrionShield,
        TYON_V1_CONFIG._fundMe,
        TYON_V1_CONFIG._ecosystemGrowth,
        TYON_V1_CONFIG._growthxWallet,
        TYON_V1_CONFIG._tyrionShieldWallet
      );
      assert.fail("contract initialised again");
    } catch (error) {
      assert.strictEqual(
        error.message,
        "VM Exception while processing transaction: revert Initializable: contract is already initialized -- Reason given: Initializable: contract is already initialized.",
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
    const tyrionShield = await tyon.tyrionShield();
    const tyonFundMe = await tyon.tyonFundMe();
    const tyonEcosystemGrowth = await tyon.tyonEcosystemGrowth();
    const growthXWallet = await tyon.walletGrowthX();
    const tyrionShieldWallet = await tyon.walletTyrionShiled();
    const _transferTaxfee = await tyon._transferTaxfee();
    const _buySellTaxFee = await tyon._buySellTaxFee();
    const _buySellEcosystemFee = await tyon._buySellEcosystemFee();
    const _transferEcosystemFee = await tyon._transferEcosystemFee();
    const _maxTxAmount = await tyon._maxTxAmount();
    const _minBuysellAmount = await tyon._minBuysellAmount();
    const ownerBadge = await tyon.getUserBadge(accounts[0]);
    const walletBadge = await tyon.getUserBadge(TYON_V1_CONFIG._growthxWallet);

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
      tyrionShield,
      TYON_V1_CONFIG._tyrionShield,
      "tyrionShield account error"
    );
    assert.equal(
      growthXWallet,
      TYON_V1_CONFIG._growthxWallet,
      "growthX wallet account error"
    );
    assert.equal(
      tyrionShieldWallet,
      TYON_V1_CONFIG._tyrionShieldWallet,
      "tyrion wallet account error"
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
    assert.equal(walletBadge, "not_applicable", "wallet badge error");

    //total fees
    assert.equal(totalFees, 0, "totalFees error");
  });
  it("should distribute total supply between owner and growthX and tyrion shield", async () => {
    const ownerBalance = await tyon.balanceOf(accounts[0]);
    const growthXBalance = await tyon.balanceOf(TYON_V1_CONFIG._growthxWallet);
    const tyrionShield = await tyon.balanceOf(
      TYON_V1_CONFIG._tyrionShieldWallet
    );
    const totalSupply = await tyon.totalSupply();
    assert.equal(ownerBalance, (totalSupply * 53) / 100, "ownerBalance error");
    assert.equal(growthXBalance, (totalSupply * 2) / 5, "growthXBalance error");
    assert.equal(tyrionShield, (totalSupply * 7) / 100, "growthXBalance error");
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
        "VM Exception while processing transaction: revert Ownable: caller is not the owner -- Reason given: Ownable: caller is not the owner."
      );
    }
  });
  it("allow owner to transfer token without deductinge ecosystem fee", async () => {
    await tyon.transfer(accounts[1], web3.utils.toWei("1000", "gwei"));
    const ownerBalance = await tyon.balanceOf(accounts[0]);
    const user1Balance = await tyon.balanceOf(accounts[1]);
    assert.equal(web3.utils.fromWei(ownerBalance, "gwei"), 264999000);
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
    const tyonShieldBalance = await tyon.balanceOf(
      TYON_V1_CONFIG._tyrionShield
    );
    assert.equal(web3.utils.fromWei(ecosystemGrowthBalance, "gwei"), 0.1875);
    assert.equal(web3.utils.fromWei(fundMeBalance, "gwei"), 0.1875);
    assert.equal(web3.utils.fromWei(growthXBalance, "gwei"), 0.1875);
    assert.equal(web3.utils.fromWei(tyonShieldBalance, "gwei"), 0.1875);
  });
  it("allows user to transfer token to a fee excluded account without deducting ecosystem fee", async () => {
    await tyon.transfer(accounts[0], web3.utils.toWei("100", "gwei"), {
      from: accounts[1],
    });
    const ownerBalance = await tyon.balanceOf(accounts[0]);
    const user1Balance = await tyon.balanceOf(accounts[1]);
    assert.equal(web3.utils.fromWei(user1Balance, "gwei"), 849.75);
    assert.equal(web3.utils.fromWei(ownerBalance, "gwei"), 264999100);
  });
  it("allows owner to set Liquid Pool address", async () => {
    await tyon.setLPAddress(accounts[9]);
    assert.ok(true);
  });
  it("allows user to transfer token to LP with deducting fee and tax", async () => {
    await tyon.transfer(accounts[9], web3.utils.toWei("600", "gwei"), {
      from: accounts[1],
    });
    const user1Balance = await tyon.balanceOf(accounts[1]);
    const LPBalance = await tyon.balanceOf(accounts[9]);

    assert.equal(web3.utils.fromWei(user1Balance, "gwei"), 252.272727272); // balance includes reflection
    assert.equal(web3.utils.fromWei(LPBalance, "gwei"), 590.909090909);
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
        "VM Exception while processing transaction: revert transfer amount should be greater than minBuysellAmount -- Reason given: transfer amount should be greater than minBuysellAmount."
      );
    }
  });
  it("allows user to buy token from LP with deducting fee and tax", async () => {
    await tyon.transfer(accounts[2], web3.utils.toWei("550", "gwei"), {
      from: accounts[9],
    });
    const user2Balance = await tyon.balanceOf(accounts[2]);
    const LPBalance = await tyon.balanceOf(accounts[9]);
    assert.equal(web3.utils.fromWei(user2Balance, "gwei"), 591.673675357); // balance includes reflection
    assert.equal(web3.utils.fromWei(LPBalance, "gwei"), 41.287560211);
  });
  it("allows user to sell token to LP with deducting fee and tax", async () => {
    await tyon.transfer(accounts[9], web3.utils.toWei("500", "gwei"), {
      from: accounts[2],
    });
    const user2Balance = await tyon.balanceOf(accounts[2]);
    const LPBalance = await tyon.balanceOf(accounts[9]);
    assert.equal(web3.utils.fromWei(user2Balance, "gwei"), 92.444042377); // balance includes reflection
    assert.equal(web3.utils.fromWei(LPBalance, "gwei"), 533.231153153);
  });
  it("assign all holders with badge", async () => {
    const holdersBadge = await tyon.getUserBadge(accounts[2]);
    const nonHoldersBadge = await tyon.getUserBadge(accounts[4]);
    assert.equal(holdersBadge, "MasterOfCoins");
    assert.equal(nonHoldersBadge, "not_applicable");
  });
  it("allows owner to set sale phase", async () => {
    const phase = await tyon.setCurrentPhase(2);
    const salePhase = await tyon.salePhase();
    assert.equal(salePhase.toString(), 2);
  });
  it("assign all holders with badge according to sale phase", async () => {
    const holdersBadge = await tyon.getUserBadge(accounts[2]);
    const nonHoldersBadge = await tyon.getUserBadge(accounts[3]);
    await tyon.transfer(accounts[3], 1000);
    const updatedBadge = await tyon.getUserBadge(accounts[3]);
    assert.equal(holdersBadge, "MasterOfCoins");
    assert.equal(nonHoldersBadge, "not_applicable");
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
        `VM Exception while processing transaction: revert AccessControl: account ${accounts[2].toLowerCase()} is missing role ${BADGE_MANAGER} -- Reason given: AccessControl: account ${accounts[2].toLowerCase()} is missing role ${BADGE_MANAGER}.`
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
        "VM Exception while processing transaction: revert Ownable: caller is not the owner -- Reason given: Ownable: caller is not the owner."
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
        "VM Exception while processing transaction: revert invalid phase -- Reason given: invalid phase."
      );
    }
  });
  it("allows owner to set _maxTxAmount", async () => {
    await tyon.setMaxTxPercent(10);
    const _maxTxAmount = await tyon._maxTxAmount();
    assert.equal(web3.utils.fromWei(_maxTxAmount, "gwei"), 50000000);
  });
  it("allows owner to set setEcosystemFeePercent", async () => {
    await tyon.setEcosystemFeePercent(20, 50);
    const _transferEcosystemFee = await tyon._transferEcosystemFee();
    const _buySellEcosystemFee = await tyon._buySellEcosystemFee();
    assert.equal(_transferEcosystemFee, 50);
    assert.equal(_buySellEcosystemFee, 20);
  });
  it("allows owner to set setTaxFeePercent", async () => {
    await tyon.setTaxFeePercent(10, 20);
    const _transferTaxfee = await tyon._transferTaxfee();
    const _buySellTaxFee = await tyon._buySellTaxFee();
    assert.equal(_transferTaxfee, 10);
    assert.equal(_buySellTaxFee, 20);
  });
  it("allows owner to set min buy sell amount", async () => {
    await tyon.setMinBuySellAmount(2000);
    const minBuySell = await tyon._minBuysellAmount();
    assert.equal(minBuySell, web3.utils.toWei("2000", "gwei"));
  });
  it("owner can grant new TAX MANAGER role", async () => {
    const TAX_MANAGER = await tyon.TAX_MANAGER();
    const hasRoleFalse = await tyon.hasRole(TAX_MANAGER, accounts[3]);
    await tyon.grantRole(TAX_MANAGER, accounts[3]);
    const hasRoleTrue = await tyon.hasRole(TAX_MANAGER, accounts[3]);
    assert.equal(hasRoleFalse, false);
    assert.equal(hasRoleTrue, true);
  });
  it("allows TAX_MANAGER to change ecosystem fee", async () => {
    await tyon.setEcosystemFeePercent(10, 5, {
      from: accounts[3],
    });
    const _transferEcosystemFee = await tyon._transferEcosystemFee();
    const _buySellEcosystemFee = await tyon._buySellEcosystemFee();
    assert.equal(_transferEcosystemFee, 5);
    assert.equal(_buySellEcosystemFee, 10);
  });
  it("allows TAX_MANAGER to change tax fee", async () => {
    await tyon.setTaxFeePercent(0, 15, {
      from: accounts[3],
    });
    const _transferTaxfee = await tyon._transferTaxfee();
    const _buySellTaxFee = await tyon._buySellTaxFee();
    assert.equal(_transferTaxfee, 0);
    assert.equal(_buySellTaxFee, 15);
  });
  it("fail if setTaxFeePercent by anyone other than TAX MANAGER", async () => {
    const TAX_MANAGER = await tyon.TAX_MANAGER();
    try {
      await tyon.setTaxFeePercent(0, 15, {
        from: accounts[2],
      });
      assert.fail("setBadge test failed");
    } catch (error) {
      assert.strictEqual(
        error.message,
        `VM Exception while processing transaction: revert AccessControl: account ${accounts[2].toLowerCase()} is missing role ${TAX_MANAGER} -- Reason given: AccessControl: account ${accounts[2].toLowerCase()} is missing role ${TAX_MANAGER}.`
      );
    }
  });
  it("allows to calculate tokensFrom reflection and reflection from token ", async () => {
    const ref = await tyon.reflectionFromToken(100000000000, false);
    const token = await tyon.tokenFromReflection(ref);
    assert.equal(token.toString(), 100000000000);
  });
  it("allows spender to transfer allowed token and icrease or decrease allowance", async () => {
    await tyon.approve(accounts[3], web3.utils.toWei("10", "gwei"), {
      from: accounts[2],
    });
    const allowance1 = await tyon.allowance(accounts[2], accounts[3]);
    await tyon.increaseAllowance(accounts[3], web3.utils.toWei("10", "gwei"), {
      from: accounts[2],
    });
    const allowance2 = await tyon.allowance(accounts[2], accounts[3]);
    await tyon.decreaseAllowance(accounts[3], web3.utils.toWei("10", "gwei"), {
      from: accounts[2],
    });
    const allowance3 = await tyon.allowance(accounts[2], accounts[3]);
    await tyon.transferFrom(
      accounts[2],
      accounts[4],
      web3.utils.toWei("10", "gwei"),
      {
        from: accounts[3],
      }
    );
    const user4Balance = await tyon.balanceOf(accounts[4]);
    assert.equal(allowance1, web3.utils.toWei("10", "gwei"));
    assert.equal(allowance2, web3.utils.toWei("20", "gwei"));
    assert.equal(allowance3, web3.utils.toWei("10", "gwei"));
    assert.equal(user4Balance.toString(), 9950000000);
  });
  it("allows transfer token from a reward excluded account to a reward excluded without deducting any fee", async () => {
    await tyon.transfer(
      TYON_V1_CONFIG._growthxWallet,
      web3.utils.toWei("1000", "gwei"),
      {
        from: accounts[0],
      }
    );
    const ownerBalance = await tyon.balanceOf(accounts[0]);
    const growthXWalletBalance = await tyon.balanceOf(
      TYON_V1_CONFIG._growthxWallet
    );
    assert.equal(web3.utils.fromWei(growthXWalletBalance, "gwei"), 200001000);
    assert.equal(web3.utils.fromWei(ownerBalance, "gwei"), 264998099.999999);
  });
  it("allows owner to withdraw locked token", async () => {
    await tyon.transfer(tyon.address, web3.utils.toWei("1000", "gwei"));
    const ownerBalanceBefore = await tyon.balanceOf(accounts[0]);
    await tyon.withdrawToken(web3.utils.toWei("1000", "gwei"), tyon.address);
    const ownerBalanceAfter = await tyon.balanceOf(accounts[0]);
    assert.equal(
      web3.utils.toWei("1000", "gwei"),
      ownerBalanceAfter - ownerBalanceBefore
    );
  });
  it("accept ETH", async () => {
    try {
      await web3.eth.sendTransaction({
        from: accounts[9],
        to: tyon.address,
        value: "10",
      });
      assert.ok(true);
    } catch (error) {
      console.log(error);
      assert.fail("can't recieve ETH");
    }
  });
  it("allows owner to withdraw ETH", async () => {
    const balance1 = await web3.eth.getBalance(tyon.address);
    await tyon.withdraw();
    const balance2 = await web3.eth.getBalance(tyon.address);
    assert.equal(balance1, 10);
    assert.equal(balance2, 0);
  });
  it("allows calculating totalFees collected", async () => {
    const fee = await tyon.totalFees();
    assert.equal(fee, 24750000000);
  });

  it("allows owner to exclude account from reward", async () => {
    const isExcluded1 = await tyon.isExcludedFromReward(accounts[1]);
    const balance1 = await tyon.balanceOf(accounts[1]);
    await tyon.excludeFromReward(accounts[1]);
    const isExcluded2 = await tyon.isExcludedFromReward(accounts[1]);
    const balance2 = await tyon.balanceOf(accounts[1]);
    await tyon.includeInReward(accounts[1]);
    const isExcluded3 = await tyon.isExcludedFromReward(accounts[1]);
    const balance3 = await tyon.balanceOf(accounts[1]);
    assert.equal(isExcluded1, false);
    assert.equal(isExcluded2, true);
    assert.equal(isExcluded3, false);
    assert.equal(balance2.toString(), balance1.toString());
    assert.equal(balance3.toString(), balance2.toString());
  });

  it("allows owner to change txFee and it will reflect on transaction", async () => {
    await tyon.transfer(accounts[3], web3.utils.toWei("10", "gwei"), {
      from: accounts[2],
    });
    const account2Balance1 = await tyon.balanceOf(accounts[2]);
    const account3Balance1 = await tyon.balanceOf(accounts[3]);
    await tyon.setTaxFeePercent(10, 20);
    await tyon.transfer(accounts[3], web3.utils.toWei("10", "gwei"), {
      from: accounts[2],
    });
    const account2Balance2 = await tyon.balanceOf(accounts[2]);
    const account3Balance2 = await tyon.balanceOf(accounts[3]);
    assert.equal(account2Balance1.toString(), 72444042377);
    assert.equal(account3Balance1.toString(), 9950001000);
    assert.equal(account2Balance2.toString(), 62450981375);
    assert.equal(account3Balance2.toString(), 19802201244); // credited 9852200244 (9.85 TYON + Reflection)
  });
});
