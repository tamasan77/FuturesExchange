import React, { Component } from "react";
import FFAContract from "./contracts/FFAContract.json";
import FFAFactory from "./contracts/FFAFactory.json"
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = {loaded:false, /*contractName: "Example Forward Contract", contractSymbol: "EFC"*/};

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      this.web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      this.accounts = await this.web3.eth.getAccounts();

      // Get the contract instance.
      this.networkId = await this.web3.eth.net.getId();

      this.ffaContract = new this.web3.eth.Contract(
        FFAContract.abi,
        FFAContract.networks[this.networkId] && FFAContract.networks[this.networkId].address,
      );

      this.ffaFactory = new this.web3.eth.Contract(
        FFAContract.abi,
        FFAFactory.networks[this.networkId] && FFAFactory.networks[this.networkId].address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({loaded:true });
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  handleInputChange = (event) => {
    const target = event.target;
    const value = target.type === "checkbox" ? target.checked : target.value;
    const name = target.name;
    this.setState({
      [name]: value
    });
  }

  handleSubmit = async() => {
    const {contractName, contractSymbol, contractSize, underlyingAPIURL, underlyingAPIPath, underlyingDecimals} = this.state;
    await this.ffaFactory.methods.createFFAContract(contractName, contractSymbol, contractSize ,underlyingAPIURL, underlyingAPIPath, underlyingDecimals).send({from: this.accounts[0]});
  }

  render() {
    if (!this.state.loaded) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Forward Contract Factory</h1>
        <h2>Create Forward Contract</h2>
        Contract Name: <input type="text" name="contractName" value={this.state.contractName} onChange={this.handleInputChange} />
        Contract Symbol: <input type="text" name="contractSymbol" value={this.state.contractSymbol} onChange={this.handleInputChange} />
        Contract Size: <input type="number" name="contractSize" value={this.state.contractSize} onChange={this.handleInputChange} />
        Underlying API URL: <input type="text" name="underlyingAPIURL" value={this.state.underlyingAPIURL} onChange={this.handleInputChange} />
        Underlying API Path: <input type="text" name="underlyinAPIPath" value={this.state.underlyinAPIPath} onChange={this.handleInputChange} />
        UnderlyingDecimals: <input type="number" name="underlyingDecimals" value={this.state.underlyingDecimals} onChange={this.handleInputChange} />
        <button type="button" onClick={this.handleSubmit}>Create new forward contract</button>
      </div>
    );
  }
}

export default App;
