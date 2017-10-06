pragma solidity ^0.4.15;

import "./token/changer/TokenChanger.sol";
import "./token/observer/TokenObserver.sol";
import "./token/retreiver/ITokenRetreiver.sol";
import "../infrastructure/behaviour/IObservable.sol";
import "../infrastructure/ownership/TransferableOwnership.sol";

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
contract DRPTokenChanger is TokenChanger, TokenObserver, TransferableOwnership, ITokenRetreiver {


    function DRPTokenChanger(address _drps, address _drpu) TokenChanger(_drps, _drpu, 20000, 100, 4) {
        IObservable(_drps).registerObserver(this);
        IObservable(_drpu).registerObserver(this);
    }


    function setFee(uint _fee) public only_owner {
        fee = _fee;
    }


    function setRate(uint _rate) public only_owner {
        rate = _rate;
    }


    function setPrecision(uint _precision) public only_owner {
        precision = _precision;
    }


    function onTokensReceived(address _token, address _sender, uint _value) internal {
        require(_token == msg.sender);
        require(_token == address(token1) || _token == address(token2));

        // Swap tokens
        swap(_token, _sender, _value);
    }
}