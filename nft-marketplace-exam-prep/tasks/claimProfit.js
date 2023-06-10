const { task } = require("hardhat/config");

task("claim-profit", "Creates a NFT")
  .addParam("marketplace", "The contratc's address")
  .setAction(async (taskArgs, hre) => {
    const [deployer, firstUser] = await hre.ethers.getSigners();
    const NFTMarketplaceFactory = await hre.ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );
    const nftMarketplace = new hre.ethers.Contract(
      taskArgs.marketplace,
      NFTMarketplaceFactory.interface,
      deployer
    );

    const tx = await nftMarketplace.approve(taskArgs.marketplace, 0);
    const receipt = await tx.wait();
    if (receipt.status === 0) {
      throw new Error("Transaction failed");
    }

    const tx2 = await nftMarketplace.listNFTForSale(taskArgs.marketplace, 0, 1);
    const receipt2 = await tx2.wait();
    if (receipt2.status === 0) {
      throw new Error("Transaction 2 failed");
    }

    const marketplaceFirstUser = nftMarketplace.connect(firstUser);
    const tx3 = await marketplaceFirstUser.purchaseNFT(
      taskArgs.marketplace,
      0,
      firstUser.address,
      { value: 1 }
    );
    const receipt3 = await tx3.wait();
    if (receipt3.status === 0) {
      throw new Error("Transaction 3 failed");
    }

    const tx4 = await nftMarketplace.claimProfit();
    const receipt4 = await tx4.wait();
    if (receipt4.status === 0) {
      throw new Error("Transaction 4 failed");
    }

    console.log(`Claimed profit with tx hash ${receipt4.transactionHash}`);
  });
