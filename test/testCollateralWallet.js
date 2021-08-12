const CollateralWallet = artifacts.require("./CollateralWallet.sol");
const TestERC20Token = artifacts.require("./TestERC20Token.sol");

contract("CollaterWallet", accounts => {
    it("should be able to construct CollateralWallet, set and get new balance", async function() {
        const CollateralWalletInstance = await CollateralWallet.deployed();
        const TestERC20TokenInstance = await TestERC20Token.deployed();

        
        

    })
});