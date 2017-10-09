pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/Accounts.sol";
import "../contracts/test/mock/MockTokenObserver.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/DRPUToken.sol";

/**
 * DRPU token observer unit tests
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPUTokenObserver {

  Accounts private accounts;
  CallProxyFactory private callProxyFactory;

  function TestDRPUTokenObserver() {
    accounts = Accounts(DeployedAddresses.Accounts());
    callProxyFactory = new CallProxyFactory();    
  }

  function test_Owner_Can_Add_Observer() {

    // Arrange
    address observer = this;
    DRPUToken token = new DRPUToken();
    
    bool isObserverBefore = token.isObserver(observer);

    // Act
    token.registerObserver(observer);
    bool isObserverAfter = token.isObserver(observer);

    // Assert
    Assert.isFalse(isObserverBefore, "Should not have been registered as an observer before registration");
    Assert.isTrue(isObserverAfter, "Should have been registered as an observer after registration");
  }

  function test_Non_Owner_Cannot_Add_Observer() {

    // Arrange
    address observer = this;
    DRPUToken token = new DRPUToken();
    CallProxy proxy = CallProxy(callProxyFactory.create(token));

    bool isObserverBefore = token.isObserver(observer);

    // Act
    DRPUToken(proxy).registerObserver(observer); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool isObserverAfter = token.isObserver(observer);

    // Assert
    Assert.isFalse(isObserverBefore, "Should not have been registered as an observer before registration");
    Assert.isFalse(isObserverAfter, "Should note have been registered as an observer after registration");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Observer_Is_Notified() {

    // Arrange
    uint amount = 25;
    address sender = this;

    MockTokenObserver observer = new MockTokenObserver();
    DRPUToken token = new DRPUToken();
    
    token.issue(sender, amount);
    token.registerObserver(observer);

    uint recordCountBefore = observer.getRecordCount();

    // Act
    token.transfer(observer, amount);
    uint recordCountAfter = observer.getRecordCount();
    var (tokenRecord, senderRecord, valueRecord) = observer.getRecordAt(recordCountAfter - 1);

    // Assert
    Assert.equal(recordCountBefore + 1, recordCountAfter, "Observer should have been notified");
    Assert.equal(tokenRecord, token, "Token record does not match");
    Assert.equal(senderRecord, sender, "Sender record does not match");
    Assert.equal(valueRecord, amount, "Value record does not match");
  }

  function test_Owner_Can_Remove_Observer() {

    // Arrange
    address observer = this;
    DRPUToken token = new DRPUToken();
    token.registerObserver(observer);

    bool isObserverBefore = token.isObserver(observer);

    // Act
    token.unregisterObserver(observer);
    bool isObserverAfter = token.isObserver(observer);

    // Assert
    Assert.isTrue(isObserverBefore, "Should have been registered as an observer before registration");
    Assert.isFalse(isObserverAfter, "Should not have been registered as an observer after registration");
  }

  function test_Observer_Can_Remove_Self() {

    // Arrange
    address observer = this;
    address owner = accounts.get(1);
    DRPUToken token = new DRPUToken();
    token.registerObserver(observer);
    token.transferOwnership(owner);

    bool isObserverBefore = token.isObserver(observer);

    // Act
    token.unregisterObserver(observer);
    bool isObserverAfter = token.isObserver(observer);

    // Assert
    Assert.isTrue(isObserverBefore, "Should have been registered as an observer before registration");
    Assert.isFalse(isObserverAfter, "Should not have been registered as an observer after registration");
  }

  function test_Non_Owner_Cannot_Remove_Observer() {

    // Arrange
    address observer = this;
    DRPUToken token = new DRPUToken();
    CallProxy proxy = CallProxy(callProxyFactory.create(token));
    token.registerObserver(observer);

    bool isObserverBefore = token.isObserver(observer);

    // Act
    DRPUToken(proxy).unregisterObserver(observer); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool isObserverAfter = token.isObserver(observer);

    // Assert
    Assert.isTrue(isObserverBefore, "Should have been registered as an observer before registration");
    Assert.isTrue(isObserverAfter, "Should still be registered as an observer after registration");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
