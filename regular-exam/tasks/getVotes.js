const { task } = require("hardhat/config");

task("get-votes", "Get votes for a withdrawal")
  .addParam("treasury", "The contract's address")
  .addParam("id", "The withdrawal id")
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();

    const TreasuryFactory = await hre.ethers.getContractFactory(
      "Treasury",
      deployer
    );

    const treasury = TreasuryFactory.attach(taskArgs.treasury);

    const withdrawalId = hre.ethers.BigNumber.from(taskArgs.id);

    const filter = treasury.filters.Voted(withdrawalId);
    const events = await treasury.queryFilter(filter, 0, "latest");

    for (const event of events) {
      const args = event.args;
      console.log(
        `Account ${args.voter} voted ${args.voteOfPerson} with ${args.amount} tokens for withdrawal ${args.withdrawalId}`
      );
    }
  });
