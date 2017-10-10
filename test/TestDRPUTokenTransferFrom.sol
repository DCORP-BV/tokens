pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/Accounts.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/DRPUToken.sol";

/**
 * DRPU token transfer from unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPUTokenTransferFrom {

  Accounts private accounts;
  CallProxyFactory private callProxyFactory;

  function TestDRPUTokenTransferFrom() {
    accounts = Accounts(DeployedAddresses.Accounts());
    callProxyFactory = new CallProxyFactory();    
  }

  function test_Can_Approve() {
    
    // Arrange
    uint allowance = 80;
    address owner = this;
    address spender = accounts.get(3);

    DRPUToken token = new DRPUToken();
    uint spenderAllowanceBefore = token.allowance(owner, spender);

    // Act
    token.approve(spender, allowance);
    uint spenderAllowanceAfter = token.allowance(owner, spender);

    // Assert
    Assert.equal(spenderAllowanceBefore + allowance, spenderAllowanceAfter, "The allowance of spender for owners' account should have been increased");
  }

  function test_Can_Transfer_From() {
    
    // Arrange
    uint amount = 80;
    uint allowance = 100;
    address owner = this;
    address spender = this;
    address receiver = accounts.get(1);

    DRPUToken token = new DRPUToken();
    token.issue(owner, amount);
    token.approve(spender, allowance);
    
    uint ownerBalanceBefore = token.balanceOf(owner);
    uint receiverBalanceBefore = token.balanceOf(receiver);
    uint spenderAllowanceBefore = token.allowance(owner, spender);

    // Act
    token.transferFrom(owner, receiver, amount);
    uint ownerBalanceAfter = token.balanceOf(owner);
    uint receiverBalanceAfter = token.balanceOf(receiver);
    uint spenderAllowanceAfter = token.allowance(owner, spender);

    // Assert
    Assert.equal(ownerBalanceBefore - amount, ownerBalanceAfter, "Amount should have been deducted from owners' balance");
    Assert.equal(receiverBalanceBefore + amount, receiverBalanceAfter, "Amount should have been added to receiver' balance");
    Assert.equal(spenderAllowanceBefore - amount, spenderAllowanceAfter, "The allowance of spender for owners' account should have been decreased");
  }

  function test_Cannot_Transfer_From_With_Insufficient_Balance() {
    
    // Arrange
    uint amount = 80;
    uint allowance = 100;
    address owner = this;
    address spender = this;
    address receiver = accounts.get(1);

    DRPUToken token = new DRPUToken();
    token.issue(owner, amount - 1);
    token.approve(spender, allowance);
    
    uint spenderAllowanceBefore = token.allowance(owner, spender);

    // Act
    bool hasThrown = !address(token).call(bytes4(bytes32(sha3("transferFrom(address,address,uint256)"))), owner, receiver, amount);
    uint spenderAllowanceAfter = token.allowance(owner, spender);

    // Assert
    Assert.equal(spenderAllowanceBefore, spenderAllowanceAfter, "The allowance of spender for owners' account should not have been changed");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Cannot_Transfer_From_While_In_Locked_State() {
    
    // Arrange
    uint amount = 80;
    uint allowance = 100;
    address owner = this;
    address spender = this;
    address receiver = accounts.get(1);

    DRPUToken token = new DRPUToken();
    token.issue(owner, amount);
    token.approve(spender, allowance);
    token.lock();
    
    uint ownerBalanceBefore = token.balanceOf(owner);
    uint receiverBalanceBefore = token.balanceOf(receiver);

    // Act
    bool hasThrown = !address(token).call(bytes4(bytes32(sha3("transferFrom(address,address,uint256)"))), owner, receiver, amount);
    uint ownerBalanceAfter = token.balanceOf(owner);
    uint receiverBalanceAfter = token.balanceOf(receiver);

    // Assert
    Assert.equal(ownerBalanceBefore, ownerBalanceAfter, "Owners' balance should not have been changed");
    Assert.equal(receiverBalanceBefore, receiverBalanceAfter, "Receiver' balance should not have been changed");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
