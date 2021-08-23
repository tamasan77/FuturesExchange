const { assert } = require("chai");

const FFAFactory = artifacts.require("./FFAFactory.sol");
const FFAContract = artifacts.require("./FFAContract.sol");

contract("FFAFactory", accounts => {
    it("should be able to create FFAContract and check for incorrect parameters", async function() {
        const ffaFactoryInstance = await FFAFactory.deployed();

        const name = "Test 1";
        const symbol = "TEST";
        //const oracleAddress = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;//why does this need quotes?
        //const jobId = "0x29fa9aa13bf1468788b7cc4a500a45b8";
        let sizeOfContract = 100;
        let maintenanceMarginRate = 1250;//this is 12.5%
        let expsoureMarginRate = 540;

        let decimals = 0;
        //check for zero decimals
        try{
            await ffaFactoryInstance.createFFAContract(name, symbol, decimals, sizeOfContract, expsoureMarginRate, maintenanceMarginRate, {from : accounts[0]});
        } catch(error) {
            decErr = error;
        }
        assert.notEqual(decErr, undefined, "Error must be thrown");

        decimals = 100;

        sizeOfContract = 0;
        //ceck for zero sizeOfContract
        try{
            await ffaFactoryInstance.createFFAContract(name, symbol, decimals, sizeOfContract, expsoureMarginRate, maintenanceMarginRate, {from : accounts[0]});
        } catch(error) {
            contractSizeErr = error;
        }
        assert.notEqual(contractSizeErr, undefined, "Error must be thrown");

        sizeOfContract = 100;

        maintenanceMarginRate = 0;
        try{
            await ffaFactoryInstance.createFFAContract(name, symbol, decimals, sizeOfContract, expsoureMarginRate, maintenanceMarginRate, {from : accounts[0]});
        } catch(error) {
            mmRateErr = error;
        }
        assert.notEqual(mmRateErr, undefined, "Error must be thrown");

        maintenanceMarginRate = 1250;

        await ffaFactoryInstance.createFFAContract(name, symbol, decimals, sizeOfContract, expsoureMarginRate, maintenanceMarginRate, {from : accounts[0]});
        
        const ffaContract = await ffaFactoryInstance.getFFAContract(0);
        const ffaContractInstance = await FFAContract.at(ffaContract);

        const ffaContractName = await ffaContractInstance.getName();
        const ffaContractSymbol = await ffaContractInstance.getSymbol();
        const ffaContractSize = await ffaContractInstance.getSizeOfContract();
        const ffaContractDecimals = await ffaContractInstance.getDecimals();
        const ffaContractState = await ffaContractInstance.getContractState();
        assert.equal(ffaContractName, name, "names should be equal");
        assert.equal(ffaContractSymbol, symbol, "symbol should be equal");
        assert.equal(ffaContractSize, sizeOfContract, "size should be equal");
        assert.equal(ffaContractDecimals, decimals, "decimals should be equal");
        assert.equal(ffaContractState, "Created", "contract state incorrect");
    })
});