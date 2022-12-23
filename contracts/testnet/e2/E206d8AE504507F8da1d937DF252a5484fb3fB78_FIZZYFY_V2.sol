/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.12;

library SafeMath 
{
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 
{
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FIZZYFY_V2 
{
    using SafeMath for uint256; 
    IERC20 public busd;    
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 200; 
    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 1000e18;
    uint256 private constant splitPercents = 2100;
    uint256 private constant tokenPercents = 900;
    uint256 private constant transferFeePercents = 1000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 15 days; 
    uint256 private constant dayRewardPercents = 100;
    uint256 private constant baseSplitPercents = 3000;
    uint256 private constant baseFundPercents = 7000;
    uint256 private constant maxAddFreeze = 45 days;
    uint256 private constant referDepth = 20;
    uint256 private constant minTokenTransfer = 10e18;
    uint256 private constant userMaxRevenueNoDirect = 20000;
    uint256 private constant userMaxIncome = 30000;

    uint256 private constant directPercents = 500;
    uint256[4] private level4Percents = [100, 200, 200, 100];
    uint256[15] private level5Percents = [100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
    uint256[4] private tokenBonusPercents = [1500, 2000, 2500, 4000];

    uint256 private constant liquidityPoolPercents = 100;
    uint256 private constant InsurancePoolPercents = 100;

    uint256[5] private balDown = [10e22, 30e22, 100e22, 500e22, 1000e22];
    uint256[5] private balDownRate = [1000, 1500, 2000, 5000, 6000]; 
    uint256[5] private balRecover = [15e22, 50e22, 150e22, 500e22, 1000e22];
    mapping(uint256=>bool) public balStatus;

    address public feeReceivers;

    address public defaultRefer;
    address public liquidityAddr;
    address public insuranceAddr;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
    uint256 public liquidityPool;
    uint256 public InsurancePool;
	
    address[] public level4Users;

    struct OrderInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    address[] public depositors;
    address[] public newDepositors;

    struct UserInfo {
        address referrer;
        uint256 start;
        uint256 level;
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 directnum;
        uint256 directBusiness;
        uint256 teamNum;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
        uint256 totalFund;
		bool isactive;
    }

    mapping(address=>UserInfo) public userInfo;
    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit;
    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 directs;
        uint256 level4Freezed;
        uint256 level4Released;
        uint256 level5Left;
        uint256 level5Freezed;
        uint256 level5Released;
        uint256 split;
        uint256 tokenValue;
        uint256 tokenBonus;
    }

    mapping(address => RewardInfo) public rewardInfo;
    
    bool public isFreezeReward;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositFund(address user, uint256 amount);    
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event TransferFund(address user, address receiver, uint256 amount);
    event TransferToken(address user, address receiver, uint256 amount);
    event ExchangeSplitToToken(address user, uint256 amount);

    event Withdraw(address user, uint256 withdrawable);

    constructor() public {
        busd = IERC20(0xD593ef3D4f6121a7a3e470937E650733FD7e1E16);
        feeReceivers = 0x4aa8d0bD99A199DcacbAf4c8FC0AD80649084926;
        liquidityAddr = 0x5e61592E3FcA39951E1f5CeE12081Dff5f46C74a;
        insuranceAddr = 0x0752d31ef8fad7A1cB5db430dD9AE1D03f3378B9;
        startTime = block.timestamp;
        defaultRefer = msg.sender;
        lastDistribute = block.timestamp;
    }

    function register(address _referral) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;        
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external {        
        busd.transferFrom(msg.sender, address(this), _amount);
		_deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function depositFund(uint256 _amount) external {        
        busd.transferFrom(msg.sender, address(this), _amount);
		userInfo[msg.sender].totalFund = userInfo[msg.sender].totalFund.add(_amount);
        emit DepositFund(msg.sender, _amount);
    }

    function transferFund(address _receiver, uint256 _amount) external {
        require(_amount >= minTokenTransfer, "amount err");        
        userInfo[msg.sender].totalFund = userInfo[msg.sender].totalFund.sub(_amount);
        userInfo[_receiver].totalFund = userInfo[_receiver].totalFund.add(_amount);
        emit TransferFund(msg.sender, _receiver, _amount);
    }

    function transferToken(address _receiver, uint256 _amount) external {
        require(_amount >= minTokenTransfer, "amount err"); 
        rewardInfo[msg.sender].tokenValue = rewardInfo[msg.sender].tokenValue.sub(_amount);
        rewardInfo[_receiver].tokenValue = rewardInfo[_receiver].tokenValue.add(_amount);
        emit TransferToken(msg.sender, _receiver, _amount);
    }

    function exchangeSplitToToken(uint256 _amount) external {
        require(_amount >= minTokenTransfer, "amount err"); 
        rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(_amount);
        rewardInfo[msg.sender].tokenValue = rewardInfo[msg.sender].tokenValue.add(_amount);
        emit ExchangeSplitToToken(msg.sender, _amount);
    }
	
	function depositBySplit(uint256 _amount) external {
        require(_amount >= minDeposit, "less than min amount");
        require(_amount <= maxDeposit, "greater than max amount");
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");

        uint256 baseSplitBal = _amount.mul(baseSplitPercents).div(baseDivider);
        uint256 baseFundBal = _amount.mul(baseFundPercents).div(baseDivider);

        require(rewardInfo[msg.sender].split >= baseSplitBal, "insufficient split");
        require(userInfo[msg.sender].totalFund >= baseFundBal, "insufficient fund balance");
        rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(baseSplitBal);
        userInfo[msg.sender].totalFund = userInfo[msg.sender].totalFund.sub(baseFundBal);
        _deposit(msg.sender, _amount);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(address _receiver, uint256 _amount) external {
        uint256 subBal = _amount.add(_amount.mul(transferFeePercents).div(baseDivider));
        require(_amount >= minTokenTransfer && _amount.mod(minTokenTransfer) == 0, "amount err");        
        require(rewardInfo[msg.sender].split >= subBal, "insufficient split");

        rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(subBal);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }
	
	function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min amount");
        require(_amount <= maxDeposit, "greater than max amount");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount <= maxDeposit, "less before");

        if(user.maxDeposit == 0)
        {
            user.maxDeposit = _amount;
			user.isactive = true;
			_updateTeamNum(msg.sender, _amount);
			totalUser = totalUser.add(1); 
            newDepositors.push(_user);
        }
        else if(user.maxDeposit < _amount)
        {
            userInfo[user.referrer].directBusiness = userInfo[user.referrer].directBusiness.add(_amount.sub(user.maxDeposit));  
            user.maxDeposit = _amount;
        }

        _distributeDeposit(_amount);

        depositors.push(_user);
        
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);

        _updateLevel(msg.sender);

        uint256 addFreeze = (orderInfos[_user].length.div(1)).mul(timeStep);
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

        _updateReferInfo(msg.sender, _amount);

        _updateReward(msg.sender, _amount);

        _releaseUpRewards(msg.sender, _amount);

        uint256 bal = busd.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }
	
    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
		uint256 liquidity = _amount.mul(liquidityPoolPercents).div(baseDivider);
		uint256 insurance = _amount.mul(InsurancePoolPercents).div(baseDivider);
        busd.transfer(feeReceivers, fee);
        busd.transfer(liquidityAddr, liquidity);        
        busd.transfer(insuranceAddr, insurance);        
        liquidityPool = liquidityPool.add(liquidity);
        InsurancePool = InsurancePool.add(insurance);
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
        uint256 total = user.maxDeposit;
        uint256 levelNow;
        if(total >= 1000e18){
            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
            if(user.teamNum >= 250 && maxTeam >= 75000e18 && otherTeam >= 75000e18){
                levelNow = 5;
            }else if(user.teamNum >= 50 && maxTeam >= 10000e18 && otherTeam >= 10000e18){
                levelNow = 4;
            }else{
                levelNow = 3;
            }
        }else if(total >= 500e18){
            levelNow = 2;
        }else if(total >= 50e18){
            levelNow = 1;
        }

        return levelNow;
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

	function _updateTeamNum(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        RewardInfo storage upRewards = rewardInfo[upline];
		for(uint256 i = 0; i < 1; i++)
		{
            if(upline != address(0))
			{
                if(userInfo[upline].start < userInfo[upline].start.add(dayPerCycle))
                {
                    if(userInfo[upline].directnum >= 1 && userInfo[upline].directnum < 5 )
                    {
                        uint256 amount = 0;
                        uint256 tokenBonusPos = 0;
                        if(userInfo[upline].maxDeposit > _amount)
                        {
                            amount = _amount;
                        }
                        else
                        {
                            amount = userInfo[upline].maxDeposit;
                        }

                        tokenBonusPos = userInfo[upline].directnum.sub(1);
                        
                        upRewards.tokenValue = upRewards.tokenValue.add(amount.mul(tokenBonusPercents[tokenBonusPos]).div(baseDivider));
                        upRewards.tokenBonus = upRewards.tokenBonus.add(amount.mul(tokenBonusPercents[tokenBonusPos]).div(baseDivider));
                    }
                }
                userInfo[upline].directnum = userInfo[upline].directnum.add(1);
                userInfo[upline].directBusiness = userInfo[upline].directBusiness.add(_amount);
            }
			else
			{
                break;
            }
        }
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
	
	function _updateReferInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;

        for(uint256 i = 0; i < referDepth; i++)
		{
            if(upline != address(0))
			{
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }
			else
			{
                break;
            }
        }
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

    function withdraw() external {
        UserInfo storage user = userInfo[msg.sender];
        uint256 maxRevenue = user.maxDeposit.mul(userMaxRevenueNoDirect).div(baseDivider);
        uint256 maxIncome = user.totalFreezed.mul(userMaxIncome).div(baseDivider);
        bool status = true;
        if(user.totalRevenue > maxIncome)
        {
            status = false;
        }

        if(user.totalRevenue > maxRevenue && user.directnum < 2 && user.directBusiness <= maxRevenue)
        {
            status = false;
        }

        
        
        require(status == true, "max revenue reached with no direct");

        (uint256 withdrawableReward, uint256 staticSplit, uint256 staticToken) = _calCurSplitRewards(msg.sender);
        uint256 splitAmt = staticSplit;
        uint256 tokenAmt = staticToken;
        uint256 withdrawable = withdrawableReward;
        RewardInfo storage userRewards = rewardInfo[msg.sender];
    
        userRewards.split = userRewards.split.add(splitAmt);
        userRewards.tokenValue = userRewards.tokenValue.add(tokenAmt);

        userRewards.statics = 0;

        userRewards.directs = 0;
        
        userRewards.level4Released = 0;
        
        userRewards.level5Released = 0;
        
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        busd.transfer(msg.sender, withdrawable);
        uint256 bal = busd.balanceOf(address(this));
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

    function getNewDepositorsLength() external view returns(uint256) {
        return newDepositors.length;
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
            uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].maxDeposit);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam){
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    function getCurSplit(address _user) public view returns(uint256, uint256){
        (, uint256 staticSplit, uint256 staticToken) = _calCurSplitRewards(_user);
		return(rewardInfo[_user].split.add(staticSplit), rewardInfo[_user].tokenValue.add(staticToken));
    }
    
    function _calCurSplitRewards(address _userAddr) private view returns(uint256, uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        uint256 totalRewards = userRewards.statics.add(userRewards.directs).add(userRewards.level4Released).add(userRewards.level5Released);
        uint256 splitAmt = totalRewards.mul(splitPercents).div(baseDivider);
        uint256 tokenAmt = totalRewards.mul(tokenPercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt).sub(tokenAmt);
        return(withdrawable, splitAmt, tokenAmt);
    }

    function _removeInvalidDeposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0))
			{
                if(userInfo[upline].teamTotalDeposit > _amount)
				{
                    userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.sub(_amount);
                }
				else
				{
                    userInfo[upline].teamTotalDeposit = 0;
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }
			else
			{
                break;
            }
        }
    }
}