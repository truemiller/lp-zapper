import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";


import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    polygon: {
      accounts: [process.env.PK!],
      chainId: 137,
      url: "https://polygon-bor.publicnode.com",
    },
  },
};

export default config;
