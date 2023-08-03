// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  //VARIABLES

  //DEPLOYING CONTRACT
  console.log("Deploying contract...");
  const lottery = await hre.ethers.deployContract("Lottery", [3983]);
  await lottery.waitForDeployment();

  console.log(`Contract deployed at: ${await lottery.getAddress()}`);

  if (hre.network.config.chainId == 11155111) {
    console.log("Waiting for 6 block confirmations...");

    let provider = new hre.ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    let deploymentTx = await lottery.deploymentTransaction();
    await provider.waitForTransaction(deploymentTx.hash, 6);

    await verify(await lottery.getAddress(), [3983]);
  }
}

async function verify(contractAddress, args) {
  console.log("Verifying contract...");
  await hre
    .run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    })
    .catch((error) => {
      console.log(error);
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
