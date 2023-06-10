const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("NFTMarketplace", function () {
  const PRICE = ethers.utils.parseEther("1");
  const INVALID_PRICE = ethers.utils.parseEther("0");

  async function mintNFT() {
    const [deployer, firstAccount, secondAccount] = await ethers.getSigners();

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
      secondAccount,
    };
  }

  async function listNFT() {
    const {
      nftMarketplace,
      nftMarketplaceFirstUser,
      deployer,
      firstAccount,
      secondAccount,
    } = await loadFixture(mintNFT);
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
        nftMarketplace.listNFTForSale(nftMarketplace.address, 0, INVALID_PRICE)
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
      const { nftMarketplaceFirstUser, firstAccount } = await loadFixture(
        mintNFT
      );

      await expect(
        nftMarketplaceFirstUser.purchaseNFT(
          nftMarketplaceFirstUser.address,
          0,
          firstAccount.address
        )
      ).to.be.revertedWith("NFT is not listed");
    });

    it("should revert if seller is owner", async function () {
      const {
        nftMarketplace,
        nftMarketplaceFirstUser,
        firstAccount,
        deployer,
      } = await loadFixture(listNFT);

      await expect(
        nftMarketplace.purchaseNFT(
          nftMarketplace.address,
          0,
          firstAccount.address
        )
      ).to.be.revertedWith("You cannot buy your own NFT");

      await expect(
        nftMarketplaceFirstUser.purchaseNFT(
          nftMarketplaceFirstUser.address,
          0,
          deployer.address
        )
      ).to.be.revertedWith("You cannot buy your own NFT");
    });

    it("should with invalid price", async function () {
      const { nftMarketplaceFirstUser, firstAccount } = await loadFixture(
        listNFT
      );

      await expect(
        nftMarketplaceFirstUser.purchaseNFT(
          nftMarketplaceFirstUser.address,
          0,
          firstAccount.address,
          { value: INVALID_PRICE }
        )
      ).to.be.revertedWith("Invalid price");
    });

    it("should success purchase NFT", async function () {
      const { nftMarketplace, nftMarketplaceFirstUser, firstAccount } =
        await loadFixture(listNFT);

      await nftMarketplaceFirstUser.purchaseNFT(
        nftMarketplace.address,
        0,
        firstAccount.address,
        { value: PRICE }
      );

      expect(await nftMarketplace.ownerOf(0)).to.equal(firstAccount.address);
      expect(
        (
          await nftMarketplace.nftsForSale(nftMarketplace.address, 0).price
        ).to.equal(0)
      );
    });
  });
});
