const { task } = require("hardhat/config");

task("store-funds", "Store funds at organization")
  .addParam("treasury", "The contract's address")
  .addParam("funds", "The funds to store")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const TreasuryFactory = await hre.ethers.getContractFactory(
      "Treasury",
      deployer
    );

    const treasury = TreasuryFactory.attach(taskArgs.treasury);

    await treasury.storeFunds({ value: taskArgs.funds });

    const treasuryBalance = await hre.ethers.provider.getBalance(
      treasury.address
    );

    console.log(
      `Funds stored at ${treasury.address} with balance ${treasuryBalance}`
    );
  });
