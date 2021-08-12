const CollateralWallet = artifacts.require("./CollateralWallet.sol");

contract("CollaterWallet", accounts => {
    it("should be able to construct CollateralWallet, set and get new balance", async function() {
        const CollateralWalletInstance = await CollateralWallet.deployed();

        const name = "Test Wallet";
        
    })
});