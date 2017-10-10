pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../contracts/source/DRPSToken.sol";
import "../contracts/source/DRPUToken.sol";
import "../contracts/source/DRPTokenChanger.sol";

/**
 * DRP Token changer convert DRPS to DRPU unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPTokenChangerConvertDRPS {
  
  function test_Can_Convert_DRPS_To_DRPU() {

    // Arange
    address account = this;
    uint value = 3500;
    uint rate = 20000;
    uint fee = 100;
    uint precision = 10**4;

    DRPSToken drpsToken = new DRPSToken();
    DRPUToken drpuToken = new DRPUToken();
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    drpuToken.addOwner(changer);
    drpsToken.addOwner(changer);
    drpsToken.registerObserver(changer);

    drpsToken.issue(account, value);
    uint drpsBalanceBefore = drpsToken.balanceOf(account);
    uint drpuBalanceBefore = drpuToken.balanceOf(account);

    // Act
    drpsToken.transfer(changer, value);

    uint drpsBalanceAfter = drpsToken.balanceOf(account);
    uint drpuBalanceAfter = drpuToken.balanceOf(account);
    uint expectedAfterConversion = value * rate / precision;
    uint expectedBalance = expectedAfterConversion - (expectedAfterConversion * fee / precision);

    // Assert
    Assert.equal(drpsBalanceBefore, value, "Incorrect initial DRPS balance");
    Assert.equal(drpuBalanceBefore, 0, "DRPU balance should be zero initially");
    Assert.equal(drpsBalanceAfter, 0, "DRPS balance should be zero after converting");
    Assert.equal(expectedBalance, drpuBalanceAfter, "Actual DRPU balance does not match the expected DRPU balance after converting");
  }
}
