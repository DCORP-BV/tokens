pragma solidity ^0.4.15;

/**
 * @title Pausable interface
 *
 * Simple interface to pause and resume 
 *
 * #created 11/10/2017
 * #author Frank Bonnet
 */
contract IPausable {


    /**
     * Returns whether the implementing contract is 
     * currently paused or not
     *
     * @return Whether the paused state is active
     */
    function isPaused() constant returns (bool);


    /**
     * Change the state to paused
     */
    function pause();


    /**
     * Change the state to resume, undo the effects 
     * of calling pause
     */
    function resume();
}