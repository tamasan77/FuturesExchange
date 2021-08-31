// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "../FFAContract.sol";

contract FFAContractMock is FFAContract {

    constructor() FFAContract("Mock Test", 
                              "MTST", 100, 
                              "http://valuation-api.herokuapp.com/price/4500/1000/0/15778476", 
                              "price", 100) {}

    /* Create long and short wallets for FFAContract*/
    CollateralWallet public longTestWallet;
    CollateralWallet public shortTestWallet;
    function createLongCollateralWallet(string memory _name) external returns(address walletAddress_) {
            longTestWallet = new CollateralWallet(_name);
            walletAddress_ = address(longTestWallet);
    }
    function createShortCollateralWallet(string memory _name) external returns(address walletAddress_) {
            shortTestWallet = new CollateralWallet(_name);
            walletAddress_ = address(shortTestWallet);
    }

    function setStateToCreated() external {
           contractState = ContractState.Created;
    }

    function setStateToInitiated() external {
        contractState = ContractState.Initiated;
    }

    function setExpirationDate(uint newDate) external{
        expirationDate = newDate;
    }

    function setLong(address newLong) external{
        long = newLong;
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }  
}