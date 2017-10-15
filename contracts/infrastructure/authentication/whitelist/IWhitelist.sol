pragma solidity ^0.4.15;

import "../IAuthenticator.sol";


/**
 * @title IWhitelist 
 *
 * Whitelist authentication interface
 *
 * #created 04/10/2017
 * #author Frank Bonnet
 */
contract IWhitelist is IAuthenticator {
    

    /**
     * Returns wheter an entry exists for `_account`
     *
     * @param _account The account to check
     * @return wheter `_account` is has an entry in the whitelist
     */
    function hasEntry(address _account) constant returns (bool);


    /**
     * Add `_account` to the whitelist
     *
     * If an account is currently disabled, the account is reenabled. Otherwise 
     * a new entry is created
     *
     * @param _account The account to add
     */
    function add(address _account);


    /**
     * Remove `_account` from the whitelist
     *
     * Will not acctually remove the entry but disable it by updating
     * the accepted record
     *
     * @param _account The account to remove
     */
    function remove(address _account);
}