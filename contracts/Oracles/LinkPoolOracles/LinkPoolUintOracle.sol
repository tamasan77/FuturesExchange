// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./LinkPoolOracle.sol";

contract LinkPoolUintOracle is LinkPoolOracle {
    //Get uint256
    bytes32 public __jobId = "b6602d14e4734c49a5e1ce19d45a4632";

    constructor (
        int __decimals, 
        string memory __apiBaseURL, 
        string memory __apiPath
    ) LinkPoolOracle(
        __jobId,
        __decimals,
        __apiBaseURL,
        __apiPath,
        false
    ) {
    }
}