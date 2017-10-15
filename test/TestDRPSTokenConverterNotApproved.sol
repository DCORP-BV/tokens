pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/mock/MockToken.sol";
import "../contracts/source/DRPSToken.sol";
import "../contracts/source/DRPSTokenConverter.sol";
import "../contracts/infrastructure/authentication/whitelist/Whitelist.sol";

/**
 * DRPS Token converter unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPSTokenConverterNotApproved {

  function test_Cannot_Convert_DRP_To_DRPS_When_Not_Approved() {

    // Arrange
    address account = this;
    uint value = 3600;

    DRPSToken drpsToken = new DRPSToken();
    MockToken drpToken = new MockToken("DCORP", "DRP", 2, false);
    Whitelist whitelist = Whitelist(DeployedAddresses.Whitelist());

    DRPSTokenConverter converter = new DRPSTokenConverter(whitelist, drpToken, drpsToken);
    converter.disableAuthentication(); // Prevent out of gas by not deploying a new whitelist buy disabeling authentication for the test instead

    drpsToken.addOwner(converter);
    drpToken.issue(account, value);

    uint drpBalanceBefore = drpToken.balanceOf(account);
    uint drpsBalanceBefore = drpsToken.balanceOf(account);

    // Act
    bool hasThrown = !converter.call(bytes4(bytes32(sha3("requestConversion(uint256)"))), value);

    uint drpBalanceAfter = drpToken.balanceOf(account);
    uint drpsBalanceAfter = drpsToken.balanceOf(account);

    // Assert
    Assert.equal(drpBalanceBefore, drpBalanceAfter, "DRP balance should not have changed");
    Assert.equal(drpsBalanceBefore, drpsBalanceAfter, "DRPS balance should not have changed");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
