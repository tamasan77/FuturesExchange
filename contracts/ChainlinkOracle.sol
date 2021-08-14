// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/* Following the documentation at:
 * https://docs.chain.link/docs/make-a-http-get-request/
 */
contract ChainlinkOracle is ChainlinkClient, Ownable {
    //after v0.7 it is neccessary to repeat using statement in all of the derived contracts
    using Chainlink for Chainlink.Request;


    //store answer from oracle
    uint256 public result;

    address private oracleAddress;
    bytes32 private jobId;

    //uint8 private decimals;

    uint256 private fee;

    constructor() {
        setPublicChainlinkToken();
        oracleAddress = 0xcd955CF975fBb52C13426BaA2022f8dB6093bDd0;
        jobId = "1e9f083e038144749052a5877b8871a7";
        fee =  0.1 * 10 ** 18; //0.1 LINK
    }

    //Create Chainlink request with uint256 job
    function requestIndexPrice() external returns (bytes32 requestId) {

        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        request.add("get", "http://127.0.0.1:5000/price/45.0/0.1/0/15778476");
        //set path to data
        request.add("path", "value");
        //depending on the format of the price data, multiply by 10^decimals
        //find out how to do exponentials
        //to remove decimals
        int numScale = 1; //this needs adjustment!!!!!!!!!!!!!!!!!!!1
        request.addInt("times", numScale);
        //send request with given fee to the oracle
        return sendChainlinkRequestTo(oracleAddress, request, fee);
    }

    //receive response as uint256
    //recordChainlinkFulffilment ensures that only requesting oracle can fulfill
    function fulfill(bytes32 _requestId, uint256 _price) external recordChainlinkFulfillment(_requestId){
        result = _price;
    }

    // withdrawLink allows the owner to withdraw any extra LINK on the contract
    //taken from documentation:
    //https://remix.ethereum.org/#version=soljson-v0.6.12+commit.27d51765.js&optimize=false&gist=7cae2cc64026ea69073ee76a32dd0268&evmVersion=null&runs=200
    function withdrawLink() external onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to withdraw");
    }

    //for the time being this function can only concatenate 6 strings
    function append(string memory a, string memory b, string memory c, string memory d, string memory e, string memory f) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c, d, e, f));
    }

    function getResult() external view returns (uint256) {
        return result;
    }
}

