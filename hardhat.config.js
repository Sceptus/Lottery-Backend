require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;

const ACC_1_PRIVATE_KEY = process.env.ACC_1_PRIVATE_KEY;
const ACC_2_PRIVATE_KEY = process.env.ACC_2_PRIVATE_KEY;

const SEPOLIA_ETHERSCAN_API_KEY = process.env.SEPOLIA_ETHERSCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [ACC_1_PRIVATE_KEY, ACC_2_PRIVATE_KEY],
      chainId: 11155111,
    },
  },
  solidity: "0.8.19",
  etherscan: {
    apiKey: {
      sepolia: SEPOLIA_ETHERSCAN_API_KEY,
    },
  },
};
