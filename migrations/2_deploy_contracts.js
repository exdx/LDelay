var LDelayBase = artifacts.require("LDelayBase");

module.exports = function(deployer) {
  deployer.deploy(LDelayBase, {gas:6000000});
};