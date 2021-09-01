const { assert } = require("chai");

const FFAFactory = artifacts.require("./FFAFactory.sol");
const FFAContractMock = artifacts.require("./FFAContractMock.sol");

contract("FFAFactory", accounts => {
    it("create FFAContract and check for incorrect parameters", async function() {
        const ffaFactoryInstance = await FFAFactory.deployed();

        const name = "Test 1";
        const symbol = "TEST";
        let sizeOfContract = 100;
        let underlyingApiURL = "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD,JPY,EUR";
        let underlyingApiPath = "USD";
        let underlyingDecimals = 100;

        //test error for zero decimals
        try{
            await ffaFactoryInstance.createFFAContract(name, symbol, sizeOfContract, underlyingApiURL, underlyingApiPath, 0);
        } catch(error) {
            decErr = error;
        }
        assert.notEqual(decErr, undefined, "Error must be thrown");

        //test error for zero sizeOfContract
        try{
            await ffaFactoryInstance.createFFAContract(name, symbol, 0, underlyingApiURL, underlyingApiPath, underlyingDecimals);
        } catch(error) {
            contractSizeErr = error;
        }
        assert.notEqual(contractSizeErr, undefined, "Error must be thrown");

        //test error for empty string given for api url and api path
        try{
            await ffaFactoryInstance.createFFAContract(name, symbol, sizeOfContract, "", underlyingApiPath, underlyingDecimals);
        } catch(error) {
            emptyURLErr = error;
        }
        assert.notEqual(emptyURLErr, undefined, "Error must be thrown");
        try{
            await ffaFactoryInstance.createFFAContract(name, symbol, sizeOfContract, underlyingApiURL, "", underlyingDecimals);
        } catch(error) {
            emptyPathErr = error;
        }
        assert.notEqual(emptyPathErr, undefined, "Error must be thrown");

        //check if createFFAContract cretaes ffa contract correctly and stores it correctly
        await ffaFactoryInstance.createFFAContract(
            name, symbol, sizeOfContract, underlyingApiURL, underlyingApiPath, underlyingDecimals);

        const ffaContract = await ffaFactoryInstance.getFFAContract(0);
        const ffaContractInstance = await FFAContractMock.at(ffaContract);

        const ffaContractName = await ffaContractInstance.getName();
        const ffaContractSymbol = await ffaContractInstance.getSymbol();
        const ffaContractSize = await ffaContractInstance.getSizeOfContract();
        const ffaContractApiURL = await ffaContractInstance.getUnderlyingApiURL();
        const ffaContractApiPath = await ffaContractInstance.getUnderlyingApiPath();
        const ffaContractDecimals = await ffaContractInstance.getUnderlyingDecimals();
        const ffaContractState = await ffaContractInstance.getContractState();
        assert.equal(ffaContractName, name, "names should be equal");
        assert.equal(ffaContractSymbol, symbol, "symbol should be equal");
        assert.equal(ffaContractSize, sizeOfContract, "size should be equal");
        assert.equal(ffaContractApiURL, underlyingApiURL, "api url set incorrect");
        assert.equal(ffaContractApiPath, underlyingApiPath, "api path set incorrect");
        assert.equal(ffaContractDecimals, underlyingDecimals, "decimals should be equal");
        assert.equal(ffaContractState, "Created", "contract state incorrect");
    })
});