const { assert } = require("chai");

const FFAContract = artifacts.require("./FFAContract.sol");
const CollateralWallet = artifacts.require("./CollateralWallet.sol");


contract("FFAContract", accounts => {
    it("should be able to initiate FFAContract", async function() {
        const ffaContractInstance = await FFAContract.deployed();
        const 
        const longWallet = await CollateralWallet.at(await ffaContractInstance.createCollateralWallet("long wallet"));
        const shortWallet = await CollateralWallet.at(await ffaContractInstance.createCollateralWallet("short wallet"));

        const long = accounts[3];
        const short = accounts[4];
        const forwardPrice = 123;
        const riskFreeRate = 7;
        const expirationDate = 1628948407;//14 Aug.

        const initiated = ffaContractInstance.initiateFFA(long, short, forwardPrice, riskFreeRate, expirationDate, longWallet, shortWallet);
        assert.equal(initiated, true, "not inititated");

    })
});