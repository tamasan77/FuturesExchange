var FFAFactory = artifacts.require("./FFAFactory.sol");
//var FFAContract = artifacts.require("./FFAContract.sol");
//var ChainlinkOracle = artifacts.require("./ChainlinkOracle.sol");

module.exports = async function(deployer) {
  await deployer.deploy(FFAFactory);
  //await deployer.deploy(FFAContract);
  //await deployer.deploy(ChainlinkOracle);
};
