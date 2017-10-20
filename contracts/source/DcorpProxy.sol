pragma solidity ^0.4.15;

import "./token/IToken.sol";
import "./token/observer/TokenObserver.sol";
import "./token/retriever/TokenRetriever.sol";
import "../infrastructure/ownership/IMultiOwned.sol";
import "../infrastructure/ownership/TransferableOwnership.sol";

/**
 * @title Dcorp Proxy
 *
 * Serves as a placeholder for the Dcorp funds, allowing the community the ability to vote on the acceptance of the VC platform,
 * and the transfer of token ownership. This mechanism is in place to allow the unlocking of the original DRP token, and to allow token 
 * holders to convert to DRPU or DRPS.

 * This proxy is deployed upon receiving the Ether that is currently held by the DRP Crowdsale contract.
 *
 * #created 16/10/2017
 * #author Frank Bonnet
 */
contract DcorpProxy is TokenObserver, TransferableOwnership, TokenRetriever {

    enum Stages {
        Deploying,
        Deployed,
        Executed
    }

    struct Balance {
        uint drps;
        uint drpu;
        uint index;
    }

    struct Vote {
        uint datetime;
        bool support;
        uint index;
    }

    struct Proposal {
        uint createdTimestamp;
        uint supportingWeight;
        uint rejectingWeight;
        mapping(address => Vote) votes;
        address[] voteIndex;
        uint index;
    }

    // State
    Stages private stage;

    // Settings
    uint constant VOTING_DURATION = 7 days;
    uint constant MIN_QUORUM = 5; // 5%

    // Alocated balances
    mapping (address => Balance) private allocated;
    address[] private allocatedIndex;

    // Proposals
    mapping(address => Proposal) private proposals;
    address[] private proposalIndex;

    // Tokens
    IToken private drpsToken;
    IToken private drpuToken;

    // Crowdsale
    address private drpCrowdsale;


    /**
     * Require that the proxy is in `_stage` 
     */
    modifier only_at_stage(Stages _stage) {
        require(stage == _stage);
        _;
    }


    /**
     * Require `_token` to be one of the drp tokens
     *
     * @param _token The address to test against
     */
    modifier only_accepted_token(address _token) {
        require(_token == address(drpsToken) || _token == address(drpuToken));
        _;
    }


    /**
     * Require that `_token` is not one of the drp tokens
     *
     * @param _token The address to test against
     */
    modifier not_accepted_token(address _token) {
        require(_token != address(drpsToken) && _token != address(drpuToken));
        _;
    }


    /**
     * Require that sender has more than zero tokens 
     */
    modifier only_token_holder() {
        require(allocated[msg.sender].drps > 0 || allocated[msg.sender].drpu > 0);
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
     * @param _drpsToken The new security token
     * @param _drpuToken The new utility token
     * @param _drpCrowdsale Proxy accepts and requires ether from the crowdsale
     */
    function DcorpProxy(address _drpsToken, address _drpuToken, address _drpCrowdsale) {
        drpsToken = IToken(_drpsToken);
        drpuToken = IToken(_drpuToken);
        drpCrowdsale = _drpCrowdsale;
        stage = Stages.Deploying;
    }


    /**
     * Returns whether the proxy is being deployed
     *
     * @return Whether the proxy is in the deploying stage
     */
    function isDeploying() public constant returns (bool) {
        return stage == Stages.Deploying;
    }


    /**
     * Returns whether the proxy is deployed. The proxy is deployed 
     * when it receives Ether from the drp crowdsale contract
     *
     * @return Whether the proxy is deployed
     */
    function isDeployed() public constant returns (bool) {
        return stage == Stages.Deployed;
    }


    /**
     * Returns whether a proposal, and with it the proxy itself, is 
     * already executed or not
     *
     * @return Whether the proxy is executed
     */
    function isExecuted() public constant returns (bool) {
        return stage == Stages.Executed;
    }


     /**
     * Accept eth from the crowdsale while deploying
     */
    function () public payable only_at_stage(Stages.Deploying) {
        require(msg.sender == drpCrowdsale);
        stage = Stages.Deployed;
    }


    /**
     * Returns the combined total supply of all drp tokens
     *
     * @return The combined total drp supply
     */
    function getTotalSupply() public constant returns (uint) {
        uint sum = 0; 
        sum += drpsToken.totalSupply();
        sum += drpuToken.totalSupply();
        return sum;
    }


    /**
     * Returns true if `_owner` has a balance allocated
     *
     * @param _owner The account that the balance is allocated for
     * @return True if there is a balance that belongs to `_owner`
     */
    function hasBalance(address _owner) public constant returns (bool) {
        return allocatedIndex.length > 0 && _owner == allocatedIndex[allocated[_owner].index];
    }


    /** 
     * Get the allocated drps token balance of `_owner`
     * 
     * @param _token The address to test against
     * @param _owner The address from which the allocated token balance will be retrieved
     * @return The allocated drps token balance
     */
    function balanceOf(address _token, address _owner) public constant returns (uint) {
        uint balance = 0;
        if (address(drpsToken) == _token) {
            balance = allocated[_owner].drps;
        } 
        
        else if (address(drpuToken) == _token) {
            balance = allocated[_owner].drpu;
        }

        return balance;
    }


    /**
     * Returns true if `_proposedAddress` is already proposed
     *
     * @param _proposedAddress Address that was proposed
     * @return Whether `_proposedAddress` is already proposed 
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
    function propose(address _proposedAddress) public only_owner only_at_stage(Stages.Deployed) {
        require(!isProposed(_proposedAddress));

        // Add proposal
        Proposal storage p = proposals[_proposedAddress];
        p.createdTimestamp = now;
        p.index = proposalIndex.push(_proposedAddress) - 1;
    }


    /**
     * Gets the voting duration, the amount of time voting 
     * is allowed
     *
     * @return Voting duration
     */
    function getVotingDuration() public constant returns (uint) {              
        return VOTING_DURATION;
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
     * @return bool Whether `_account` has voted on the proposal
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
     * Returns true if `_account` supported a proposal
     *
     * @param _proposedAddress The proposed DCORP address 
     * @param _account The key (address) that maps to the vote
     * @return bool Supported
     */
    function getVote(address _proposedAddress, address _account) public constant returns (bool) {
        return proposals[_proposedAddress].votes[_account].support;
    }


    /**
     * Allows a token holder to vote on a proposal
     *
     * @param _proposedAddress The proposed DCORP address 
     * @param _support True if supported
     */
    function vote(address _proposedAddress, bool _support) public only_at_stage(Stages.Deployed) only_proposed(_proposedAddress) only_during_voting_period(_proposedAddress) only_token_holder {    
        Proposal storage p = proposals[_proposedAddress];
        Balance storage b = allocated[msg.sender];
        
        // Register vote
        if (!hasVoted(_proposedAddress, msg.sender)) {
            p.votes[msg.sender] = Vote(
                now, _support, p.voteIndex.push(msg.sender) - 1);

            // Register weight
            if (_support) {
                p.supportingWeight += b.drps + b.drpu;
            } else {
                p.rejectingWeight += b.drps + b.drpu;
            }
        } else {
            Vote storage v = p.votes[msg.sender];
            if (v.support != _support) {

                // Register changed weight
                if (_support) {
                    p.supportingWeight += b.drps + b.drpu;
                    p.rejectingWeight -= b.drps + b.drpu;
                } else {
                    p.rejectingWeight += b.drps + b.drpu;
                    p.supportingWeight -= b.drps + b.drpu;
                }
            }

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
        return (p.supportingWeight, p.rejectingWeight);
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
                supported = support + reject >= getTotalSupply() * MIN_QUORUM / 100;
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
     * @param _acceptedAddress The accepted DCORP address 
     * @return bool Success
     */
    function execute(address _acceptedAddress) public only_owner only_at_stage(Stages.Deployed) only_proposed(_acceptedAddress) only_after_voting_period(_acceptedAddress) only_when_supported(_acceptedAddress) {
        
        // Mark as executed
        stage = Stages.Executed;

        // Add accepted address as token owner
        IMultiOwned(drpsToken).addOwner(_acceptedAddress);
        IMultiOwned(drpuToken).addOwner(_acceptedAddress);

        // Remove self token as owner
        IMultiOwned(drpsToken).removeOwner(this);
        IMultiOwned(drpuToken).removeOwner(this);

        // Transfer Eth (safe because we don't know how much gas is used counting votes)
        uint balanceBefore = _acceptedAddress.balance;
        uint balanceToSend = this.balance;
        _acceptedAddress.transfer(balanceToSend);

        // Assert balances
        assert(balanceBefore + balanceToSend == _acceptedAddress.balance);
        assert(this.balance == 0);
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
    function onTokensReceived(address _token, address _from, uint _value) internal only_at_stage(Stages.Deployed) only_accepted_token(_token) {
        require(_token == msg.sender);

        // Allocate tokens
        if (!hasBalance(_from)) {
            allocated[_from] = Balance(
                0, 0, allocatedIndex.push(_from) - 1);
        }

        Balance storage b = allocated[_from];
        if (_token == address(drpsToken)) {
            b.drps += _value;
        } else {
            b.drpu += _value;
        }

        // Increase weight
        _adjustWeight(_from, _value, true);
    }


    /**
     * Withdraw DRPS tokens from the proxy and reduce the 
     * owners weight accordingly
     * 
     * @param _value The amount of DRPS tokens to withdraw
     */
    function withdrawDRPS(uint _value) public {
        Balance storage b = allocated[msg.sender];

        // Require sufficient balance
        require(b.drps >= _value);
        require(b.drps - _value <= b.drps);

        // Update balance
        b.drps -= _value;

        // Reduce weight
        _adjustWeight(msg.sender, _value, false);

        // Call external
        if (!drpsToken.transfer(msg.sender, _value)) {
            revert();
        }
    }


    /**
     * Withdraw DRPU tokens from the proxy and reduce the 
     * owners weight accordingly
     * 
     * @param _value The amount of DRPU tokens to withdraw
     */
    function withdrawDRPU(uint _value) public {
        Balance storage b = allocated[msg.sender];

        // Require sufficient balance
        require(b.drpu >= _value);
        require(b.drpu - _value <= b.drpu);

        // Update balance
        b.drpu -= _value;

        // Reduce weight
        _adjustWeight(msg.sender, _value, false);

        // Call external
        if (!drpuToken.transfer(msg.sender, _value)) {
            revert();
        }
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve tokens from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public only_owner not_accepted_token(_tokenContract) {
        super.retrieveTokens(_tokenContract);
    }


    /**
     * Adjust voting weight in ongoing proposals on which `_owner` 
     * has already voted
     * 
     * @param _owner The owner of the weight
     * @param _value The amount of weight that is adjusted
     * @param _increase Indicated whether the weight is increased or decreased
     */
    function _adjustWeight(address _owner, uint _value, bool _increase) private {
        for (uint i = proposalIndex.length; i > 0; i--) {
            Proposal storage p = proposals[proposalIndex[i - 1]];
            if (now > p.createdTimestamp + VOTING_DURATION) {
                break; // Last active proposal
            }

            if (hasVoted(proposalIndex[i - 1], _owner)) {
                if (p.votes[_owner].support) {
                    if (_increase) {
                        p.supportingWeight += _value;
                    } else {
                        p.supportingWeight -= _value;
                    }
                } else {
                    if (_increase) {
                        p.rejectingWeight += _value;
                    } else {
                        p.rejectingWeight -= _value;
                    }
                }
            }
        }
    }
}
