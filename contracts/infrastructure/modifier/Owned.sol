pragma solidity ^0.4.15;

/**
 * @title Owned modifier
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract Owned {

    // The address of the account that is the current owner 
    address internal owner;


    /**
     * The publiser is the inital owner
     */
    function Owned() {
        owner = msg.sender;
    }


    /**
     * Access is restricted to the current owner
     */
    modifier only_owner() {
        require(msg.sender == owner);

        _;
    }
}