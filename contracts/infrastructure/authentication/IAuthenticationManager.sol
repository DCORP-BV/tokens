pragma solidity ^0.4.15;


/**
 * @title IAuthenticationManager 
 *
 * Allows the authentication process to be enabled and disabled
 *
 * #created 15/10/2017
 * #author Frank Bonnet
 */
contract IAuthenticationManager {
    

    /**
     * Returns true if authentication is enabled and false 
     * otherwise
     *
     * @return Whether the converter is currently authenticating or not
     */
    function isAuthenticating() constant returns (bool);


    /**
     * Enable authentication
     */
    function enableAuthentication();


    /**
     * Disable authentication
     */
    function disableAuthentication();
}