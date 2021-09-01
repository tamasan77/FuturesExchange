// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./LinkPoolUintOracle.sol";

contract LinkPoolValuationOracle is LinkPoolUintOracle {
    int public _decimals_ = 10 ** 2;
    string private constant _apiBaseURL_ = "http://valuation-api.herokuapp.com/price/";
    string public constant _apiPath_ = "price";

    constructor() 
        LinkPoolUintOracle (
            _decimals_,
            _apiBaseURL_,
            _apiPath_
        ) {
    }
}