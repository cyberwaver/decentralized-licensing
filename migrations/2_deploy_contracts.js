var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var Licence = artifacts.require("./Licence.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(Licence);
};
