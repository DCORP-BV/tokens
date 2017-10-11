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
     * Returns true if '_token' is on of the tokens that are 
     * managed by this token changer
     * 
     * @param _token The address being tested
     * @return Wheter the '_token' is part of this token changer
     */
    function isToken(address _token) constant returns (bool);


    /**
     * Returns the address of the left token
     *
     * @return Left token address
     */
    function getLeftToken() constant returns (address);


    /**
     * Returns the address of the right token
     *
     * @return Right token address
     */
    function getRightToken() constant returns (address);


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