pragma solidity ^0.8.30;

import {Ownable} from '../lib/openzeppelin-contracts/contracts/access/Ownable.sol';
import {IERC20} from '../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

contract DAOContract is Ownable {

    struct Proposal {
        uint id;
        string description;
        bool executed;

        uint voteCountFor;
        uint voteCountAgainst;
        uint deadline;
    }

    uint public proposalCount;

    uint public minAmountToCreateProposal;
    uint public votingPeriod = 3 days;

    uint public constant MAJORITY_PERC = 50;
    IERC20 public immutable governanceToken;

    mapping(uint => Proposal) public proposals;
    mapping(uint => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint id, address creator, string description);
    event ProposalExecuted(uint id);
    event Voted(uint id, address voter, bool support, uint amount);

    constructor(address _governanceToken, uint _minAmountToCreateProposal, uint _votingPeriod) Ownable(msg.sender){
        require(_governanceToken != address(0), "DAO: governance token is zero");
        require(_votingPeriod > 0, "DAO: voting period should be greater than zero");
        governanceToken = IERC20(_governanceToken);
        minAmountToCreateProposal = _minAmountToCreateProposal;
        votingPeriod = _votingPeriod;
    }

    modifier isExecutable(uint _proposalId) {
        Proposal storage proposal = proposals[_proposalId];

        require(_proposalId > 0 && _proposalId <= proposalCount, "DAO: invalid proposal Id");
        require(!proposal.executed, "DAO: proposal was executed before");
        require(block.timestamp >= proposal.deadline, "DAO: voting period is still active");

        uint totalVotes = proposal.voteCountFor + proposal.voteCountAgainst;
        require(totalVotes > 0, "DAO: no votes for this proposal");

        require(proposal.voteCountFor > totalVotes * MAJORITY_PERC / 100, "DAO: quorum was not reached");
        _;
    }

    function createProposal(string memory _description) external onlyOwner {
        require(bytes(_description).length > 0, "DAO: proposal not described");
        require(governanceToken.balanceOf(msg.sender) >= minAmountToCreateProposal, "DAO: not enough tokens to create proposal");
        proposalCount++;

        uint deadline = block.timestamp + votingPeriod;

        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            executed: false,
            voteCountFor: 0,
            voteCountAgainst: 0,
            deadline: deadline
        });

        emit ProposalCreated(proposalCount, msg.sender, _description);
    }

    function vote(uint _proposalId, bool _support) external  {
        Proposal storage proposal = proposals[_proposalId];

        require(_proposalId > 0 && _proposalId <= proposalCount, "DAO: invalid proposal Id");
        require(block.timestamp < proposal.deadline, "DAO: voting is expired");
        require(!hasVoted[_proposalId][msg.sender], "DAO: user already has voted");

        uint voterBalance = governanceToken.balanceOf(msg.sender);
        require(voterBalance > 0, "DAO: vote amount should be greater than zero");

        if(_support){
            proposal.voteCountFor += voterBalance;
        } else {
            proposal.voteCountAgainst += voterBalance;
        }

        hasVoted[_proposalId][msg.sender] = true;

        emit Voted(_proposalId, msg.sender, _support, voterBalance);
    }

    function canExecute(uint _proposalId) external view isExecutable(_proposalId) returns(bool) {
        return true;
    }

    function executeProposal(uint _proposalId) external isExecutable(_proposalId) onlyOwner {
        proposals[_proposalId].executed = true;
        emit ProposalExecuted(_proposalId);
    }

    function getProposal(uint _proposalId) external view returns(string memory) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "DAO: invalid proposal Id");
        return proposals[_proposalId].description;
    }
}
