const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");
const TYON_V1 = artifacts.require("TYON_V1");
const { TYON_V1_CONFIG } = require("../config/config");

module.exports = async function (deployer) {
  const instance = await deployProxy(
    TYON_V1,
    [
      TYON_V1_CONFIG._growthX,
      TYON_V1_CONFIG._tyonShield,
      TYON_V1_CONFIG._fundMe,
      TYON_V1_CONFIG._ecosystemGrowth,
    ],
    { deployer }
  );
};

// module.exports = async function (deployer) {
//   const upgraded = await upgradeProxy(instance.address, BoxV2, { deployer });
// };
