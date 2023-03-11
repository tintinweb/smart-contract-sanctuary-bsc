/**
 *Submitted for verification at BscScan.com on 2023-03-11
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract FDF {
    using SafeMath for uint256; 
    IERC20 public usdt;
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 200; //手续费百分比（万分之200）
    uint256 private constant minDeposit = 100e18;//最小存款
    uint256 private maxDeposit = 1000e18;//最大存款(初始15天开放1000，16天-30天开放2000， 31天开放4000)
    uint256 private constant freezeIncomePercents = 3000;//冻结百分比（万分之3000）
    uint256 private constant timeStep = 10 minutes;//时间步长
    uint256 private constant dayPerCycle = 30 minutes;//周期天数
    uint256 private constant dayRewardPercents = 150;//奖励百分比（万分之150）
    uint256 private constant maxAddFreeze = 90 minutes;//最大天数
    uint256 private constant referDepth = 10;//团队深度

    uint256 private constant directPercents = 500;//直推奖励的百分比
    uint256[4] private level4Percents = [100, 300, 200, 100];//
    uint256[5] private level5Percents = [200, 200, 100, 200, 100];

    uint256 private constant luckPoolPercents = 50;
    uint256 private constant topPoolPercents = 50;

    address[2] public feeReceivers;//两个手续费接收地址

    address public defaultRefer;//默认地址？
    uint256 public startTime;//开始时间
    uint256 public lastDistribute;//最后分配
    uint256 public totalUser; //所有用户
    uint256 public luckPool;//锁定池
    uint256 public topPool;//top奖

    uint256[3] maxRewardTop = [4000e18, 2000e18, 1000e18];
    uint16[3] ratesTop = [5000, 3000, 2000];

    mapping(uint256=>address[]) public dayLuckUsers;//每天锁定用户
    mapping(uint256=>uint256[]) public dayLuckUsersDeposit;//每天锁定用户存款
    mapping(uint256=>address[3]) public dayTopUsers;//每天top奖用户

    address[] public level4Users;//达到二级奖励的用户

    struct OrderInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos;//用户订单

    address[] public depositors;//储户地址
    uint256[] public depositorsIndex;//储户索引

    struct UserInfo {
        address referrer;//推荐人
        uint256 start;
        uint256 level; // 0, 1, 2, 3, 4, 5
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 teamNum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
    }

    mapping(address => UserInfo) public userInfo;//地址对应用户信息
    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit; // day=>user=>amount
    mapping(address => mapping(uint256 => address[])) public teamUsers;

    mapping(uint256 => mapping(address => uint256)) public topRewardRecord;//TOP奖记录
    mapping(uint256 => mapping(address => uint256)) public luckRewardRecord;//幸运奖记录
    mapping(uint256 => address[]) public luckRewardUser;//每天的幸运奖用户

    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 directs;
        uint256 level4Freezed;
        uint256 level4Released;
        uint256 level5Left;
        uint256 level5Freezed;
        uint256 level5Released;
        uint256 luck;
        uint256 top;
        uint256 split;
        uint256 splitDebt;
    }

    mapping(address=>RewardInfo) public rewardInfo;
    
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    address owner;

    constructor(address _usdtAddr, address _defaultRefer, address[2] memory _feeReceivers) public {
        owner = msg.sender;
        usdt = IERC20(_usdtAddr);
        feeReceivers = _feeReceivers;
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = _defaultRefer;
    }

    //账号注册
    function register(address _referral) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }

    //新增存款
    function deposit(uint256 _amount) external {
        usdt.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    //通过循环账户存款
    function depositBySplit(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient split");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        _deposit(msg.sender, _amount);
        emit DepositBySplit(msg.sender, _amount);
    }

    //通过循环账户转账
    function transferBySplit(address _receiver, uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient income");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }

    //分发奖励
    function distributePoolRewards() private {
        if(block.timestamp > lastDistribute.add(timeStep)){
            uint256 dayNow = getCurDay();

            _distributeLuckPool(dayNow);

            _distributeTopPool(dayNow);
            lastDistribute = block.timestamp;
        }
    }

    //提取奖励
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
        userRewards.level4Released = 0;
        userRewards.level5Released = 0;
        
        userRewards.luck = 0;
        userRewards.top = 0;
        
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        
        usdt.transfer(msg.sender, withdrawable);

        emit Withdraw(msg.sender, withdrawable);
    }

    //获取现在天数
    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    //某天锁定人数
    function getDayLuckLength(uint256 _day) external view returns(uint256) {
        return dayLuckUsers[_day].length;
    }

    //mapping(address => mapping(uint256 => address[])) public teamUsers;
    //团队=>层级=>用户
    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }
    //用户订单数量
    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }
    
    //储户总人数
    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }

    //用户最大冻结
    function getMaxFreezing(address _user) public view returns(uint256) {
        uint256 maxFreezing;
        for(uint256 i = orderInfos[_user].length; i > 0; i--){
            OrderInfo storage order = orderInfos[_user][i - 1];
            if(order.unfreeze > block.timestamp){
                if(order.amount > maxFreezing){
                    maxFreezing = order.amount;
                }
            }else{
                break;
            }
        }
        return maxFreezing;
    }

    //团队业绩
    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam){
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    //用户循环账户可用？
    function getCurSplit(address _user) public view returns(uint256){
        (, uint256 staticSplit) = _calCurStaticRewards(_user);
        (, uint256 dynamicSplit) = _calCurDynamicRewards(_user);
        return rewardInfo[_user].split.add(staticSplit).add(dynamicSplit).sub(rewardInfo[_user].splitDebt);
    }

    function _calCurStaticRewards(address _user) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.statics;
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
    }

    function _calCurDynamicRewards(address _user) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.directs.add(userRewards.level4Released).add(userRewards.level5Released);
        totalRewards = totalRewards.add(userRewards.luck.add(userRewards.top));
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
    }

    //刷新团队人数
    function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    //刷新top奖的用户
    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow) private {
        userLayer1DayDeposit[_dayNow][_user] = userLayer1DayDeposit[_dayNow][_user].add(_amount);
        bool updated;
        for(uint256 i = 0; i < 3; i++){
            address topUser = dayTopUsers[_dayNow][i];
            if(topUser == _user){
                _reOrderTop(_dayNow);
                updated = true;
                break;
            }
        }
        if(!updated){
            address lastUser = dayTopUsers[_dayNow][2];
            if(userLayer1DayDeposit[_dayNow][lastUser] < userLayer1DayDeposit[_dayNow][_user]){
                dayTopUsers[_dayNow][2] = _user;
                _reOrderTop(_dayNow);
            }
        }
    }

    function _reOrderTop(uint256 _dayNow) private {
        for(uint256 i = 3; i > 1; i--){
            address topUser1 = dayTopUsers[_dayNow][i - 1];
            address topUser2 = dayTopUsers[_dayNow][i - 2];
            uint256 amount1 = userLayer1DayDeposit[_dayNow][topUser1];
            uint256 amount2 = userLayer1DayDeposit[_dayNow][topUser2];
            if(amount1 > amount2){
                dayTopUsers[_dayNow][i - 1] = topUser2;
                dayTopUsers[_dayNow][i - 2] = topUser1;
            }
        }
    }

    function _removeInvalidDeposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(userInfo[upline].teamTotalDeposit > _amount){
                    userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.sub(_amount);
                }else{
                    userInfo[upline].teamTotalDeposit = 0;
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateReferInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){
            user.level = levelNow;
            if(levelNow == 4){
                level4Users.push(_user);
            }
        }
    }

    function _calLevelNow(address _user) private view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.totalDeposit;
        uint256 levelNow;
        if(total >= 2000e18){
            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
            if(total >= 4000e18 && user.teamNum >= 100 && maxTeam >= 50000e18 && otherTeam >= 50000e18){
                levelNow = 5;
            }else if(user.teamNum >= 50 && maxTeam >= 20000e18 && otherTeam >= 20000e18){
                levelNow = 4;
            }else{
                levelNow = 3;
            }
        }else if(total >= 1000e18){
            levelNow = 2;
        }else if(total >= 100e18){
            levelNow = 1;
        }

        return levelNow;
    }

    function _deposit(address _user, uint256 _amount) private {
        _updateMaxDeposit();
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount <= maxDeposit, "more than max");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");

        if(user.maxDeposit == 0){
            user.maxDeposit = _amount;
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
            user.maxDirectDeposit = _amount;
        }

        _distributeDeposit(_amount);

        if(user.totalDeposit == 0){
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
        if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false
        ));

        depositorsIndex.push(orderInfos[_user].length-1);

        _unfreezeFundAndUpdateReward(msg.sender, _amount);

        distributePoolRewards();

        _updateReferInfo(msg.sender, _amount);

        _updateReward(msg.sender, _amount);

        _releaseUpRewards(msg.sender, _amount);

    }

    function getMaxDeposit() public view returns(uint256){
        uint256 dayNow = getCurDay();
        if(dayNow > 6){
            return 4000e18;
        }else if(dayNow > 3){
            return 2000e18;
        }
        return 1000e18;
    }

    function _updateMaxDeposit() private {
        uint256 max = getMaxDeposit();
        if (maxDeposit != max){
            maxDeposit = max;
        }
    }

    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        bool isUnfreezeCapital;
        for(uint256 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i];
            if(block.timestamp > order.unfreeze  && order.isUnfreezed == false && _amount >= order.amount){
                order.isUnfreezed = true;
                isUnfreezeCapital = true;
                
                if(user.totalFreezed > order.amount){
                    user.totalFreezed = user.totalFreezed.sub(order.amount);
                }else{
                    user.totalFreezed = 0;
                }
                
                _removeInvalidDeposit(_user, order.amount);

                uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);

                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);

                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);
                
                user.totalRevenue = user.totalRevenue.add(staticReward);

                break;
            }
        }

        if(!isUnfreezeCapital){ 
            RewardInfo storage userReward = rewardInfo[_user];
            if(userReward.level5Freezed > 0){
                uint256 release = _amount;
                if(_amount >= userReward.level5Freezed){
                    release = userReward.level5Freezed;
                }
                userReward.level5Freezed = userReward.level5Freezed.sub(release);
                userReward.level5Released = userReward.level5Released.add(release);
                user.totalRevenue = user.totalRevenue.add(release);
            }
        }
    }

    //每天的幸运奖人数
    function getDayLuckRewardLength(uint256 _day) public view returns(uint256) {
        return luckRewardUser[_day].length;
    }

    //根据天数和索引查找幸运奖用户
    function getDayLuckRewardRecord(uint256 _day, uint256 index) public view returns(address user, uint256 amount){
        user = luckRewardUser[_day][index];
        amount = luckRewardRecord[_day][user];
    }

    function _distributeLuckPool(uint256 _dayNow) private {
        uint256 dayDepositCount = dayLuckUsers[_dayNow - 1].length;
        if(dayDepositCount > 0){
            uint256 checkCount = 10;
            if(dayDepositCount < 10){
                checkCount = dayDepositCount;
            }
            uint256 totalDeposit;
            uint256 totalReward;
            for(uint256 i = dayDepositCount; i > dayDepositCount.sub(checkCount); i--){
                totalDeposit = totalDeposit.add(dayLuckUsersDeposit[_dayNow - 1][i - 1]);
            }

            for(uint256 i = dayDepositCount; i > dayDepositCount.sub(checkCount); i--){
                address userAddr = dayLuckUsers[_dayNow - 1][i - 1];
                if(userAddr != address(0)){
                    uint256 reward = luckPool.mul(dayLuckUsersDeposit[_dayNow - 1][i - 1]).div(totalDeposit);
                    totalReward = totalReward.add(reward);
                    rewardInfo[userAddr].luck = rewardInfo[userAddr].luck.add(reward);
                    userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);

                    //新增幸运奖记录，方便查询
                    luckRewardUser[_dayNow - 1].push(userAddr);
                    luckRewardRecord[_dayNow - 1][userAddr] = reward;
                }
            }
            if(luckPool > totalReward){
                luckPool = luckPool.sub(totalReward);
            }else{
                luckPool = 0;
            }
        }
    }
    // 发放top奖
    function _distributeTopPool(uint256 _dayNow) private {
        
        uint256 totalReward;
        for(uint256 i = 0; i < 3; i++){
            address userAddr = dayTopUsers[_dayNow - 1][i];
            if(userAddr != address(0)){
                uint256 reward = topPool.mul(ratesTop[i]).div(baseDivider);
                if(reward > maxRewardTop[i]){
                    reward = maxRewardTop[i];
                }
                rewardInfo[userAddr].top = rewardInfo[userAddr].top.add(reward);
                userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);
                totalReward = totalReward.add(reward);

                topRewardRecord[_dayNow - 1][userAddr] = reward;
            }
        }
        if(topPool > totalReward){
            topPool = topPool.sub(totalReward);
        }else{
            topPool = 0;
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        usdt.transfer(feeReceivers[0], fee.div(2));
        usdt.transfer(feeReceivers[1], fee.div(2));
        uint256 luck = _amount.mul(luckPoolPercents).div(baseDivider);
        luckPool = luckPool.add(luck);
        uint256 top = _amount.mul(topPoolPercents).div(baseDivider);
        topPool = topPool.add(top);
    }

    function _updateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                uint256 newAmount = _amount;
                if(upline != defaultRefer){
                    uint256 maxFreezing = getMaxFreezing(upline);
                    if(maxFreezing < _amount){
                        newAmount = maxFreezing;
                    }
                }
                RewardInfo storage upRewards = rewardInfo[upline];
                uint256 reward;
                if(i > 4){
                    if(userInfo[upline].level > 4){
                        reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);
                        upRewards.level5Freezed = upRewards.level5Freezed.add(reward);
                    }
                }else if(i > 0){
                    if( userInfo[upline].level > 3){
                        reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);
                        upRewards.level4Freezed = upRewards.level4Freezed.add(reward);
                    }
                }else{
                    reward = newAmount.mul(directPercents).div(baseDivider);
                    upRewards.directs = upRewards.directs.add(reward);
                    userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _releaseUpRewards(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                uint256 newAmount = _amount;
                if(upline != defaultRefer){
                    uint256 maxFreezing = getMaxFreezing(upline);
                    if(maxFreezing < _amount){
                        newAmount = maxFreezing;
                    }
                }

                RewardInfo storage upRewards = rewardInfo[upline];
                if(i > 0 && i < 5 && userInfo[upline].level > 3){
                    if(upRewards.level4Freezed > 0){
                        uint256 level4Reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);
                        if(level4Reward > upRewards.level4Freezed){
                            level4Reward = upRewards.level4Freezed;
                        }
                        upRewards.level4Freezed = upRewards.level4Freezed.sub(level4Reward); 
                        upRewards.level4Released = upRewards.level4Released.add(level4Reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(level4Reward);
                    }
                }

                if(i >= 5 && userInfo[upline].level > 4){
                    if(upRewards.level5Left > 0){
                        uint256 level5Reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);
                        if(level5Reward > upRewards.level5Left){
                            level5Reward = upRewards.level5Left;
                        }
                        upRewards.level5Left = upRewards.level5Left.sub(level5Reward); 
                        upRewards.level5Freezed = upRewards.level5Freezed.add(level5Reward);
                    }
                }
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function kill() public{
        if(msg.sender == owner){
            selfdestruct(msg.sender);
        }
        
    }
 
}