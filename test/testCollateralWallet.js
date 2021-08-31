const { assert } = require("chai");


const CollateralWallet = artifacts.require("./CollateralWallet.sol");
const TestERC20Token = artifacts.require("./TestERC20Token.sol");
const FFAContractMock = artifacts.require("./mocks/FFAContractMock.sol");

contract("CollaterWallet", accounts => {
    //given addresses
    it("should be able to construct CollateralWallet, set and get new balance", async function() {
        const collateralWalletInstance = await CollateralWallet.deployed();
        const testERC20TokenInstance = await TestERC20Token.deployed();
        const ffaContractInstance = await FFAContractMock.deployed();

        //check for zero addresses for setNewBalance
        try{
            await collateralWalletInstance.setNewBalance(0, testERC20TokenInstance.address, 200);
        } catch(error) {
            zeroContractAddrErr = error;
        }
        assert.notEqual(zeroContractAddrErr, undefined, "Error must be thrown");

        try{
            await collateralWalletInstance.setNewBalance(ffaContractInstance.address, 0, 200);
        } catch(error) {
            zeroTokenAddrErr = error;
        }
        assert.notEqual(zeroTokenAddrErr, undefined, "Error must be thrown");

        await collateralWalletInstance.setNewBalance(ffaContractInstance.address, testERC20TokenInstance.address, 200);

        //check zero addresses for getMappedBalance
        try{
            await collateralWalletInstance.getMappedBalance(0, testERC20TokenInstance.address);
        } catch(error) {
            zeroContractErr = error;
        }
        assert.notEqual(zeroContractErr, undefined, "Error must be thrown");

        try{
            await collateralWalletInstance.getMappedBalance(ffaContractInstance.address, 0);
        } catch(error) {
            zeroTokenErr = error;
        }
        assert.notEqual(zeroTokenErr, undefined, "Error must be thrown");
        
        //test get and set new balance
        await collateralWalletInstance.setNewBalance(ffaContractInstance.address, testERC20TokenInstance.address, 200);
        let newBalance = await collateralWalletInstance.getMappedBalance(ffaContractInstance.address, testERC20TokenInstance.address);
        assert.equal(newBalance, 200, "correct balance");
    });

    it("approveSpender should work and catch incorrect parameters", async function() {
        const collateralWalletInstance = await CollateralWallet.deployed();
        const testERC20TokenInstance = await TestERC20Token.deployed();

        //check error for zero spender address for approveSpender
        try {
            await collateralWalletInstance.approveSpender(testERC20TokenInstance.address, address(0), 200);
        } catch(error) {
            zeroSpenderErr = error;
        }
        assert.notEqual(zeroSpenderErr, undefined, "Zero spender address not caught");

        //check error for zero token addres for approveSpender
        let spenderAddress = accounts[7];

        try {
            await collateralWalletInstance.approveSpender(address(0), spenderAddress, 200);
        } catch(error) {
            zeroTokenErr = error;
        }
        assert.notEqual(zeroTokenErr, undefined, "Error must be thrown");

        //check if approve works with correct parameters
        await collateralWalletInstance.approveSpender(testERC20TokenInstance.address, spenderAddress, 150);
        assert.equal(
            await testERC20TokenInstance.allowance(collateralWalletInstance.address, spenderAddress), 
            150, "allowance set incorrectly");
    })
});