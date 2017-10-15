pragma solidity ^0.4.15;

import "./IAuthenticationManager.sol";


/**
 * @title AuthenticationManager 
 *
 * Allows the authentication process to be enabled and disabled
 *
 * #created 15/10/2017
 * #author Frank Bonnet
 */
contract AuthenticationManager is IAuthenticationManager {
    
    // Switch
    bool private requiresAuthentication;


    /**
     * Construct authentication manager
     *
     * @param _requiresAuthentication Whether to start in the enabled phase or not
     */
    function AuthenticationManager(bool _requiresAuthentication) {
        requiresAuthentication = _requiresAuthentication;
    }


    /**
     * Returns true if authentication is enabled and false 
     * otherwise
     *
     * @return Whether the converter is currently authenticating or not
     */
    function isAuthenticating() public constant returns (bool) {
        return requiresAuthentication;
    }


    /**
     * Enable authentication
     */
    function enableAuthentication() public {
        requiresAuthentication = true;
    }


    /**
     * Disable authentication
     */
    function disableAuthentication() public {
        requiresAuthentication = false;
    }
}