var FFAFactory = artifacts.require("./FFAFactory.sol");
var FFAContract = artifacts.require("./FFAContract.sol");
var CollateralWallet = artifacts.require("./CollateralWallet.sol");
var TestERC20Token = artifacts.require("./TestERC20Token.sol");
//var ChainlinkOracle = artifacts.require("./ChainlinkOracle.sol");

module.exports = async function(deployer) {
  await deployer.deploy(FFAFactory);
  await deployer.deploy(FFAContract, "Test Contract", "TSTC", 10, 100);
  await deployer.deploy(CollateralWallet, "Test Wallet");
  await deployer.deploy(TestERC20Token, 1000000);
  //await deployer.deploy(ChainlinkOracle);
};
