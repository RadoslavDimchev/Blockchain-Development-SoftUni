const { task } = require("hardhat/config");

task("accounts", "Prints the list of accounts")
  .addParam("test", "log test string")
  .setAction(async (taskArgs, hre) => {
    console.log(taskArgs.test);

    const accounts = await hre.ethers.getSigners();
    for (const account of accounts) {
      console.log(account.address);
    }
  });
