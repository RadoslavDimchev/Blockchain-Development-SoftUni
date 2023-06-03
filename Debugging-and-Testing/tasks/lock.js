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

task("send", "Send ether to account")
  .addParam("acc", "account")
  .setAction(async (taskArgs, hre) => {
    const account = (await hre.ethers.getSigners())[0];

    const balance = await hre.ethers.provider.getBalance(account.address);
    console.log(hre.ethers.utils.formatEther(balance));

    const tx = await account.sendTransaction({
      to: taskArgs.acc,
      value: hre.ethers.utils.parseEther("1.0"),
    });

    await tx.wait();

    const newBalance = await hre.ethers.provider.getBalance(account.address);
    console.log(hre.ethers.utils.formatEther(newBalance));
  });
