const { task } = require("hardhat/config");

task("deploy", "print deployer (owner) and contract address").setAction(
  async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const CrowdfundingPlatform = await hre.ethers.getContractFactory(
      "CrowdfundingPlatform",
      deployer
    );
    const crowdfundingPlatform = await CrowdfundingPlatform.deploy();
    await crowdfundingPlatform.deployed();

    console.log(
      `Crowdfunding Platform with owner ${deployer.address} deployed to ${crowdfundingPlatform.address}`
    );
  }
);
