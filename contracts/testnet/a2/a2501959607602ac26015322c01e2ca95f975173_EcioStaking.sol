// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
// import './Math.sol';
import './SafeMath.sol';
import './TransferHelper.sol';
import './IERC20.sol';
import './Ownable.sol';
// import 'hardhat/console.sol';

contract EcioStaking is Ownable {
    using SafeMath  for uint;

    struct UserInfo {
        uint256 amount;
        uint256 rewarded;
        uint256 rewardDebt;
        uint256 lastCalculatedTimeStamp;
        uint256 lastDepositTimeStamp;
        uint256 lockedDay;
    }

    // pool info
    address public lpToken;
    // IERC20 lpToken;
    uint256 public totalAmount;

    address public rewardToken;
    address public adminAddress;
    // Reward tokens created per Sec.
    uint256 public rewardRate;
    

    uint256 public totalAmountLockDay;
    // Info of each user that stakes LP tokens.
    // mapping (address => UserInfo) public userInfo;
    mapping (address => mapping (uint => UserInfo)) public userInfo;
    mapping(address => mapping (address => uint256)) allowed;
    address[] public userList;
    mapping(address => uint) public userlistNum;
    mapping(address => mapping (uint => bool)) public userLockStatus;
    uint private unlocked = 1;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Reward(address indexed user, uint256 amount);

    constructor(
        address _lpToken,
        // IERC20 _lpToken,
        address _rewardToken
    ) public {
        adminAddress = msg.sender;
        lpToken = _lpToken;
        rewardToken = _rewardToken;
        totalAmount = 0;
        totalAmountLockDay = 0;
        _transferOwnership(msg.sender);
    }

    function updateRewardTokenAddress(address _address) public onlyOwner {
        rewardToken = _address;
    }

    function updateLpTokenAddress(address _address) public onlyOwner {
        lpToken = _address;
    }

    function userStakingCounter(address _useraddress) public view returns (uint256) {
        return userlistNum[_useraddress];
    }

    function userCounter() public view returns (uint256) {
        return userList.length;
    }

    function useraddress(uint256 userNum) public view returns (address) {
        return userList[userNum];
    }

    function stakedLp(uint userStakingNum) public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender][userStakingNum];
        return user.amount;
    }

    function multiplier(uint256 lockDays) public view returns (uint256) {
        if(lockDays == 30) return 10;
        if(lockDays == 60) return 15;
        if(lockDays == 90) return 20;
        if(lockDays == 120) return 30;
        if(lockDays == 240) return 40;
        if(lockDays == 360) return 50;
    }

    function stakingPeriod(uint userStakingNum) public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender][userStakingNum];
        return user.lockedDay;
    }

    function earnEcio(address _useraddress ,uint userStakingNum) public view returns (uint256) {
        UserInfo storage user = userInfo[_useraddress][userStakingNum];
        uint256 lastTimeStamp = block.timestamp;
        uint256 virtualRewardAmount = 0;
        if(user.lastCalculatedTimeStamp + 1 days < lastTimeStamp){
            uint256 virtualActiveDay = ((lastTimeStamp - user.lastCalculatedTimeStamp) / (1 days));
            uint256 virtualRewardAmount = (virtualActiveDay * user.amount * multiplier(user.lockedDay) * (1e6) * (1e18)) / totalAmountLockDay;
            
            return user.rewarded + virtualRewardAmount;
            // user.rewardDebt = user.rewardDebt.add(accDebt);
            // user.lastCalculatedTimeStamp = lastTimeStamp;
        }
        else return user.rewarded + virtualRewardAmount;
    }

    function lockDate(address _useraddress ,uint userStakingNum) public view returns (uint256) {
        UserInfo storage user = userInfo[_useraddress][userStakingNum];
        return user.lastDepositTimeStamp;
    }

    function stakingStatus(uint userStakingNum) public view returns (bool) {
        UserInfo storage user = userInfo[msg.sender][userStakingNum];
        if(user.lastDepositTimeStamp + user.lockedDay * 1 days > block.timestamp) return false;
        else return true;
    }

    function userLockStatusReturner(uint userStakingNum) public view returns (bool) {
        return userLockStatus[msg.sender][userStakingNum];
    }

    function unlock(uint userEcioBalance, uint userStakingNum) public {
        require(userEcioBalance > 150, "Amount not enough");
        TransferHelper.safeTransferFrom(lpToken, msg.sender, address(this), 150);
        userLockStatus[msg.sender][userStakingNum] = false;
    }

    function updatePool() public {
        for(uint i = 0 ; i < userList.length ; i ++){
            for(uint j = 0 ; j < userlistNum[userList[i]] ; j ++){
                UserInfo storage user = userInfo[userList[i]][j];
                uint256 lastTimeStamp = block.timestamp;
                if(user.lastCalculatedTimeStamp + 1 days < lastTimeStamp){
                    uint256 realActiveDay = (lastTimeStamp - user.lastCalculatedTimeStamp) / (1 days);
                    uint256 accDebt = (realActiveDay * user.amount * multiplier(user.lockedDay) * (1e6) * (1e18)) / totalAmountLockDay;
                    user.rewardDebt = user.rewardDebt.add(accDebt);
                    user.lastCalculatedTimeStamp = user.lastCalculatedTimeStamp + realActiveDay * (1 days);
                }
            }
        }
    }

    function stake(uint256 amount, uint256 lockDay) public {
        require(amount > 0, "invaild amount");
        TransferHelper.safeTransferFrom(lpToken, msg.sender, address(this), amount);
        // UserInfo storage user = userInfo[msg.sender];
        bool isFirst = true;
        for (uint i = 0; i < userList.length; i++) {
            if (userList[i] == msg.sender) {
                isFirst = false;
            }
        }
        updatePool();
        if (isFirst) {
            UserInfo storage user = userInfo[msg.sender][0];
            userLockStatus[msg.sender][0] = true;
            userlistNum[msg.sender] = 1;
            userList.push(msg.sender);
            user.amount = amount;
            user.rewarded = 0;
            user.rewardDebt = 0;
            user.lastDepositTimeStamp = block.timestamp;
            user.lastCalculatedTimeStamp = block.timestamp;
            user.lockedDay = lockDay;            
        } else {
            UserInfo storage user = userInfo[msg.sender][userlistNum[msg.sender]];
            userLockStatus[msg.sender][userlistNum[msg.sender]] = true;
            userlistNum[msg.sender] = userlistNum[msg.sender] + 1;
            user.amount = user.amount + amount;
            user.lastDepositTimeStamp = block.timestamp;
            user.lastCalculatedTimeStamp = block.timestamp;
            user.lockedDay = lockDay;
        }
        totalAmount = totalAmount + amount;
        totalAmountLockDay = totalAmountLockDay.add(amount * multiplier(lockDay));
        emit Deposit(msg.sender, amount);
    }

    function deleteBlock(uint userStakingNum) internal {
        userlistNum[msg.sender] =userlistNum[msg.sender] - 1;
        bool flag = false;
        if(userlistNum[msg.sender] == 0){
            flag = false;
            for(uint i = 0 ; i < userList.length - 1 ; i ++){
                if(userList[i] == msg.sender){
                    flag = true;
                    continue;
                }
                if(flag == false){
                    continue;
                }
                userList[i] = userList[i + 1];
            }
            userList.pop();
        }
        else{
            flag = false;
            for(uint i = 0 ; i < userlistNum[msg.sender] - 1 ; i ++) {
                if(i == userStakingNum) {
                    flag = true;
                    continue;
                }
                if(flag == false) {
                    continue;
                }
                else{
                    UserInfo storage user = userInfo[msg.sender][i];
                    UserInfo storage user1 = userInfo[msg.sender][i + 1];
                    userLockStatus[msg.sender][i] = true;
                    user.amount = user1.amount;
                    user.rewarded = user1.rewarded;
                    user.rewardDebt = user1.rewardDebt;
                    user.lastDepositTimeStamp = user1.lastDepositTimeStamp;
                    user.lastCalculatedTimeStamp = user1.lastCalculatedTimeStamp;
                    user.lockedDay = user1.lockedDay;
                }
            }
        }
    }

    function withdraw(uint userStakingNum) public {
        UserInfo storage user = userInfo[msg.sender][userStakingNum];
        require(user.lastDepositTimeStamp > 0, "invalid user");
        require(user.amount > 0, "not staked");
        if(userLockStatus[msg.sender][userStakingNum] == true) require(user.lastDepositTimeStamp + user.lockedDay * 1 days < block.timestamp, "you are in lockedTime.");
        updatePool();
        TransferHelper.safeTransfer(lpToken, msg.sender, user.amount);
        totalAmount = totalAmount - user.amount;
        totalAmountLockDay = totalAmountLockDay.sub(user.amount * multiplier(user.lockedDay));
        deleteBlock(userStakingNum);
        emit Withdraw(msg.sender, user.amount);
    }

    function rewardUpdate(uint userStakingNum) public {
        UserInfo storage user = userInfo[msg.sender][userStakingNum];
        updatePool();
        user.rewarded = user.rewarded + user.rewardDebt;
        user.rewardDebt = 0;
    }

    function claim(uint userStakingNum) public {
        UserInfo storage user = userInfo[msg.sender][userStakingNum];
        updatePool();
        uint amount = user.rewardDebt;
        // require(amount > 0, "not enough reward amount");
        user.rewarded = user.rewarded + amount;
        user.rewardDebt = 0;
        TransferHelper.safeTransfer(rewardToken, msg.sender, amount);
        emit Reward(msg.sender, amount);
    }

    function transferToken(address _contractAddress, address _to, uint256 _amount) public onlyOwner {
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(_to, _amount);
    }
}