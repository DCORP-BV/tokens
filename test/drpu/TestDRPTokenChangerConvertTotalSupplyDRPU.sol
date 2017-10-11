pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../../contracts/source/DRPSToken.sol";
import "../../contracts/source/DRPUToken.sol";
import "../../contracts/source/DRPTokenChanger.sol";

/**
 * DRP Token changer convert DRPU to DRPS unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPTokenChangerConvertTotalSupplyDRPU {

  function test_Total_Supply_Updates_When_Converting_DRPU_To_DRPS() {

    // Arange
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
    drpuToken.registerObserver(changer);

    drpuToken.issue(account, value);
    uint drpsTotalSupplyBefore = drpsToken.totalSupply();
    uint drpuTotalSupplyBefore = drpuToken.totalSupply();

    // Act
    drpuToken.transfer(changer, value);

    uint drpsTotalSupplyAfter = drpsToken.totalSupply();
    uint drpuTotalSupplyAfter = drpuToken.totalSupply();
    uint expectedAfterConversion = value * precision / rate;
    uint expectedSupply = expectedAfterConversion - (expectedAfterConversion * fee / precision);

    // Assert
    Assert.equal(drpuTotalSupplyBefore, value, "Incorrect initial DRPU total supply");
    Assert.equal(drpsTotalSupplyBefore, 0, "DRPS total supply should be zero initially");
    Assert.equal(drpuTotalSupplyAfter, 0, "DRPU total supply should be zero after converting");
    Assert.equal(expectedSupply, drpsTotalSupplyAfter, "Actual DRPS total supply does not match the expected DRPS total supply after converting");
  }
}
