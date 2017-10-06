
// Contracts
var Whitelist = artifacts.require("Whitelist")
var DRPUToken = artifacts.require("DRPUToken")
var DRPSToken = artifacts.require("DRPSToken")

// Testing
var Accounts = artifacts.require("Accounts")
var TestCallProxyFactory = artifacts.require("CallProxyFactory")

var deployTestArtifacts = function (deployer, network, accounts) {
  return deployer.deploy(Accounts, accounts)
}

module.exports = function(deployer, network, accounts) {
  var whitelistInstance
  var drpuInstance
  var drpsInstance

  var preDeploy = Promise.resolve();
  if (network == 'test' || network == 'develop') {
    preDeploy = function (deployer, network, accounts) {
      return deployTestArtifacts(deployer, network, accounts)
    }
  }

  return preDeploy(deployer, network, accounts).then(function (){
    return deployer.deploy(Whitelist)
  }) 
  .then(function () {
    return Whitelist.deployed()
  })
  .then(function (_instance) {
    whitelistInstance = _instance
    return deployer.deploy(DRPUToken)
  })
  .then(function () {
    return DRPUToken.deployed()
  })
  .then(function (_instance) {
    drpuInstance = _instance
    return deployer.deploy(DRPSToken)
  })
  .then(function () {
    return DRPSToken.deployed()
  })
  .then(function (_instance) {
    drpsInstance = _instance
  })
}
