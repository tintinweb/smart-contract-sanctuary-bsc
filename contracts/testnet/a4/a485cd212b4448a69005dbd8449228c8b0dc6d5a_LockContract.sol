/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

interface OwnableContract {
    function transferOwnership(address newOwner) external;

    function owner() external view returns (address);
}

contract LockContract {
    struct LockData {
        address locker;
        address contractAddress;
        uint lockTime;
        bool locked;
    }

    mapping(uint => LockData) public lockDatas;
    uint lockCount = 0;

    function lock(address _contractAddress, uint _lockTime) external {
        require(
            OwnableContract(_contractAddress).owner() == msg.sender,
            "Permission denied!"
        );
        lockDatas[lockCount].locker = msg.sender;
        lockDatas[lockCount].contractAddress = _contractAddress;
        lockDatas[lockCount].lockTime = block.timestamp+ _lockTime;
        lockDatas[lockCount].locked = true;
        lockCount++;
    }

    function unlock(uint lockId) external {
        require(lockDatas[lockId].locker == msg.sender, "Permission denied!");
        require(lockDatas[lockId].lockTime <= block.timestamp, "Locking time!");
        OwnableContract(lockDatas[lockId].contractAddress).transferOwnership(
            lockDatas[lockId].locker
        );
        lockDatas[lockId].locker = address(0);
        lockDatas[lockId].contractAddress = address(0);
        lockDatas[lockId].lockTime = 0;
        lockDatas[lockId].locked = false;
    }
}