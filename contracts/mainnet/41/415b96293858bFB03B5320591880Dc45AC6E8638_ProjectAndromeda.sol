// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.6;

import "./utils/SafeMath.sol";
import "./interfaces/IERC20.sol";

contract ProjectAndromeda {
    using SafeMath for uint256; 
    uint256 private constant baseDivider = 10000;
    uint256 private constant operationsAllocation = 1000;
    uint256 private constant holdingsAllocation = 3500;
    uint256 private constant minDeposit = 10e18;
    uint256 private constant maxDeposit = 5000e18;
    uint256 private constant baseDeposit = 1000e18;
    uint256 private constant splitPercents = 2100;
    uint256 private constant splitFeePercents = 1000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 30 days; 
    uint256 private constant dayRewardPercents = 150;
    uint256 private constant maxAddFreeze = 30 days;    
    uint256 private constant referDepth = 15;
    uint256[15] private invitePercents = [500, 100, 200, 300, 100, 100, 100, 100, 100, 100, 50, 50, 50, 50, 50];
    uint256[5] private levelDeposit = [100e18, 1000e18, 2000e18, 3000e18, 5000e18];
    uint256[5] private levelInvite = [0, 10000e18, 20000e18, 30000e18, 100000e18];
    uint256[5] private levelTeam = [0, 30, 50, 100, 300];
    uint256[3] private balReached = [1000000e18, 5000000e18, 8000000e18];
    uint256[3] private balFreezeStatic = [700000e18, 300000e18, 500000e18];
    uint256[3] private balFreezeDynamic = [400000e18, 1500000e18, 2000000e18];
    uint256[3] private balRecover = [1500000e18, 5000000e18, 2000000e18];
    uint256 private constant poolPercents = 50;
    uint256 private constant luckMinDeposit = 100e18;
    uint256 private constant maxSearchDepth = 3000;
    IERC20 private stakedToken;
    address private multiSig;
    address private holdings;
    uint256 private startTime;
    uint256 private lastDistribute;
    uint256 private totalUsers;
    uint256 private luckPool;
    mapping(uint256=>uint256) private dayNewbies;
    mapping(uint256=>uint256) private dayDeposit;
    mapping(uint256=>address[]) private dayLuckUsers;
    mapping(uint256=>uint256[]) private dayLuckUsersDeposit;
    address[] private depositors;
    mapping(uint256=>bool) private balStatus;
    bool private freezeStaticReward;
    bool private freezeDynamicReward;

    struct UserInfo {
        address referrer;
        uint256 level;
        uint256 maxDeposit;
        uint256 maxDepositable;
        uint256 teamNum;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
        uint256 unfreezeIndex;
        bool unfreezedDynamic;
    }

    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 invited;
        uint256 level5Freezed;
        uint256 level5Released;
        uint256 luckWin;
        uint256 split;
    }

    struct OrderInfo {
        uint256 amount;
        uint256 start;
        uint256 unfreeze;
        bool isUnfreezed;
    }
    
    mapping(address=>UserInfo) private userInfo;
    mapping(address=>RewardInfo) private rewardInfo;
    mapping(address=>OrderInfo[]) private orderInfos;
    mapping(address=>mapping(uint256=>uint256)) private userCycleMax;
    mapping(address=>mapping(uint256=>address[])) private teamUsers;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, uint256 subBal, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);
    event DistributePoolRewards(uint256 day, uint256 time);

    constructor(address _stakedToken, address _multiSig, address _holdings, uint256 _startTime) {
        stakedToken = IERC20(_stakedToken);
        holdings = _holdings;
        multiSig = _multiSig;
        startTime = _startTime;
        lastDistribute = _startTime;
    }

    function register(address _referral) external {
        require(userInfo[_referral].referrer == address(0), "Cannot set referrer after first deposit");
        UserInfo storage user = userInfo[msg.sender];
        user.referrer = _referral;
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external {
        stakedToken.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount, true);
        emit Deposit(msg.sender, _amount);
    }

    function depositBySplit(uint256 _amount) external {
        require(userInfo[msg.sender].maxDeposit == 0, "actived");
        require(rewardInfo[msg.sender].split >= _amount, "insufficient split");
        rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(_amount);
        _deposit(msg.sender, _amount, false);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(address _receiver, uint256 _amount) external {
        uint256 subBal = _amount.add(_amount.mul(splitFeePercents).div(baseDivider));
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "Amount Error");
        require(rewardInfo[msg.sender].split >= subBal, "Insufficient Split Amount");
        rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(subBal);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, subBal, _receiver, _amount);
    }

    function withdraw() external {
        (uint256 withdrawable, uint256 split) = _calCurRewards(msg.sender);
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        userRewards.statics = 0;
        userRewards.invited = 0;
        userRewards.level5Released = 0;
        userRewards.luckWin = 0;
        userRewards.split = userRewards.split.add(split);
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        stakedToken.transfer(msg.sender, withdrawable);
        uint256 bal = stakedToken.balanceOf(address(this));
        _setFreezeReward(bal);
        emit Withdraw(msg.sender, withdrawable);
    }

    function distributePoolRewards() external {
        if (block.timestamp >= lastDistribute.add(timeStep)){
            uint256 dayNow = getCurDay();
            _distributeLuckPool(dayNow.sub(1));
            lastDistribute = startTime.add(dayNow.mul(timeStep));
            emit DistributePoolRewards(dayNow, lastDistribute);
        }
    }

    function _deposit(address _userAddr, uint256 _amount, bool _isLuckable) private {
        require(block.timestamp >= startTime, "Not Started");
        UserInfo storage user = userInfo[_userAddr];
        require(user.referrer != address(0), "Not Registered");
        require(_amount >= minDeposit && _amount <= maxDeposit && _amount.mod(minDeposit) == 0, "Amount Error");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "Amount too small");
        uint256 curCycle = getCurCycle();
        uint256 userCurMax = userCycleMax[msg.sender][curCycle];
        if (userCurMax == 0) {
            if (curCycle == 0 || user.maxDepositable == 0) {
                userCurMax = baseDeposit;
            } else {
                userCurMax = user.maxDepositable;
            }
            userCycleMax[msg.sender][curCycle] = userCurMax;
        }
        require(_amount <= userCurMax, "Amount Too Much");
        _distributeDeposit(_amount);
        if (_amount == userCurMax) {
            if (userCurMax >= maxDeposit) {
                userCycleMax[msg.sender][curCycle.add(1)] = maxDeposit;
            } else {
                userCycleMax[msg.sender][curCycle.add(1)] = userCurMax.add(baseDeposit);
            }
        } else {
            userCycleMax[msg.sender][curCycle.add(1)] = userCurMax;
        }
        user.maxDepositable = userCycleMax[msg.sender][curCycle.add(1)];
        uint256 dayNow = getCurDay();
        bool isNewbie;
        if (user.maxDeposit == 0) {
            isNewbie = true;
            user.maxDeposit = _amount;
            dayNewbies[dayNow] = dayNewbies[dayNow].add(1);
            totalUsers = totalUsers.add(1);
            if (_isLuckable && _amount >= luckMinDeposit && dayLuckUsers[dayNow].length < 10) {
                dayLuckUsers[dayNow].push(_userAddr);
                dayLuckUsersDeposit[dayNow].push(_amount);
            }
        } else if (_amount > user.maxDeposit) {
            user.maxDeposit = _amount;
        }
        user.totalFreezed = user.totalFreezed.add(_amount);
        uint256 addFreeze = (orderInfos[_userAddr].length).mul(timeStep);
        if (addFreeze > maxAddFreeze) {
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_userAddr].push(OrderInfo(_amount, block.timestamp, unfreezeTime, false));
        dayDeposit[dayNow] = dayDeposit[dayNow].add(_amount);
        depositors.push(_userAddr);
        _unfreezeCapitalOrReward(msg.sender, _amount);
        _updateUplineReward(msg.sender, _amount);
        _updateTeamInfos(msg.sender, _amount, isNewbie);
        _updateLevel(msg.sender);
        uint256 bal = stakedToken.balanceOf(address(this));
        _balActived(bal);
        if (freezeStaticReward || freezeDynamicReward) {
            _setFreezeReward(bal);
        } else if (user.unfreezedDynamic) {
            user.unfreezedDynamic = false;
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        uint256 opsAmount = _amount.mul(operationsAllocation).div(baseDivider);
        stakedToken.transfer(multiSig, opsAmount);
        uint256 holdingAmount = _amount.mul(holdingsAllocation).div(baseDivider);
        stakedToken.transfer(holdings, holdingAmount);
        uint256 poolAmount = _amount.mul(poolPercents).div(baseDivider);
        luckPool = luckPool.add(poolAmount);
    }

    function _updateLevel(address _userAddr) private {
        UserInfo storage user = userInfo[_userAddr];
        for (uint256 i = user.level; i < levelDeposit.length; i++){
            if (user.maxDeposit >= levelDeposit[i]) {
                (uint256 maxTeam, uint256 otherTeam) = getTeamDeposit(_userAddr);
                if (maxTeam >= levelInvite[i] && otherTeam >= levelInvite[i] && user.teamNum >= levelTeam[i]){
                    user.level = i + 1;
                }
            }
        }
    }

    function _unfreezeCapitalOrReward(address _userAddr, uint256 _amount) private {
        UserInfo storage user = userInfo[_userAddr];
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        OrderInfo storage order = orderInfos[_userAddr][user.unfreezeIndex];
        if (order.isUnfreezed == false && block.timestamp >= order.unfreeze && _amount >= order.amount) {
            order.isUnfreezed = true;
            user.unfreezeIndex = user.unfreezeIndex.add(1);
            _removeInvalidDeposit(_userAddr, order.amount);
            uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);
            if (freezeStaticReward) {
                if (user.totalFreezed > user.totalRevenue){
                    uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                    if (staticReward > leftCapital) {
                        staticReward = leftCapital;
                    }
                } else {
                    staticReward = 0;
                }
            }
            userRewards.capitals = userRewards.capitals.add(order.amount);
            userRewards.statics = userRewards.statics.add(staticReward);
            user.totalRevenue = user.totalRevenue.add(staticReward);
        } else if (userRewards.level5Freezed > 0) {
            uint256 release = _amount;
            if (_amount >= userRewards.level5Freezed) {
                release = userRewards.level5Freezed;
            }
            userRewards.level5Freezed = userRewards.level5Freezed.sub(release);
            userRewards.level5Released = userRewards.level5Released.add(release);
            user.totalRevenue = user.totalRevenue.add(release);
        } else if (freezeStaticReward && !user.unfreezedDynamic) {
            user.unfreezedDynamic = true;
        }
    }

    function _removeInvalidDeposit(address _userAddr, uint256 _amount) private {
        uint256 totalFreezed = userInfo[_userAddr].totalFreezed;
        userInfo[_userAddr].totalFreezed = totalFreezed > _amount ? totalFreezed.sub(_amount) : 0;
        address upline = userInfo[_userAddr].referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit > _amount ? userInfo[upline].teamTotalDeposit.sub(_amount) : 0;
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _updateTeamInfos(address _userAddr, uint256 _amount, bool _isNewbie) private {
        address upline = userInfo[_userAddr].referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                if (_isNewbie && _userAddr != upline) {
                    userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                    teamUsers[upline][i].push(_userAddr);
                }
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _updateUplineReward(address _userAddr, uint256 _amount) private {
        address upline = userInfo[_userAddr].referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                if (!freezeStaticReward || userInfo[upline].totalFreezed > userInfo[upline].totalRevenue || (userInfo[upline].unfreezedDynamic && !freezeDynamicReward)) {
                    uint256 newAmount;
                    if (orderInfos[upline].length > 0) {
                        OrderInfo storage latestUpOrder = orderInfos[upline][orderInfos[upline].length.sub(1)];
                        uint256 maxFreezing = latestUpOrder.unfreeze > block.timestamp ? latestUpOrder.amount : 0;
                        if (maxFreezing < _amount) {
                            newAmount = maxFreezing;
                        } else {
                            newAmount = _amount;
                        }
                    }
                    
                    if (newAmount > 0) {
                        RewardInfo storage upRewards = rewardInfo[upline];
                        if (userInfo[upline].level > i || userInfo[upline].level == 5) {
                            uint256 reward = newAmount.mul(invitePercents[i]).div(baseDivider);
                            if (i < 4) {
                                upRewards.invited = upRewards.invited.add(reward);
                                userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                            } else {
                                upRewards.level5Freezed = upRewards.level5Freezed.add(reward);
                            }
                        }
                    }
                }
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _balActived(uint256 _bal) private {
        for (uint256 i = balReached.length; i > 0; i--) {
            if (_bal >= balReached[i - 1]) {
                balStatus[balReached[i - 1]] = true;
                break;
            }
        }
    }

    function _setFreezeReward(uint256 _bal) private {
        for (uint256 i = balReached.length; i > 0; i--) {
            if (balStatus[balReached[i - 1]]) {
                if (_bal < balFreezeStatic[i - 1]) {
                    freezeStaticReward = true;
                    if (_bal < balFreezeDynamic[i - 1]) {
                        freezeDynamicReward = true;
                    }
                } else {
                    if ((freezeStaticReward || freezeDynamicReward) && _bal >= balRecover[i - 1]) {
                        freezeStaticReward = false;
                        freezeDynamicReward = false;
                    }
                }
                break;
            }
        }
    }

    function _calCurRewards(address _userAddr) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        uint256 totalRewards = userRewards.statics.add(userRewards.invited).add(userRewards.level5Released);
        uint256 splitAmt = totalRewards.mul(splitPercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
    }

    function _distributeLuckPool(uint256 _lastDay) private {
        uint256 luckTotalDeposits;
        for (uint256 i = 0; i < dayLuckUsers[_lastDay].length; i++) {
            luckTotalDeposits = luckTotalDeposits.add(dayLuckUsersDeposit[_lastDay][i]);
        }

        uint256 totalReward;
        for (uint256 i = 0; i < dayLuckUsers[_lastDay].length; i++) {
            uint256 reward = luckPool.mul(dayLuckUsersDeposit[_lastDay][i]).div(luckTotalDeposits);
            totalReward = totalReward.add(reward);
            rewardInfo[dayLuckUsers[_lastDay][i]].luckWin = rewardInfo[dayLuckUsers[_lastDay][i]].luckWin.add(reward);
            userInfo[dayLuckUsers[_lastDay][i]].totalRevenue = userInfo[dayLuckUsers[_lastDay][i]].totalRevenue.add(reward);
        }
        luckPool = luckPool > totalReward ? luckPool.sub(totalReward) : 0;
    }

    function getLuckInfos(uint256 _day) external view returns(address[] memory, uint256[] memory) {
        return(dayLuckUsers[_day], dayLuckUsersDeposit[_day]);
    }

    function getTeamDeposit(address _userAddr) public view returns(uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for (uint256 i = 0; i < teamUsers[_userAddr][0].length; i++) {
            uint256 userTotalTeam = userInfo[teamUsers[_userAddr][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_userAddr][0][i]].totalFreezed);
            totalTeam = totalTeam.add(userTotalTeam);
            if (userTotalTeam > maxTeam) {
                maxTeam = userTotalTeam;
            }
            if (i >= maxSearchDepth) {
                break;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getCurCycle() public view returns(uint256) {
        uint256 curCycle = (block.timestamp.sub(startTime)).div(dayPerCycle);
        return curCycle;
    }

    function getDayInfos(uint256 _day) external view returns(uint256, uint256){
        return (dayNewbies[_day], dayDeposit[_day]);
    }

    function getUserInfos(address _userAddr) external view returns(UserInfo memory, RewardInfo memory, OrderInfo[] memory) {
        return (userInfo[_userAddr], rewardInfo[_userAddr], orderInfos[_userAddr]);
    }

    function getBalInfos(uint256 _bal) external view returns(bool, bool, bool) {
        return(balStatus[_bal], freezeStaticReward, freezeDynamicReward);
    }

    function getTeamUsers(address _userAddr, uint256 _layer) external view returns(address[] memory) {
        return teamUsers[_userAddr][_layer];
    }

    function getUserCycleMax(address _userAddr, uint256 _cycle) external view returns(uint256){
        return userCycleMax[_userAddr][_cycle];
    }

    function getDepositors() external view returns(address[] memory) {
        return depositors;
    }

    function getContractInfos() external view returns(address[2] memory, uint256[5] memory) {
        address[2] memory infos0;
        infos0[0] = address(stakedToken);
        infos0[1] = multiSig;

        uint256[5] memory infos1;
        infos1[0] = startTime;
        infos1[1] = lastDistribute;
        infos1[2] = totalUsers;
        infos1[3] = luckPool;
        uint256 dayNow = getCurDay();
        infos1[4] = dayDeposit[dayNow];
        return (infos0, infos1);
    }
}

// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.6;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.6;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}