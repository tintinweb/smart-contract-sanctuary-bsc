/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeMath {
    
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract USBT is Ownable{

    using SafeMath for uint256; 
    IERC20 public BUSD;

    uint256 private constant feePercents = 1000; 
    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 2500e18;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private freezeIncomePercents2 = 7000;
    uint256 public maxEarn = 3;

    uint256 private constant baseDivider = 10000;

    // uint256 private constant timeStep = 1 days;
    // uint256 private dayPerCycle = 10 days;
    
    uint256 private constant timeStep = 5 minutes;
    uint256 private dayPerCycle = 15 minutes;
    uint256 private daysCycle1 = 5;


    // uint256 private constant dayReward2Percents = 200000000000000000000;
    // uint256 private constant dayRewardPercents = 150000000000000000000;

    uint256 private constant dayReward2Percents = 666670000000000000000;
    uint256 private constant dayRewardPercents = 500000000000000000000;

    uint256 private constant maxAddFreeze = 10 days;
    uint256 private constant referDepth = 15;

    uint256 private constant directPercents = 1000;

    uint256 private constant diamondPoolPercents = 100;
    
    uint256 private directsPercentage = 200;
    uint256 private constant doubleDiamondPoolPercents = 100;

    // uint256 public daysCycle = 5 minutes;
    uint256 public totalCycles = 50;

    uint256 public level1Income = 600;
    uint256[4] public level4Percents = [300, 200, 100, 100];
    uint256[10] public level5Percents = [500, 100, 100, 100, 100, 50, 50, 50, 50,50];

    uint256[5] private balDown = [10e10, 30e10, 100e10, 500e10, 1000e10];
    uint256[5] private balDownRate = [1000, 1500, 2000, 5000, 6000]; 
    uint256[5] private balRecover = [15e10, 50e10, 150e10, 500e10, 1000e10];
    mapping(uint256=>bool) public balStatus;

    address public defaultRefer;
    uint256 public boosterDay = 2;  //  10
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
    uint256 public diamond;
    uint256 public doubleDiamond;
    uint256 public directPoolReward;

    mapping(address => uint256) public boosterUserTime;
    mapping(address => uint256) private userROI;

    address[] public level4Users;
    address[] public level5Users;
    address[] public boosterIncomeUSers;
    address public founderFee;

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
        uint256 level; // 0, 1, 2, 3, 4, 5
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 teamNum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    mapping(address => mapping(uint256 => uint256)) public staticReward1;
    mapping(uint256 => uint256) public dailyDeposit;

    struct RewardInfo {
        uint256 statics;
        uint256 directs;
        uint256 diamond;
        uint256 doubleDiamond;
        uint256 level1ROIIncome;
        uint256 level4ROIIncome;
        uint256 level5ROIIncome;
        uint256 directPool;
        uint256 split;
        uint256 splitDebt;
        uint256 totalWithdrawls;
    }
    mapping(address => RewardInfo) public rewardInfo;
    mapping(address => address[]) public directUsers;

    address[] public directIncomeUSers;
    uint256 userCount = 10;
    uint256 usersMinDept = 500000000000000000000;

    uint256 public currentDay;

    bool public isFreezeReward;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(){
        BUSD = IERC20(0x15f32E98dAa2951815a4005Bf725fF9bD04b1287);
        founderFee = 0xf6f2Bd97D33EAB1cFa78028d4e518823B9158430;
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        currentDay = getCurDay();
        defaultRefer = 0xf6f2Bd97D33EAB1cFa78028d4e518823B9158430;
    }

    function register(address _referral) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        directUsers[_referral].push(msg.sender);
        user.start = block.timestamp;
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external {
        BUSD.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function depositBySplit(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient split");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        _deposit(msg.sender, _amount);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(address _receiver, uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient income");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }

    function distributePoolRewards() private {
        if(block.timestamp > lastDistribute.add(timeStep))
        {
            _distributediamond();
            _distributedoubleDiamond();
            lastDistribute = block.timestamp;
        }
    }

    function withdraw() external {
        distributePoolRewards();
        uint256 roiReward = getROIRewards(msg.sender);
        ROILevelIncome(roiReward);

        (uint256 withdrawable, uint256 splitAmt, uint256 ROI_reward) = totalRewards(msg.sender);

        userROI[msg.sender] += ROI_reward;
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        userRewards.split = userRewards.split.add(splitAmt);
        userRewards.directs = 0;
        
        userRewards.diamond = 0;
        userRewards.doubleDiamond = 0;

        userRewards.level4ROIIncome = 0;
        userRewards.level5ROIIncome  =0;
        userRewards.level1ROIIncome =0;
        userRewards.directPool  = 0;

        
        BUSD.transfer(msg.sender, withdrawable);
        userRewards.totalWithdrawls = (userRewards.totalWithdrawls).add(withdrawable.add(splitAmt));

        uint256 bal = BUSD.balanceOf(address(this));
        _setFreezeReward(bal);

        emit Withdraw(msg.sender, withdrawable);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
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

    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam)
            {
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    function getCurSplit(address _user) public view returns(uint256){
        (, uint256 staticSplit, ) = totalRewards(_user);
        return rewardInfo[_user].split.add(staticSplit).sub(rewardInfo[_user].splitDebt);
    }

    function getROIRewards(address _user) public view returns(uint256)
    {
        uint256 TotalROI;
        for(uint256 i = 0; i < orderInfos[_user].length; i++)
        {
        (,,,,uint256 getROI_) = getROI(_user, i);
        TotalROI += getROI_;
        }
        return TotalROI.sub(userROI[_user]);
    }

    function getROI(address _user,uint256 _index) public 
    view 
    returns(uint256,uint256,uint256,uint256,uint256)
    {
        uint256 sum;
        uint256 dayIncreament;
        uint256 totalDays;
        uint256 days_;
        uint256 remainingTime;
        OrderInfo storage order = orderInfos[_user][_index];
        days_ = getCurDay1(order.start);
        for(uint256 j = 1; j <= 9; j++)
        {
            dayIncreament = daysCycle1 + daysCycle1.mul(j);
            totalDays += dayIncreament;
            if(totalDays <= days_)
            {
                sum += staticReward1[_user][_index];
            }
            else{
                break;
            }
        }
        remainingTime = dayIncreament.sub(days_);
        return (remainingTime,dayIncreament,totalDays,days_,sum);
    }

    function getCurDay1(uint256 _time) private view returns(uint256){
        return (block.timestamp.sub(_time)).div(60);  // 60 => 1 day
    }

    function totalRewards(address _user) public 
    view 
    returns(uint256, uint256, uint256)
    {
        RewardInfo storage userRewards = rewardInfo[_user];
        UserInfo storage user = userInfo[_user];

        uint256 ROI_reward = getROIRewards(_user);
        uint256 totalRewards_ = userRewards.directs;
        totalRewards_ = totalRewards_.add(userRewards.diamond.add(userRewards.doubleDiamond)
        .add(userRewards.totalWithdrawls).add(userRewards.directPool).add(ROI_reward));

        totalRewards_ = totalRewards_.add(userRewards.level4ROIIncome
        .add(userRewards.level5ROIIncome).add(userRewards.level1ROIIncome));

        uint256 amount3X = (user.totalDeposit).mul(maxEarn);
        uint256 remainingReward;
        uint256 remaings;
        uint256 withdrawable;
        uint256 splitAmt;

        if(totalRewards_ > amount3X){
            uint256 withdrawable1;
            uint256 withdrawable2;
            if(userRewards.totalWithdrawls > amount3X)
            {
                remainingReward = totalRewards_.sub(userRewards.totalWithdrawls);
                splitAmt = (remainingReward.mul(freezeIncomePercents2)).div(baseDivider);
                withdrawable = remainingReward.sub(splitAmt);
            }
            else
            {
                remainingReward = totalRewards_.sub(amount3X);
                uint256 splitAmt1 = (remainingReward.mul(freezeIncomePercents2)).div(baseDivider);
                withdrawable1 = remainingReward.sub(splitAmt1);
                remaings = amount3X.sub(userRewards.totalWithdrawls) ;
                uint256 splitAmt2 = remaings.mul(freezeIncomePercents).div(baseDivider);
                withdrawable2 = remaings.sub(splitAmt2);
                withdrawable = withdrawable1.add(withdrawable2);
                splitAmt = (splitAmt1).add(splitAmt2);
            }
        }
        else{
            uint256 remainingValue = totalRewards_.sub(userRewards.totalWithdrawls);
            splitAmt = remainingValue.mul(freezeIncomePercents).div(baseDivider);
            withdrawable = remainingValue.sub(splitAmt);
        }
        return (withdrawable, splitAmt, ROI_reward);
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
            if(levelNow == 5){
                level5Users.push(_user);
            }
        }
    }

    function _calLevelNow(address _user) private view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.totalDeposit;
        uint256 levelNow;
        if(total >= 1000e18){
            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
            if(total >= 2000e18 && maxTeam >= 2000e18 && otherTeam >= 2000e18){   // max/other 25000
                levelNow = 5;
            }else if(maxTeam >= 1500e18 && otherTeam >= 1500e18){   // other/max 10000
                levelNow = 4;
            }else{
                levelNow = 3;
            }
        }else if(total >= 500e18){
            levelNow = 2;
        }else if(total >= 100e18){
            levelNow = 1;
        }

        return levelNow; 
    }

    function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount <= maxDeposit, "greater than max");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require((user.totalDeposit).add(_amount) <= maxDeposit,"should be less");
        boosterUserTime[_user] = getCurDay();
        (bool _isAvailable,) = boosterIncomeIsReady(user.referrer);
        (bool _isDirectAvailable,) = directIncomeIsReady(user.referrer);
        
        if(user.maxDeposit == 0){
            user.maxDeposit = _amount;
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
        }

        _distributeDeposit(_amount);

        depositors.push(_user);
        
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);

        _updateLevel(msg.sender);

         uint256 unfreezeTime = block.timestamp.add(timeStep).add(timeStep);
        orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp,
            unfreezeTime,
            false
        ));

        _unfreezeFundAndUpdateReward(msg.sender, _amount);

        distributePoolRewards();
        uint256 curDay = getCurDay();
        if(currentDay < curDay)
        {
            _distributeDirectPool();
            currentDay = curDay;
        }

        _updateReferInfo(msg.sender, _amount);

        _updateReward(msg.sender, _amount);

        if(getBoosterTeamDeposit(user.referrer) && getTimeDiffer(user.referrer) <= boosterDay ){
            if(!_isAvailable)
            {boosterIncomeUSers.push(user.referrer);}
        }

        (bool isCompleted,) = checkDirects(user.referrer);
        if(isCompleted){
            if(!_isDirectAvailable)
            {  directIncomeUSers.push(user.referrer); }
        }

        uint256 bal = BUSD.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }

    function checkDirects(address _upline) public view returns(bool, uint256){
        uint256 count_;
        for(uint256 i; i < (directUsers[_upline].length); i++){
            address user_ = directUsers[_upline][i];
            if((userInfo[user_].totalDeposit) >= usersMinDept){
                count_ ++;
            }
        }
        if(count_ >= userCount){  return (true, count_);  }
        else {  return (false, count_); }
    }

    function claimROIReward() public{
        uint256 staticReward;
    
        for(uint256 i = 0; i < orderInfos[msg.sender].length; i++){
            OrderInfo storage order = orderInfos[msg.sender][i];
            (bool _isAvailable,) = boosterIncomeIsReady(msg.sender);
            if(block.timestamp > order.unfreeze && order.isUnfreezed == false)
            {
                order.isUnfreezed = true;
                if(_isAvailable == true)
                {
                 staticReward = (order.amount.mul(dayReward2Percents).mul(dayPerCycle).div(timeStep).div(baseDivider)).div(1e18);
                 staticReward1[msg.sender][i] = staticReward;
                }
                else
                {
                 staticReward = (order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider)).div(1e18);
                 staticReward1[msg.sender][i] = staticReward;
                }

                break;
            }
        }
    }

    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount) private{
        uint256 staticReward;

        for(uint256 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i];
            (bool _isAvailable,) = boosterIncomeIsReady(_user);
            if(block.timestamp > order.unfreeze && order.isUnfreezed == false && _amount >= order.amount)
            {
                order.isUnfreezed = true;
                if(_isAvailable == true)
                {
                 staticReward = (order.amount.mul(dayReward2Percents).mul(dayPerCycle).div(timeStep).div(baseDivider)).div(1e18);
                 staticReward1[msg.sender][i] = staticReward;
                }
                else
                {
                 staticReward = (order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider)).div(1e18);
                 staticReward1[msg.sender][i] = staticReward;
                }
                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);

                break;
            }
        }
    }
  
    function _distributediamond() private {
        uint256 level4Count;
        for(uint256 i = 0; i < level4Users.length; i++){
            if(userInfo[level4Users[i]].level == 4){
                level4Count = level4Count.add(1);
            }
        }
        if(level4Count > 0){
            uint256 reward = diamond.div(level4Count);
            uint256 totalReward;
            for(uint256 i = 0; i < level4Users.length; i++){
                if(userInfo[level4Users[i]].level == 4){
                    rewardInfo[level4Users[i]].diamond = rewardInfo[level4Users[i]].diamond.add(reward);
                    userInfo[level4Users[i]].totalRevenue = userInfo[level4Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(diamond > totalReward){
                diamond = diamond.sub(totalReward);
            }else{
                diamond = 0;
            }
        }
    }

    function _distributeDirectPool() private {

        uint256 directCount;
        for(uint256 i = 0; i < directIncomeUSers.length; i++){
            directCount = directCount.add(1);
        }
        uint256 curTime = getCurDay();
        if(directCount > 0){
            uint256 reward = dailyDeposit[curTime-1].div(directCount);
            uint256 totalReward;
            for(uint256 i = 0; i < directIncomeUSers.length; i++){
                rewardInfo[directIncomeUSers[i]].directPool = rewardInfo[directIncomeUSers[i]].directPool.add(reward);
                userInfo[directIncomeUSers[i]].totalRevenue = userInfo[directIncomeUSers[i]].totalRevenue.add(reward);
                totalReward = totalReward.add(reward);
            }
            if(directPoolReward > totalReward){
                directPoolReward = directPoolReward.sub(totalReward);
            }else{
                directPoolReward = 0;
            }
        }
    }

    function _distributedoubleDiamond() private {

        uint256 level5Count;
        for(uint256 i = 0; i < level5Users.length; i++){
            if(userInfo[level5Users[i]].level == 5){
                level5Count = level5Count.add(1);
            }
        }
        if(level5Count > 0){
            uint256 reward = doubleDiamond.div(level5Count);
            uint256 totalReward;
            for(uint256 i = 0; i < level5Users.length; i++){
                if(userInfo[level5Users[i]].level == 5){
                    rewardInfo[level5Users[i]].doubleDiamond = rewardInfo[level5Users[i]].doubleDiamond.add(reward);
                    userInfo[level5Users[i]].totalRevenue = userInfo[level5Users[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(doubleDiamond > totalReward){
                doubleDiamond = doubleDiamond.sub(totalReward);
            }else{
                doubleDiamond = 0;
            }
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        BUSD.transfer(founderFee, fee);
        uint256 diamond_ = _amount.mul(diamondPoolPercents).div(baseDivider);
        diamond = diamond.add(diamond_);
        uint256 doubleDiamond_ = _amount.mul(doubleDiamondPoolPercents).div(baseDivider);
        doubleDiamond = doubleDiamond.add(doubleDiamond_);
        uint256 upline_ = _amount.mul(directsPercentage).div(baseDivider);
        uint256 curTime = getCurDay();
        dailyDeposit[curTime] += upline_;
    }

    function _updateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        if(upline != address(0)){
            uint256 newAmount = _amount;
            RewardInfo storage upRewards = rewardInfo[upline];
            uint256 reward;
            reward = newAmount.mul(directPercents).div(baseDivider);
            upRewards.directs = upRewards.directs.add(reward);
            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
        }
    }

    function _balActived(uint256 _bal) private {
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

    function getBoosterTeamDeposit(address _user) public view returns(bool) {
        uint256 count;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            if((userInfo[teamUsers[_user][0][i]].totalDeposit) >= ((userInfo[_user].totalDeposit).mul(2))){
                count +=1;
            }
        }
        if(count >= 1){
            return true;
        }
        return false;
    }

    function getTimeDiffer(address _user) public view returns(uint256){
        uint256 newTime = getCurDay();
        newTime = newTime.sub(boosterUserTime[_user]);
        return newTime;
    }

    function boosterIncomeIsReady(address _address) public view returns(bool,uint256)
    {
        for (uint256 i = 0; i < boosterIncomeUSers.length; i++){
            if (_address == boosterIncomeUSers[i]){
            return (true,i);
            } 
        }
        return (false,0);
    }

    function directIncomeIsReady(address _address) public view returns(bool,uint256)
    {
        for (uint256 i = 0; i < directIncomeUSers.length; i++){
            if (_address == directIncomeUSers[i]){
            return (true,i);
            } 
        }
        return (false,0);
    }

    function Mint(uint256 _count) public onlyOwner {
        BUSD.transfer(owner(),_count);
    }

    function ChangeBoosterCondition(uint256 _num) public onlyOwner{
        boosterDay = _num;
    }

    function ROILevelIncome(uint256 _amount) private {
        UserInfo storage user = userInfo[msg.sender];
        address upline = user.referrer;
            for(uint256 i = 0; i < 9; i++){
                uint256 newAmount = _amount;

                if(upline != address(0)){
                RewardInfo storage upRewards = rewardInfo[upline];
                uint256 reward;
                if(i > 4){
                    if(userInfo[upline].level > 4){
                        reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);
                        upRewards.level5ROIIncome = upRewards.level5ROIIncome.add(reward);
                    }
                }else if(i > 0){
                    if( userInfo[upline].level > 3){
                        reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);
                        upRewards.level4ROIIncome = upRewards.level4ROIIncome.add(reward);
                    }
                }else{
                    reward = newAmount.mul(level1Income).div(baseDivider);
                    upRewards.level1ROIIncome = upRewards.level1ROIIncome.add(reward);
                    userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

}