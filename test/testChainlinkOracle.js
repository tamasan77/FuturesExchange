/*
const ChainlinkOracle = artifacts.require("./ChainlinkOracle.sol");

contract("ChainlinkOracle", accounts => {
    it("should be able to get price from valuation oracle", async function() {
        const chainlinkOracleInstance = await ChainlinkOracle.deployed();

        await chainlinkOracleInstance.requestIndexPrice();
        const result = await chainlinkOracleInstance.getResult();
        assert.equal(result, 47, "price result incorrect");
    })
});
*/