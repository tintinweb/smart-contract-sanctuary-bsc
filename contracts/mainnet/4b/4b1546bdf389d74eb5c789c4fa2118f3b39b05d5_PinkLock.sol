// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./EnumerableSetUpgradeable.sol";
import "./Ownable.sol";

contract PinkLock  is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    

    IERC20 private immutable _token;

    uint256 private allInPool1;
    uint256 private allInPool2;
    uint256 private allInPool3;
    uint256 private allInPool4;
    uint256 private allInPool5;
    bool isLock=true;
    uint private unlocked = 1;
    address private lpToken;

    constructor(
        IERC20 token_,
        address lpToken_
    ) {
       
        _token = token_;
        lpToken = lpToken_;
    }

    struct Lock {
        uint256 id;
        uint256 amount;
        uint256 day;
        uint256 lockDate;
        uint256 unlockDate;
        address owner;
        address token;
        bool isRelease;
    }

    Lock[] public locks;
    mapping(address => EnumerableSetUpgradeable.UintSet) private _userLpLockIds;
    mapping (address => uint256) private _pledgeCount;
    mapping (address => uint256) private _userInPool;

     event LockAdded(
        uint256 indexed id,
        uint256 amount,
        uint256 lockDate,
        uint256 unlockDate,
        address owner,
        address token
    );

    event LockRemoved(
            uint256 indexed id,
            address owner,
            address token,
            uint256 amount,
            uint256 unlockedAt
        );

    function lock(
        uint256 amount,
        uint256 day,
        address owner,
        uint256 unlockDate
    ) external payable runSafe returns (uint256 id)  {
        require(unlockDate > block.timestamp);
        require(amount > 0);
        id = _addLock(owner,day, amount, unlockDate);
        _userInPool[owner]=_userInPool[owner].add(amount);
        _userLpLockIds[owner].add(id);
        _pledgeCount[owner]=_pledgeCount[owner].add(1);
        _addInPool(day,amount);
        token().safeTransferFrom(owner,address(this), amount);
        emit LockAdded(id,amount,block.timestamp,unlockDate,owner,lpToken);
        return id;
    }

    function _addLock(
        address owner,
        uint256 day,
        uint256 amount,
        uint256 unlockDate
    ) private returns (uint256 id) {
        id = locks.length;
        Lock memory newLock = Lock({
        id: id,
        day: day,
        owner: owner,
        token:lpToken,
        amount: amount,
        lockDate: block.timestamp,
        unlockDate: unlockDate,
        isRelease:false
        });
        locks.push(newLock);
    }


    function unlock(uint256 lockId) external  validLock(lockId) runSafe {
        Lock storage userLock = locks[lockId];
        require(userLock.owner == msg.sender, "You are not the owner of this lock");
        if(isLock){
            require(block.timestamp >= userLock.unlockDate, "It is not time to unlock");
        }
        
        require(userLock.amount > 0, "Nothing to unlock");
  
        _userLpLockIds[msg.sender].remove(lockId);
       

        uint256 unlockAmount = userLock.amount;

        _userInPool[msg.sender]=_userInPool[msg.sender].sub(unlockAmount);
        //_pledgeCount[msg.sender]=_pledgeCount[msg.sender].sub(1);
        _subInPool(userLock.day,unlockAmount);
      
        userLock.amount = 0;
        userLock.isRelease = true;

       
        token().safeTransfer(msg.sender, unlockAmount);
        

        emit LockRemoved(
            userLock.id,
            msg.sender,
            lpToken,
            unlockAmount,
            block.timestamp
        );
  }

    function _addInPool(uint256 _day,uint _amount) private returns(bool){
        if(_day==30){
            allInPool1=allInPool1.add(_amount);
        }else if(_day==90){
            allInPool2=allInPool2.add(_amount);
        }else if(_day==180){
            allInPool3=allInPool3.add(_amount);
        }else if(_day==360){
            allInPool4=allInPool4.add(_amount);
        }else if(_day==720){
            allInPool5=allInPool5.add(_amount);
        }
        return true;
    }

    function _subInPool(uint256 _day,uint _amount) private returns(bool){
        if(_day==30){
            allInPool1=allInPool1.sub(_amount);
        }else if(_day==90){
            allInPool2=allInPool2.sub(_amount);
        }else if(_day==180){
            allInPool3=allInPool3.sub(_amount);
        }else if(_day==360){
            allInPool4=allInPool4.sub(_amount);
        }else if(_day==720){
            allInPool5=allInPool5.sub(_amount);
        }
        return true;
    }

    function token() public view virtual returns (IERC20) {
        return _token;
    }

    function lpLocksForUser(address user) public view returns (Lock[] memory) {
        uint256 length = _userLpLockIds[user].length();
        Lock[] memory userLocks = new Lock[](length);
        for (uint256 i = 0; i < length; i++) {
        userLocks[i] = locks[_userLpLockIds[user].at(i)];
        }
        return userLocks;
    }

    

    

    function getPledgeCount(address user) public view returns(uint256){
        return _pledgeCount[user];
    }

    function getUserInPool(address user) public view returns(uint256){
        return _userInPool[user];
    }

    function lpLockCountForUser(address user) public view returns (uint256) {//inpool count
    return _userLpLockIds[user].length();
  }

   function openIsLock() public  onlyOwner {
        isLock=false;
    }

    function closeIsLock() public  onlyOwner {
        isLock=true;
    }

    function setUnlocked() public  onlyOwner {
        unlocked=1;
    }

    function getItemPool() public  view returns(uint256[5] memory) {
        uint256[5] memory res=[allInPool1,allInPool2,allInPool3,allInPool4,allInPool5];
        return res;
    }

    modifier validLock(uint256 lockId) {
        require(lockId < locks.length, "Invalid lock id");
    _;
  }

  function allLocks() public view returns (Lock[] memory) {
    return locks;
  }

    modifier runSafe() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

   


}