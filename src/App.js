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
      userDeposit: null,
      userCoverage: null
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

    // Get accounts.
    this.state.web3.eth.getAccounts((error, accounts) => {
        ldelayContract.deployed().then((instance) => {
            LDelayBaseInstance = instance
            //Transaction sending to deposit premium function 
            return LDelayBaseInstance.depositPremium(this.state.web3.eth.toWei(50, "finney"), {from: accounts[0]})
        }).then((result) => {
            //Call getBalance function to return coverage
            return LDelayBaseInstance.getBalance.call(accounts[0])
        }).then((result) => {
            //Update state with the result
            return this.setState({ userDeposit: result.c[0]})
        })
    }) 
  }

  handleClick(event){
      const contract = this.state.contract
      const account = this.state.account
  }

  render() {
    return (
      <div className="App">
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">Truffle Box</a>
        </nav>

        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <h1>LDelay: Decentralized Parametric Microinsurance</h1>
              <p>Buy insurance against L train delays today!</p>
              <h2>Purchase</h2>
              <p>Your premium was: {this.state.userDeposit}</p>
              <button onClick={this.handleClick.bind(this)}>Deposit Premium</button>
            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App
