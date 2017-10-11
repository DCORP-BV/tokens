pragma solidity ^0.4.15;

import "./token/changer/TokenChanger.sol";
import "./token/retreiver/ITokenRetreiver.sol";
import "../infrastructure/ownership/TransferableOwnership.sol";

/**
 * @title DRPU Converter
 *
 * ...
 *
 * DRPU as indicated by its ‘U’ designation is Dcorp’s utility token for those who are under strict 
 * compliance within their country of residence, and does not entitle holders to profit sharing.
 *
 * https://www.dcorp.it/drpu
 *
 * #created 11/10/2017
 * #author Frank Bonnet
 */
contract DRPUTokenConverter is TokenChanger, TransferableOwnership, ITokenRetreiver {


    /**
     * Construct drp - drpu token changer
     *
     * @param _drp Ref to the (old) DRP token smart-contract
     * @param _drpu Ref to the DRPU token smart-contract https://www.dcorp.it/drpu
     */
    function DRPUTokenConverter(address _drp, address _drpu) 
        TokenChanger(_drp, _drpu, 2, 0, 0, false, false) {}


    /**
     * Request that the (old) drp smart-contract transfers `_value` worth 
     * of (old) drp to the drpu token converter to be converted
     * 
     * Note! This function requires the drpu token converter smart-contract 
     * to be approved to spend at least `_value` worth of (old) drp by the 
     * owner of the tokens by calling the approve() function in the (old) 
     * dpr token smart-contract
     *
     * @param _value The amount of tokens to transfer and convert
     */
    function transfer(uint _value) public {
        require(_value > 0);
        address sender = msg.sender;

        // Transfer old drp from sender to converter
        token1.transferFrom(sender, this, _value);

        // Convert tokens
        convert(token1, sender, _value);
    }


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