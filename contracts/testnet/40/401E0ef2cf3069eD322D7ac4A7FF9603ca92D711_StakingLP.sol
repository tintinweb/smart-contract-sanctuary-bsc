// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IPancakeRouter {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract StakingLP is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint112;
    using Counters for Counters.Counter;

    constructor(
        address _rewardToken,
        address _wbnbToken,
        address _router,
        address _pair,
        string memory _poolCode
    ) {
        rewardToken = IERC20(_rewardToken);
        wbnbToken = IERC20(_wbnbToken);
        router = IPancakeRouter(_router);
        pair = IPancakePair(_pair);
        POOL_CODE = _poolCode;
        startStakingAt = 1650276000;
        endStakingAt = 1652608800;
        stakeLockDuration = 30 days;
        dailyApr = 33;
        stakeDurationMilestones = [7 days, 14 days, 21 days, 30 days];
        stakeDurationMilestoneToPenaltyRate[7 days] = 2000;
        stakeDurationMilestoneToPenaltyRate[14 days] = 1000;
        stakeDurationMilestoneToPenaltyRate[21 days] = 500;
        stakeDurationMilestoneToPenaltyRate[30 days] = 200;
    }

    event Staked(address indexed staker, uint256 indexed id, uint256 amount);
    event ClaimRequested(address indexed staker, uint256 indexed id);
    event Claimed(
        address indexed staker,
        uint256 indexed id,
        uint256 interest,
        uint256 principal
    );

    string public POOL_CODE;

    uint256[] public stakeDurationMilestones;

    mapping(uint256 => uint256) public stakeDurationMilestoneToPenaltyRate;
    /// @dev The token ID counter
    Counters.Counter internal _tokenIdCounter;
    /// @dev The token used for rewards
    IERC20 public rewardToken;
    /// @dev The WBNB token
    IERC20 public wbnbToken;
    /// @dev The router contract
    IPancakeRouter public router;
    /// @dev The pair contract of DNL-WBNB
    IPancakePair public pair;
    /// @dev The staking addresses array
    address[] internal _addresses;
    /// @dev Address to their staking Ids
    mapping(address => uint256[]) public addressToIds;
    /// @dev Claimable time of specific stake id
    mapping(uint256 => uint256) public idToClaimAbleAt;
    /// @dev Id to stake detail
    mapping(uint256 => StakeDetail) public idToStakeDetail;
    /// @dev Id to stake status
    mapping(uint256 => StakeStatus) public idToStakeStatus;
    /// @dev Total staked amount
    uint256 public totalStakedAmount;
    /// @dev Time point begin and end staking
    uint256 public startStakingAt;
    uint256 public endStakingAt;
    /// @dev Daily APR
    uint256 public dailyApr = 33;
    /// @dev Stake lock duration
    uint256 public stakeLockDuration = 30 days;
    /// @dev Constants for interest calculation
    uint256 constant ONE_DAY_IN_SECONDS = 24 * 60 * 60;
    uint256 constant ONE_HOUR_IN_SECONDS = 60 * 60;
    /// @dev Detail of a staking id
    struct StakeDetail {
        uint256 startAt;
        uint256 endAt;
        uint256 amount;
        uint256 dailyAPR;
        address owner;
    }
    /// @dev Status of a staking id
    enum StakeStatus {
        Staked,
        Claimed
    }
    /// @dev The modifer that only allow the call from staker holder
    modifier onlyStakeholder(uint256 _id) {
        StakeDetail memory stakeDetail = idToStakeDetail[_id];
        require(
            stakeDetail.owner == msg.sender,
            "StakingLP: Caller is not the stakeholder"
        );
        _;
    }

    /// @dev Change the reward token contract address
    /// @param _rewardToken Address of the token contract
    function setRewardToken(address _rewardToken) external onlyOwner {
        rewardToken = IERC20(_rewardToken);
    }

    /// @dev Chane the Wbnb token contract address
    /// @param _wbnbToken Address of the token contract
    function setWbnbToken(address _wbnbToken) external onlyOwner {
        wbnbToken = IERC20(_wbnbToken);
    }

    /// @dev Change the pancake router contract address
    /// @param _router Address of the router contract
    function setRouter(address _router) external onlyOwner {
        router = IPancakeRouter(_router);
    }

    /// @dev Change the pair contract address
    /// @param _pair Address of the pair contract
    function setPair(address _pair) external onlyOwner {
        pair = IPancakePair(_pair);
    }

    /// @dev Set start time of this staking pool
    /// @param _time When the staking will start
    function setStartStakingAt(uint256 _time) external onlyOwner {
        startStakingAt = _time;
    }

    /// @dev Set end time of this staking pool
    /// @param _time When the staking will end
    function setEndStakingAt(uint256 _time) external onlyOwner {
        endStakingAt = _time;
    }

    /// @dev Set daily APR
    /// @param _apr APR of the staking pool
    function setDailyApr(uint256 _apr) external onlyOwner {
        dailyApr = _apr;
    }

    /// @dev Set stake lock duration
    /// @param _duration Stake lock duration
    function setStakeLockDuration(uint256 _duration) external onlyOwner {
        stakeLockDuration = _duration;
    }

    /// @dev Set stake duration milestones
    /// @param _stakeDurationMilestones Stake duration milestones
    function setStakeDurationMilestones(
        uint256[] memory _stakeDurationMilestones
    ) external onlyOwner {
        stakeDurationMilestones = _stakeDurationMilestones;
    }

    /// @dev Set stake duration milestone to penalty rate
    /// @param _stakeDurationMilestone Stake duration milestone
    /// @param _penaltyRate Penalty rate
    function setStakeDurationMilestoneToPenaltyRate(
        uint256 _stakeDurationMilestone,
        uint256 _penaltyRate
    ) external onlyOwner {
        stakeDurationMilestoneToPenaltyRate[
            _stakeDurationMilestone
        ] = _penaltyRate;
    }

    /// @dev Get Penalty rate by stake duration
    /// @param _stakeDuration Stake duration milestone

    function getPenaltyRateByStakeDuration(uint256 _stakeDuration)
        public
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < stakeDurationMilestones.length; i++) {
            if (stakeDurationMilestones[i] >= _stakeDuration) {
                return
                    stakeDurationMilestoneToPenaltyRate[
                        stakeDurationMilestones[i]
                    ];
            }
        }
        return 0;
    }

    /// @dev Get staking ids by address
    /// @param _address Address of the staker
    function getStakingIdsByAddress(address _address)
        public
        view
        returns (uint256[] memory)
    {
        return addressToIds[_address];
    }

    /// @dev Get stake holders count
    function getStakeHoldersCount() external view returns (uint256) {
        return _addresses.length;
    }

    /// @dev Get address of stake holder by index
    function getAddressByIndex(uint256 _index) external view returns (address) {
        return _addresses[_index];
    }

    /// @dev Get stake Detail
    /// @param _id Id of the stake
    function getStakeDetail(uint256 _id)
        external
        view
        returns (StakeDetail memory)
    {
        return idToStakeDetail[_id];
    }

    /// @dev Get Pair Price in Wbnb
    function getPairPrice() public view returns (uint256) {
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, ) = pair.getReserves();

        uint256 totalPoolValue = reserve1.mul(2);
        uint256 mintedPair = pair.totalSupply();
        return totalPoolValue.mul(1e18).div(mintedPair);
    }

    /// @dev Get current Interest by Id
    /// @param _id Id of the stake
    function getCurrentLPInterestById(uint256 _id)
        public
        view
        returns (uint256)
    {
        StakeDetail memory stakeDetail = idToStakeDetail[_id];
        uint256 stakePeriod;
        if (
            block.timestamp >= stakeDetail.endAt ||
            idToStakeStatus[_id] == StakeStatus.Claimed
        ) {
            stakePeriod = stakeDetail.endAt - stakeDetail.startAt;
        } else {
            stakePeriod = block.timestamp - stakeDetail.startAt;
        }
        uint256 currentInterest;
        currentInterest = stakeDetail
            .amount
            .mul(stakePeriod)
            .mul(stakeDetail.dailyAPR)
            .div(ONE_DAY_IN_SECONDS)
            .div(10000);
        return currentInterest;
    }

    /// @dev Get current DNL interest by Id
    /// @param _id Id of the stake
    function getCurrentDNLInterestById(uint256 _id)
        public
        view
        returns (uint256)
    {
        uint256 currentDNLInterest;
        uint256 currentLPInterest = getCurrentLPInterestById(_id);
        uint256 pairPrice = getPairPrice();
        /// Get current interest in BNB
        uint256 currentInterestInBNB = currentLPInterest.mul(pairPrice).div(
            1e18
        );
        // return currentInterestInBNB;
        /// Convert BNB to reward Token
        address[] memory path = new address[](2);
        path[0] = address(wbnbToken);
        path[1] = address(rewardToken);
        uint256[] memory amounts = router.getAmountsOut(
            currentInterestInBNB,
            path
        );
        currentDNLInterest = amounts[1];
        return currentDNLInterest;
    }

    /// @dev Get current total LP interest of an address
    /// @param _address Address of the staker
    function getCurrentLPInterestOfAddress(address _address)
        public
        view
        returns (uint256)
    {
        uint256 currentTotalLPInterest = 0;
        uint256[] memory stakingIds = getStakingIdsByAddress(_address);
        for (uint256 i = 0; i < stakingIds.length; i++) {
            currentTotalLPInterest = currentTotalLPInterest.add(
                getCurrentLPInterestById(stakingIds[i])
            );
        }
        return currentTotalLPInterest;
    }

    /// @dev Get current total interest of an address
    /// @param _address Address of the staker
    function getCurrentDNLInterestOfAddress(address _address)
        public
        view
        returns (uint256)
    {
        uint256 currentTotalInterest;
        uint256[] memory stakingIds = addressToIds[_address];
        for (uint256 i = 0; i < stakingIds.length; i++) {
            uint256 currentInterest = getCurrentDNLInterestById(stakingIds[i]);
            currentTotalInterest = currentTotalInterest.add(currentInterest);
        }
        return currentTotalInterest;
    }

    /// @dev Stake Pair Token To Pool
    /// @param _amount Amount of the pair token to be staked
    function stake(uint256 _amount) external nonReentrant {
        require(
            block.timestamp >= startStakingAt &&
                block.timestamp <= endStakingAt,
            "StakingLP: Staking is not available at this time"
        );
        require(_amount > 0, "StakingLP: Amount must be greater than 0");
        totalStakedAmount += _amount;
        uint256 currentId = _tokenIdCounter.current();
        StakeDetail memory stakeDetail = StakeDetail(
            block.timestamp,
            block.timestamp + stakeLockDuration,
            _amount,
            dailyApr,
            msg.sender
        );
        if (addressToIds[msg.sender].length == 0) {
            _addresses.push(msg.sender);
        }
        idToStakeDetail[currentId] = stakeDetail;
        addressToIds[msg.sender].push(currentId);
        _tokenIdCounter.increment();
        pair.transferFrom(msg.sender, address(this), _amount);
        idToStakeStatus[currentId] = StakeStatus.Staked;
        emit Staked(msg.sender, currentId, _amount);
    }

    /// @dev Claim Token by staking id
    /// @param _id Id of the stake
    function claim(uint256 _id) external nonReentrant onlyStakeholder(_id) {
        StakeDetail memory stakeDetail = idToStakeDetail[_id];
        require(
            idToStakeStatus[_id] == StakeStatus.Staked,
            "StakingLP: Already claimed"
        );
        uint256 penaltyRate = getPenaltyRateByStakeDuration(
            block.timestamp - stakeDetail.startAt
        );
        if (block.timestamp <= stakeDetail.endAt) {
            idToStakeDetail[_id].endAt = block.timestamp;
        }
        uint256 currentDNLInterest = getCurrentDNLInterestById(_id);
        idToStakeStatus[_id] = StakeStatus.Claimed;
        uint256 lpReturnAmount = stakeDetail.amount.sub(
            stakeDetail.amount.mul(penaltyRate).div(10000)
        );
        totalStakedAmount = totalStakedAmount.sub(stakeDetail.amount);
        pair.transfer(stakeDetail.owner, lpReturnAmount);
        rewardToken.transfer(msg.sender, currentDNLInterest);
        emit Claimed(msg.sender, _id, currentDNLInterest, lpReturnAmount);
    }

    /// @dev Transfer pair token
    /// @param _recepient Address of the receiver
    /// @param _amount Amount of the pair token to be transferred
    function transferPairToken(address _recepient, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        return pair.transfer(_recepient, _amount);
    }

    /// @dev Transfer reward token
    /// @param _recepient Address of the receiver
    /// @param _amount Amount of the reward token to be transferred
    function transferRewardToken(address _recepient, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        return rewardToken.transfer(_recepient, _amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}