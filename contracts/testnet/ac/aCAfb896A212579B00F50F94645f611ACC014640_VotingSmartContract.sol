/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

struct Candidate {
    uint256 id;
    string name;
    uint256 votes;
    address[] voters;
}

struct Pool {
    uint256 id;
    string name;
    string description;
    uint256 createdAt;
    uint256 closedAt;
    uint256 totalVotes;
    address createdBy;
}

contract VotingSmartContract {
    address public owner;

    mapping(uint256 => Pool) private pools;
    mapping(uint256 => mapping(address => bool)) private voted;
    mapping(uint256 => Candidate[]) private candidatesByPool;

    Pool[] private poolList;

    constructor() {
        owner = msg.sender;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    function changeOwner(address newOwner) public {
        require(isOwner(), "Only owner can change the owner");
        owner = newOwner;
    }

    function createPool(
        string calldata name,
        string calldata description,
        string[] calldata _cadidates,
        uint256 closedAt
    ) public {
        require(isOwner(), "Only owner can create a pool");
        uint256 length = poolList.length;

        Pool memory pool = Pool(
            length,
            name,
            description,
            block.timestamp,
            closedAt,
            0,
            msg.sender
        );
        pools[length] = pool;
        poolList.push(pool);

        for (uint256 i = 0; i < _cadidates.length; i++) {
            Candidate memory candidate = Candidate(
                i,
                _cadidates[i],
                0,
                new address[](0)
            );
            candidatesByPool[length].push(candidate);
        }

        emit PoolCreated(length, name, description, closedAt, block.timestamp);
    }

    function vote(uint256 poolId, uint256 candidateId) public {
        require(
            pools[poolId].closedAt > block.timestamp,
            "Voting is closed for this pool"
        );
        require(
            candidatesByPool[poolId].length > candidateId,
            "Invalid candidate"
        );

        require(
            !isVoted(poolId, msg.sender),
            "You have already voted for this pool"
        );

        candidatesByPool[poolId][candidateId].votes++;
        candidatesByPool[poolId][candidateId].voters.push(msg.sender);
        pools[poolId].totalVotes++;
        poolList[poolId].totalVotes++;
        voted[poolId][msg.sender] = true;

        emit PoolVoted(
            poolId,
            candidateId,
            candidatesByPool[poolId][candidateId].name,
            msg.sender,
            block.timestamp
        );
    }

    function getPool(uint256 poolId) public view returns (Pool memory) {
        return pools[poolId];
    }

    function getPoolList() public view returns (Pool[] memory) {
        return poolList;
    }

    function getCandidates(
        uint256 poolId
    ) public view returns (Candidate[] memory) {
        return candidatesByPool[poolId];
    }

    function isVoted(uint256 poolId, address voter) public view returns (bool) {
        return voted[poolId][voter];
    }

    event PoolCreated(
        uint256 id,
        string name,
        string description,
        uint256 closedAt,
        uint256 timestamp
    );

    event PoolVoted(
        uint256 id,
        uint256 cadidateId,
        string name,
        address voter,
        uint256 timestamp
    );
}