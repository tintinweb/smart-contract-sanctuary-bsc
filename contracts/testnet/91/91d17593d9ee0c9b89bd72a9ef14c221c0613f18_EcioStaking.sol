// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import './SafeMath.sol';
import './TransferHelper.sol';
import './Ownable.sol';
import './IERC20.sol';

contract EcioStaking is Ownable {
    using SafeMath  for uint;

    struct UserInfo {
        uint256 amount;
        uint256 rewarded;
        uint256 rewardDebt;
        uint256 lastCalculatedTimeStamp;
        uint256 lastDepositTimeStamp;
    }

    // pool info
    address public lpToken;
    uint256 public totalAmount;
    uint256 public lastRewardTimeStamp;

    uint256 private REWARD_PER_DAY = 1 * 1e6 * 1e18; // 1,000,000, ecio per day


    address public rewardToken;
    address public adminAddress;
    // Reward tokens created per Sec.
    
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    address[] public userList;
    uint256 public lockedTime = 60 * 24 * 3600; // 30days
    uint private unlocked = 1;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Reward(address indexed user, uint256 amount);

    constructor(
        address _lpToken,
        address _rewardToken
    ) public {
        adminAddress = msg.sender;
        lpToken = _lpToken;
        rewardToken = _rewardToken;
        totalAmount = 0;
        _transferOwnership(msg.sender);
    }

    //change reward token address
    function updateRewardTokenAddress(address _address) public onlyOwner {
        rewardToken = _address;
    }
    
    //change Lp token address
    function updateLpTokenAddress(address _address) public onlyOwner {
        lpToken = _address;
    }

    //user number
    function userCounter() public view returns (uint256) {
        return userList.length;
    }

    //user address
    function userAddress(uint256 userNum) public view returns (address) {
        return userList[userNum];
    }

    //user staked amount
    function userStakedLpAmount(uint256 userNum) public view returns (uint256) {
        UserInfo storage user = userInfo[userList[userNum]];
        return user.amount;
    }

    //reward amount
    function ecioClaimPossibleAmout(address _useraddress) public view returns (uint256) {
        UserInfo storage user = userInfo[_useraddress];
        uint256 lastTimeStamp = block.timestamp;
        uint256 virtualRewardAmount = 0;
        uint256 virtualActiveMinute = (lastTimeStamp - user.lastCalculatedTimeStamp) / (1 minutes);
        virtualRewardAmount = (virtualActiveMinute * user.amount * REWARD_PER_DAY) / (totalAmount * 24 * 60);
        return user.rewardDebt + virtualRewardAmount;
    }

    //total staked Lp Token amount
    function totalLpTokenAmount() public view returns (uint256) {
        return totalAmount;
    }

    //user claim status(possible or impossible)
    function userPossibleClaimReturner(address _useraddress) public view returns (bool) {
        UserInfo storage user = userInfo[_useraddress];
        if(user.lastDepositTimeStamp + 10 minutes < block.timestamp) return true;
        else return false;
    }

    //user claim period
    function userClaimPeriod(address _useraddress) public view returns (uint256) {
        UserInfo storage user = userInfo[_useraddress];
        if(user.lastDepositTimeStamp + 60 days < block.timestamp) return block.timestamp - 60 days;
        else return 0;
    }

    //update pool
    function updatePool() internal {
        for (uint i = 0; i < userList.length; i++) {
            UserInfo storage user = userInfo[userList[i]];
            uint256 lastTimeStamp = block.timestamp;
            uint256 rewardedMinutes = (lastTimeStamp - user.lastCalculatedTimeStamp) / 1 minutes;
            uint256 accDebt = rewardedMinutes * REWARD_PER_DAY * user.amount / (totalAmount * 24 * 60);
            user.rewardDebt = user.rewardDebt.add(accDebt);
            user.lastCalculatedTimeStamp = user.lastCalculatedTimeStamp + rewardedMinutes * 1 minutes;
        }
    }

    function stake(uint256 amount) public {
        require(amount > 0, "invaild amount");
        TransferHelper.safeTransferFrom(lpToken, msg.sender, address(this), amount);
        UserInfo storage user = userInfo[msg.sender];
        bool isFirst = true;
        for (uint i = 0; i < userList.length; i++) {
            if (userList[i] == msg.sender) {
                isFirst = false;
            }
        }
        updatePool();
        if (isFirst) {
            userList.push(msg.sender);
            user.amount = amount;
            user.rewarded = 0;
            user.rewardDebt = 0;
            user.lastDepositTimeStamp = block.timestamp;
            user.lastCalculatedTimeStamp = block.timestamp;            
        } else {
            user.amount = user.amount + amount;
            user.lastDepositTimeStamp = block.timestamp;
            user.lastCalculatedTimeStamp = block.timestamp;
        }
        totalAmount = totalAmount + amount;
        emit Deposit(msg.sender, amount);
    }

    function deleteBlock() internal {
        bool isUser = false;
        for(uint256 i = 0 ; i < userList.length - 1 ; i ++){
            if(userList[i] == msg.sender){
                isUser = true;
                continue;
            }
            if(isUser == false) {
                continue;
            }
            userList[i] = userList[i + 1];
        }
        userList.pop();
    }

    function unStake() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.lastDepositTimeStamp > 0, "invalid user");
        require(user.amount > 0, "not staked");
        updatePool();
        TransferHelper.safeTransfer(lpToken, msg.sender, user.amount);
        totalAmount = totalAmount - user.amount;
        deleteBlock();
        emit Withdraw(msg.sender, user.amount);
    }

    function claim() public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        uint amount = user.rewardDebt;
        require(amount > 0, "not enough reward amount");
        require(user.lastDepositTimeStamp + 10 minutes < block.timestamp, "You are in lockedTime");
        user.rewarded = user.rewarded + amount;
        user.rewardDebt = 0;
        TransferHelper.safeTransfer(rewardToken, msg.sender, amount);
        emit Reward(msg.sender, amount);
    }

    function transferToken(address _contractAddress, address _to, uint256 _amount) external onlyOwner {
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(_to, _amount);
    }
}