var LDelayBase = artifacts.require("LDelayBase");
var LDelayOracle = artifacts.require("LDelayOracle");
var SafeMath = artifacts.require("libraries/SafeMath");
var StringUtils = artifacts.require("libraries/StringUtils");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.deploy(StringUtils);

  deployer.link(SafeMath, LDelayBase).then(() => {
        deployer.link(StringUtils, LDelayBase)
    });
    deployer.deploy(LDelayOracle).then(function() {
        return deployer.deploy(LDelayBase, LDelayOracle.address);
    });
        // .then(
        //     LDelayOracle.call(setBaseContractAddress({from:LDelayBase.address}))
        // )
};