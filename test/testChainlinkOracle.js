/*
const ChainlinkOracle = artifacts.require("./ChainlinkOracle.sol");

contract("ChainlinkOracle", accounts => {
    it("should be able to get price from valuation oracle", async function() {
        const chainlinkOracleInstance = await ChainlinkOracle.deployed();

        await chainlinkOracleInstance.requestIndexPrice();
        let result = await chainlinkOracleInstance.getResult();
        assert.equal(result.words[0], 47, "price result incorrect");
    })
});
*/

/*
it takes time for the job request to get fulfilled so I tested manually first
*/