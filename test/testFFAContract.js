const { assert } = require("chai");


const FFAContract = artifacts.require("./FFAContract.sol");
const CollateralWallet = artifacts.require("./CollateralWallet.sol");
const TestERC20Token = artifacts.require("./TestERC20Token.sol");


contract("FFAContract", accounts => {
    async function isContract(address) {
        const bytecode = await web3.eth.getCode(address);
        return bytecode != "0x";
    };
    it("should initiate FFA and catch incorrect parameters", async function() {
        const ffaContractInstance = await FFAContract.deployed();

        await ffaContractInstance.createLongCollateralWallet("long wallet");
        await ffaContractInstance.createShortCollateralWallet("short wallet");
        const longWallet = await ffaContractInstance.longTestWallet();
        const shortWallet = await ffaContractInstance.shortTestWallet();
        const longWalletInstance = await CollateralWallet.at(longWallet);
        const shortWalletInstance = await CollateralWallet.at(shortWallet);

        let initialForwardPrice = 4378;
        let riskFreeRate = 124;
        let shortParty = accoutns[4];
        let expirationDate = 16295802270;
        let oracleAddress = 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455;
        let jobId = "b6602d14e4734c49a5e1ce19d45a4632";
        let linkAddress = 0xa36085F69e2889c224210F603D836748e7dC0088;
        let fee = 0.1 * 10 ** 18;

        //catch zero address error
        let longParty = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, web3.utils.toChecksumAddress(longWalletInstance.address), web3.utils.toChecksumAddress(shortWalletInstance.address), web3.utils.toChecksumAddress(oracleAddress), jobId, fee, linkAddress);
        } catch(error) {
            lpZeroErr = error;
        }
        assert.notEqual(lpZeroErr, undefined, "Error must be thrown");
        longParty = accounts[3];

        //catch zero address error
        shortParty = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, web3.utils.toChecksumAddress(longWalletInstance.address), web3.utils.toChecksumAddress(shortWalletInstance.address), web3.utils.toChecksumAddress(oracleAddress), jobId, fee, linkAddress);
        } catch(error) {
            spZeroErr = error;
        }
        assert.notEqual(spZeroErr, undefined, "Error must be thrown");

        //catch same address error
        shortParty = accounts[3];
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, web3.utils.toChecksumAddress(longWalletInstance.address), web3.utils.toChecksumAddress(shortWalletInstance.address), web3.utils.toChecksumAddress(oracleAddress), jobId, fee, linkAddress);
        } catch(error) {
            slpEqualErr = error;
        }
        assert.notEqual(slpEqualErr, undefined, "Error must be thrown");

        shortParty = accounts[4];

        //catch zero wallet addresses and same wallet addresses
        let longWalletAddress = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, longWalletAddress, web3.utils.toChecksumAddress(shortWalletInstance.address), web3.utils.toChecksumAddress(oracleAddress), jobId, fee, linkAddress);
        } catch(error) {
            lwZeroErr = error;
        }
        assert.notEqual(lwZeroErr, undefined, "Error must be thrown");

        longWalletAddress = web3.utils.toChecksumAddress(longWalletInstance.address);

        let shortWalletAddress = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, longWalletAddress, shortWalletAddress, web3.utils.toChecksumAddress(oracleAddress), jobId, fee, linkAddress);
        } catch(error) {
            swZeroErr = error;
        }
        assert.notEqual(swZeroErr, undefined, "Error must be thrown");

        shortWalletAddress = longWalletAddress;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, longWalletAddress, shortWalletAddress, web3.utils.toChecksumAddress(oracleAddress), jobId, fee, linkAddress);
        } catch(error) {
            slwSameErr = error;
        }
        assert.notEqual(slwSameErr, undefined, "Error must be thrown");

        shortWalletAddress = web3.utils.toChecksumAddress(shortWalletInstance.address);

        //check error for expiration date after initiation date
        expirationDate = 935285085; //1999 date
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, initialForwardPrice, riskFreeRate, expirationDate, longWalletAddress, shortWalletAddress, web3.utils.toChecksumAddress(oracleAddress), jobId, fee, linkAddress);
        } catch(error) {
            expDateErr = error;
        }
        assert.notEqual(expDateErr, undefined, "Error must be thrown");

        expirationDate = 16295802270;

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

        //check error of insufficient balance
        try{
            await ffaContractInstance.transferCollateralFrom(web3.utils.toChecksumAddress(longWalletInstance.address), web3.utils.toChecksumAddress(shortWalletInstance.address), 125, web3.utils.toChecksumAddress(testERC20TokenInstance.address));
        } catch(error) {
            balErr = error;
        }
        assert.notEqual(balErr, undefined, "Error must be thrown");
    });
});