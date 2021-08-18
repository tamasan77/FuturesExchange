

const CollateralWallet = artifacts.require("./CollateralWallet.sol");
const TestERC20Token = artifacts.require("./TestERC20Token.sol");
const FFAContract = artifacts.require("./FFAContract.sol");

contract("CollaterWallet", accounts => {
    //given addresses
    it("should be able to construct CollateralWallet, set and get new balance", async function() {
        const collateralWalletInstance = await CollateralWallet.deployed();
        const testERC20TokenInstance = await TestERC20Token.deployed();
        const ffaContractInstance = await FFAContract.deployed();

        await collateralWalletInstance.setNewBalance(ffaContractInstance.address, testERC20TokenInstance.address, 200);
        const newBalance = await collateralWalletInstance.getMappedBalance(ffaContractInstance.address, testERC20TokenInstance.address);
        assert.equal(newBalance, 200, "balances equal");
    })
});