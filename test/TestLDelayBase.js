var LDelayBase = artifacts.require("LDelayBase");

contract('LDelayBase', function(accounts) {
    it("should accept a deposit of ethereum", function() {
        return LDelayBase.deployed().then(function(instance) {
            var ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[0],value:web3.toWei(3,"ether")});
        })
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
            assert.equal(result.toString(), web3.toWei(10, "finney").toString());
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
        });
    });
    it("should pay in the case the train status is delayed", function() {
        //pass
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
            contractBalance = web3.eth.getBalance(ldelay.address).toString();
            assert.equal(contractBalance, expectedBalance.toString());
        });
    });
})
