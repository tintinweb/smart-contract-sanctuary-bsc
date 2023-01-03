/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

contract ADATLiquidityLock {
    struct Lock {
        address owner;
        uint lockDuration;
        uint tokenCount;
    }

    mapping(address => Lock) public locks;

    function lockPair(address token, uint lockDuration, uint tokenCount) public {
        require(locks[token].lockDuration == 0, "Token is already locked");
        locks[token] = Lock(msg.sender, lockDuration, tokenCount);
    }

    function unlockPair(address token, uint tokenCount) public {
        Lock storage lock = locks[token];
        require(lock.lockDuration != 0, "Token is not locked");
        require(lock.lockDuration + lock.lockDuration < block.timestamp, "Lock duration has not expired");
        require(lock.owner == msg.sender, "Only the owner can unlock the token");
        require(lock.tokenCount == tokenCount, "Incorrect number of tokens");
        lock.lockDuration = 0;
        lock.tokenCount = 0;
    }

    function getLockDuration(address token) public view returns (uint) {
        return locks[token].lockDuration;
    }

    function getTokenCount(address token) public view returns (uint) {
        return locks[token].tokenCount;
    }
}