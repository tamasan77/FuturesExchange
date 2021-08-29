// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./LinkPoolOracle.sol";

contract LinkPoolValuationOracle is LinkPoolOracle {
    int public _decimals = 10 ** 2;
    string private constant _apiBaseURL = "http://valuation-api.herokuapp.com/price";
    string public constant _apiPath = "price";

    constructor() 
        LinkPoolOracle (
            _decimals,
            _apiBaseURL,
            _apiPath
        ) {
    }
}