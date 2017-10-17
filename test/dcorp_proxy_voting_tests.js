/* global assert, it, artifacts, contract, before */

/**
 * DCORP Proxy voting integration tests
 *
 * #created 17/10/2017
 * #author Frank Bonnet
 */
var DcorpProxy = artifacts.require('DcorpProxy')
var DRPSToken = artifacts.require('DRPSToken')
var DRPUToken = artifacts.require('DRPUToken')

// Modules
var BigNumber = require('bignumber.js')

/**
 * Start a cleanroom
 */
contract('DcorpProxy (Voting)', function (accounts) {
    // Config
  var drpsTokenholders = [{
    account: accounts[8],
    balance: 18000
  }, {
    account: accounts[5],
    balance: 540000
  }, {
    account: accounts[9],
    balance: 400
  }]

  var drpuTokenholders = [{
    account: accounts[6],
    balance: 18000
  }, {
    account: accounts[4],
    balance: 540000
  }, {
    account: accounts[7],
    balance: 600 // DRPU holders must have more weight
  }]

  var tokenholders = drpsTokenholders.concat(drpuTokenholders)

  var rejectedAddress = accounts[1]
  var acceptedAddress = accounts[2]

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

          var promises = []
          for (var i = 0; i < drpsTokenholders.length; i++) {
            promises.push(drpsTokenInstance.transfer(
                    proxyInstance.address, drpsTokenholders[i].balance, {from: drpsTokenholders[i].account}))
          }

          for (var i = 0; i < drpuTokenholders.length; i++) {
            promises.push(drpuTokenInstance.transfer(
                    proxyInstance.address, drpuTokenholders[i].balance, {from: drpuTokenholders[i].account}))
          }

          return Promise.all(promises)
        })
  })

  it('Should be able to reject a proposal', function () {
    return proxyInstance.propose(rejectedAddress).then(function () {
      var promises = []
      for (var i = 0; i < drpsTokenholders.length; i++) {
        promises.push(proxyInstance.vote(
                    rejectedAddress, true, {from: drpsTokenholders[i].account}))
      }

      for (var i = 0; i < drpuTokenholders.length; i++) {
        promises.push(proxyInstance.vote(
                    rejectedAddress, false, {from: drpuTokenholders[i].account}))
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

      for (var i = 0; i < drpuTokenholders.length; i++) {
        promises.push(proxyInstance.vote(
                    acceptedAddress, true, {from: drpuTokenholders[i].account}))
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

  it('Should allow vote changes', function () {
    var initiallySupported
    var initialVotes

    return proxyInstance.isSupported.call(acceptedAddress, false).then(function (_supported) {
      initiallySupported = _supported

      var promises = []
      for (var i = 0; i < tokenholders.length; i++) {
        promises.push(proxyInstance.getVote(
                    acceptedAddress, tokenholders[i].account))
      }

      return Promise.all(promises)
    })
        .then(function (_votes) {
          initialVotes = _votes

            // Change votes
          var promises = []
          for (var i = 0; i < tokenholders.length; i++) {
            promises.push(proxyInstance.vote(
                    acceptedAddress, !initialVotes[i], {from: tokenholders[i].account}))
          }

          return Promise.all(promises)
        })
        .then(function () {
          var promises = []
          for (var i = 0; i < tokenholders.length; i++) {
            promises.push(proxyInstance.getVote(
                    acceptedAddress, tokenholders[i].account))
          }

          return Promise.all(promises)
        })
        .then(function (_votes) {
            // Assert that votes have changed
          for (var i = 0; i < tokenholders.length; i++) {
            assert.notEqual(initialVotes[i], _votes[i], 'Vote was not changed')
          }

          return proxyInstance.isSupported.call(acceptedAddress, false)
        })
        .then(function (_supported) {
          assert.notEqual(initiallySupported, _supported, 'Result was not changed')
        })
  })

  it('Withdrawing tokens should affect voting weights', function () {
    var withdrawPercentage = 40
    var withdrawPrecision = 100
    var withdrawRounds = 4

    var initiallySupported
    var initialBalances

    return proxyInstance.isSupported.call(acceptedAddress, false).then(function (_supported) {
      initiallySupported = _supported

      var promises = []
      for (var i = 0; i < drpuTokenholders.length; i++) {
        promises.push(proxyInstance.balanceOf(
                    drpuTokenInstance.address, drpuTokenholders[i].account))
      }

      return Promise.all(promises)
    })
        .then(function (_balances) {
          initialBalances = _balances

            // Withdraw tokens
          var promises = []
          for (var i = 0; i < drpuTokenholders.length; i++) {
            for (var ii = 0; ii < withdrawRounds; ii++) {
              promises.push(proxyInstance.withdrawDRPU(
                    drpuTokenholders[i].balance * withdrawPercentage / withdrawRounds / withdrawPrecision, {from: drpuTokenholders[i].account}))
            }
          }

          return Promise.all(promises)
        })
        .then(function () {
          var promises = []
          for (var i = 0; i < drpuTokenholders.length; i++) {
            promises.push(proxyInstance.balanceOf(
                    drpuTokenInstance.address, drpuTokenholders[i].account))
          }

          return Promise.all(promises)
        })
        .then(function (_balances) {
            // Assert that votes have changed
          for (var i = 0; i < drpuTokenholders.length; i++) {
            var expectedWithdraw = drpuTokenholders[i].balance * withdrawPercentage / withdrawPrecision
            var expectedBalance = drpuTokenholders[i].balance - expectedWithdraw
            assert.isTrue(new BigNumber(_balances[i]).lt(initialBalances[i]), 'Balance should have been changed')
            assert.isTrue(new BigNumber(_balances[i]).eq(expectedBalance), 'Balance was not updated as expected')
            assert.isTrue(new BigNumber(initialBalances[i]).sub(expectedWithdraw).eq(_balances[i]), 'Unexpected amount withdrawn')
          }

          return proxyInstance.isSupported.call(acceptedAddress, false)
        })
        .then(function (_supported) {
          assert.notEqual(initiallySupported, _supported, 'Result was not changed')
        })
  })

  it('Depositing tokens should affect voting weights', function () {
    var depositPercentage = 40
    var depositPrecision = 100
    var depositRounds = 2

    var initiallySupported
    var initialBalances

    return proxyInstance.isSupported.call(acceptedAddress, false).then(function (_supported) {
      initiallySupported = _supported

      var promises = []
      for (var i = 0; i < drpuTokenholders.length; i++) {
        promises.push(proxyInstance.balanceOf(
                    drpuTokenInstance.address, drpuTokenholders[i].account))
      }

      return Promise.all(promises)
    })
        .then(function (_balances) {
          initialBalances = _balances

            // Withdraw tokens
          var promises = []
          for (var i = 0; i < drpuTokenholders.length; i++) {
            for (var ii = 0; ii < depositRounds; ii++) {
              promises.push(drpuTokenInstance.transfer(
                        proxyInstance.address, drpuTokenholders[i].balance * depositPercentage / depositRounds / depositPrecision, {from: drpuTokenholders[i].account}))
            }
          }

          return Promise.all(promises)
        })
        .then(function () {
          var promises = []
          for (var i = 0; i < drpuTokenholders.length; i++) {
            promises.push(proxyInstance.balanceOf(
                    drpuTokenInstance.address, drpuTokenholders[i].account))
          }

          return Promise.all(promises)
        })
        .then(function (_balances) {
            // Assert that votes have changed
          for (var i = 0; i < drpuTokenholders.length; i++) {
            var expectedIncrease = drpuTokenholders[i].balance * depositPercentage / depositPrecision
            var expectedBalance = new BigNumber(initialBalances[i]).add(expectedIncrease)
            assert.isTrue(new BigNumber(_balances[i]).gt(initialBalances[i]), 'Balance should have been changed')
            assert.isTrue(new BigNumber(_balances[i]).eq(expectedBalance), 'Balance was not updated as expected')
            assert.isTrue(new BigNumber(initialBalances[i]).add(expectedIncrease).eq(_balances[i]), 'Unexpected amount deposited')
          }

          return proxyInstance.isSupported.call(acceptedAddress, false)
        })
        .then(function (_supported) {
          assert.notEqual(initiallySupported, _supported, 'Result was not changed')
        })
  })
})
