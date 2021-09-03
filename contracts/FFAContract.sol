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
import "./Oracles/LinkPoolOracles/LinkPoolValuationOracle.sol";
import "./Oracles/LinkPoolOracles/LinkPoolUintOracle.sol";
import "./Oracles/LinkPoolOracles/USDRFROracle.sol";

contract FFAContract is IFFAContract{
    using SafeERC20 for IERC20;
    //state of contract
    enum ContractState {Created, Initiated, Settled, Defaulted}
    //contract detail
    string private name;
    string private symbol;
    ContractState internal contractState;
    uint256 private sizeOfContract;
    address internal long;
    address internal short;
    uint256 private initialForwardPrice;
    uint public annualRiskFreeRate;
    uint256 internal expirationDate;
    uint256 private underlyingPrice;//scaled 1/100 ie. 45.07 -> 4507
    //collateral wallets
    address private longWallet;
    address private shortWallet;
    address private collateralTokenAddress;
    //margin requirements
    //MM(8%) + EM (2%) = IM (10%)
    uint public exposureMarginRate;
    uint public maintenanceMarginRate;
    //M2M
    uint256 public prevDayClosingPrice;
    //underlying index price oracle
    string private underlyingApiURL;
    string private underlyingApiPath;
    int public underlyingDecimals;
    LinkPoolValuationOracle valuationOracle;
    LinkPoolUintOracle underlyingOracle;
    USDRFROracle usdRiskFreeRateOracle;
    uint8 private rfrMaturityTranchIndex;

    constructor(
            string memory _name, 
            string memory _symbol, 
            uint256 _sizeOfContract,
            string memory _underlyingApiURL,
            string memory _underlyingApiPath,
            int _underlyingDecimals
            //address _collateralTokenAddress,
    ) {
        name = _name;
        symbol = _symbol;
        sizeOfContract = _sizeOfContract;
        underlyingApiPath = _underlyingApiPath;
        underlyingApiURL = _underlyingApiURL;
        underlyingDecimals = _underlyingDecimals;
        //collateralTokenAddress = _collateralTokenAddress;
        valuationOracle = new LinkPoolValuationOracle();
        underlyingOracle = new LinkPoolUintOracle(underlyingDecimals, underlyingApiURL, underlyingApiPath);
        contractState = ContractState.Created;
        //emit CreatedContract(decimals, sizeOfContract);
    }

    //initiateFFA: initiates futures contract with given parameters
    function initiateFFA(address _long, address _short, uint256 _initialForwardPrice, 
                         uint256 _expirationDate,
                         address _longWallet, address _shortWallet, uint _exposureMarginRate,
                         uint _maintenanceMarginRate, address _collateralTokenAddress) 
                         external override returns (bool initiated_) {
        require(_long != address(0), "Long can't be zero address");
        require(_short != address(0), "Short can't be zero address");
        require(_long != _short, "Long and short can't be same party");
        require(_longWallet != address(0), "Long wallet cannot have zero address");
        require(_shortWallet != address(0), "Short wallet cannot have zero address");
        require(_longWallet != _shortWallet, "long and short wallets cannot be the same");
        require(_maintenanceMarginRate != 0, "maintenance margin rate cannot be zero");
        require(BokkyPooBahsDateTimeLibrary.diffSeconds(block.timestamp, _expirationDate) > 0, "FFA contract has to expire in the future");
        long = _long;
        short = _short;
        //call valuation API to get initialForwardPrice!!!!!!!!!!!!!11
        initialForwardPrice = _initialForwardPrice;
        prevDayClosingPrice = initialForwardPrice;
        //annualRiskFreeRate = _annualRiskFreeRate;
        expirationDate = _expirationDate;
        longWallet = _longWallet;
        shortWallet = _shortWallet;
        exposureMarginRate = _exposureMarginRate;
        maintenanceMarginRate = _maintenanceMarginRate;
        collateralTokenAddress = _collateralTokenAddress;
        contractState = ContractState.Initiated;
        //Do i need to deal with allowance?
        uint initialMarginRate = exposureMarginRate + maintenanceMarginRate;
        emit Initiated(long, short, initialForwardPrice, annualRiskFreeRate, expirationDate, sizeOfContract, initialMarginRate);
        initiated_ = true;
    }

    //request underlying price
    function requestUnderlyingPrice() public {
        underlyingOracle.requestIndexPrice("");
    }

    //set underlying price once job is fulfilled
    function setUnderlyingPrice() public {
        underlyingPrice = underlyingOracle.getUnsignedResult();
    }

    //request forward price
    function requestForwardPrice() public  {
        valuationOracle.requestIndexPrice(concetenateStringsForURL(uint2str(underlyingPrice), uint2str(annualRiskFreeRate), uint2str(block.timestamp), uint2str(expirationDate)));
    }

    //set forward price once job is fulfilled
    function getForwardPrice() public view returns(uint256){
        return valuationOracle.getUnsignedResult();
    }

    //concatanate strings and add /  where needed for URL
    function concetenateStringsForURL(string memory a, string memory b, string memory c, string memory d) internal pure returns (string memory) {
	    return string(abi.encodePacked(a,"/", b, "/", c, "/", d));
    }

    
    //parse uint to string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    /*  Margin calculation
        * Initial Margin = Maintenance Margin + Exposure Margin
        * A margin call is issued when a party's cash balance drops below the maintenance margin.
        * A party will be allowed to hold their position as long as the maintenance margin is satisfied.
        * M2M is calculated based on the previous day's closing price. Based on the M2M each party's
        * account is credited or debited daily. 
        * At settlement calculate the P&L = Final Contract Value - Initial Contract Value
        * https://zerodha.com/varsity/chapter/margin-m2m/
    */

    /* markToMarket : does mark to market daily */
    function markToMarket(uint256 currentForwardPrice) external override {
        require(contractState == ContractState.Initiated, 
                "Contract has to be in Initiated state");
        require(BokkyPooBahsDateTimeLibrary.diffSeconds(block.timestamp, expirationDate) > 0, 
                "M to m can only happen before expiration");
        
        //current forward price needs to be updated
        uint256 newContractValue = currentForwardPrice * sizeOfContract;
        uint256 oldContractValue = prevDayClosingPrice * sizeOfContract;
        //contract value change
        int contractValueChange = int256(newContractValue) - int256(oldContractValue);

        //delivery within collateral wallets
        //In this case the amount to be transfered is in cents, not dollars due to 1:100 scaling
        if (contractValueChange > 0) {
            transferCollateralFrom(shortWallet, longWallet, 
                                   uint256(contractValueChange), collateralTokenAddress);
        }
        if (contractValueChange < 0) {
            transferCollateralFrom(longWallet, shortWallet, 
                                   uint256(-contractValueChange), 
                                   collateralTokenAddress);
        }

        //update prevDayClosingPrice to current price
        prevDayClosingPrice = currentForwardPrice;
        
        emit MarkedToMarket(block.timestamp, contractValueChange, long, short);
    }
    //settle contract 
    function settleAtExpiration() external override {
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(expirationDate, block.timestamp) >= 0, "Settlement cannot occure before expiration date" );
            require(contractState == ContractState.Initiated, "Contract has to be in Initiated state");

            //calculate P&L
            uint256 initialContractValue = initialForwardPrice * sizeOfContract;
            uint256 finalContractValue = prevDayClosingPrice * sizeOfContract;
            int profitAndLoss = int256(finalContractValue) - int256(initialContractValue);

            //change contract state and emit event
            contractState = ContractState.Settled;
            emit Settled(long, short, expirationDate, profitAndLoss);
            //settled_ = true;
    }

    /* What happens when futures/forward contract counterparty defaults?
     * https://money.stackexchange.com/questions/46475/what-happens-if-futures-contract-seller-defaults
     * In this case we assume that the losing party's collateral wallet will always have enough funds to
     * cover losses.
     * A party can "terminate" the forward contract by entering another same contract taking the opposite
     * position. 
     * https://financetrain.com/forward-contract-termination-prior-to-expiry/
     */
    //default contract
    function defaultContract(address _defaultingParty) public override returns (bool defaulted_) {
            require(contractState == ContractState.Initiated, "Contract has to be in Initiated state");
            require(BokkyPooBahsDateTimeLibrary.diffSeconds(block.timestamp, expirationDate) > 0, "Defaulting can only happen before expiration");

            //change contract state and emit event
            contractState = ContractState.Defaulted;
            emit Defaulted(block.timestamp, _defaultingParty);
            defaulted_ = true;
    }
    /* transferCollateralFrom: transfers given amount of given token from one 
     *collateral wallet to the other*/
    function transferCollateralFrom(address senderWalletAddress, 
            address recipientWalletAddress, uint256 amount, 
            address _collateralTokenAddress) public returns (bool transfered_){

            require(senderWalletAddress != address(0), 
                    "Sender wallet address cannot be zero");
            require(recipientWalletAddress != address(0), 
                    "Recipient wallet address cannot be zero");
            require(recipientWalletAddress != senderWalletAddress, 
                    "Sender and recipient wallets cannot be the same");
            require(amount > 0, 
                    "Amount transferred has to be greater than zero");
            CollateralWallet senderWallet = CollateralWallet(senderWalletAddress);
            CollateralWallet recipientWallet = CollateralWallet(recipientWalletAddress);
            uint256 originalSenderMappedBalance = senderWallet.getMappedBalance(
                                                                address(this), 
                                                                _collateralTokenAddress);
            require(originalSenderMappedBalance >= amount, 
                    "collateral balance not sufficient");

            //approval might need fixing
            senderWallet.approveSpender(_collateralTokenAddress, 
                                        address(this), amount);
            IERC20(_collateralTokenAddress).transferFrom(senderWalletAddress, 
                                                         recipientWalletAddress, 
                                                         amount);

            //deduct from sender balance mapping
            unchecked {
                uint256 newSenderMappedBalance = originalSenderMappedBalance - amount;
                senderWallet.setNewBalance(address(this), _collateralTokenAddress, 
                                           newSenderMappedBalance);
            }

            //add to recipient balance mapping
            uint256 newRecipientMappedBalance = recipientWallet.getMappedBalance(
                                                                    address(this), 
                                                                    _collateralTokenAddress) 
                                                                    + amount;
            recipientWallet.setNewBalance(address(this), _collateralTokenAddress, 
                                          newRecipientMappedBalance);
 
            transfered_ = true;
    }

    //receive and fallback functions
    /*
        receive () external payable {
        
        }
        fallback () external payable {
    }*/
    
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
    function getUnderlyingDecimals() external view returns (int) {
        return underlyingDecimals;
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
    function getExpirationDate() external view returns (uint256) {
            return expirationDate;
    }
    function getLongWalletAddress() external view returns (address) {
            return longWallet;
    }
    function getShortWalletAddress() external view returns (address) {
            return shortWallet;
    }

    function getUnderlyingApiURL() external view returns (string memory) {
        return underlyingApiURL;
    }

    function getUnderlyingApiPath() external view returns (string memory) {
        return underlyingApiPath;
    }

}