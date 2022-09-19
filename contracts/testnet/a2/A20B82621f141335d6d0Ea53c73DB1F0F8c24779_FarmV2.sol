// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./FarmV2Factory.sol";
import "./extensions/FarmV2Depositable.sol";
import "./extensions/FarmV2Withdrawable.sol";

contract FarmV2 is FarmV2Depositable, FarmV2Withdrawable, FarmV2Factory {
    /**
     * @dev The contract constructor.
     *
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor(Configuration memory config_) {
        _config = config_;
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

import "./FarmV2Context.sol";

abstract contract FarmV2Factory is FarmV2Context {
    /**
     * @dev Set the stake tokens lock status.
     */
    function setLockStatus(bool status) external onlyOwner {
        _config.isLocked = status;
    }

    /**
     * @dev Set the maximum depositable amount per account.
     */
    function setMaxDeposit(uint256 amount) external onlyOwner {
        _config.maxDeposit = amount;
    }

    /**
     * @dev Change the current rewards rate.
     */
    function setRewardsRate(uint256 value) external onlyOwner {
        if (value <= 0) {
            revert InvalidAmount();
        }

        _config.rewardsRate = value;
    }

    /**
     * @dev Set the pool start time.
     */
    function setStartTime(uint256 time) external onlyOwner {
        _config.startAt = time;
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "../FarmV2Context.sol";

// solhint-disable not-rely-on-time
abstract contract FarmV2Depositable is FarmV2Context {
    /**
     * @dev Emit when the account deposit tokens to the pool.
     */
    event Deposited(address indexed account, uint256 indexed amount);

    /**
     * @dev Deposit the tokens to the pool and start earning.
     */
    function deposit(uint256 amount) external virtual nonReentrant {
        if (!isStarted()) {
            revert PoolIsNotStarted();
        }

        address account = _msgSender();

        if (amount <= 0 || amount > maxDeposit(account)) {
            revert InvalidAmount();
        }

        // Transfer tokens to this contract.
        uint256 balanceBefore = stakeTokenBalance();

        // slither-disable-next-line reentrancy-no-eth,reentrancy-benign
        if (!stakeToken().transferFrom(account, address(this), amount)) {
            revert TransferFailed();
        }

        uint256 balanceAfter = stakeTokenBalance();

        // Get the real deposited amount if the stake token has fee.
        unchecked {
            if (balanceAfter <= balanceBefore) {
                revert TransferFailed();
            }

            uint256 realAmount = balanceAfter - balanceBefore;

            if (realAmount < amount) {
                amount = realAmount;
            }
        }

        // Save deposit informations.
        _deposits[account].push(
            Deposit({
                amount: amount,
                claimed: 0,
                harvested: 0,
                time: block.timestamp,
                lastWithdrawAt: block.timestamp,
                isEnded: false
            })
        );

        unchecked {
            _balances[account] += amount;
            _totalStaked += amount;
        }

        emit Deposited(account, amount);
    }

    /**
     * @dev Calculator the maximum depositable amount.
     */
    function available() public view virtual returns (uint256 result) {
        uint256 pool = rewardsPool();

        if (pool <= 0) {
            return 0;
        }

        unchecked {
            // slither-disable-next-line divide-before-multiply
            result = (pool * 10**decimals()) / ((apr() / 100 / YEAR) * duration());

            // Round the result to ensure the earned tokens always
            // less than rewards pool.
            uint256 denominators = 10**rewardsToken().decimals();

            // slither-disable-next-line divide-before-multiply
            result = denominators * (result / denominators);

            // Div result for rewards rate.
            result = (result * 10**decimals()) / rewardsRate();
        }

        unchecked {
            uint256 totalStaked_ = totalStaked();

            if (result <= totalStaked_) {
                return 0;
            }

            result -= totalStaked_;
        }
    }

    /**
     * @dev Returns the maximum depositable amount of the account.
     */
    function maxDeposit(address account) public view virtual returns (uint256) {
        uint256 balance = stakeToken().balanceOf(account);
        uint256 depositablePerAccount = maxDepositPerAccount();
        uint256 depositable = Math.min(balance, available());

        if (depositablePerAccount > 0) {
            uint256 staked = balanceOf(account);

            if (staked >= depositablePerAccount) {
                return 0;
            }

            unchecked {
                depositablePerAccount -= staked;
            }

            return Math.min(depositablePerAccount, depositable);
        }

        return depositable;
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

import "./FarmV2Earnable.sol";

// solhint-disable not-rely-on-time
abstract contract FarmV2Withdrawable is FarmV2Earnable {
    /**
     * @dev Emit when the account withdraw deposited tokens from the pool.
     */
    event Withdrawed(address indexed account, uint256 indexed amount);

    /**
     * @dev Withdraw the deposited tokens from the pool.
     */
    function withdraw(uint256 amount) external virtual nonReentrant {
        if (amount <= 0) {
            revert InvalidAmount();
        }

        address account = _msgSender();
        uint256 amount_ = amount;

        (Deposit[] memory deposits_, uint256 apr_, uint256 duration_, bool isLocked_) = (
            _deposits[account],
            apr(),
            duration(),
            isLocked()
        );

        unchecked {
            for (uint256 i = 0; i < deposits_.length; ++i) {
                Deposit memory deposit_ = deposits_[i];

                // If tokens is not unlocked, skip to next deposit.
                if (isLocked_ && block.timestamp < deposit_.time + duration_) {
                    continue;
                }

                if (deposit_.amount <= 0) {
                    continue;
                }

                // Update deposit informations.
                deposit_.claimed = _earned(deposit_, apr_, duration_);

                if (deposit_.claimed > 0) {
                    _totalClaimed += deposit_.claimed;
                }

                deposit_.harvested = 0;
                deposit_.lastWithdrawAt = block.timestamp;

                // Update the deposit ended status to ensure next withdraw
                // not recalculate earned on remaining amount.
                if (deposit_.lastWithdrawAt >= deposit_.time + duration_) {
                    deposit_.isEnded = true;
                }

                // Update amount.
                if (amount_ >= deposit_.amount) {
                    amount_ -= deposit_.amount;
                    deposit_.amount = 0;
                } else {
                    deposit_.amount -= amount_;
                    amount_ = 0;
                }

                _deposits[account][i] = deposit_;

                if (amount_ < deposit_.amount) {
                    break;
                }
            }
        }

        if (amount_ != 0) {
            revert InsufficientBalance();
        }

        unchecked {
            _balances[account] -= amount;
            _totalStaked -= amount;
            _totalWithdrawed += amount;
        }

        // Transfer tokens to the account.
        if (!stakeToken().transfer(account, amount)) {
            revert TransferFailed();
        }

        emit Withdrawed(account, amount);
    }

    /**
     * @dev Returns the maximum withdrawable tokens.
     */
    function withdrawable(address account) external view virtual returns (uint256 amount) {
        uint256 balance = balanceOf(account);

        if (!isLocked() || balance <= 0) {
            return balance;
        }

        (Deposit[] memory deposits_, uint256 duration_) = (_deposits[account], duration());

        for (uint256 i = 0; i < deposits_.length; ++i) {
            unchecked {
                if (block.timestamp < deposits_[i].time + duration_) {
                    continue;
                }

                amount += deposits_[i].amount;
            }
        }
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract FarmV2Context is ReentrancyGuard, Ownable {
    error InsufficientBalance();
    error TransferFailed();
    error PoolIsNotEmpty();
    error PoolIsNotStarted();
    error InvalidAmount();

    struct Configuration {
        uint256 apr;
        uint256 duration;
        bool isLocked;
        uint256 maxDeposit;
        uint256 rewardsRate;
        uint256 startAt;
        IERC20Metadata rewardsToken;
        IERC20Metadata stakeToken;
    }

    struct Deposit {
        uint256 amount;
        uint256 claimed;
        uint256 harvested;
        uint256 time;
        uint256 lastWithdrawAt;
        bool isEnded;
    }

    uint256 internal constant YEAR = 365 days;

    Configuration internal _config;

    uint256 internal _totalStaked;
    uint256 internal _totalHarvested;
    uint256 internal _totalWithdrawed;
    uint256 internal _totalClaimed;

    mapping(address => uint256) internal _balances;
    mapping(address => Deposit[]) internal _deposits;

    /**
     * @dev Returns the total deposits struct of the account.
     */
    function getDeposits(address account) external view virtual returns (Deposit[] memory) {
        return _deposits[account];
    }

    /**
     * @dev Returns the current APR of this pool.
     */
    function apr() public view virtual returns (uint256) {
        return _config.apr;
    }

    /**
     * @dev Returns the current staked token of the account.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Returns the number of decimals used to simulator float number.
     */
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev Returns the pool duration.
     *
     * The duration is used for lock the staked tokens if enabled
     * and calculator the earned tokens.
     */
    function duration() public view virtual returns (uint256) {
        return _config.duration;
    }

    /**
     * @dev Determines if the staked tokens will be locked.
     */
    function isLocked() public view virtual returns (bool) {
        return _config.isLocked;
    }

    /**
     * @dev Returns balance of the rewards pool.
     */
    function rewardsPool() public view virtual returns (uint256 balance) {
        balance = rewardsTokenBalance();

        if (rewardsToken() == stakeToken()) {
            unchecked {
                uint256 staked = totalStaked();

                if (balance < staked) {
                    return 0;
                }

                balance -= staked;
            }
        }
    }

    /**
     * @dev Returns the current rewards rate.
     */
    function rewardsRate() public view virtual returns (uint256) {
        return _config.rewardsRate;
    }

    /**
     * @dev Returns the rewards token address.
     */
    function rewardsToken() public view virtual returns (IERC20Metadata) {
        return _config.rewardsToken;
    }

    /**
     * @dev Returns the stake token address.
     */
    function stakeToken() public view virtual returns (IERC20Metadata) {
        return _config.stakeToken;
    }

    /**
     * @dev Returns the pool start time.
     */
    function startAt() public view virtual returns (uint256) {
        return _config.startAt;
    }

    /**
     * @dev Returns the total staked tokens.
     */
    function totalStaked() public view virtual returns (uint256) {
        return _totalStaked;
    }

    /**
     * @dev Determines if the current pool is started.
     */
    function isStarted() internal view virtual returns (bool) {
        return block.timestamp >= startAt(); // solhint-disable-line not-rely-on-time
    }

    /**
     * @dev Returns the maximum depositable amount per account.
     */
    function maxDepositPerAccount() internal view virtual returns (uint256) {
        return _config.maxDeposit;
    }

    /**
     * @dev Returns the rewards token balance of current contract.
     */
    function rewardsTokenBalance() internal view virtual returns (uint256) {
        return rewardsToken().balanceOf(address(this));
    }

    /**
     * @dev Returns the stake token balance of current contract.
     */
    function stakeTokenBalance() internal view virtual returns (uint256) {
        return stakeToken().balanceOf(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";

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

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

import "../FarmV2Context.sol";

// solhint-disable not-rely-on-time
abstract contract FarmV2Earnable is FarmV2Context {
    /**
     * @dev Emit when the account harvested successfully.
     */
    event Harvested(address indexed account, uint256 indexed amount);

    /**
     * @dev Harvest all earned tokens of the sender.
     */
    function harvest() external virtual nonReentrant {
        address account = _msgSender();
        uint256 earned_;

        (Deposit[] memory deposits_, uint256 apr_, uint256 duration_) = (_deposits[account], apr(), duration());

        unchecked {
            for (uint256 i = 0; i < deposits_.length; ++i) {
                uint256 earnedByDeposit = _earned(deposits_[i], apr_, duration_);

                if (earnedByDeposit > 0) {
                    _deposits[account][i].harvested += earnedByDeposit - deposits_[i].claimed;
                    _deposits[account][i].claimed = 0;
                }

                earned_ += earnedByDeposit;
            }

            earned_ /= 10**decimals();
        }

        if (earned_ <= 0) {
            revert InsufficientBalance();
        }

        if (!rewardsToken().transfer(account, earned_)) {
            revert TransferFailed();
        }

        unchecked {
            _totalHarvested += earned_;
        }

        emit Harvested(account, earned_);
    }

    /**
     * @dev Returns the total earned tokens of the account.
     */
    function earned(address account) external view virtual returns (uint256 earned_) {
        (Deposit[] memory deposits_, uint256 apr_, uint256 duration_) = (_deposits[account], apr(), duration());

        for (uint256 i = 0; i < deposits_.length; ++i) {
            unchecked {
                earned_ += _earned(deposits_[i], apr_, duration_);
            }
        }
    }

    /**
     * @dev Calculator the earned tokens of the deposit by specified APR
     * and duration.
     *
     * Calculation formula:
     *  + Rewards Per Seconds (RPS): amount * (APR / 365 days)%
     *  + Stake Time: now - stake start time
     *  + Earned: (RPS * min(Stake Time, duration) + claimed) - harvested
     */
    function _earned(
        Deposit memory deposit_,
        uint256 apr_,
        uint256 duration_
    ) internal view virtual returns (uint256 earned_) {
        uint256 amount = deposit_.amount;

        if (amount <= 0 || deposit_.isEnded) {
            return deposit_.claimed;
        }

        // Calculator the stake time.
        uint256 stakeTime = duration_;

        unchecked {
            uint256 end = deposit_.time + duration_;

            if (deposit_.lastWithdrawAt < end) {
                if (block.timestamp < end) {
                    end = block.timestamp;
                }

                stakeTime = end - deposit_.lastWithdrawAt;
            }
        }

        // Calculator the deposit amount by rewards rate.
        unchecked {
            amount = (amount * rewardsRate()) / 10**decimals();

            if (amount <= 0) {
                return deposit_.claimed;
            }
        }

        // Calculator earned tokens.
        unchecked {
            earned_ = ((amount * stakeTime * apr_) / YEAR / 100) + deposit_.claimed;

            if (earned_ <= deposit_.harvested) {
                return 0;
            }

            earned_ -= deposit_.harvested;
        }
    }
}