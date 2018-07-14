var Property = artifacts.require("../contracts/Property.sol");
var Investors = artifacts.require("../contracts/Investors.sol");
//var PropertyContractInterface = artifacts.require("../contracts/PropertyContractInterface.sol");
var PropertyContract = artifacts.require("../contracts/PropertyContract.sol");

module.exports = function(deployer) {
  deployer.deploy(Property);
  deployer.deploy(Investors);
  //deployer.deploy(PropertyContractInterface);
  //deployer.link(Property, PropertyContract);
  //deployer.link(Investors, PropertyContract);
  deployer.autolink();
  deployer.deploy(PropertyContract);
};
