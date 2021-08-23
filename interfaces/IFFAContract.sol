// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "../contracts/CollateralWallet.sol";

interface IFFAContract {

    event CreatedContract(uint decimals, uint256 sizeOfContract);
    event Initiated(address indexed long, address indexed short, uint256 initialForwardPrice, uint riskFreeRate, uint256 expirationDate, uint256 sizeOfContract);
    //event Valuated(uint8 riskFreeRate, int256 indexPrice, uint256 valuationDate, int256 forwardValue);
    event MarkedToMarket(uint256 mtmDate, int256 contractValueChange, address long, address short);
    event Settled(address long, address short, uint256 expirationDate, int256 profitAndLoss);
    event Defaulted(uint256 defaultDate, address defaultingParty);

    function initiateFFA(address _long, address _short, uint256 _forwardPrice, 
                            uint _riskFreeRate, uint256 _expirationDate,
                             address _longWallet, address _shortWallet) 
                             external returns (bool initiated_);
    //function calcFFAValue() external returns (uint256 value_);
    function markToMarket() external returns (bool markedToMarket_);
    function settleAtExpiration() external returns (bool settled_);
    function defaultContract(address _defaultingParty) external returns (bool defaulted_);
}