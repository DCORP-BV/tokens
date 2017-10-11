pragma solidity ^0.4.15;

import "./token/IToken.sol";
import "./token/ManagedToken.sol";
import "./token/observer/ITokenObserver.sol";
import "./token/retreiver/ITokenRetreiver.sol";
import "../infrastructure/behaviour/Observable.sol";

/**
 * @title DRP Security token (DRPS)
 *
 * DRPS as indicated by its ‘S’ designation, maintaining the primary security functions of the DRP token as 
 * outlined within the Dcorp whitepaper (https://www.dcorp.it/whitepaper).  
 *
 * Those who bear DRPS will be entitled to profit sharing in the form of dividends as per a voting process, 
 * and is considered the "Security" token of Dcorp.
 *
 * https://www.dcorp.it/drps
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract DRPSToken is ManagedToken, Observable, ITokenRetreiver {

    
    /**
     * Construct the managed security token
     */
    function DRPSToken() ManagedToken("DRP Security", "DRPS", 8, false) {}


    /**
     * Returns whether sender is allowed to register `_observer`
     *
     * @param _observer The address to register as an observer
     * @return Whether the sender is allowed or not
     */
    function canRegisterObserver(address _observer) internal constant returns (bool) {
        return _observer != address(this) && isOwner(msg.sender);
    }


    /**
     * Returns whether sender is allowed to unregister `_observer`
     *
     * @param _observer The address to unregister as an observer
     * @return Whether the sender is allowed or not
     */
    function canUnregisterObserver(address _observer) internal constant returns (bool) {
        return msg.sender == _observer || isOwner(msg.sender);
    }


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * - Notifies registered observers when the observer receives tokens
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) public returns (bool) {
        bool result = super.transfer(_to, _value);
        if (isObserver(_to)) {
            ITokenObserver(_to).notifyTokensReceived(msg.sender, _value);
        }

        return result;
    }


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * - Notifies registered observers when the observer receives tokens
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        bool result = super.transferFrom(_from, _to, _value);
        if (isObserver(_to)) {
            ITokenObserver(_to).notifyTokensReceived(_from, _value);
        }

        return result;
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retreive tokens from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retreiveTokens(address _tokenContract) public only_owner {
        IToken tokenInstance = IToken(_tokenContract);
        uint tokenBalance = tokenInstance.balanceOf(this);
        if (tokenBalance > 0) {
            tokenInstance.transfer(msg.sender, tokenBalance);
        }
    }


    /**
     * Prevents the accidental sending of ether
     */
    function () payable {
        revert();
    }
}
