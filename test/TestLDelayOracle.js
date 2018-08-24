var LDelayOracle = artifacts.require("LDelayOracle");
var LDelayBase = artifacts.require("LDelayBase");
var expectThrow = require('./helpers/expectThrow').expectThrow;

contract('LDelayOracle', function(accounts) {
    it("should accept a call to the oraclize library", function() {
        //NOTE: since only LDelayBase contract can call the oraclize function (for security reason) this test must call from the base contract
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
            assert.equal(result.logs[0].event.slice(0,18), "LogOracleQueryMade"); //query sent to oraclize library
        });
    });
    it("should not accept a call from any contract other than base", function() {
        return LDelayOracle.deployed().then(function(instance) {
            oracle = instance;
            var policyid = 1;
            var timelimit = 2;
            expectThrow(oracle.getLTrainStatus(policyid, timelimit, {from: accounts[0], value: web3.toWei(0.1, "ether"), gas:2000000})) //should throw
        });
    });
    it("should write status back into base contract", function() {
        /*
        This test is difficult to write because it depends on the result of the oracle query to come back otherwise it reverts
        Since there is not way to "fast forward" the oraclize callback (minimum time is set to 5 minutes for security and implementation reasons)
        One would have time time.sleep(300) to have this test execute properly
        This test will be unfinished :/
        */
    });
    it("should not write status if oraclize callback has not finished", function() {
        return LDelayOracle.deployed().then(function(instance) {
            oracle = instance;
            var policyid = 0;
            expectThrow(oracle.setBaseTrainStatus(policyid, {from: accounts[3], gas: 2000000})) //oraclize query has not returned by this point
        });
    });
    it("should not allow other calls to setBaseContractAddress", function() {
        //NOTE: setBaseContractAddress should only be called once, upon deployment, to establish a link between the deployed base and oracle contracts
        return LDelayOracle.deployed().then(function(instance) {
            oracle = instance;
            expectThrow(oracle.setBaseContractAddress(accounts[5], {from: accounts[0], gas:2000000})) //should throw
        });
    });
})