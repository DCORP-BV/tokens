pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/DRPUToken.sol";

/**
 * DRPU token unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPUToken {

  CallProxyFactory private callProxyFactory;

  function TestDRPUToken() {
    callProxyFactory = new CallProxyFactory();
  }
  
  function test_Initial_Balance_Is_Zero_Using_Deployed_Contract() {

    // Arange
    DRPUToken token = DRPUToken(DeployedAddresses.DRPUToken());
    uint expected = 0;

    // Act
    uint actual = token.totalSupply();

    // Assert
    Assert.equal(
      actual, expected, "The initial supply should be 0 initially");
  }

  function test_Initial_Balance_Is_Zero_Using_New_Instance() {
    
    // Arrange
    DRPUToken token = new DRPUToken();
    uint expected = 0;

    // Act
    uint actual = token.totalSupply();

    // Assert
    Assert.equal(
      actual, expected, "The initial supply should be 0 initially");
  }

  function test_Initial_Unlocked_State_Using_Deployed_Contract() {
    
    // Arange
    DRPUToken token = DRPUToken(DeployedAddresses.DRPUToken());

    // Act 
    bool locked = token.isLocked();

    // Assert
    Assert.isFalse(
      locked, "The contract should not be in the locked state");
  }

  function test_Initial_Unlocked_State_Using_New_Instance() {

    // Arange
    DRPUToken token = new DRPUToken();

    // Act 
    bool locked = token.isLocked();

    // Assert
    Assert.isFalse(
      locked, "The contract should not be in the locked state");
  }

  function test_Owner_Can_Lock() {

    // Arrange
    DRPUToken token = new DRPUToken();
    bool lockedBefore = token.isLocked();

    // Act
    token.lock();
    bool lockedAfter = token.isLocked();

    // Assert
    Assert.isFalse(lockedBefore, "For this test the token is expected to be in the unlocked stage initially");
    Assert.isTrue(lockedAfter, "The token should be in the locked stage");
  }

  function test_Non_Owner_Cannot_Lock() {
    
    // Arrange
    DRPUToken token = new DRPUToken();
    CallProxy proxy = CallProxy(callProxyFactory.create(token));
    bool lockedBefore = token.isLocked();

    // Act
    DRPUToken(proxy).lock(); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool lockedAfter = token.isLocked();

    // Assert
    Assert.isFalse(lockedBefore, "For this test the token is expected to be in the unlocked stage initially");
    Assert.isFalse(lockedAfter, "The token should still be in the unlocked stage");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Owner_Can_Unlock() {

    // Arrange
    DRPUToken token = new DRPUToken();
    token.lock();
    bool lockedBefore = token.isLocked();

    // Act
    token.unlock();
    bool lockedAfter = token.isLocked();

    // Assert
    Assert.isTrue(lockedBefore, "For this test the token is expected to be in the locked stage initially");
    Assert.isFalse(lockedAfter, "The token should be in the unlocked stage");
  }

  function test_Non_Owner_Cannot_Unlock() {
    
    // Arrange
    DRPUToken token = new DRPUToken();
    CallProxy proxy = CallProxy(callProxyFactory.create(token));
    token.lock();
    bool lockedBefore = token.isLocked();

    // Act
    DRPUToken(proxy).unlock(); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool lockedAfter = token.isLocked();

    // Assert
    Assert.isTrue(lockedBefore, "For this test the token is expected to be in the locked stage initially");
    Assert.isTrue(lockedAfter, "The token should still be in the locked stage");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
