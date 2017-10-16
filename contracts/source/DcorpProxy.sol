pragma solidity ^0.4.15;

import "./token/IToken.sol";
import "./token/retriever/ITokenRetriever.sol";
import "../infrastructure/ownership/IMultiOwned.sol";
import "../infrastructure/ownership/TransferableOwnership.sol";

/**
 * @title Dcorp Proxy
 *
 * !!UNTESTED!!
 *
 * #created 16/10/2017
 * #author Frank Bonnet
 */
contract DcorpProxy is TransferableOwnership, ITokenRetriever {

    struct Vote {
        uint datetime;
        IToken token;
        bool support;
        uint index;
    }

    struct Proposal {
        uint createdTimestamp;
        mapping(address => Vote) votes;
        address[] voteIndex;
        uint index;
    }

    // State
    bool private executed;

    // Settings
    uint constant VOTING_DURATION = 7 days;
    uint constant MIN_QUORUM = 5; // 5%

    // Proposals
    mapping(address => Proposal) private proposals;
    address[] private proposalIndex;

    // Tokens
    IToken private drpToken;
    IToken private drpsToken;
    IToken private drpuToken;


    /**
     * Require `_token` to be one of the drp tokens
     *
     * @param _token The address to test against
     */
    modifier only_accepted_token(address _token) {
        require(_token == address(drpToken) || _token == address(drpsToken) || _token == address(drpuToken));
        _;
    }


    /**
     * Require that sender has more than zero tokens
     *
     * @param _token The address to retreive the balance from
     */
    modifier only_token_holder(address _token) {
        require(IToken(_token).balanceOf(msg.sender) > 0);
        _;
    }


    /**
     * Require `_proposedAddress` to have been proposed already
     *
     * @param _proposedAddress Address that needs to be proposed
     */
    modifier only_proposed(address _proposedAddress) {
        require(isProposed(_proposedAddress));
        _;
    }


    /**
     * Require that the voting period for the proposal has
     * not yet ended
     *
     * @param _proposedAddress Address that was proposed
     */
    modifier only_during_voting_period(address _proposedAddress) {
        require(now <= proposals[_proposedAddress].createdTimestamp + VOTING_DURATION);
        _;
    }


    /**
     * Require that the voting period for the proposal has ended
     *
     * @param _proposedAddress Address that was proposed
     */
    modifier only_after_voting_period(address _proposedAddress) {
        require(now > proposals[_proposedAddress].createdTimestamp + VOTING_DURATION);
        _;
    }


    /**
     * Require that the proposal is supported
     *
     * @param _proposedAddress Address that was proposed
     */
    modifier only_when_supported(address _proposedAddress) {
        require(isSupported(_proposedAddress, false));
        _;
    }
    

    /**
     * Construct the proxy
     *
     * @param _drpToken The old DRP token
     * @param _drpsToken The new security token
     * @param _drpuToken The new utility token
     */
    function DcorpProxy(address _drpToken, address _drpsToken, address _drpuToken) {
        drpToken = IToken(_drpToken);
        drpsToken = IToken(_drpsToken);
        drpuToken = IToken(_drpuToken);
        executed = false;
    }


    /**
     * Returns the combined total supply of all drp tokens
     *
     * @return The combined total drp supply
     */
    function getTotalTokenSupply() public constant returns (uint) {
        uint sum = 0; 
        sum += drpToken.totalSupply();
        sum += drpsToken.totalSupply();
        sum += drpuToken.totalSupply();
        return sum;
    }


    /**
     * Returns true if `_proposedAddress` is already proposed
     *
     * @return The address to test against
     */
    function isProposed(address _proposedAddress) public constant returns (bool) {
        return proposalIndex.length > 0 && _proposedAddress == proposalIndex[proposals[_proposedAddress].index];
    }


    /**
     * Returns the how many proposals where made
     *
     * @return The amount of proposals
     */
    function getProposalCount() public constant returns (uint) {
        return proposalIndex.length;
    }


    /**
     * Propose the transfer token ownership and all funds to `_proposedAddress` 
     *
     * @param _proposedAddress The proposed DCORP address 
     */
    function proposeTransfer(address _proposedAddress) public only_owner {
        require(!isProposed(_proposedAddress));

        // Add proposal
        Proposal storage p = proposals[_proposedAddress];
        p.createdTimestamp = now;
        p.index = proposalIndex.push(_proposedAddress) - 1;
    }


    /**
     * Gets the number of votes towards a proposal
     *
     * @param _proposedAddress The proposed DCORP address 
     * @return uint Vote count
     */
    function getVoteCount(address _proposedAddress) public constant returns (uint) {              
        return proposals[_proposedAddress].voteIndex.length;
    }


    /**
     * Returns true if `_account` has voted on a proposal
     *
     * @param _proposedAddress The proposed DCORP address 
     * @param _account The key (address) that maps to the vote
     * @return bool Voted
     */
    function hasVoted(address _proposedAddress, address _account) public constant returns (bool) {
        bool voted = false;
        if (getVoteCount(_proposedAddress) > 0) {
            Proposal storage p = proposals[_proposedAddress];
            voted = p.voteIndex[p.votes[_account].index] == _account;
        }

        return voted;
    }


    /**
     * Allows a token holder to vote on a proposal
     *
     * @param _proposedAddress The proposed DCORP address 
     * @param _token The token used to vote with
     * @param _support True if supported
     */
    function vote(address _proposedAddress, address _token, bool _support) public only_proposed(_proposedAddress) only_accepted_token(_token) only_token_holder(_token) only_during_voting_period(_proposedAddress) {    
        Proposal storage p = proposals[_proposedAddress];
        address account = msg.sender;
        
        if (!hasVoted(_proposedAddress, account)) {
            p.votes[account] = Vote(
                now, IToken(_token), _support, p.voteIndex.push(account) - 1);
        } else {
            Vote storage v = p.votes[account];
            v.support = _support;
            v.datetime = now;
        }
    }


    /**
     * Returns the current voting results for a proposal
     *
     * @param _proposedAddress The proposed DCORP address 
     * @return supported, rejected
     */
    function getVotingResult(address _proposedAddress) public constant returns (uint, uint) {      
        Proposal storage p = proposals[_proposedAddress];    
        uint support = 0;
        uint reject = 0;
    
        for (uint i = 0; i < getVoteCount(_proposedAddress); i++) {
            address account = p.voteIndex[i];
            Vote storage v = p.votes[account];
            uint weight = v.token.balanceOf(account);
            if (v.support) {
                support += weight;
            } else {
                reject += weight;
            }
        }

        return (support, reject);
    }


    /**
     * Returns true if the proposal is supported
     *
     * @param _proposedAddress The proposed DCORP address 
     * @param _strict If set to true the function requires that the voting period is ended
     * @return bool Supported
     */
    function isSupported(address _proposedAddress, bool _strict) public constant returns (bool) {        
        Proposal storage p = proposals[_proposedAddress];
        bool supported = false;

        if (!_strict || now > p.createdTimestamp + VOTING_DURATION) {
            var (support, reject) = getVotingResult(_proposedAddress);
            supported = support > reject;
            if (supported) {
                supported = support + reject >= getTotalTokenSupply() * MIN_QUORUM / 100;
            }
        }
        
        return supported;
    }


    /**
     * Executes the proposal
     *
     * Should only be called after the voting period and 
     * when the proposal is supported
     *
     * @param _proposedAddress The proposed DCORP address 
     * @return bool Success
     */
    function execute(address _proposedAddress) public only_owner only_proposed(_proposedAddress) only_after_voting_period(_proposedAddress) only_when_supported(_proposedAddress) {
        
        // Only once
        require(!executed);
        executed = true;

        // Transfer token ownership to DCORP
        IMultiOwned(drpsToken).addOwner(_proposedAddress);
        IMultiOwned(drpuToken).addOwner(_proposedAddress);

        // Transfer Eth (safe because we don't know how much gas is used counting votes)
        uint balanceBefore = _proposedAddress.balance;
        uint balanceToSend = this.balance;
        _proposedAddress.transfer(balanceToSend);

        // Assert balances
        assert(balanceBefore + balanceToSend == _proposedAddress.balance);
        assert(this.balance == 0);
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
        IToken tokenInstance = IToken(_tokenContract);
        uint tokenBalance = tokenInstance.balanceOf(this);
        if (tokenBalance > 0) {
            tokenInstance.transfer(msg.sender, tokenBalance);
        }
    }


    /**
     * Accept eth
     */
    function () payable {}
}
