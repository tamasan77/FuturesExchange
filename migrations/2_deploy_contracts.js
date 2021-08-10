var FFAFactory = artifacts.require("./FFAFactory.sol");
//var ChainlinkOracle = artifacts.require("./ChainlinkOracle.sol");

module.exports = function(deployer) {
  deployer.deploy(FFAFactory);
  //deployer.deploy(ChainlinkOracle);
};
