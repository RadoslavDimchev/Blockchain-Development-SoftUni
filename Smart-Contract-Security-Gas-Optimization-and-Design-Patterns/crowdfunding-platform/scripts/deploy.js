const hre = require("hardhat");

async function main() {
  const CrowdfundingPlatform = await hre.ethers.getContractFactory(
    "CrowdfundingPlatform"
  );
  const crowdfundingPlatform = await CrowdfundingPlatform.deploy(unlockTime, {
    value: lockedAmount,
  });

  await crowdfundingPlatform.deployed();

  console.log(
    `Crowdfunding Platform deployed to ${crowdfundingPlatform.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
