/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT
/*
███████╗██╗  ██╗██╗███╗   ███╗   ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗
██╔════╝██║  ██║██║████╗ ████║   ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝
███████╗███████║██║██╔████╔██║   █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  
╚════██║██╔══██║██║██║╚██╔╝██║   ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  
███████║██║  ██║██║██║ ╚═╝ ██║██╗██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
*/
//     https://shim.finance/
// SHIM PROTOCOL COPYRIGHT (C) 2022 


pragma solidity ^0.8.11;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

}

contract ShimLock is ReentrancyGuard {
    using SafeMath for uint256;
    string public name = "ShimLock";

    struct LockInfo {
        uint256 id;
        address owner;
        address token;
        uint256 lockStartTime;
        uint256 lockPeriod;
        uint256 lockedAmount;
    }

    LockInfo[] public lockInfo;
    mapping (address => uint256[]) public userInfo;

    event LockCreate(
        uint256 indexed id,
        address token,
        address owner,
        uint256 lockStartTime,
        uint256 lockPeriod,
        uint256 lockAmount
    );
    event LockRelease(
        uint256 indexed id,
        uint256 unlockAmount
    );
    event LockAmountIncrease(
        uint256 indexed id,
        uint256 amount
    );
    event LockPeriodIncrease(
        uint256 indexed id,
        uint256 period
    );
    event LockOwnerTransfer(
        uint256 indexed id,
        address newOwner
    );
    
    constructor() {}

    function totalLockLength() external view returns (uint256) {
        return lockInfo.length;
    }

    function userLockLength(address _userAddress) external view returns (uint256) {
        return userInfo[_userAddress].length;
    }
    
    function createLock(
        address _token,
        address _owner,
        uint256 _lockPeriod,
        uint256 _lockAmount
    ) external nonReentrant{
        IERC20(_token).transferFrom(msg.sender, address(this), _lockAmount);
        uint256 _id = lockInfo.length;
        userInfo[_owner].push(_id);
        lockInfo.push(LockInfo({
            id: _id,
            owner: _owner,
            token: _token,
            lockStartTime: block.timestamp,
            lockPeriod: _lockPeriod,
            lockedAmount: _lockAmount
        }));

        emit LockCreate(
            _id,
            _token,
            _owner,
            block.timestamp,
            _lockPeriod,
            _lockAmount
        );
    }

    function unLock(
        uint256 _id,
        uint256 _unlockAmount
    ) external nonReentrant{
        require(lockInfo[_id].owner == msg.sender, "Forbidden");
        require(lockInfo[_id].lockedAmount >= _unlockAmount, "Overflow UnLock Amount");
        require(block.timestamp >= (lockInfo[_id].lockStartTime +
            lockInfo[_id].lockPeriod), "Not time to unlock");
        if (_unlockAmount > 0) {
            IERC20(lockInfo[_id].token).transfer(
                lockInfo[_id].owner, _unlockAmount);
            lockInfo[_id].lockedAmount = lockInfo[_id].lockedAmount.sub(_unlockAmount);
        } else {
            IERC20(lockInfo[_id].token).transfer(
                lockInfo[_id].owner, lockInfo[_id].lockedAmount);
            lockInfo[_id].lockedAmount = 0;
        }

        emit LockRelease(
            _id,
            _unlockAmount
        );
    }

    function increaseLockAmount(
        uint256 _id,
        uint256 _amount
    ) external nonReentrant{
        IERC20(lockInfo[_id].token).transferFrom(msg.sender, address(this), _amount);
        lockInfo[_id].lockedAmount = lockInfo[_id].lockedAmount.add(_amount);

        emit LockAmountIncrease(
            _id,
            _amount
        );
    }

    function increaseLockPeriod(
        uint256 _id,
        uint256 _period
    ) external nonReentrant{
        require(lockInfo[_id].owner == msg.sender, "Forbidden");
        lockInfo[_id].lockPeriod = lockInfo[_id].lockPeriod.add(_period);

        emit LockPeriodIncrease(
            _id,
            _period
        );
    }

    function transferLockOwner(
        uint256 _id,
        address _newOwner
    ) external nonReentrant{
        require(lockInfo[_id].owner == msg.sender, "Forbidden");
        require(lockInfo[_id].owner != _newOwner, "Forbidden");
        require(_newOwner != address(0), "Cannot be zero address");
        address _currentOwner = lockInfo[_id].owner;
        lockInfo[_id].owner = _newOwner;
        for (uint256 i = 0; i < userInfo[_currentOwner].length; i++) {
            if(userInfo[_currentOwner][i] == _id) {
                userInfo[_currentOwner][i] = userInfo[_currentOwner][userInfo[_currentOwner].length - 1];
                userInfo[_currentOwner].pop();
                break;
            }
        }
        userInfo[_newOwner].push(_id);

        emit LockOwnerTransfer(
            _id,
            _newOwner
        );
    }
}