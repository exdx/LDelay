// var HDWalletProvider = require("truffle-hdwallet-provider");
// var rinkeby = require('./rinkeby');


module.exports = {
    networks: {
      development: {
        host: "localhost",
        port: 9545,
        network_id: "*" // Match any network id
      }
    }//,
//     rinkeby: {
//         provider: function() {
//           return new HDWalletProvider(rinkeby.mnemonic, "https://rinkeby.infura.io/" + rinkeby.apiKey.toString());
//         },
//         network_id: 4,
//         gasPrice: 20000000000,
//         gas: 3716887
//   }
};
  
