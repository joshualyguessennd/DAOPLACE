//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/access/Ownable.sol";
import "./Proposal.sol";


contract DaoPlace is Ownable {
    
    
    Proposal proposal;
    
    
    //
    struct DaoInfo {
        IERC20 Daotoken;
        address retailer;
        Proposal[]  proposals;
        uint256  participants;
        uint256 amountBase;
        uint256 daoValue;
        address[] users;
    }

    DaoInfo[] public daoInfo;
    
    
    struct User {
        address id;
        uint256 StakingBalance;
        uint256 reward;
    }
    

    mapping(uint256 => mapping(address => User)) userInfo;
    event Participate(address indexed user, uint256 daoId, uint256 date);
    event Quit(address indexed user, uint256 daoId, uint256 date);
    event StartProposal(address contractAddress, string actionTitle, string actionDescription, uint256 actionDeadline);
    
    
    // modifier that allow only the initiator project to make some proposals
    modifier omlyInitiator(uint256 _daoId) {
        DaoInfo storage dao = daoInfo[_daoId];
        
        require(dao.retailer == msg.sender);
        _;
    }
    
    
    modifier onlyParticipant(uint256 _daoId) {
        require(isParticipant(msg.sender, _daoId) == true, "you are not allow");
        _;
    }
    
    


    // create a new Dao
    function addDao(IERC20 _token, uint256 _amountBase, address _retailer) public onlyOwner{
        Proposal[] memory _proposals;
        
        address[] memory _users;
        
        daoInfo.push(
            DaoInfo({
                Daotoken: _token,
                retailer: _retailer,
                participants: 0,
                proposals: _proposals,
                users: _users,
                amountBase: _amountBase,
                daoValue: 0
            })
        );
        
    }
    
    
    

    // join a dao user have to deposit ERC20 token in the pool of his choice to take part 
    function deposit(uint _daoId) public {
        DaoInfo storage dao = daoInfo[_daoId];
        require(isParticipant(msg.sender, _daoId) == false, "your already a member");
        
        dao.Daotoken.transferFrom(address(msg.sender), address(this), dao.amountBase);
        dao.daoValue = dao.daoValue + dao.amountBase;
        dao.users.push(msg.sender);
        dao.participants = dao.users.length;
        emit Participate(msg.sender, _daoId,  block.timestamp);
        
    }
    
    
    function getIndex(uint256 _daoId) public view returns (uint256) {
        DaoInfo storage dao = daoInfo[_daoId];
        for(uint256 i=0; i<dao.users.length; i++){
            if(msg.sender == dao.users[i]){
                return i;
            }
        }
    }
    
    
    function quit(uint256 _daoId) public {
        DaoInfo storage dao = daoInfo[_daoId];
        require(isParticipant(msg.sender, _daoId) == true, "you're not part of this trip");
        uint256 id = getIndex(_daoId);
        dao.users[id] = dao.users[dao.users.length -1];
        dao.Daotoken.transfer(address(msg.sender), dao.amountBase);
        dao.participants = dao.participants - 1;
        dao.users.pop();
    }
    
    
    function isParticipant(address _participant, uint256 _daoId) public view returns (bool) {
        DaoInfo storage dao = daoInfo[_daoId];
        if(dao.users.length == 0) return false;
        for(uint256 i=0; i<dao.users.length; i++){
            if(dao.users[i] == _participant) {
                return true;
            }
            
        }
        return false;
    }
    
    
    function Vote(uint _daoId, uint256 _id, bool voteCast) external onlyParticipant(_daoId){
        DaoInfo storage dao = daoInfo[_daoId];
        proposal = dao.proposals[_id];
        proposal.vote(voteCast);
    }
    
    
    
   
    
    
    
    // function to list all dao participants
    function  daoParticipant(uint _daoId) external view returns (address[] memory){
        DaoInfo storage dao = daoInfo[_daoId];
        return dao.users;
    }

    // start an action in the dao
    function initProposal(string calldata title, string calldata description, uint256 _daoId) external omlyInitiator(_daoId){
        DaoInfo storage dao = daoInfo[_daoId];
        
        Proposal newProposal = new Proposal(title, description);
        dao.proposals.push(newProposal);
        
    }

    // function to return all proposals took by the dao
    function returnDaoProposal(uint256 _daoId) external view returns (Proposal[] memory) {
        DaoInfo storage dao = daoInfo[_daoId];
        return dao.proposals;
    }

    

    

    
}