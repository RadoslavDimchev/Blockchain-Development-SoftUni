const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("NFTMarketplace", function () {
  async function mintNFT() {
    const [deployer, firstAccount] = await ethers.getSigners();

    const NFTMarketplaceFactory = await ethers.getContractFactory(
      "NFTMarketplace",
      deployer
    );
    const nftMarketplace = await NFTMarketplaceFactory.deploy();
    const nftMarketplaceFirstUser = nftMarketplace.connect(firstAccount);

    await nftMarketplace.createNFT("test");

    return { nftMarketplace, nftMarketplaceFirstUser, deployer, firstAccount };
  }

  describe("Listing", function () {
    it("", async function () {
      // const { lock, unlockTime } = await loadFixture(mintNFT);
      // expect(await lock.unlockTime()).to.equal(unlockTime);
    });
  });

  describe("Purchase", function () {
    it("", async function () {});
  });
});
