pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../../contracts/test/Accounts.sol";
import "../../contracts/test/proxy/CallProxy.sol";
import "../../contracts/test/proxy/CallProxyFactory.sol";
import "../../contracts/source/DRPUToken.sol";

/**
 * DRPU token burning unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPUTokenBurning {

  Accounts private accounts;
  CallProxyFactory private callProxyFactory;

  function TestDRPUTokenBurning() {
    accounts = Accounts(DeployedAddresses.Accounts());
    callProxyFactory = new CallProxyFactory();
  }

  function test_Owner_Can_Burn_Tokens() {

    // Arrange
    DRPUToken token = new DRPUToken();
    address from = accounts.get(0);
    uint balance = 25;
    uint amount = 15;
    token.issue(from, balance);
    uint balanceBefore = token.balanceOf(from);
    
    // Act
    token.burn(from, amount);
    uint balanceAfter = token.balanceOf(from);

    // Assert
    Assert.equal(balanceAfter, balanceBefore - amount, "Balance should have been decreased");
  }

  function test_Burning_Tokens_Decreases_Total_Supply() {

    // Arrange
    DRPUToken token = new DRPUToken();
    address from = accounts.get(0);
    uint balance = 25;
    uint amount = 15;
    token.issue(from, balance);
    uint totalSupplyBefore = token.totalSupply();

    // Act
    token.burn(from, amount);
    uint totalSupplyAfter = token.totalSupply();

    // Assert
    Assert.equal(totalSupplyAfter, totalSupplyBefore - amount, "Total supply should have been decreased");
  }

  function test_Owner_Cannot_Burn_More_Tokens_Than_Available_Balance() {
    
    // Arrange
    DRPUToken token = new DRPUToken();
    address from = accounts.get(0);
    uint balance = 25;
    token.issue(from, balance);
    uint balanceBefore = token.balanceOf(from);
    uint amount = balanceBefore + 1;
    
    // Act
    bool hasThrown = !address(token).call(bytes4(bytes32(sha3("burn(address,uint256)"))), from, amount);
    uint balanceAfter = token.balanceOf(from);

    // Assert
    Assert.equal(balanceAfter, balanceBefore, "Balance should not have been decreased");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Non_Owner_Cannot_Burn_Tokens() {
    
    // Arrange
    DRPUToken token = new DRPUToken();
    CallProxy proxy = CallProxy(callProxyFactory.create(token));
    address from = accounts.get(0);
    uint balance = 25;
    uint amount = 15;
    token.issue(from, balance);
    uint balanceBefore = token.balanceOf(from);
    
    // Act
    DRPUToken(proxy).burn(from, amount); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    uint balanceAfter = token.balanceOf(from);

    // Assert
    Assert.equal(balanceAfter, balanceBefore, "Balance should not have been decreased");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
