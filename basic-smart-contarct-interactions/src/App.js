import { useEffect, useState } from "react";
import "./App.css";
import { ethers } from "ethers";

function App() {
  const [currentAccount, setCurrentAccount] = useState(null);
  const [provider, setProvider] = useState(null);
  const [blockNumber, setBlockNumber] = useState(null);
  const [balance, setBalance] = useState(null);

  useEffect(() => {
    if (localStorage.getItem("connected")) {
      connectHandler();
    }
  }, []);

  const connectHandler = () => {
    if (!window.ethereum) {
      alert("install MetaMask");
      return;
    }

    const newProvider = new ethers.providers.Web3Provider(window.ethereum);

    newProvider
      .send("eth_requestAccounts", [])
      .then((accounts) => {
        if (accounts.length > 0) {
          setCurrentAccount(accounts[0]);
          localStorage.setItem("connected", true);
          setProvider(newProvider);
        }
      })
      .catch((e) => console.log(e));
  };

  const getBlockNumberHandler = async () => {
    if (!provider) {
      return;
    }

    const currentBlockNumber = await provider.getBlockNumber();
    setBlockNumber(currentBlockNumber);
  };

  const getBalanceHandler = async () => {
    if (!provider || !currentAccount) {
      return;
    }

    const newBalance = await provider.getBalance(currentAccount);
    setBalance(ethers.utils.formatEther(newBalance));
  };

  const getBalanceInWeiFromETHHandler = async () => {
    if (balance) {
      setBalance((state) => ethers.utils.parseEther(state));
    }
  };

  const sendTransaction = async () => {
    
  };

  return (
    <div className="App">
      <button onClick={connectHandler}>Connect</button>
      {currentAccount ? <h2>{currentAccount}</h2> : <h2>not connected</h2>}

      <button onClick={getBlockNumberHandler}>Get Block Number</button>
      {blockNumber !== null && <h2>{blockNumber}</h2>}

      <button onClick={getBalanceHandler}>Get Balance</button>
      <button onClick={getBalanceInWeiFromETHHandler}>Get Balance in wei from parsed eth</button>
      {balance !== null && <h2>{balance.toString()}</h2>}

      <button onClick={sendTransaction} >Send transaction</button>
    </div>
  );
}

export default App;
