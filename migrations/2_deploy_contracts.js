//var FFAFactory = artifacts.require("./FFAFactory.sol");
var FFAContract = artifacts.require("./FFAContract.sol");
//var CollateralWallet = artifacts.require("./CollateralWallet.sol");
//var TestERC20Token = artifacts.require("./TestERC20Token.sol");
//var ChainlinkOracle = artifacts.require("./ChainlinkOracle.sol");

//using Kovan testnet and corresponding oracle nodes/jobs
module.exports = async function(deployer) {
  //await deployer.deploy(FFAFactory);
  
  /* Deploying FFAContract
   * using Linkpool node: https://market.link/jobs/0609deab-6d61-4937-85e4-a8e810b8b272
   * riskFreeRate: 10%
   * sizeOfContract: 1000
   * exposureMargin: 2%
   * maintenanceMargin: 8%
  */
  await deployer.deploy(FFAContract, "Test Contract", "TSTC", 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455, "b6602d14e4734c49a5e1ce19d45a4632", 100, 1000, 2, 8);
  
  //await deployer.deploy(CollateralWallet, "Test Wallet");
  //await deployer.deploy(TestERC20Token, 1000000);
  //await deployer.deploy(ChainlinkOracle);
};
