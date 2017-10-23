/* global assert, it, artifacts, contract, before */

/**
 * DCORP Proxy execution integration tests
 *
 * #created 17/10/2017
 * #author Frank Bonnet
 */
var MockDCORP = artifacts.require('MockDCORP')
var DcorpProxy = artifacts.require('DcorpProxy')
var DRPSToken = artifacts.require('DRPSToken')
var DRPUToken = artifacts.require('DRPUToken')

// Modules
var BigNumber = require('bignumber.js')
var web3Factory = require('./lib/web3_factory.js')
var web3 = web3Factory.create({testrpc: true})

// Helpers
var util = require('./lib/util.js')

/**
 * Start a cleanroom
 */
contract('DcorpProxy (Deploy)', function (accounts) {
    // Config
  var drpsTokenholders = [{
    account: accounts[8],
    balance: 9000
  }]

  var drpuTokenholders = [{
    account: accounts[6],
    balance: 54000
  }]

  var rejectedAddress = accounts[4]
  var acceptedAddress = accounts[5]
  var nonDrpCrowdsaleAddress = accounts[1]
  var crowdsaleBalance

  var crowdsaleInstance
  var proxyInstance
  var drpsTokenInstance
  var drpuTokenInstance

    // Setup test
  before(function () {
    return DRPSToken.deployed().then(function (_instance) {
      drpsTokenInstance = _instance

      var promises = []
      for (var i = 0; i < drpsTokenholders.length; i++) {
        promises.push(drpsTokenInstance.issue(
                    drpsTokenholders[i].account, drpsTokenholders[i].balance))
      }

      return Promise.all(promises)
    })
    .then(function () {
      return DRPUToken.deployed()
    })
    .then(function (_instance) {
      drpuTokenInstance = _instance

      var promises = []
      for (var i = 0; i < drpuTokenholders.length; i++) {
        promises.push(drpuTokenInstance.issue(
                drpuTokenholders[i].account, drpuTokenholders[i].balance))
      }

      return Promise.all(promises)
    })
    .then(function () {
      return DcorpProxy.deployed()
    })
    .then(function (_instance) {
      proxyInstance = _instance
      return MockDCORP.deployed()
    })
    .then(function (_instance) {
      crowdsaleInstance = _instance
      return crowdsaleInstance.proposeTransfer(proxyInstance.address)
    })
    .then(function () {
      return web3.eth.getBalancePromise(crowdsaleInstance.address)
    })
    .then(function (_balance) {
      crowdsaleBalance = new BigNumber(_balance)
    })
  })

  it('Should be in the deploying stage initially', function () {
    return proxyInstance.isDeploying.call().then(function (_isDeploying) {
      assert.isTrue(_isDeploying, 'Should be in the deploying stage')
    })
  })

  it('Should not allow any account other than the drp tokens to call notifyTokensReceived()', function () {
    var account = drpsTokenholders[0].account
    var token = drpsTokenInstance.address
    return proxyInstance.notifyTokensReceived(account, 10, {from: account}).catch(
            (error) => util.errors.throws(error, 'Accounts other than the drp tokens shouldnot be able to call this function'))
        .then(function () {
          return proxyInstance.balanceOf.call(token, account)
        })
        .then(function (_balance) {
          assert.isTrue(new BigNumber(_balance).eq(0), 'No tokens should have been allocated')
        })
  })

  it('Should not accept drps tokens in the deploying stage', function () {
    return drpsTokenInstance.transfer(proxyInstance.address, drpsTokenholders[0].balance, {from: drpsTokenholders[0].account}).catch(
            (error) => util.errors.throws(error, 'Should not accept drps tokens from in deploying stage'))
        .then(function () {
          return drpsTokenInstance.balanceOf.call(proxyInstance.address)
        })
        .then(function (_balance) {
          assert.isTrue(new BigNumber(_balance).eq(0), 'Proxy should not have a drps balance')
        })
  })

  it('Should not accept drpu tokens in the deploying stage', function () {
    return drpuTokenInstance.transfer(proxyInstance.address, drpuTokenholders[0].balance, {from: drpuTokenholders[0].account}).catch(
            (error) => util.errors.throws(error, 'Should not accept drpu tokens from in deploying stage'))
        .then(function () {
          return drpuTokenInstance.balanceOf.call(proxyInstance.address)
        })
        .then(function (_balance) {
          assert.isTrue(new BigNumber(_balance).eq(0), 'Proxy should not have a drpu balance')
        })
  })

  it('Should not be able to propose an address in the deploying stage', function () {
    return proxyInstance.propose(acceptedAddress).catch(
        (error) => util.errors.throws(error, 'Should not accept a proposal deploying stage'))
    .then(function () {
      return proxyInstance.getProposalCount.call()
    })
    .then(function (_count) {
      assert.isTrue(new BigNumber(_count).eq(0), 'Should not contain any proposals')
    })
  })

  it('Should not accept eth from another address than the crowdsale', function () {
    return proxyInstance.sendTransaction({value: crowdsaleBalance, from: nonDrpCrowdsaleAddress}).catch(
        (error) => util.errors.throws(error, 'Should not accept ehter from nonDrpCrowdsaleAddress'))
    .then(function () {
      return web3.eth.getBalancePromise(proxyInstance.address)
    })
    .then(function (_balance) {
      assert.isTrue(new BigNumber(_balance).eq(0), 'Balance should not be updated')
      return proxyInstance.isDeploying.call()
    })
    .then(function (_isDeploying) {
      assert.isTrue(_isDeploying, 'Should be in the deploying stage')
    })
  })

  it('Should not be able to deploy before receiving eth', function () {
    return proxyInstance.deploy().catch(
      (error) => util.errors.throws(error, 'Should not be able to call the deploy function'))
    .then(function() {
      return proxyInstance.isDeployed.call()
    })
    .then(function (_isDeployed) {
        assert.isFalse(_isDeployed, 'Should be in the deploying stage')
    })
  })

  it('Should be able to send eth to the proxy in the deploying stage', function () {
    return crowdsaleInstance.executeTransfer().then(function () {
      return web3.eth.getBalancePromise(proxyInstance.address)
    })
    .then(function (_balance) {
      assert.isTrue(new BigNumber(_balance).eq(crowdsaleBalance), 'Balance should be updated')
    })
  })

  it('Should be able to deploy after receiving eth', function () {
    return proxyInstance.deploy().then(function() {
      return proxyInstance.isDeployed.call()
    })
    .then(function (_isDeployed) {
        assert.isTrue(_isDeployed, 'Should be in the deployed stage')
    })
  })

  it('Should not be able to send eth to the proxy in the deployed stage', function () {
    var balanceBefore
    return web3.eth.getBalancePromise(proxyInstance.address).then(function (_balance) {
      balanceBefore = new BigNumber(_balance)
      return crowdsaleInstance.sendTransaction({value: crowdsaleBalance, from: nonDrpCrowdsaleAddress})
    })
    .then(function () {
      return crowdsaleInstance.executeTransfer()
    })
    .catch((error) => util.errors.throws(error, 'Should not accept ehter from when in the deployed stage'))
    .then(function () {
      return web3.eth.getBalancePromise(proxyInstance.address)
    })
    .then(function (_balance) {
      assert.isTrue(new BigNumber(_balance).eq(balanceBefore), 'Balance should not be updated')
    })
  })

  it('Should accept drps tokens in the deployed stage', function () {
    return drpsTokenInstance.transfer(proxyInstance.address, drpsTokenholders[0].balance, {from: drpsTokenholders[0].account}).then(function () {
      return drpsTokenInstance.balanceOf.call(proxyInstance.address)
    })
    .then(function (_balance) {
      assert.isTrue(new BigNumber(_balance).eq(drpsTokenholders[0].balance), 'Proxy should have a drps balance')
    })
  })

  it('Should accept drpu tokens in the deployed stage', function () {
    return drpuTokenInstance.transfer(proxyInstance.address, drpuTokenholders[0].balance, {from: drpuTokenholders[0].account}).then(function () {
      return drpuTokenInstance.balanceOf.call(proxyInstance.address)
    })
        .then(function (_balance) {
          assert.isTrue(new BigNumber(_balance).eq(drpuTokenholders[0].balance), 'Proxy should have a drpu balance')
        })
  })

  it('Should be able to propose an address in the deployed stage', function () {
    return proxyInstance.getProposalCount.call().then(function (_count) {
      assert.isTrue(new BigNumber(_count).eq(0), 'Should contain no proposal')
      return proxyInstance.isProposed.call(acceptedAddress)
    })
        .then(function (_isProposed) {
          assert.isFalse(_isProposed, 'Should not be proposed')
          return proxyInstance.propose(acceptedAddress)
        })
        .then(function () {
          return proxyInstance.getProposalCount.call()
        })
        .then(function (_count) {
          assert.isTrue(new BigNumber(_count).eq(1), 'Should contain one proposal')
          return proxyInstance.isProposed.call(acceptedAddress)
        })
        .then(function (_isProposed) {
          assert.isTrue(_isProposed, 'Should be proposed')
        })
  })
})
