// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./FFAContract.sol";

contract FFAFactory {
    using SafeERC20 for IERC20;

    //hold address of FFA contracts
    address[] private ffaContracts;

    //address _oracleAddress = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;//temporary

    event Created(uint8 decimals, uint256 sizeOfContract);

    function createFFAContract(
        string calldata _name, 
        string calldata _symbol, 
        //address _oracleAddress,
        //bytes32 _jobId, 
        uint8 _decimals,
        uint256 _sizeOfContract
        ) 
        external returns (address ffaContractAddress_) {
            //check valid oracleAddress and jobId
            //require (_oracleAddress != address(0), "oracle address cannot be zero address");
            //require(_jobId != "", "jobId cannot be empty string");
            
            ffaContractAddress_ = address(new FFAContract(_name, _symbol, _decimals, _sizeOfContract));
            require(keccak256(abi.encodePacked(FFAContract(ffaContractAddress_).getContractState())) == keccak256(abi.encodePacked("Created")), "contract not created");
            ffaContracts.push(ffaContractAddress_);
            emit Created( _decimals, _sizeOfContract);
    }

    //do i need modifier?
    //could just send address and then use .at
    function getFFAContract(uint256 index) external view returns(FFAContract) {
        return FFAContract(ffaContracts[index]);
    }
}

//Dennis notes:
//query the state of the contract whether it's created
            //no gas cost
            //try catch - expect error and have specific plan to unwind system
            // - heuristic call
            //may or may not have direct control over what we are calling
            //deal with 3rd party errors
            //solidty added try-catch blocks for contract calls because they can be heuristic
            //heuristic - range of things that go wrong
            //if you have to try cath you dont try catch for internal server error
            //in smart contract htings are heuristic - latency of network may fail for variety of reasons
            //smart contracts don't make outside calls for this heuristic problem -> this is why chainlink is great
            //this is why try catch was introduced
            //destructor - sufficiently cleanup the object, nested, orpahns etc...
            //"try catch finally" - tried event caught error, for any other error finally execute this