const { task } = require("hardhat/config");

task("deploy", "Deploys contract").setAction(async (taskArgs, hre) => {
  const [deployer] = await hre.ethers.getSigners();

  const TreasuryFactory = await hre.ethers.getContractFactory(
    "Treasury",
    deployer
  );
  const treasury = await TreasuryFactory.deploy();

  await treasury.deployed();

  console.log(
    `Treasury with owner ${deployer.address} deployed to ${treasury.address}`
  );
});
