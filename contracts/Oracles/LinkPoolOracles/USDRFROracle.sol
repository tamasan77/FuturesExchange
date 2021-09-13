// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "./LinkPoolIntOracle.sol";

/* Using https://www.quandl.com/data/USTREASURY/BILLRATES-Treasury-Bill-Rates
 * Risk free rate is usually considered to be equal to interest paid on 3-month T-bill
 * Techincally the risk free rate returned should also depend on the forward contract's 
 * time period.
 * Calculating the risk free rate: 
 * https://www.orionstartups.com/research/how-to-calculate-the-risk-free-rate
 * WATCH OUT: rate can be negative!!!
 * Put API key in .env file
 *
 * have start_date be an adjustable parameter:
 * depending on the current date and the expiration date the risk free rate can be 
 * determined from T-bills with various maturity trenches.
 * We expect standard forward contracts to be up to twelve month. (anything beyond that would be a long-dated forward)
 * In the quandl API here is how to get various maturity tranches according data[n] array index:
 * "column_names":[
		"Date",
		"4 Wk Bank Discount Rate", (index 1)
		"4 Wk Coupon Equiv",
		"8 Wk Bank Discount Rate", (index 3)
		"8 Wk Coupon Equiv",
		"13 Wk Bank Discount Rate", (index 5)
		"13 Wk Coupon Equiv",
		"26 Wk Bank Discount Rate", (index 7)
		"26 Wk Coupon Equiv",
		"52 Wk Bank Discount Rate", (index 9)
		"52 Wk Coupon Equiv"],
 * - for 0-6weeks expiration we'll use 4Wk rate
 * - for 7-10weeks use 8Wk rate
 * - for 11-19weeks use 13Wk rate
 * - for 20-39weeks use 26Wk rate
 * - for 40+ weeks use 52Wk rate
 *
 * Watch out for decimals for risk free rates!! Data is given as percentage
 * Decimal convention for risk free rate: 1.23 => 1.23 % => scale by 1:100 => 123
 */

contract USDRFROracle is LinkPoolIntOracle {
    int public _decimals_ = 10 ** 2;
    //need to add API key to base URL
    //start date will be a api URL parameter
    string public constant _apiBaseURL_ = "https://www.quandl.com/api/v3/datasets/USTREASURY/BILLRATES.json?api_key=MY_KEY";
    //use 0 index for data array since we always want the most recent value
    string public  _apiPathBase_ = "dataset.data.0.";//correct thsi (it is not correct syntax and also it's fixed 4 Wk rate)

    constructor(
    ) LinkPoolIntOracle(
        _decimals_,
        _apiBaseURL_,
        ""
    ) {}

    function calcMaturityTranchIndex(uint contractDurationInSeconds) internal pure returns(uint) {
        if (contractDurationInSeconds <= 3628800) {// <=4 weeks
            return 1;
         } else if ((3628800 < contractDurationInSeconds) && (contractDurationInSeconds <= 6048000)) {
            return 2;
         } else if ((6048000 < contractDurationInSeconds) && (contractDurationInSeconds <= 11491200)) {
            return 3;
         } else if ((11491200 < contractDurationInSeconds) && (contractDurationInSeconds <= 23587200)) {
            return 4;
         } else {
            return 5;
         }
    }

    function updateAPIPath(uint contractDurationInSeconds)  external {
         setAPIPath(string(abi.encodePacked(_apiPathBase_, calcMaturityTranchIndex(contractDurationInSeconds)))); 
    }

    function concetanateStringUint(string memory a, uint b) internal pure returns (string memory){
        return string(abi.encodePacked(a, uint2str(b)));
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
}