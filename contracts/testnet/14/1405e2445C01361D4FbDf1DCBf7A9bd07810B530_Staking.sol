//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./TransferHelper.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IStaking.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract Staking is Context, IStaking, ReentrancyGuard {
    uint16 public constant DENOMINATOR = 10000;

    address public immutable factory;

    PoolInfo public poolInfo;

    mapping(address => UserInfo) public userInfo;

    event Staked(address user, uint256 amount);
    event Withdrawn(address user, uint256 amount);
    event RewardPaid(address user, uint256 amount);

    constructor(address _factory) {
        require(_factory != address(0), "Staking: Address 0x00...");
        factory = _factory;
    }

    modifier onlyFactory() {
        require(_msgSender() == factory, "Staking: Not factory sender");
        _;
    }

    modifier upcomingOrActiveStatus() {
        require(
            block.timestamp < poolInfo.generalInfo.endTime,
            "Staking: Complete status"
        );
        _;
    }

    modifier activeStatus() {
        require(
            block.timestamp >= poolInfo.generalInfo.startTime &&
                block.timestamp < poolInfo.generalInfo.endTime,
            "Staking: Not active status"
        );
        _;
    }

    modifier activeOrCompleteStatus() {
        require(
            block.timestamp >= poolInfo.generalInfo.startTime,
            "Staking: Upcoming status"
        );
        _;
    }

    modifier upcomingStatus() {
        require(
            block.timestamp < poolInfo.generalInfo.startTime,
            "Staking: Not upcoming status"
        );
        _;
    }

    modifier completeStatus() {
        require(
            block.timestamp >= poolInfo.generalInfo.endTime,
            "Staking: Not completed status"
        );
        _;
    }

    /**
     * @dev Modifier to update reward variables
     * @param account user address or 0x00...
     */
    modifier updateReward(address account) {
        uint256 stockTokens;
        UserInfo storage user = userInfo[account];
        (poolInfo.rewardPerTokenStored, stockTokens) = rewardPerToken();
        poolInfo.lastUpdateTime = lastTimeRewardApplicable();
        if (stockTokens > 0)
            TransferHelper.safeTransfer(
                poolInfo.generalInfo.rewardToken,
                factory,
                stockTokens
            );
        if (account != address(0)) {
            user.rewards = earned(account);
            user.userRewardPerTokenPaid = poolInfo.rewardPerTokenStored;
        }
        _;
    }

    /** @dev Allows factory to put necessary parmeters
     * @notice factory only available
     * @param info new staking pool parameters
     */
    function initialize(GeneralInfo memory info) external override onlyFactory {
        require(!poolInfo.initialized, "Staking: Already initialized");
        poolInfo.initialized = true;
        poolInfo.multiplier = 10**IERC20Metadata(info.stakedToken).decimals();
        poolInfo.generalInfo = info;
    }

    /** @dev Get last timestamp of reward issue
     * @return minimum between now and endTime variable
     */
    function lastTimeRewardApplicable() public view returns (uint256) {
        if (block.timestamp < poolInfo.generalInfo.startTime) return 0;
        return Math.min(block.timestamp, poolInfo.generalInfo.endTime);
    }

    /** @dev Get current rate per 1 token
     * @return the current rate of the reward for the token at the current moment
     */
    function rewardPerToken() public view returns (uint256, uint256) {
        if (block.timestamp < poolInfo.generalInfo.startTime) return (0, 0);
        if (poolInfo.totalStaked == 0) {
            return (
                poolInfo.rewardPerTokenStored,
                poolInfo.generalInfo.rewardPerSecond *
                    (lastTimeRewardApplicable() -
                        Math.max(
                            poolInfo.generalInfo.startTime,
                            poolInfo.lastUpdateTime
                        ))
            );
        }
        return (
            poolInfo.rewardPerTokenStored +
                (((lastTimeRewardApplicable() - poolInfo.lastUpdateTime) *
                    poolInfo.generalInfo.rewardPerSecond *
                    poolInfo.multiplier) / poolInfo.totalStaked),
            0
        );
    }

    /** @dev Get current reward for the user
     * @param account user address
     * @return the current amount of rewards for the current user
     */
    function earned(address account) public view returns (uint256) {
        (uint256 currentRewardPerToken, ) = rewardPerToken();
        return
            (userInfo[account].balance *
                (currentRewardPerToken -
                    userInfo[account].userRewardPerTokenPaid)) /
            poolInfo.multiplier +
            userInfo[account].rewards;
    }

    /** @dev Get fee unstake amount for the current user at this moment
     * @param account user address
     * @param amount unstake amount
     * @return fee unstake amount
     */
    function earlyUnstakePenalty(address account, uint256 amount)
        public
        view
        returns (uint256)
    {
        if (
            block.timestamp <
            userInfo[account].stakeStart + poolInfo.generalInfo.minStakingTime
        ) {
            return
                (amount * poolInfo.generalInfo.earlyUnstakePenalty) /
                DENOMINATOR;
        } else return 0;
    }

    /** @dev Get user staked balance (for Factory contarct generally)
     * @param user user address
     * @return user balance
     */
    function userBalance(address user) external view returns (uint256) {
        return userInfo[user].balance;
    }

    /** @dev Function for deposit action
     * @notice stake visibility is public as overriding LPTokenWrapper's stake() function
     * @param amount value of deposit
     */
    function stake(uint256 amount)
        external
        activeStatus
        updateReward(_msgSender())
        nonReentrant
    {
        require(amount > 0, "Staking: Cannot stake 0");
        poolInfo.totalStaked += amount;
        UserInfo storage user = userInfo[_msgSender()];
        if (user.balance == 0) IFactory(factory).addActualStaking(_msgSender());
        user.balance += amount;
        user.stakeStart = block.timestamp;
        TransferHelper.safeTransferFrom(
            poolInfo.generalInfo.stakedToken,
            _msgSender(),
            address(this),
            amount
        );
        emit Staked(_msgSender(), amount);
    }

    /** @dev Function for withdraw action
     * @notice withdraw visibility is public as overriding LPTokenWrapper's withdraw() function
     * @param amount value of claim
     */
    function withdraw(uint256 amount)
        public
        activeOrCompleteStatus
        updateReward(_msgSender())
        nonReentrant
    {
        UserInfo storage user = userInfo[_msgSender()];
        require(
            amount > 0 && user.balance >= amount,
            "Staking: Cannot withdraw 0 || You have not enough balance"
        );
        poolInfo.totalStaked -= amount;
        user.balance -= amount;
        if (user.balance == 0)
            IFactory(factory).removeFromActualStaking(_msgSender());
        uint256 fee = earlyUnstakePenalty(_msgSender(), amount);
        if (fee > 0) {
            TransferHelper.safeTransfer(
                poolInfo.generalInfo.stakedToken,
                poolInfo.generalInfo.feeTo,
                fee
            );
        }
        TransferHelper.safeTransfer(
            poolInfo.generalInfo.stakedToken,
            _msgSender(),
            amount - fee
        );
        emit Withdrawn(_msgSender(), amount);
    }

    /** @dev Function for withdraw + getReward actions
     */
    function exit() external {
        getReward();
        withdraw(userInfo[_msgSender()].balance);
    }

    /** @dev Function for claim all rewards action
     */
    function getReward()
        public
        activeOrCompleteStatus
        updateReward(_msgSender())
        nonReentrant
    {
        address sender = _msgSender();
        uint256 reward = earned(sender);
        if (reward > 0) {
            userInfo[sender].rewards = 0;
            TransferHelper.safeTransfer(
                poolInfo.generalInfo.rewardToken,
                sender,
                reward
            );
            emit RewardPaid(sender, reward);
        }
    }

    /** @dev change generalInfo.startTime pool parameter
     * @notice factory only available && upcoming status only
     * @param newStartTime new value
     */
    function changeStartTime(uint256 newStartTime)
        external
        override
        onlyFactory
        upcomingStatus
        updateReward(address(0))
        nonReentrant
    {
        require(
            block.timestamp <= newStartTime &&
                poolInfo.generalInfo.startTime != newStartTime &&
                newStartTime + poolInfo.generalInfo.minStakingTime <=
                poolInfo.generalInfo.endTime,
            "Staking: Wrong newStartTime value"
        );

        if (newStartTime > poolInfo.generalInfo.startTime) {
            TransferHelper.safeTransfer(
                poolInfo.generalInfo.rewardToken,
                tx.origin,
                (newStartTime - poolInfo.generalInfo.startTime) *
                    poolInfo.generalInfo.rewardPerSecond
            );
        } else {
            TransferHelper.safeTransferFrom(
                poolInfo.generalInfo.rewardToken,
                tx.origin,
                address(this),
                (poolInfo.generalInfo.startTime - newStartTime) *
                    poolInfo.generalInfo.rewardPerSecond
            );
        }
        poolInfo.generalInfo.startTime = newStartTime;
    }

    /** @dev change generalInfo.endTime pool parameter
     * @notice (factory only available) && (upcoming || active status only)
     * @param newEndTime new value
     */
    function changeEndTime(uint256 newEndTime)
        external
        override
        onlyFactory
        upcomingOrActiveStatus
        updateReward(address(0))
        nonReentrant
    {
        require(
            block.timestamp <= newEndTime &&
                poolInfo.generalInfo.endTime != newEndTime &&
                newEndTime >=
                poolInfo.generalInfo.minStakingTime +
                    poolInfo.generalInfo.startTime,
            "Staking: Wrong newEndTime value"
        );

        if (newEndTime > poolInfo.generalInfo.endTime) {
            TransferHelper.safeTransferFrom(
                poolInfo.generalInfo.rewardToken,
                tx.origin,
                address(this),
                (newEndTime - poolInfo.generalInfo.endTime) *
                    poolInfo.generalInfo.rewardPerSecond
            );
        } else {
            TransferHelper.safeTransfer(
                poolInfo.generalInfo.rewardToken,
                tx.origin,
                (poolInfo.generalInfo.endTime - newEndTime) *
                    poolInfo.generalInfo.rewardPerSecond
            );
        }
        poolInfo.generalInfo.endTime = newEndTime;
    }

    /** @dev change generalInfo.rewardPerSecond pool parameter
     * @notice (factory only available) && (upcoming || active status only)
     * @param newRewardPerSecond new value
     */
    function changeRewardPerSecond(uint256 newRewardPerSecond)
        external
        override
        onlyFactory
        upcomingOrActiveStatus
        updateReward(address(0))
        nonReentrant
    {
        require(
            newRewardPerSecond > 0 &&
                newRewardPerSecond != poolInfo.generalInfo.rewardPerSecond,
            "Staking: Wrong newRewardPerSecond value"
        );

        uint256 leftBoarder = (block.timestamp > poolInfo.generalInfo.startTime)
            ? block.timestamp
            : poolInfo.generalInfo.startTime;

        if (newRewardPerSecond > poolInfo.generalInfo.rewardPerSecond) {
            TransferHelper.safeTransferFrom(
                poolInfo.generalInfo.rewardToken,
                tx.origin,
                address(this),
                (newRewardPerSecond - poolInfo.generalInfo.rewardPerSecond) *
                    (poolInfo.generalInfo.endTime - leftBoarder)
            );
        } else {
            TransferHelper.safeTransfer(
                poolInfo.generalInfo.rewardToken,
                tx.origin,
                (poolInfo.generalInfo.rewardPerSecond - newRewardPerSecond) *
                    (poolInfo.generalInfo.endTime - leftBoarder)
            );
        }
        poolInfo.generalInfo.rewardPerSecond = newRewardPerSecond;
    }

    /** @dev change generalInfo.earlyUnstakePenalty pool parameter
     * @notice (factory only available) && (upcoming || active status only)
     * @param newFee new value
     */
    function changeEarlyUnstakeFee(uint16 newFee)
        external
        override
        onlyFactory
        upcomingOrActiveStatus
        updateReward(address(0))
    {
        require(
            newFee <= DENOMINATOR &&
                newFee != poolInfo.generalInfo.earlyUnstakePenalty,
            "Staking: Wrong newFee value"
        );
        poolInfo.generalInfo.earlyUnstakePenalty = newFee;
    }

    /** @dev change generalInfo.minStakingTime pool parameter
     * @notice (factory only available) && (upcoming || active status only)
     * @param newMinStakingTime new value
     */
    function changeMinStakingTime(uint256 newMinStakingTime)
        external
        override
        onlyFactory
        upcomingOrActiveStatus
        updateReward(address(0))
    {
        require(
            poolInfo.generalInfo.minStakingTime != newMinStakingTime &&
                poolInfo.generalInfo.startTime + newMinStakingTime <=
                poolInfo.generalInfo.endTime,
            "Staking: Wrong newMinStakingTime value"
        );
        poolInfo.generalInfo.minStakingTime = newMinStakingTime;
    }

    /** @dev allows to claim extra reward tokens (in case when at the end of the staking
     * there is no stakers (poolInfo.totalStaked == 0))
     * @notice (factory only available) && (upcoming || complete status only)
     */
    function claimExtraRewards() external override onlyFactory completeStatus {
        require(poolInfo.totalStaked == 0, "Staking: Not empty pool");
        (, uint256 stockTokens) = rewardPerToken();
        require(stockTokens > 0, "Staking: There are no extra tokens");
        poolInfo.lastUpdateTime = block.timestamp;
        TransferHelper.safeTransfer(
            poolInfo.generalInfo.rewardToken,
            tx.origin,
            stockTokens
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IFactory {
    function addActualStaking(address user) external;

    function removeFromActualStaking(address user) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IStruct.sol";

interface IStaking is IStruct {
    function initialize(GeneralInfo memory info) external;

    function changeStartTime(uint256 newStartTime) external;

    function changeEndTime(uint256 newEndTime) external;

    function changeRewardPerSecond(uint256 newRewardPerSecond) external;

    function changeEarlyUnstakeFee(uint16 newFee) external;

    function changeMinStakingTime(uint256 newMinStakingTime) external;

    function claimExtraRewards() external;

    // function userInfo(address user) external view returns (UserInfo memory);
    function userBalance(address user) external view returns (uint256);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
     * by making the `nonReentrant` function external, and making it call a
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IStruct {
    struct GeneralInfo {
        address stakedToken;
        address rewardToken;
        address feeTo;
        uint256 startTime;
        uint256 endTime;
        uint256 minStakingTime;
        uint256 rewardPerSecond;
        uint16 earlyUnstakePenalty;
    }

    struct UserInfo {
        uint256 balance;
        uint256 userRewardPerTokenPaid;
        uint256 rewards;
        uint256 stakeStart;
    }

    struct PoolInfo {
        bool initialized;
        uint256 totalStaked;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 multiplier;
        GeneralInfo generalInfo;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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