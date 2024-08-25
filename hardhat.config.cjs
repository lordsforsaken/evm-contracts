require("@nomicfoundation/hardhat-toolbox");

const key = process.env.PRIV_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    hardhat: {
    },
    arbitrumSepolia: {
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      accounts: [key]
    }
  }
};
