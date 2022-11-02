/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IELockerV2 {
    function ENVOLOCK(
        address _owner,
        address _token,
        uint256 _amount,
        uint256 _lockTime,
        bool _feeWithBNB,
        string memory _desc
    ) external payable returns (uint256 id);

    function editLock(
        uint256 _id,
        uint256 _newAmount,
        uint256 _newLockTime
    ) external returns (bool);

    function safeUnlock(uint256 _id) external returns (bool);
}

interface IPFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

contract EnvoLockerV2 is IELockerV2 {
    address payable public lockerTreasury;
    uint256 private ID = 0;
    address public constant pancakeFactory =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    struct LockID {
        uint256 id;
        address owner;
        address token;
        uint256 amount;
        uint256 lockTime;
        string desc;
    }

    LockID[] private locksID;

    constructor(address payable _lockerTreasury) {
        lockerTreasury = _lockerTreasury;
    }

    receive() external payable {}

    function ENVOLOCK(
        address _owner,
        address _token,
        uint256 _amount,
        uint256 _lockTime,
        bool _feeWithBNB,
        string memory _desc
    ) external payable override returns (uint256 id) {
        require(_token != address(0), "Invalid Token Address!");
        require(_amount > 0, "Amount can't be 0");
        require(
            _lockTime > block.timestamp,
            "Unlock date should be in the future"
        );

        if (_feeWithBNB) {
            require(
                msg.value == 1000000000000000000,
                "Insufficient Fee Transaction"
            );
            lockerTreasury.transfer(1000000000000000000);
            return nomralLock(_owner, _token, _amount, _lockTime, _desc);
        } else {
            nomralLock(_owner, _token, _amount, _lockTime, _desc);
            return ID += 1;
        }
    }

    function nomralLock(
        address _owner,
        address _token,
        uint256 _amount,
        uint256 _lockTime,
        string memory _desc
    ) internal returns (uint256 id) {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        locksID.push(
            LockID({
                id: locksID.length,
                owner: _owner,
                token: _token,
                amount: _amount,
                lockTime: _lockTime,
                desc: _desc
            })
        );
        id = locksID.length;
    }

    function findLockByAddress(address _owner)
        external
        view
        returns (LockID memory locksss)
    {
        for (uint256 i = 0; i < locksID.length; i++) {
            if (locksID[i].owner == _owner) {
                return locksID[i];
            }
        }
    }

    function findLockById(uint256 _id)
        external
        view
        returns (LockID memory Lid)
    {
        return locksID[_id];
    }

    function editLock(
        uint256 _id,
        uint256 _newAmount,
        uint256 _newLockTime
    ) external override returns (bool) {
        LockID storage lockID = locksID[_id];
        require(msg.sender == lockID.owner, "You're not the owner!");
        require(
            _newLockTime > lockID.lockTime,
            "New Time should be more than previous time!"
        );
        require(lockID.amount != 0, "No token is being lock");
        require(
            _newAmount >= lockID.amount,
            "New amount should not be less than last amount"
        );
        lockID.amount = _newAmount;
        lockID.lockTime = _newLockTime;
        return true;
    }

    function safeUnlock(uint256 _id) external override returns (bool) {
        LockID storage lockID = locksID[_id];
        require(msg.sender == lockID.owner, "You're not the owner!");
        require(
            lockID.lockTime <= block.timestamp,
            "Token is not yet unlocked!"
        );

        IERC20(lockID.token).transferFrom(
            address(this),
            msg.sender,
            lockID.amount
        );
        return true;
    }

    function getAllLocks() external view returns (LockID[] memory) {
        LockID[] memory lockID = new LockID[](locksID.length);
        for (uint256 i = 0; i < locksID.length; i++) {
            lockID[i] = locksID[i];
        }
        return lockID;
    }
}