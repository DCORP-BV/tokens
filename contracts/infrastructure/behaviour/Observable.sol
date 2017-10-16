pragma solidity ^0.4.15;

import "./IObservable.sol";

/**
 * @title Abstract Observable
 *
 * Allows observers to register and unregister with the the 
 * implementing smart-contract that is observable
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract Observable is IObservable {


    // Observers
    mapping(address => uint) private observers;
    address[] private observerIndex;


    /**
     * Returns true if `_account` is a registered observer
     * 
     * @param _account The account to test against
     * @return Whether the account is a registered observer
     */
    function isObserver(address _account) public constant returns (bool) {
        return observerIndex.length > 0 && _account == observerIndex[observers[_account]];
    }


    /**
     * Gets the amount of registered observers
     * 
     * @return The amount of registered observers
     */
    function getObserverCount() public constant returns (uint) {
        return observerIndex.length;
    }


    /**
     * Gets the observer at `_index`
     * 
     * @param _index The index of the observer
     * @return The observers address
     */
    function getObserverAtIndex(uint _index) public constant returns (address) {
        return observerIndex[_index];
    }


    /**
     * Register `_observer` as an observer
     * 
     * @param _observer The account to add as an observer
     */
    function registerObserver(address _observer) public {
        require(canRegisterObserver(_observer));
        if (!isObserver(_observer)) {
            observers[_observer] = observerIndex.push(_observer) - 1;
        }
    }


    /**
     * Unregister `_observer` as an observer
     * 
     * @param _observer The account to remove as an observer
     */
    function unregisterObserver(address _observer) public {
        require(canUnregisterObserver(_observer));
        if (isObserver(_observer)) {
            uint indexToDelete = observers[_observer];
            address keyToMove = observerIndex[observerIndex.length - 1];
            observerIndex[indexToDelete] = keyToMove;
            observers[keyToMove] = indexToDelete;
            observerIndex.length--;
        }
    }


    /**
     * Returns whether it is allowed to register `_observer` by calling 
     * canRegisterObserver() in the implementing smart-contract
     *
     * @param _observer The address to register as an observer
     * @return Whether the sender is allowed or not
     */
    function canRegisterObserver(address _observer) internal constant returns (bool);


    /**
     * Returns whether it is allowed to unregister `_observer` by calling 
     * canRegisterObserver() in the implementing smart-contract
     *
     * @param _observer The address to unregister as an observer
     * @return Whether the sender is allowed or not
     */
    function canUnregisterObserver(address _observer) internal constant returns (bool);
}
