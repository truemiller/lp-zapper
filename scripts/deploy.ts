import { ethers } from "hardhat";

async function main() {
  const Zap = await ethers.getContractFactory("Zap");
  const zap = await Zap.deploy();
  await zap.waitForDeployment();

  const zapAddress = zap.address;
  console.log("Deployment address", zapAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
