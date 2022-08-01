// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma abicoder v2;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '../lib/IB8DexStake.sol';
import '../lib/IB8DToken.sol';

contract B8DexStake is IB8DexStake, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IB8DToken public b8dToken;            // The Token token itself
    uint256 public penaltyPercent;        // Penalty percent
    bool public claimingEnabled;          // Claiming enabled

    /**
     * @notice
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;

    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp, uint256 unblock_timestamp, uint256 window_index, uint256 reward);

    /**
     * @notice Unstaked event is triggered whenever a user un stakes tokens, address is indexed to make it filterable
     */
    event UnStaked(address indexed user, uint256 amount, uint256 timestamp, uint256 window_index, uint256 reward);

    /**
     * @notice Claim event is triggered whenever a user un clim rewards, address is indexed to make it filterable
     */
    event Claimed(address indexed user, uint256 amount, uint256 timestamp, uint256 days_count, uint256 claim_timestamp, uint256 window_index, uint256 reward);


    /**
     * @notice array of windows
     */
    //    mapping(Window => uint256) internal windows;
    Window[] internal windows;

    /**
     * @notice
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;

    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */
    constructor(
        address _b8dToken
    ) {
        b8dToken = IB8DToken(_b8dToken);
        stakeholders.push();
        penaltyPercent = uint(25);
        claimingEnabled = true;
    }

    /** @dev Add new staked windows
     *
     * @param blockedDaysCount: blocked days count
     * @param rewardPerDay: reward percent per day
     * @param maxSum: max sum claiming
     *
     */
    function addWindow(
        uint256 blockedDaysCount,
        uint256 rewardPerDay,
        uint256 maxSum
    )
    external
    onlyOwner
    {
        _addWindow(blockedDaysCount, rewardPerDay, maxSum);
    }

    /** @dev Update staked windows
     *
     * @param windowIndex: window index
     * @param blockedDaysCount: blocked days count
     * @param rewardPerDay: reward percent per day
     * @param maxSum: max sum claiming
     *
     */
    function updateWindow(
        uint256 windowIndex,
        uint256 blockedDaysCount,
        uint256 rewardPerDay,
        uint256 maxSum
    )
    external
    onlyOwner
    {
        _updateWindow(windowIndex, blockedDaysCount, rewardPerDay, maxSum);
    }

    /** @dev Remove staked windows
     *
     * @param windowIndex: window index
     *
     */
    function removeWindow(
        uint256 windowIndex
    )
    external
    onlyOwner
    {
        _removeWindow(windowIndex);
    }

    /** @dev Getting window information
     *
     */
    function getWindow(
        uint256 _windowIndex
    )
    external
    view
    returns(Window memory)
    {
        Window memory window = windows[_windowIndex];

        return window;
    }

    /** @dev Getting windows information
     *
     */
    function getWindows()
    external
    view
    returns(Window[] memory)
    {
        Window[] memory windows_arr;

        for (uint256 w = 0; w < windows.length; w++) {
            windows_arr[w] = windows[w];
        }

        return windows_arr;
    }

    /**
     * @dev Create new stake by window index
     *
     * @param _amount: amount to adding
     * @param _windowIndex: window index
     */
    function stake(
        uint256 _amount,
        uint256 _windowIndex
    ) external {
        _stake(_msgSender(), _amount, _windowIndex);
    }

    /**
     * @dev Add tokens to actual stake by stake index
     *
     * @param _amount: amount to adding
     * @param _windowIndex: window index
     * @param _stakeIndex: stake index
     */
    function addToStake(
        uint256 _amount,
        uint256 _windowIndex,
        uint256 _stakeIndex
    ) external {
        _addToStake(_msgSender(), _amount, _windowIndex, _stakeIndex);
    }

    /**
     * @dev withdraw all staked tokens and rewards by stake index
     *
     * @param _stakeIndex: stake index
     */
    function unStake(
        uint256 _stakeIndex
    ) external {
        _unStake(_msgSender(), _stakeIndex);
    }

    /**
     * @dev Claim rewards by stake index
     *
     * @param _stakeIndex: stake index
     *
     */
    function claim(
        uint256 _stakeIndex
    ) external {
        _claim(_msgSender(), _stakeIndex);
    }

    /**
     * @dev Claim all rewards by all windows
     *
     */
    function claimAll() external {
        _claimAll(_msgSender());
    }

    /** @dev hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     *
     * @param _staker: user address
     *
     */
    function hasStake(
        address _staker
    )
    external
    view
    returns(StakingSummary memory)
    {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s++) {
            uint256 availableReward = _calculateStakeReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount.add(summary.stakes[s].amount);
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }

    /** @dev hasStakeWindow is used to check if a account has stakes  for window and the total window amount
     *
     * @param _staker: user address
     * @param _windowIndex: window index
     *
     */
    function hasStakeWindow(
        address _staker,
        uint256 _windowIndex
    )
    external
    view
    returns(Stake memory)
    {
        require(stakes[_staker] > 0, "staker is not found");

        Stake[] memory all_stakes_arr = stakeholders[stakes[_staker]].address_stakes;

        require(all_stakes_arr.length > 0, "staker is not found");

        uint256 stake_index;
        for (uint256 s = 0; s < all_stakes_arr.length; s++) {
            if (all_stakes_arr[s].window_index == _windowIndex) {
                uint256 availableReward = _calculateStakeReward(all_stakes_arr[s]);
                all_stakes_arr[s].claimable = availableReward;
                stake_index = s;
            }
        }

        require(stake_index >= 0, "window is not found");

        return all_stakes_arr[stake_index];
    }

    /** @dev Collect tokens to owner
     *
     */
    function collect()
    external
    onlyOwner
    {
        _collect();
    }

    /** @dev Setting new penalty percent
     *
     * @param _newPenaltyPercent: new penalty percent
     */
    function setPenaltyPercent(
        uint256 _newPenaltyPercent
    )
    external
    onlyOwner
    {
        _setPenaltyPercent(_newPenaltyPercent);
    }

    /** @dev Return actual time
     *
     */
    function _time()
    internal
    view
    returns (uint)
    {
        return block.timestamp;
    }

    /** @dev Add new staked windows
     *
     * @param blockedDaysCount: blocked days count
     * @param rewardPerDay: reward percent per day
     * @param maxSum: max sum claiming
     *
     */
    function _addWindow(
        uint256 blockedDaysCount,
        uint256 rewardPerDay,
        uint256 maxSum
    )
    internal
    {
        windows.push();
        uint256 windowIndex = windows.length - 1;
        windows[windowIndex].blockedDaysCount = blockedDaysCount;
        windows[windowIndex].rewardPerDay = rewardPerDay;
        windows[windowIndex].maxSum = maxSum;
    }

    /** @dev Update staked windows
     *
     * @param windowIndex: window index
     * @param blockedDaysCount: blocked days count
     * @param rewardPerDay: reward percent per day
     * @param maxSum: max sum claiming
     *
     */
    function _updateWindow(
        uint256 windowIndex,
        uint256 blockedDaysCount,
        uint256 rewardPerDay,
        uint256 maxSum
    )
    internal
    {
        windows[windowIndex].blockedDaysCount = blockedDaysCount;
        windows[windowIndex].rewardPerDay = rewardPerDay;
        windows[windowIndex].maxSum = maxSum;
    }

    /** @dev Remove staked windows
     *
     * @param windowIndex: window index
     *
     */
    function _removeWindow(
        uint256 windowIndex
    )
    internal
    {
        delete windows[windowIndex];
    }

    /**
     * @dev CalculateStakeReward is used to calculate how much a user should be rewarded for their stakes
     * and the duration the stake has been active
     *
     * @param timestamp: claim creating date
     * @param daysCount: days count for token blocks
     */
    function _calculateStakeTimestamp(
        uint256 timestamp,
        uint256 daysCount
    )
    internal
    view
    returns(uint256)
    {
        return timestamp.add(daysCount.mul(1 days));
    }

    /**
     * @dev Create new stake holder
     *
     * @param staker: user address
     */
    function _addStakeholder(
        address staker
    )
    internal
    returns (uint256)
    {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex;
    }

    /**
     * @dev Create new stake by window index
     *
     * @param sender: user address
     * @param _amount: amount to adding
     * @param _windowIndex: window index
     */
    function _stake(
        address sender,
        uint256 _amount,
        uint256 _windowIndex
    ) internal {
        require(_time() > 0, "_time() should be > 0");
        require(_amount > 0, "Cannot stake nothing");

        uint256 index = stakes[sender];
        Window memory window = windows[_windowIndex];
        Stake[] memory all_stakes_arr = stakeholders[stakes[sender]].address_stakes;
        uint256 stakeDays = window.blockedDaysCount;

        require(windows[_windowIndex].claimedSum.add(_amount) <= window.maxSum, "max sum for claimed is reached");

        bool hasWindow = false;

        for (uint256 s = 0; s < all_stakes_arr.length; s++) {
            if (all_stakes_arr[s].window_index == _windowIndex) {
                hasWindow = true;
            }
        }

        require(hasWindow == false, "window already staked");

        uint256 reward = window.rewardPerDay;

        uint256 timestamp = _time();
        uint256 unblock_timestamp = _calculateStakeTimestamp(timestamp, stakeDays);

        if (index == 0) {
            index = _addStakeholder(sender);
        }

        b8dToken.transferFrom(address(sender), address(this), _amount);

        stakeholders[index].address_stakes.push(Stake(sender, _amount, timestamp, unblock_timestamp, timestamp, _windowIndex, reward, 0));

        windows[_windowIndex].claimedSum = windows[_windowIndex].claimedSum.add(_amount);

        emit Staked(sender, _amount, index, timestamp, unblock_timestamp, _windowIndex, reward);
    }

    /**
     * @dev Add tokens to actual stake by stake index
     *
     * @param sender: user address
     * @param _amount: amount to adding
     * @param _windowIndex: window index
     * @param _stakeIndex: stake index
     */
    function _addToStake(
        address sender,
        uint256 _amount,
        uint256 _windowIndex,
        uint256 _stakeIndex
    ) internal {
        require(_time() > 0, "_time() should be > 0");
        require(_amount > 0, "Cannot stake nothing");

        uint256 index = stakes[sender];
        Window memory window = windows[_windowIndex];

        require(windows[_windowIndex].claimedSum.add(_amount) <= window.maxSum, "max sum for claimed is reached");

        uint256 stakeDays = window.blockedDaysCount;
        uint256 reward = window.rewardPerDay;

        uint256 timestamp = _time();
        uint256 unblock_timestamp = _calculateStakeTimestamp(timestamp, stakeDays);

        b8dToken.transferFrom(address(sender), address(this), _amount);

        uint256 stakedAmount = stakeholders[index].address_stakes[_stakeIndex].amount;

        stakeholders[index].address_stakes[_stakeIndex].amount = stakedAmount + _amount;
        stakeholders[index].address_stakes[_stakeIndex].since = timestamp;
        stakeholders[index].address_stakes[_stakeIndex].unblock_date = unblock_timestamp;
        stakeholders[index].address_stakes[_stakeIndex].last_claim = timestamp;

        windows[_windowIndex].claimedSum = windows[_windowIndex].claimedSum + _amount;

        emit Staked(msg.sender, _amount, index, timestamp, unblock_timestamp, _windowIndex, reward);
    }

    /**
     * @dev CalculateStakeReward is used to calculate how much a user should be rewarded for their stakes
     * and the duration the stake has been active
     *
     * @param _current_stake: current stake object
     */
    function _calculateStakeReward(
        Stake memory _current_stake
    )
    internal
    view
    returns(uint256)
    {
        require(_time() > 0, "_time() should be > 0");

        uint256 timestamp = _time();
        return (((timestamp.sub(_current_stake.last_claim)).div(1 days)).mul(_current_stake.amount)).div(_current_stake.reward);
    }

    /**
     * @dev withdraw all staked tokens and rewards by stake index
     *
     * @param sender: user address
     * @param _stakeIndex: stake index
     */
    function _unStake(
        address sender,
        uint256 _stakeIndex
    )
    internal
    {
        require(_time() > 0, "_time() should be > 0");

        uint256 timestamp = _time();
        uint256 user_index = stakes[sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[_stakeIndex];

        uint256 amount = current_stake.amount;
        uint256 penalty;
        uint256 reward = _calculateStakeReward(current_stake);

        if (current_stake.unblock_date > timestamp) {
            penalty = amount.div(100).mul(penaltyPercent);
        }

        uint256 totalAmount = amount + reward - penalty;

        b8dToken.transfer(sender, totalAmount);

        delete stakeholders[user_index].address_stakes[_stakeIndex];

        windows[current_stake.window_index].claimedSum = windows[current_stake.window_index].claimedSum - amount;

        emit UnStaked(msg.sender, totalAmount, timestamp, current_stake.window_index, current_stake.reward);
    }

    /**
     * @dev Claim rewards by stake index
     *
     * @param sender: user address
     * @param _stakeIndex: stake index
     */
    function _claim(
        address sender,
        uint256 _stakeIndex
    )
    internal
    {
        require(_time() > 0, "_time() should be > 0");
        require(claimingEnabled == true, "claimingEnabled should be == true");

        uint256 timestamp = _time();

        uint256 user_index = stakes[sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[_stakeIndex];

        uint256 since_timestamp = current_stake.since;
        uint256 days_claim_count = uint(timestamp.sub(since_timestamp)).div(1 days);
        uint256 claim_timestamp = since_timestamp.add(days_claim_count.mul(1 days));

        uint256 reward = _calculateStakeReward(current_stake);

        require(reward > 0, "reward is missing");

        b8dToken.transfer(sender, reward);

        stakeholders[user_index].address_stakes[_stakeIndex].last_claim = claim_timestamp;

        emit Claimed(sender, reward, timestamp, days_claim_count, claim_timestamp, current_stake.window_index, current_stake.reward);
    }

    /**
     * @dev Claim all rewards by all windows
     *
     * @param sender: user address
     */
    function _claimAll(
        address sender
    )
    internal
    {
        require(_time() > 0, "_time() should be > 0");
        require(claimingEnabled == true, "claimingEnabled should be == true");

        uint256 timestamp = _time();

        uint256 user_index = stakes[sender];

        require(user_index > 0, "staker is not found");

        Stake[] memory stakes_arr = stakeholders[user_index].address_stakes;

        require(stakes_arr.length > 0, "stakes not found");

        uint256 reward;

        for (uint256 s = 0; s < stakes_arr.length; s++) {
            uint256 availableReward = _calculateStakeReward(stakes_arr[s]);
            reward = reward.add(availableReward);

            if (availableReward > 0) {
                uint256 since_timestamp = stakes_arr[s].last_claim;
                uint256 days_claim_count = uint(timestamp.sub(since_timestamp)).div(1 days);
                uint256 claim_timestamp = since_timestamp.add(days_claim_count.mul(1 days));

                stakeholders[user_index].address_stakes[s].last_claim = claim_timestamp;

                emit Claimed(sender, availableReward, timestamp, days_claim_count, claim_timestamp, stakes_arr[s].window_index, stakes_arr[s].reward);
            }
        }

        require(reward > 0, "reward is missing");

        b8dToken.transfer(sender, reward);
    }

    /** @dev Collect Tokens to owner
     *
     */
    function _collect() internal {
        require(_time() > 0, "_time() should be > 0");

        uint256 balance = b8dToken.balanceOf(address(this));

        require(balance > 0, "unsoldTokens should be > 0");

        b8dToken.transfer(owner(), balance);
    }

    /** @dev Start and Stop claiming
     *
     */
    function _startStopClaiming() internal {
        if (claimingEnabled) {
            claimingEnabled = false;
        } else {
            claimingEnabled = true;
        }
    }

    /** @dev Setting new penalty percent
     *
     * @param _newPenaltyPercent: new Penalty Percent
     */
    function _setPenaltyPercent(
        uint256 _newPenaltyPercent
    ) internal {
        penaltyPercent = _newPenaltyPercent;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IB8DexStake {

    /**
     * @notice Staked windows object
     */
    struct Window {
        uint256 blockedDaysCount;
        uint256 rewardPerDay;
        uint256 maxSum;
        uint256 claimedSum;
    }

    /**
     * @notice
     * A stake struct is used to represent the way we store stakes,
     * A Stake will contain the users address, the amount staked and a timestamp,
     * Since which is when the stake was made
     */
    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        uint256 unblock_date;
        uint256 last_claim;
        uint256 window_index;
        uint256 reward;
        uint256 claimable;
    }

    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        Stake[] stakes;
    }

    /**
     * @notice Add new staked windows
     *
     * @param blockedDaysCount: blocked days count
     * @param rewardPerDay: reward percent per day
     * @param maxSum: max sum claiming
     * @dev Callable by owner
     */
    function addWindow(
        uint256 blockedDaysCount,
        uint256 rewardPerDay,
        uint256 maxSum
    ) external;

    /**
     * @notice Update staked windows
     *
     * @param windowIndex: window index
     * @param blockedDaysCount: blocked days count
     * @param rewardPerDay: reward percent per day
     * @param maxSum: max sum claiming
     * @dev Callable by owner
     */
    function updateWindow(
        uint256 windowIndex,
        uint256 blockedDaysCount,
        uint256 rewardPerDay,
        uint256 maxSum
    ) external;

    /** @notice Remove staked windows
     *
     * @param windowIndex: window index
     *
     */
    function removeWindow(
        uint256 windowIndex
    )
    external;

    /** @notice Getting windows information
     *
     */
    function getWindow(
        uint256 _windowIndex
    )
    external
    view
    returns(Window memory);

    /** @dev Getting windows information
     *
     */
    function getWindows()
    external
    view
    returns(Window[] memory);

    /**
     * @notice Create new stake by window index
     *
     * @param _amount: amount to adding
     * @param _windowIndex: window index
     * @dev Callable by users
     */
    function stake(
        uint256 _amount,
        uint256 _windowIndex
    ) external;

    function addToStake(
        uint256 _amount,
        uint256 _windowIndex,
        uint256 _stakeIndex
    ) external;

    /**
     * @notice withdraw all staked tokens and rewards by stake index
     *
     * @param _stakeIndex: stake index
     * @dev Callable by users
     */
    function unStake(
        uint256 _stakeIndex
    ) external;

    /**
     * @notice Claim rewards by stake index
     *
     * @param _stakeIndex: stake index
     * @dev Callable by users
     *
     */
    function claim(
        uint256 _stakeIndex
    ) external;

    /**
     * @notice Claim all rewards by all windows
     * @dev Callable by users
     *
     */
    function claimAll() external;

    /**
     * @notice hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     *
     * @param _staker: user address
     * @dev Callable by users
     *
     */
    function hasStake(
        address _staker
    )
    external
    view
    returns(StakingSummary memory);

    /**
     * @notice hasStakeWindow is used to check if a account has stakes  for window and the total window amount
     *
     * @param _staker: user address
     * @param _windowIndex: window index
     * @dev Callable by users
     *
     */
    function hasStakeWindow(
        address _staker,
        uint256 _windowIndex
    )
    external
    view
    returns(Stake memory);

    /**
     * @notice Collect tokens to owner
     * @dev Callable by owner
     *
     */
    function collect()
    external;

    /** @notice Setting new penalty percent
     *
     * @param _newPenaltyPercent: new Penalty Percent
     * @dev Callable by owner
     *
     */
    function setPenaltyPercent(
        uint256 _newPenaltyPercent
    )
    external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IB8DToken is IERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     */
    function burn(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}