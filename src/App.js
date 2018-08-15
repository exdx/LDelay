import React, { Component } from 'react'
import LDelayBase from '../build/contracts/LDelayBase.json'
import getWeb3 from './utils/getWeb3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      web3: null,
      contract: null,
      account: null,
      balance: null,
      userDeposit: 0,
      userCoverage: 0,
      userTimeLimit: 0
    }
  }

  componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    getWeb3
    .then(results => {
      this.setState({
        web3: results.web3
      })

      // Instantiate contract once web3 provided.
      this.instantiateContract()
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  instantiateContract() {

    const contract = require('truffle-contract')
    const ldelayContract = contract(LDelayBase)
    ldelayContract.setProvider(this.state.web3.currentProvider)

    // Declaring this for later so we can chain functions on LDelayBase.
    var LDelayBaseInstance

    // Get accounts and contract.
    this.state.web3.eth.getAccounts((error, accounts) => {
        ldelayContract.deployed().then((instance) => {
            LDelayBaseInstance = instance
            return this.setState({ contract: LDelayBaseInstance, account: accounts[0] })
        })
    })
  }

  purchaseCoverage(event) {
      const contract = this.state.contract
      const account = this.state.account

      return contract.depositPremium(10, {from: account, value: this.state.web3.toWei(10, "finney")})
        .then((result) => {
            return contract.getBalance.call({ from: account })
        }).then((response) => {
            return this.setState({ userDeposit: this.state.web3.fromWei(response.toNumber(), "ether" )})
          })
  }

  handleChange(event) {
    this.setState({value: this.state.userTimeLimit});
  }


  render() {
    return (
      <div className="App">
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">LDelay</a>
        </nav>

        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <h1>LDelay: Decentralized Parametric Microinsurance</h1>
              <p>Buy insurance against L train delays today!</p>
              <p>Your Account: {this.state.account} </p>
              <h2>Purchase</h2>
              <p>LDelay enables you to purchase insurance covering your future trip.<br></br>
              When will you arrive at the subway station?</p> 
                <form onSubmit={this.handleSubmit}>
                <label>
                <input type="text" value="In minutes" onChange={this.handleChange} style={{fontStyle: 'italic'}} />
                </label>
                <input type="submit" value="Submit" />
                </form>
              <p>Your premium was: {this.state.userDeposit} ETH</p>
              <button onClick={this.purchaseCoverage.bind(this, this.state.userDeposit)}>Purchase Coverage</button>
              <h2>Coverage</h2>
              <p>Your coverage is: {this.state.userCoverage} ETH for {this.state.userTimeLimit} minutes in the future.</p>
            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App