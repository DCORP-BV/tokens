pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/mock/MockToken.sol";
import "../contracts/source/DRPUToken.sol";
import "../contracts/source/DRPUTokenConverter.sol";
import "../contracts/infrastructure/authentication/whitelist/Whitelist.sol";

/**
 * DRPU Token converter unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPUTokenConverterNotApproved {

  function test_Cannot_Convert_DRP_To_DRPU_When_Not_Approved() {

    // Arrange
    address account = this;
    uint value = 3600;

    DRPUToken drpuToken = new DRPUToken();
    MockToken drpToken = new MockToken("DCORP", "DRP", 2, false);
    Whitelist whitelist = Whitelist(DeployedAddresses.Whitelist());

    DRPUTokenConverter converter = new DRPUTokenConverter(whitelist, drpToken, drpuToken);
    converter.disableAuthentication(); // Prevent out of gas by not deploying a new whitelist buy disabeling authentication for the test instead

    drpuToken.addOwner(converter);
    drpToken.issue(account, value);

    uint drpBalanceBefore = drpToken.balanceOf(account);
    uint drpuBalanceBefore = drpuToken.balanceOf(account);

    // Act
    bool hasThrown = !converter.call(bytes4(bytes32(sha3("requestConversion(uint256)"))), value);

    uint drpBalanceAfter = drpToken.balanceOf(account);
    uint drpuBalanceAfter = drpuToken.balanceOf(account);

    // Assert
    Assert.equal(drpBalanceBefore, drpBalanceAfter, "DRP balance should not have changed");
    Assert.equal(drpuBalanceBefore, drpuBalanceAfter, "DRPU balance should not have changed");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
