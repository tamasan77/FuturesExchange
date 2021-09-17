// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./CollateralWallet.sol";

contract CollateralWalletFactory {
    //hold addresses of Collateral Wallets
    address[] public collateralWallets;

    event CollateralWalletCreated(string name);

    function createCollateralWallet (string memory name) external returns (address collateralWalletAddress_){
        require(bytes(name).length != 0, "url empty");
        collateralWalletAddress_ = address(new CollateralWallet(name));
        collateralWallets.push(collateralWalletAddress_);
        emit CollateralWalletCreated(name);
    }
}