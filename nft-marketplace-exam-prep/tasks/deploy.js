const { task } = require("hardhat/config");

task("deploy", "Deploys a NFTMarketplace contract").setAction(
  async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const NFTMarketplaceFactory = await hre.ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );
    const nftMarketplace = await NFTMarketplaceFactory.deploy();

    await nftMarketplace.deployed();

    console.log(
      `NFTMarketplace with owner ${deployer.address} deployed to ${nftMarketplace.address}`
    );
  }
);
