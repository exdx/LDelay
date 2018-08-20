var LDelayBase = artifacts.require("LDelayBase");

contract('LDelayBase', function(accounts){
    it("should accept a deposit of ethereum", function() {
        return LDelayBase.deployed()
            .then(function(instance) {
                ldelay = instance;
                var testCoverageLimit = 5;
                return ldelay.depositPremium(testCoverageLimit, {from:accounts[0],value:web3.toWei(3,"ether")})
        })
    });
    it("should set the customer balance equal to their premium", function() {
        return LDelayBase.deployed()
        .then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[0],value:web3.toWei(3,"ether")})
            .then(function() {
                return ldelay.getBalance.call(accounts[0])
                    .then(function(result) {
                    assert.equal(result.toString(), web3.toWei(10, "finney"))
                })
            })
        })
    });
    it("should allow for the user to issue a policy", function() {
        return LDelayBase.deployed()
        .then(function(instance) {
            ldelay = instance;
            var testCoverageLimit = 5;
            return ldelay.depositPremium(testCoverageLimit, {from:accounts[0],value:web3.toWei(3,"ether")})
    .then(function(result) {
        return ldelay.issuePolicy({from:accounts[0], gas: 2000000})
            })
        })
    })
})
