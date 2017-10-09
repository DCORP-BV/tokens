pragma solidity ^0.4.15;

import "./IOwnership.sol";
import "../modifier/Owned.sol";

/**
 * @title Ownership
 *
 * Perminent ownership
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract Ownership is IOwnership, Owned {


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public constant returns (bool) {
        return _account == owner;
    }


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() public constant returns (address) {
        return owner;
    }
}
