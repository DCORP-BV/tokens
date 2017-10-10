pragma solidity ^0.4.15;

import "./token/changer/TokenChanger.sol";
import "./token/observer/TokenObserver.sol";
import "./token/retreiver/ITokenRetreiver.sol";
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
contract DRPTokenChanger is TokenChanger, TokenObserver, TransferableOwnership, ITokenRetreiver {


    /**
     * Construct drps - drpu token changer
     *
     * @param _drps Ref to the DRPS token smart-contract https://www.dcorp.it/drps
     * @param _drpu Ref to the DRPU token smart-contract https://www.dcorp.it/drpu
     */
    function DRPTokenChanger(address _drps, address _drpu) TokenChanger(_drps, _drpu, 20000, 100, 4) {}


    /**
     * Allow the owner of the token changer to modify the 
     * fee that is paid in tokens when using the token changer
     *
     * @param _fee The percentage of tokens that is charged
     */
    function setFee(uint _fee) public only_owner {
        fee = _fee;
    }


    /**
     * Allow the owner of the token changer to modify the 
     * rate that is used to change between DRPU and DRPS
     *
     * @param _rate The rate used when changing tokens
     */
    function setRate(uint _rate) public only_owner {
        rate = _rate;
    }


    /**
     * Allow the owner of the token changer to modify the 
     * precision of the rate and fee params
     *
     * @param _decimals The amount of decimals used
     */
    function setPrecision(uint _decimals) public only_owner {
        precision = 10**_decimals;
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
    function onTokensReceived(address _token, address _from, uint _value) internal {
        require(_token == msg.sender);
        require(_token == address(token1) || _token == address(token2));

        // Convert tokens
        convert(_token, _from, _value);
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