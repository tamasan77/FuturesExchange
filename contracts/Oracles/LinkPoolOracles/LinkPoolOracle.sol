// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "../../ChainlinkOracle.sol";

contract LinkPoolOracle is ChainlinkOracle {
    address public _oracleAddress = 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455;
    //bytes32 public _jobId = "b6602d14e4734c49a5e1ce19d45a4632";
    address public _linkAddress = 0xa36085F69e2889c224210F603D836748e7dC0088;
    uint256 public _fee = 0.1 * 10 ** 18; //0.1 LINK

    constructor (
        bytes32 _jobId,
        int _decimals, 
        string memory _apiBaseURL, 
        string memory _apiPath)
        ChainlinkOracle (
            _oracleAddress, 
            _jobId,
            _linkAddress,
            _fee,
            _decimals,
            _apiBaseURL,
            _apiPath
        ) {
    }
}