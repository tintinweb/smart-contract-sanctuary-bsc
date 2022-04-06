/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid sig 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid sig 'v' value");
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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
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


    function lockByMarshall(address target, uint amount, uint32 duration) external returns(bool);
    function unlockBalanceByMarshall(address target, address to, uint amount) external returns(bool);
    function activateMarshall(address target) external returns(bool);
    function deactivateMarshall(address target) external returns(bool);


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

    struct VaultData {
        uint32 lockUntil;
        uint256 amount;
    }

    ///@dev structured data for holding user's balance
    struct Holders {
        mapping(address=>VaultData) vault;
    }

}



interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

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
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
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


library Encoder {
    function toBytes(string memory _literal) internal pure returns(bytes memory) {
        return abi.encodeWithSignature(_literal);
    }
    //solhint-disable-next-line
    function toBytes_Addr(string memory _literal, address arg) internal pure returns(bytes memory) {
        return abi.encodeWithSignature(_literal,arg);
    }

    //solhint-disable-next-line
    function toBytes_Addr1_Uint1(string memory _literal, address arg1, uint arg2) internal pure returns(bytes memory) {
        return abi.encodeWithSignature(_literal,arg1,arg2);
    }

    //solhint-disable-next-line
    function toBytes_Addr1_Uint2(string memory _literal, address arg1, uint arg2, uint arg3) internal pure returns(bytes memory) {
        return abi.encodeWithSignature(_literal,arg1,arg2,arg3);
    }

    //solhint-disable-next-line
    function toBytes_Addr2_Uint1(string memory _literal, address arg1, address arg2, uint arg3) internal pure returns(bytes memory) {
        return abi.encodeWithSignature(_literal,arg1,arg2,arg3);
    }
    
    //solhint-disable-next-line
    function toBytes_Addr2(string memory _literal, address arg1, address arg2) internal pure returns(bytes memory) {
        return abi.encodeWithSignature(_literal,arg1,arg2);
    }

    //solhint-disable-next-line
    function toBytes_AddrUintBytes32(string memory _literal, address arg1, uint arg2, bytes32 arg3) internal pure returns(bytes memory) {
        return abi.encodeWithSignature(_literal,arg1,arg2,arg3);
    }
}

library Decoder {
    function toUint256(bytes memory data) internal pure returns(uint256) {
        return abi.decode(data, (uint256));
    }

    function toUint8(bytes memory data) internal pure returns(uint8) {
        return abi.decode(data, (uint8));
    }

    function toBool(bytes memory data) internal pure returns(bool) {
        return abi.decode(data, (bool));
    }

    function toAddress(bytes memory data) internal pure returns(address) {
        return abi.decode(data, (address));
    }

}


library Verifier {
    using Decoder for bytes;
    
    function verifyTrue(bytes memory data) internal pure returns(bool) {
        require(data.toBool(), "Call failed");
        return true;
    }

    function verifyUintGT(bytes memory a, uint256 b) internal pure returns(uint256) {
        uint256 c = a.toUint256();
        require(c > b, "Source errored");
        return c;
    }

    function verifyUint8GT(bytes memory a, uint8 b) internal pure returns(uint8) {
        uint8 c = a.toUint8();
        require(c > b, "Invalid");
        return c;
    }

    function verifyUintGEq(bytes memory a, uint256 b) internal pure returns(uint256) {
        uint256 c = a.toUint256();
        require(c >= b, "Not correspond");
        return c;
    }

    function notZero(address target) internal pure {
        require(target != zero(), "address: zero");
    }

    function notZeros(address a, address b) internal pure {
        require(a != zero() && b != zero(), "address: zero");
    }


    function zero() internal pure returns(address) {
        return address(0);
    }

    function isZero(address target) internal pure returns(bool) {
        return target == zero();
    }

    function isTrue(bool _type) internal pure {
        require(_type, "False");
    }

    function notTrue(bool _type) internal pure {
        require(!_type, "True");
    }

    function isGThan(uint a, uint b) internal pure {
        require(a > b,"Not greater than");
    }

    function isGTLessThan(uint a, uint b, uint c) internal pure {
        require(a > b && a < c,"Invalid arg");
    }

    function isGOrEqual(uint a, uint b) internal pure {
        require(a >= b,"Not greater or equal");
    }

    function isGaL(uint a, uint b, uint c) internal pure {
        require(a >= b && a <= c, "Invalid amount");
    }

    function ifGThan(uint a, uint b) internal pure returns(bool) {
        return a > b;
    }

    function ifGThanOrEqual(uint a, uint b) internal pure returns(bool) {
        return a >= b;
    }

    function equateAddr(address a, address b, string memory errorMessage) internal pure {
        require(a == b, errorMessage);
    }
}


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
abstract contract Ownable is Pausable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
        require(owner() == _msgSender(), "Ownable: not the owner");
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
        require(newOwner != address(0), "Ownable: zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}




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

/**@author Quatrefinance {Bobeu}
    NOTE: ALL DEPENDENCY MODULES AND SUBMODULES RALATED TO THIS CONTRACT ARE IMPORTED AND INSPIRED BY THE 
            OPENZEPPELIN CONTRACTS. WE FORWARD OUR REGARDS AND KUDOS TO THESE GREAT GUYS.
                ERC20Upg IS UPGRADEABLE AND WE HAVE STRICTLY FOLLOW OZ's 
                        GUIDELINES FOR WRITING UPGRADEABLE CONTRACTS.

 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn"t required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
abstract contract ERC20NoUpg is IERC20Metadata, Context, Ownable {
      using SafeMath for uint256;

    uint256 private iterator;//balance iterator: differentiator for balances internally
    uint256 private _totalSupply;//Total supply at any given time. Changes with respect to stakings
    address private _grandMarshall;

    mapping(address=>uint256) private _balances; // Houses user's balances
    mapping(address=>Holders) private holders; //Mapping of all holders
    mapping(address=>mapping(address=>uint256)) private _allowances; //Allowances mapping
    mapping(address=>uint256) public vestings;
    mapping(address=>bool) private marshalls;

    string private _name = "Qf Token"; ///@notice ERC20 Token Name
    string private _symbol = "QTOK"; ///@notice ERC20 Token symbol
    bool private boolVars; //Initializers

    modifier isMarshalled() {
        require(marshalls[_msgSender()], "UnAuthorized");
        _;
    }

    constructor(uint _supply) {
        boolVars = false; 
        vestings[address(this)] = _supply * 10**18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory _nam) {
        _nam = _name;
        return _nam;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory _sym) {
        _sym = _symbol;
        return _sym;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256 _ts) {
        _ts = _totalSupply;
        return _ts;
    }

    function setGrandMarshall(address newGMarshall) public onlyOwner {
        require(newGMarshall != address(0), "GM: is zero address");
        _grandMarshall = newGMarshall;
    }

    function grandMarshall() public view returns(address) {
        return _grandMarshall;        
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns(uint bal) {
        bal = _balances[account];
        return bal;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address _owner, address spender) public view override returns(uint256 _allow) {
        _allow = _allowances[_owner][spender];
        return _allow;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // ///@dev Approve a new sale address callable only by the owner
    // function elevate(address newAddr) public onlyOwner returns(bool) {
    //     require(newAddr != address(0), "Invalid address");
    //     _allowances[address(this)][newAddr] = 1;
    //     return true;
    // }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``"s tokens of at least
     * `amount`.
     * If called by the farmer, it signifies staking.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount) public override returns(bool) {
            _transfer(sender, recipient, amount);

            uint256 curAllow = _allowances[sender][_msgSender()];
            require(curAllow >= amount, "ERC20: Amt exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), curAllow - amount);
            }

            return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _beforeTokenTransfer(_msgSender(), spender, addedValue);
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subVal`.
     */
    function decreaseAllowance(address spender, uint256 subVal) public returns (bool) {
        _beforeTokenTransfer(_msgSender(), spender, subVal);
        uint256 curAllow = _allowances[_msgSender()][spender];
        require(curAllow >= subVal, "Decreased allowance below zero");
        _approve(_msgSender(), spender, curAllow.sub(subVal));

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * We did a few twist here: This is a generic ERC20 transfer, to keep with the 
     * standard, balance of sender is deducted from the normal iterated balance
     * but we check if recipient has lock in force, preference is given to the extra 
     * secure layer.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        _beforeTokenTransfer(sender, recipient, amount);
        require(recipient != address(0), "address: zero");
        uint mainLedgerBalSender = _balances[sender];
        uint mainLedgerBalrecipient = _balances[recipient];
        require(mainLedgerBalSender >= amount, "ERC20: Amount exceeds balance");
        _balances[sender] = mainLedgerBalSender.sub(amount);
        unchecked {
            _balances[recipient] = mainLedgerBalrecipient + amount;
        }
        
        emit Transfer(sender, recipient, amount);

    }

    ///@dev unlocks target by Marshall
    function unlockBalanceByMarshall(address target, address to, uint amount) public override isMarshalled returns(bool) {
        return _unlock(target, _msgSender(), to, amount);
    }

    function _now() internal view returns(uint32) {
        return uint32(block.timestamp);
    }

    function _lock(address target, uint32 duration, address lockTo, uint amount) private returns(bool _return) {
        require(duration > 0, "Invalid timestamp");
        unchecked {
            holders[target].vault[lockTo].lockUntil = duration;
        }
        uint mainLedgerBalrecipient = _balances[target];
        require(mainLedgerBalrecipient >= amount, "insufficient Balance");
        uint _amt = holders[target].vault[lockTo].amount;
        unchecked {
            _balances[target] = mainLedgerBalrecipient - amount;
            holders[target].vault[lockTo].amount = _amt + amount;
        }
        _return = true;
    }

    function _unlock(address target, address lockTo, address to, uint amount) private returns(bool _return) {
        uint lockedBal = holders[target].vault[lockTo].amount;
        uint32 duration = holders[target].vault[lockTo].lockUntil;
        require(lockedBal >= amount, "Marshal: Amount exceed locked");
        if(_now() < duration) revert("UNLOCK: Time is ahead");
        uint mainLedgerBalrecipient = _balances[to];
        unchecked {
            holders[target].vault[lockTo].amount = lockedBal - amount;
            _balances[to] = mainLedgerBalrecipient + amount;
        }
        _return = true;
    }

    ///@dev locks target by marshall
    function lockByMarshall(address target, uint amount, uint32 duration) public override isMarshalled returns(bool) {
        return _lock(target, duration, _msgSender(), amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * @notice _mints simply transfers from the owners' unlocked balance to 
     *   recipient "to"s balance.
     */
    function _mint(address to, uint256 amount) internal virtual {
        require(to != address(0), "ERC20: mint zero address?");
        _beforeTokenTransfer(address(this), to, amount);
        require(vestings[address(this)] >= amount, "Empty");
        _adjustSupply(amount, 1);
        unchecked {
            vestings[address(this)] -= amount;
            _balances[to] += amount;
        }
    }


    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `recipient` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        _beforeTokenTransfer(account, address(0), amount);
        require(account != address(0), "ERC20: zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: Low bal");

        unchecked {
            _balances[account] = accountBalance - amount;
        }
        emit Transfer(account, address(0), amount);
        _adjustSupply(amount, 0);

    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `_owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `_owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) internal {
        require(_owner != address(0) && spender != address(0), "ERC20: zero address");
        _beforeTokenTransfer(_owner, spender, amount);
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    //@dev Approves specific contract to perform special transaction
    function _setMarshall(address marshall, bool value) internal virtual returns(bool _return) {
        bool _value = marshalls[marshall];
        require(_value != value, "Already Marshalled");
        marshalls[marshall] = value;
        _return = true;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``"s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``"s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    /**@dev Adjusts supply with an 'amount' based on the command 'cmd'.
        @param amount - Total Supply adjustable with 'amount'.
        @param cmd - '0' command reduces the totalSupply
        @param cmd - 'any' (uint8) increases the totalSupply
     */
    function _adjustSupply(uint amount, uint8 cmd) internal virtual {
        uint tSupply = _totalSupply;
        if(cmd == 0) {
            require(tSupply >= amount, "Amt greater than supply");
            _totalSupply = tSupply.sub(amount);
        } else {
            _totalSupply = tSupply.add(amount);
        }
 
    }

    /**@dev reduces the regular balance of target by an "amount" when cmd = 0. otherwise, increases it by "amount"
     */
    function _toggleBalance(address target, uint amount, uint _reward, uint8 cmd) internal virtual {
        uint bal = _balances[target];
        if(cmd == 0) {
            require(bal >= amount, "Not enough balance to stake");
            unchecked {
                _balances[target] = bal - amount;
                vestings[_msgSender()] += amount;
                _adjustSupply(amount, 0);
            }
        } else {
            _balances[target] = bal.add(amount);
            uint vst = vestings[address(this)];
            if(vst >= _reward) {
                vestings[address(this)] -= _reward;
                _balances[target] += _reward;
            }
            _adjustSupply(amount.add(_reward), 1);
        }
    }

    function _tip(address _fan, uint amount) private {
        uint regFarm = _balances[address(this)];
        if(amount > 0) {
            uint tip;
            unchecked {
                uint _tipRate = ((1.0e18 * 10000) / 100.0e18) * 10**18;
                tip = ((_tipRate * amount) / 10**18) / 10000;
            }
            if(regFarm >= tip) {
                _transfer(address(this), _fan, tip);
                _adjustSupply(tip, 1);
            }
        }
    }

    /**@dev Activate or deactivate fantip
        @param cmd - Activates if zero otherwise Deactivates.
     */
    function toggleTip(uint8 cmd) public onlyOwner returns(bool) {
        if(cmd == 0) {
            require(!boolVars, "Already activated");
            boolVars = true;
        } else {
            require(boolVars, "Already deactivated");
            boolVars = false;
        }
        return true;
    }

}



abstract contract ERC20Permit is ERC20NoUpg, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(uint _supply) EIP712("Qfour Token", "1") ERC20NoUpg(_supply) {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}


abstract contract QTokenAbstract is ERC20Permit {
    constructor (uint _supply) ERC20Permit(_supply) {
        transferOwnership(_msgSender());
    }


    ///@dev Pauses the contract. When called, some functions are halted.
    function pause() public returns(uint8) {
        require(_msgSender() == owner() || allowance(address(this), _msgSender()) == 1, "Not authorized");
        _pause();
        return 1;
    }

    ///@dev unpauses the contract.
    function unpause() public returns(uint8) {
        require(_msgSender() == owner() || allowance(address(this), _msgSender()) == 1, "Not authorized");
        _unpause();
        return 1;
    }

     /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "Pausable: transfer while paused");
    }

    //Returns current block number
    function currBlockAndTimestamp() public view returns(uint256, uint256) {
        return (block.number, block.timestamp);
    }

}


contract QuatreTokenModule is QTokenAbstract, ReentrancyGuard {
    modifier onlyGrandMarshall(address caller) {
        if(caller != grandMarshall()) revert("UnAuthorized");
        _;
    }

    constructor() QTokenAbstract(1_000_000_000) {
        transferOwnership(_msgSender());
    }

    
    receive() external payable {
        require(msg.value > 1e15 wei, "Failed");
    }

    function emergencyWithdraw(address to) public payable onlyOwner returns(bool) {
        uint amount = address(this).balance;
        require(amount > 0 && to != address(0), "Invalid args");
        //solhint-disable-next-line
        (bool success,) = to.call{value:amount}("");
        require(success, "Transfer failed");
        return true;
    }

    function activateMarshall(address target) public override onlyGrandMarshall(_msgSender()) returns(bool) {
        return _setMarshall(target, true);
    }

    function deactivateMarshall(address target) public override onlyGrandMarshall(_msgSender()) returns(bool) {
        return _setMarshall(target, false);
    }

    ///@dev Mints token of amount to recipient increases the recipient"s balance
    //Should only be called by the owner.
    function mintToken(address recipient, uint amount) public onlyOwner returns(uint8) {
        _mint(recipient, amount);
        return 1;
    }

    function mintBatch(address[] memory recipients, uint amount) public onlyOwner returns(uint8) {
        for(uint i = 0; i < recipients.length; i++) {
            address to = recipients[i];
            _mint(to, amount);
        }
        return 1;
    }

     /**
     * @dev Snapshots the totalSupply after it has been decreased.
     * NOTE: can only burn by the farmer and only after buyback or specific request
     * from an account.
     * Again, it is very unlikely for the farmer to burn from the treasury since the whole supply is not 
     * in circulation yet.
     * To burn after buyback, Farmer can either do it via another account or send to itself then burn.
     */
    function burn(address account, uint256 amount) external onlyOwner returns(uint8) {
        _burn(account, amount);
        return 1;
    }


}