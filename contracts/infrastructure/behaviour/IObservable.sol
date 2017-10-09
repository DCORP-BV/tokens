pragma solidity ^0.4.15;

/**
 * @title Observable interface
 *
 * Allows observers to register and unregister with the the 
 * implementing smart-contract that is observable
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract IObservable {


    /**
     * Returns true if `_account` is a registered observer
     * 
     * @param _account The account to test against
     * @return Whether the account is a registered observer
     */
    function isObserver(address _account) constant returns (bool);


    /**
     * Gets the amount of registered observers
     * 
     * @return The amount of registered observers
     */
    function getObserverCount() constant returns (uint);


    /**
     * Gets the observer at `_index`
     * 
     * @param _index The index of the observer
     * @return The observers address
     */
    function getObserverAtIndex(uint _index) constant returns (address);


    /**
     * Register `_observer` as an observer
     * 
     * @param _observer The account to add as an observer
     */
    function registerObserver(address _observer);


    /**
     * Unregister `_observer` as an observer
     * 
     * @param _observer The account to remove as an observer
     */
    function unregisterObserver(address _observer);
}
