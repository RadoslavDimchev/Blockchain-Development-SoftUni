const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("NFTMarketplace", function () {
  const PRICE = ethers.utils.parseEther("1");
  const NOT_VALID_PRICE = ethers.utils.parseEther("0");

  async function mintNFT() {
    const [deployer, firstAccount] = await ethers.getSigners();

    const NFTMarketplaceFactory = await ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );
    const nftMarketplace = await NFTMarketplaceFactory.deploy();
    const nftMarketplaceFirstUser = nftMarketplace.connect(firstAccount);

    await nftMarketplace.createNFT("test");

    return {
      nftMarketplace,
      nftMarketplaceFirstUser,
      deployer,
      firstAccount,
    };
  }

  async function listNFT() {
    const [deployer, firstAccount, secondAccount] = await ethers.getSigners();

    const NFTMarketplaceFactory = await ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );
    const nftMarketplace = await NFTMarketplaceFactory.deploy();
    const nftMarketplaceFirstUser = nftMarketplace.connect(firstAccount);

    await nftMarketplace.createNFT("test");

    await nftMarketplace.listNFTForSale(nftMarketplace.address, 0, PRICE);

    return {
      nftMarketplace,
      nftMarketplaceFirstUser,
      deployer,
      firstAccount,
      secondAccount,
    };
  }

  describe("Listing", function () {
    it("should revert if not owner list NFT", async function () {
      const { nftMarketplaceFirstUser } = await loadFixture(mintNFT);

      await expect(
        nftMarketplaceFirstUser.listNFTForSale(
          nftMarketplaceFirstUser.address,
          0,
          PRICE
        )
      ).to.be.reverted;
    });

    it("should revert if NFT is listed", async function () {
      const { nftMarketplace } = await loadFixture(mintNFT);

      await nftMarketplace.listNFTForSale(nftMarketplace.address, 0, PRICE);

      await expect(
        nftMarketplace.listNFTForSale(nftMarketplace.address, 0, PRICE)
      ).to.be.revertedWith("NFT is already listed");
    });

    it("should revert with invalid price", async function () {
      const { nftMarketplace } = await loadFixture(mintNFT);

      await expect(
        nftMarketplace.listNFTForSale(
          nftMarketplace.address,
          0,
          NOT_VALID_PRICE
        )
      ).to.be.revertedWith("Price must be greater than 0");
    });

    it("should success list NFT", async function () {
      const { nftMarketplace, deployer } = await loadFixture(mintNFT);

      const tx = await nftMarketplace.listNFTForSale(
        nftMarketplace.address,
        0,
        PRICE
      );

      await expect(tx)
        .to.emit(nftMarketplace, "NFTListed")
        .withArgs(nftMarketplace.address, 0, deployer.address, PRICE);
    });
  });

  describe("Purchase", function () {
    it("should revert if NFT is not listed", async function () {
      const { nftMarketplace, firstAccount } = await loadFixture(mintNFT);

      await expect(
        nftMarketplace.purchaseNFT(nftMarketplace.address, 0, firstAccount.address)
      ).to.be.revertedWith("NFT is not listed");
    });
    // it("test", async function () {
    //   const { nftMarketplace, secondAccount } = await loadFixture(listNFT);
    //   const tx = nftMarketplace.purchaseNFT(nftMarketplace, 0, secondAccount.address);
    //   expect(true).to.be.true;
    // });
    // it("should revert if seller is owner", async function () {
    //   const { nftMarketplace } = await loadFixture(listNFT);
    //   const tx = nftMarketplace.purchaseNFT(nftMarketplace, 0, nftMarketplace);
    //   expect(tx).to.be.revertedWith("You cannot buy your own NFT");
    // });
  });
});
