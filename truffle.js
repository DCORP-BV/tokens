module.exports = {
  networks: {
    test: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    main: {
      host: "localhost",
      port: 8547,
      network_id: 1, // Official Ethereum network 
      from: "0xA96Fd4994168bF4A15aeF72142ac605cF45b6d8e"
    }
  }
};
