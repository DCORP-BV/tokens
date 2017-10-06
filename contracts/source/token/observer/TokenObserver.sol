pragma solidity ^0.4.15;

import "./ITokenObserver.sol";

contract TokenObserver is ITokenObserver {

    function notifyTokensReceived(address _sender, uint _amount) public {
        onTokensReceived(msg.sender, _sender, _amount);
    }

    function onTokensReceived(address _token, address _sender, uint _amount) internal;
}
