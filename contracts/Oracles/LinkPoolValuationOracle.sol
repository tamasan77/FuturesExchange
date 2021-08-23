// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./ValuationOracle.sol";

contract LinkPoolValuationOracle is ValuationOracle {
    address _oracleAddress = 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455;
    bytes32 _jobId = "b6602d14e4734c49a5e1ce19d45a4632";
    address _linkAddress = 0xa36085F69e2889c224210F603D836748e7dC0088;
    uint256 _fee = 0.1 * 10 ** 18; //0.1 LINK

    constructor(
        uint256 underlyingPrice, 
        uint8 annualRiskFreeRate, 
        uint256 valuationDate, 
        uint256 expirationDate) 
        ValuationOracle (
            _oracleAddress,
            _jobId,
            _linkAddress,
            _fee,
            underlyingPrice,
            annualRiskFreeRate,
            valuationDate,
            expirationDate
        ) {
    }
}