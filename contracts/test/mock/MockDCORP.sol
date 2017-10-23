pragma solidity ^0.4.15;


/**
 * @title Mock DCORP for testing only
 *
 * #created 23/10/2017
 * #author Frank Bonnet
 */  
contract MockDCORP {

    struct Proposal {
        address dcorpAddress;
        uint256 deadline;
        uint256 approvedWeight;
        uint256 disapprovedWeight;
        mapping (address => uint256) voted;
    }

    Proposal public transferProposal;


    function MockDCORP() payable {}


    function proposeTransfer(address _dcorpAddress) {
        transferProposal = Proposal({
            dcorpAddress: _dcorpAddress,
            deadline: now,
            approvedWeight: 0,
            disapprovedWeight: 0
        });
    }


    function executeTransfer() {
        if (!transferProposal.dcorpAddress.send(this.balance)) {
            revert();
        }
    } 
}
