pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/Accounts.sol";
import "../contracts/test/proxy/CallProxy.sol";
import "../contracts/test/proxy/CallProxyFactory.sol";
import "../contracts/infrastructure/authentication/whitelist/Whitelist.sol";

/**
 * Whitelist unit tests
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract TestWhitelist {

  Accounts private accounts;
  CallProxyFactory private callProxyFactory;

  function TestWhitelist() {
    accounts = Accounts(DeployedAddresses.Accounts());
    callProxyFactory = new CallProxyFactory();
  }
  
  function test_Can_Add_Account_To_Whitelist() {

    // Arange
    address account = accounts.get(1);
    Whitelist whitelist = new Whitelist();

    bool isAuthenticatedBefore = whitelist.authenticate(account);
    bool hasRecordBefore = whitelist.hasEntry(account);

    // Act
    whitelist.add(account);
    bool isAuthenticatedAfter = whitelist.authenticate(account);
    bool hasRecordAfter = whitelist.hasEntry(account);

    // Assert
    Assert.isFalse(isAuthenticatedBefore, "Account should not be authenticated before adding it to the whitelist");
    Assert.isTrue(isAuthenticatedAfter, "Account should be authenticated after adding it to the whitelist");
    Assert.isFalse(hasRecordBefore, "Account should not be recorded before adding it to the whitelist");
    Assert.isTrue(hasRecordAfter, "Account should be recorded after adding it to the whitelist");
  }

  function test_Can_Remove_Account_From_Whitelist() {

    // Arange
    address account = accounts.get(2);

    Whitelist whitelist = new Whitelist();
    whitelist.add(account);

    bool isAuthenticatedBefore = whitelist.authenticate(account);

    // Act
    whitelist.remove(account);
    bool isAuthenticatedAfter = whitelist.authenticate(account);

    // Assert
    Assert.isTrue(isAuthenticatedBefore, "Account should be authenticated before adding it to the whitelist");
    Assert.isFalse(isAuthenticatedAfter, "Account should not be authenticated after adding it to the whitelist");
  }

  function test_Non_Owner_Cannot_Add_Account_To_Whitelist() {

    // Arange
    address account = accounts.get(3);
    Whitelist whitelist = new Whitelist();
    CallProxy proxy = CallProxy(callProxyFactory.create(whitelist));

    bool isAuthenticatedBefore = whitelist.authenticate(account);
    bool hasRecordBefore = whitelist.hasEntry(account);

    // Act
    Whitelist(proxy).add(account); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool isAuthenticatedAfter = whitelist.authenticate(account);
    bool hasRecordAfter = whitelist.hasEntry(account);

    // Assert
    Assert.isFalse(isAuthenticatedBefore, "Account should not be authenticated before adding it to the whitelist");
    Assert.isFalse(isAuthenticatedAfter, "Account should still not be authenticated after adding it to the whitelist");
    Assert.isFalse(hasRecordBefore, "Account should not be recorded before adding it to the whitelist");
    Assert.isFalse(hasRecordAfter, "Account should still not be recorded after adding it to the whitelist");
    Assert.isTrue(hasThrown, "Should have thrown");
  }

  function test_Non_Owner_Cannot_Remove_Account_From_Whitelist() {

    // Arange
    address account = accounts.get(2);

    Whitelist whitelist = new Whitelist();
    CallProxy proxy = CallProxy(callProxyFactory.create(whitelist));

    whitelist.add(account);
    bool isAuthenticatedBefore = whitelist.authenticate(account);

    // Act
    Whitelist(proxy).remove(account); // msg.sender will be the proxy
    bool hasThrown = proxy.throws();
    bool isAuthenticatedAfter = whitelist.authenticate(account);

    // Assert
    Assert.isTrue(isAuthenticatedBefore, "Account should be authenticated before adding it to the whitelist");
    Assert.isTrue(isAuthenticatedAfter, "Account should still be authenticated after adding it to the whitelist");
    Assert.isTrue(hasThrown, "Should have thrown");
  }
}
