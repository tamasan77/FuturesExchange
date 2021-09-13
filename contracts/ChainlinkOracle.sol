// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IChainlinkOracle.sol";


contract ChainlinkOracle is ChainlinkClient, Ownable,  IChainlinkOracle{
    //after v0.7 it is neccessary to repeat using statement in all of the derived contracts
    using Chainlink for Chainlink.Request;


    //store answer from oracle
    bool public isSignedResult;
    uint256 private unsignedResult;
    int256 private signedResult;

    //oracle and job info
    /* The reason I don't set these to a constant value is because
     * sometimes different chainlink nodes and jobs stop/start working.
     */
    address public oracleAddress;
    bytes32 public jobId;


    //path for API response can either be a string or a string array
    string private apiPath;
    string[] private apiPathArray;

    string private apiBaseURL;

    //deal with decimals
    int public decimals;

    //fee is usually 0.1Link which is equal to (0.1 * 10 ** 18)
    uint256 public fee;

    constructor(address _oracleAddress, bytes32 _jobId, 
                address linkAddress, uint256 _fee, int _decimals, 
                string memory _apiBaseURL, string memory _apiPath, 
                bool _isSignedResult) 
    {  
        if (linkAddress == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(linkAddress);
        }
        oracleAddress = _oracleAddress;
        jobId = _jobId;
        fee = _fee;
        decimals = _decimals;
        apiBaseURL = _apiBaseURL;
        apiPath = _apiPath;
        isSignedResult = _isSignedResult;
    }

    //Create Chainlink request with uint256 job
    //apiURLParameters is empty string for underlying oracles
    function requestIndexPrice(string memory apiURLParameters) external override returns (bytes32 requestId) {
        Chainlink.Request memory request;
        if (isSignedResult) {
            request = buildChainlinkRequest(jobId, address(this), this.fulfillSigned.selector);
        } else {
            request = buildChainlinkRequest(jobId, address(this), this.fulfillUnsigned.selector);
        }

        request.add("get", concetenateTwoStrings(apiBaseURL, apiURLParameters));
        //set path to data
        request.add("path", apiPath);
        request.addInt("times", decimals);
        //send request with given fee to the oracle
        requestId = sendChainlinkRequestTo(oracleAddress, request, fee);
        emit RequestSent(oracleAddress, jobId, fee);
    }

    //receive response as uint256
    //recordChainlinkFulffilment ensures that only requesting oracle can fulfill
    function fulfillSigned(bytes32 _requestId, int256 _result) external override recordChainlinkFulfillment(_requestId){
        signedResult = _result;
        emit Fulfilled(_requestId);
    }

    function fulfillUnsigned(bytes32 _requestId, uint256 _result) external override recordChainlinkFulfillment(_requestId){
        unsignedResult = _result;
        emit Fulfilled(_requestId);
    }


    // withdrawLink allows the owner to withdraw any extra LINK on the contract
    function withdrawLink() external override onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        uint256 linkBalance = link.balanceOf(address(this));
        require(link.transfer(msg.sender, linkBalance), "Unable to withdraw");
        emit LinkWithdrawn(msg.sender, linkBalance);
    }

    /*
    //concatanate strings and add /  where needed for URL
    function concetenateStringsForURL(string memory a, string memory b, string memory c, string memory d, string memory e) internal pure returns (string memory) {
	    return string(abi.encodePacked(a,"/", b, "/", c, "/", d, "/", e));
    }*/

    /*
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
    }*/

    //concatanate two strings
    function concetenateTwoStrings(string memory a, string memory b) internal pure returns(string memory) {
        return string(abi.encodePacked(a, b));
    }

    //fallback function to receive eth
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback () external payable {

    }

    function getUnsignedResult() external view returns (uint256) {
        return unsignedResult;
    }

    function getSignedResult() external view returns (int256) {
        return signedResult;
    }
}

