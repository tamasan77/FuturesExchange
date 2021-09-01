// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./LinkPoolUintOracle.sol";

contract LinkPoolBTCUSDOracle is LinkPoolUintOracle {
    int public _decimals_ = 10 ** 2;
    string private constant _apiBaseURL_ = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD,JPY,EUR";
    string public constant _apiPath_ = "USD";
    

    constructor()
       LinkPoolUintOracle (
           _decimals_,
           _apiBaseURL_,
           _apiPath_
       ) {
    }
}