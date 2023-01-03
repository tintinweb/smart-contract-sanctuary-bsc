// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

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
        return a > b ? a : b;
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
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

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
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT

/**
 *
 * ███████╗████████╗██╗  ██╗
 * ██╔════╝╚══██╔══╝██║  ██║
 * █████╗     ██║   ███████║
 * ██╔══╝     ██║   ██╔══██║
 * ███████╗   ██║   ██║  ██║
 * ╚══════╝   ╚═╝   ╚═╝  ╚═╝
 *
 * ███████╗ █████╗  █████╗ ████████╗ █████╗ ██████╗ ██╗   ██╗
 * ██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗╚██╗ ██╔╝
 * █████╗  ███████║██║  ╚═╝   ██║   ██║  ██║██████╔╝ ╚████╔╝
 * ██╔══╝  ██╔══██║██║  ██╗   ██║   ██║  ██║██╔══██╗  ╚██╔╝
 * ██║     ██║  ██║╚█████╔╝   ██║   ╚█████╔╝██║  ██║   ██║
 * ╚═╝     ╚═╝  ╚═╝ ╚════╝    ╚═╝    ╚════╝ ╚═╝  ╚═╝   ╚═╝
 *
 */

/**
 * @title A mining contract used for compounding rewards.
 * @notice This contract allows users to create credits with ETH. Credits are then converted into miners which in turn creates more credits. Users may then either cash out credits
 * created by the miners or reinvest to create more credits and compound their returns. Participants may use referral codes to generate credits from other participants depositing funds
 * using their referral address.
 */

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IEthPowerups {
  function calcNftMultiplier(address _address) external view returns (uint);
}

interface IEthFactory {
  function getLastCreated(address _address) external view returns (uint);
}

contract EthFactory is Ownable, ReentrancyGuard {
  constructor(address _feeReceiver, address nftAddress) {
    feeReceiver = payable(_feeReceiver);
    INFT = IEthPowerups(nftAddress);
  }

  receive() external payable {}

  /*|| === STATE VARIABLES === ||*/
  uint private marketValue;
  uint private constant CREDITS_PER_1_MINER = 1080000; /// credits needed to create one miner
  uint public depositFee = 4;
  uint public withdrawFee = 4;
  uint public refPercent = 7;
  uint public minDeposit = 0.05 ether; /// Minimum eth a wallet can deposit
  uint public startingMax = 2 ether; /// Minimum max deposit
  uint public maxInterval = .5 ether; /// Increase by when new step is hit
  uint public stepInterval = 25 ether; /// Step length between each interval
  IEthPowerups public INFT;
  address payable public feeReceiver;
  bool private initialized = false;

  /*|| === MAPPINGS === ||*/
  mapping(address => uint) private createdMiners; /// Miners are used to generate credits
  mapping(address => uint) private claimedCredits; /// credits generated from purchasing and referrals
  mapping(address => uint) private lastCreation; /// Latest timestamp credits were created
  mapping(address => address) public referral; /// Referral address code bound to deposit address
  mapping(address => uint) public investedEth; /// WEI a single wallet has deposited

  /*|| === EXTERNAL FUNCTIONS === ||*/

  function setDepositFee(uint _depositFee) external onlyOwner {
    require(_depositFee < 6, "Too high");
    depositFee = _depositFee;
  }

  function setWithdrawFee(uint _withdrawFee) external onlyOwner {
    require(_withdrawFee < 6, "Too high");
    withdrawFee = _withdrawFee;
  }

  function setRefPercent(uint _refPercent) external onlyOwner {
    require(_refPercent < 20, "Too high");
    refPercent = _refPercent;
  }

  function setMinDeposit(uint _minDeposit) external onlyOwner {
    minDeposit = _minDeposit;
  }

  function setStartingMax(uint _startingMax) external onlyOwner {
    startingMax = _startingMax;
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function setMaxInterval(uint _maxInterval) external onlyOwner {
    maxInterval = _maxInterval;
  }

  function setStepInterval(uint _stepInterval) external onlyOwner {
    stepInterval = _stepInterval;
  }

  function setFeeReceiver(address _feeReceiver) external onlyOwner {
    feeReceiver = payable(_feeReceiver);
  }

  function setNftContract(address _address) external onlyOwner {
    INFT = IEthPowerups(_address);
  }

  function ethRewards(address _address) external view returns (uint) {
    uint credits = getMyCredits(_address);
    uint rewards = calculateRewards(credits);
    return rewards;
  }

  function getMyMiners(address _address) external view returns (uint) {
    return createdMiners[_address];
  }

  function getLastCreated(address _address) external view returns (uint) {
    return lastCreation[_address];
  }

  /*|| === PUBLIC FUNCTIONS === ||*/
  function startFactory() public payable onlyOwner {
    require(marketValue == 0);
    initialized = true;
    marketValue = 108000000000;
  }

  function purchaseCredits(address ref) public payable {
    require(initialized);
    if (address(this).balance < 500 ether) {
      uint maxDeposit = (address(this).balance / stepInterval) * maxInterval + startingMax;
      require(msg.value + investedEth[msg.sender] <= maxDeposit, "Max deposit");
    }
    require(msg.value + investedEth[msg.sender] >= minDeposit, "Min deposit");

    investedEth[msg.sender] += msg.value;

    /// Calculate miners bought
    uint creditsBought = calculateCredits(msg.value, address(this).balance - msg.value);
    /// Subtract miners bought from deposit fee
    creditsBought -= Math.mulDiv(creditsBought, depositFee, 100);
    /// Calculate fee in WEI and send to the receiver address
    uint fee = Math.mulDiv(msg.value, depositFee, 100);
    feeReceiver.transfer(fee);
    /// Add miners bought to claimed miners to prepare to activate
    claimedCredits[msg.sender] += creditsBought;
    createMiners(ref);
  }

  function createMiners(address ref) public {
    require(initialized);

    if (ref == msg.sender) {
      ref = feeReceiver;
    }

    if (referral[msg.sender] == address(0) && referral[msg.sender] != msg.sender) {
      referral[msg.sender] = ref;
    }

    uint credits = getMyCredits(msg.sender);
    /// Create miners from credits generated and bought
    uint newMiners = credits / CREDITS_PER_1_MINER;
    /// Add created miners to mapping
    createdMiners[msg.sender] += newMiners;
    /// Reset claimed credits
    claimedCredits[msg.sender] = 0;
    /// Reset last created time
    lastCreation[msg.sender] = block.timestamp;
    /// Send profit to referral address
    claimedCredits[referral[msg.sender]] += Math.mulDiv(credits, refPercent, 100);
    /// Boost market to nerf miners hoarding
    marketValue = marketValue + (credits / (5));
  }

  function claimRewards() public nonReentrant {
    require(initialized);
    /// Get current credits
    uint credits = getMyCredits(msg.sender);
    /// Get rewards generated
    uint rewards = calculateRewards(credits);
    require(rewards > 0, "No rewards");
    /// Calculate withdraw fees
    uint fee = Math.mulDiv(rewards, withdrawFee, 100);
    /// Reset claimed credits
    claimedCredits[msg.sender] = 0;
    /// Reset last created time
    lastCreation[msg.sender] = block.timestamp;
    /// Increase market value by the number of credits sold
    marketValue += credits;
    /// Transfer withdraw fee to fee receiver
    feeReceiver.transfer(fee);
    payable(msg.sender).transfer(rewards - fee);
  }

  function calculateRewards(uint rewards) public view returns (uint) {
    return calculateTrade(rewards, marketValue, address(this).balance);
  }

  function calculateCredits(uint eth, uint contractBalance) public view returns (uint) {
    return calculateTrade(eth, contractBalance, marketValue);
  }

  function calculateCreditsSimple(uint eth) public view returns (uint) {
    return calculateCredits(eth, address(this).balance);
  }

  function getMyCredits(address _address) public view returns (uint) {
    uint createdCredits = getCreditsSinceLastCreation(_address);
    return claimedCredits[_address] + createdCredits + Math.mulDiv(createdCredits, INFT.calcNftMultiplier(_address), 100);
  }

  function getCreditsSinceLastCreation(address _address) public view returns (uint) {
    uint secondsPassed = calculateMin(CREDITS_PER_1_MINER, (block.timestamp - lastCreation[_address]));
    return secondsPassed * createdMiners[_address];
  }

  /*|| === PRIVATE FUNCTIONS === ||*/
  function calculateTrade(uint x, uint y, uint z) private pure returns (uint) {
    return (10000 * z) / (5000 + (((10000 * y) + (5000 * x)) / x));
  }

  function calculateMin(uint a, uint b) private pure returns (uint) {
    return a < b ? a : b;
  }
}