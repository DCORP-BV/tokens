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
  
  function test_Owner_Can_Change_Rate() {

    // Arange
    uint newRate = 15000;
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    uint rateBefore = changer.getRate();

    // Act
    changer.setRate(newRate);
    uint rateAfter = changer.getRate();

    // Assert
    Assert.notEqual(newRate, rateBefore, "New rate must be different from the current rate");
    Assert.equal(newRate, rateAfter, "Rate should have been updated");
  }

  function test_Owner_Can_Change_Fee() {

    // Arange
    uint newFee = 200;
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    uint feeBefore = changer.getFee();

    // Act
    changer.setFee(newFee);
    uint feeAfter = changer.getFee();

    // Assert
    Assert.notEqual(newFee, feeBefore, "New fee must be different from the current fee");
    Assert.equal(newFee, feeAfter, "Fee should have been updated");
  }

  function test_Owner_Can_Change_Precision() {

    // Arange
    uint newDecimals = 5;
    uint newPrecision = 10**newDecimals;
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    uint precisionBefore = changer.getPrecision();

    // Act
    changer.setPrecision(newDecimals);
    uint precisionAfter = changer.getPrecision();

    // Assert
    Assert.notEqual(newPrecision, precisionBefore, "New precision must be different from the current fee");
    Assert.equal(newPrecision, precisionAfter, "Precision should have been updated");
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

  function test_Non_Owner_Cannot_Change_Rate() {

    // Arange
    uint newRate = 15000;
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);
    CallProxy proxy = CallProxy(callProxyFactory.create(changer));

    uint rateBefore = changer.getRate();

    // Act
    DRPTokenChanger(proxy).setRate(newRate); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    uint rateAfter = changer.getRate();

    // Assert
    Assert.notEqual(newRate, rateBefore, "New rate must be different from the current rate");
    Assert.equal(rateBefore, rateAfter, "Rate should not have been updated");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Non_Owner_Cannot_Change_Fee() {

    // Arange
    uint newFee = 200;
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);
    CallProxy proxy = CallProxy(callProxyFactory.create(changer));

    uint feeBefore = changer.getFee();

    // Act
    DRPTokenChanger(proxy).setFee(newFee); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    uint feeAfter = changer.getFee();

    // Assert
    Assert.notEqual(newFee, feeBefore, "New fee must be different from the current fee");
    Assert.equal(feeBefore, feeAfter, "Fee should not have been updated");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Non_Owner_Cannot_Change_Precision() {

    // Arange
    uint newDecimals = 5;
    uint newPrecision = 10**newDecimals;
    DRPSToken drpsToken = DRPSToken(DeployedAddresses.DRPSToken());
    DRPUToken drpuToken = DRPUToken(DeployedAddresses.DRPUToken());
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);
    CallProxy proxy = CallProxy(callProxyFactory.create(changer));

    uint precisionBefore = changer.getPrecision();

    // Act
    DRPTokenChanger(proxy).setPrecision(newDecimals); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    uint precisionAfter = changer.getPrecision();

    // Assert
    Assert.notEqual(newPrecision, precisionBefore, "New precision must be different from the current fee");
    Assert.equal(precisionBefore, precisionAfter, "Precision should not have been updated");
    Assert.isTrue(hasThrown, "Should have thrown");
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
