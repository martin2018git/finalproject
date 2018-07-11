var SupplyChain = artifacts.require("../contracts/SupplyChain.sol");

module.exports = function(deployer) {
  deployer.deploy(SupplyChain);
};
