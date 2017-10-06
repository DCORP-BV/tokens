pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/Accounts.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/DRPUToken.sol";

/**
 * DRPU token transfer unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPUTokenTransfer {

  Accounts private accounts;
  CallProxyFactory private callProxyFactory;

  function TestDRPUTokenTransfer() {
    accounts = Accounts(DeployedAddresses.Accounts());
    callProxyFactory = new CallProxyFactory();    
  }

  function test_Can_Transfer() {

    // Arrange
    uint amount = 25;
    address sender = this;
    address receiver = accounts.get(2);

    DRPUToken token = new DRPUToken();
    token.issue(sender, amount);

    uint senderBalanceBefore = token.balanceOf(sender);
    uint receiverBalanceBefore = token.balanceOf(receiver);

    // Act
    token.transfer(receiver, amount);
    uint senderBalanceAfter = token.balanceOf(sender);
    uint receiverBalanceAfter = token.balanceOf(receiver);

    // Assert
    Assert.equal(senderBalanceBefore - amount, senderBalanceAfter, "Amount should have been deducted from senders' balance");
    Assert.equal(receiverBalanceBefore + amount, receiverBalanceAfter, "Amount should have been added to receiver' balance");
  }

  function test_Cannot_Transfer_With_Insufficient_Balance() {

    // Arrange
    uint amount = 25;
    address sender = this;
    address receiver = accounts.get(2);

    DRPUToken token = new DRPUToken();
    token.issue(sender, amount - 1);

    uint senderBalanceBefore = token.balanceOf(sender);
    uint receiverBalanceBefore = token.balanceOf(receiver);

    // Act
    bool hasThrown = !address(token).call(bytes4(bytes32(sha3("transfer(address,uint)"))), receiver, amount);
    uint senderBalanceAfter = token.balanceOf(sender);
    uint receiverBalanceAfter = token.balanceOf(receiver);

    // Assert
    Assert.equal(senderBalanceBefore, senderBalanceAfter, "Senders' balance should not have been changed");
    Assert.equal(receiverBalanceBefore, receiverBalanceAfter, "Receiver' balance should not have been changed");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Cannot_Transfer_While_In_Locked_State() {

    // Arrange
    uint amount = 25;
    address sender = this;
    address receiver = accounts.get(2);

    DRPUToken token = new DRPUToken();
    token.issue(sender, amount);
    token.lock();

    uint senderBalanceBefore = token.balanceOf(sender);
    uint receiverBalanceBefore = token.balanceOf(receiver);

    // Act
    bool hasThrown = !address(token).call(bytes4(bytes32(sha3("transfer(address,uint)"))), receiver, amount);
    uint senderBalanceAfter = token.balanceOf(sender);
    uint receiverBalanceAfter = token.balanceOf(receiver);

    // Assert
    Assert.equal(senderBalanceBefore, senderBalanceAfter, "Senders' balance should not have been changed");
    Assert.equal(receiverBalanceBefore, receiverBalanceAfter, "Receiver' balance should not have been changed");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
