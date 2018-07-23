var LDelayBase = artifacts.require("LDelayBase");

contract('LDelayBase', function(accounts){
    it("should accept a deposit of ethereum", function() {
        return LDelayBase.deployed()
            .then(function(instance) {
                ldelay = instance;
                return ldelay.depositPremium({from:accounts[0],value:web3.toWei(3,"ether")})
        })
    });
    it("should not accept a deposit less than the premium amount", function() {
        return LDelayBase.deployed()
            .then(function(instance) {
                ldelay = instance;
                ldelay.depositPremium({from:accounts[0],value:web3.toWei(2,"ether")})
                    .then(async function(promise) {
                        try {
                          await promise;
                          assert.fail('Expected revert not received');
                        } catch (error) {
                          const revertFound = error.message.search('revert') >= 0;
                          assert(revertFound, `Expected "revert", got ${error} instead`);
                        }
                      })
                        //txObj => assert.strictEqual(txObj.receipt.status, '0x00', '0x00 indicates transaction failed'));
            })
        });
    })