pragma solidity ^0.4.15;

import "./token/IToken.sol";
import "./token/ManagedToken.sol";
import "./token/observer/ITokenObserver.sol";
import "./token/retreiver/ITokenRetreiver.sol";
import "../infrastructure/behaviour/Observable.sol";

/**
 * @title DRP Utility token (DRPU)
 *
 * DRPU as indicated by its ‘U’ designation is Dcorp’s utility token for those who are under strict 
 * compliance within their country of residence, and does not entitle holders to profit sharing.
 *
 * https://www.dcorp.it/drpu
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract DRPUToken is ManagedToken, Observable, ITokenRetreiver {


    /**
     * Construct the managed utility token
     */
    function DRPUToken() ManagedToken("DRP Utility", "DRPU", false) {}


    function registerObserver(address _observer) only_owner {
        super.registerObserver(_observer);
    }


    function unregisterObserver(address _observer) only_owner {
        super.unregisterObserver(_observer);
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
            tokenInstance.transfer(owner, tokenBalance);
        }
    }


    /**
     * Prevents the accidental sending of ether
     */
    function () payable {
        revert();
    }
}
