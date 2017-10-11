pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../contracts/test/mock/MockToken.sol";
import "../contracts/source/token/changer/TokenChanger.sol";

/**
 * Token changer unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestTokenChanger {

  function test_Can_Setup_Token_Changer() {

    // Arange
    uint rate = 20000; // 200%
    uint fee = 100; // 1%
    uint precision = 4; // decimals
    bool pausedState = false;
    bool shouldBurn = true;

    MockToken token1 = new MockToken("Token 1", "LEFT", 8, false);
    MockToken token2 = new MockToken("Token 2", "RIGHT", 8, false);

    // Act
    TokenChanger changer = new TokenChanger(
      token1, token2, rate, fee, precision, pausedState, shouldBurn);

    bool actualPausedState = changer.isPaused();
    uint actualRate = changer.getRate();
    uint actualFee = changer.getFee();
    uint actualPrecision = changer.getPrecision();
    uint expectedPrecision = 10**precision;

    // Assert
    Assert.equal(pausedState, actualPausedState, "Incorrect state");
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
    bool pausedState = false;
    bool shouldBurn = true;

    MockToken token1 = new MockToken("Token 1", "LEFT", 8, false);
    MockToken token2 = new MockToken("Token 2", "RIGHT", 8, false);

    TokenChanger changer = new TokenChanger(
      token1, token2, rate, fee, precision, pausedState, shouldBurn);

    // Act
    uint actualFee = changer.calculateFee(value);
    uint expectedFee = value * fee / 10**precision;

    // Assert 
    Assert.equal(actualFee, expectedFee, "Fee is not calculated correctly");
  }
}
