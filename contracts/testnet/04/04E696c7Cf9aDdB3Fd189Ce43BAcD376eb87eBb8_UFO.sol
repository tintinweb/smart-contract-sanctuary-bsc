/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

pragma solidity ^0.8.0;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

pragma solidity ^0.8.0;

contract UFO {
    using SafeMath for uint256;
    IERC20 private usdt;
    uint256 private startTime;
    uint256 private lastDistribute;
    uint256 public totalUsers;
    uint256 public Sunpool;
    uint256 public Jupiterpool;
    address private creater;
    address private operator;
    uint256 private constant SUN_RANK_LIMIT = 200;
    uint256 private constant JUPITER_RANK_LIMIT = 300;
    uint256 private constant minDeposit = 100e18;
    uint256 private constant maxDeposit = 1000e18; //1000e18
    uint256 private constant timeStep = 1 hours; //1 days
    uint256 private constant dayPerCycle = 15 hours; //15 days
    uint256 private constant maxAddFreeze = 30 hours; //30 days
    uint256 private constant baseDeposit = 100e18;
    uint256 private constant referDepth = 15;
    uint256 private constant dayRewardPercents = 134;
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 200;
    uint256 private constant operatorPercent = 200;
    uint256 private constant RoyalityFee = 50;
    uint256 private constant maxSearchDepth = 3000;
    uint256 private constant transferFeePercents = 1000;
    uint256 private constant ActivationPercents = 3000;
    uint256[5] private levelDeposit = [
        100e18,
        300e18,
        500e18,
        1000e18,
        1000e18
    ];
    uint256[10] private balReached = [
        100000e18,
        500000e18,
        1000000e18,
        2500000e18,
        500000e18,
        10000000e18,
        20000000e18,
        30000000e18,
        40000000e18,
        50000000e18
    ];
    uint256[10] private balFreezeStatic = [
        75000e18,
        375000e18,
        750000e18,
        1875000e18,
        3750000e18,
        7500000e18,
        15000000e18,
        22500000e18,
        30000000e18,
        37500000e18
    ];
    uint256[10] private balFreezeDynamic = [
        50000e18,
        250000e18,
        500000e18,
        1250000e18,
        2500000e18,
        5000000e18,
        10000000e18,
        15000000e18,
        20000000e18,
        25000000e18
    ];
    uint256[10] private breakthree = [
        25000e18,
        125000e18,
        250000e18,
        625000e18,
        1250000e18,
        2500000e18,
        5000000e18,
        7500000e18,
        10000000e18,
        12500000e18
    ];
    uint256[10] private balRecover = [
        110000e18,
        550000e18,
        1100000e18,
        2750000e18,
        5500000e18,
        11000000e18,
        22000000e18,
        33000000e18,
        44000000e18,
        55000000e18
    ];
    uint256[5] private levelInvite = [
        0,
        5000e18,
        15000e18,
        30000e18,
        100000e18
    ];
    uint256[5] private levelTeam = [1, 3, 5, 10, 10];
    uint256[15] private invitePercents = [
        500,
        100,
        200,
        300,
        100,
        50,
        50,
        50,
        50,
        50,
        50,
        50,
        50,
        50,
        50
    ]; // commision

    uint256[10] private directSponser = [2, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    uint256[10] private DepositValue = [
        100e18,
        200e18,
        300e18,
        400e18,
        500e18,
        600e18,
        700e18,
        800e18,
        900e18,
        1000e18
    ];
    bool private freezeStaticReward;
    bool private freezeDynamicReward;
    bool private freezeroyality;

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
        bool inSunRank;
        bool inJupiterRank;
    }

    struct RewardInfo {
        uint256 capitals;
        uint256 statics;
        uint256 invited;
        uint256 level5Freezed;
        uint256 level5Released;
        uint256 activation;
        uint256 royality;
    }

    struct OrderInfo {
        uint256 amount;
        uint256 start;
        uint256 unfreeze;
        bool isUnfreezed;
    }

    address private defaultRefer;
    address[] private depositors;
    address[] public sunRankUsers;
    address[] public jupiterRankUsers;
    address[] public jupiterRankQueue;
    mapping(address => UserInfo) private userInfo;
    mapping(address => RewardInfo) private rewardInfo;
    mapping(address => OrderInfo[]) private orderInfos;
    mapping(uint256 => uint256) private dayNewbies;
    mapping(address => mapping(uint256 => uint256)) private userCycleMax;
    mapping(uint256 => uint256) private dayDeposit;
    mapping(address => mapping(uint256 => address[])) private teamUsers;
    mapping(uint256 => bool) private balStatus;
    event Withdraw(address user, uint256 withdrawable);
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DistributeRoyality(uint256 day, uint256 time);
    event TransferByActivation(
        address user,
        uint256 subBal,
        address receiver,
        uint256 amount
    );
    event depositByActivation(address user, uint256 amount);

    constructor(
        address _usdtAddr,
        address _defaultRefer,
        address _createrAddress,
        address _OperatorAddress,
        uint256 _startTime
    ) {
        usdt = IERC20(_usdtAddr);
        creater = _createrAddress;
        operator = _OperatorAddress;
        startTime = _startTime;
        lastDistribute = _startTime;
        defaultRefer = _defaultRefer;
    }

    //==============================PRIVATE FUNCTIONS=============================//
    function _distributeDeposit(uint256 amount) private {
        uint256 totalFee = amount.mul(feePercents).div(baseDivider);
        require(
            usdt.transfer(creater, totalFee),
            "Unable to send USDT to Creator Address"
        );
        uint256 operatorfees = amount.mul(operatorPercent).div(baseDivider);
        require(
            usdt.transfer(operator, operatorfees),
            "Unable to send USDT to operator Address"
        );
        uint256 poolAmount = amount.mul(RoyalityFee).div(baseDivider);
        Jupiterpool = Jupiterpool.add(poolAmount);
        Sunpool = Sunpool.add(poolAmount);
    }

    function _deposit(address _userAddr, uint256 _amount) private {
        require(block.timestamp >= startTime, "Project is not Started");
        UserInfo storage user = userInfo[_userAddr];
        require(user.referrer != address(0), "User Not Registered");
        require(
            _amount >= minDeposit &&
                _amount <= maxDeposit &&
                _amount.mod(minDeposit) == 0,
            "Invalid Amount"
        );
        require(
            user.maxDeposit == 0 || _amount >= user.maxDeposit,
            "Less Amount"
        );
        // directReferrals[user.referrer]++;
        _distributeDeposit(_amount);
        uint256 curCycle = getCurCycle();
        uint256 userCurMax = userCycleMax[msg.sender][curCycle];
        if (userCurMax == 0) {
            if (curCycle == 0 || user.maxDepositable == 0) {
                userCurMax = baseDeposit;
            } else {
                userCurMax = user.maxDepositable;
            }
            userCycleMax[msg.sender][curCycle] = userCurMax;
        }
        require(_amount <= maxDeposit, "too much");
        // if (user.totalFreezed > 0) {
        //     revert("wait for id to be unfreezed");
        // }
        
        if(user.maxDeposit != 0){
          OrderInfo storage order = orderInfos[msg.sender][user.unfreezeIndex];
         if(block.timestamp < order.unfreeze){
            revert ("wait for ID to unblock");
        }
        }   
        if (_amount == userCurMax) {
            if (userCurMax >= maxDeposit) {
                userCycleMax[msg.sender][curCycle.add(1)] = maxDeposit;
            } else {
                userCycleMax[msg.sender][curCycle.add(1)] = userCurMax.add(
                    baseDeposit
                );
            }
        } else {
            userCycleMax[msg.sender][curCycle.add(1)] = userCurMax;
        }
        user.maxDepositable = userCycleMax[msg.sender][curCycle.add(1)];

        uint256 dayNow = getCurDay();
        bool isNewbie;
        if (user.maxDeposit == 0) {
            isNewbie = true;
            user.maxDeposit = _amount;
            dayNewbies[dayNow] = dayNewbies[dayNow].add(1);
            totalUsers = totalUsers.add(1);
        } else if (_amount > user.maxDeposit) {
            user.maxDeposit = _amount;
        }
        user.totalFreezed = user.totalFreezed.add(_amount);
        uint256 addFreeze = (orderInfos[_userAddr].length).mul(timeStep);
        if (addFreeze > maxAddFreeze) {
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_userAddr].push(
            OrderInfo(_amount, block.timestamp, unfreezeTime, false)
        );
        dayDeposit[dayNow] = dayDeposit[dayNow].add(_amount);
        depositors.push(_userAddr);
        _unfreezeCapitalOrReward(msg.sender, _amount);
        _updateUplineReward(msg.sender, _amount);
        _updateTeamInfos(msg.sender, _amount, isNewbie);
        _updateLevel(msg.sender);
        _distrubulteRoyality();
        uint256 bal = usdt.balanceOf(address(this));
        _balActived(bal);
        if (freezeStaticReward || freezeDynamicReward || freezeroyality) {
            _setFreezeReward(bal);
        } else if (user.unfreezedDynamic) {
            user.unfreezedDynamic = false;
        }
    }

    function _updateTeamInfos(
        address useraddress,
        uint256 amount,
        bool _isNewbie
    ) private {
        address upline = userInfo[useraddress].referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                if (_isNewbie && useraddress != upline) {
                    userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                    teamUsers[upline][i].push(useraddress); 
                }
                userInfo[upline].teamTotalDeposit = userInfo[upline]
                    .teamTotalDeposit
                    .add(amount);
                if (upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _balActived(uint256 _bal) private {
        for (uint256 i = balReached.length; i > 0; i--) {
            if (_bal >= balReached[i - 1]) {
                balStatus[balReached[i - 1]] = true;
                break;
            }
        }
    }

    function _setFreezeReward(uint256 _bal) private {
        for (uint256 i = balReached.length; i > 0; i--) {
            if (balStatus[balReached[i - 1]]) {
                if (_bal < balFreezeStatic[i - 1]) {
                    // freezeStaticReward = true;
                    freezeroyality = true;
                    if (_bal < balFreezeDynamic[i - 1]) {
                        freezeStaticReward = true;
                    }
                    if (_bal < breakthree[i - 1]) {
                        freezeDynamicReward = true;
                    }
                } else {
                    if (
                        (freezeroyality ||
                            freezeStaticReward ||
                            freezeDynamicReward) && _bal >= balRecover[i - 1]
                    ) {
                        freezeroyality = false;
                        freezeStaticReward = false;
                        freezeDynamicReward = false;
                    }
                }
                break;
            }
        }
    }

    function _unfreezeCapitalOrReward(address useraddress, uint256 amount)
        private
    {   
        UserInfo storage user = userInfo[useraddress];
        RewardInfo storage userRewards = rewardInfo[useraddress];
        OrderInfo storage order = orderInfos[useraddress][user.unfreezeIndex];
        if (
            order.isUnfreezed == false &&
            block.timestamp >= order.unfreeze &&
            amount >= order.amount
        ) {
            order.isUnfreezed = true;
            user.unfreezeIndex = user.unfreezeIndex.add(1);
            _removeInvalidDeposit(useraddress, order.amount);
            uint256 staticReward = order
                .amount
                .mul(dayRewardPercents)
                .mul(dayPerCycle) 
                .div(timeStep)
                .div(baseDivider);
            if (freezeStaticReward || freezeroyality) {
                if (user.totalFreezed > user.totalRevenue) {
                    uint256 leftCapital = user.totalFreezed.sub(
                        user.totalRevenue
                    );
                    if (staticReward > leftCapital) {
                        staticReward = leftCapital;
                    }
                } else {
                    staticReward = 0;   
                }
            }
            userRewards.capitals = userRewards.capitals.add(order.amount);
            userRewards.statics = userRewards.statics.add(staticReward);
            user.totalRevenue = user.totalRevenue.add(staticReward);
        } else if (userRewards.level5Freezed > 0) {
            uint256 release = amount;
            if (amount >= userRewards.level5Freezed) {
                release = userRewards.level5Freezed;
            }
            userRewards.level5Freezed = userRewards.level5Freezed.sub(release);
            userRewards.level5Released = userRewards.level5Released.add(
                release
            );
            user.totalRevenue = user.totalRevenue.add(release);
        } else if (
            freezeStaticReward && !user.unfreezedDynamic && freezeroyality
        ) {
            user.unfreezedDynamic = true;
        }
    }

    function _removeInvalidDeposit(address useraddress, uint256 amount)
        private
    {
        uint256 totalFreezed = userInfo[useraddress].totalFreezed;
        userInfo[useraddress].totalFreezed = totalFreezed > amount
            ? totalFreezed.sub(amount)
            : 0;
        address upline = userInfo[useraddress].referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                userInfo[upline].teamTotalDeposit = userInfo[upline]
                    .teamTotalDeposit > amount
                    ? userInfo[upline].teamTotalDeposit.sub(amount)
                    : 0;
                if (upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function _updateLevel(address useraddress) private {
        UserInfo storage user = userInfo[useraddress];
        for (uint256 i = user.level; i < levelDeposit.length; i++) {
            if (user.maxDeposit >= levelDeposit[i]) {
                (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(
                    useraddress
                );
                if (
                    maxTeam >= levelInvite[i] &&
                    otherTeam >= levelInvite[i] &&
                    user.teamNum >= levelTeam[i]
                ) {
                    user.level = i + 1;
                    if (
                        !user.inJupiterRank &&
                        !user.inSunRank &&
                        jupiterRankQueue.length <= SUN_RANK_LIMIT &&
                        jupiterRankUsers.length == JUPITER_RANK_LIMIT &&
                        maxTeam >= 30000e18 &&
                        otherTeam >= 30000e18 &&
                        user.teamNum >= 10
                    ) {
                        jupiterRankQueue.push(msg.sender);
                    }
                }
            }
        }
        if (
            !user.inSunRank &&
            sunRankUsers.length < SUN_RANK_LIMIT &&
            user.level == 4 
        ) {
            sunRankUsers.push(msg.sender);
            user.inSunRank = true;
            if (user.inJupiterRank) {
                removeJupiterRankUser(msg.sender);
            }
        }
        //add user to jupiter rank
        if (
            !user.inJupiterRank &&
            jupiterRankUsers.length < JUPITER_RANK_LIMIT &&
            user.level == 3
        ) {
            jupiterRankUsers.push(msg.sender);
            user.inJupiterRank = true;
        }
    }

    function _updateUplineReward(address useraddress, uint256 amount) private {
        address upline = userInfo[useraddress].referrer;
        for (uint256 i = 0; i < referDepth; i++) {
            if (upline != address(0)) {
                if (
                    !freezeStaticReward ||
                    !freezeroyality ||
                    userInfo[upline].totalFreezed >
                    userInfo[upline].totalRevenue ||
                    (userInfo[upline].unfreezedDynamic && !freezeDynamicReward)
                ) {
                    uint256 newAmount;
                    if (orderInfos[upline].length > 0) {
                        OrderInfo storage latestUpOrder = orderInfos[upline][
                            orderInfos[upline].length.sub(1)
                        ];
                        uint256 maxFreezing = latestUpOrder.unfreeze >
                            block.timestamp
                            ? latestUpOrder.amount
                            : 0;
                        if (maxFreezing < amount) {
                            newAmount = maxFreezing;
                        } else {
                            newAmount = amount;
                        }
                    }

                    if (newAmount > 0) {
                        RewardInfo storage upRewards = rewardInfo[upline];
                        if (
                            userInfo[upline].level > i ||
                            userInfo[upline].level == 5
                        ) {
                            uint256 reward = newAmount
                                .mul(invitePercents[i])
                                .div(baseDivider);
                            if (i < 4) {
                                upRewards.invited = upRewards.invited.add(
                                    reward
                                );
                                userInfo[upline].totalRevenue = userInfo[upline]
                                    .totalRevenue
                                    .add(reward);
                            } else {
                                upRewards.level5Freezed = upRewards
                                    .level5Freezed
                                    .add(reward);
                            }
                        }
                    }
                }
                if (upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            } else {
                break;
            }
        }
    }

    function sunroyality() private {
        uint256 Sunperuserreward = Sunpool.div(sunRankUsers.length);
        for (uint256 i = 0; i < sunRankUsers.length; i++) {
            address useraddr = sunRankUsers[i];
            RewardInfo storage reward = rewardInfo[useraddr];
            reward.royality = Sunperuserreward++;
        }
        Sunpool =0;
    }

    function Jupiterroyality() private {
        uint256 Jipiteruserreward = Jupiterpool.div(jupiterRankUsers.length);
        for (uint256 i = 0; i < jupiterRankUsers.length; i++) {
            address useraddr = jupiterRankUsers[i];
            RewardInfo storage reward = rewardInfo[useraddr];
            reward.royality = Jipiteruserreward++;
        }
        Jupiterpool = 0;
    }

    function _distrubulteRoyality() private {
        if (block.timestamp >= lastDistribute.add(timeStep)) {
            if (sunRankUsers.length > 0) {
                sunroyality();
            }
            if (jupiterRankUsers.length > 0) {
                Jupiterroyality();
            }
        }
    }

    function removeJupiterRankUser(address userAddress) private {
        for (uint256 i = 0; i < jupiterRankUsers.length; i++) {
            if (jupiterRankUsers[i] == userAddress) {
                jupiterRankUsers[i] = jupiterRankUsers[
                    jupiterRankUsers.length - 1
                ];
                jupiterRankUsers.pop();
                userInfo[userAddress].inJupiterRank = false;
                address queue = jupiterRankQueue[0];
                userInfo[queue].inJupiterRank = true;
                jupiterRankQueue[0] = jupiterRankQueue[
                    jupiterRankQueue.length - 1
                ];
                jupiterRankQueue.pop();
                return;
            }
        }
    }

    //==============================EXTERNAL FUNCTIONS======================//

    function Join(address _referral) external {
        require(
            userInfo[_referral].maxDeposit > 0 || _referral == defaultRefer,
            "invalid refer"
        );
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        emit Register(msg.sender, _referral);
    }

    function deposit(uint256 amount) external {
        usdt.transferFrom(msg.sender, address(this), amount);
        _deposit(msg.sender, amount);
        emit Deposit(msg.sender, amount);
    }

    function distributeRoyality() external {
        if (block.timestamp >= lastDistribute.add(timeStep)) {
            uint256 dayNow = getCurDay();
            _distrubulteRoyality();
            lastDistribute = startTime.add(dayNow.mul(timeStep));
            emit DistributeRoyality(dayNow, startTime);
        }
    }

    function DepositByActivation(uint256 _amount) external {
        require(userInfo[msg.sender].maxDeposit == 0, "actived");
        require(
            rewardInfo[msg.sender].activation >= _amount,
            "insufficient split"
        );  
        rewardInfo[msg.sender].activation = rewardInfo[msg.sender]
            .activation
            .sub(_amount);
        _deposit(msg.sender, _amount);
        emit depositByActivation(msg.sender, _amount);
    }

    function TransferActivation(address _receiver, uint256 _amount) external {
        uint256 subBal = _amount.add(
            _amount.mul(transferFeePercents).div(baseDivider)
        );
        require(
            _amount >= minDeposit && _amount.mod(minDeposit) == 0,
            "amount err"
        );
        require(
            rewardInfo[msg.sender].activation >= subBal,
            "insufficient activation"
        );
        rewardInfo[msg.sender].activation = rewardInfo[msg.sender]
            .activation
            .sub(subBal);
        rewardInfo[_receiver].activation = rewardInfo[_receiver].activation.add(
            _amount
        );
        emit TransferByActivation(msg.sender, subBal, _receiver, _amount);
    }

    function withdraw() external {
        (
            uint256 withdrawable,
            uint256 activationAmt
        ) = _calCurRewards(msg.sender);
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        UserInfo storage user = userInfo[msg.sender];
        userRewards.statics = 0;
        userRewards.invited = 0;
        userRewards.level5Released = 0;
        userRewards.royality = 0;
        userRewards.activation = userRewards.activation.add(activationAmt);
        // userRewards.royality = userRewards.royality.add(royalityAmt);
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        require(withdrawable > 20e18, "Minimum withdraw limit is 20USDT");
        if (withdrawable > 20e18) {
            for (uint256 i = 0; i < DepositValue.length; i++) {
                if (user.maxDeposit == DepositValue[i]) {
                    require(
                        DepositValue[i] >= directSponser[i],
                        "invalid sponsers"
                    );
                }
            }
        }
        require(
            usdt.transfer(msg.sender, withdrawable),
            "your doing something wrong"
        );
        uint256 bal = usdt.balanceOf(address(this));
        _setFreezeReward(bal);
        emit Withdraw(msg.sender, withdrawable);
    }

    //===========================VIEW FUNCTIONS==============================//
    function getCurCycle() public view returns (uint256) {
        uint256 curCycle = (block.timestamp.sub(startTime)).div(dayPerCycle);
        return curCycle;
    }

    function getCurDay() public view returns (uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getTeamDeposit(address useraddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for (uint256 i = 0; i < teamUsers[useraddress][0].length; i++) {
            uint256 userTotalTeam = userInfo[teamUsers[useraddress][0][i]]
                .teamTotalDeposit
                .add(userInfo[teamUsers[useraddress][0][i]].totalFreezed);
            totalTeam = totalTeam.add(userTotalTeam);
            if (userTotalTeam > maxTeam) {
                maxTeam = userTotalTeam;
            }
            if (i >= maxSearchDepth) break;
        }
        otherTeam = totalTeam.sub(maxTeam);
        return (maxTeam, otherTeam, totalTeam);
    }

    function _calCurRewards(address useraddress)
        private
        view
        returns (
            uint256,
            uint256
        )
    {
        RewardInfo storage userRewards = rewardInfo[useraddress];
        uint256 totalRewards = userRewards
            .statics
            .add(userRewards.invited)
            .add(userRewards.level5Released)
            .add(userRewards.royality);
        uint256 activationAmt = totalRewards.mul(ActivationPercents).div(
            baseDivider
        );
        // uint256 royalityAmt = userRewards.royality;
        uint256 withdrawable = totalRewards.sub(activationAmt);
        return (withdrawable, activationAmt);
    }

    function getDayInfos(uint256 _day)
        external
        view
        returns (uint256, uint256)
    {
        return (dayNewbies[_day], dayDeposit[_day]);
    }

    function getUserInfos(address _userAddr)
        external
        view
        returns (
            UserInfo memory,
            RewardInfo memory,
            OrderInfo[] memory
        )
    {
        return (
            userInfo[_userAddr],
            rewardInfo[_userAddr],
            orderInfos[_userAddr]
        );
    }

    function getBalInfos(uint256 _bal)
        external
        view
        returns (
            bool,
            bool,
            bool
        )
    {
        return (balStatus[_bal], freezeStaticReward, freezeDynamicReward);
    }

    function getTeamUsers(address _userAddr, uint256 _layer)
        external
        view
        returns (address[] memory)
    {
        return teamUsers[_userAddr][_layer];
    }

    function getUserCycleMax(address _userAddr, uint256 _cycle)
        external
        view
        returns (uint256)
    {
        return userCycleMax[_userAddr][_cycle];
    }

    function getDepositors() external view returns (address[] memory) {
        return depositors;
    }

    // function getranks() external view returns(uint256[5] memory ) {
    //      UserInfo storage user = userInfo[];
         
    // }

    function getContractInfos()
        external
        view
        returns (address[4] memory, uint256[6] memory)
    {
        address[4] memory infos0;
        infos0[0] = address(usdt);
        infos0[1] = creater;
        infos0[2] = defaultRefer;
        infos0[3] = operator;
        uint256[6] memory infos1;
        infos1[0] = startTime;
        infos1[1] = lastDistribute;
        infos1[2] = totalUsers;
        uint256 dayNow = getCurDay();
        infos1[5] = dayDeposit[dayNow];
        return (infos0, infos1);
    }
}