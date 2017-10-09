pragma solidity ^0.4.15;

import "./ITokenChanger.sol";
import "../IManagedToken.sol";

/**
 * @title Token Changer
 *
 * Provides a generic way to convert between two tokens using a fixed 
 * ratio and an optional fee.
 *
 * #created 06/10/2017
 * #author Frank Bonnet
 */
contract TokenChanger is ITokenChanger {

    IManagedToken internal token1; // token1 = token2 * rate / precision
    IManagedToken internal token2; // token2 = token1 / rate * precision

    uint internal rate; // Ratio between tokens
    uint internal fee; // Percentage lost in transfer
    uint internal precision; // Precision 


    /**
     * Construct token changer
     *
     * @param _token1 Ref to the 'left' token smart-contract
     * @param _token2 Ref to the 'right' token smart-contract
     * @param _rate The rate used when changing tokens
     * @param _fee The percentage of tokens that is charged
     * @param _precision The amount of decimals used for _rate and _fee
     */
    function TokenChanger(address _token1, address _token2, uint _rate, uint _fee, uint _precision) {
        token1 = IManagedToken(_token1);
        token2 = IManagedToken(_token2);
        rate = _rate;
        fee = _fee;
        precision = 10**_precision;
    }


    /**
     * Returns the fee that is paid in tokens when using 
     * the token changer
     *
     * @return The percentage of tokens that is charged
     */
    function getFee() public constant returns (uint) {
        return fee;
    }


    /**
     * Returns the rate that is used to change between tokens
     *
     * @return The rate used when changing tokens
     */
    function getRate() public constant returns (uint) {
        return rate;
    }


    /**
     * Returns the precision of the rate and fee params
     *
     * @return The amount of decimals used
     */
    function getPrecision() public constant returns (uint) {
        return precision;
    }


    /**
     * Calculates and returns the fee based on `_value` of tokens
     *
     * @return The actual fee
     */
    function calculateFee(uint _value) public constant returns (uint) {
        return fee == 0 ? _value : _value * fee / precision;
    }


    /**
     * Converts tokens by burning the tokens received at the token smart-contact 
     * located at `_from` and by issuing tokens at the opposite token smart-contract
     *
     * @param _from The token smart-contract that received the tokens
     * @param _sender The account that send the tokens (token owner)
     * @param _value The amount of tokens that where received
     */
    function convert(address _from, address _sender, uint _value) internal {
        require(_value > 0);

        uint amountToIssue;
        if (_from == address(token1)) {
            amountToIssue = _value * rate / precision;
            token1.burn(this, _value);
            token2.issue(_sender, amountToIssue - calculateFee(amountToIssue));
        }

        else if (_from == address(token2)) {
            amountToIssue = _value / rate * precision;
            token2.burn(this, _value);
            token1.issue(_sender, amountToIssue - calculateFee(amountToIssue));
        }
    }
}