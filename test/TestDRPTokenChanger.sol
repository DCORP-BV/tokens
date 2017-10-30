pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/DRPSToken.sol";
import "../contracts/source/DRPUToken.sol";
import "../contracts/source/DRPTokenChanger.sol";

/**
 * DRP Token changer unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPTokenChanger {

  CallProxyFactory private callProxyFactory;

  function TestDRPTokenChanger() {
    callProxyFactory = new CallProxyFactory();
  }

  function test_Owner_Can_Pause() {

    // Arange
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    bool pausedStateBefore = changer.isPaused();

    // Act
    changer.pause();
    bool pausedStateAfter = changer.isPaused();

    // Assert
    Assert.isFalse(pausedStateBefore, "Should not be in the paused state initially");
    Assert.isTrue(pausedStateAfter, "Should be in the paused state after");
  }

  function test_Owner_Can_Resume() {

    // Arange
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    changer.pause();
    bool pausedStateBefore = changer.isPaused();

    // Act
    changer.resume();
    bool pausedStateAfter = changer.isPaused();

    // Assert
    Assert.isTrue(pausedStateBefore, "Should be in the paused state initially");
    Assert.isFalse(pausedStateAfter, "Should not be in the paused state after");
  }

  function test_Non_Owner_Cannot_Pause() {

    // Arange
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);
    CallProxy proxy = CallProxy(callProxyFactory.create(changer));

    bool pausedStateBefore = changer.isPaused();

    // Act
    DRPTokenChanger(proxy).pause(); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool pausedStateAfter = changer.isPaused();

    // Assert
    Assert.isFalse(pausedStateBefore, "Should not be in the paused state initially");
    Assert.isFalse(pausedStateAfter, "Should not be in the paused state after");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Non_Owner_Cannot_Resume() {

    // Arange
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);
    CallProxy proxy = CallProxy(callProxyFactory.create(changer));

    changer.pause();
    bool pausedStateBefore = changer.isPaused();

    // Act
    DRPTokenChanger(proxy).resume(); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool pausedStateAfter = changer.isPaused();

    // Assert
    Assert.isTrue(pausedStateBefore, "Should be in the paused state initially");
    Assert.isTrue(pausedStateAfter, "Should be in the paused state after");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
