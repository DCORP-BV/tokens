pragma solidity ^0.4.15;


contract IObservable {

    function isObserver(address _account) constant returns (bool);

    function getObserverCount() constant returns (uint);

    function getObserverAtIndex(uint _index) constant returns (address);

    function registerObserver(address _observer);

    function unregisterObserver(address _observer);
}
