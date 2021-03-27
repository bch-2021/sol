const HDWalletProvider = require('truffle-hdwallet-provider');
require('dotenv').config(); // Store environment-specific variable from '.env' to process.env

module.exports = {
  networks: {
    development: {
      host: 'localhost', // Localhost (default: none)
      port: 7545, // Standard Ethereum port (default: none)
      network_id: '*', // Any network (default: none)
      gas: 6000000,
      gasLimit: 6000000, // <-- Use this high gas value
      gasPrice: 1,
    },
    ropsten: {
      provider: () => new HDWalletProvider(
        process.env.MNENOMIC,
        `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
      ),
      network_id: 3,
      // gas: 8000000,
      // gasLimit: 8000000,
      gasPrice: 10000000000,
    },
    kovan: {
      provider: () => new HDWalletProvider(
        process.env.MNENOMIC,
        `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`, 0, 3,
      ),
      network_id: 42,
      // gas: 8000000,
      // gasLimit: 8000000,
      gasPrice: 10000000,
    },

    main: {
      provider: () => new HDWalletProvider(
        process.env.MNENOMIC, `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      ),
      gasPrice: 1,
      network_id: 1,
    },
  },
  mocha: {
    // timeout: 100000
  },
  compilers: {
    solc: {
      version: '0.7.6',
      settings: {
        optimizer: {
          enabled: true,
          runs: 1000,
        },
      },
    },
  },
};
