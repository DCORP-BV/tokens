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
var time = require('./lib/time.js')

/**
 * Start a cleanroom
 */
contract('DcorpProxy (Execution)', function (accounts) {
    // Config
  var drpsTokenholders = [{
    account: accounts[8],
    balance: 9000
  }, {
    account: accounts[9],
    balance: 40
  }]

  var drpuTokenholders = [{
    account: accounts[6],
    balance: 54000
  }, {
    account: accounts[7],
    balance: 60
  }]

  var rejectedAddress = accounts[1]
  var acceptedAddress = accounts[2]

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
      return crowdsaleInstance.executeTransfer()
    })
    .then(function () {
      return proxyInstance.deploy()
    })
    .then(function () {
      var promises = []
      for (var i = 0; i < drpsTokenholders.length; i++) {
        promises.push(drpsTokenInstance.transfer(
                proxyInstance.address, drpsTokenholders[i].balance, {from: drpsTokenholders[i].account}))
      }

      for (var ii = 0; ii < drpuTokenholders.length; ii++) {
        promises.push(drpuTokenInstance.transfer(
                proxyInstance.address, drpuTokenholders[ii].balance, {from: drpuTokenholders[ii].account}))
      }
    })
  })

  it('Should be able to reject a proposal', function () {
    return proxyInstance.propose(rejectedAddress).then(function () {
      var promises = []
      for (var i = 0; i < drpsTokenholders.length; i++) {
        promises.push(proxyInstance.vote(
                    rejectedAddress, true, {from: drpsTokenholders[i].account}))
      }

      for (var ii = 0; ii < drpuTokenholders.length; ii++) {
        promises.push(proxyInstance.vote(
                    rejectedAddress, false, {from: drpuTokenholders[ii].account}))
      }
      return Promise.all(promises)
    })
        .then(function () {
          return proxyInstance.isSupported.call(rejectedAddress, false)
        })
        .then(function (_supported) {
          assert.isFalse(_supported, 'Proposal should not be supported')
        })
  })

  it('Should be able to accept a proposal', function () {
    return proxyInstance.propose(acceptedAddress).then(function () {
      var promises = []
      for (var i = 0; i < drpsTokenholders.length; i++) {
        promises.push(proxyInstance.vote(
                    acceptedAddress, false, {from: drpsTokenholders[i].account}))
      }

      for (var ii = 0; ii < drpuTokenholders.length; ii++) {
        promises.push(proxyInstance.vote(
                    acceptedAddress, true, {from: drpuTokenholders[ii].account}))
      }
      return Promise.all(promises)
    })
        .then(function () {
          return proxyInstance.isSupported.call(acceptedAddress, false)
        })
        .then(function (_supported) {
          assert.isTrue(_supported, 'Proposal should be supported')
        })
  })

  it('Should not be able to execute a rejected proposal before the end of the voting period', function () {
    return proxyInstance.execute(rejectedAddress).catch(
            (error) => util.errors.throws(error, 'Should not be able to execute the proposal'))
        .then(function () {
          return proxyInstance.isExecuted.call()
        })
        .then(function (_executed) {
          assert.isFalse(_executed, 'The proxy should not be executed')
        })
  })

  it('Should not be able to execute an accepted proposal before the end of the voting period', function () {
    return proxyInstance.execute(acceptedAddress).catch(
            (error) => util.errors.throws(error, 'Should not be able to execute the proposal'))
        .then(function () {
          return proxyInstance.isExecuted.call()
        })
        .then(function (_executed) {
          assert.isFalse(_executed, 'The proxy should not be executed')
        })
  })

  it('Should not be able to execute a rejected proposal after the end of the voting period', function () {
    return proxyInstance.getVotingDuration.call().then(function (_votingPeriod) {
      return web3.evm.increaseTimePromise(_votingPeriod.toNumber() + 1 * time.days)
    })
        .then(function () {
          return proxyInstance.isExecuted()
        })
        .then(function () {
          return proxyInstance.execute(rejectedAddress)
        })
        .catch((error) => util.errors.throws(error, 'Should not be able to execute the proposal'))
        .then(function () {
          return proxyInstance.isExecuted.call()
        })
        .then(function (_executed) {
          assert.isFalse(_executed, 'The proxy should not be executed')
        })
  })

  it('Should be the owner of both tokens before execution', function () {
    return drpuTokenInstance.isOwner(proxyInstance.address).then(function (_isOwner) {
      assert.isTrue(_isOwner, 'Proxy should be an owner of the drpu token')
      return drpsTokenInstance.isOwner(proxyInstance.address)
    })
        .then(function (_isOwner) {
          assert.isTrue(_isOwner, 'Proxy should be an owner of the drps token')
        })
  })

  it('Should not have added the accepted address as owner to both tokens before execution', function () {
    return drpuTokenInstance.isOwner(acceptedAddress).then(function (_isOwner) {
      assert.isFalse(_isOwner, 'Accepted address should not be an owner of the drpu token')
      return drpsTokenInstance.isOwner(acceptedAddress)
    })
        .then(function (_isOwner) {
          assert.isFalse(_isOwner, 'Accepted address should not be an owner of the drps token')
        })
  })

  it('Should be able to execute an accepted proposal after the end of the voting period', function () {
    var initialProxyBalance
    var initialAcceptedAddressBalance
    var proxyBalance
    var acceptedAddressBalance
    return web3.eth.getBalancePromise(proxyInstance.address).then(function (_balance) {
      initialProxyBalance = new BigNumber(_balance)
      return web3.eth.getBalancePromise(acceptedAddress)
    })
        .then(function (_balance) {
          initialAcceptedAddressBalance = new BigNumber(_balance)
          return proxyInstance.execute(acceptedAddress)
        })
        .then(function () {
          return proxyInstance.isExecuted.call()
        })
        .then(function (_executed) {
          assert.isTrue(_executed, 'The should be executed')
          return web3.eth.getBalancePromise(proxyInstance.address)
        })
        .then(function (_balance) {
          proxyBalance = new BigNumber(_balance)
          return web3.eth.getBalancePromise(acceptedAddress)
        })
        .then(function (_balance) {
          acceptedAddressBalance = new BigNumber(_balance)
          assert.isTrue(initialProxyBalance.gt(proxyBalance), 'Initial proxy balance should be larger than balance after execution')
          assert.isTrue(proxyBalance.eq(0), 'Proxy balance after execution should be zero')
          assert.isTrue(initialAcceptedAddressBalance.lt(acceptedAddressBalance), 'Initial accepted address balance should be smaller than balance after execution')
          assert.isTrue(acceptedAddressBalance.eq(initialAcceptedAddressBalance.add(initialProxyBalance)), 'Accepted address balance should be equal to the sum of both initial balances')
        })
  })

  it('Should have added the accepted address as owner to both tokens after execution', function () {
    return drpuTokenInstance.isOwner(acceptedAddress).then(function (_isOwner) {
      assert.isTrue(_isOwner, 'Accepted address should be an owner of the drpu token')
      return drpsTokenInstance.isOwner(acceptedAddress)
    })
        .then(function (_isOwner) {
          assert.isTrue(_isOwner, 'Accepted address should be an owner of the drps token')
        })
  })

  it('Should have removed the proxy as owner from both tokens after execution', function () {
    return drpuTokenInstance.isOwner(proxyInstance.address).then(function (_isOwner) {
      assert.isFalse(_isOwner, 'Proxy should not be an owner of the drpu token')
      return drpsTokenInstance.isOwner(proxyInstance.address)
    })
        .then(function (_isOwner) {
          assert.isFalse(_isOwner, 'Proxy not should be an owner of the drps token')
        })
  })

  it('Should not be able to send eth to the proxy after execution', function () {
    var amount = web3.utils.toWei(1, 'ether')
    return proxyInstance.sendTransaction({value: amount, from: accounts[0]}).catch(
            (error) => util.errors.throws(error, 'Should not be able to send eth'))
        .then(function () {
          return web3.eth.getBalancePromise(proxyInstance.address)
        })
        .then(function (_balance) {
          assert.isTrue(new BigNumber(_balance).eq(0), 'Balance should be zero')
        })
  })
})
