const path = require("path");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Mnemonic ="";
const AccountIndex = 0;

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    develop: {
      port: 8545
    }
  },
  ganache_local: {
    provider: function() {
      return new HDWalletProvider(Mnemonic, "http://127.0.0.1:7545", AccountIndex)
    },
    network_id: 5777
  },
  compilers: {
    solc: {
      version: "^0.8.6"
    }
  }
};
