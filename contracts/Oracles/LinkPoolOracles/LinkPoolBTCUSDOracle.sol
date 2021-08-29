// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./LinkPoolOracle.sol";

contract LinkPoolBTCUSDOracle is LinkPoolOracle {
    int public _decimals = 10 ** 2;
    string private constant _apiBaseURL = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD,JPY,EUR";
    string public constant _apiPath = "USD";
    

    constructor()
       LinkPoolOracle (
           _decimals,
           _apiBaseURL,
           _apiPath
       ) {
    }
}