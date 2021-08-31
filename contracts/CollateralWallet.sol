// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./FFAContract.sol";

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

    //receive and fallback functions
    /*
    receive () external payable {
    
    }
    */
    /*
    fallback () external payable {

    }*/


    //setters
    //ADD MODIFIERS FOR SAFETY!!!!!!!!!!!!
    function setNewBalance(address ffaContractAddress, address collateralTokenAddress, uint256 newBalance) external {
        require(ffaContractAddress != address(0), "contract address cannot be zero");
        require(collateralTokenAddress != address(0), "token address cannot be zero");
        ffaToPledgedCollateralMapping[ffaContractAddress][collateralTokenAddress] = newBalance;
        pledgedCollateralToFFAMapping[collateralTokenAddress][ffaContractAddress] = newBalance;
    }

    function getMappedBalance(address ffaContractAddress, address collateralTokenAddress) external view returns (uint256) {
        require(ffaContractAddress != address(0), "contract address cannot be zero");
        require(collateralTokenAddress != address(0), "token address cannot be zero");
        return ffaToPledgedCollateralMapping[ffaContractAddress][collateralTokenAddress];
    }

    function approveSpender(address collateralTokenAddress, address spender, uint256 amount) external {
        require(spender != address(0), "spender address cannot be zero");
        require(collateralTokenAddress != address(0), "token address cannot be zero");
        IERC20(collateralTokenAddress).approve(spender, amount);
    }

    function getName() external view returns(string memory) {
        return name;
    }
}