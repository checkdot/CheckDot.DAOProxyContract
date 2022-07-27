const HDWalletProvider = require('@truffle/hdwallet-provider');
var secret = require("./secret");

module.exports = {
  plugins: ['solidity-coverage', 'truffle-plugin-verify'],
  api_keys: {
    bscscan: secret.API_KEY
  },
  networks: {
    development: {
      // truffle deploy --network development
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      // replace by local ganache account
      from: "0x7f87C43136F7A4c78788bEb8e39EE400328f184a"
    },
    testnet: { // truffle deploy --network testnet
      provider: () => new HDWalletProvider(secret.MMENOMIC, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bsc: { // truffle deploy --network bsc
      provider: () => new HDWalletProvider(secret.MMENOMIC, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },
  compilers: {
    solc: {
      version: "0.8.9"
    }
  }
};
