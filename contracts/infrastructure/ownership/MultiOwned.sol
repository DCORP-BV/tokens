pragma solidity ^0.4.15;

import "./IMultiOwned.sol";

/**
 * @title Multi-owned
 *
 * Allows multiple owners
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract MultiOwned is IMultiOwned {

    // Owners
    mapping (address => uint) private owners;
    address[] private ownersIndex;


     /**
     * Access is restricted to owners only
     */
    modifier only_owner() {
        require(isOwner(msg.sender));
        _;
    }


    /**
     * The publisher is the initial owner
     */
    function MultiOwned() {
        ownersIndex.push(msg.sender);
        owners[msg.sender] = 0;
    }


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public constant returns (bool) {
        return ownersIndex.length > 0 && _account == ownersIndex[owners[_account]];
    }


    /**
     * Returns the amount of owners
     *
     * @return The amount of owners
     */
    function getOwnerCount() public constant returns (uint) {
        return ownersIndex.length;
    }


    /**
     * Gets the owner at `_index`
     *
     * @param _index The index of the owner
     * @return The address of the owner found at `_index`
     */
    function getOwnerAt(uint _index) public constant returns (address) {
        return ownersIndex[_index];
    }


    /**
     * Adds `_account` as a new owner
     *
     * @param _account The account to add as an owner
     */
    function addOwner(address _account) public only_owner {
        if (!isOwner(_account)) {
            owners[_account] = ownersIndex.push(_account) - 1;
        }
    }


    /**
     * Removes `_account` as an owner
     *
     * @param _account The account to remove as an owner
     */
    function removeOwner(address _account) public only_owner {
        if (isOwner(_account)) {
            uint indexToDelete = owners[_account];
            address keyToMove = ownersIndex[ownersIndex.length - 1];
            ownersIndex[indexToDelete] = keyToMove;
            owners[keyToMove] = indexToDelete; 
            owners[_account] = 0;
            ownersIndex.length--;
        }
    }
}
