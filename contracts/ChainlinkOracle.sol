// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IChainlinkOracle.sol";


contract ChainlinkOracle is ChainlinkClient, Ownable,  IChainlinkOracle{
    //after v0.7 it is neccessary to repeat using statement in all of the derived contracts
    using Chainlink for Chainlink.Request;


    //store answer from oracle
    uint256 private result;

    //oracle and job info
    /* The reason I don't set these to a constant value is because
     * sometimes different chainlink nodes and jobs stop/start working.
     */
    address public oracleAddress;
    bytes32 public jobId;

    //could these be bytes(x) instead of string?

    //URL to make GET request from
    string private apiURL;

    //path for API response
    string private apiPath;

    //address of the link contract address for given network
    address public linkAddress;//I could set this here as a constant as it wouldn't change--------------

    //deal with decimals
    int8 public decimals;

    //fee is usually 0.1Link which is equal to (0.1 * 10 ** 18)
    uint256 public fee;

    constructor(address _oracleAddress, bytes32 _jobId, string memory _apiURL, string memory _apiPath, address _linkAddress, uint256 _fee, int8 _decimals) {  
        //Kovan link
        /*
            address _link = 0xa36085F69e2889c224210F603D836748e7dC0088;
            if (_link ==address(0)) {
                setPublicChainlinkToken();
            } else {
                setChainlinkToken(_link);
            }

            //kovan node oracle
            oracleAddress = 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455;
            jobId = "b6602d14e4734c49a5e1ce19d45a4632";

            fee =  0.1 * 10 ** 18; //0.1 LINK
        */

        oracleAddress = _oracleAddress;
        jobId = _jobId;
        apiURL = _apiURL;
        apiPath = _apiPath;
        linkAddress = _linkAddress;
        fee = _fee;
        decimals = _decimals;
    }

    //Create Chainlink request with uint256 job
    function requestIndexPrice() external override returns (bytes32 requestId) {

        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        request.add("get", apiURL);
        //set path to data
        request.add("path", apiPath);
        request.addInt("times", decimals);
        //send request with given fee to the oracle
        requestId = sendChainlinkRequestTo(oracleAddress, request, fee);
        emit RequestSent(oracleAddress, jobId, fee);
    }

    //receive response as uint256
    //recordChainlinkFulffilment ensures that only requesting oracle can fulfill
    function fulfill(bytes32 _requestId, uint256 _result) external override recordChainlinkFulfillment(_requestId){
        result = _result;
        emit Fulfilled(_requestId);
    }

    // withdrawLink allows the owner to withdraw any extra LINK on the contract
    function withdrawLink() external override onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        uint256 linkBalance = link.balanceOf(address(this));
        require(link.transfer(msg.sender, linkBalance), "Unable to withdraw");
        emit LinkWithdrawn(msg.sender, linkBalance);
    }

    //fallback function to receive eth
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback () external payable {

    }

    function getResult() external view returns (uint256) {
        return result;
    }
}

