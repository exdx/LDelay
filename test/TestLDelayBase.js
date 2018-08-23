var LDelayBase = artifacts.require("LDelayBase");

/*
This is a suite of integration tests that mimic the user experience
The contract should support deposits, calling the oracle, and withdrawing funds
Checks are done primarily by checking events were emitted (function execution was normal) 
Also checking that ether balanaces/coverages are above zero

NOTE: Each test uses a new account - this is by design since the dApp is only allowing one policy per account as a safety measure
Since each test shares state between the test contract this was necessary to prevent revert errors
*/

contract('LDelayBase', function(accounts) {
    it("should accept a deposit of ethereum", function() {
        return LDelayBase.deployed().then(function(instance) {
            var ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[0],value:web3.toWei(3,"ether")});
        }).then(function(result) {
            assert.equal(result.logs[0].event, "LogDepositMade");
        });
    });
    it("should set the customer balance equal to their premium", function() {
        var ldelay;
        return LDelayBase.deployed().then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[1],value:web3.toWei(3,"ether")});
        }).then(function() {
            return ldelay.getBalance.call({from:accounts[1]});
        }).then(function(result) {
            assert.equal(result.toString(), web3.toWei(10, "finney"));
        });
    });
    it("should allow for the user to issue themselves a policy", function() {
        var ldelay;
        return LDelayBase.deployed().then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[2],value:web3.toWei(3,"ether")});
        }).then(function() {
            return ldelay.issuePolicy({from:accounts[2], gas: 2000000});
        }).then(function(result) {
            assert.equal(result.logs[0].event, "LogPolicyMade");
        });
    });
    it("should allow a call to the oracle contract", function() {
        var ldelay;
        return LDelayBase.deployed().then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[3],value:web3.toWei(3,"ether")});
        }).then(function() {
            return ldelay.issuePolicy({from:accounts[3], gas: 2000000});
        }).then(function() {
            return ldelay.callOraclefromBase({from:accounts[3], value: web3.toWei("1", "ether"), gas: 2000000});
        }).then(function(result) {
            assert.equal(result.logs[0].event, "LogOracleQueryMade");
        });
    });
    it("should read user balances", function() {
        var ldelay;
        return LDelayBase.deployed().then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[4],value:web3.toWei(3,"ether")});
        }).then(function() {
            return ldelay.getBalance.call({from:accounts[4]});
        }).then(function(result) {
            assert.isAbove(result.toNumber(), 0);
        });
    });
    it("should read user coverages", function() {
        var ldelay;
        return LDelayBase.deployed().then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[5],value:web3.toWei(3,"ether")});
        }).then(function() {
            return ldelay.issuePolicy({from:accounts[5], gas: 2000000});
        }).then(function() {
            return ldelay.getCoverage.call({from:accounts[5]});
        }).then(function(result) {
            assert.isAbove(result.toNumber(), 0);
        });
    });
    it("should read total coverage in the pool", function() {
        var ldelay;
        return LDelayBase.deployed().then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[6],value:web3.toWei(3,"ether")});
        }).then(function() {
            return ldelay.issuePolicy({from:accounts[6], gas: 2000000});
        }).then(function() {
            return ldelay.getTotalCoverage.call({from:accounts[6]});
        }).then(function(result) {
            assert.isAbove(result.toNumber(), 0);
        });
    });
    it("should allow the user to call approve claim", function() {
        var ldelay;
        return LDelayBase.deployed().then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[7],value:web3.toWei(3,"ether")});
        }).then(function() {
            return ldelay.issuePolicy({from:accounts[7], gas: 2000000});
        }).then(function() {
            return ldelay.approveClaim({from:accounts[7], gas: 2000000});
        }).then(function(result) {
            assert.equal(result.logs[0].event, "LogPolicyClosed");
        });
    });
    it("should pay in the case the train status is delayed", function() {
        /*
        This test should test the behavior of the approveClaim function when the train status is "Delayed"
        Unforunately the MTA API is inconsistent and does not return alerts that would set the status to delayed via the AWS Lambda function
        Implmenting this test successfully would require refactoring the API (to scrape data directly from the MTA website) - time did not allow this
        OR stubbing out the status for a test policy (setting it to Delayed) and then checking the resulting behavior
        To my knowledge there is no way to manually override solidity function code in the test framework
        Therefore this test is incomplete :/
        */
    });
    it("should not pay in the case the train status is normal", function() {
        var ldelay;
        var contractBalance;
        return LDelayBase.deployed().then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[8],value:web3.toWei(3,"ether")});
        }).then(function() {
            return ldelay.issuePolicy({from:accounts[8], gas: 2000000});
        }).then(function() {
            return ldelay.approveClaim({from:accounts[8], gas: 2000000});
        }).then(function () {
            var expectedBalance = web3.toWei("2", "ether") + web3.toWei("0.1", "finney") //100 ether plus 0.1 customer deposit 
            contractBalance = web3.eth.getBalance(ldelay.address) - web3.toWei("0.1", "finney") * 8 //remove deposits from previous tests
            assert.equal(contractBalance, expectedBalance.toString());
        });
    });
})
