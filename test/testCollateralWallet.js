

const CollateralWallet = artifacts.require("./CollateralWallet.sol");
const TestERC20Token = artifacts.require("./TestERC20Token.sol");
const FFAContract = artifacts.require("./FFAContract.sol");

contract("CollaterWallet", accounts => {
    //given addresses
    it("should be able to construct CollateralWallet, set and get new balance", async function() {
        const collateralWalletInstance = await CollateralWallet.deployed();
        const testERC20TokenInstance = await TestERC20Token.deployed();
        const ffaContractInstance = await FFAContract.deployed();

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
            let newBalance = await collateralWalletInstance.getMappedBalance(0, testERC20TokenInstance.address);
        } catch(error) {
            zeroContractErr = error;
        }
        assert.notEqual(zeroContractErr, undefined, "Error must be thrown");

        try{
            let newBalance = await collateralWalletInstance.getMappedBalance(ffaContractInstance.address, 0);
        } catch(error) {
            zeroTokenErr = error;
        }
        assert.notEqual(zeroTokenErr, undefined, "Error must be thrown");

        let newBalance = await collateralWalletInstance.getMappedBalance(ffaContractInstance.address, testERC20TokenInstance.address);
        assert.equal(newBalance, 200, "correct balance");
    })
});