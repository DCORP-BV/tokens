pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../contracts/test/mock/MockToken.sol";
import "../contracts/source/DRPUToken.sol";
import "../contracts/source/DRPUTokenConverter.sol";

/**
 * DRPU Token converter unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPUTokenConverter {

  function test_Can_Convert_DRP_To_DRPU() {

    // Arrange
    address account = this;
    uint value = 3600;
    uint rate = 2 * 10**6; // Diff in decimals

    DRPUToken drpuToken = new DRPUToken();
    MockToken drpToken = new MockToken("DCORP", "DRP", 2, false);

    DRPUTokenConverter converter = new DRPUTokenConverter(drpToken, drpuToken);
    drpuToken.addOwner(converter);

    drpToken.issue(account, value);
    drpToken.approve(converter, value);

    uint drpBalanceBefore = drpToken.balanceOf(account);
    uint drpLockedInConverterBefore = drpToken.balanceOf(converter);

    // Act
    converter.requestConversion(value);

    uint drpBalanceAfter = drpToken.balanceOf(account);
    uint drpLockedInConverterAfter = drpToken.balanceOf(converter);
    uint drpuBalanceAfter = drpuToken.balanceOf(account);
    uint expectedBalance = value * rate;

    // Assert
    Assert.equal(drpBalanceBefore - value, drpBalanceAfter, "DRP balance of sender is incorrect");
    Assert.equal(drpLockedInConverterBefore + value, drpLockedInConverterAfter, "DRP balance of converter is incorrect");
    Assert.equal(drpuBalanceAfter, expectedBalance, "DRPU balance is incorrect after converting");
  }
}
