//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;

import "github.com/smartcontractkit/chainlink/evm-contracts/src/v0.6/ChainlinkClient.sol";




contract Proposal is ChainlinkClient {
    
    address public creator;
    string public title;
    string public description;
    uint256 private yesCount;
    uint256 private noCount;
    bool votingLive = false;
    mapping(address => bool) public voters;
    
    event Voted(address voter, uint256 date);
    uint256 private oraclePayment;
    bytes32 private jobId;
    address private oracle;
    address[] participants;
    
    
    
    

    constructor(
        string memory _actionTitle,
        string memory _actiondescription
    ) public {
        
        description = _actiondescription;
        title = _actionTitle;
        
        setPublicChainlinkToken();
        oraclePayment = 0.1 * 10 ** 18; // 0.1 link
        //kovan alarm
        oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e; 
        jobId = "a7ab70d561d34eb49e9b1612fd2e044b";
        // initialize vote
        yesCount = 0;
        noCount = 0;
        votingLive = false;
    }
    // launch a vote time with chainlink oracle
    function launchVote(uint256 timeAllow) public {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        req.addUint("until", block.timestamp + timeAllow * 1 days);
        votingLive = true;
        sendChainlinkRequestTo(oracle, req, oraclePayment);
    }
    
    function fulfill(bytes32 _requestId) public recordChainlinkFulfillment(_requestId) {
        votingLive = false;
    }
    
    //join the participants array
    function joinVote() public {
        participants.push(msg.sender);
    }
    
    
     function vote(bool voteCast) external {
        require(!voters[msg.sender], "Already voted!");
        
        
        //if voting is live and address hasn't voted yet, count vote  
        if(voteCast) {yesCount++;}
        if(!voteCast) {noCount++;}
        //address has voted, mark them as such
        voters[msg.sender] = true;
   }
   
   // get list of all voters
   function getParticipant() public view returns (address[] memory){
       return participants;
   }
    

    // get all vote count
    function getVote() public view returns (uint256 yesVote, uint256 noVote) {
        return (yesCount, noCount);
    }
    
    // determine if address have voted or not
    function haveYouVoted() public view returns (bool) {
      return voters[msg.sender];
    }
    
    
    
}