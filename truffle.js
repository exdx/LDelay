module.exports = {
    networks: {
      development: {
        host: "localhost",
        port: 9545,
        gas: 2000000,
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
  
