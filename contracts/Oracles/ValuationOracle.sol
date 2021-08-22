// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "../ChainlinkOracle.sol";

contract ValuationOracle is ChainlinkOracle {
    string private constant baseURL = "http://valuation-api.herokuapp.com/price";
    string public constant apiPath = "price";
    string public urlParameters;

    //figure out decimals for future contract price

    
    /* fixed-point representation scaled 1/100
     * Examples of internal representation of values
     * - underlyingPrice: $43.78 -> 4378
     * - annualRiskFreeRate: 1.24% -> 124%
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
            concetenateStringsForURL(baseURL, uint2str(underlyingPrice), uint2str(annualRiskFreeRate), uint2str(valuationDate), uint2str(expirationDate)), 
            apiPath, 
            linkAddress, 
            fee, 
            100
        ) {
    }
    
    //concatanate strings and add /  where needed for URL
    function concetenateStringsForURL(string memory a, string memory b, string memory c, string memory d, string memory e) internal pure returns (string memory) {
	    return string(abi.encodePacked(a,"/", b, "/", c, "/", d, "/", e));
    }

    //parse uint to string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}