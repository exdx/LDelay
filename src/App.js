import React, { Component } from 'react'
import LDelayBase from '../build/contracts/LDelayBase.json'
import LDelayOracle from '../build/contracts/LDelayOracle.json'
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
      oracle: null,
      account: null,
      balance: null,
      userDeposit: 0,
      userCoverage: 0,
      userTimeLimit: 0,
      userPolicyID: null,
      userTrainStatus: "unknown"
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
    const ldelayOracle = contract(LDelayOracle)
    ldelayContract.setProvider(this.state.web3.currentProvider)
    ldelayOracle.setProvider(this.state.web3.currentProvider)

    // Declaring this for later so we can chain functions on LDelayBase/LDelayOracle.
    var LDelayBaseInstance
    var LDelayOracleInstance

    // Get oracle contract.
    this.state.web3.eth.getAccounts((error, accounts) => {
        ldelayOracle.deployed().then((instance) => {
            LDelayOracleInstance = instance
            return this.setState({ oracle: LDelayOracleInstance })
        })
    }) 
    // Get base contract and account. 
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

    //policyEvent watches the oracle event to get the policy id assigned to the user - the ID is an argument to setBaseTrainStatus()
    var policyEvent = this.state.contract.LogOracleQueryMade({_from: this.state.account});
    policyEvent.watch(function(err, result) {
        if (err) {
          console.log(err)
          return;
        }
        console.log("User Policy ID is: " + result.args.policyID.c[0].toString())
        return this.setState({ userPolicyID: result.args.policyID.c[0].toString() });
      }.bind(this))

    return contract.callOraclefromBase({from: account, value: this.state.web3.toWei("0.000175", "ether"), gas: '3000000'})
  }

  validateUserResult(event) {
    const oracle = this.state.oracle
    const account = this.state.account
    const contract = this.state.contract

    oracle.setBaseTrainStatus(this.state.userPolicyID, {from: account, gas: '300000'})
    .then((result) => {
        return contract.verifyUserTrainStatus.call({ from: account })
    }).then((response) => {
        return this.setState({ userTrainStatus: response.toString() }, this.handleStatusSubmit);
    })
}
  
  approveClaim(event) {
    const account = this.state.account
    const contract = this.state.contract

    contract.approveClaim({from: account, gas: '3000000'})
  }

  buttonTimeChange(event) {
    this.setState({ userTimeLimit: event.target.value }, this.handleTimeSubmit);
  }

  handleTimeSubmit(event) {
      console.log('The user has select a time coverage of: '+ this.state.userTimeLimit + ' minutes.');
  }

  handleStatusSubmit(event) {
      console.log('The user final policy status is: ' + this.state.userTrainStatus)
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
              <p>Buy microinsurance against L train delays today! <br></br>
              More information is on the <a href="https://github.com/Denton24646/LDelay#ldelay">LDelay GitHub.</a></p>
              <p>Your Account: {this.state.account} </p>
              <p><i>Please follow the steps in order. <br></br>Steps 1-3 are meant to be done sequentially right away. Step 4 is for later, after the trip.</i></p>
              <h2>1) Purchase Coverage</h2>
              <p>LDelay enables you to purchase microinsurance covering your future trip.<br></br>
              Please note your subway arrival time should be between 5 and 60 minutes into the future. You may only purchase one policy per account. <br></br>
              When will you arrive at the subway station (in minutes)?</p> 
                <form>
                <input type="text" style={{fontStyle: 'italic'}} value={this.state.value} onBlur={this.buttonTimeChange.bind(this)}/>
                </form>
              <p>You selected coverage for {this.state.userTimeLimit} minutes into the future.</p>
              <button onClick={this.purchaseCoverage.bind(this)}>Purchase Coverage</button>
              <p>Your premium was: {this.state.userDeposit} ETH. Please issue yourself a policy.</p>
              <h2>2) Issue Policy</h2>
              <button onClick={this.issuePolicy.bind(this)}>Issue Policy</button>
              <p>Your coverage is for {this.state.userTimeLimit} minutes into the future with a limit of {this.state.userCoverage} ETH. </p>
              <h2>3) Call Oracle Service</h2>
              <p>The oracle will issue a query to the MTA to determine the status of the train at the time you selected. </p>
              <button onClick={this.callOracle.bind(this)}>Call Oracle</button>
              <p>Your oracle query was sent and will return in {this.state.userTimeLimit} minutes!</p>
              <h2>4) Process Claim</h2>
              <p>Use this after your oracle query has returned - otherwise your transaction will revert.</p>
              <button onClick={this.validateUserResult.bind(this)}>Verify Train Status</button>
              <p>The train status at the time you selected was {this.state.userTrainStatus}. </p>
              <p>You may make a claim and if your train was delayed you will automatically get sent your coverage amount!</p>
              <button onClick={this.approveClaim.bind(this)}>Process Claim</button>
              <br></br>
              <p>Thanks for choosing LDelay! Have a great day.</p>

            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App

               