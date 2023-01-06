/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

abstract contract SignVerify {

    function splitSignature(bytes memory sig)
        internal
        pure
        returns(uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        internal
        pure
        returns(address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        return ecrecover(hash, v, r, s);
    }

    function toString(address account)
        public
        pure 
        returns(string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data)
        internal
        pure
        returns(string memory) 
    {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() 
    {   _status = _NOT_ENTERED;     }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused()
        public 
        view 
        virtual 
        returns (bool) 
    {   return _paused;     }

    modifier whenNotPaused(){
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause()
        internal 
        virtual 
        whenNotPaused 
    {
      _paused = true;
      emit Paused(_msgSender());
    }

    function _unpause() 
        internal 
        virtual 
        whenPaused 
    {
      _paused = false;
      emit Unpaused(_msgSender());
    }
}

contract LockStaking is Ownable, SignVerify, Pausable, ReentrancyGuard{

    using SafeMath for uint256; 
    IERC20 public LSToken;

    uint256 private constant feePercents = 300; 
    uint256 private constant minDeposit = 10e18;
    uint256 private constant baseDivider = 10000;

    uint256 private constant timeStep = 1 minutes;
 
    uint256 private constant dayCycle_100 = 300;
    uint256 private constant dayCycle_200 = 600;
    uint256 private constant dayCycle_400 = 900;
    uint256 private constant dayCycle_600 = 1200;

    uint256 public  Percents_100 = 20;
    uint256 public  Percents_200 = 35;
    uint256 public  Percents_400 = 45;
    uint256 public  Percents_600 = 55;

    uint256 private constant referDepth = 10;
    uint256 private constant directPercents = 500;
    uint256[20] private ROIlevel = [800, 500, 400, 300, 200, 100, 100, 100, 200, 200];

    address public feeReceivers;

    uint256 private Card_100 = 5;
    uint256 private Card_200 = 10;
    uint256 private Card_400 = 15;
    uint256 private Card_600 = 20;
    /////////////////////////////////////////////////////////////////////////////

    address public defaultRefer;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 

    struct OrderInfo {
        uint256 amount;
        uint256 cardDays;
        uint256 start;
        uint256 unStakeTime; 
        bool isUnStake;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    address[] public depositors;

    struct UserInfo {
        address referrer;
        uint256 start;
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 totalDepositAmount;
        uint256 teamNum;
        uint256 directsNum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalStake_100;
        uint256 totalStake_200;
        uint256 totalStake_400;
        uint256 totalStake_600;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardInfo {
        uint256 directs;
     
        uint256 total_Rewards;
    }
    ///  Lavel 
    mapping(address=>mapping(uint256=>uint256)) public _totalUser; // User Count 
    mapping(address=>mapping(uint256=>uint256)) public _totalUserAmount; // User Amount 
    mapping(address=>mapping(address=>mapping(uint256=>bool))) public _userAddressVerification; // User verifications
    mapping(address => uint256) public countUser;
    mapping(address => uint256) public countUser1;
    mapping(address => mapping(uint256 => address)) public UserAdress;
    mapping(address => mapping(uint256 => uint256)) public UserDepoisteamount;
    mapping(address=>mapping(address=>bool)) public _userAddressVerforDirects;
    mapping(address => RewardInfo) public rewardInfo;
    mapping(address => uint256) public withdraw_Reward_100;
    mapping(address => uint256) public withdraw_Reward_200;
    mapping(address => uint256) public withdraw_Reward_400;
    mapping(address => uint256) public withdraw_Reward_600;
    

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount, uint256 FTMamount);

    constructor()
    {
        LSToken = IERC20(0x5163CB4B3402c70fA1814448D6343C2215c6A716);
        feeReceivers = 0xf8F76f766B39420019E4301ca7949279302D1A90;
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = 0xc2E3aDdd10F6C48082Ac8173B864dd304930E6d8;
    }

    function register(address _referral) public {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;
        userInfo[user.referrer].directsNum = userInfo[user.referrer].directsNum.add(1);
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _tokenAmount, uint256 _cardTime)  
    external
    nonReentrant
    whenNotPaused
    {
        require(msg.sender == tx.origin," External Err ");
        require(_cardTime == dayCycle_100 
        || _cardTime == dayCycle_200
        || _cardTime == dayCycle_400
        || _cardTime == dayCycle_600
        );

        LSToken.transferFrom(msg.sender, address(this), _tokenAmount);
        _deposit(msg.sender,_tokenAmount, _cardTime);
    }

    function _deposit(address _user, uint256 _tokenAmount, uint256 cardTime) private {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_tokenAmount >= minDeposit, "less than min");

        if(user.maxDeposit == 0){
            user.maxDeposit = _tokenAmount;
        }else if(user.maxDeposit < _tokenAmount){
            user.maxDeposit = _tokenAmount;
        }

        depositors.push(_user);
        if(cardTime == dayCycle_100)
        {
            user.totalStake_100 = user.totalStake_100.add(_tokenAmount);
        }
        else if(cardTime == dayCycle_200)
        {
            user.totalStake_200 = user.totalStake_200.add(_tokenAmount);
        }
        else if(cardTime == dayCycle_400)
        {
            user.totalStake_400 = user.totalStake_400.add(_tokenAmount);
        }
        else if(cardTime == dayCycle_600)
        {
            user.totalStake_600 = user.totalStake_600.add(_tokenAmount);
        }
        
        user.totalDeposit = totalDeposite(_user);

        user.totalDepositAmount += _tokenAmount;

        uint256 unfreezeTime = block.timestamp.add(cardTime);
        orderInfos[_user].push(OrderInfo(
            _tokenAmount,
            cardTime,
            block.timestamp, 
            unfreezeTime,
            false
        ));

        _updateReferInfo(_user, _tokenAmount);

        _updateDirects(_user, _tokenAmount);

        _updateUserLevelInfo(_user, _tokenAmount);

        UpdateDirectsInfo(_user);

        updateReferral(_user);
    }

    mapping(address => mapping(uint256 => uint256)) public userCount;
    mapping(address => mapping(uint256 => mapping(uint256 => address))) public userReferral;
    mapping(address => mapping(address => mapping(uint256 => bool))) public userReferralVerification;
    mapping(address => uint256) public rewardReceived;
    function updateReferral(address _user) public
    {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 1; i <= referDepth; i++){
            if(upline != address(0))
            {
                if(!userReferralVerification[upline][_user][i])
                { 
                userCount[upline][i] += 1;
                uint256 counts = userCount[upline][i];
                userReferral[upline][i][counts] = _user;
                userReferralVerification[upline][_user][i] = true;
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }
    function UpdateROI(address users) view public returns(uint256)
    {
        uint256[10] memory rewardsTotal;
        uint256 sum = 0;
        for(uint256 _levels = 1; _levels <= referDepth ; _levels++)
        {
            rewardsTotal[_levels-1] = UpdateROIInfo(users,_levels);
        }
        // uint256[] memory UpdateROIInfomation = UpdateROIInfo(users);
        for(uint256 j = 0; j < referDepth; j++)
        {  sum = sum.add(rewardsTotal[j]);  }

        sum = sum.sub(rewardReceived[users]);
        return sum;
    }
    function UpdateROIInfo(address users, uint256 levels) public 
    view returns (uint256) {
        uint256 _amounts;
        uint256 totalday;
        uint256 reward;
        // for(uint256 levels = 1; levels <= referDepth ; levels++)
        // {
             uint256 countsUser = userCount[users][levels];
            for(uint256 userlevels = 1; userlevels <= countsUser ; userlevels++)
            {
                address useraddress = userReferral[users][levels][userlevels];
                for(uint256 i = 0; i < orderInfos[useraddress].length; i++)
                {
                    OrderInfo storage order = orderInfos[useraddress][i];
                    if(order.cardDays == dayCycle_100)
                    {
                        _amounts = (order.amount.mul(ROIlevel[levels-1])).div(baseDivider);
                        _amounts = _amounts.div(5);
                         totalday = getTotalDay(order.start);
                        if( totalday > Card_100)
                        {    totalday = Card_100;   }
                        reward += totalday.mul(_amounts);
                    }
                    else if(order.cardDays == dayCycle_200)
                    {
                        _amounts = (order.amount.mul(ROIlevel[levels-1])).div(baseDivider);
                        _amounts = _amounts.div(10);
                         totalday = getTotalDay(order.start);
                        if( totalday > Card_200)
                        {    totalday = Card_200;   }
                        reward += totalday.mul(_amounts);
                    }
                    else if(order.cardDays == dayCycle_400)
                    {
                        _amounts = (order.amount.mul(ROIlevel[levels-1])).div(baseDivider);
                        _amounts = _amounts.div(15);
                         totalday = getTotalDay(order.start);
                        if( totalday > Card_400)
                        {    totalday = Card_400;   }
                        reward += totalday.mul(_amounts);
                    }
                    else if(order.cardDays == dayCycle_600)
                    {
                        _amounts = (order.amount.mul(ROIlevel[levels-1])).div(baseDivider);
                        _amounts = _amounts.div(20);
                         totalday = getTotalDay(order.start);
                        if( totalday > Card_600)
                        {    totalday = Card_600;   }
                        reward += totalday.mul(_amounts);
                    }
                }
            }
        // }
        return reward;
    }

    function totalDeposite(address user1) public view returns(uint256)
    {
        UserInfo storage user = userInfo[user1];
        uint256 TotalDeposites= user.totalStake_100.add(user.totalStake_200).add(user.totalStake_400).add(user.totalStake_600);
        return  TotalDeposites;
    }
    function _updateUserLevelInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(!_userAddressVerification[_user][upline][i])
                {
                _totalUser[upline][i] += 1;
                _userAddressVerification[_user][upline][i] = true;
                }
                _totalUserAmount[upline][i] += _amount;
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function getRewards(address _user) public 
    view returns(uint256 _reward_100,uint256 _reward_200,uint256 _reward_400,uint256 _reward_600)
    {
        (uint256 _reward_1000,uint256 _reward_2000, uint256 _reward_4000,uint256 _reward_6000) =  UpdateRewards(_user);
        _reward_1000 = _reward_1000.sub(withdraw_Reward_100[_user]);
        _reward_2000 = _reward_2000.sub(withdraw_Reward_200[_user]);
        _reward_4000 = _reward_4000.sub(withdraw_Reward_400[_user]);
        _reward_6000 = _reward_6000.sub(withdraw_Reward_600[_user]);

        // _withdrawable = _withdrawable.sub(withdraw_Reward[_user]);
        return (_reward_1000, _reward_2000,  _reward_4000,_reward_6000);
    }
   
    function withdraw(uint256 withdrwa_cardTime) external {
        uint256 totalReward;

        require(withdrwa_cardTime == dayCycle_100 
        || withdrwa_cardTime == dayCycle_200 
        || withdrwa_cardTime == dayCycle_400
        || withdrwa_cardTime == dayCycle_600,"Invalid Card Time");
        
        (uint256 rewards_100,uint256 rewards_200, uint256 rewards_400,uint256 rewards_600)= getRewards(msg.sender);
        if(withdrwa_cardTime == dayCycle_100)
        {
            withdraw_Reward_100[msg.sender] = withdraw_Reward_100[msg.sender] + rewards_100;
            totalReward = rewards_100;
        }else if(withdrwa_cardTime == dayCycle_200)
        {
            withdraw_Reward_200[msg.sender] = withdraw_Reward_200[msg.sender] + rewards_200;
            totalReward = rewards_200;
        }else if(withdrwa_cardTime == dayCycle_400)
        {
            withdraw_Reward_400[msg.sender] = withdraw_Reward_400[msg.sender] + rewards_400;
            totalReward = rewards_400;
        }else if(withdrwa_cardTime == dayCycle_600)
        {
            withdraw_Reward_600[msg.sender] = withdraw_Reward_600[msg.sender] + rewards_600;
            totalReward = rewards_600;
        }

        RewardInfo storage upRewards = rewardInfo[msg.sender];
        uint256 calwithdrwable = totalReward;
        upRewards.total_Rewards += calwithdrwable;

        uint256 feeDeduction = calwithdrwable.mul(feePercents).div(baseDivider);
        calwithdrwable = calwithdrwable.sub(feeDeduction);

        _feeAfterReward(feeDeduction);
        require(calwithdrwable > 0, "Error");
        LSToken.transfer(msg.sender,  calwithdrwable);
    }
    
    function withdrawDirectsandROI() external
    {   

        uint256 TotalROI = UpdateROI(msg.sender);
        rewardReceived[msg.sender] += TotalROI;
        RewardInfo storage upRewards = rewardInfo[msg.sender];
        uint256 calwithdrwable1 = upRewards.directs.add(TotalROI);

        uint256 feeDeduction = calwithdrwable1.mul(feePercents).div(baseDivider);
        calwithdrwable1 = calwithdrwable1.sub(feeDeduction);

        _feeAfterReward(feeDeduction);
        require(calwithdrwable1 > 0, "Error");
        LSToken.transfer(msg.sender,  calwithdrwable1);

        upRewards.directs = 0;
        // upRewards.countDirectsUser = 0;
        // upRewards.totalTeamAmount = 0;
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

    function getMaxFreezing(address _user) public view returns(uint256) {
        uint256 maxFreezing;
        for(uint256 i = orderInfos[_user].length; i > 0; i--){
            OrderInfo storage order = orderInfos[_user][i - 1];
            if(order.unStakeTime > block.timestamp){
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
            if(userTotalTeam > maxTeam)
            {
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    function _updateTeamNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
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
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function getTotalDay(uint256 _day) public view returns(uint256) {
        return (block.timestamp.sub(_day)).div(timeStep);
    }
    mapping(address => uint256) public totalreward_100;
    
    function UpdateRewards(address users) private 
    view returns (uint256 _reward_100,uint256 _reward_200, uint256 _reward_400,uint256 _reward_600 ) {
        uint256 _amounts;
        uint256 totalday;
        uint256 reward;
        uint256 reward_100;
        uint256 reward_200;
        uint256 reward_400;
        uint256 reward_600;

        for(uint256 i = 0; i < orderInfos[users].length; i++){
            OrderInfo storage order = orderInfos[users][i];
            if(order.cardDays == dayCycle_100)
            {
                _amounts = (order.amount.mul(Percents_100)).div(baseDivider);
                totalday = getTotalDay(order.start);
                if( totalday > Card_100)
                {    totalday = Card_100;   }
                reward = totalday.mul(_amounts);
                reward_100 += reward;  
            }
            else if(order.cardDays == dayCycle_200)
            {
                _amounts = (order.amount.mul(Percents_200)).div(baseDivider);
                totalday = getTotalDay(order.start);
                if( totalday > Card_200)
                {    totalday = Card_200;   }
                reward = totalday.mul(_amounts);
                reward_200 += reward; 
            }
            else if(order.cardDays == dayCycle_400)
            {
                _amounts = (order.amount.mul(Percents_400)).div(baseDivider);
                totalday = getTotalDay(order.start);
                if( totalday > Card_400)
                {    totalday = Card_400;   }
                reward = totalday.mul(_amounts);
                reward_400 += reward; 
            }
           else if(order.cardDays == dayCycle_600)
            {
                _amounts = (order.amount.mul(Percents_600)).div(baseDivider);
                totalday = getTotalDay(order.start);
                if( totalday > Card_600)
                {    totalday = Card_600;   }
                reward = totalday.mul(_amounts);
                reward_600 += reward; 
            }
        }
        return (reward_100,reward_200,reward_400,reward_600);
    }
    function _feeAfterReward(uint256 _tokenAmount) private {

        if(_tokenAmount > 0)
        {
            LSToken.transfer(feeReceivers, _tokenAmount);
        }
    }
    function _updateDirects(address _user, uint256 _amount) private{
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
            if(upline != address(0))
            {
                uint256 newAmount = _amount;
                RewardInfo storage upRewards = rewardInfo[upline];
                uint256 reward;
                reward = newAmount.mul(directPercents).div(baseDivider);
                upRewards.directs = upRewards.directs.add(reward);
            }
    }

    function UpdateDirectsInfo(address _user) private{
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
            if(upline != address(0))
            {
                if(!_userAddressVerforDirects[_user][upline])
                {
                countUser1[upline] += 1; 
                countUser[_user] = countUser1[upline];
                _userAddressVerforDirects[_user][upline] = true;
                }
                UserAdress[upline][countUser[_user]] = _user;
                UserDepoisteamount[upline][countUser[_user]] = totalDeposite(_user);
            }
    }
    
    function unstake(uint256 Unstake_cardTime) public
    {
        UserInfo storage user = userInfo[msg.sender];
        for(uint256 i = 0; i < orderInfos[msg.sender].length; i++){
            OrderInfo storage order = orderInfos[msg.sender][i];
            if(dayCycle_100 == Unstake_cardTime)
            {
                if(order.cardDays == dayCycle_100)
                {
                    if(!order.isUnStake)
                    {
                        uint256 totalday = getTotalDay(order.start);
                        if( totalday > Card_100)
                        {
                            user.totalStake_100 = user.totalStake_100.sub(order.amount);
                            LSToken.transfer(msg.sender, order.amount);
                            UpdateDirectsInfo(msg.sender);
                            order.isUnStake = true;
                        }
                    }
                }
            }
            if(dayCycle_200 == Unstake_cardTime)
            {
                if(order.cardDays == dayCycle_200)
                {
                    if(!order.isUnStake)
                    {
                        uint256 totalday = getTotalDay(order.start);
                        if( totalday > Card_200)
                        {
                            user.totalStake_200 = user.totalStake_200.sub(order.amount);
                            LSToken.transfer(msg.sender, order.amount);
                            UpdateDirectsInfo(msg.sender);
                            order.isUnStake = true;
                        }
                    }
                }
            }
            if(dayCycle_400 == Unstake_cardTime)
            {
                if(order.cardDays == dayCycle_400)
                {
                    if(!order.isUnStake)
                    {
                        uint256 totalday = getTotalDay(order.start);
                        if( totalday > Card_400)
                        {
                            user.totalStake_400 = user.totalStake_400.sub(order.amount);
                            LSToken.transfer(msg.sender, order.amount);
                            UpdateDirectsInfo(msg.sender);
                            order.isUnStake = true;
                            
                        }
                    }
                }
            }
            if(dayCycle_600 == Unstake_cardTime)
            {
                if(order.cardDays == dayCycle_600)
                {
                    if(!order.isUnStake)
                    {
                        uint256 totalday = getTotalDay(order.start);
                        if( totalday > Card_600)
                        {
                            user.totalStake_600 = user.totalStake_600.sub(order.amount);
                            LSToken.transfer(msg.sender, order.amount);
                            UpdateDirectsInfo(msg.sender);
                            order.isUnStake = true;
                        }
                    }
                }
            }
        }
    }

    function withdrawLSToken(uint256 _count)
    public
    onlyOwner
    {   LSToken.transfer(owner(),_count);   }

    function emergancyWithdrawLSToken()
    public
    onlyOwner
    {   LSToken.transfer(owner(),LSToken.balanceOf(address(this)));  }

    function pauseContract()
    public
    onlyOwner
    {       _pause();   }

    function unPauseContract()
    public
    onlyOwner 
    {       _unpause();     }
}