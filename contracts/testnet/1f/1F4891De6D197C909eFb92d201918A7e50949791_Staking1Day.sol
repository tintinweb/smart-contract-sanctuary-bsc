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
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

abstract contract Staking {
    address public immutable token; // Address of the token to be used for the stake
    uint32 public immutable maturationDays; // Number of days that must elapse after a deposit before an investor can unstake without penalty
    uint32 public immutable startingBurnRate; // The initial burn rate, which will decrease over time until maturation
    uint32 public immutable rewardRate; // A multiplier applied to the staking amount, used to calculate the reward tokens due to an investor at maturation

    uint32 constant PRECISION = 1000;
    uint32 constant DAY = 86_400;

    event StakeDeposited(
        address indexed staker, // Address of the investor who deposited the stake
        uint256 stakeIndex, // Index of the stake that was deposited
        uint256 amount, // Amount of stake tokens deposited
        uint256 maturationDate // Date the stake will mature
    );

    event StakeWithdrawn(
        address indexed staker, // Address of the investor who withdrew the stake
        uint256 stakeIndex, // Index of the stake that was withdrawn
        uint256 stakeWithdrawn, // Amount of stake tokens withdrawn
        uint256 stakeBurnt // Amount of stake tokens burnt
    );

    event RewardClaimed(
        address indexed staker, // Address of the investor who claimed the reward
        uint256 stakeIndex, // Index of the stake for which rewards were claimed
        uint256 amount // Amount of reward tokens claimed
    );
    
    struct Stake {
        uint256 amount; // Amount staked
        uint256 reward; // Total reward due at maturation
        address staker; // Address that made the stake
        uint256 startDate; // Date the stake was made
        uint256 maturationDate; // Date the stake will mature
        uint256 dateWithdrawn; // Date the stake was withdrawn (0 if not withdrawn)
        uint256 totalRewardClaimed; // Total reward claimed so far
        uint256 stakeBurnt; // Total amount burnt on premature withdrawal
    }

    // Mapping of investor address to array of stakes. Each investor can have multiple stakes.
    mapping (address => Stake[]) internal stakes;
    
    // Array of all investor addresses
    address[] investors;

    /*
    * @notice Constructor
    * @param token Address of the token to be used for the stake
    * @param maturationDays Number of days that must elapse after a deposit before an investor can unstake without penalty
    * @param startingBurnRate The initial burn rate, which will decrease over time until maturation. Precision 1000 (e.g., 2% = 2_000, 100% = 100_000)
    * @param rewardRate A multiplier applied to the staking amount, used to calculate the reward tokens due to an investor at maturation. Precision 1000 (e.g., 2% = 2_000, 100% = 100_000)
    */
    constructor(address token_, uint32 maturationDays_, uint32 startingBurnRate_, uint32 rewardRate_) {
        token = token_;
        maturationDays = maturationDays_;
        startingBurnRate = startingBurnRate_;
        rewardRate = rewardRate_;
    }

    /*
    * @notice Get the caller's stake by index
    * @param index Index of the stake
    * @return Stake struct
    */
    function getStake(uint256 index) public view returns (Stake memory) {
        Stake memory stake = stakes[address(msg.sender)][index];
        require(stake.startDate > 0, "Stake does not exist");
        return stake;
    }

    /*
    * @notice Get the stake of an investor by index
    * @param investor Address of the investor
    * @param index Index of the stake
    * @return Stake struct
    */
    function getInvestorStake(address investor, uint256 index) public view returns (Stake memory) {
        Stake memory stake = stakes[investor][index];
        require(stake.startDate > 0, "Stake does not exist");
        return stake;
    }

    /*
    * @notice Get the number of stakes deposited by the caller
    * @return Number of stakes
    */
    function getStakeCount() public view returns (uint256) {
        return stakes[address(msg.sender)].length;
    }

    /*
    * @notice Get the number of stakes deposited by an investor
    * @param investor Address of the investor
    * @return Number of stakes
    */
    function getInvestorStakeCount(address investor) public view returns (uint256) {
        return stakes[investor].length;
    }

    /*
    * @notice Get the number of investors
    * @return Number of investors
    */
    function getInvestorCount() public view returns (uint256) {
        return investors.length;
    }

    /*
    * @notice Get an investor's address by index
    * @param index Index of the investor
    * @return Address of the investor
    */
    function getInvestor(uint256 index) public view returns (address) {
        return investors[index];
    }

    /*
    * @notice Deposit a stake. The stake will be added to the caller's stakes array. It will include a maturation date which is the current date + maturationDays
    * @param amount Amount to stake
    */
    function depositStake(uint256 amount) public {
        // Check that amount is not zero
        require(amount > 0, "Amount must be greater than zero");

        // Create a new Stake and set the maturationDate to now + maturationDays
        Stake memory stake = Stake(amount, Math.mulDiv(amount, rewardRate, PRECISION * 100), address(msg.sender), block.timestamp, block.timestamp + (maturationDays * DAY), 0, 0, 0);
        
        // Add the investor to the investors array if they are not already in it
        if (stakes[address(msg.sender)].length == 0) {
            investors.push(address(msg.sender));
        }
        // Add the new Stake to the stakes array
        stakes[address(msg.sender)].push(stake);

        // Transfer the amount from the staker to the contract
        IERC20(token).transferFrom(address(msg.sender), address(this), amount);

        // Emit the StakeDeposited event
        emit StakeDeposited(address(msg.sender), stakes[address(msg.sender)].length - 1, amount, stake.maturationDate);
    }

    /*
    * @notice Calculate the amount of tokens that could be returned on a stake. This function does not change the state of the contract.
    * @param investor Address of the investor
    * @param index Index of the stake
    * @return Amount of reward that would be claimed if the investor called claimReward(index)
    */
    function previewInvestorClaimReward(address investor, uint256 index) public view returns (uint256) {
        // Get the stake 
        Stake memory stake = getInvestorStake(investor, index);

        uint256 rewardDueNow = 0;
         // If the stake has not yet matured,    
        if (stake.maturationDate > block.timestamp) {      
            // Calculate the reward due now, assuming no previous rewards have been claimed
            // Starts at 0 and increases linearly to the total reward amount over the maturation period
            uint256 timeRemaining = stake.maturationDate - block.timestamp;
            rewardDueNow = stake.reward - Math.mulDiv(stake.reward, timeRemaining, maturationDays * DAY, Math.Rounding.Up);
        } 
        // If the stake has matured, the reward due now is the total reward amount
        else {
            rewardDueNow = stake.reward;
        }
        // Return the reward due now minus the reward already claimed
        return rewardDueNow - stake.totalRewardClaimed;
    }

    /*
    * @notice Withdraw all rewards due on a stake. This function will calculate the amount of reward tokens due to the caller and transfer them to the caller's address.
    * @param index Index of the stake
    */
    function claimReward(uint256 index) public {
        // Get the stake  
        uint256 rewardAmount = previewInvestorClaimReward(address(msg.sender), index);
        require(rewardAmount > 0, "No reward to claim");

        Stake storage stake = stakes[address(msg.sender)][index];
        stake.totalRewardClaimed += rewardAmount;
        IERC20(token).transfer(stake.staker, rewardAmount); 
        emit RewardClaimed(stake.staker, index, rewardAmount);
    }

    /*
    * @notice Calculate the amount of tokens that would be withdrawn and burned on a stake. This function does not change the state of the contract.
    * @param investor Address of the investor
    * @param index Index of the stake
    * @return Amounts of tokens that would be withdrawn and would be burned if the investor called withdrawStake(index)
    */
    function previewInvestorWithdrawStake(address investor, uint256 index) public view returns (uint256, uint256) {
        // Get the stake 
        Stake memory stake = getInvestorStake(investor, index);

        // Check that the stake has not already been withdrawn
        require(stake.dateWithdrawn == 0, "Stake has already been withdrawn");

        // Calculate the burn amount. Starting burn rate is 20% and decreases linearly to 0% at maturation
        uint256 burnAmount = 0;
        if (stake.maturationDate > block.timestamp) {
            uint256 timeRemaining = stake.maturationDate - block.timestamp;
            uint256 currentBurnRate = Math.mulDiv(startingBurnRate, timeRemaining, maturationDays * DAY);
            burnAmount = Math.mulDiv(stake.amount, currentBurnRate, 100 * PRECISION, Math.Rounding.Up); 
        }
        // Calculate the amount to be withdrawn
        uint256 withdrawAmount = stake.amount - burnAmount;

        return (withdrawAmount, burnAmount);
    }

    /*
    * @notice Withdraw all tokens from a stake. Calculate the amount of tokens due to the caller and transfer them to the caller's address. It may also burn a percentage of the tokens, depending on how early the stake was withdrawn.
    * @param index Index of the stake
    */
    function withdrawStake(uint256 index) public {
        // Preview
        (uint256 withdrawAmount, uint256 burnAmount) = previewInvestorWithdrawStake(address(msg.sender), index);
        Stake storage stake = stakes[address(msg.sender)][index];

        // Burn the burn amount by sending it to address 1
        if (burnAmount > 0) {
            stake.stakeBurnt = burnAmount;
            IERC20(token).transfer(address(1), burnAmount);
        }
        stake.dateWithdrawn = block.timestamp;

        // Send the remaining amount to the staker
        IERC20(token).transfer(stake.staker, withdrawAmount);

        emit StakeWithdrawn(stake.staker, index, withdrawAmount, burnAmount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./Staking.sol";

contract Staking1Day is Staking {
    uint32 constant MATURATION_DAYS = 1;
    uint32 constant STARTING_BURN_RATE = 20_000;
    uint32 constant REWARD_RATE = 100_000;
    constructor(address _tokenAddress) Staking(_tokenAddress, MATURATION_DAYS, STARTING_BURN_RATE, REWARD_RATE) {}
}