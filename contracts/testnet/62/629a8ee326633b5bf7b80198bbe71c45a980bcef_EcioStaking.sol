// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import './Math.sol';
import './TransferHelper.sol';
import './IERC20.sol';

contract EcioStaking {
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
    uint256 public totalAmount;

    address public rewardToken;
    address public adminAddress;
    // Reward tokens created per Sec.
    uint256 public rewardRate;
    
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    mapping(address => mapping (address => uint256)) allowed;
    address[] public userList;
    uint private unlocked = 1;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Reward(address indexed user, uint256 amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    constructor(
        address _lpToken,
        address _rewardToken,
        uint256 _rewardRate
    ) public {
        adminAddress = msg.sender;
        lpToken = _lpToken;
        rewardToken = _rewardToken;
        rewardRate = _rewardRate;
        totalAmount = 0;
    }

    function lockedPeriod(uint256 lockDay) public returns (uint256) {
        return lockDay * 24 * 3600;
    }

    function setAdmin(address _adminAddress) public {
        require(adminAddress == msg.sender, "not Admin");
        adminAddress = _adminAddress;
    }

    function stakedLp() public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.amount;
    }

    function multiplier() public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        if(user.lockedDay == 30) return 1;
        if(user.lockedDay == 60) return 2;
        if(user.lockedDay == 90) return 3;
        if(user.lockedDay == 120) return 4;
    }

    function stakingPeriod() public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.lockedDay;
    }

    function earnEcio() public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.rewarded;
    }

    function lockDate() public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        return user.lastDepositTimeStamp;
    }

    function stakingStatus() public view returns (bool) {
        UserInfo storage user = userInfo[msg.sender];
        if(user.lastDepositTimeStamp + user.lockedDay > block.timestamp) return false;
        else return true;
    }

    function approve(uint256 numTokens) public returns (bool) {
        allowed[msg.sender][address(this)] = numTokens;
        emit Approval(msg.sender, address(this), numTokens);
        return true;
    }

    function updatePool() internal {
        for (uint i = 0; i < userList.length; i++) {
            UserInfo storage user = userInfo[userList[i]];
            uint256 lastTimeStamp = block.timestamp;
            uint256 accDebt = lastTimeStamp.sub(user.lastCalculatedTimeStamp).mul(rewardRate).mul(1e18) / totalAmount;
            user.rewardDebt = user.rewardDebt.add(accDebt);
            user.lastCalculatedTimeStamp = lastTimeStamp;
        }
    }

    function deposit(uint256 amount, uint256 lockedDay) public {
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
            user.lockedDay = lockedDay;            
        } else {
            user.amount = user.amount + amount;
            user.lastDepositTimeStamp = block.timestamp;
            user.lockedDay = lockedDay;
        }
        totalAmount = totalAmount + amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.lastDepositTimeStamp > 0, "invalid user");
        require(user.amount > 0, "not staked");
        require(user.lastDepositTimeStamp + lockedPeriod(user.lockedDay) < block.timestamp, "you are in lockedTime.");
        updatePool();
        TransferHelper.safeTransfer(lpToken, msg.sender, user.amount);
        totalAmount = totalAmount - user.amount;
        user.amount = 0;
        user.rewarded = user.rewarded + user.rewardDebt;
        user.rewardDebt = 0;
        emit Withdraw(msg.sender, user.amount);
    }

    function reward() public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        uint amount = user.rewardDebt;
        require(amount > 0, "not enough reward amount");
        user.rewarded = user.rewarded + amount;
        user.rewardDebt = 0;
        TransferHelper.safeTransfer(rewardToken, msg.sender, amount);
        emit Reward(msg.sender, amount);
    }
}