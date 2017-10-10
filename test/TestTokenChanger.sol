pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/Accounts.sol";
import "../contracts/test/mock/MockToken.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/token/changer/TokenChanger.sol";

/**
 * Token changer unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestTokenChanger {

  Accounts private accounts;
  CallProxyFactory private callProxyFactory;

  function TestTokenChanger() {
    accounts = Accounts(DeployedAddresses.Accounts());
    callProxyFactory = new CallProxyFactory();
  }

  function test_Can_Setup_Token_Changer() {

    // Arange
    uint rate = 20000; // 200%
    uint fee = 100; // 1%
    uint precision = 4; // decimals

    MockToken token1 = new MockToken("Token 1", "LEFT", false);
    MockToken token2 = new MockToken("Token 2", "RIGHT", false);

    // Act
    TokenChanger changer = new TokenChanger(
      token1, token2, rate, fee, precision);

    uint actualRate = changer.getRate();
    uint actualFee = changer.getFee();
    uint actualPrecision = changer.getPrecision();
    uint expectedPrecision = 10**precision;

    // Assert
    Assert.equal(rate, actualRate, "Incorrect rate");
    Assert.equal(fee, actualFee, "Incorrect fee");
    Assert.equal(expectedPrecision, actualPrecision, "Incorrect precision");
  }

  function test_Correctly_Calculates_Fee() {

    // Arange
    uint value = 2500;
    uint rate = 20000; // 200%
    uint fee = 100; // 1%
    uint precision = 4; // decimals

    MockToken token1 = new MockToken("Token 1", "LEFT", false);
    MockToken token2 = new MockToken("Token 2", "RIGHT", false);

    TokenChanger changer = new TokenChanger(
      token1, token2, rate, fee, precision);

    // Act
    uint actualFee = changer.calculateFee(value);
    uint expectedFee = value * fee / 10**precision;

    // Assert 
    Assert.equal(actualFee, expectedFee, "Fee is not calculated correctly");
  }
}
