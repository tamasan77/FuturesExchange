const path = require("path");
require("dotenv").config({path: "./.env"});
const HDWalletProvider = require("@truffle/hdwallet-provider");
const AccountIndex = 0;

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    development: {
      port: 7545,
      network_id: "*",
      host: "127.0.0.1"
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(
          process.env.MNEMONIC,
          process.env.INFURA_RINKEBY_URL
        )
      },
      gas: 3000000,
      network_id: 4, 
      networkCheckTimeout: 20000
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider(
          process.env.MNEMONIC,
          process.env.INFURA_KOVAN_URL
        )
      }, 
      gas: 3000000,
      network_id: 42,
      networkCheckTimeout: 20000
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(
          process.env.MNEMONIC, 
          process.env.INFURA_ROPSTEN_URL
        )
      },
      network_id: 3,
      gas: 4000000,
      networkCheckTimeout: 20000
    },
    ganache_local: {
      port: 7545,
      network_id: 5777,
      host: "127.0.0.1",
      gas: 372197500,
      gasPrice: 20000000000
    }
  },
  compilers: {
    solc: {
      version: "^0.8.6",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
};
