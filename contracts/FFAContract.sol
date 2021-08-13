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
        uint256 private initialForwardPrice;
        uint8 private riskFreeRate;
        uint256 private expirationDate;

        //collateral wallets
        address private longWallet;
        address private shortWallet;
        address private collateralTokenAddress;


        //margin requirements
        uint256 private exposureMarginRate;
        uint256 private maintenanceMarginRate;

        //M2M
        uint256 private prevDayClosingPrice;

        //valuation
        //int256 private contractValue;
        uint256 private pricingDate;

        //underlying index price oracle
        //address private oracleAddress;
        //bytes32 private jobId;
        ChainlinkOracle internal valuationOracle;

        constructor(
            string memory _name, 
            string memory _symbol, 
            //address _oracleAddress,
            //bytes32 _jobId, 
            uint8 _decimals,
            uint256 _sizeOfContract,
            address _collateralTokenAddress
        ) {
            name = _name;
            symbol = _symbol;
            //oracleAddress = _oracleAddress;
            //jobId = _jobId;
            decimals = _decimals;
            sizeOfContract = _sizeOfContract;
            collateralTokenAddress = _collateralTokenAddress;
            //valuationOracle = new ChainlinkOracle(oracleAddress, jobId);//not sure
            contractState = ContractState.Created;
            emit CreatedContract(decimals, sizeOfContract);
        }

        //initiation
        function initiateFFA(address _long, address _short, uint256 _initialForwardPrice, 
                             uint8 _riskFreeRate, uint256 _expirationDate,
                             address _longWallet, address _shortWallet) 
                             external override returns (bool initiated_) {
            require(_long != address(0), "Long can't be zero address");
            require(_short != address(0), "Short can't be zero address");
            require(_long != _short, "Long and short can't be same party");
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(block.timestamp, _expirationDate) > 0, "FFA contract has to expire in the future");
            long = _long;
            short = _short;
            //call valuation API to get initialForwardPrice
            initialForwardPrice = _initialForwardPrice;
            prevDayClosingPrice = initialForwardPrice;
            riskFreeRate = _riskFreeRate;
            expirationDate = _expirationDate;
            longWallet = _longWallet;
            shortWallet = _shortWallet;
            contractState = ContractState.Initiated;
            //Do i need to deal with allowance?
            emit Initiated(long, short, initialForwardPrice, riskFreeRate, expirationDate, sizeOfContract);
            initiated_ = true;
        }

        //calculate value of contract
        /*
        function calcFFAValue() external override returns (uint256 value_) {
            pricingDate = block.timestamp;
            //use valuation oracle here
            
            value_ = 0;
        }*/

        //calculate forward price
        function calcForwardPrice() public returns (uint256 price_) {
            pricingDate = block.timestamp;

            //call valuation oracle here
            price_ = 243;
        }

        /*
            * Initial Margin = Maintenance Margin + Exposure Margin
            * A margin call is issued when a party's cash balance drops below the maintenance margin.
            * M2M is calculated based on the previous day's closing price. Based on the M2M each party's
            * account is credited or debited daily. 
            * At settlement calculate the P&L = Final Contract Value - Initial Contract Value
            * https://zerodha.com/varsity/chapter/margin-m2m/
        */
        //mark to market
        function markToMarket() external override returns (bool markedToMarket_) {
            require(contractState == ContractState.Initiated, "Contract has to be in Initiated state");
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(block.timestamp, expirationDate) > 0, "M to m can only happen before expiration");

            //valuation
            uint256 currentForwardPrice = calcForwardPrice();
            uint256 newContractValue = currentForwardPrice * sizeOfContract;
            uint256 oldContractValue = prevDayClosingPrice * sizeOfContract;
            //contract value change
            int256 contractValueChange = int256(newContractValue - oldContractValue);

            //delivery within collateral wallets
            if (contractValueChange > 0) {
                transferCollateralFrom(shortWallet, longWallet, uint256(contractValueChange), collateralTokenAddress);
            }
            if (contractValueChange < 0) {
                transferCollateralFrom(longWallet, shortWallet, uint256(-1 * contractValueChange), collateralTokenAddress);
            }

            //update prevDayClosingPrice to current price
            prevDayClosingPrice = currentForwardPrice;

            //emit event
            emit MarkedToMarket(block.timestamp, contractValueChange, long, short);
            markedToMarket_ = true;
        }

        //payoff at settlement
        /*
        function settlementPayoff() private returns (bool settlementPayoff_) {
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(expirationDate, block.timestamp) >= 0, "Settlement cannot occure before expiration date" );
            require(contractState == ContractState.Initiated, "Contract has to be in Initiated state");

        }*/

        //settle contract 
        function settleAtExpiration() external override returns (bool settled_) {
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(expirationDate, block.timestamp) >= 0, "Settlement cannot occure before expiration date" );
            require(contractState == ContractState.Initiated, "Contract has to be in Initiated state");

            //calculate P&L
            uint256 initialContractValue = initialForwardPrice * sizeOfContract;
            uint256 finalContractValue = prevDayClosingPrice * sizeOfContract;
            int256 profitAndLoss = int256(finalContractValue - initialContractValue);

            //change contract state and emit event
            contractState = ContractState.Settled;
            emit Settled(long, short, expirationDate, profitAndLoss);
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

        function transferCollateralFrom(address senderWalletAddress, address recipientWalletAddress, uint256 amount, address _collateralTokenAddress) public returns (bool transfered_){
            CollateralWallet senderWallet = CollateralWallet(senderWalletAddress);
            CollateralWallet recipientWallet = CollateralWallet(recipientWalletAddress);
            uint256 originalSenderMappedBalance = senderWallet.getMappedBalance(address(this), _collateralTokenAddress);
            require(originalSenderMappedBalance >= amount, "collateral balance not sufficient");

            //approval might need fixing
            senderWallet.approveSpender(_collateralTokenAddress, address(this), amount);
            IERC20(_collateralTokenAddress).transferFrom(senderWalletAddress, recipientWalletAddress, amount);

            //deduct from sender balance mapping
            unchecked {
                uint256 newSenderMappedBalance = originalSenderMappedBalance - amount;
                senderWallet.setNewBalance(address(this), _collateralTokenAddress, newSenderMappedBalance);
            }

            //add to recipient balance mapping
            uint256 newRecipientMappedBalance = recipientWallet.getMappedBalance(address(this), _collateralTokenAddress) + amount;
            recipientWallet.setNewBalance(address(this), _collateralTokenAddress, newRecipientMappedBalance);
 
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

        function getInitialForwardPrice() external view returns (uint256) {
            return initialForwardPrice;
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