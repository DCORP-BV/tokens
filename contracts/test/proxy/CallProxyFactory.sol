pragma solidity ^0.4.15;

import "./CallProxy.sol";

/**
 * CallProxy creation
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */  
contract CallProxyFactory {

    /**
     * Create a CallProxy instance
     */
    function create(address _target) returns (address) {
        return new CallProxy(_target);
    }
}