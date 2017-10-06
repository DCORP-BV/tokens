pragma solidity ^0.4.15;

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
contract ITokenChanger {

    function getFee() constant returns (uint);

    function getRate() constant returns (uint);

    function getPrecision() constant returns (uint);

    function calculateFee(uint _value) constant returns (uint);
}