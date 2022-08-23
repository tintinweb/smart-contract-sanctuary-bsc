/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: none

pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}

contract TokenLockerV2 is Context {
    struct LockStruct {
        IERC20 token;
        address beneficiary;
        uint256 amount;
        uint256 releaseTimestamp;
        bool isActive;
    }

    mapping (address => uint256[]) private beneficiaryIDs;

    LockStruct[] private locker;

    function getLockInfo(uint256 lockID) public view returns (IERC20 token, address beneficiary, uint256 amount, uint256 releaseTimestamp, bool isActive) { 
        return (locker[lockID].token, locker[lockID].beneficiary, locker[lockID].amount, locker[lockID].releaseTimestamp, locker[lockID].isActive);
    }
    function getLockerLength() public view returns (uint256) { 
        return locker.length;
    }

    function getIDByBeneficiary(address beneficiary, uint256 index) public view returns (uint256) {
        return beneficiaryIDs[beneficiary][index];
    }

    function getInfoByBeneficiary(address beneficiary, IERC20 token) public view returns (uint256 TotalActiveLocks, uint256 TotalHeld, uint256 TotalUnlocked) {
        uint256 totalActiveLocks; uint256 totalLocked; uint256 totalUnlocked;

        for (uint256 i = 0; i < beneficiaryIDs[beneficiary].length; i++) {
            uint256 lockID = beneficiaryIDs[beneficiary][i];
            if (locker[lockID].isActive && locker[lockID].token == token) {
                totalActiveLocks++;
                totalLocked = totalLocked + locker[lockID].amount;
                if (block.timestamp >= locker[lockID].releaseTimestamp)
                    totalUnlocked = totalUnlocked + locker[lockID].amount;
            }
        }
        return (totalActiveLocks, totalLocked, totalUnlocked);
    }

    function lockToken (IERC20 token, address beneficiary, uint256 amount, uint256 releaseTimestamp) public {
        require(releaseTimestamp > block.timestamp, "TokenTimelock: release time is before current time");

        bool isLockAlreadyCreated = false; uint256 lockID;
        for (uint256 i = 0; i < beneficiaryIDs[beneficiary].length; i++) {
            lockID = beneficiaryIDs[beneficiary][i];
            if (locker[lockID].isActive && locker[lockID].token == token && locker[lockID].releaseTimestamp == releaseTimestamp)
                isLockAlreadyCreated = true;
        }
        if (isLockAlreadyCreated)
            increaseLockAmount(lockID, amount);
        else {
            LockStruct memory newLock = LockStruct({
                token: token,
                beneficiary: beneficiary,
                amount: amount,
                releaseTimestamp: releaseTimestamp,
                isActive: true
            });
            locker.push(newLock);

            beneficiaryIDs[beneficiary].push(locker.length - 1);

            token.transferFrom(_msgSender(), address(this), amount);
        }
    }

    function extendLock(uint256 lockID, uint256 releaseTimestamp) public virtual {
        require(locker[lockID].isActive, "TokenTimelock: lock ID is inactive.");
        require(_msgSender() == locker[lockID].beneficiary, "TokenTimelock: release time is before current lock.");
        require(releaseTimestamp > locker[lockID].releaseTimestamp, "TokenTimelock: release time is before current lock.");

        locker[lockID].releaseTimestamp = releaseTimestamp;
    }

    function increaseLockAmount(uint256 lockID, uint256 addAmount) public virtual {
        require(locker[lockID].isActive, "TokenTimelock: lock ID is inactive.");

        locker[lockID].amount = locker[lockID].amount + addAmount;

        locker[lockID].token.transferFrom(_msgSender(), address(this), addAmount);
    }

    function release(uint256 lockID) public virtual {
        require(_msgSender() == locker[lockID].beneficiary, "TokenTimelock: release time is before current lock.");
        require(block.timestamp >= locker[lockID].releaseTimestamp, "TokenTimelock: current time is before release time.");
        require(locker[lockID].amount > 0, "TokenTimelock: no tokens to release");

        locker[lockID].token.transfer(locker[lockID].beneficiary, locker[lockID].amount);

        locker[lockID].amount = 0;
        locker[lockID].isActive = false;
    }

    function releaseAllUnlocked() public virtual {
        for (uint256 i = 0; i < beneficiaryIDs[_msgSender()].length; i++) {
            uint256 lockID = beneficiaryIDs[_msgSender()][i];
            if (block.timestamp >= locker[lockID].releaseTimestamp && locker[lockID].amount > 0) {
                locker[lockID].token.transfer(locker[lockID].beneficiary, locker[lockID].amount);

                locker[lockID].amount = 0;
                locker[lockID].isActive = false;
            }
        }
    }
}