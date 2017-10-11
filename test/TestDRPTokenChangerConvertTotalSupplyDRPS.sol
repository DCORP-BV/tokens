pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../contracts/source/DRPSToken.sol";
import "../contracts/source/DRPUToken.sol";
import "../contracts/source/DRPTokenChanger.sol";

/**
 * DRP Token changer convert DRPS to DRPS unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPTokenChangerConvertTotalSupplyDRPS {

  function test_Total_Supply_Updates_When_Converting_DRPS_To_DRPU() {

    // Arrange
    address account = this;
    uint value = 3500;
    uint rate = 20000;
    uint fee = 100;
    uint precision = 10**4;

    DRPSToken drpsToken = new DRPSToken();
    DRPUToken drpuToken = new DRPUToken();
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    drpsToken.addOwner(changer);
    drpuToken.addOwner(changer);
    drpsToken.registerObserver(changer);

    drpsToken.issue(account, value);
    uint drpsTotalSupplyBefore = drpsToken.totalSupply();
    uint drpuTotalSupplyBefore = drpuToken.totalSupply();

    // Act
    drpsToken.transfer(changer, value);

    uint drpsTotalSupplyAfter = drpsToken.totalSupply();
    uint drpuTotalSupplyAfter = drpuToken.totalSupply();
    uint expectedAfterConversion = value * rate / precision;
    uint expectedSupply = expectedAfterConversion - (expectedAfterConversion * fee / precision);

    // Assert
    Assert.equal(drpsTotalSupplyBefore, value, "Incorrect initial DRPS total supply");
    Assert.equal(drpuTotalSupplyBefore, 0, "DRPU total supply should be zero initially");
    Assert.equal(drpsTotalSupplyAfter, 0, "DRPS total supply should be zero after converting");
    Assert.equal(expectedSupply, drpuTotalSupplyAfter, "Actual DRPU total supply does not match the expected DRPU total supply after converting");
  }
}
