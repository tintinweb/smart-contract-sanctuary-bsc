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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

// EIP-712 is Final as of 2022-08-11. This file is deprecated.

import "./EIP712.sol";

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQuantumPortalAuthorityMgr {
    enum Action { NONE, FINALIZE, SLASH }
    function validateAuthoritySignature(
        Action action,
        bytes32 msgHash,
        bytes32 salt,
        uint64 expiry,
        bytes memory signature
    ) external;
    function validateAuthoritySignatureSingleSigner(
        Action action,
        bytes32 msgHash,
        bytes32 salt,
        uint64 expiry,
        bytes memory signature
    ) external returns (address[] memory signers, bool quorumComplete);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IQuantumPortalAuthorityMgr.sol";
import "foundry-contracts/contracts/signature/MultiSigCheckable.sol";

/**
 @notice Authority manager, provides authority signature verification, for 
    different actions.
 */
contract QuantumPortalAuthorityMgr is IQuantumPortalAuthorityMgr, MultiSigCheckable {
    string public constant NAME = "FERRUM_QUANTUM_PORTAL_AUTHORITY_MGR";
    string public constant VERSION = "000.010";

    // signers that have signed a message
    address[] public completedSigners;

    // mapping to check if an address exists in completedSigners
    mapping(address => bool) public alreadySigned;

    // the current msgHash we are checking
    bytes32 public currentMsgHash;

    // the current quorumId we are checking
    address public currentQuorumId;

    constructor() EIP712(NAME, VERSION) {}

    bytes32 constant VALIDATE_AUTHORITY_SIGNATURE =
        keccak256("ValidateAuthoritySignature(uint256 action,bytes32 msgHash,bytes32 salt,uint64 expiry)");

    /**
     @notice Validates an authority signature
             TODO: Update to differentiate between finalize and slash. For example more
             signers requred for slash
     */
    function validateAuthoritySignature(
        Action action,
        bytes32 msgHash,
        bytes32 salt,
        uint64 expiry,
        bytes memory signature
    ) external override {
        require(action != Action.NONE, "QPAM: action required");
        require(msgHash != bytes32(0), "QPAM: msgHash required");
        require(expiry != 0, "QPAM: expiry required");
        require(salt != 0, "QPAM: salt required");
        require(expiry > block.timestamp, "QPAM: signature expired");
        bytes32 message = keccak256(abi.encode(VALIDATE_AUTHORITY_SIGNATURE, uint256(action), msgHash, salt, expiry));
        verifyUniqueSalt(message, salt, 1, signature);
    }

    /**
     @notice Validates an authority signature
             Returns true if the signature is valid and 
     */
    function validateAuthoritySignatureSingleSigner(
        Action action,
        bytes32 msgHash,
        bytes32 salt,
        uint64 expiry,
        bytes memory signature
    ) external override returns (address[] memory signers, bool quorumComplete) {

        // ensure that the current msgHash matches the one in process or msgHash is empty
        if (currentMsgHash != bytes32(0)) {
            require(msgHash == currentMsgHash, "QPAM: msgHash different than expected");
        }

        require(action != Action.NONE, "QPAM: action required");
        require(msgHash != bytes32(0), "QPAM: msgHash required");
        require(expiry != 0, "QPAM: expiry required");
        require(salt != 0, "QPAM: salt required");
        require(expiry > block.timestamp, "QPAM: signature expired");
        bytes32 message = keccak256(abi.encode(VALIDATE_AUTHORITY_SIGNATURE, uint256(action), msgHash, salt, expiry));

        // Validate the message for only this signer
        bytes32 digest = _hashTypedDataV4(message);
        bool result;
        (result, signers) = tryVerifyDigestWithAddressWithMinSigCheck(digest, 1, signature, false);
        require(result, "QPAM: Invalid signer");
        require(signers.length == 1, "QPAM: Wrong number of signers");
        address signer = signers[0];

        address signerQuorumId = quorumSubscriptions[signer].id;

        // if first signer, then set quorumId and msgHash
        if (completedSigners.length == 0) {
            currentMsgHash = msgHash;
            currentQuorumId = signerQuorumId;
        } else {
            // check the signer is part of the same quorum
            require(signerQuorumId == currentQuorumId, "QPAM: Signer quorum mismatch");

            // ensure not a duplicate signer
            require(!alreadySigned[signer], "QPAM: Already Signed!");
        }

        // insert signer to the signers list
        completedSigners.push(signer);
        alreadySigned[signer] = true;

        // if the quorum min length is complete, clear storage and return success
        if (completedSigners.length >= quorumSubscriptions[signer].minSignatures) {
            currentMsgHash = bytes32(0);
            currentQuorumId = address(0);

            // remove all signed mapping
            for (uint i=0; i<completedSigners.length; i++) {
                delete alreadySigned[completedSigners[i]];
            }
            delete completedSigners;
            return (completedSigners, true);
        } else { 
            return (completedSigners, false);
        }

    }

    /**
     @notice Clears the currentMsgHash to unblock invalid states
     */
    function clearCurrentMsgHash() external {
        currentMsgHash = bytes32(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
import "@openzeppelin/contracts/access/Ownable.sol";

contract WithAdmin is Ownable {
	address public admin;
	event AdminSet(address admin);

	function setAdmin(address _admin) external onlyOwner {
		admin = _admin;
		emit AdminSet(_admin);
	}

	modifier onlyAdmin() {
		require(msg.sender == admin || msg.sender == owner(), "WA: not admin");
		_;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../common/WithAdmin.sol";
import "./MultiSigLib.sol";

/**
 @notice
    Base class for contracts handling multisig transactions
      Rules:
      - First set up the master governance quorum (groupId 1). onlyOwner
	  - Owner can remove public or custom quorums, but cannot remove governance
	  quorums.
	  - Once master governance is setup, governance can add / remove any quorums
	  - All actions can only be submitted to chain by admin or owner
 */
abstract contract MultiSigCheckable is WithAdmin, EIP712 {
    uint16 public constant GOVERNANCE_GROUP_ID_MAX = 256;
    uint32 constant WEEK = 3600 * 24 * 7;
    struct Quorum {
        address id;
        uint64 groupId; // GroupId: 0 => General, 1 => Governance, >1 => Custom
        uint16 minSignatures;
        // If the quorum is owned, only owner can change its config.
        // Owner must be a governence q (id <256)
        uint8 ownerGroupId;
    }
    event QuorumCreated(Quorum quorum);
    event QuorumUpdated(Quorum quorum);
    event AddedToQuorum(address quorumId, address subscriber);
    event RemovedFromQuorum(address quorumId, address subscriber);

    mapping(bytes32 => bool) public usedHashes;
    mapping(address => Quorum) public quorumSubscriptions; // Repeating quorum defs to reduce reads
    mapping(address => Quorum) public quorums;
    mapping(address => uint256) public quorumsSubscribers;
    mapping(uint256 => bool) internal groupIds; // List of registered group IDs
    address[] public quorumList; // Only for transparency. Not used. To sanity check quorums offchain

    modifier governanceGroupId(uint64 expectedGroupId) {
        require(
            expectedGroupId < GOVERNANCE_GROUP_ID_MAX,
            "MSC: must be governance"
        );
        _;
    }

    modifier expiryRange(uint64 expiry) {
        require(block.timestamp < expiry, "CR: signature timed out");
        require(expiry < block.timestamp + WEEK, "CR: expiry too far");
        _;
    }

    /**
     @notice Force remove from quorum (if managed)
        to allow last resort option in case a quorum
        goes rogue. Overwrite if you don't need an admin control
        No check on minSig so if the no of members drops below
        minSig, the quorum becomes unusable.
     @param _address The address to be removed from quorum
     */
    function forceRemoveFromQuorum(address _address)
        external
        virtual
        onlyAdmin
    {
        Quorum memory q = quorumSubscriptions[_address];
        require(q.id != address(0), "MSC: subscription not found");
        _removeFromQuorum(_address, q.id);
    }

    bytes32 constant REMOVE_FROM_QUORUM_METHOD =
        keccak256("RemoveFromQuorum(address _address,bytes32 salt,uint64 expiry)");

    /**
     @notice Removes an address from the quorum. Note the number of addresses 
      in the quorum cannot drop below minSignatures.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to remove
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function removeFromQuorum(
        address _address,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external virtual {
        internalRemoveFromQuorum(_address, salt, expiry, multiSignature);
    }

    bytes32 constant ADD_TO_QUORUM_METHOD =
        keccak256(
            "AddToQuorum(address _address,address quorumId,bytes32 salt,uint64 expiry)"
        );

    /**
     @notice Adds an address to the quorum.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to be added
     @param quorumId The quorum ID
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function addToQuorum(
        address _address,
        address quorumId,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external expiryRange(expiry) {
        require(quorumId != address(0), "MSC: quorumId required");
        require(_address != address(0), "MSC: address required");
        require(salt != 0, "MSC: salt required");
        bytes32 message = keccak256(
            abi.encode(ADD_TO_QUORUM_METHOD, _address, quorumId, salt, expiry)
        );
        Quorum memory q = quorums[quorumId];
        require(q.id != address(0), "MSC: quorum not found");
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        require(quorumSubscriptions[_address].id == address(0), "MSC: user already in a quorum");
        quorumSubscriptions[_address] = q;
        quorumsSubscribers[q.id] += 1;
        emit AddedToQuorum(quorumId, _address);
    }

    bytes32 constant UPDATE_MIN_SIGNATURE_METHOD =
        keccak256(
            "UpdateMinSignature(address quorumId,uint16 minSignature,bytes32 salt,uint64 expiry)"
        );

    /**
     @notice Updates the min signature for a quorum.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param quorumId The quorum ID
     @param minSignature The new minSignature
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function updateMinSignature(
        address quorumId,
        uint16 minSignature,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external expiryRange(expiry) {
        require(quorumId != address(0), "MSC: quorumId required");
        require(minSignature > 0, "MSC: minSignature required");
        require(salt != 0, "MSC: salt required");
        Quorum memory q = quorums[quorumId];
        require(q.id != address(0), "MSC: quorumId not found");
        require(
            quorumsSubscribers[q.id] >= minSignature,
            "MSC: minSignature is too large"
        );
        bytes32 message = keccak256(
            abi.encode(
                UPDATE_MIN_SIGNATURE_METHOD,
                quorumId,
                minSignature,
                salt,
                expiry
            )
        );
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        quorums[quorumId].minSignatures = minSignature;
    }

    bytes32 constant CANCEL_SALTED_SIGNATURE =
        keccak256("CancelSaltedSignature(bytes32 salt)");

    /**
     @notice Cancel a salted signature
        Remove this method if public can create groupIds.
        People can write bots to prevent a person to execute a signed message.
        This is useful for cases that the signers have signed a message
        and decide to change it.
        They can cancel the salt first, then issue a new signed message.
     @param salt The signature salt
     @param expectedGroupId Expected group ID for the signature
     @param multiSignature The multisig encoded signature
    */
    function cancelSaltedSignature(
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) external virtual {
        require(salt != 0, "MSC: salt required");
        bytes32 message = keccak256(abi.encode(CANCEL_SALTED_SIGNATURE, salt));
        require(
            expectedGroupId != 0 && expectedGroupId < 256,
            "MSC: not governance groupId"
        );
        verifyUniqueSalt(message, salt, expectedGroupId, multiSignature);
    }

    /**
    @notice Initialize a quorum
        Override this to allow public creatig new quorums.
        If you allow public creating quorums, you MUST NOT have
        customized groupIds. Make sure groupId is created from
        hash of a quorum and is not duplicate.
    @param quorumId The unique quorumID
    @param groupId The groupID, which can be shared by quorums (if managed)
    @param minSignatures The minimum number of signatures for the quorum
    @param ownerGroupId The owner group ID. Can modify this quorum (if managed)
    @param addresses List of addresses in the quorum
    */
    function initialize(
        address quorumId,
        uint64 groupId,
        uint16 minSignatures,
        uint8 ownerGroupId,
        address[] calldata addresses
    ) public virtual onlyAdmin {
        _initialize(quorumId, groupId, minSignatures, ownerGroupId, addresses);
    }

    /**
     @notice Initializes a quorum
     @param quorumId The quorum ID
     @param groupId The group ID
     @param minSignatures The min signatures
     @param ownerGroupId The owner group ID
     @param addresses The initial addresses in the quorum
     */
    function _initialize(
        address quorumId,
        uint64 groupId,
        uint16 minSignatures,
        uint8 ownerGroupId,
        address[] memory addresses
    ) internal virtual {
        require(quorumId != address(0), "MSC: quorumId required");
        require(addresses.length > 0, "MSC: addresses required");
        require(minSignatures != 0, "MSC: minSignatures required");
        require(
            minSignatures <= addresses.length,
            "MSC: minSignatures too large"
        );
        require(quorums[quorumId].id == address(0), "MSC: already initialized");
        require(ownerGroupId == 0 || ownerGroupId != groupId, "MSC: self ownership not allowed");
        if (groupId != 0) {
            ensureUniqueGroupId(groupId);
        }
        Quorum memory q = Quorum({
            id: quorumId,
            groupId: groupId,
            minSignatures: minSignatures,
            ownerGroupId: ownerGroupId
        });
        quorums[quorumId] = q;
        quorumList.push(quorumId);
        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                quorumSubscriptions[addresses[i]].id == address(0),
                "MSC: only one quorum per subscriber"
            );
            quorumSubscriptions[addresses[i]] = q;
        }
        quorumsSubscribers[quorumId] = addresses.length;
        emit QuorumCreated(q);
    }

    /**
     @notice Ensures groupID is unique. Override this method if your business
      logic requires special management of groupId and ownerGroupIds such that
      duplicate groupIds are allowed.
     @param groupId The groupId
     */
    function ensureUniqueGroupId(uint256 groupId
    ) internal virtual {
        require(groupId != 0, "MSC: groupId required");
        require(!groupIds[groupId], "MSC: groupId is not unique");
        groupIds[groupId] = true;
    }

    /**
     @notice Removes an address from the quorum. Note the number of addresses 
      in the quorum cannot drop below minSignatures.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to remove
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function internalRemoveFromQuorum(
        address _address,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) internal virtual expiryRange(expiry) {
        require(_address != address(0), "MSC: address required");
        require(salt != 0, "MSC: salt required");
        Quorum memory q = quorumSubscriptions[_address];
        require(q.id != address(0), "MSC: subscription not found");
        bytes32 message = keccak256(
            abi.encode(REMOVE_FROM_QUORUM_METHOD, _address, salt, expiry)
        );
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        uint256 subs = quorumsSubscribers[q.id];
        require(subs >= quorums[q.id].minSignatures + 1, "MSC: quorum becomes ususable");
        _removeFromQuorum(_address, q.id);
    }


    /**
     @notice Remove an address from the quorum
     @param _address the address
     @param qId The quorum ID
     */
    function _removeFromQuorum(address _address, address qId) internal {
        delete quorumSubscriptions[_address];
        quorumsSubscribers[qId] = quorumsSubscribers[qId] - 1;
        emit RemovedFromQuorum(qId, _address);
    }

    /**
     @notice Checking salt's uniqueness because same message can be signed with different people.
     @param message The message to verify
     @param salt The salt to be unique
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     */
    function verifyUniqueSalt(
        bytes32 message,
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal virtual {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        (, bool result) = tryVerify(message, expectedGroupId, multiSignature);
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message already used");
        usedHashes[salt] = true;
    }

    function verifyUniqueSaltWithQuorumId(
        bytes32 message,
        address expectedQuorumId,
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal virtual {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        bytes32 digest = _hashTypedDataV4(message);
        (bool result, address[] memory signers) = tryVerifyDigestWithAddress(digest, expectedGroupId, multiSignature);
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message already used");
        require(
            expectedQuorumId == address(0) ||
            quorumSubscriptions[signers[0]].id == expectedQuorumId, "MSC: wrong quorum");
        usedHashes[salt] = true;
    }

    /**
     @notice Verifies the a unique un-salted message
     @param message The message hash
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     */
    function verifyUniqueMessageDigest(
        bytes32 message,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        (bytes32 salt, bool result) = tryVerify(
            message,
            expectedGroupId,
            multiSignature
        );
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message digest already used");
        usedHashes[salt] = true;
    }

    /**
     @notice Tries to verify a digest message
     @param digest The digest
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     @return result Identifies success or failure
     */
    function tryVerifyDigest(
        bytes32 digest,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bool result) {
        (result, ) = tryVerifyDigestWithAddress(
            digest,
            expectedGroupId,
            multiSignature
        );
    }

    /**
     @notice Returns if the digest can be verified
     @param digest The digest
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig. Note that this
        format requires signatures to be sorted in the order of signers (as bytes)
     @return result Identifies success or failure
     @return signers Lis of signers.
     */
    function tryVerifyDigestWithAddress(
        bytes32 digest,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bool result, address[] memory signers) {
        (result, signers) = tryVerifyDigestWithAddressWithMinSigCheck(digest, expectedGroupId, multiSignature, true);
    }

    /**
     @notice Returns if the digest can be verified
     @param digest The digest
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig. Note that this
        format requires signatures to be sorted in the order of signers (as bytes)
     @param checkForMinSigs If the minimum number of signatures check should be performed
     @return result Identifies success or failure
     @return signers Lis of signers.
     */
    function tryVerifyDigestWithAddressWithMinSigCheck(
        bytes32 digest,
        uint64 expectedGroupId,
        bytes memory multiSignature,
        bool checkForMinSigs
    ) internal view returns (bool result, address[] memory signers) {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        MultiSigLib.Sig[] memory signatures = MultiSigLib.parseSig(
            multiSignature
        );
        require(signatures.length > 0, "MSC: no zero len signatures");
        signers = new address[](signatures.length);

        address _signer = ECDSA.recover(
            digest,
            signatures[0].v,
            signatures[0].r,
            signatures[0].s
        );
        signers[0] = _signer;
        address quorumId = quorumSubscriptions[_signer].id;
        if (quorumId == address(0)) {
            return (false, new address[](0));
        }
        require(
            expectedGroupId == 0 || quorumSubscriptions[_signer].groupId == expectedGroupId,
            "MSC: invalid groupId for signer"
        );
        Quorum memory q = quorums[quorumId];
        for (uint256 i = 1; i < signatures.length; i++) {
            _signer = ECDSA.recover(
                digest,
                signatures[i].v,
                signatures[i].r,
                signatures[i].s
            );
            quorumId = quorumSubscriptions[_signer].id;
            if (quorumId == address(0)) {
                return (false, new address[](0));
            }
            require(
                q.id == quorumId,
                "MSC: all signers must be of same quorum"
            );

            require(
                expectedGroupId == 0 || q.groupId == expectedGroupId,
                "MSC: invalid groupId for signer"
            );
            signers[i] = _signer;
            // This ensures there are no duplicate signers
            require(signers[i - 1] < _signer, "MSC: Sigs not sorted");
        }

        if (checkForMinSigs) {
            require(signatures.length >= q.minSignatures, "MSC: not enough signatures");
        }
        return (true, signers);
    }

    /**
     @notice Tries to verify a message hash
        @dev example message;

        bytes32 constant METHOD_SIG =
            keccak256("WithdrawSigned(address token,address payee,uint256 amount,bytes32 salt)");
        bytes32 message = keccak256(abi.encode(
          METHOD_SIG,
          token,
          payee,
          amount,
          salt
     @param message The message
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
    */
    function tryVerify(
        bytes32 message,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bytes32 digest, bool result) {
        digest = _hashTypedDataV4(message);
        result = tryVerifyDigest(digest, expectedGroupId, multiSignature);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

library MultiSigLib {
	struct Sig { uint8 v; bytes32 r; bytes32 s; }

	/**
	 * Signature is encoded as below:
	 * every two bytes32, is an (r, s) pair.
	 * last bytes32 is the v's array.
	 * If we have more than 32 sigs, more
	 * bytes at the end are dedicated to vs.
	 */
	function parseSig(bytes memory multiSig)
	internal pure returns (Sig[] memory sigs) {
		uint cnt = multiSig.length / 32;
		cnt = cnt * 32 * 2 / (2*32+1);
		uint vLen = (multiSig.length / 32) - cnt;
		require(cnt - (cnt / 2 * 2) == 0, "MSL: Invalid sig size");
		sigs = new Sig[](cnt / 2);
		uint rPtr = 0x20;
		uint sPtr = 0x40;
		uint vPtr = multiSig.length - (vLen * 0x20) + 1;
		for (uint i=0; i<cnt / 2; i++) {
			bytes32 r;
			bytes32 s;
			uint8 v;
			assembly {
					r := mload(add(multiSig, rPtr))
					s := mload(add(multiSig, sPtr))
					v := mload(add(multiSig, vPtr))
			}
			rPtr = rPtr + 0x40;
			sPtr = sPtr + 0x40;
			vPtr = vPtr + 1;

			sigs[i].v = v;
			sigs[i].r = r;
			sigs[i].s = s;
		}
	}
}