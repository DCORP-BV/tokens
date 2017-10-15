pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../contracts/test/mock/MockToken.sol";
import "../contracts/source/DRPSToken.sol";
import "../contracts/source/DRPSTokenConverter.sol";

/**
 * DRPS Token converter unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPSTokenConverter {

  function test_Can_Convert_DRP_To_DRPS() {

    // Arrange
    address account = this;
    uint value = 3600;
    uint rate = 1 * 10**6; // Diff in decimals

    DRPSToken drpsToken = new DRPSToken();
    MockToken drpToken = new MockToken("DCORP", "DRP", 2, false);

    DRPSTokenConverter converter = new DRPSTokenConverter(drpToken, drpsToken);
    drpsToken.addOwner(converter);

    drpToken.issue(account, value);
    drpToken.approve(converter, value);

    uint drpBalanceBefore = drpToken.balanceOf(account);
    uint drpLockedInConverterBefore = drpToken.balanceOf(converter);

    // Act
    converter.requestConversion(value);

    uint drpBalanceAfter = drpToken.balanceOf(account);
    uint drpLockedInConverterAfter = drpToken.balanceOf(converter);
    uint drpsBalanceAfter = drpsToken.balanceOf(account);
    uint expectedBalance = value * rate;

    // Assert
    Assert.equal(drpBalanceBefore - value, drpBalanceAfter, "DRP balance of sender is incorrect");
    Assert.equal(drpLockedInConverterBefore + value, drpLockedInConverterAfter, "DRP balance of converter is incorrect");
    Assert.equal(drpsBalanceAfter, expectedBalance, "DRPS balance is incorrect after converting");
  }
}
