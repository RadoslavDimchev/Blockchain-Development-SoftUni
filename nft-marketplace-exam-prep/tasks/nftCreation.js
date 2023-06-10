const { task } = require("hardhat/config");

task("nft-creation", "Creates a NFT")
  .addParam("marketplace", "The contratc's address")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const NFTMarketplaceFactory = await hre.ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );
    const nftMarketplace = new hre.ethers.Contract(
      taskArgs.marketplace,
      NFTMarketplaceFactory.interface,
      deployer
    );
    // const nftMarketplace = await NFTMarketplaceFactory.attach(
    //   taskArgs.marketplace
    // );

    const tx = await nftMarketplace.createNFT("test");
    const receipt = await tx.wait();

    if (receipt.status === 0) {
      throw new Error("Transaction failed");
    }

    console.log(`NFT created with tx hash ${receipt.transactionHash}`);
  });
