const hre = require("hardhat");

async function main() {

  const accounts = await hre.ethers.getSigners();

  await hre.run("extract_poetry");
  const poetry = require("../generated_poetry.json");

  console.log("Starting...");
  const tokenInfoFactory = await hre.ethers.getContractFactory("TokenInfo");
  const tokenInfoInstance = await tokenInfoFactory.deploy(...poetry);
  await tokenInfoInstance.deployed();
  console.log("TokenInfo deployed to:", tokenInfoInstance.address);

  const helpUkrainFactory = await hre.ethers.getContractFactory("HelpUkrain");
  const helpUkrainInstance = await helpUkrainFactory.deploy(
    tokenInfoInstance.address
  );
  await helpUkrainInstance.deployed();
  console.log("HelpUkrain deployed to:", helpUkrainInstance.address);

  console.log("Starting the minting of bunch...");
  await helpUkrainInstance.mintTo(
    accounts[0].address,
    parseInt(process.env.BUNCH_AMOUNT)
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
