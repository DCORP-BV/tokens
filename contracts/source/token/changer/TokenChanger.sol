pragma solidity ^0.4.15;

import "./ITokenChanger.sol";
import "../IManagedToken.sol";

/**
 * @title DRP Token Changer
 *
 * ...
 *
 * https://www.dcorp.it/tokenchanger
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


    function TokenChanger(address _token1, address _token2, uint _rate, uint _fee, uint _precision) {
        token1 = IManagedToken(_token1);
        token2 = IManagedToken(_token2);
        rate = _rate;
        fee = _fee;
        precision = 10**_precision;
    }


    function getFee() public constant returns (uint) {
        return fee;
    }


    function getRate() public constant returns (uint) {
        return rate;
    }


    function getPrecision() public constant returns (uint) {
        return precision;
    }


    function calculateFee(uint _value) public constant returns (uint) {
        return fee == 0 ? _value : _value * fee / precision;
    }


    function swap(address _from, address _sender, uint _value) internal {
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