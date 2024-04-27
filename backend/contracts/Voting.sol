// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Voting {
    uint nextVoteId;

    struct Vote {
        string uri;
        address owner;
        uint endTime;
        uint[] votes;
        mapping(address => bool) voted;
        uint options;
    }

    mapping(uint => Vote) votes;
    mapping(address => bool) public members;

    event MemberJoined(address indexed member, uint joinedAt);
    event VoteCreated(
        address indexed owner,
        uint indexed voteId,
        uint indexed createdAd,
        uint endTime
    );
    event Voted(
        address indexed voter,
        uint indexed voteId,
        uint indexed option,
        uint createdAt
    );

    modifier isMember() {
        require(members[msg.sender], "you are not a member");
        _;
    }

    modifier canVote(uint voteId, uint option) {
        require(voteId < nextVoteId, "poll does not exist");
        require(option < votes[voteId].options, "invalid option");
        require(!votes[voteId].voted[msg.sender], "you already voted");
        require(block.timestamp < votes[voteId].endTime, "poll already ended");
        _;
    }

    function join() external {
        require(!members[msg.sender], "you are already a member");
        members[msg.sender] = true;

        emit MemberJoined(msg.sender, block.timestamp);
    }

    function createVote(
        string memory uri,
        uint endTime,
        uint options
    ) external isMember {
        require(
            options >= 2 && options <= 8,
            "options must be between 2 and 8"
        );
        require(endTime > block.timestamp, "poll can not be in the past");
        uint voteId = nextVoteId;

        votes[voteId].uri = uri;
        votes[voteId].endTime = endTime;
        votes[voteId].owner = msg.sender;
        votes[voteId].options = options;
        votes[voteId].votes = new uint[](options);

        emit VoteCreated(msg.sender, voteId, block.timestamp, endTime);
        nextVoteId++;
    }

    function vote(
        uint voteId,
        uint option
    ) external isMember canVote(voteId, option) {
        votes[voteId].votes[option] = votes[voteId].votes[option] + 1;
        votes[voteId].voted[msg.sender] = true;

        emit Voted(msg.sender, voteId, option, block.timestamp);
    }

    function getVote(
        uint voteId
    ) public view returns (string memory, address, uint[] memory, uint) {
        return (
            votes[voteId].uri,
            votes[voteId].owner,
            votes[voteId].votes,
            votes[voteId].endTime
        );
    }

    function didVote(address member, uint voteId) public view returns (bool) {
        return votes[voteId].voted[member];
    }
}
