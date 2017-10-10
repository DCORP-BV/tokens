pragma solidity ^0.4.15;

/**
 * @title Token Changer interface
 *
 * Basic token changer public interface 
 *
 * #created 06/10/2017
 * #author Frank Bonnet
 */
contract ITokenChanger {


    /**
     * Returns whether the token changer is currently 
     * paused or not. While being in the paused state 
     * the contract should revert the transaction instead 
     * of converting tokens
     *
     * @return Whether the token changer is in the paused state
     */
    function isPaused() constant returns (bool);


    /**
     * Returns the fee that is paid in tokens when using 
     * the token changer
     *
     * @return The percentage of tokens that is charged
     */
    function getFee() constant returns (uint);

    
    /**
     * Returns the rate that is used to change between tokens
     *
     * @return The rate used when changing tokens
     */
    function getRate() constant returns (uint);


    /**
     * Returns the precision of the rate and fee params
     *
     * @return The amount of decimals used
     */
    function getPrecision() constant returns (uint);


    /**
     * Calculates and returns the fee based on `_value` of tokens
     *
     * @return The actual fee
     */
    function calculateFee(uint _value) constant returns (uint);
}