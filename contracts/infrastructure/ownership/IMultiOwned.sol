pragma solidity ^0.4.15;

/**
 * @title Multi-owned interface
 *
 * Interface that allows multiple owners
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract IMultiOwned {

    /**
     * Returns true if `_account` is an owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) constant returns (bool);


    /**
     * Returns the amount of owners
     *
     * @return The amount of owners
     */
    function getOwnerCount() constant returns (uint);


    /**
     * Gets the owner at `_index`
     *
     * @param _index The index of the owner
     * @return The address of the owner found at `_index`
     */
    function getOwnerAt(uint _index) constant returns (address);


     /**
     * Adds `_account` as a new owner
     *
     * @param _account The account to add as an owner
     */
    function addOwner(address _account);


    /**
     * Removes `_account` as an owner
     *
     * @param _account The account to remove as an owner
     */
    function removeOwner(address _account);
}
