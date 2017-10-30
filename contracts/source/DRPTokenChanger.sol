pragma solidity ^0.4.15;

import "./token/changer/TokenChanger.sol";
import "./token/observer/TokenObserver.sol";
import "./token/retriever/TokenRetriever.sol";
import "../infrastructure/ownership/TransferableOwnership.sol";

/**
 * @title DRP Token Changer
 *
 * This contract of this VC platform token changer will allow anyone with a current balance of DRP, 
 * to deposit it and in return receive DRPU, or DRPS.
 *
 * DRPU as indicated by its ‘U’ designation is Dcorp’s utility token for those who are under strict 
 * compliance within their country of residence, and does not entitle holders to profit sharing.
 *
 * DRPS as indicated by its ‘S’ designation, maintaining the primary security functions of the DRP token 
 * as outlined within the Dcorp whitepaper. Those who bear DRPS will be entitled to profit sharing in the 
 * form of dividends as per a voting process, and is considered the "Security" token of Dcorp.
 *
 * https://www.dcorp.it/tokenchanger
 *
 * #created 06/10/2017
 * #author Frank Bonnet
 */
contract DRPTokenChanger is TokenChanger, TokenObserver, TransferableOwnership, TokenRetriever {


    /**
     * Construct drps - drpu token changer
     *
     * @param _drps Ref to the DRPS token smart-contract https://www.dcorp.it/drps
     * @param _drpu Ref to the DRPU token smart-contract https://www.dcorp.it/drpu
     */
    function DRPTokenChanger(address _drps, address _drpu) 
        TokenChanger(_drps, _drpu, 20000, 100, 4, false, true) {}


    /**
     * Pause the token changer making the contract 
     * revert the transaction instead of converting 
     */
    function pause() public only_owner {
        super.pause();
    }


    /**
     * Resume the token changer making the contract 
     * convert tokens instead of reverting the transaction 
     */
    function resume() public only_owner {
        super.resume();
    }


    /**
     * Event handler that initializes the token conversion
     * 
     * Called by `_token` when a token amount is received on 
     * the address of this token changer
     *
     * @param _token The token contract that received the transaction
     * @param _from The account or contract that send the transaction
     * @param _value The value of tokens that where received
     */
    function onTokensReceived(address _token, address _from, uint _value) internal is_token(_token) {
        require(_token == msg.sender);

        // Convert tokens
        convert(_token, _from, _value);
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve tokens from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public only_owner {
        super.retrieveTokens(_tokenContract);
    }


    /**
     * Prevents the accidental sending of ether
     */
    function () payable {
        revert();
    }
}