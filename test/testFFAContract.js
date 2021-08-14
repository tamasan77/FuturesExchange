const { assert } = require("chai");


const FFAContract = artifacts.require("./FFAContract.sol");
const CollateralWallet = artifacts.require("./CollateralWallet.sol");
const TestERC20Token = artifacts.require("./TestERC20Token.sol");


contract("FFAContract", accounts => {
    it("FFA contract works", async function() {
        const ffaContractInstance = await FFAContract.deployed();

        await ffaContractInstance.createCollateralWallet("long wallet");
        await ffaContractInstance.createCollateralWallet("short wallet");
        
        const longWallet = await ffaContractInstance.getCollateralWallets(0);
        const shortWallet = await ffaContractInstance.getCollateralWallets(1);

        const longWalletInstance = await CollateralWallet.at(longWallet);
        const shortWalletInstance = await CollateralWallet.at(shortWallet);

        const long = accounts[3];
        const short = accounts[4];
        const initialForwardPrice = 123;
        const riskFreeRate = 7;
        const expirationDate = 1628948407;//14 Aug.

        //testing inititation
        await ffaContractInstance.initiateFFA(long, short, initialForwardPrice, riskFreeRate, expirationDate, longWalletInstance.address, shortWalletInstance.address);
        assert.equal(await ffaContractInstance.getContractState(), "Initiated", "Initiated state failed");
        assert.equal(await ffaContractInstance.getLong(), long, "Long not correct");
        assert.equal(await ffaContractInstance.getShort(), short, "Short not correct");
        assert.equal(await ffaContractInstance.getInitialForwardPrice(), initialForwardPrice, "Price not correct");
        assert.equal(await ffaContractInstance.getRiskFreeRate(), riskFreeRate, "Rate not correct");
        assert.equal(await ffaContractInstance.getExpirationDate(), expirationDate, "Expiration date not correct");
        assert.equal(await ffaContractInstance.getLongWalletAddress(), longWalletInstance.address, "Long wallet not correct");
        assert.equal(await ffaContractInstance.getShortWalletAddress(), shortWalletInstance.address, "Short wallet not correct");

        //testing transferCollateralFrom
        //set balances: 100 TestERC20Tokens each
        const testERC20TokenInstance = await TestERC20Token.deployed();
        await longWalletInstance.setNewBalance(ffaContractInstance.address, testERC20TokenInstance.address, 100);
        await shortWalletInstance.setNewBalance(ffaContractInstance.address, testERC20TokenInstance.address, 100);
        //transfer 100 tokens to each wallet
        await testERC20TokenInstance.transfer(longWalletInstance.address, 100);
        await testERC20TokenInstance.transfer(shortWalletInstance.address, 100);
        //transfer 25 tokens from long to short wallet
        await ffaContractInstance.transferCollateralFrom(longWalletInstance.address, shortWalletInstance.address, 25, testERC20TokenInstance.address);
        const longWalletBalance = await longWalletInstance.getMappedBalance(ffaContractInstance.address, testERC20TokenInstance.address);
        const shortWalletBalance = await shortWalletInstance.getMappedBalance(ffaContractInstance.address, testERC20TokenInstance.address);
        assert.equal(longWalletBalance, 75, "transfer failed");
        assert.equal(shortWalletBalance, 125, "transfer failed");
    })
});