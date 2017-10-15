pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../contracts/test/mock/MockToken.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/source/DRPSToken.sol";
import "../contracts/source/DRPSTokenConverter.sol";
import "../contracts/infrastructure/authentication/whitelist/Whitelist.sol";

/**
 * DRPS Token converter unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestDRPSTokenConverterAuthenticationManager {

  CallProxyFactory private callProxyFactory;

  function TestDRPSTokenConverterAuthenticationManager() {
    callProxyFactory = new CallProxyFactory();
  }

  function test_Authentication_Is_Enabled_Initially() {

    // Arrange
    DRPSTokenConverter converter = new DRPSTokenConverter(address(0), address(0), address(0));

    // Act
    bool isAuthenticating = converter.isAuthenticating();

    // Assert
    Assert.isTrue(isAuthenticating, "Should be authentication initially");
  }

  function test_Can_Disable_Authentication() {

    // Arrange
    DRPSTokenConverter converter = new DRPSTokenConverter(address(0), address(0), address(0));
    bool isAuthenticatingBefore = converter.isAuthenticating();

    // Act
    converter.disableAuthentication();
    bool isAuthenticatingAfter = converter.isAuthenticating();

    // Assert
    Assert.isTrue(isAuthenticatingBefore, "Should be authentication initially");
    Assert.isFalse(isAuthenticatingAfter, "Should not be authentication after calling disableAuthentication()");
  }

  function test_Can_Enable_Authentication() {

    // Arrange
    DRPSTokenConverter converter = new DRPSTokenConverter(address(0), address(0), address(0));
    converter.disableAuthentication();

    bool isAuthenticatingBefore = converter.isAuthenticating();

    // Act
    converter.enableAuthentication();
    bool isAuthenticatingAfter = converter.isAuthenticating();

    // Assert
    Assert.isFalse(isAuthenticatingBefore, "Should not be authentication initially");
    Assert.isTrue(isAuthenticatingAfter, "Should be authentication after calling enableAuthentication()");
  }

  function test_Non_Owner_Cannot_Disable_Authentication() {

    // Arrange
    DRPSTokenConverter converter = new DRPSTokenConverter(address(0), address(0), address(0));
    CallProxy proxy = CallProxy(callProxyFactory.create(converter));
    bool isAuthenticatingBefore = converter.isAuthenticating();

    // Act
    DRPSTokenConverter(proxy).disableAuthentication();  // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool isAuthenticatingAfter = converter.isAuthenticating();

    // Assert
    Assert.isTrue(isAuthenticatingBefore, "Should be authentication initially");
    Assert.isTrue(isAuthenticatingAfter, "Should still be authentication after calling disableAuthentication()");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Non_Owner_Cannot_Enable_Authentication() {

    // Arrange
    DRPSTokenConverter converter = new DRPSTokenConverter(address(0), address(0), address(0));
    CallProxy proxy = CallProxy(callProxyFactory.create(converter));
    converter.disableAuthentication();

    bool isAuthenticatingBefore = converter.isAuthenticating();

    // Act
    DRPSTokenConverter(proxy).enableAuthentication();
    bool hasThrown = proxy.throws();
    bool isAuthenticatingAfter = converter.isAuthenticating();

    // Assert
    Assert.isFalse(isAuthenticatingBefore, "Should not be authentication initially");
    Assert.isFalse(isAuthenticatingAfter, "Should still not be authentication after calling enableAuthentication()");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
