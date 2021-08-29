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
        address oracleAddress,
        bytes32 jobId, 
        uint256 fee,
        address linkAddress,
        string memory underlyingApiURL,
        string memory underlyingApiPath,
        int decimals,
        uint256 sizeOfContract
        /* margin rate representation:
         * Scaled 1/100
         * 1.25% -> 125
         */
        ) 
        external returns (address ffaContractAddress_) {
            
            require (oracleAddress != address(0), "oracle address cannot be zero address");
            require(jobId != "", "jobId cannot be empty string");
            require(decimals != 0, "decimals can't be zero");
            require(sizeOfContract > 0, "contract size cannot be zero");

            
            ffaContractAddress_ = address(new FFAContract(name, symbol, oracleAddress, jobId, fee, linkAddress, underlyingApiURL, underlyingApiPath, decimals, sizeOfContract));
            require(keccak256(abi.encodePacked(FFAContract(ffaContractAddress_).getContractState())) == keccak256(abi.encodePacked("Created")), "contract not created");
            ffaContracts.push(ffaContractAddress_);
            emit Created(name, symbol, sizeOfContract);
    }

    function getFFAContract(uint256 index) external view returns(FFAContract) {
        return FFAContract(ffaContracts[index]);
    }
}

