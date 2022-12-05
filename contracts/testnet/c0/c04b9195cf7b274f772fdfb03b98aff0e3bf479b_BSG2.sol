/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: GPLv3

pragma solidity =0.8.15;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BSG2 is Ownable {
    using SafeMath for uint256; 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 200; 
    uint256 private constant minDeposit = 100e18;
    uint256 private constant maxDeposit = 5000e18;
    uint256 private constant baseDeposit = 1000e18;
    uint256 private constant splitPercents = 2100;
    uint256 private constant lotteryPercents = 900;
    uint256 private constant transferFeePercents = 1000;

    uint256 private constant timeStep = 1 minutes;
    uint256 private constant dayPerCycle = 15 minutes; 
    uint256 private constant dayRewardPercents = 150;
    uint256 private constant maxAddFreeze = 45 minutes;
    uint256 private constant referDepth = 15;
    uint256[15] private invitePercents = [500, 100, 200, 300, 100, 100, 100, 100, 100, 100, 50, 50, 50, 50, 50];
    uint256[5] private levelDeposit = [100e18, 1000e18, 2000e18, 3000e18, 5000e18];
    uint256[5] private levelInvite = [0, 10000e18, 20000e18, 30000e18, 100000e18];
    uint256[5] private levelTeam = [0, 30, 50, 100, 300];

    uint256[3] private balReached = [100e22, 500e22, 1000e22];
    uint256[3] private balFreezeStatic = [70e22, 300e22, 500e22];
    uint256[3] private balFreezeDynamic = [40e22, 150e22, 200e22];
    uint256[3] private balRecover = [150e22, 500e22, 1000e22];
    uint256 private constant poolPercents = 50;
    uint256 private constant luckMinDeposit = 500e18;
    uint256 private constant lotteryDuration = 30 minutes;
    uint256 private constant lotteryBetFee = 10e18;
    mapping(uint256=>uint256) private dayLotteryReward; 
    uint256[10] private lotteryWinnerPercents = [3500, 2000, 1000, 500, 500, 500, 500, 500, 500, 500];
    uint256 private constant maxSearchDepth = 3000;

    IERC20 private usdt;
    address private feeReceiver;
    address private defaultRefer;
    uint256 private startTime;
    uint256 private lastDistribute;
    uint256 private totalUsers; 
    uint256 private luckPool;
    uint256 private lotteryPool;
    mapping(uint256=>uint256) private dayNewbies;
    mapping(uint256=>uint256) private dayDeposit;
    mapping(uint256=>address[]) private dayLuckUsers;
    mapping(uint256=>uint256[]) private dayLuckUsersDeposit;
    address[] private depositors;
    mapping(uint256=>bool) private balStatus;
    bool private freezeStaticReward;
    bool private freezeDynamicReward;
    mapping(uint256=>mapping(uint256=>address[])) private allLotteryRecord;

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
        uint256 lotteryWin;
        uint256 split;
        uint256 lottery;
    }

    struct OrderInfo {
        uint256 amount;
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    struct LotteryRecord {
        uint256 time;
        uint256 number;
    }

    mapping(address=>UserInfo) private userInfo;
    mapping(address=>RewardInfo) private rewardInfo;
    mapping(address=>OrderInfo[]) private orderInfos;
    mapping(address=>LotteryRecord[]) private userLotteryRecord;
    mapping(address=>mapping(uint256=>uint256)) private userCycleMax;
    mapping(address=>mapping(uint256=>address[])) private teamUsers;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, uint256 subBal, address receiver, uint256 amount, uint256 transferType);
    event Withdraw(address user, uint256 withdrawable);
    event LotteryBet(uint256 time, address user, uint256 number);
    event DistributePoolRewards(uint256 day, uint256 time);

    constructor(address _usdtAddr, address _defaultRefer, address _feeReceiver, uint256 _startTime) {
        usdt = IERC20(_usdtAddr);
        feeReceiver = _feeReceiver;
        startTime = _startTime;
        lastDistribute = _startTime;
        defaultRefer = _defaultRefer;
    }

    function register(address _referral) external {
        require(userInfo[_referral].maxDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 _amount) external {
        usdt.transferFrom(msg.sender, address(this), _amount);
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

    function transferBySplit(address _receiver, uint256 _amount, uint256 _type) external {
        uint256 subBal = _amount.add(_amount.mul(transferFeePercents).div(baseDivider));
        if(_type == 0){
            require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
            require(rewardInfo[msg.sender].split >= subBal, "insufficient split");
            rewardInfo[msg.sender].split = rewardInfo[msg.sender].split.sub(subBal);
            rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);

        }else{
            require(_amount > 0, "amount err");
            require(rewardInfo[msg.sender].lottery >= subBal, "insufficient lottery");
            rewardInfo[msg.sender].lottery = rewardInfo[msg.sender].lottery.sub(subBal);
            rewardInfo[_receiver].lottery = rewardInfo[_receiver].lottery.add(_amount);

        }
        emit TransferBySplit(msg.sender, subBal, _receiver, _amount, _type);
    }

    function lotteryBet(uint256 _number) external {
        require(userInfo[msg.sender].maxDeposit > 0, "deposit first");
        uint256 dayNow = getCurDay();
        uint256 lotteryEnd = startTime.add(dayNow.mul(timeStep)).add(lotteryDuration);
        require(block.timestamp < lotteryEnd, "today is over");
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        require(userRewards.lottery >= lotteryBetFee, "insufficient lottery");
        userRewards.lottery = userRewards.lottery.sub(lotteryBetFee);
        allLotteryRecord[dayNow][_number].push(msg.sender);
        userLotteryRecord[msg.sender].push(LotteryRecord(block.timestamp, _number));
        emit LotteryBet(block.timestamp, msg.sender, _number);
    }

    function withdraw() external {
        (uint256 withdrawable, uint256 split, uint256 lottery) = _calCurRewards(msg.sender);
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        userRewards.statics = 0;
        userRewards.invited = 0;
        userRewards.level5Released = 0;
        userRewards.luckWin = 0;
        userRewards.lotteryWin = 0;
        userRewards.split = userRewards.split.add(split);
        userRewards.lottery = userRewards.lottery.add(lottery);
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        usdt.transfer(msg.sender, withdrawable);
        uint256 bal = usdt.balanceOf(address(this));
        _setFreezeReward(bal);
        emit Withdraw(msg.sender, withdrawable);
    }

    function distributePoolRewards() external {
        if(block.timestamp >= lastDistribute.add(timeStep)){
            uint256 dayNow = getCurDay();
            _distributeLuckPool(dayNow.sub(1));
            _distributeLotteryPool(dayNow.sub(1));
            lastDistribute = startTime.add(dayNow.mul(timeStep));
            emit DistributePoolRewards(dayNow, lastDistribute);
        }
    }

    function _deposit(address _userAddr, uint256 _amount, bool _isLuckable) private {
        require(block.timestamp >= startTime, "not start");
        UserInfo storage user = userInfo[_userAddr];
        require(user.referrer != address(0), "not register");
        require(_amount >= minDeposit && _amount <= maxDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "too less");
        _distributeDeposit(_amount);
        uint256 curCycle = getCurCycle();
        uint256 userCurMax = userCycleMax[msg.sender][curCycle];
        if(userCurMax == 0){
            if(curCycle == 0 || user.maxDepositable == 0){
                userCurMax = baseDeposit;
            }else{
                userCurMax = user.maxDepositable;
            }
            userCycleMax[msg.sender][curCycle] = userCurMax;
        }
        require(_amount <= userCurMax, "too much");
        if(_amount == userCurMax){
            if(userCurMax >= maxDeposit){
                userCycleMax[msg.sender][curCycle.add(1)] = maxDeposit;
            }else{
                userCycleMax[msg.sender][curCycle.add(1)] = userCurMax.add(baseDeposit);
            }
        }else{
            userCycleMax[msg.sender][curCycle.add(1)] = userCurMax;
        }
        user.maxDepositable = userCycleMax[msg.sender][curCycle.add(1)];

        uint256 dayNow = getCurDay();
        bool isNewbie;
        if(user.maxDeposit == 0){
            isNewbie = true;
            user.maxDeposit = _amount;
            dayNewbies[dayNow] = dayNewbies[dayNow].add(1);
            totalUsers = totalUsers.add(1);
            if(_isLuckable && _amount >= luckMinDeposit && dayLuckUsers[dayNow].length < 10){
                dayLuckUsers[dayNow].push(_userAddr);
                dayLuckUsersDeposit[dayNow].push(_amount);
            }
        }else if(_amount > user.maxDeposit){
            user.maxDeposit = _amount;
        }
        user.totalFreezed = user.totalFreezed.add(_amount);
        uint256 addFreeze = (orderInfos[_userAddr].length).mul(timeStep);
        if(addFreeze > maxAddFreeze) {
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
        uint256 bal = usdt.balanceOf(address(this));
        _balActived(bal);
        if(freezeStaticReward || freezeDynamicReward){
            _setFreezeReward(bal);
        }else if(user.unfreezedDynamic){
            user.unfreezedDynamic = false;
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        uint256 totalFee = _amount.mul(feePercents).div(baseDivider);
        usdt.transfer(feeReceiver, totalFee);
        uint256 poolAmount = _amount.mul(poolPercents).div(baseDivider);
        luckPool = luckPool.add(poolAmount);
        lotteryPool = lotteryPool.add(poolAmount);
    }

    function _updateLevel(address _userAddr) private {
        UserInfo storage user = userInfo[_userAddr];
        for(uint256 i = user.level; i < levelDeposit.length; i++){
            if(user.maxDeposit >= levelDeposit[i]){
                (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_userAddr);
                if(maxTeam >= levelInvite[i] && otherTeam >= levelInvite[i] && user.teamNum >= levelTeam[i]){
                    user.level = i + 1;
                }
            }
        }
    }

    function _unfreezeCapitalOrReward(address _userAddr, uint256 _amount) private {
        UserInfo storage user = userInfo[_userAddr];
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        OrderInfo storage order = orderInfos[_userAddr][user.unfreezeIndex];
        if(order.isUnfreezed == false && block.timestamp >= order.unfreeze && _amount >= order.amount){
            order.isUnfreezed = true;
            user.unfreezeIndex = user.unfreezeIndex.add(1);
            _removeInvalidDeposit(_userAddr, order.amount);
            uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);
            if(freezeStaticReward){
                if(user.totalFreezed > user.totalRevenue){
                    uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                    if(staticReward > leftCapital){
                        staticReward = leftCapital;
                    }
                }else{
                    staticReward = 0;
                }
            }
            userRewards.capitals = userRewards.capitals.add(order.amount);
            userRewards.statics = userRewards.statics.add(staticReward);
            user.totalRevenue = user.totalRevenue.add(staticReward);
        }else if(userRewards.level5Freezed > 0){
            uint256 release = _amount;
            if(_amount >= userRewards.level5Freezed){
                release = userRewards.level5Freezed;
            }
            userRewards.level5Freezed = userRewards.level5Freezed.sub(release);
            userRewards.level5Released = userRewards.level5Released.add(release);
            user.totalRevenue = user.totalRevenue.add(release);
        }else if(freezeStaticReward && !user.unfreezedDynamic){
            user.unfreezedDynamic = true;
        }
    }

    function _removeInvalidDeposit(address _userAddr, uint256 _amount) private {
        uint256 totalFreezed = userInfo[_userAddr].totalFreezed;
        userInfo[_userAddr].totalFreezed = totalFreezed > _amount ? totalFreezed.sub(_amount) : 0;
        address upline = userInfo[_userAddr].referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit > _amount ? userInfo[upline].teamTotalDeposit.sub(_amount) : 0;
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateTeamInfos(address _userAddr, uint256 _amount, bool _isNewbie) private {
        address upline = userInfo[_userAddr].referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(_isNewbie && _userAddr != upline){
                    userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                    teamUsers[upline][i].push(_userAddr);
                }
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateUplineReward(address _userAddr, uint256 _amount) private {
        address upline = userInfo[_userAddr].referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                if(!freezeStaticReward || userInfo[upline].totalFreezed > userInfo[upline].totalRevenue || (userInfo[upline].unfreezedDynamic && !freezeDynamicReward)){
                    uint256 newAmount;
                    if(orderInfos[upline].length > 0){
                        OrderInfo storage latestUpOrder = orderInfos[upline][orderInfos[upline].length.sub(1)];
                        uint256 maxFreezing = latestUpOrder.unfreeze > block.timestamp ? latestUpOrder.amount : 0;
                        if(maxFreezing < _amount){
                            newAmount = maxFreezing;
                        }else{
                            newAmount = _amount;
                        }
                    }
                    
                    if(newAmount > 0){
                        RewardInfo storage upRewards = rewardInfo[upline];
                        if(userInfo[upline].level > i || userInfo[upline].level == 5){
                            uint256 reward = newAmount.mul(invitePercents[i]).div(baseDivider);
                            if(i < 4){
                                upRewards.invited = upRewards.invited.add(reward);
                                userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                            }else{
                                upRewards.level5Freezed = upRewards.level5Freezed.add(reward);
                            }
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

    function _balActived(uint256 _bal) private {
        for(uint256 i = balReached.length; i > 0; i--){
            if(_bal >= balReached[i - 1]){
                balStatus[balReached[i - 1]] = true;
                break;
            }
        }
    }

    function _setFreezeReward(uint256 _bal) private {
        for(uint256 i = balReached.length; i > 0; i--){
            if(balStatus[balReached[i - 1]]){
                if(_bal < balFreezeStatic[i - 1]){
                    freezeStaticReward = true;
                    if(_bal < balFreezeDynamic[i - 1]){
                        freezeDynamicReward = true;
                    }
                }else{
                    if((freezeStaticReward || freezeDynamicReward) && _bal >= balRecover[i - 1]){
                        freezeStaticReward = false;
                        freezeDynamicReward = false;
                    }
                }
                break;
            }
        }
    }

    function _calCurRewards(address _userAddr) private view returns(uint256, uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_userAddr];
        uint256 totalRewards = userRewards.statics.add(userRewards.invited).add(userRewards.level5Released).add(userRewards.luckWin).add(userRewards.lotteryWin);
        uint256 splitAmt = totalRewards.mul(splitPercents).div(baseDivider);
        uint256 lotteryAmt = totalRewards.mul(lotteryPercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt).sub(lotteryAmt);
        return(withdrawable, splitAmt, lotteryAmt);
    }

    function _distributeLuckPool(uint256 _lastDay) private {
        uint256 luckTotalDeposits;
        for(uint256 i = 0; i < dayLuckUsers[_lastDay].length; i++){
            luckTotalDeposits = luckTotalDeposits.add(dayLuckUsersDeposit[_lastDay][i]);
        }

        uint256 totalReward;
        for(uint256 i = 0; i < dayLuckUsers[_lastDay].length; i++){
            uint256 reward = luckPool.mul(dayLuckUsersDeposit[_lastDay][i]).div(luckTotalDeposits);
            totalReward = totalReward.add(reward);
            rewardInfo[dayLuckUsers[_lastDay][i]].luckWin = rewardInfo[dayLuckUsers[_lastDay][i]].luckWin.add(reward);
            userInfo[dayLuckUsers[_lastDay][i]].totalRevenue = userInfo[dayLuckUsers[_lastDay][i]].totalRevenue.add(reward);
        }
        luckPool = luckPool > totalReward ? luckPool.sub(totalReward) : 0;
    }

    function _distributeLotteryPool(uint256 _lastDay) private {
        address[] memory winners = getLottoryWinners(_lastDay);
        uint256 totalReward;
        for(uint256 i = 0; i < winners.length; i++){
            if(winners[i] != address(0)){
                uint256 reward = lotteryPool.mul(lotteryWinnerPercents[i]).div(baseDivider);
                totalReward = totalReward.add(reward);
                rewardInfo[winners[i]].lotteryWin = rewardInfo[winners[i]].lotteryWin.add(reward);
                userInfo[winners[i]].totalRevenue = userInfo[winners[i]].totalRevenue.add(reward);
            }else{
                break;
            }
        }
        dayLotteryReward[_lastDay] = totalReward;
        lotteryPool = lotteryPool > totalReward ? lotteryPool.sub(totalReward) : 0;
    }

    function getLuckInfos(uint256 _day) external view returns(address[] memory, uint256[] memory) {
        return(dayLuckUsers[_day], dayLuckUsersDeposit[_day]);
    }

    function getLottoryWinners(uint256 _day) public view returns(address[] memory) {
        uint256 newbies = dayNewbies[_day];
        address[] memory winners = new address[](10);
        uint256 counter;
        for(uint256 i = newbies; i >= 0; i--){
            for(uint256 j = 0; j < allLotteryRecord[_day][i].length; j++ ){
                address lotteryUser = allLotteryRecord[_day][i][j];
                if(lotteryUser != address(0)){
                    winners[counter] = lotteryUser;
                    counter++;
                    if(counter >= 10) break;
                }
            }
            if(counter >= 10 || i == 0 || newbies.sub(i) >= maxSearchDepth) break;
        }
        return winners;
    }

    function getTeamDeposit(address _userAddr) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_userAddr][0].length; i++){
            uint256 userTotalTeam = userInfo[teamUsers[_userAddr][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_userAddr][0][i]].totalFreezed);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam){
                maxTeam = userTotalTeam;
            }
            if(i >= maxSearchDepth) break;
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getCurCycle() public view returns(uint256) {
        uint256 curCycle = (block.timestamp.sub(startTime)).div(dayPerCycle);
        return curCycle;
    }

    function getDayInfos(uint256 _day) external view returns(uint256, uint256, uint256){
        return (dayNewbies[_day], dayDeposit[_day], dayLotteryReward[_day]);
    }

    function getUserInfos(address _userAddr) external view returns(UserInfo memory, RewardInfo memory, OrderInfo[] memory, LotteryRecord[] memory) {
        return (userInfo[_userAddr], rewardInfo[_userAddr], orderInfos[_userAddr], userLotteryRecord[_userAddr]);
    }

    function getBalInfos(uint256 _bal) external view returns(bool, bool, bool) {
        return(balStatus[_bal], freezeStaticReward, freezeDynamicReward);
    }

    function getAllLotteryRecord(uint256 _day, uint256 _number) external view returns(address[] memory) {
        return allLotteryRecord[_day][_number];
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

    function getContractInfos() external view returns(address[3] memory, uint256[6] memory) {
        address[3] memory infos0;
        infos0[0] = address(usdt);
        infos0[1] = feeReceiver;
        infos0[2] = defaultRefer;

        uint256[6] memory infos1;
        infos1[0] = startTime;
        infos1[1] = lastDistribute;
        infos1[2] = totalUsers;
        infos1[3] = luckPool;
        infos1[4] = lotteryPool;
        uint256 dayNow = getCurDay();
        infos1[5] = dayDeposit[dayNow];
        return (infos0, infos1);
    }


    function userWithdrawable(address _userAddress) public view returns(uint256) {
        (uint256 withdrawable,,) = _calCurRewards(_userAddress);
        RewardInfo storage userRewards = rewardInfo[_userAddress];
        withdrawable = withdrawable.add(userRewards.capitals);
        return withdrawable;
    }

    function rescueToken(address payable _reciever, uint256 _amount) public onlyOwner {
        _reciever.transfer(_amount); 
    }

    function rescueBNB( address payaddress ,address tokenAddress, uint256 tokens ) public onlyOwner 
    {
       IERC20(tokenAddress).transfer(payaddress, tokens);
    }
}