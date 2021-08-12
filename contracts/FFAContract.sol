// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "../utils/BokkyPooBahsDateTimeLibrary.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interfaces/IFFAContract.sol";
import "./ChainlinkOracle.sol";
import "./CollateralWallet.sol";

contract FFAContract is IFFAContract{
        using SafeERC20 for IERC20;

        //state of contract
        enum ContractState {Created, Initiated, Settled, Defaulted}

        //contract detail
        string private name;
        string private symbol;
        uint8 private decimals;
        ContractState public contractState;
        uint256 private sizeOfContract;
        address private long;
        address private short;
        uint256 private forwardPrice;
        uint8 private riskFreeRate;
        uint256 private expirationDate;

        //collateral wallets
        address private longWallet;
        address private shortWallet;


        //margin requirements
        uint256 private initialMargin;
        uint256 private maintenanceMargin;

        //valuation
        int256 private value;
        uint256 private valuationDate;

        //underlying index price oracle
        //address private oracleAddress;
        //bytes32 private jobId;
        ChainlinkOracle internal valuationOracle;

        //add events to interface
        /*
        event CreatedContract(uint8 decimals, uint256 sizeOfContract);
        event Initiated(address indexed long, address indexed short, uint256 forwardPrice, uint8 riskFreeRate, uint256 expirationDate);
        event Valuated(uint8 riskFreeRate, int256 indexPrice, uint256 valuationDate, int256 forwardValue);
        event MarkedToMarket(uint256 mtmDate, int256 dailyPayoff, address long, address short);
        event Settled(address long, address short, uint256 expirationDate);
        event Defaulted(uint256 defaultDate, address defaultingParty);*/

        constructor(
            string memory _name, 
            string memory _symbol, 
            //address _oracleAddress,
            //bytes32 _jobId, 
            uint8 _decimals,
            uint256 _sizeOfContract
        ) {
            name = _name;
            symbol = _symbol;
            //oracleAddress = _oracleAddress;
            //jobId = _jobId;
            decimals = _decimals;
            sizeOfContract = _sizeOfContract;
            //valuationOracle = new ChainlinkOracle(oracleAddress, jobId);//not sure
            contractState = ContractState.Created;
            emit CreatedContract(decimals, sizeOfContract);
        }

        //initiation
        function initiateFFA(address _long, address _short, uint256 _forwardPrice, 
                             uint8 _riskFreeRate, uint256 _expirationDate,
                             address _longWallet, address _shortWallet) 
                             external override returns (bool initiated_) {
            require(_long != address(0), "Long can't be zero address");
            require(_short != address(0), "Short can't be zero address");
            require(_long != _short, "Long and short can't be same party");
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(block.timestamp, _expirationDate) > 0, "FFA contract has to expire in the future");
            long = _long;
            short = _short;
            forwardPrice = _forwardPrice;
            riskFreeRate = _riskFreeRate;
            expirationDate = _expirationDate;
            longWallet = _longWallet;
            shortWallet = _shortWallet;
            contractState = ContractState.Initiated;
            //Do i need to deal with allowance?
            emit Initiated(long, short, forwardPrice, riskFreeRate, expirationDate);
            initiated_ = true;
        }

        //calculate value of contract
        function calcFFAValue() external override returns (uint256 value_) {
            valuationDate = block.timestamp;
            //use valuation oracle here
            
            value_ = 0;
        }

        //mark to market
        function markToMarket() external override returns (bool markedToMarket_) {
            //check requirements
            require(contractState == ContractState.Initiated, "Contract has to be in Initiated state");
            //require(BokkyPooBahsDateTimeLibrary.diffSeconds(block.timestamp, expirationDate) > 0, "M to m can only happen before expiration");
            //check allowance if neccessary here

            //calculate net daily payoff
            int256 dailyPayoff = 0;

            //delivery within collateral wallets

            //emit event
            emit MarkedToMarket(block.timestamp, dailyPayoff, long, short);
            markedToMarket_ = true;
        }

        //settle contract 
        function settleAtExpiration() public override returns (bool settled_) {
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(expirationDate, block.timestamp) >= 0, "Settlement cannot occure before expiration date" );
            require(contractState == ContractState.Initiated, "Contract has to be in Initiated state");

            //change contract state and emit event
            contractState = ContractState.Settled;
            emit Settled(long, short, expirationDate);
            settled_ = true;
        }

        //default contract
        function defaultContract(address _defaultingParty) public override returns (bool defaulted_) {
            require(contractState == ContractState.Initiated, "Contract has to be in Initiated state");
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(block.timestamp, expirationDate) > 0, "Defaulting can only happen before expiration");

            //change contract state and emit event
            contractState = ContractState.Defaulted;
            emit Defaulted(block.timestamp, _defaultingParty);
            defaulted_ = true;
        }

        function transferCollateralFrom(CollateralWallet senderWallet, CollateralWallet recipientWallet, uint256 amount, address collateralTokenAddress) internal returns (bool transfered_){
            uint256 originalSenderMappedBalance = senderWallet.getMappedBalance(address(this), collateralTokenAddress);
            require(originalSenderMappedBalance >= amount, "collateral balance not sufficient");

            IERC20(collateralTokenAddress).safeTransfer(address(recipientWallet), amount);

            //deduct from sender balance mapping
            unchecked {
                uint256 newSenderMappedBalance = originalSenderMappedBalance - amount;
                senderWallet.setNewBalance(address(this), collateralTokenAddress, newSenderMappedBalance);
            }

            //add to recipient balance mapping
            uint256 newRecipientMappedBalance = recipientWallet.getMappedBalance(address(this), collateralTokenAddress) + amount;
            recipientWallet.setNewBalance(address(this), collateralTokenAddress, newRecipientMappedBalance);

            transfered_ = true;
        }

        //these are for testing
        /////////////////////////////////////
        address[] private collateralWallets;

        function createCollateralWallet(string memory _name) external returns(address walletAddress_) {
            walletAddress_ = address(new CollateralWallet(_name));
            collateralWallets.push(walletAddress_);
        }

        function getCollateralWallets(uint256 index) external view returns(CollateralWallet) {
            return CollateralWallet(collateralWallets[index]);
        }
        //////////////////////////////////////

        //what about receive and fallback functions?

        //getter functions
        function getContractState() external view returns(string memory) {
            if (contractState == ContractState.Created) {
                return "Created";
            } else if (contractState == ContractState.Initiated) {
                return "Initiated";
            } else if (contractState == ContractState.Settled) {
                return "Settled";
            } else if (contractState == ContractState.Defaulted) {
                return "Defaulted";
            } else {
                return "state error";
            }
        }

        function getName() external view returns(string memory) {
            return name;
        }

        function getSymbol() external view returns(string memory) {
            return symbol;
        }
        
        function getSizeOfContract() external view returns(uint256) {
            return sizeOfContract;
        }

        function getDecimals() external view returns (uint8) {
            return decimals;
        }

        function getLong() external view returns (address) {
            return long;
        }

        function getShort() external view returns (address) {
            return short;
        }

        function getForwardPrice() external view returns (uint256) {
            return forwardPrice;
        }

        function getRiskFreeRate() external view returns (uint8) {
            return riskFreeRate;
        }

        function getExpirationDate() external view returns (uint256) {
            return expirationDate;
        }

        function getLongWalletAddress() external view returns (address) {
            return longWallet;
        }

        function getShortWalletAddress() external view returns (address) {
            return shortWallet;
        }




}