
// Contracts
var Whitelist = artifacts.require("Whitelist")
var DRPUToken = artifacts.require("DRPUToken")
var DRPSToken = artifacts.require("DRPSToken")
var DRPTokenChanger = artifacts.require("DRPTokenChanger")

// Testing
var Accounts = artifacts.require("Accounts")
var TestCallProxyFactory = artifacts.require("CallProxyFactory")

// Instances
var whitelistInstance
var drpuInstance
var drpsInstance
var drpTokenChangerInstance
var deployingAccount

var deployTestArtifacts = function (deployer, network, accounts) {
  return deployer.deploy(Accounts, accounts)
}

var cleanUp = function (deployer, network, accounts) {
  return drpsInstance.removeOwner(deployingAccount).then(function(){
    return drpuInstance.removeOwner(deployingAccount)
  })
}

module.exports = function(deployer, network, accounts) {
  deployingAccount = accounts[0]

  var preDeploy = () => Promise.resolve();
  if (network == 'test' || network == 'develop' || network == 'development') {
    preDeploy = function () {
      return deployTestArtifacts(deployer, network, accounts)
    }
  }

  var postDeploy = () => Promise.resolve();
  if (network != 'test' && network != 'develop' && network != 'development') {
    postDeploy = function () {
      return cleanUp(deployer, network, accounts)
    }
  }

  return preDeploy().then(function (){
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
    return deployer.deploy(
      DRPTokenChanger, drpsInstance.address, drpuInstance.address)
  })
  .then(function () {
    return DRPTokenChanger.deployed()
  })
  .then(function (_instance) {
    drpTokenChangerInstance = _instance
    return drpsInstance.addOwner(drpTokenChangerInstance.address)
  })
  .then(function () {
    return drpuInstance.addOwner(drpTokenChangerInstance.address)
  })
  .then(function () {
    return drpsInstance.registerObserver(drpTokenChangerInstance.address)
  })
  .then(function () {
    return drpuInstance.registerObserver(drpTokenChangerInstance.address)
  })
  .then(function () {
    return postDeploy()
  })
}
