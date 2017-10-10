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
contract TestDRPTokenChangerConvertPausedDRPS {

  function test_Cannot_Convert_DRPS_To_DRPU_In_Paused_State() {

    // Arange
    address account = this;
    uint value = 3500;

    DRPSToken drpsToken = new DRPSToken();
    DRPUToken drpuToken = new DRPUToken();
    DRPTokenChanger changer = new DRPTokenChanger(drpsToken, drpuToken);

    drpuToken.addOwner(changer);
    drpsToken.addOwner(changer);
    drpsToken.registerObserver(changer);

    drpsToken.issue(account, value);
    uint drpsBalanceBefore = drpsToken.balanceOf(account);
    uint drpuBalanceBefore = drpuToken.balanceOf(account);

    changer.pause();

    // Act
    bool hasThrown = !address(drpsToken).call(bytes4(bytes32(sha3("transfer(address,uint256)"))), address(changer), value);
    uint drpsBalanceAfter = drpsToken.balanceOf(account);
    uint drpuBalanceAfter = drpuToken.balanceOf(account);

    // Assert
    Assert.equal(drpsBalanceBefore, drpsBalanceAfter, "DRPS balance should not have changed");
    Assert.equal(drpuBalanceBefore, drpuBalanceAfter, "DRPU balance should not have changed");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
