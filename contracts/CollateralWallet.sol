// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./FFAContract.sol";
//import "../interfaces/ICollateralWallet.sol";

contract CollateralWallet is Pausable, Ownable{//IERC20Metadata
    using SafeERC20 for IERC20;

    //do i even need this?
    //IERC20[] private tokens;

    string private name;

    //ffa contracts have collaterals that have unique balance
    mapping(address => mapping(address => uint256)) private ffaToPledgedCollateralMapping;
    mapping(address => mapping(address => uint256)) private pledgedCollateralToFFAMapping;

    //add events here

    constructor (/*IERC20[] memory _tokens,*/ string memory _name) {
        name = _name;
        //tokens = _tokens;
    }

    //deposit

    //withdraw

    //transferCollateral moved to FFAContract.sol
    /*
    function transferCollateral(CollateralWallet recipientWallet, uint256 amount, address ffaContractAddress, address collateralTokenAddress) external returns (bool transfered_){
        require(ffaToPledgedCollateralMapping[ffaContractAddress][collateralTokenAddress] >= amount, "collateral balance not sufficient");
        require(pledgedCollateralToFFAMapping[collateralTokenAddress][ffaContractAddress] >= amount, "collateral balance not sufficient");

        IERC20(collateralTokenAddress).safeTransfer(address(recipientWallet), amount);

        //deduct from sender balance mapping
        unchecked {
            ffaToPledgedCollateralMapping[ffaContractAddress][collateralTokenAddress] -= amount;
            pledgedCollateralToFFAMapping[collateralTokenAddress][ffaContractAddress] -= amount;
        }
        //add to recipient balance mapping
        recipientWallet.ffaToPledgedCollateralMapping[ffaContractAddress][collateralTokenAddress] += amount;

        transfered_ = true;
    }*/


    //setters
    //ADD MODIFIERS FOR SAFETY!!!!!!!!!!!!
    function setNewBalance(address ffaContractAddress, address collateralTokenAddress, uint256 newBalance) external {
        ffaToPledgedCollateralMapping[ffaContractAddress][collateralTokenAddress] = newBalance;
        pledgedCollateralToFFAMapping[collateralTokenAddress][ffaContractAddress] = newBalance;
    }

    function getMappedBalance(address ffaContractAddress, address collateralTokenAddress) external view returns (uint256) {
        return ffaToPledgedCollateralMapping[ffaContractAddress][collateralTokenAddress];
    }

    function getName() external view returns(string memory) {
        return name;
    }
}