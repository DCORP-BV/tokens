pragma solidity ^0.4.15;

/**
 * @title Transferable ownership interface
 *
 * Enhances ownership by allowing the current owner to 
 * transfer ownership to a new owner
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract ITransferableOwnership {
    

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner);
}
