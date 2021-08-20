// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "../ChainlinkOracle.sol";

contract UnderlyingPriceOracleBTCUSD is ChainlinkOracle {
    string private constant apiURL = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD,JPY,EUR";
    string public constant apiPath = "USD";
    

    constructor(
        address oracleAddress,
        bytes32 jobId,
        address linkAddress,
        uint256 fee) 
        ChainlinkOracle (
            oracleAddress,
            jobId,
            apiURL, 
            apiPath,
            linkAddress,
            fee,
            100
        ) {
    }
}