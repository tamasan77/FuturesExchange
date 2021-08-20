// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "../ChainlinkOracle.sol";

contract ValuationOracle is ChainlinkOracle {
    string private constant baseURL = "http://valuation-api.herokuapp.com/price/";
    string public constant apiPath = "price";
    string public urlParameters;

    //figure out decimals for future contract price
    int8 decimals = 10 ** 2;
    
    /* fixed-point representation scaled 1/100
     * Examples of internal representation of values
     * - underlyingPrice: $43.78 -> 4378
     * - annualRiskFreeRate: 1.24% -> 124
     */
    constructor(
        address oracleAddress, 
        bytes32 jobId, 
        address linkAddress, 
        uint256 fee, 
        uint256 underlyingPrice, 
        uint8 annualRiskFreeRate, 
        uint256 valuationDate, 
        uint256 expirationDate) 
        ChainlinkOracle (
            oracleAddress, 
            jobId, 
            append(baseURL, )
        ) {

    }
    

    function append(string memory a, string memory b, string memory c, string memory d, string memory e, string memory f) internal pure returns (string memory) {
	    return string(abi.encodePacked(a, b, c, d, e, f));
    }
}