const { assert } = require("chai");

const FFAFactory = artifacts.require("./FFAFactory.sol");
const FFAContract = artifacts.require("./FFAContract.sol");

contract("FFAFactory", accounts => {
    it("should be able to create FFAContract", async function() {
        const ffaFactoryInstance = await FFAFactory.deployed();

        const name = "Test 1";
        const symbol = "TEST";
        //const oracleAddress = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;//why does this need quotes?
        //const jobId = "0x29fa9aa13bf1468788b7cc4a500a45b8";
        const decimals = 10;
        const sizeOfContract = 100;

        const result = await ffaFactoryInstance.createFFAContract(name, symbol, decimals, sizeOfContract, {from : accounts[0]});
        
        const ffaContract = await ffaFactoryInstance.getFFAContract(0);
        const ffaContractInstance = await FFAContract.at(ffaContract);

        const ffaContractName = await ffaContractInstance.getName();
        const ffaContractSymbol = await ffaContractInstance.getSymbol();
        const ffaContractSize = await ffaContractInstance.getSizeOfContract();
        const ffaContractDecimals = await ffaContractInstance.getDecimals();
        assert.equal(ffaContractName, name, "names should be equal");
        assert.equal(ffaContractSymbol, symbol, "symbol should be equal");
        assert.equal(ffaContractSize, sizeOfContract, "size should be equal");
        assert.equal(ffaContractDecimals, decimals, "decimals should be equal");

    })
});