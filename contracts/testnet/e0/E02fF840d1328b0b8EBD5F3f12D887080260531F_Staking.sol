//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Vesting.sol";
import "./interfaces/IStaking.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

uint8 constant YEARLY_STAKING_WEIGHTS = (13 * 12) / 2;
uint256 constant SECONDS_IN_MONTH = 30 * 24 * 60 * 60;
uint8 constant YEAR_IN_MONTHS = 12;

contract Staking is Ownable, Pausable {
    struct ApyMontlyStep {
        uint64 percentage;
        uint64 resolution;
    }

    struct StakingAllocation {
        bool taken;
        uint64 apyMontlyStepId;
        uint256 from;
        uint256 amount;
    }

    struct StakingAllocationReport {
        StakingAllocation allocation;
        uint256 currentReward;
    }

    event RewardPoolChanged(uint256 prev, uint256 curr);
    event ApyMonthlyStepChanged(ApyMontlyStep prev, ApyMontlyStep curr);
    event Staked(address indexed addr, uint256 indexed amount);
    event SentToVesting(address indexed addr, uint256 amount, uint256 duration);
    event Withdrawn(address indexed addr, uint256 amount);

    uint64 public apysMontlyStepCount;
    IERC20 public token;
    IVesting public vesting;
    uint256 public rewardPool;
    uint256 public vestingDuration;

    uint256 internal maximalRewardCalculated;

    mapping(uint64 => ApyMontlyStep) public apyConfiurations;
    mapping(address => uint64) public addrStakingAllocationsCount;
    mapping(address => mapping(uint64 => StakingAllocation))
        public addrStakingAllocations;

    constructor(
        address tokenAddr_,
        address vestingAddr_,
        uint256 rewardPool_,
        uint256 vestingDuration_
    ) {
        token = IERC20(tokenAddr_);
        vesting = IVesting(vestingAddr_);
        rewardPool = rewardPool_;
        vestingDuration = vestingDuration_;
    }

    function updateRewardPool(uint256 rewardPool_) external onlyOwner {
        emit RewardPoolChanged(rewardPool, rewardPool_);
        rewardPool = rewardPool_;
    }

    function setNewApyMonthlyStep(uint64 percentage, uint64 resolution)
        external
        onlyOwner
    {
        ApyMontlyStep memory newMonthlyStep = ApyMontlyStep(
            percentage,
            resolution
        );

        emit ApyMonthlyStepChanged(
            apyConfiurations[apysMontlyStepCount],
            newMonthlyStep
        );

        apysMontlyStepCount += 1;
        apyConfiurations[apysMontlyStepCount] = newMonthlyStep;
    }

    function stakingAllocationsReportsForAddress(address addr)
        public
        view
        returns (StakingAllocationReport[] memory)
    {
        return stakingAllocationsReportsForAddress_(addr, block.timestamp);
    }

    function stakingAllocationsReportsForAddress_(
        address addr,
        uint256 timestamp
    ) internal view returns (StakingAllocationReport[] memory) {
        uint64 allocationsAmount = addrStakingAllocationsCount[addr];
        StakingAllocationReport[]
            memory reports = new StakingAllocationReport[](allocationsAmount);

        for (uint64 iteration = 0; iteration < allocationsAmount; ++iteration) {
            StakingAllocation memory currentAllocation = addrStakingAllocations[
                addr
            ][iteration + 1];

            if (currentAllocation.taken) {
                reports[iteration] = StakingAllocationReport(
                    currentAllocation,
                    0
                );
            } else {
                uint256 currentReward = calculationRewardFromAllocation(
                    currentAllocation,
                    timestamp
                );
                reports[iteration] = StakingAllocationReport(
                    currentAllocation,
                    currentReward
                );
            }
        }

        return reports;
    }

    function stake(uint256 amount) external {
        stake_(_msgSender(), block.timestamp, amount);
    }

    function maximalRewardToTakeFromAddrAllocation(
        address addr,
        uint64 allocationId
    ) public view returns (uint256) {
        require(
            addrStakingAllocationsCount[addr] >= allocationId,
            "Allocation doesn't exist for address"
        );

        StakingAllocation memory stakingAllocation = addrStakingAllocations[
            addr
        ][allocationId];

        return
            maximalRewardToTakeFromApyMonthlyStep(
                stakingAllocation.apyMontlyStepId,
                stakingAllocation.amount
            );
    }

    function maximalRewardToTake(uint256 amount) public view returns (uint256) {
        return
            maximalRewardToTakeFromApyMonthlyStep(apysMontlyStepCount, amount);
    }

    function maximalRewardToTakeFromApyMonthlyStep(uint64 apyId, uint256 amount)
        public
        view
        returns (uint256)
    {
        ApyMontlyStep memory monthlyStep = apyConfiurations[apyId];
        uint256 inFirstMonthReward = (amount * monthlyStep.percentage) /
            monthlyStep.resolution /
            YEAR_IN_MONTHS;
        return inFirstMonthReward * YEARLY_STAKING_WEIGHTS;
    }

    function calculationRewardFromAllocation(
        StakingAllocation memory allocation,
        uint256 timestamp
    ) public view returns (uint256) {
        ApyMontlyStep memory monthlyStep = apyConfiurations[
            allocation.apyMontlyStepId
        ];

        uint256 timeElapsed = timestamp - allocation.from;
        uint256 fullyStakedMonths = timeElapsed / SECONDS_IN_MONTH;

        require(
            fullyStakedMonths != 0,
            "Minimal staking duration has not been exceeded"
        );

        uint256 secondsInNotFullyStakedMonth = 0;

        if (fullyStakedMonths > YEAR_IN_MONTHS) {
            fullyStakedMonths = YEAR_IN_MONTHS;
            secondsInNotFullyStakedMonth = 0;
        } else {
            secondsInNotFullyStakedMonth =
                timeElapsed -
                fullyStakedMonths *
                SECONDS_IN_MONTH;
        }

        uint256 rewardFromFullyStakendMonths = ((((fullyStakedMonths *
            (fullyStakedMonths + 1)) / 2) * allocation.amount) *
            monthlyStep.percentage) /
            monthlyStep.resolution /
            YEARLY_STAKING_WEIGHTS;
        uint256 rewardFromCurrentMonth = ((fullyStakedMonths + 1) *
            secondsInNotFullyStakedMonth *
            monthlyStep.percentage) /
            YEAR_IN_MONTHS /
            SECONDS_IN_MONTH /
            monthlyStep.resolution;
        uint256 reward = rewardFromFullyStakendMonths + rewardFromCurrentMonth;

        return reward;
    }

    function stake_(
        address addr,
        uint256 timestamp,
        uint256 amount
    ) internal whenNotPaused {
        require(amount > 0, "Cannot stake zero tokens");

        uint256 maximalReward = maximalRewardToTake(amount);

        require(
            maximalReward + maximalRewardCalculated < rewardPool,
            "Balance of reward is not small for accepting staking"
        );

        uint64 nextStakingIterationCount = addrStakingAllocationsCount[addr];

        uint64 addrStakingAllocation = nextStakingIterationCount + 1;

        addrStakingAllocations[addr][addrStakingAllocation] = StakingAllocation(
            false,
            apysMontlyStepCount,
            timestamp,
            amount
        );

        token.transferFrom(addr, address(this), amount);
        emit Staked(addr, amount);

        addrStakingAllocationsCount[addr] += 1;
        maximalRewardCalculated += maximalReward;
    }

    function withdrawFromAllocation(uint64 allocationId) external {
        withdrawFromAllocation_(_msgSender(), block.timestamp, allocationId);
    }

    function withdrawFromAllocation_(
        address addr,
        uint256 timestamp,
        uint64 allocationId
    ) internal {
        require(
            addrStakingAllocationsCount[addr] >= allocationId,
            "That allocation not exists for address"
        );

        StakingAllocation storage allocation = addrStakingAllocations[addr][
            allocationId
        ];

        require(!allocation.taken, "That allocation is already taken");

        uint256 maxRewardFromAllication = maximalRewardToTakeFromApyMonthlyStep(
            allocation.apyMontlyStepId,
            allocation.amount
        );

        uint256 reward = calculationRewardFromAllocation(allocation, timestamp);
        maximalRewardCalculated -= maxRewardFromAllication - reward;

        token.transfer(addr, allocation.amount);
        emit Withdrawn(addr, allocation.amount);

        token.approve(address(vesting), reward);
        vesting.lockOnVesting(addr, vestingDuration, reward);
        emit SentToVesting(addr, reward, vestingDuration);

        allocation.taken = true;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IVesting.sol";

contract Vesting is Context, IVesting, Ownable {
    using SafeMath for uint256;

    event VestingAdded(
        address indexed addr,
        uint256 toRealse,
        uint256 start,
        uint256 duration
    );

    struct VestingParameters {
        uint256 toRelease;
        uint256 start;
        uint256 duration;
        uint256 released;
    }

    IERC20 public vestingToken;
    uint256 public totalVested;

    mapping(address => uint256) public vestingAmounts;
    mapping(address => mapping(uint256 => VestingParameters)) public vestings;

    constructor(address vestingTokenAddr) {
        prevalidateVesting(vestingTokenAddr);

        vestingToken = IERC20(vestingTokenAddr);
    }

    function prevalidateVesting(address vestingTokenAddr) internal pure {
        require(vestingTokenAddr != address(0), "Vesting token zero address");
    }

    function vestingsOf(address addr)
        public
        view
        returns (VestingParameters[] memory)
    {
        uint256 vestingAmount = vestingAmounts[addr];
        VestingParameters[] memory vestings_ = new VestingParameters[](
            vestingAmount
        );

        for (uint256 i = 0; i < vestingAmount; ++i) {
            vestings_[i] = vestings[addr][i+1];
        }

        return vestings_;
    }

    function release() external override {
        release_(_msgSender(), block.timestamp);
    }

    function lockOnVesting(
        address addr,
        uint256 duration,
        uint256 amount
    ) external override {
        lockOnVesting(addr, block.timestamp, duration, amount);
    }

    function lockOnVesting(
        address addr,
        uint256 timestamp,
        uint256 duration,
        uint256 amount
    ) internal {
        vestingToken.transferFrom(msg.sender, address(this), amount);
        totalVested = totalVested.add(amount);
        vestingAmounts[addr] = vestingAmounts[addr].add(1);
        uint256 vestingId = vestingAmounts[addr];
        VestingParameters memory vesting = VestingParameters(
            amount,
            timestamp,
            duration,
            0
        );
        vestings[addr][vestingId] = vesting;
    }

    function release_(address addr, uint256 timestmap) internal {
        uint256 amount = combineTokenAmount_(addr, timestmap);

        vestingToken.transfer(addr, amount);
        emit Withdrawn(addr, amount);
    }

    function combineTokenAmount_(address addr, uint256 timestamp)
        internal
        returns (uint256)
    {
        uint256 amount = 0;
        uint256 vestingAmount = vestingAmounts[addr];

        for (uint256 i = 0; i < vestingAmount; i++) {
            VestingParameters storage params = vestings[addr][i + 1];

            if (params.toRelease == params.released) {
                continue;
            }

            if (timestamp > params.start) {
                uint256 timeElapsed = timestamp.sub(params.start);

                if (timeElapsed > params.duration) {
                    amount += params.toRelease;
                    params.released = params.toRelease;
                } else {
                    uint256 toRelease = timeElapsed.mul(params.toRelease).div(
                        params.duration
                    );
                    params.released = params.released.add(toRelease);
                    amount += toRelease;
                }
            }
        }

        return amount;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IStaking {
    event Staked(address indexed addr, uint256 indexed amount);
    event SentToVesting(address indexed addr, uint256 amount, uint256 duration);
    event Withdrawn(address indexed addr, uint256 amount);

    function withdraw(uint256 amount) external;
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";

interface IVesting {
    event Withdrawn(address indexed addr, uint256 amount);

    function release() external;

    function lockOnVesting(
        address addr,
        uint256 duration,
        uint256 amount
    ) external;
}