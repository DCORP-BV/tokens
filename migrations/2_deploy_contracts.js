
// Contracts
var Whitelist = artifacts.require("Whitelist")
var DRPUToken = artifacts.require("DRPUToken")
var DRPSToken = artifacts.require("DRPSToken")
var DRPTokenChanger = artifacts.require("DRPTokenChanger")
var DRPUTokenConverter = artifacts.require("DRPUTokenConverter")
var DRPSTokenConverter = artifacts.require("DRPSTokenConverter")

// Testing
var Accounts = artifacts.require("Accounts")
var DRPMockToken = artifacts.require("MockToken")

// Instances
var whitelistInstance
var drpuInstance
var drpsInstance
var drpTokenChangerInstance
var drpuTokenConverterInstance
var drpsTokenConverterInstance

// Vars
var drpAddress

var preDeploy = () => Promise.resolve()
var postDeploy = () => Promise.resolve()

var isTestingNetwork = function (network) {
  return network == 'test' || network == 'develop' || network == 'development'
}

var deployTestArtifacts = function (deployer, network, accounts) {
  return deployer.deploy(Accounts, accounts).then(function () {
    return deployer.deploy(DRPMockToken, 'DCorp', 'DRP', 2, false)
  })
  .then(function () {
    return DRPMockToken.deployed()
  })
  .then(function (_instance) {
    drpAddress = _instance.address
    return Promise.resolve()
  })
}

var cleanUp = function (deployingAccount) {
  return drpsInstance.removeOwner(deployingAccount).then(function(){
    return drpuInstance.removeOwner(deployingAccount)
  })
}

module.exports = function(deployer, network, accounts) {

  // Test env settings
  if (isTestingNetwork(network)) {
    preDeploy = function () {
      return deployTestArtifacts(deployer, network, accounts)
    }
    postDeploy = function () {
      return cleanUp(accounts[0])
    }
  }

  // Deploy
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
    return deployer.deploy(DRPUTokenConverter, whitelistInstance.address, drpAddress, drpuInstance.address) 
  })
  .then(function () {
    return DRPUTokenConverter.deployed()
  })
  .then(function (_instance) {
    drpuTokenConverterInstance = _instance
    return deployer.deploy(DRPSTokenConverter, whitelistInstance.address, drpAddress, drpsInstance.address) 
  })
  .then(function () {
    return DRPSTokenConverter.deployed()
  })
  .then(function (_instance) {
    drpsTokenConverterInstance = _instance
    return drpsInstance.addOwner(drpsTokenConverterInstance.address)
  })
  .then(function () {
    return drpuInstance.addOwner(drpuTokenConverterInstance.address)
  })
  .then(function () {
    return postDeploy()
  })
}
