const { task } = require("hardhat/config");

task("contribute", "contributor, contract addresses and contribution amount")
  .addParam("crowdfundingCampaign", "contract address")
  .addParam("amount", "amount to contribute")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const CrowdfundingCampaign = await hre.ethers.getContractFactory(
      "CrowdfundingCampaign",
      deployer
    );
    const crowdfundingCampaign = CrowdfundingCampaign.attach(taskArgs.campaign);

    await crowdfundingCampaign.contribute({ value: taskArgs.amount });

    console.log(
      `User ${deployer.address} contributed ${taskArgs.amount} to Campaign ${campaign.address}`
    );
  });
