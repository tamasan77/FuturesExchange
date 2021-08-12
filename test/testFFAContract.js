const { assert } = require("chai");

const FFAContract = artifacts.require("./FFAContract.sol");
const CollateralWallet = artifacts.require("./CollateralWallet.sol");


contract("FFAContract", accounts => {
    it("should be able to initiate FFAContract", async function() {
        const ffaContractInstance = await FFAContract.deployed();

        await ffaContractInstance.createCollateralWallet("long wallet");
        await ffaContractInstance.createCollateralWallet("short wallet");
        
        const longWallet = await ffaContractInstance.getCollateralWallets(0);
        const shortWallet = await ffaContractInstance.getCollateralWallets(1);

        const longWalletInstance = await CollateralWallet.at(longWallet);
        const shortWalletInstance = await CollateralWallet.at(shortWallet);

        const long = accounts[3];
        const short = accounts[4];
        const forwardPrice = 123;
        const riskFreeRate = 7;
        const expirationDate = 1628948407;//14 Aug.

        await ffaContractInstance.initiateFFA(long, short, forwardPrice, riskFreeRate, expirationDate, longWalletInstance.address, shortWalletInstance.address);
        assert.equal(await ffaContractInstance.getContractState(), "Initiated", "Initiated state failed");
        assert.equal(await ffaContractInstance.getLong(), long, "Long not correct");
        assert.equal(await ffaContractInstance.getShort(), short, "Short not correct");
        assert.equal(await ffaContractInstance.getForwardPrice(), forwardPrice, "Price not correct");
        assert.equal(await ffaContractInstance.getRiskFreeRate(), riskFreeRate, "Rate not correct");
        assert.equal(await ffaContractInstance.getExpirationDate(), expirationDate, "Expiration date not correct");
        assert.equal(await ffaContractInstance.getLongWalletAddress(), longWalletInstance.address, "Long wallet not correct");
        assert.equal(await ffaContractInstance.getShortWalletAddress(), shortWalletInstance.address, "Short wallet not correct");
    })
});