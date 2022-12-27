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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

pragma solidity ^0.8.4;

interface IGameItemERC1155 {

    function totalSupply(uint256 id) external view returns (uint256);
    function exists(uint256 id) external view returns (bool);

    function mintTokenIdWithWitelist(address to, uint256[] memory tokenids, uint256[] memory amounts) external;
    function transferWithNumber(uint256 start, uint256 idsNumber, uint256 amount, address to) external;
}

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMill is IERC721{
    function gradeId(uint256 tokenId) external view returns (uint256);
    function qualityId(uint256 tokenId) external view returns (uint256);
    function attributeId(uint256 tokenId) external view returns (uint256);
    function durability(uint256 tokenId) external view returns (uint256);
    function setDurability(uint256 tokenId, uint256 durability) external;
}

//// SPDX-License-Identifier: MIT
//
//pragma solidity ^0.8.4;
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/utils/Strings.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
//import "./interfaces/IMill.sol";
//
//contract Mill is IMill,Ownable{
//
//    mapping(uint256 => uint256) durability;
//    constructor(uint256 _level) ERC721("TestNft", "TN"){
//        level = _level;
//    }
//
//    function setDurability(address _user,uint _durability) onlyOwner{
//        durability[_user] = _durability;
//    }
//}

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MinePool.sol";
import "./asset/interfaces/IMill.sol";
import "./asset/interfaces/IGameItemERC1155.sol";

contract MineLens {

    struct MinePoolBaseInfo{
        bool paused;
        uint256 mineFieldLength;
    }

//    struct MineralOutput{
//        MineralInfo mineralInfo;//矿产信息
//        uint256 outputRate;//产出速率
//    }
//
//    struct MineralInfo{//矿产信息结构体
//        IGameItemERC1155 mineral;//矿产
//        uint256 id;//矿产ID
//    }

    function getMinePoolBaseInfo(MinePool _pool) public view returns(MinePoolBaseInfo memory){
       uint256 len =  _pool.mineFieldLength();
        return MinePoolBaseInfo({
            paused: _pool.paused(),
            mineFieldLength: len
        });
    }

//    enum State{
//        UNCULTIVATED,//未开垦的
//        CULTIVATED,//已开垦的
//        MING//挖矿中
//    }
//
//    struct UserMineFieldsInfo{
//        UserMineFieldInfo[] userMineFields;
//    }
//
    struct UserMineFieldBaseInfo{
        uint256 electricityRate;//消耗代币速率
        uint256 outputRate;//产出速率
        uint256 durabilityRate;//耐久度损耗率
        uint256 startAt;//开始区块
        MinePool.State state;//状态
        IERC20 electricityCoin;//消耗代币
        IERC20 outputToken;//产出代币
        MinePool.MillInfo millInfo;//矿机信息

//        bool needUnlock;//是否需要解锁
//        IERC20 unlockCoin;
//        uint256 unlockCoinAmount;
    }

//    struct RewardInfo{
//        IERC20 mineral;//矿产
//        uint256 rewardDebt;//待领取收益
//    }

    function getUserMineFieldBaseInfo(MinePool _pool, address _user) public view returns(UserMineFieldBaseInfo[] memory){
        uint256 len =  _pool.mineFieldLength();
        UserMineFieldBaseInfo[] memory _userMineFieldBaseInfos = new UserMineFieldBaseInfo[](len);

        for(uint256 i = 0; i< len; i++){
            _userMineFieldBaseInfos[i] = this.getUserMineFieldBaseInfo(_pool, _user, i);
        }

        return _userMineFieldBaseInfos;
    }

    function getUserMineFieldBaseInfo(MinePool _pool, address _user, uint256 _pid) external view returns(UserMineFieldBaseInfo memory){
//        ( uint256 unlockCoinAmount
//        , uint256 millAttributeId
//        , uint256 millQualityId
//        , uint256 millGradeId
//        , uint256 electricityRate
//        , uint256 outputRate
//        , uint256 durabilityRate
//        , IERC20 unlockCoin
//        , IERC20 electricityCoin
//        , IERC20 outputToken
//        , bool unlock) = _pool.mineFields(_pid);

        ( uint256 _electricityRate
        , uint256 _outputRate
        , uint256 _durabilityRate
        , uint256 _startAt
        , MinePool.State _state
        , IERC20 _electricityCoin
        , IERC20 _outputToken
        , MinePool.MillInfo memory _millInfo) = _pool.userMineField(_user,_pid);

//        bool _needUnlock = !unlock && _state == MinePool.State.UNCULTIVATED;

        return UserMineFieldBaseInfo({
            electricityRate: _electricityRate,
            outputRate: _outputRate,
            durabilityRate: _durabilityRate,
            startAt: _startAt,
            state: _state,
            electricityCoin: _electricityCoin,
            outputToken: _outputToken,
            millInfo: _millInfo
//            needUnlock: _needUnlock,
//            unlockCoin: unlockCoin,
//            unlockCoinAmount: unlockCoinAmount
        });
    }

//    function getUserMineFieldInfo(MinePool _pool, address _user, uint256 _pid) public view returns(bool){
//        ( uint256 consumeRate
//        , uint256 outputRate
//        , uint256 durabilityLossRate
//        , uint256 startAt
//        , IERC20 consumeToken
//        , IERC20 outputToken
//        , MinePool.MillInfo memory millInfo
//        , MinePool.State state) = _pool.userMineField(_user,_pid);
//    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./asset/interfaces/IMill.sol";
import "./asset/interfaces/IGameItemERC1155.sol";

contract MinePool is Ownable,Pausable,ReentrancyGuard{
    using Math for uint256;
    using SafeMath for uint256;

    struct MineField{//矿场坑位结构体
        uint256 unlockCoinAmount;//解锁代币花费
        uint256 millAttributeId;//矿机属性ID
        uint256 millQualityId;//矿机品质ID
        uint256 millGradeId;//矿机级别ID
        uint256 electricityRate;//消耗代币速率
        uint256 outputRate;//产出速率
        uint256 durabilityRate;//耐久度损耗率 eg：200个区块消耗1个耐久度
        IERC20 unlockCoin;//解锁代币
        IERC20 electricityCoin;//消耗代币
        IERC20 outputToken;//产出代币
        bool unlock;//开启状态

        MineralOutput[] mineralOutputs;//挖出的矿产集合
    }

    struct MineralOutput {//矿产产出结构体
        MineralInfo mineralInfo;//矿产信息
        uint256 outputRate;//产出速率
    }

    struct UserMineralField {//用户坑位结构体
        uint256 electricityRate;//消耗代币速率
        uint256 outputRate;//产出速率
        uint256 durabilityRate;//耐久度损耗率
        uint256 startAt;//开始区块
        State state;//状态
        IERC20 electricityCoin;//消耗代币
        IERC20 outputToken;//产出代币
        MillInfo millInfo;//矿机信息

        MineralReward[] mineralRewards;//收益集合
    }

    struct CoinDebt {//代币债务结构体
        IERC20 coin;//奖励代币地址
        uint256 conversionRate;//转化率
        uint256 debt;//待处理债务
    }

    struct MineralReward {//矿产奖励结构体
        MineralInfo mineralInfo;//矿产信息
        uint256 outputRate;//产出速率
        uint256 rewardDebt;//待领取奖励
    }

    struct MillInfo{//矿机信息结构体
        IMill mill;//矿机
        uint256 tokenId;
    }

    struct MineralInfo{//矿产信息结构体
        IGameItemERC1155 mineral;//矿产
        uint256 id;//矿产ID
    }

    struct MineralRewardPid {//坑位矿产收益结构体
        uint256 pid;//矿坑ID
        MineralReward[] mineralRewards;//矿产收益集合
    }

    enum State{
        UNCULTIVATED,//未开垦的
        CULTIVATED,//已开垦的(已初始化/已初始化并解锁)
        MING//挖矿中
    }

    address public feeTo;//手续费地址
    MineField[] public mineFields;//矿场坑位集合

    mapping(address => mapping(uint256 => UserMineralField)) public userMineField;//用户与矿产坑位映射

    constructor (address _feeTo) {
        require(_feeTo != address(0),"_feeTo is the zero address");
        feeTo = _feeTo;
    }

    modifier isMineFieldPid(uint256 _pid) {
        require(_pid <= mineFieldLength() - 1, "not find this mineField");
        _;
    }

    modifier isUncultivated(uint256 _pid, address _user) {
        UserMineralField storage userMineralField = userMineField[_user][_pid];
        require(userMineralField.state == State.UNCULTIVATED, "CULTIVATED");
        _;
    }

    modifier isCultivated(uint256 _pid, address _user) {
        UserMineralField storage userMineralField = userMineField[_user][_pid];
        require(userMineralField.state == State.CULTIVATED, "UNCULTIVATED");
        _;
    }

    modifier isNotMing(uint256 _pid, address _user) {
        UserMineralField storage userMineralField = userMineField[_user][_pid];
        require(userMineralField.state != State.MING, "MING");
        _;
    }

    modifier isMing(uint256 _pid, address _user) {
        UserMineralField storage userMineralField = userMineField[_user][_pid];
        require(userMineralField.state == State.MING, "Not MING");
        _;
    }

    function resetFeeTo(address payable _feeTo) external onlyOwner{
        require(_feeTo != address(0), "_feeTo is the zero address");
        address oldFeeTo = feeTo;
        feeTo = _feeTo;
    }

    function mineFieldLength() public view returns (uint256) {
        return mineFields.length;
    }

    //管理员增加矿坑
    //[1,3,4,5,6,7,8,0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,true,[[[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,12],10],[[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,12],11]]]
    function addMineField(MineField memory _mineField) onlyOwner public returns(uint256){
        MineField storage mineField = mineFields.push();

        mineField.unlockCoinAmount = _mineField.unlockCoinAmount;
        mineField.millAttributeId = _mineField.millAttributeId;
        mineField.millQualityId = _mineField.millQualityId;
        mineField.millGradeId = _mineField.millGradeId;
        mineField.electricityRate = _mineField.electricityRate;
        mineField.outputRate = _mineField.outputRate;
        mineField.durabilityRate = _mineField.durabilityRate;
        mineField.unlockCoin = _mineField.unlockCoin;
        mineField.electricityCoin = _mineField.electricityCoin;
        mineField.outputToken = _mineField.outputToken;
        mineField.unlock = _mineField.unlock;

        //重置挖出的矿产集合
        uint256 _pid = mineFieldLength()-1;
        MineralOutput[] memory _mineralOutputs = _mineField.mineralOutputs;
        pushMineralOutputs(_pid,_mineralOutputs);

        return _pid;
    }

    //0,[11,31,41,51,61,71,81,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,false,[[[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,121],101],[[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,121],111]]]
    function updateMineField(uint256 _pid, MineField memory _mineField) isMineFieldPid(_pid) onlyOwner public{
        MineField storage mineField = mineFields[_pid];

        mineField.millAttributeId = _mineField.millAttributeId;
        mineField.millQualityId = _mineField.millQualityId;
        mineField.millGradeId = _mineField.millGradeId;
        mineField.electricityRate = _mineField.electricityRate;
        mineField.outputRate = _mineField.outputRate;
        mineField.durabilityRate = _mineField.durabilityRate;
        mineField.electricityCoin = _mineField.electricityCoin;
        mineField.outputToken = _mineField.outputToken;
        mineField.unlock = _mineField.unlock;

        //清空挖出的矿产集合
        popMineralOutputs(_pid);

        //重置挖出的矿产集合
        MineralOutput[] memory _mineralOutputs = _mineField.mineralOutputs;
        pushMineralOutputs(_pid,_mineralOutputs);
    }

    //重置挖出的矿产集合
    function pushMineralOutputs(uint256 _pid, MineralOutput[] memory _mineralOutputs) internal{
        MineField storage mineField = mineFields[_pid];
        MineralOutput[] storage mineralOutputs = mineField.mineralOutputs;
        uint256 _len = _mineralOutputs.length;
        for(uint256 i=0; i< _len; i++){
            MineralOutput memory _mineralOutput = _mineralOutputs[i];
            mineralOutputs.push(MineralOutput({
                mineralInfo: _mineralOutput.mineralInfo,
                outputRate: _mineralOutput.outputRate
            }));
        }
    }

    //清空挖出的矿产集合
    function popMineralOutputs(uint256 _pid) internal{
        MineField storage mineField = mineFields[_pid];
        MineralOutput[] storage mineralOutputs = mineField.mineralOutputs;

        uint256 len = mineralOutputs.length;
        for(uint256 i=0; i< len; i++){
            mineralOutputs.pop();
        }
    }

    function initMineField(uint256 _pid, address _user) external payable isMineFieldPid(_pid) isNotMing(_pid,_user) nonReentrant whenNotPaused {
        MineField storage mineField = mineFields[_pid];
        MineralOutput[] storage mineralOutputs = mineField.mineralOutputs;
        uint256 len = mineralOutputs.length;

        UserMineralField storage userMineralField = userMineField[_user][_pid];

        if(userMineralField.state == State.UNCULTIVATED){//非开垦状态
            if(!mineField.unlock && mineField.unlockCoinAmount != 0){
                //TODO pay
//                if(address(mineField.unlockCoin) == address(0)){//支付平台币
//                    require(msg.value >= mineField.unlockCoinAmount, "The ether value sent is not correct");
//                    payable(feeTo).transfer(msg.value);
//                }else{//支付代币
//                    mineField.unlockCoin.transferFrom(msg.sender, feeTo, mineField.unlockCoinAmount);
//                }
            }
            userMineralField.state = State.CULTIVATED;
        }

        userMineralField.electricityCoin = mineField.electricityCoin;
        userMineralField.electricityRate = mineField.electricityRate;
        userMineralField.outputToken = mineField.outputToken;
        userMineralField.outputRate = mineField.outputRate;
        userMineralField.durabilityRate = mineField.durabilityRate;
        userMineralField.startAt = 0;
        userMineralField.millInfo.mill = IMill(address(0));
        userMineralField.millInfo.tokenId = 0;

        for(uint256 i=0; i< len; i++){
            MineralOutput storage mineralOutput = mineralOutputs[i];
            userMineralField.mineralRewards.push(MineralReward({
                mineralInfo: mineralOutput.mineralInfo,
                outputRate: mineralOutput.outputRate,
                rewardDebt: 0
            }));
        }
    }

    //挖矿
    function mining(uint256 _pid, MillInfo memory _millInfo) public payable isMineFieldPid(_pid) isNotMing(_pid,msg.sender) nonReentrant whenNotPaused{
        //重新初始化矿坑
        this.initMineField(_pid, msg.sender);

        //矿机质押
        IMill mill = _millInfo.mill;
        //TODO pay
//        mill.safeTransferFrom(msg.sender,address(this),_millInfo.tokenId);//质押矿机

        UserMineralField storage userMineralField = userMineField[msg.sender][_pid];
        userMineralField.millInfo = _millInfo;
        userMineralField.startAt = block.number;
    }

    //查看债务
    function getDebts(uint256 _pid, address _user) external view isMineFieldPid(_pid) returns (CoinDebt memory, CoinDebt memory, MineralReward[] memory) {
        UserMineralField storage userMineralField = userMineField[_user][_pid];
        MineralReward[] storage mineralRewards = userMineralField.mineralRewards;
        uint256 len = mineralRewards.length;

        CoinDebt memory coinDebtOutput = CoinDebt(userMineralField.outputToken,userMineralField.outputRate,0);
        CoinDebt memory coinDebtConsumer = CoinDebt(userMineralField.electricityCoin,userMineralField.electricityRate,0);
        MineralReward[] memory _mineralRewards = new MineralReward[](len);//矿产奖励
        if(userMineralField.state != State.MING){ //未挖矿状态
            return (coinDebtOutput, coinDebtConsumer, _mineralRewards);
        }

        //计算实际可获取收益的区块数
        uint256 effectiveBlock = getEffectiveBlock(_pid,msg.sender);

        coinDebtOutput.debt = effectiveBlock.mul(coinDebtOutput.conversionRate);
        coinDebtConsumer.debt = effectiveBlock.mul(coinDebtConsumer.conversionRate);

        for(uint256 i = 0; i< len; i++){
            MineralReward storage mineralReward = mineralRewards[i];
            uint256 rewardDebt = effectiveBlock.div(mineralReward.outputRate);

            MineralReward memory _mineralReward = MineralReward(mineralReward.mineralInfo
                , mineralReward.outputRate
                , rewardDebt);
            _mineralRewards[i] = _mineralReward;
        }

        return (coinDebtOutput, coinDebtConsumer, _mineralRewards);
    }

    function getDurability(uint256 _pid, address _user) public view returns(uint256,uint256){
        UserMineralField storage userMineralField = userMineField[_user][_pid];
        MillInfo storage millInfo = userMineralField.millInfo;
        IMill mill = millInfo.mill;
        uint256 tokenId = millInfo.tokenId;

        if(userMineralField.state != State.MING){ //未挖矿状态
            return (0, 0);
        }

        uint256 deltaBlock = block.number.sub(userMineralField.startAt);
        uint256 durability = mill.durability(tokenId);
        //向上取整
        uint256 durabilityLoss = deltaBlock.ceilDiv(userMineralField.durabilityRate);

        if(durability >= durabilityLoss){
            return (durabilityLoss, durability.sub(durabilityLoss));
        }else{
            return (durability, 0);
        }
    }

    //计算实际可获取收益的区块数
    function getEffectiveBlock(uint256 _pid, address _user) internal view returns(uint256){
        UserMineralField storage userMineralField = userMineField[_user][_pid];
        (uint256 usedDurability, uint256 surplusDurability) = getDurability(_pid,_user);
        uint256 effectiveBlock = userMineralField.durabilityRate.mul(usedDurability);
        uint256 deltaBlock = block.number.sub(userMineralField.startAt);
        return deltaBlock > effectiveBlock ? effectiveBlock : deltaBlock;
    }
//
//    //提取全部坑位收益
//    function withdrawAllRewards() public isMineFieldPid(_pid) nonReentrant{
//        uint256 len = mineFields.length;
//        for(uint256 i=0; i< len; i++){
//            withdrawRewards(i);
//        }
//    }
//
    //提取收益
    function withdrawRewards(uint256 _pid) public payable isMineFieldPid(_pid) isMing(_pid,msg.sender){
        UserMineralField storage userMineralField = userMineField[msg.sender][_pid];
        IMill mill = userMineralField.millInfo.mill;
        uint256 tokenId = userMineralField.millInfo.tokenId;

        (CoinDebt memory coinDebtOutput, CoinDebt memory coinDebtConsumer, MineralReward[] memory mineralRewards) = this.getDebts(_pid,msg.sender);
        //TODO pay
//        //支付电费
//        if(address(coinDebtConsumer.coin) == address(0)){//支付平台币
//            require(msg.value >= coinDebtConsumer.debt, "The ether value sent is not correct");
//            payable(feeTo).transfer(msg.value);
//        }else{
//            coinDebtConsumer.coin.transferFrom(msg.sender, feeTo, coinDebtConsumer.debt);
//        }

        //重置耐久度
        (uint256 usedDurability, uint256 surplusDurability) = getDurability(_pid, msg.sender);
        mill.setDurability(tokenId, surplusDurability);

        uint256 len = mineralRewards.length;
        for(uint256 i= 0; i < len; i++){
            MineralReward memory mineralReward = mineralRewards[i];
            IGameItemERC1155 mineral = mineralReward.mineralInfo.mineral;
            uint256 id = mineralReward.mineralInfo.id;
            uint256 rewardDebt = mineralReward.rewardDebt;
            uint256[] memory ids = new uint256[](1);
            ids[0] = id;
            uint256[] memory amounts = new uint256[](1);
            amounts[0] = rewardDebt;
            mineral.mintTokenIdWithWitelist(msg.sender,ids,amounts); //铸造矿产
        }

        //重新初始化
        this.initMineField(_pid, msg.sender);
    }
}