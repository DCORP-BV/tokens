pragma solidity ^0.4.15;

/**
 * @title IAuthenticator 
 *
 * Authenticator interface
 *
 * #created 15/10/2017
 * #author Frank Bonnet
 */
contract IAuthenticator {
    

    /**
     * Authenticate 
     *
     * Returns wheter `_account` is authenticated or not
     *
     * @param _account The account to authenticate
     * @return wheter `_account` is successfully authenticated
     */
    function authenticate(address _account) constant returns (bool);
}