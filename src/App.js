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

      return contract.depositPremium(this.state.userTimeLimit, {from: account, value: this.state.web3.toWei(10, "finney")})
        .then((result) => {
            return contract.getBalance.call({ from: account })
        }).then((response) => {
            return this.setState({ userDeposit: this.state.web3.fromWei(response.toNumber(), "ether" )})
          })
  }

  issuePolicy(event) {
    const contract = this.state.contract
    const account = this.state.account

    return contract.issuePolicy({from: account})
    .then((result) => {
        return contract.getCoverage.call({ from: account })
    }).then((response) => {
        return this.setState({ userCoverage: this.state.web3.fromWei(response.toNumber(), "ether" )})
      })
  }

  callOracle(event) {
    const contract = this.state.contract
    const account = this.state.account

    return contract.callOraclefromBase({from: account})
  }

  buttonTimeChange(event) {
    this.setState({ userTimeLimit: event.target.value }, this.handleTimeSubmit);
  }

  handleTimeSubmit(event) {
      console.log('The user has select a time coverage of: '+ this.state.userTimeLimit + ' minutes.');
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
              <p>Buy insurance against L train delays today! <br></br>
              More information is on the <a href="https://github.com/Denton24646/LDelay#ldelay">github</a></p>
              <p>Your Account: {this.state.account} </p>
              <p><i>Please follow the steps in order.</i></p>
              <h2>1) Purchase Coverage</h2>
              <p>LDelay enables you to purchase insurance covering your future trip.<br></br>
              Please note your arrival should be between 5 and 60 minutes into the future. You may only purchase one policy per account. <br></br>
              When will you arrive at the subway station (in minutes)?</p> 
                <form>
                <input type="text" style={{fontStyle: 'italic'}} value={this.state.value} onBlur={this.buttonTimeChange.bind(this)}/>
                </form>
              <p>You selected coverage for {this.state.userTimeLimit} minutes into the future.</p>
              <button onClick={this.purchaseCoverage.bind(this)}>Purchase Coverage</button>
              <p>Your premium was: {this.state.userDeposit} ETH. Please issue yourself a policy.</p>
              <h2>2) Issue Policy</h2>
              <button onClick={this.issuePolicy.bind(this)}>Issue Policy</button>
              <p>Your coverage is for {this.state.userTimeLimit} minutes into the future with a limit of {this.state.userCoverage}. </p>
              <h2>3) Call Oracle Service</h2>
              <p>The oracle will issue a query to the MTA to determine the status of the train at the time you selected. </p>
              <button onClick={this.callOracle.bind(this)}>Call Oracle</button>
            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App

               