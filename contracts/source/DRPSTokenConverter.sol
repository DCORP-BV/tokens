pragma solidity ^0.4.15;

import "./token/changer/TokenChanger.sol";
import "./token/retriever/ITokenRetriever.sol";
import "../infrastructure/authentication/AuthenticationManager.sol";
import "../infrastructure/authentication/whitelist/IWhitelist.sol";
import "../infrastructure/ownership/TransferableOwnership.sol";

/**
 * @title DRPS Converter
 *
 * ...
 *
 * DRPS as indicated by its ‘S’ designation, maintaining the primary security functions of the DRP token as 
 * outlined within the Dcorp whitepaper (https://www.dcorp.it/whitepaper).  
 *
 * Those who bear DRPS will be entitled to profit sharing in the form of dividends as per a voting process, 
 * and is considered the "Security" token of Dcorp.
 *
 * https://www.dcorp.it/drps
 *
 * #created 11/10/2017
 * #author Frank Bonnet
 */
contract DRPSTokenConverter is TokenChanger, AuthenticationManager, TransferableOwnership, ITokenRetriever {

    // Authentication
    IWhitelist private whitelist;


    /**
     * Construct drp - drps token changer
     *
     * Rate is multiplied by 10**6 taking into account the difference in 
     * decimals between (old) DRP (2) and DRPU (8)
     *
     * @param _whitelist The address of the whitelist authenticator
     * @param _drp Ref to the (old) DRP token smart-contract
     * @param _drps Ref to the DRPS token smart-contract https://www.dcorp.it/drps
     */
    function DRPSTokenConverter(address _whitelist, address _drp, address _drps) 
        TokenChanger(_drp, _drps, 1 * 10**6, 0, 0, false, false) AuthenticationManager(true) {
        whitelist = IWhitelist(_whitelist);
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
     * Enable authentication
     */
    function enableAuthentication() public only_owner {
        super.enableAuthentication();
    }


    /**
     * Disable authentication
     */
    function disableAuthentication() public only_owner {
        super.disableAuthentication();
    }


    /**
     * Request that the (old) drp smart-contract transfers `_value` worth 
     * of (old) drp to the drps token converter to be converted
     * 
     * Note! This function requires the drps token converter smart-contract 
     * to be approved to spend at least `_value` worth of (old) drp by the 
     * owner of the tokens by calling the approve() function in the (old) 
     * dpr token smart-contract
     *
     * @param _value The amount of tokens to transfer and convert
     */
    function requestConversion(uint _value) public {
        require(_value > 0);
        address sender = msg.sender;

        // Authenticate
        require(!isAuthenticating() || whitelist.authenticate(sender));

        IToken drpToken = IToken(getLeftToken());
        drpToken.transferFrom(sender, this, _value); // Transfer old drp from sender to converter 
        convert(drpToken, sender, _value); // Convert to drps
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
        require(getLeftToken() != _tokenContract); // Ensure that the (old) drp token stays locked

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