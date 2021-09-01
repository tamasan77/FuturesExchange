// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./LinkPoolOracle.sol";

contract LinkPoolIntOracle is LinkPoolOracle {
    //Get Int256 job
    bytes32 public __jobId = "2649fc4ca83c4016bfd2d15765592bee";

    constructor (
        int __decimals, 
        string memory __apiBaseURL, 
        string memory __apiPath
    ) LinkPoolOracle(
        __jobId,
        __decimals,
        __apiBaseURL,
        __apiPath
    ) {
    }
}