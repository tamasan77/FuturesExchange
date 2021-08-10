const FFAFactory = artifacts.require("./FFAFactory.sol");

/*
contract("FFAFactory", accounts => {
    it("should be able to create FFAContract", async function() {
        const ffaFactoryInstance = await FFAFactory.deployed();

        const name = "Test 1";
        const symbol = "TEST";
        //const oracleAddress = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;//why does this need quotes?
        const jobId = "0x29fa9aa13bf1468788b7cc4a500a45b8";
        const decimals = 10;
        const sizeOfContract = 100;

        const result = await ffaFactoryInstance.createFFAContract(name, symbol, jobId, decimals, sizeOfContract, {from : accounts[0]});
        
        const ffaContract = await ffaFactoryInstance.getFFAContract(0);
        const ffaContractName = await ffaContract.getName();
        assert.equal(ffaContractName, name, "Name is different");
    })
});*/