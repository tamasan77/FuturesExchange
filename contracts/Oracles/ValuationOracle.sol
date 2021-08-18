// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "../ChainlinkOracle.sol";

contract ValuationOracle is ChainlinkOracle {
    string baseURL = "http://valuation-api.herokuapp.com/price/";
    

    function append(string memory a, string memory b, string memory c, string memory d, string memory e, string memory f) internal pure returns (string memory) {
	    return string(abi.encodePacked(a, b, c, d, e, f));
    }
}