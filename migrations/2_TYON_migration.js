const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");
const TYON_V1 = artifacts.require("TYON_V1");
const { TYON_V1_CONFIG } = require("../config/config");

module.exports = async function (deployer, network, accounts) {
  let instance;

  instance = await deployProxy(
    TYON_V1,
    [
      TYON_V1_CONFIG._growthX,
      TYON_V1_CONFIG._tyrionShield,
      TYON_V1_CONFIG._fundMe,
      TYON_V1_CONFIG._ecosystemGrowth,
      TYON_V1_CONFIG._growthxWallet,
      TYON_V1_CONFIG._tyrionShieldWallet,
    ],
    { deployer }
  );

  //   await instance.transferOwnership(
  //     "0xcF872915E9187Ef676d8fFA83f9bc4E46b0293Cf"
  //   );
  //   const owner = await instance.owner();
  //   console.log("new owner:", owner);
};

// module.exports = async function (deployer) {
//   const upgraded = await upgradeProxy(instance.address, BoxV2, { deployer });
// };
