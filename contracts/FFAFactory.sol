// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./FFAContract.sol";

contract FFAFactory {
    using SafeERC20 for IERC20;

    //hold addresses of FFA contracts
    address[] private ffaContracts;

    event Created(string name, string symbol, uint256 sizeOfContract);
    
    function createFFAContract(
        string memory name, 
        string memory symbol,
        uint256 sizeOfContract,
        string memory underlyingApiURL,
        string memory underlyingApiPath,
        int256 underlyingDecimals
        ) 
        external returns (address ffaContractAddress_) {
            require(bytes(underlyingApiURL).length != 0, "url cannot be empty string");
            require(bytes(underlyingApiPath).length != 0, "url cannot be empty string");
            require(underlyingDecimals != 0, "decimals can't be zero");
            require(sizeOfContract > 0, "contract size cannot be zero");
            ffaContractAddress_ = address(new FFAContract(name, symbol, sizeOfContract, underlyingApiURL, underlyingApiPath, underlyingDecimals));
            require(keccak256(abi.encodePacked(FFAContract(ffaContractAddress_).getContractState())) == keccak256(abi.encodePacked("Created")), "contract not created");
            ffaContracts.push(ffaContractAddress_);
            emit Created(name, symbol, sizeOfContract);
    }

    function getFFAContract(uint256 index) external view returns(FFAContract) {
        return FFAContract(ffaContracts[index]);
    }
}

