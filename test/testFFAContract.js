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
        let shortParty = accounts[4];
        let expirationDate = 16295802270;
        let exposureMarginRate = 200;
        let maintenanceMarginRate = 800;

        //catch zero address error
        let longParty = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                                  initialForwardPrice, expirationDate, 
                                                  web3.utils.toChecksumAddress(longWalletInstance.address), 
                                                  web3.utils.toChecksumAddress(shortWalletInstance.address), 
                                                  exposureMarginRate, maintenanceMarginRate);
        } catch(error) {
            lpZeroErr = error;
        }
        assert.notEqual(lpZeroErr, undefined, "Error must be thrown");
        longParty = accounts[3];

        //catch zero address error
        shortParty = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                                  initialForwardPrice, expirationDate, 
                                                  web3.utils.toChecksumAddress(longWalletInstance.address), 
                                                  web3.utils.toChecksumAddress(shortWalletInstance.address), 
                                                  exposureMarginRate, maintenanceMarginRate);
        } catch(error) {
            spZeroErr = error;
        }
        assert.notEqual(spZeroErr, undefined, "Error must be thrown");

        //catch same address error
        shortParty = accounts[3];
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                                  initialForwardPrice, expirationDate, 
                                                  web3.utils.toChecksumAddress(longWalletInstance.address), 
                                                  web3.utils.toChecksumAddress(shortWalletInstance.address), 
                                                  exposureMarginRate, maintenanceMarginRate);
        } catch(error) {
            slpEqualErr = error;
        }
        assert.notEqual(slpEqualErr, undefined, "Error must be thrown");

        shortParty = accounts[4];

        //catch zero wallet addresses and same wallet addresses
        let longWalletAddress = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                                  initialForwardPrice, expirationDate, 
                                                  longWalletAddress, 
                                                  web3.utils.toChecksumAddress(shortWalletInstance.address), 
                                                  exposureMarginRate, maintenanceMarginRate);
        } catch(error) {
            lwZeroErr = error;
        }
        assert.notEqual(lwZeroErr, undefined, "Error must be thrown");

        longWalletAddress = web3.utils.toChecksumAddress(longWalletInstance.address);

        let shortWalletAddress = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                                  initialForwardPrice, expirationDate, 
                                                  longWalletAddress, shortWalletAddress, 
                                                  exposureMarginRate, maintenanceMarginRate);
        } catch(error) {
            swZeroErr = error;
        }
        assert.notEqual(swZeroErr, undefined, "Error must be thrown");

        shortWalletAddress = longWalletAddress;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                                  initialForwardPrice, expirationDate, 
                                                  longWalletAddress, shortWalletAddress, 
                                                  exposureMarginRate, maintenanceMarginRate);
        } catch(error) {
            slwSameErr = error;
        }
        assert.notEqual(slwSameErr, undefined, "Error must be thrown");

        shortWalletAddress = web3.utils.toChecksumAddress(shortWalletInstance.address);

        //check error for expiration date after initiation date
        expirationDate = 935285085; //1999 date
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                                  initialForwardPrice, expirationDate,
                                                   longWalletAddress, shortWalletAddress, 
                                                   exposureMarginRate, maintenanceMarginRate);
        } catch(error) {
            expDateErr = error;
        }
        assert.notEqual(expDateErr, undefined, "Error must be thrown");

        expirationDate = 16295802270;

        //check erro for zero maintenance margin rate
        maintenanceMarginRate = 0;
        try {
            await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                                  initialForwardPrice, expirationDate,
                                                   longWalletAddress, shortWalletAddress, 
                                                   exposureMarginRate, maintenanceMarginRate);
        } catch(error) {
            mMZeroErr = error;
        }
        assert.notEqual(mMZeroErr, undefined, "Error must be thrown");
        
        maintenanceMarginRate = 800;

        /*Checking some functions that cannot be called before initiation*/
        //check error for mToM which cannot be called before initiation
        try {
            await ffaContractInstance.markToMarket(4600);
        } catch(error) {
            beforeInitError = error;
        }
        assert.notEqual(beforeInitError, undefined, "Error must be thrown");

        //testing inititation
        await ffaContractInstance.initiateFFA(longParty, shortParty, 
                                              initialForwardPrice, expirationDate, 
                                              longWalletAddress, shortWalletAddress,
                                              200, 800);
        assert.equal(await ffaContractInstance.getContractState(), "Initiated", "Initiated state failed");
        assert.equal(await ffaContractInstance.getLong(), longParty, "Long not correct");
        assert.equal(await ffaContractInstance.getShort(), shortParty, "Short not correct");
        assert.equal(await ffaContractInstance.getInitialForwardPrice(), initialForwardPrice, "Price not correct");
        assert.equal(await ffaContractInstance.maintenanceMarginRate(), 800, "Rate not correct");
        assert.equal(await ffaContractInstance.getExpirationDate(), expirationDate, "Expiration date not correct");
        assert.equal(await ffaContractInstance.getLongWalletAddress(), longWalletInstance.address, "Long wallet not correct");
        assert.equal(await ffaContractInstance.getShortWalletAddress(), shortWalletInstance.address, "Short wallet not correct");
    });
    
    it("transferCollateralFrom should work and catch incorrect parameters", async function() {
        const ffaContractInstance = await FFAContract.deployed();

        const longWallet = await ffaContractInstance.longTestWallet();
        const shortWallet = await ffaContractInstance.shortTestWallet();
        const longWalletInstance = await CollateralWallet.at(longWallet);
        const shortWalletInstance = await CollateralWallet.at(shortWallet);

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
            await ffaContractInstance.transferCollateralFrom(
                web3.utils.toChecksumAddress(longWalletInstance.address), 
                web3.utils.toChecksumAddress(shortWalletInstance.address), 
                125, web3.utils.toChecksumAddress(testERC20TokenInstance.address));
        } catch(error) {
            balErr = error;
        }
        assert.notEqual(balErr, undefined, "Error must be thrown");

        //check error for zero wallet addresses
        try{
            await ffaContractInstance.transferCollateralFrom(
                address(0), 
                web3.utils.toChecksumAddress(shortWalletInstance.address), 
                25, web3.utils.toChecksumAddress(testERC20TokenInstance.address));
        } catch(error) {
            zeroLongErr = error;
        }
        assert.notEqual(zeroLongErr, undefined, "Error must be thrown");

        try{
            await ffaContractInstance.transferCollateralFrom(
                web3.utils.toChecksumAddress(longWalletInstance.address), 
                address(0), 
                25, web3.utils.toChecksumAddress(testERC20TokenInstance.address));
        } catch(error) {
            zeroShortErr = error;
        }
        assert.notEqual(zeroShortErr, undefined, "Error must be thrown");

        //check error for same wallet addreses
        try{
            await ffaContractInstance.transferCollateralFrom(
                web3.utils.toChecksumAddress(longWalletInstance.address), 
                web3.utils.toChecksumAddress(longWalletInstance.address),
                25, web3.utils.toChecksumAddress(testERC20TokenInstance.address));
        } catch(error) {
            sameAddrErr = error;
        }
        assert.notEqual(sameAddrErr, undefined, "Error must be thrown");

        //check error for zero amount transfer
        try{
            await ffaContractInstance.transferCollateralFrom(
                web3.utils.toChecksumAddress(longWalletInstance.address), 
                web3.utils.toChecksumAddress(shortWalletInstance.address), 
                0, web3.utils.toChecksumAddress(testERC20TokenInstance.address));
        } catch(error) {
            zeroAmountErr = error;
        }
        assert.notEqual(zeroAmountErr, undefined, "Error must be thrown");
    });

    it("markToMarket should work and catch incorrect parameters", async function() {
        const ffaContractInstance = await FFAContract.deployed();
        const testERC20TokenInstance = await TestERC20Token.deployed();

        const longWallet = await ffaContractInstance.longTestWallet();
        const shortWallet = await ffaContractInstance.shortTestWallet();
        const longWalletInstance = await CollateralWallet.at(longWallet);
        const shortWalletInstance = await CollateralWallet.at(shortWallet);

        


    });
});