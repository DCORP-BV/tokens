pragma solidity ^0.4.15;


contract ITokenObserver {

    function notifyTokensReceived(address _from, uint _value);
}
