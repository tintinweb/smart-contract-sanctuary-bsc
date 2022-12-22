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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;


interface Ibridge{
    struct asset {
        address tokenAddress; 
        uint256 minAmount;
        uint256 maxAmount;
        uint256 feeBalance;
        uint256 collectedFees;
        bool ownedRail;
        address manager;
        address feeRemitance;
        uint256 balance;
        bool isSet;
     }


    function isAssetSupportedChain(address assetAddress , uint256 chainID) external view returns (bool);


    function controller() external view returns (address);


    function claim(bytes32 transaction_id) external;


    function mint(bytes32 transaction_id) external ;


    function settings() external view returns (address); 


    function chainId() external view returns (uint256);


    function foriegnAssetChainID(address _asset) external view returns (uint256);


    function assetLimits(address _asset, bool native) external view returns (uint256 , uint256);


    function foriegnAssets(address assetAddress) external view returns (asset memory);


    function wrappedForiegnPair(address assetAddress , uint256 chainID) external view returns (address);

    function udpadateBridgePool(address _bridgePool) external;

    function isDirectSwap(address assetAddress ,uint256 chainID) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IController {

    function isAdmin(address account) external view returns (bool);


    function isRegistrar(address account) external view returns (bool);


    function isOracle(address account) external view returns (bool);


    function isValidator(address account) external view returns (bool);


    function owner() external view returns (address);

    
    function validatorsCount() external view returns (uint256);

    function settings() external view returns (address);


    function deployer() external view returns (address);


    function feeController() external view returns (address);

    
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IRegistery {
    struct Transaction{
            uint256 chainId;
            address assetAddress;
            uint256 amount;
            address receiver;
            uint256 nounce;
            bool  isCompleted;
        }

    function getUserNonce(address user) external returns (uint256);
    function isSendTransaction(bytes32 transactionID) external returns (bool);
    function isClaimTransaction(bytes32 transactionID) external returns (bool);
    function isMintTransaction(bytes32 transactionID) external returns (bool);
    function isburnTransactio(bytes32 transactionID) external returns (bool);
    function transactionValidated(bytes32 transactionID) external returns (bool);
    function assetChainBalance(address asset, uint256 chainid) external returns (uint256);

    function sendTransactions(bytes32 transactionID) external returns (Transaction memory);
    function claimTransactions(bytes32 transactionID) external returns (Transaction memory);
    function burnTransactions(bytes32 transactionID) external returns (Transaction memory);
    function mintTransactions(bytes32 transactionID) external returns (Transaction memory);
    
    function completeSendTransaction(bytes32 transactionID) external;
    function completeBurnTransaction(bytes32 transactionID) external;
    function completeMintTransaction(bytes32 transactionID) external;
    function completeClaimTransaction(bytes32 transactionID) external;
    function transferOwnership(address newOwner) external;
    
  
    function registerTransaction(
       bytes32 transactionID,
       uint256 chainId,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce,
       uint8 _transactionType
     ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface Isettings {

    function networkFee(uint256 chainId) external view returns (uint256);

    function minValidations() external view returns (uint256);
    
    function isNetworkSupportedChain(uint256 chainID) external view returns (bool);

    function feeRemitance() external view returns (address);

    function railRegistrationFee() external view returns (uint256);

    function railOwnerFeeShare() external view returns (uint256);

    function onlyOwnableRail() external view returns (bool);

    function updatableAssetState() external view returns (bool);

    function minWithdrawableFee() external view returns (uint256);

    function brgToken() external view returns (address);

    function getNetworkSupportedChains() external view returns(uint256[] memory);
    
    function baseFeePercentage() external view returns(uint256);

    function baseFeeEnable() external view returns(bool);

    function approvedToAdd(address token , address user) external view returns(bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interface/Iregistry.sol";
import "./interface/Isettings.sol";
import "./interface/Ibridge.sol";
import "./interface/Icontroller.sol";

contract  Registry is Ownable {
    using ECDSA for bytes32;
    struct Transaction{
       uint256 chainId;
       address assetAddress;
       uint256 amount;
       address receiver;
       uint256 nounce;
       bool  isCompleted;
   }
   struct validation {
       uint256 validationCount;
       bool validated;
   }
   enum transactionType {send , burn , mint ,claim}

   mapping (address => uint256) public assetTotalTransactionCount;
   mapping (address => mapping( uint256 => uint256 )) public assetTransactionTypeCount;
   mapping(address => mapping( uint256 => uint256 )) public assetChainBalance;
   mapping(address => uint256) public getUserNonce; 
   mapping (bytes32 => bool)  public isSendTransaction;
   mapping (bytes32 => Transaction)  public sendTransactions;
   mapping (bytes32 => bool)  public isClaimTransaction;
   mapping (bytes32 => Transaction)  public claimTransactions;
   mapping(bytes32 => Transaction) public mintTransactions;
   mapping(bytes32 => bool) public isMintTransaction;
   mapping(bytes32 => Transaction) public burnTransactions;
   mapping(bytes32 => bool) public isburnTransaction;
   mapping(bytes32 => validation ) public transactionValidations;
   mapping(bytes32 => address[] ) public TransactionValidators;
   mapping(bytes32 => mapping(address => bool)) public hasValidatedTransaction;
   uint256 public totalTransactions;

   event TransactionValidated(bytes32 indexed transactionID);
   event SendTransactionCompleted(bytes32 indexed transactionID);
   event BurnTransactionCompleted(bytes32 indexed transactionID);
   event MintTransactionCompleted(bytes32 indexed transactionID);
   event ClaimTransactionCompleted(bytes32 indexed transactionID);

   constructor(){}
  

  function completeSendTransaction(bytes32 transactionID) external {
      require(isSendTransaction[transactionID] ,"invalid Transaction");
      emit SendTransactionCompleted(transactionID);
      sendTransactions[transactionID].isCompleted = true;
  }


  function completeBurnTransaction(bytes32 transactionID) external {
       require(isburnTransaction[transactionID] ,"invalid Transaction");
       emit BurnTransactionCompleted(transactionID);
       burnTransactions[transactionID].isCompleted = true ;
  }


  function completeMintTransaction(bytes32 transactionID) external {
       require(isMintTransaction[transactionID] ,"invalid Transaction");
       emit MintTransactionCompleted(transactionID);
       mintTransactions[transactionID].isCompleted = true;
  }


  function completeClaimTransaction(bytes32 transactionID) external {
      require(isClaimTransaction[transactionID] ,"invalid Transaction");
      emit ClaimTransactionCompleted(transactionID);
      assetChainBalance[claimTransactions[transactionID].assetAddress][claimTransactions[transactionID].chainId] -= claimTransactions[transactionID].amount;
       claimTransactions[transactionID].isCompleted = true;
  }


   


  function registerTransaction(
       bytes32 transactionID,
       uint256 chainId,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce,
       transactionType _transactionType
  ) 
        public 
        onlyOwner 
  {
      if (_transactionType  == transactionType.send) {
          sendTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isSendTransaction[transactionID] = true;
          getUserNonce[receiver]++;
          assetChainBalance[assetAddress][chainId] += amount;
      } else if (_transactionType  == transactionType.burn) {
          burnTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isburnTransaction[transactionID] = true;
          getUserNonce[receiver]++;
      }
      assetTotalTransactionCount[assetAddress]++;
      totalTransactions++;
  }
  
  
  function _registerTransaction(
       bytes32 transactionID,
       uint256 chainId,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce,
       transactionType _transactionType
  ) 
      internal
  {
      if (_transactionType  == transactionType.mint) {
          mintTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isMintTransaction[transactionID] = true;
      } else if (_transactionType  == transactionType.claim) {
          claimTransactions[transactionID] = Transaction(chainId , assetAddress ,amount , receiver ,nounce, false);
          isClaimTransaction[transactionID] = true;
      }
  }
  
  
  function registerClaimTransaction(
      bytes32 claimID,
      uint256 chainFrom,
      address assetAddress,
      uint256 amount,
      address receiver,
      uint256 nounce
    ) 
      external 
    {
        require(IController(Ibridge(owner()).controller()).isOracle(msg.sender),"U_A");
        require(!isClaimTransaction[claimID], "registerred");
        require(Ibridge(owner()).isAssetSupportedChain(assetAddress ,chainFrom), "chain_err");
        bytes32 requiredClaimID = keccak256(abi.encodePacked(
            chainFrom,
            Ibridge(owner()).chainId(),
            assetAddress,
            amount,
            receiver,
            nounce
            ));

        require(claimID  == requiredClaimID , "claimid_err");
        _registerTransaction(claimID ,chainFrom , assetAddress, amount , receiver ,nounce, transactionType.claim );
   }


   function registerMintTransaction(
       bytes32 mintID,
       uint256 chainFrom,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce
    ) 
       external 
    {
        require(IController(Ibridge(owner()).controller()).isOracle(msg.sender),"U_A");
        require(!isMintTransaction[mintID], "registerred");
        Ibridge  bridge = Ibridge(owner());
        address wrappedAddress = bridge.wrappedForiegnPair(assetAddress ,chainFrom);
        require(wrappedAddress != address(0), "I_A");
        if(!bridge.isDirectSwap(assetAddress , chainFrom)){
            Ibridge.asset memory  foriegnAsset = bridge.foriegnAssets(wrappedAddress);
            require(foriegnAsset.isSet , "asset_err");
            require(bridge.foriegnAssetChainID(wrappedAddress) == chainFrom , "chain_err");
        }
        
        bytes32 requiredmintID = keccak256(abi.encodePacked(
            chainFrom,
            bridge.chainId(),
            assetAddress,
            amount,
            receiver,
            nounce
            ));
        require(mintID  == requiredmintID, "mint: error validation mint ID");
        _registerTransaction(mintID ,chainFrom , wrappedAddress, amount , receiver ,nounce, transactionType.mint);
   }



   function validateTransaction(bytes32 transactionId , bytes[] memory signatures ,bool mintable) external  {
       require(IController(Ibridge(owner()).controller()).isValidator(msg.sender) , "U_A");
       require(Isettings(Ibridge(owner()).settings()).minValidations() != 0 , "minvalidator_err");
       Transaction memory transaction;
       if (mintable) {
           require(isMintTransaction[transactionId] , "mintID_err"); 
           transaction =  mintTransactions[transactionId];
           if(!Ibridge(owner()).isDirectSwap(transaction.assetAddress , transaction.chainId)){
               (,uint256 max) =  Ibridge(owner()).assetLimits(transaction.assetAddress, false);
               require(transaction.amount <= max , "Amount_limit_Err");
           }
        } else {
            require(isClaimTransaction[transactionId] , "caimID_err"); 
            transaction =  claimTransactions[transactionId]; 
            (,uint256 max) =  Ibridge(owner()).assetLimits(transaction.assetAddress , true);
            require(transaction.amount <= max && transaction.amount <= assetChainBalance[transaction.assetAddress][transaction.chainId]   , "Amount_limit_Err");
        }
       require(!transaction.isCompleted, "completed");
       uint256 validSignatures;
       for (uint256 i; i < signatures.length; ++i) {
            address signer = getSigner(
                getChainId(),
                transaction.chainId,
                transaction.assetAddress,
                transaction.amount,
                transaction.receiver,
                transaction.nounce,
                signatures[i]
            );
            if (
                IController(Ibridge(owner()).controller()).isValidator(
                    signer
                ) && !hasValidatedTransaction[transactionId][signer]
            ) {
                validSignatures = validSignatures + 1;
                TransactionValidators[transactionId].push(signer);
                hasValidatedTransaction[transactionId][signer] = true;
            }
        }
       // this part of the code was remove to access if you can recreate it to verify the signatures for a transaction

       // the message that was signed by the validators is a hash of derived as shown bellow

        // keccak256(abi.encodePacked(
        //     "\x19Ethereum Signed Message:\n32",
        //     keccak256(abi.encodePacked(
        //         chainID,   // this is goten from Ibridge(owner()).chainId()
        //         interfacingChainId,
        //         assetAddress,
        //         amount,
        //         receiver,
        //         nounce
        //     ))))

    // to all you need to do here is verify each of this signatures to accertain if the are from a valid signer


       //
       require(validSignatures >= Isettings(Ibridge(owner()).settings()).minValidations() ,"insuficient_signers");
       transactionValidations[transactionId].validationCount = validSignatures; 
       transactionValidations[transactionId].validated  = true;
        emit TransactionValidated(transactionId);
       if (mintable) {
           Ibridge(owner()).mint(transactionId);
       } else {
           Ibridge(owner()).claim(transactionId);
       }
   }

   function getChainId() internal view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    function getSigner(
        uint256 chainID,
        uint256 interfacingChainId,
        address assetAddress,
        uint256 amount,
        address receiver,
        uint256 nounce,
        bytes memory signature
    ) public view returns (address) {
        bytes32 signedMsg =             
            keccak256(abi.encodePacked(
                chainID,   // this is goten from Ibridge(owner()).chainId()
                interfacingChainId,
                assetAddress,
                amount,
                receiver,
                nounce
            ));

        return signedMsg
        .toEthSignedMessageHash()
        .recover(signature);
    }
   

    function transactionValidated(bytes32 transactionID) external  view returns (bool) {
      return transactionValidations[transactionID].validated;
  }

}