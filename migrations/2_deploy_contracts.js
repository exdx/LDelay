var LDelayBase = artifacts.require("LDelayBase");
var LDelayOracle = artifacts.require("LDelayOracle");
var SafeMath = artifacts.require("libraries/SafeMath");
var StringUtils = artifacts.require("libraries/StringUtils");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(SafeMath);
  deployer.deploy(StringUtils);

  deployer.link(SafeMath, LDelayBase).then(() => {
        deployer.link(StringUtils, LDelayBase)
    });
    deployer.deploy(LDelayOracle, {from: accounts[9], gas: 6000000, value: 1000000000000000000}).then(function() {
        return deployer.deploy(LDelayBase, LDelayOracle.address, {from: accounts[9], gas: 6000000, value: 2000000000000000000});
    });
};