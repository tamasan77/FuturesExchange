const _deploy_contracts = require("../migrations/2_deploy_contracts");

const FFAContract = artifacts.require("./FFAContract.sol");

contract("FFAContract", accounts => {
    it("should be able to initiate FFAContract", async function() {
        const ffaContractInstance = await FFAContract.deployed();

        const long = acounts[3];
        const short = accounts[4];
        const forwardPrice = 123;
        const riskFreeRate = 7;
        const expirationDate = 1628948407;//14 Aug.
        

    })
});