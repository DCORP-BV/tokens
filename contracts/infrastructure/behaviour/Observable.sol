pragma solidity ^0.4.15;

import "./IObservable.sol";

contract Observable is IObservable {


    /**
     * Observers
     */
    mapping(address => uint) private observers;
    address[] private observerIndex;


    function isObserver(address _account) public constant returns (bool) {
        return observerIndex.length > 0 && _account == observerIndex[observers[_account]];
    }


    function getObserverCount() public constant returns (uint) {
        return observerIndex.length;
    }


    function getObserverAtIndex(uint _index) public constant returns (address) {
        return observerIndex[_index];
    }


    function registerObserver(address _observer) {
        if (!isObserver(_observer)) {
            observers[_observer] = observerIndex.push(_observer) - 1;
        }
    }


    function unregisterObserver(address _observer) {
        if (isObserver(_observer)) {
            uint indexToDelete = observers[_observer];
            observerIndex[indexToDelete] = observerIndex[observerIndex.length - 1];
            observers[_observer] = indexToDelete;
            observerIndex.length--;
        }
    }
}
