var LDelayBase = artifacts.require("LDelayBase");

module.exports = function(deployer) {
  deployer.deploy(LDelayBase, {gas:6000000});
};

//support for libraries done below

// const IterableMapping = artifacts.require('IterableMapping.sol');
// const User = artifacts.require('User.sol');

// module.exports = function (deployer) {
//     deployer.deploy(IterableMapping).then(() => {
//         deployer.deploy(User);
//     });
//     deployer.link(IterableMapping, User);
// };