pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/Accounts.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/DRPUToken.sol";

/**
 * DRPU token ownership unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPUTokenOwnership {

  Accounts private accounts;
  CallProxyFactory private callProxyFactory;

  function TestDRPUTokenOwnership() {
    accounts = Accounts(DeployedAddresses.Accounts());
    callProxyFactory = new CallProxyFactory();
  }

  function test_Initial_Owner_Is_Deploying_Account() {
    
    // Arange
    DRPUToken token = DRPUToken(DeployedAddresses.DRPUToken());

    // Act 
    bool isOwner = token.isOwner(tx.origin);

    // Assert
    Assert.isTrue(isOwner, "The deploying account is not the owner of the token contract");
  }

  function test_Owner_Can_Add_Owner() {

    // Arrange
    DRPUToken token = new DRPUToken();
    address newOwner = accounts.get(0);
    bool isOwnerBefore = token.isOwner(newOwner);

    // Act
    token.addOwner(newOwner);
    bool isOwnerAfter = token.isOwner(newOwner);

    // Assert
    Assert.isFalse(isOwnerBefore, "The new owner cannot be a current owner");
    Assert.isTrue(isOwnerAfter, "The new owner should now be an owner");
  }

  function test_Non_Owner_Cannot_Add_Owner() {
    
     // Arrange
    DRPUToken token = new DRPUToken();
    CallProxy proxy = CallProxy(callProxyFactory.create(token));
    address newOwner = accounts.get(0);
    bool isOwnerBefore = token.isOwner(newOwner);
    uint ownerCountBefore = token.getOwnerCount();

    // Act
    DRPUToken(proxy).addOwner(newOwner); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool isOwnerAfter = token.isOwner(newOwner);
    uint ownerCountAfter = token.getOwnerCount();

    // Assert
    Assert.isFalse(isOwnerBefore, "The new owner cannot be a current owner");
    Assert.isFalse(isOwnerAfter, "The new owner should not be an owner");
    Assert.equal(ownerCountBefore, ownerCountAfter, "Should not have added an owner");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Owner_Can_Remove_Owner() {

    // Arrange
    DRPUToken token = new DRPUToken();
    address newOwner = accounts.get(3);
    token.addOwner(newOwner);

    bool isOwnerBefore = token.isOwner(this);
    uint ownerCountBefore = token.getOwnerCount();

    // Act
    token.removeOwner(this);
    bool isOwnerAfter = token.isOwner(this);
    uint ownerCountAfter = token.getOwnerCount();

    // Assert
    Assert.isTrue(token.isOwner(newOwner), "newOwner should be owner");
    Assert.isTrue(isOwnerBefore, "The new owner should be an owner before");
    Assert.isFalse(isOwnerAfter, "The new owner should be removed after");
    Assert.equal(ownerCountBefore - 1, ownerCountAfter, "Should have removed an owner");
  }

  function test_Non_Owner_Cannot_Remove_Owner() {
    
    // Arrange
    DRPUToken token = new DRPUToken();
    CallProxy proxy = CallProxy(callProxyFactory.create(token));
    address newOwner = accounts.get(0);
    token.addOwner(newOwner);

    bool isOwnerBefore = token.isOwner(newOwner);
    uint ownerCountBefore = token.getOwnerCount();

    // Act
    DRPUToken(proxy).removeOwner(newOwner); // msg.sender will be the proxy
    bool isOwnerAfter = token.isOwner(newOwner);
    uint ownerCountAfter = token.getOwnerCount();

    // Assert
    Assert.isTrue(isOwnerBefore, "The new owner should be an owner before");
    Assert.isTrue(isOwnerAfter, "The new owner should not have been removed after");
    Assert.equal(ownerCountBefore, ownerCountAfter, "Should not have removed an owner");
  }
}
