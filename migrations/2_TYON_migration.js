const TYON_V1 = artifacts.require("TYON_V1");
const { TYON_V1_CONFIG } = require("../config/config");

module.exports = function (deployer) {
  deployer.deploy(
    TYON_V1,
    TYON_V1_CONFIG._growthX,
    TYON_V1_CONFIG._tyonShield,
    TYON_V1_CONFIG._fundMe,
    TYON_V1_CONFIG._ecosystemGrowth
  );
};
