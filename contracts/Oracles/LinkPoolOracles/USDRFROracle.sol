// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./LinkPoolOracle.sol";

/* Using https://www.quandl.com/data/USTREASURY/BILLRATES-Treasury-Bill-Rates
 * Risk free rate is usually considered to be equal to interest paid on 3-month T-bill
 * Techincally the risk free rate returned should also depend on the forward contract's 
 * time period.
 * Calculating the risk free rate: 
 * https://www.orionstartups.com/research/how-to-calculate-the-risk-free-rate
 */