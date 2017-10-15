pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../contracts/source/DRPSToken.sol";
import "../contracts/source/DRPUToken.sol";
import "../contracts/source/DRPTokenChanger.sol";

/**
 * DRP Token changer convert DRPU to DRPS unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPTokenChangerConvertDRPU {

  function test_Can_Convert_DRPU_To_DRPS() {

    // Arange
    address account = this;
    uint value = 3600;
    uint rate = 20000;
    uint fee = 100;
    uint precision = 10**4;

    DRPSToken drpsToken = new DRPSToken();
    DRPUToken drpuToken = new DRPUToken();
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    drpsToken.addOwner(changer);
    drpuToken.addOwner(changer);
    drpuToken.registerObserver(changer);

    drpuToken.issue(account, value);
    uint drpsBalanceBefore = drpsToken.balanceOf(account);
    uint drpuBalanceBefore = drpuToken.balanceOf(account);

    // Act
    drpuToken.transfer(changer, value);

    uint drpsBalanceAfter = drpsToken.balanceOf(account);
    uint drpuBalanceAfter = drpuToken.balanceOf(account);
    uint expectedAfterConversion = value * precision / rate;
    uint expectedBalance = expectedAfterConversion - (expectedAfterConversion * fee / precision);

    // Assert
    Assert.equal(drpuBalanceBefore, value, "Incorrect initial DRPU balance");
    Assert.equal(drpsBalanceBefore, 0, "DRPS balance should be zero initially");
    Assert.equal(drpuBalanceAfter, 0, "DRPU balance should be zero after converting");
    Assert.equal(expectedBalance, drpsBalanceAfter, "Actual DRPS balance does not match the expected DRPS balance after converting");
  }
}
