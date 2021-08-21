const { assert } = require("chai");


const FFAContract = artifacts.require("./FFAContract.sol");
const CollateralWallet = artifacts.require("./CollateralWallet.sol");
const TestERC20Token = artifacts.require("./TestERC20Token.sol");


contract("FFAContract", accounts => {
    it("should initiate FFA and catch incorrect parameters", async function() {
        const ffaContractInstance = await FFAContract.deployed();

        await ffaContractInstance.createLongCollateralWallet("long wallet");
        await ffaContractInstance.createShortCollateralWallet("short wallet");
        const longWallet = await ffaContractInstance.longTestWallet();
        const shortWallet = await ffaContractInstance.shortTestWallet();
        const longWalletInstance = await CollateralWallet.at(longWallet);
        const shortWalletInstance = await CollateralWallet.at(shortWallet);

        let longParty = accounts[3];
        let shortParty = accounts[4];
        let initialForwardPrice = 4500;
        let riskFreeRate = 10;
        let expirationDate = 16295802270;

        //testing inititation
        await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, web3.utils.toChecksumAddress(longWalletInstance.address), web3.utils.toChecksumAddress(shortWalletInstance.address));
        assert.equal(await ffaContractInstance.getContractState(), "Initiated", "Initiated state failed");
        assert.equal(await ffaContractInstance.getLong(), longParty, "Long not correct");
        assert.equal(await ffaContractInstance.getShort(), shortParty, "Short not correct");
        assert.equal(await ffaContractInstance.getInitialForwardPrice(), initialForwardPrice, "Price not correct");
        assert.equal(await ffaContractInstance.getRiskFreeRate(), riskFreeRate, "Rate not correct");
        assert.equal(await ffaContractInstance.getExpirationDate(), expirationDate, "Expiration date not correct");
        assert.equal(await ffaContractInstance.getLongWalletAddress(), longWalletInstance.address, "Long wallet not correct");
        assert.equal(await ffaContractInstance.getShortWalletAddress(), shortWalletInstance.address, "Short wallet not correct");
    });
    
    it("transferCollateralFrom should work and catch incorrect parameters", async function() {
        const ffaContractInstance = await FFAContract.deployed();

        await ffaContractInstance.createLongCollateralWallet("long wallet");
        await ffaContractInstance.createShortCollateralWallet("short wallet");
        const longWallet = await ffaContractInstance.longTestWallet();
        const shortWallet = await ffaContractInstance.shortTestWallet();
        const longWalletInstance = await CollateralWallet.at(longWallet);
        const shortWalletInstance = await CollateralWallet.at(shortWallet);

        let longParty = accounts[3];
        let shortParty = accounts[4];
        let initialForwardPrice = 4500;
        let riskFreeRate = 10;
        let expirationDate = 16295802270;
        await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, web3.utils.toChecksumAddress(longWalletInstance.address), web3.utils.toChecksumAddress(shortWalletInstance.address));

        //testing transferCollateralFrom
        //set balances: 100 TestERC20Tokens each
        const testERC20TokenInstance = await TestERC20Token.deployed();
        await longWalletInstance.setNewBalance(ffaContractInstance.address, testERC20TokenInstance.address, 100);
        await shortWalletInstance.setNewBalance(ffaContractInstance.address, testERC20TokenInstance.address, 100);
        //transfer 100 tokens to each wallet
        await testERC20TokenInstance.transfer(longWalletInstance.address, 100);
        await testERC20TokenInstance.transfer(shortWalletInstance.address, 100);
        //transfer 25 tokens from long to short wallet
        await ffaContractInstance.transferCollateralFrom(web3.utils.toChecksumAddress(longWalletInstance.address), web3.utils.toChecksumAddress(shortWalletInstance.address), 25, web3.utils.toChecksumAddress(testERC20TokenInstance.address));
        const longWalletBalance = await longWalletInstance.getMappedBalance(ffaContractInstance.address, testERC20TokenInstance.address);
        const shortWalletBalance = await shortWalletInstance.getMappedBalance(ffaContractInstance.address, testERC20TokenInstance.address);
        assert.equal(longWalletBalance, 75, "transfer failed");
        assert.equal(shortWalletBalance, 125, "transfer failed");
    });
});