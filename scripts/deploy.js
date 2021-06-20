// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const CMORegistry = await hre.ethers.getContractFactory("CMORegistry");
  const cmoRegistryInstance = await CMORegistry.deploy(
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  );

  await cmoRegistryInstance.deployed();

  console.log("CMORegistry deployed to:", cmoRegistryInstance.address);

  await setTokenWithRange({
    min: 999,
    max: 2000,
    tokenPrice: 1000,
    cmoRegistryInstance,
  });
}

async function setTokenWithRange({
  min,
  max,
  tokenPrice,
  cmoRegistryInstance,
}) {
  const createTx = await cmoRegistryInstance.createTokenWithRange(min, max);

  const createTxReceipt = await createTx.wait();

  if (createTxReceipt) {
    const setTokenPriceTx = await cmoRegistryInstance.setTokenPrice(
      1,
      tokenPrice
    );

    await setTokenPriceTx.wait();
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
