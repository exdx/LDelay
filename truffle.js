module.exports = {
    networks: {
      development: {
        host: "localhost",
        port: 9545,
        gas: 6721976,
        network_id: "*" // Match any network id
      }
    },
    solc: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
  };
  
