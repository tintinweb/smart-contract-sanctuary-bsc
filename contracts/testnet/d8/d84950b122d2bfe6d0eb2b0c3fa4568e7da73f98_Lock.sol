/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: GPLv3

pragma solidity =0.8.16;

interface IERC20 {

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Lock {

    event Locked(address indexed owner, address indexed token, uint256 total, uint64 startAt, uint64 endAt);

    event Withdrawed(address indexed owner, address indexed token, uint256 amount, uint256 balance);

    struct LockItem {
        address token; // token address (immutable)
        uint256 total; // total locked (immutable)
        uint256 balance; // current amount balance (mutable)
        uint64 lockedAt; // locked time (immutable)
        uint64 startAt; // start time to unlock (mutable)
        uint64 endAt; // end time to unlock all (immutable)
    }

    mapping(address => LockItem[]) public lockings;

    function lockToken(address owner, address token, uint256 amount, uint64 startAt, uint64 endAt) external {
        require(owner != address(0), "zero address");
        require(token != address(0), "zero address");
        require(amount > 0, "invalid amount");
        require(startAt >= block.timestamp, "invalid start time");
        require(endAt > startAt, "invalid end time");
        // transfer token into contract:
        (IERC20(token)).transferFrom(msg.sender, address(this), amount);
        // set lock info:
        LockItem memory lock = LockItem(token, amount, amount, uint64(block.timestamp), startAt, endAt);
        LockItem[] storage locks = lockings[owner];
        locks.push(lock);
        emit Locked(owner, token, amount, startAt, endAt);
    }

    function withdrawToken(uint256 index) external {
        LockItem[] storage locks = lockings[msg.sender];
        require(locks.length > index, "index out of bounds");
        LockItem storage lock = locks[index];
        require(block.timestamp > lock.startAt, "still locked");
        // calculate how many token is unlocked:
        uint64 ts = uint64(block.timestamp);
        uint256 canWithdraw = (lock.endAt <= ts) ? lock.balance : (lock.balance * (ts - lock.startAt)) / (lock.endAt - lock.startAt);
        (IERC20(lock.token)).transferFrom(address(this), msg.sender, canWithdraw);
        uint256 left = lock.balance - canWithdraw;
        emit Withdrawed(msg.sender, lock.token, canWithdraw, left);
        if (left == 0) {
            // move the last element into the place to delete:
            locks[index] = locks[locks.length - 1];
            locks.pop();
        } else {
            lock.balance = left;
            lock.startAt = ts;
        }
    }
}