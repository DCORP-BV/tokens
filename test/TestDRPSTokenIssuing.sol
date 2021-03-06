pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/Accounts.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/DRPSToken.sol";

/**
 * DRPS token issuing unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPSTokenIssuing {

  Accounts private accounts;
  CallProxyFactory private callProxyFactory;

  function TestDRPSTokenIssuing() {
    accounts = Accounts(DeployedAddresses.Accounts());
    callProxyFactory = new CallProxyFactory();
  }

  function test_Owner_Can_Issue_Tokens() {

    // Arrange
    DRPSToken token = new DRPSToken();
    address receiver = accounts.get(0);
    uint balanceBefore = token.balanceOf(receiver);
    uint amount = 25;

    // Act
    token.issue(receiver, amount);
    uint balanceAfter = token.balanceOf(receiver);

    // Assert
    Assert.equal(balanceAfter, balanceBefore + amount, "Balance should have been increased");
  }

  function test_Issueing_Tokens_Increases_Total_Supply() {

    // Arrange
    DRPSToken token = new DRPSToken();
    address receiver = accounts.get(0);
    uint totalSupplyBefore = token.totalSupply();
    uint amount = 25;

    // Act
    token.issue(receiver, amount);
    uint totalSupplyAfter = token.totalSupply();

    // Assert
    Assert.equal(totalSupplyAfter, totalSupplyBefore + amount, "Total supply should have been increased");
  }

  function test_Non_Owner_Cannot_Issue_Tokens() {
    
    // Arrange
    DRPSToken token = new DRPSToken();
    CallProxy proxy = CallProxy(callProxyFactory.create(token));
    address receiver = accounts.get(0);
    uint balanceBefore = token.balanceOf(receiver);
    uint amount = 25;

    // Act
    DRPSToken(proxy).issue(receiver, amount); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    uint balanceAfter = token.balanceOf(receiver);

    // Assert
    Assert.equal(balanceAfter, balanceBefore, "Balance should not have changed");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
