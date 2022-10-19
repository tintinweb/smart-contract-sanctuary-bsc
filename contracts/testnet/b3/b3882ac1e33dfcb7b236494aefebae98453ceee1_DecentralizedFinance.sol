/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
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

contract DecentralizedFinance  {
    using SafeMath for uint256; 
    IBEP20 public busd;
    address public contractOwner;
    modifier onlyContractOwner() { 
        require(msg.sender == contractOwner, "onlyOwner"); 
        _; 
    }

    uint256 private constant baseDivider = 10000;              //// denominator ( divided by this to get the percentages)
    uint256 private constant feePercents = 200;             /*2% */
    uint256 private constant minDeposit = 50e18;            /*minimum deposit*/
    uint256 private constant maxDeposit = 10000e18;         /*maximum deposit*/
    uint256 private constant freezeIncomePercents = 2500;   ////25 % will frezze
    uint256 private constant timeStep = 1 minutes;          // basically used to divide by 1 day to get actual values
    uint256 private constant dayPerCycle =7 minutes;       /////cycle duration is 10 MINUTES for now (7 days in original)
    uint256 private constant dayRewardPercents = 571428571428600000;       /////4% weekly
    uint256 private constant maxAddFreeze = 45 minutes;     //max add freeze time >> (45 days in original) 
    uint256 private constant referDepth = 25;               //referDepth
    uint256 private Gassfee = 2;


    uint256 private constant directPercents = 600;  //6 %
    uint256[4] private level4Percents = [100, 200, 300, 100];  //1,2,3,1
    uint256[25] private level5Percents = [200, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,50,50,50,50,50,50,50,50,50,50]; //2,1,1,1,1,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5
    
    // this is pool amout which is 1% on each deposit
    uint256 private constant luckPoolPercents = 50; //0.5 %
    uint256 private constant starPoolPercents = 30; //0.3 %
    uint256 private constant topPoolPercents = 20;  //0.2 %

    uint256[5] private balDown = [10e10, 30e10, 100e10, 500e10, 1000e10];
    uint256[5] private balDownRate = [1000, 1500, 2000, 5000, 6000];  //10,15,20,50,60
    uint256[5] private balRecover = [15e10, 50e10, 150e10, 500e10, 1000e10]; 
    mapping(uint256=>bool) public balStatus; // bal=>status

    address public feeReceivers; //this address will receive 2% on each deposit

    address public defaultRefer; // default referral address
    uint256 public startTime;   //plan start time
    uint256 public lastDistribute;  //last distributeed pool time
    uint256 public totalUser; //total registered user
    address public owner;

    // these are the pool amout varibales which are storig 1% of each deposit

    uint256 public luckPool; //luck pool total income
    uint256 public starPool;    //star pool total income
    uint256 public topPool;     //top pool total income

    mapping(uint256=>address[]) public dayLuckUsers;
    mapping(uint256=>uint256[]) public dayLuckUsersDeposit;
    mapping(uint256=>address[3]) public dayTopUsers;  //stored the top 3 users against specific day

    address[] public level4Users; // level 4 users >> once user reached to the level 4 then their addresses will automatically start storing in this array

    struct OrderInfo {  //structure of orderInfo (amount,start time,unfreeze amount,check of "isUnfreezed" )
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos; //order info per person (amount,start time,unfreeze amount,check of "isUnfreezed" )

    address[] public depositors; //all depositer addresses of the contract

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

    mapping(address=>UserInfo) public userInfo;  //userInfo mapping returns values against any address (refferer,start time,current level, maximum deposit, total deposit, team number,maximum direct deposit,team totla deposit,total freezed, total revenue)  
    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit;  // maintained specific users amout on speicific day
    mapping(address => mapping(uint256 => address[])) public teamUsers;

     struct gassinfo
    {
        uint256 amount;
        uint256 time;
    }
    mapping(address => gassinfo) public UserFee;

    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 directs;
        uint256 level4Freezed;
        uint256 level4Released;
        uint256 level5Left;
        uint256 level5Freezed;
        uint256 level5Released;
        uint256 star;
        uint256 luck;
        uint256 top;
        uint256 split;
        uint256 splitDebt;
    }

    mapping(address=>RewardInfo) public rewardInfo;
    
    bool public isFreezeReward;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(IBEP20 _busdAddr, address _defaultRefer, address  _feeReceivers) public {
        busd = _busdAddr;
        feeReceivers = _feeReceivers;
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = _defaultRefer;
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require (owner==msg.sender ,"only owner can call");
        _;
    }
    function changeFeePercentage(uint256 _amount) public onlyOwner {
        Gassfee=_amount;
    }

        // register to the plan if new user 
    // referral must have graterr total deposit than 0, or refferal should be defaul refferal
    // refferr should not be 0 address
    // updated the total user of plan
    // update the start time of user
    // update the referal of caller address
    // update the team number

    function register(address _referral,uint256 _amount) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;
        _updateTeamNum(msg.sender);
        totalUser = totalUser.add(1);

         busd.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
        
        emit Register(msg.sender, _referral);
    }

     //  depoit the "amount" to the plan and calls the _deposit

    function deposit(uint256 _amount) external {        
        busd.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    // @dev callers can deposit into the plan by using his rewardInfo[msg.sender].split
    // _amount should be grater than minDeposit and in minDeposit mulitple
    // caller must be new to plan
    // used split is added in to rewardInfo[msg.sender].splitDebt

    function depositBySplit(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient split");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        _deposit(msg.sender, _amount);
        emit DepositBySplit(msg.sender, _amount);
    }

    // @dev caller transfering the "_amount" from his rewardInfo[msg.sender].split to the "_receiver" rewardInfo[_receiver].split
    // "_amount" is added in callers rewardInfo[msg.sender].splitDebt
    // minDepositSpit is 10 usd and mod is 10 usd

    uint256 public minDepositSpit= 10e18; //10 usd

    function transferBySplit(address _receiver, uint256 _amount) external {
        require(_amount >= minDepositSpit && _amount.mod(minDepositSpit) == 0, "amount err");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient income");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }

    // @dev called directly and also from deposit and depositbysplit
    // if current time is grater than last distributed time + timestep (1 day) then
     // distribute star pool reward among level 4 users
    // 
    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep)){
            uint256 dayNow = getCurDay();
            // distribute star pool reward
            _distributeStarPool();
            // distribute luck pool reward
            _distributeLuckPool(dayNow);
            // distribute top pool reward
            _distributeTopPool(dayNow);
            lastDistribute = block.timestamp ;
        }
    }
     function ClaimGassFee() public 
    {
        require(UserFee[msg.sender].amount > 0 , "error no gass fee");
        require( block.timestamp > UserFee[msg.sender].time + 7 days  , "error no gass fee");

        busd.transfer(msg.sender,UserFee[msg.sender].amount); 
         UserFee[msg.sender].time = 0;
    }

     // withdraw the income in form of usdt
    // income = withdrawable (staticReward+dynamicReward) + splitAmt(staticSplit+dynamicSplit) + userRewards.capitals

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
        userRewards.star = 0;
        userRewards.top = 0;
        
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        
        busd.transfer(msg.sender, withdrawable);
        uint256 bal = busd.balanceOf(address(this));
        _setFreezeReward(bal);

        emit Withdraw(msg.sender, withdrawable);
    }

    // gets the time difference between user deposit time and plan start time
    // starttime is plan start time
    // timestep is the divider to get the difference
    

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getDayLuckLength(uint256 _day) external view returns(uint256) {
        return dayLuckUsers[_day].length;
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    //  gets the orderInfo length
    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }

    // gives the max freezing amount if the unfreezing time is not reached
    function getMaxFreezing(address _user) public view returns(uint256) {
        uint256 maxFreezing;
        for(uint256 i = orderInfos[_user].length; i > 0; i--)
        {
            OrderInfo storage order = orderInfos[_user][i - 1];
                if(order.unfreeze > block.timestamp)
                {
                    if(order.amount > maxFreezing){
                        maxFreezing = order.amount;
                    }
                }  

                else
                {
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

    // gives the user curret split amount
    function getCurSplit(address _user) public view returns(uint256){
        (, uint256 staticSplit) = _calCurStaticRewards(_user);
        (, uint256 dynamicSplit) = _calCurDynamicRewards(_user);
        return rewardInfo[_user].split.add(staticSplit).add(dynamicSplit).sub(rewardInfo[_user].splitDebt);
    }

    // static reward (userRewards.statics)
    // splitAmt = (userRewards.statics * freezeIncomePercents (25%) / baseDivider)
    // withdrawable= userRewards.statics - splitAmt
    function _calCurStaticRewards(address _user) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.statics;
        //split amount formula
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
    }

    // 

    function _calCurDynamicRewards(address _user) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.directs.add(userRewards.level4Released).add(userRewards.level5Released);
        totalRewards = totalRewards.add(userRewards.luck.add(userRewards.star).add(userRewards.top));
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
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

    // _updateTopUser(user.referrer, _amount, dayNow);
    // stored the amount of specific user on specific day >> userLayer1DayDeposit
    // stored the top 3 user of the day

    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow) private 
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


    //  maintainded the top user against specific day

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

    // changed the team total deposit when unfreezing is called
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

    // updats the refer info >>userInfo (teamTotalDeposit,referrer) 
    // also updates the upline leveles
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

    // this will update the user's level value
    // @dev gets the current level from _calLevelNow


    function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
        uint256 levelNow = _calLevelNow(_user);
        // @dev if current level is grater than past then new level will stored in userInfo.
        // if user level will 4 then user address stored in level 4 users.>>level4Users
        if(levelNow > user.level)
        {
            user.level = levelNow;
                 if(levelNow == 4)
                        {
                             level4Users.push(_user);
                        }
        }
    }

    // @dev we can setup the level condition in this function
    // @returns the level of the user
    // level 5 >>>>>>> total deposit of the user must be grater or equal than 500 usdt && user's team number grater than or equal to 200 && maximum team deposit grater than or equal to 10000 usdt,other team deposit grater than or equal to 10000 usdt,
    // level 4 >>>>>>> total deposit of the user must be grater or equal than 300 usdt && user's team number grater than or equal to 100 && maximum team deposit grater than or equal to 5000 usdt,other team deposit grater than or equal to 5000 usdt
    // level 3 >>>>>>> total deposit of the user must be grater or equal than 200 usdt && user's team number grater than or equal to 50 
    // level 2 >>>>>>> user's team number grater than or equal to 50 
    // level 1 >>>>>>> user's team number grater than or equal to 30 


    function _calLevelNow(address _user) private view returns(uint256) {

        UserInfo storage user = userInfo[_user];
        uint256 total = user.totalDeposit;
        uint256 levelNow;

        (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);

        if(total >= 500e18 && user.teamNum >= 200 && maxTeam >= 10000e18 && otherTeam >= 10000e18)
                        {
                                                 levelNow = 5;
                        }
        else if(total >= 300e18 && user.teamNum >= 100 && maxTeam >= 5000e18 && otherTeam >= 5000e18)
                        {
                                                 levelNow = 4;
                        }
        else if(total >= 200e18 && user.teamNum >= 50)
                        {    
                                                levelNow = 3;

                         }
    
        else if(user.teamNum >= 30)
                        {
                                                 levelNow = 2;
                        }

        else if(user.teamNum > 5)
                        {
                                                 levelNow = 1;
                         }

        return levelNow;
    }

    // @dev this will call after extrnal deposit function is called
    // it will check >>user's referrer must be exist
    // it will checks >> deposit amount must be grater than or equal minimum deposit amount
    // it will checks >> amount should be in ratio of 50 and deposit amount must be grater than or equal minimum deposit amount
    // it will check >> user maximum deposit must be 0 or current amount must be grater than or equal past deposit


    function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");
        //  this will get the gass fee and stored in UserFee
////////////////////////////////////////////////////////////////////////////////////////////////        
         uint256 feepercent = _amount*Gassfee/100;
          UserFee[_user].amount += feepercent;
          UserFee[_user].time = block.timestamp;
// ///////////////////////////////////////////////////////////////////////////////////////////
        //  maintains the maximum despoit
        if(user.maxDeposit == 0)
        {
            user.maxDeposit = _amount;
        }
         //  maintains the maximum despoit

        else if(user.maxDeposit < _amount)
        {
            user.maxDeposit = _amount;
        }

        // amount will go to this function where feeReceivers percent sent, luckPool,starpool,toppool percentages are stored
        _distributeDeposit(_amount);

        // if user total deposit is equal to zero than 
        if(user.totalDeposit == 0)
        {   
            // gets the time difference between user deposit time and plan start time
            uint256 dayNow = getCurDay();
            // push the callers address into dayLuckUsers against the plan day
            dayLuckUsers[dayNow].push(_user);
            // push the callers deposit amount into dayLuckUsersDeposit against the plan day
            dayLuckUsersDeposit[dayNow].push(_amount);
            //update the top user of the day and deposit amount of user on specific day
            _updateTopUser(user.referrer, _amount, dayNow);
        }
        //  stored the callers address in depositors array
        depositors.push(_user);
        // stored user total deposit >>deposit amount will go to the deposit amount as it is
        user.totalDeposit = user.totalDeposit.add(_amount);
        // stored user total freezed >>deposit amount will go to the freezed amount as it is
        user.totalFreezed = user.totalFreezed.add(_amount);
        // updates the level of the caller
        _updateLevel(msg.sender);

        // orderinfos length is divided by 2 and mulitply by timestamp(1 day by default) >> it will return the addfreeze
        uint256 addFreeze = (orderInfos[_user].length.div(2)).mul(timeStep);
        if(addFreeze > maxAddFreeze)
        {
            addFreeze = maxAddFreeze;
        }
        // unfreeze time will be get by adding currentTime and daypercycle and addFreeze value
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        // orderinfo related to amount of deposit , depositing time,unfreezer time and unfree boolean are stored
        orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false
        ));

        // unfreezed the amount if unfreeze time reached and updates the reward here
        _unfreezeFundAndUpdateReward(msg.sender, _amount);
        // distribute the star,luck,top pool rewards
        distributePoolRewards();
        // updats the refer info >>userInfo (teamTotalDeposit,referrer) 
    // also updates the upline leveles
        _updateReferInfo(msg.sender, _amount);
    // updates the totl revenue and level5freezed amount and level4 freezed amount
        _updateReward(msg.sender, _amount);
    // release the upline rewards
        _releaseUpRewards(msg.sender, _amount);
    
        uint256 bal = busd.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward)
        {
            _setFreezeReward(bal);
        }
    }

    // @dev unfreezed the amount if unfreeze time reached and updates the reward here
    // rewardInfo (capitals,statistics,level5Freezed,level5Released)will updated here under different condition
    // userInfo total revenue and totalFreezed is also caluclated and stored here
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

                uint256 staticReward = (order.amount.mul(dayRewardPercents).mul(100).mul(dayPerCycle).div(timeStep).div(baseDivider))/1e18;
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


    //@dev distribue the star pool
    // call from distributePoolRewards functions


    function _distributeStarPool() private {
        uint256 level4Count;
        // gets level4 users and get their count to divide the reward accuratly 
        for(uint256 i = 0; i < level4Users.length; i++)
        {
            if(userInfo[level4Users[i]].level == 4)
            {
                level4Count = level4Count.add(1);
            }
        }
            // if level4 count become grater than 0 then
        // divide the star pol amount on level 4 users cout
        // rewardInfo is updated (star)
        // userInfo is updated (totalRevenue)
        // star pool become 0 after distribution
        // 
        if(level4Count > 0)
        {
            uint256 reward = starPool.div(level4Count);
            uint256 totalReward;

            for(uint256 i = 0; i < level4Users.length; i++)
            {
                    if(userInfo[level4Users[i]].level == 4)
                    {
                        rewardInfo[level4Users[i]].star = rewardInfo[level4Users[i]].star.add(reward);
                        userInfo[level4Users[i]].totalRevenue = userInfo[level4Users[i]].totalRevenue.add(reward);
                        totalReward = totalReward.add(reward);
                    }
            }
                    if(starPool > totalReward)
                    {
                        starPool = starPool.sub(totalReward);
                    }
                    else
                     {
                        starPool = 0;
                    }
        }
    }

    // distribute luck pool reward
    // rewardInfo is updated (luck)
    // userInfo is updated (totalRevenue)
    // luck pool will be 0 after distribution


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
    // distribute the top pool reward
    // rewardInfo is updated (top)
    // userInfo is updated (totalRevenue)
    // top pool will zero after ditribution 



    function _distributeTopPool(uint256 _dayNow) private {
        uint16[3] memory rates = [5000, 3000, 2000];
        uint72[3] memory maxReward = [2000e18, 1000e18, 500e18];
        uint256 totalReward;
        for(uint256 i = 0; i < 3; i++){
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

    //@dev called only when user call deposit/depositBySplit methods of contract
    // 

    function _distributeDeposit(uint256 _amount) private {

        // send the feePercents to feeReceivers address
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        busd.transfer(feeReceivers, fee);
        
        // luckpool total income is added here >>calculation from luckPoolPercents =    0.5%
        uint256 luck = _amount.mul(luckPoolPercents).div(baseDivider);
        luckPool = luckPool.add(luck);
    
        // starpool total income is added here >>calculation from starPoolPercents =    0.3%
        uint256 star = _amount.mul(starPoolPercents).div(baseDivider);
        starPool = starPool.add(star);

        // toppool total income is added here >>calculation from topPoolPercents =    0.2%
        uint256 top = _amount.mul(topPoolPercents).div(baseDivider);
        topPool = topPool.add(top);
    }


    // updates the reward
    // updates userInfo (totalRevenue)
    // updates rewardInfo of upline (level5Freezed,level4Freezed,directs)


    function _updateReward(address _user, uint256 _amount) private 
    {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;

        for(uint256 i = 0; i < referDepth; i++)
        {
            // checking ig refferer of depositor is dead address/ zero address or not
            // entered in if condition if refferer is not dead address/ zero address
            if(upline != address(0))
            {


                // store the depositer's deposit _amount in newAmount
                uint256 newAmount = _amount;
                // checking refferer of depositor is default reffer or not
                // if its not default reffer ,entered in the condtion
                // inner if >>> if uplines max freezing amount is lesser than depositer amount then we will go with the max newAmount 
                    if(upline != defaultRefer)
                    {
                        uint256 maxFreezing = getMaxFreezing(upline);
                            if(maxFreezing < _amount)
                            {
                            newAmount = maxFreezing;
                            }
                    }

                // 
                RewardInfo storage upRewards = rewardInfo[upline];
                uint256 reward;

                    if(i > 4)
                    {
                            if(userInfo[upline].level > 4)
                            {
                            reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);
                            upRewards.level5Freezed = upRewards.level5Freezed.add(reward);
                            }
                    }
                    
                    else if(i > 0)
                    {
                        if( userInfo[upline].level > 3)
                        {
                        reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);
                        upRewards.level4Freezed = upRewards.level4Freezed.add(reward);
                        }
            
                    }


                    else if(upline == defaultRefer){
                        reward = newAmount.mul(directPercents).div(baseDivider);
                    upRewards.directs = upRewards.directs.add(reward);
                    userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                    }
                    
                    else 
                    {   
                            if(userInfo[upline].teamNum > 5)
                        {
                            reward = newAmount.mul(directPercents).div(baseDivider);
                                upRewards.directs = upRewards.directs.add(reward);
                                userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        }
                    }

                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;





            }


            // else statement of first condition
            else
            {
                break;
            }
        }


    }

    // release the upline rewards
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
}