const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Treasury", function () {
  const AMOUNT = 1000;
  const NOT_VALID_AMOUNT = 0;
  const DESCRIPTION = "First Withdrawal Description";
  const DURATION = 10000;
  const NOT_VALID_DURATION = 0;
  const WITHDRAWAL_ID = 0;
  const NOT_VALID_WITHDRAWAL_ID = 1;
  const YES = "Yes";
  const NO = "No";
  const NOT_VALID_VOTE = "NOT_VALID_VOTE";

  async function storeFunds() {
    const [deployer, firstAcc] = await ethers.getSigners();

    const Treasury = await ethers.getContractFactory("Treasury");
    const treasury = await Treasury.deploy();

    const treasuryFirstAcc = treasury.connect(firstAcc);
    await treasury.storeFunds({ value: AMOUNT });
    await treasuryFirstAcc.storeFunds({ value: AMOUNT });

    return { deployer, firstAcc, treasury, treasuryFirstAcc };
  }

  async function initiateWithdrawal() {
    const { deployer, firstAcc, treasury, treasuryFirstAcc } =
      await loadFixture(storeFunds);

    await treasury.initiateWithdrawal(AMOUNT, DESCRIPTION, DURATION);

    return { deployer, firstAcc, treasury, treasuryFirstAcc };
  }

  describe("Store Funds", function () {
    it("should success store funds", async function () {
      const { treasury, deployer } = await loadFixture(storeFunds);

      const deployerBalance = await treasury.balanceOf(deployer.address);

      expect(deployerBalance).to.be.equal(AMOUNT);
    });

    it("should success store funds for first acc", async function () {
      const { treasury, firstAcc } = await loadFixture(storeFunds);

      const firstAccBalance = await treasury.balanceOf(firstAcc.address);

      expect(firstAccBalance).to.be.equal(AMOUNT);
    });
  });

  describe("Initiate Withdrawal", function () {
    it("should revert if not owner initiate", async function () {
      const { treasuryFirstAcc } = await loadFixture(storeFunds);

      await expect(
        treasuryFirstAcc.initiateWithdrawal(AMOUNT, DESCRIPTION, DURATION)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should revert if amount is not valid", async function () {
      const { treasury } = await loadFixture(storeFunds);

      await expect(
        treasury.initiateWithdrawal(NOT_VALID_AMOUNT, DESCRIPTION, DURATION)
      ).to.be.revertedWithCustomError(treasury, "InvalidAmount");
    });

    it("should revert if duration is not valid", async function () {
      const { treasury } = await loadFixture(storeFunds);

      await expect(
        treasury.initiateWithdrawal(AMOUNT, DESCRIPTION, NOT_VALID_DURATION)
      ).to.be.revertedWith("Duration must be greater than 0");
    });

    it("should success", async function () {
      const { treasury } = await loadFixture(initiateWithdrawal);

      const withdrawal = await treasury.withdrawals(WITHDRAWAL_ID);

      expect(withdrawal.amount).to.be.equal(AMOUNT);
    });
  });

  describe("Voting", function () {
    it("should revert if with not valid withdrawal id", async function () {
      const { treasuryFirstAcc } = await loadFixture(initiateWithdrawal);

      await expect(
        treasuryFirstAcc.vote(NOT_VALID_WITHDRAWAL_ID, YES, AMOUNT)
      ).to.be.revertedWith("Withdrawal not found");
    });

    it("should revert if not valid amount", async function () {
      const { treasuryFirstAcc } = await loadFixture(initiateWithdrawal);

      await expect(
        treasuryFirstAcc.vote(WITHDRAWAL_ID, YES, NOT_VALID_AMOUNT)
      ).to.be.revertedWithCustomError(treasuryFirstAcc, "InvalidAmount");
    });

    it("should revert if voting period is ended", async function () {
      const { treasuryFirstAcc } = await loadFixture(initiateWithdrawal);

      await time.increase(DURATION + 1);

      await expect(
        treasuryFirstAcc.vote(WITHDRAWAL_ID, YES, AMOUNT)
      ).to.be.revertedWith("Voting period is ended");
    });

    it("should revert if not valid vote option", async function () {
      const { treasuryFirstAcc } = await loadFixture(initiateWithdrawal);

      await expect(
        treasuryFirstAcc.vote(WITHDRAWAL_ID, NOT_VALID_VOTE, AMOUNT)
      ).to.be.revertedWithCustomError(treasuryFirstAcc, "InvalidVoteOption");
    });

    it("should success add votes to yes", async function () {
      const { treasury, treasuryFirstAcc } = await loadFixture(
        initiateWithdrawal
      );

      await treasuryFirstAcc.vote(WITHDRAWAL_ID, YES, AMOUNT);

      const withdrawal = await treasury.withdrawals(WITHDRAWAL_ID);

      expect(withdrawal.votesYes).to.be.equal(AMOUNT);
    });

    it("should success add votes to no", async function () {
      const { treasury, treasuryFirstAcc } = await loadFixture(
        initiateWithdrawal
      );

      await treasuryFirstAcc.vote(WITHDRAWAL_ID, NO, AMOUNT);

      const withdrawal = await treasury.withdrawals(WITHDRAWAL_ID);

      expect(withdrawal.votesNo).to.be.equal(AMOUNT);
    });

    it("should success transfer tokens from first acc to treasury", async function () {
      const { treasury, treasuryFirstAcc, firstAcc } = await loadFixture(
        initiateWithdrawal
      );

      await treasuryFirstAcc.vote(WITHDRAWAL_ID, NO, AMOUNT);

      const treasuryTokenBalance = await treasury.balanceOf(treasury.address);
      const firstAccTokenBalance = await treasury.balanceOf(firstAcc.address);

      expect(treasuryTokenBalance).to.be.equal(AMOUNT);
      expect(firstAccTokenBalance).to.be.equal(0);
    });
  });
});
