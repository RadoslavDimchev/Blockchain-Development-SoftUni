const { task } = require("hardhat/config");

task("createCampaign").setAction(async (taskArgs, hre) => {
  const [deployer] = await hre.ethers.getSigners();

  const CrowdfundingPlatform = await hre.ethers.getContractFactory(
    "CrowdfundingPlatform",
    deployer
  );
  const crowdfundingPlatform = await CrowdfundingPlatform.deploy();
  await crowdfundingPlatform.deployed();

  await crowdfundingPlatform.createCampaign(
    "TT",
    "Test",
    "Description",
    100,
    10000
  );

  console.log("success");
});
