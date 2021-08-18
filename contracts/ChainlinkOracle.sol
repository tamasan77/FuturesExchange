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
    uint256 private result;

    address private oracleAddress;
    bytes32 private jobId;

    //uint8 private decimals;

    uint256 private fee;

    //event Received(message.sender, msg.value);

    constructor() {
        //Kovan link address
        address _link = 0xa36085F69e2889c224210F603D836748e7dC0088;
        if (_link ==address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }

        //kovan node oracle
        oracleAddress = 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455;
        jobId = "b6602d14e4734c49a5e1ce19d45a4632";

        //rinkeby node oracle
        /*
        oracleAddress = 0x3CE9f959d2961b7CE7f7C5AaBbA11fBCA23868a7;
        jobId = "70282998bad444c0a42aba1eb5a31cea";
        */
        fee =  0.1 * 10 ** 18; //0.1 LINK
    }

    //Create Chainlink request with uint256 job
    function requestIndexPrice() external returns (bytes32 requestId) {

        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        request.add("get", "https://valuation-api.herokuapp.com/price/45.0/0.1/0/15778476");
        //set path to data
        request.add("path", "price");
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
    /*
    function append(string memory a, string memory b, string memory c, string memory d, string memory e, string memory f) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c, d, e, f));
    }
    */

    //fallback function to receive eth
    receive() external payable {

    }


    function getResult() external view returns (uint256) {
        return result;
    }
}

