var LDelayOracle = artifacts.require("LDelayOracle");
var LDelayBase = artifacts.require("LDelayBase");

contract('LDelayOracle', function(accounts){

    var base = LDelayBase.deployed().address

    it("should accept a call to the oraclize library", function() {
        return LDelayOracle.deployed()
            .then(function(instance) {
                oracle = instance;
                var policyid = 1;
                var timelimit = 2;
                return oracle.getLTrainStatus(policyid, timelimit, {from: base, value: web3.toWei(0.1, "ether"), gas:2000000})
        })
    });
    it("should not accept a call from any contract other than base", function() {
        //pass
    });
    it("should write status back into base contract", function() {
        //pass
    })
    it("should not write status if oraclize callback has not finished", function() {
        //pass
    })
    it("should not allow other calls to setBaseContractAddress", function() {
        //pass
    });
})