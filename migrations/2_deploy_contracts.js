//var FFAFactory = artifacts.require("./FFAFactory.sol");
var FFAContract = artifacts.require("./FFAContract.sol");
var CollateralWallet = artifacts.require("./CollateralWallet.sol");
//var ChainlinkOracle = artifacts.require("./ChainlinkOracle.sol");

module.exports = async function(deployer) {
  //await deployer.deploy(FFAFactory);
  await deployer.deploy(FFAContract, "Test Contract", "TST", 10, 100);
  //await deployer.deploy(ChainlinkOracle);
};
