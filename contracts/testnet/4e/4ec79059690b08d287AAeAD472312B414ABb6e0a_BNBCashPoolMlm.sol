/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IBEP1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

pragma solidity 0.8.17;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

pragma solidity 0.8.17;

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
  
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

pragma solidity 0.8.17;

interface IBEP20 {
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

pragma solidity 0.8.17;

library Math {
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
}

pragma solidity 0.8.17;

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

pragma solidity 0.8.17;

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

pragma solidity 0.8.17;

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

pragma solidity 0.8.17;

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

pragma solidity 0.8.17;

library SignatureChecker {
    function isValidSignatureNow( bytes32 hash, address signer, bytes memory signature) internal pure returns (bool) {
        bytes32 ethSignedMsg = ECDSA.toEthSignedMessageHash(hash);
        address signerAddress = ECDSA.recover(ethSignedMsg,signature);
        return signer == signerAddress;
    }
}

pragma solidity 0.8.17;

library SafeBEP20 {
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity 0.8.17;

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

pragma solidity 0.8.17;

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

pragma solidity 0.8.17; 

contract BNBCashPoolMlm is Ownable, Pausable {
    using SafeMath for uint;
    using SafeBEP20 for IBEP20;
    using SignatureChecker for bytes32;

    IBEP20 public BCP;
    IBEP20 public BUSD;
    address public signer;
    IUniswapV2Router02 public router; //0x9ac64cc6e4415144c455bd8e4837fea55603e5c3
    address public uniswapPair;

    uint public currReferenceId = 0;
    uint public totalReferenceId = 0;
    uint public entryFee = 10 ether;
    uint public multiplier = 4;
    uint public resDividend = 1000;
    uint public creatorFee = 800;
    uint public exceedDividend = 5000;
    uint public resPoolTimeStamp = 30 days;
    bool public lockSwap;
    
    uint constant ELIGIBLE_TO_STAKE = 3;
    uint constant REQUIRED_DOWNLNES = 3;
    uint256 constant internal MAGNITUDE = 2 ** 64;

    struct Level {
        uint levelPrice;
        uint cashout;
        uint dividends;
    }

    struct User {
        uint referenceId;
        uint userId;
        uint currentLvl;
        uint totalCashOut;
        uint allowedSponsor;
        address[] referrals;
        address[] sponsors;
        bytes32 sponsorCode;
        bool registered;
        UserResPool reservePool;
        mapping(uint => UserDivPool) userDividendPool;
        mapping(uint => bool) isClaimed;
        mapping(uint => bool) isDividendAdded;
        mapping(uint => bool) existInPool;
    }
    
    struct UserDivPool {
        int256 payoutsTo;
        uint totalClaimed;
        uint stakedAmount;
        uint reserveAmt;
        bool isExist;
    }
    
    struct UserResPool {
        uint totalReservePool;
        uint totalReservePoolClaimed;
        uint dividend;
        uint divClaimed;
        uint lastClaimed;
        bool isActivated;
    }
    
    struct Pool {
        uint level;
        uint stakeAmt;
        uint affiliate;
    }
    
    struct DividendPool {
        uint totalShares;
        uint totalDivShared;
        uint divPerShare;
    }
    
    struct CashOut {
        uint level;
        bool isUpgradeExceed;
        bytes signature;
        uint deadLine;
    }

    Level[] public levels;
    mapping(address => User) private user;
    mapping(uint => address) public userByRefId;
    mapping(bytes32 => bool) public isVerified;
    mapping(uint => Pool) public pools;
    mapping(uint => DividendPool) public dividendPool;
    mapping(bytes32 => address) public sponsorCodeOwnership;

    event RegisteredEvent(
        address indexed upline,
        address indexed user,
        bytes32 indexed sponsorCode,
        uint entryFees,
        uint64 timestamp
    );
    event CashOutEvent(
        address indexed caller,
        uint indexed level,
        uint claimed,
        uint64 timestamp
    );
    event StakeEvent(
        address indexed caller,
        uint amount,
        uint indexed level,
        uint64 timestamp
    );
    event DividendPoolEvent (
        address indexed caller,
        uint indexed poolId,
        uint dividend,
        uint64 timestamp
    );
    event DividendReservePoolEvent (
        address indexed caller,
        uint dividend,
        uint64 timestamp
    );
    event AddedDivToPoolEvent (
        uint indexed poolId,
        uint dividend,
        uint64 timestamp
    );
    event ReservePoolActivationEvent (
        address indexed caller,
        uint dividend,
        uint64 timestamp
    );

    constructor(IBEP20 bcp, IBEP20 busd, address signerAddress) {
        require(bcp != IBEP20(address(0)), "BNBCashPoolMlm: bcp is zero");
        require(busd != IBEP20(address(0)), "BNBCashPoolMlm: bcp is zero");
        require(signerAddress != address(0), "BNBCashPoolMlm: signerAddress is zero");

        BCP = bcp;
        BUSD = busd;
        signer = signerAddress;
        Level memory level;
        levels.push(level);
        router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        
        uniswapPair = address(IUniswapV2Factory(router.factory()).getPair(router.WETH(), address(busd)));

        initLevel();
        initPools();
        lockSwap = true;
    }

    receive() external payable {}

    function updateBCP(IBEP20 newBCP) external onlyOwner {
        require(address(newBCP) != address(0), "updateBCP: newBCP is zero");
        BCP = newBCP;
    }

    function updateBUSD(IBEP20 newBUSD) external onlyOwner {
        require(address(newBUSD) != address(0), "updateBUSD: newBUSD is zero");
        BUSD = newBUSD;
    }

    function updateSigner(address newSigner) external onlyOwner {
        require(newSigner != address(0), "UpdateSigner: newSigner is zero");
        signer = newSigner;
    }

    function updateEntryFee(uint newEntryFee) external onlyOwner {
        require(newEntryFee != 0, "UpdateEntryFee: newEntryFee is zero");
        entryFee = newEntryFee;
    }

    function updateMultiplier(uint newMultiplier) external onlyOwner {
        require(newMultiplier != 0, "updateMultiplier: newMultiplier is zero");
        multiplier = newMultiplier;
    }

    function updateResPoolTimeStamp(uint newResPoolTimeStamp) external onlyOwner {
        require(newResPoolTimeStamp != 0, "updateResPoolTimeStamp: newResPoolTimeStamp is zero");
        resPoolTimeStamp = newResPoolTimeStamp;
    }

    function updateResDividend(uint newResDividend) external onlyOwner {
        require(newResDividend != 0, "updateResDividend: newResDividend is zero");
        resDividend = newResDividend;
    }

    function updateExceedDividend(uint newExceedDividend) external onlyOwner {
        require(newExceedDividend != 0, "updateExceedDividend: newExceedDividend is zero");
        exceedDividend = newExceedDividend;
    }

    function updateCreatorFee(uint newCreatorFee) external onlyOwner {
        require(newCreatorFee != 0, "updateCreatorFee: newCreatorFee is zero");
        creatorFee = newCreatorFee;
    }

    function updateLockSwap(bool newLockSwap) external onlyOwner {
        lockSwap = newLockSwap;
    }

    function updateRouter(IUniswapV2Router02 newRouter) external onlyOwner {
        router = newRouter;
    }

    function updatePair(address newUniswapPair) external onlyOwner {
        uniswapPair = newUniswapPair;
    }

    function updateLevelCashout(uint level, uint newCashOut) external onlyOwner {
        require(level > 0 && level < levels.length, "updateLevelCashout: incorrect index");
        require(newCashOut != 0, "updateLevelCashout: newCashOut is zero");
        levels[level].cashout = newCashOut;
    }

    function updateLevelDiv(uint level, uint newDiv) external onlyOwner {
        require(level > 0 && level < levels.length, "updateLevelDiv: incorrect index");
        require(newDiv != 0, "updateLevelDiv: newDiv is zero");
        levels[level].dividends = newDiv;
    }

    function updatePoolAffiliate(uint poolId, uint newAffiliate) external onlyOwner {
        require(newAffiliate != 0, "updatePoolAffiliate: zero affiliate");
        pools[poolId].affiliate = newAffiliate;
    }

    function updatePoolStakeAmount(uint poolId, uint newAmount) external onlyOwner {
        require(newAmount != 0, "updatePoolStakeAmount: zero stake amount");
        pools[poolId].stakeAmt = newAmount;
    }

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function register( bytes32 sponsorCode, bool payWithBNB) public payable whenNotPaused {
        address caller = _msgSender();
        User storage userStorage = user[caller];
        require(address(BUSD) != address(0), "register: BUSD is zero");
        require(!userStorage.registered, "register: caller already registered");
        _sponsorShip(caller, payWithBNB, sponsorCode);

        address upline;
        uint referenceId = currReferenceId;
        if (currReferenceId != 0 && totalReferenceId != 0) {
            upline = userByRefId[referenceId];
            User storage uplineStorage = user[upline];
            
            if (uplineStorage.registered) {
                uplineStorage.referrals.push(caller);
                if (uplineStorage.referrals.length == REQUIRED_DOWNLNES) {
                    currReferenceId++;
                    uplineStorage.currentLvl = 1;
                }
            }
        }
        if (currReferenceId == 0) {
            currReferenceId = 1;
        }
        totalReferenceId++;
        userStorage.registered = true;
        userStorage.referenceId = referenceId;
        userStorage.userId = totalReferenceId;
        userByRefId[totalReferenceId] = caller;
        emit RegisteredEvent(
            upline,
            caller,
            sponsorCode,
            entryFee,
            uint64(block.timestamp)
        );
    }

    function stake(uint level, bool allowSponsor, uint bcpPrice, bytes memory signature, uint deadLine) public whenNotPaused {
        address caller = _msgSender();
        User storage userStorage = user[caller];
        Pool memory pool = pools[level];
        require(deadLine > block.timestamp, "cashOut: deadline expired");
        require(pool.stakeAmt != 0, "stake: pool not exist");
        require(bcpPrice != 0, "stake: price is zero"); 
        require(!userStorage.existInPool[level], "stake: already exist in level");
        require(userStorage.currentLvl >= ELIGIBLE_TO_STAKE, "stake: user haven't reached level 3");
        
        bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), level, bcpPrice, allowSponsor, pool.stakeAmt, deadLine));
        require(!isVerified[msgHash], "stake: already verifed");
        require(msgHash.isValidSignatureNow( signer,signature), "stake: incorrect signature");
        
        bytes32 prevSponsorCode = userStorage.sponsorCode;
        isVerified[msgHash] = true;
        userStorage.existInPool[level] = true;
        userStorage.userDividendPool[findReservePool(level)].stakedAmount = pool.stakeAmt;
        userStorage.reservePool.totalReservePool = userStorage.reservePool.totalReservePool.add(
            pool.stakeAmt
        );
        if (prevSponsorCode == 0 && allowSponsor) {
            prevSponsorCode = sponsorCodeGenerator(caller);
            userStorage.sponsorCode = prevSponsorCode;
            sponsorCodeOwnership[prevSponsorCode] = caller;
        }
        if (prevSponsorCode != 0 && allowSponsor && !userStorage.isClaimed[level]) {
            userStorage.allowedSponsor = userStorage.allowedSponsor.add(pool.affiliate);
            userStorage.isClaimed[level] = true;
        }
        BUSD.safeTransferFrom(
            caller, 
            address(this), 
            pool.stakeAmt
        );        
        if (!lockSwap) {
            _swapToBCP(
                caller, 
                bcpPrice, 
                pool.stakeAmt
            );
        }
        emit StakeEvent(
            caller,
            pool.stakeAmt,
            level,
            uint64(block.timestamp)
        );
    }

    function cashOut(CashOut[] memory params, uint bcpPrice) public whenNotPaused {
        address caller = _msgSender();
        User storage userStorage = user[caller];        
        require(userStorage.currentLvl != 0, "cashOut: register before cashout");
        require(bcpPrice != 0, "cashOut: price is zero"); 
        require(userStorage.registered, "cashOut: register before cashout");
        require(params.length <= levels.length, "cashOut: level mismatch");
        
        uint totalCashOut = 0;
        uint exceedDiv = 0;
        for(uint index = 0; index < params.length; index++) {
            CashOut memory param = params[index];
            bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), param.level, bcpPrice, param.isUpgradeExceed, param.deadLine));
            if (!msgHash.isValidSignatureNow(signer,param.signature) ||
                param.deadLine < block.timestamp ||
                isVerified[msgHash]) {
                    if (!isVerified[msgHash]) {
                        isVerified[msgHash] = true;
                    }
                    continue;
            }
            isVerified[msgHash] = true;
            if (param.level == 0 || 
                param.level > levels.length ||
                levelCheckOut(caller, param.level)) {
                continue;
            }
            uint poolReserveId = findReservePool(param.level);
            if (poolReserveId > 0) {
                uint foundPool = findPool(poolReserveId);
                if (!isUserExistInPool(caller, foundPool) && 
                    foundPool == param.level && 
                    !param.isUpgradeExceed) {
                        param.isUpgradeExceed = true;
                }
            }
            userStorage.currentLvl = userStorage.currentLvl.add(1);
            Level memory level = levels[param.level];
            if (!userStorage.isClaimed[param.level]) {
                userStorage.isClaimed[param.level] = true;
                if(param.isUpgradeExceed) {
                    uint[2] memory divAndCommission;
                    divAndCommission[0] = level.cashout.mul(exceedDividend).div(10000);
                    divAndCommission[1] = (level.cashout).sub(divAndCommission[0]);
                    _addDivPool(
                        param.level,
                        divAndCommission[0]
                    );
                    exceedDiv = exceedDiv.add(divAndCommission[1]);
                    emit CashOutEvent(
                        caller,
                        param.level,
                        0,
                        uint64(block.timestamp)
                    );
                } else {
                    totalCashOut = totalCashOut.add(level.cashout);
                    emit CashOutEvent(
                        caller,
                        param.level,
                        level.cashout,
                        uint64(block.timestamp)
                    );
                }
            }   
            if (!userStorage.isDividendAdded[param.level] && level.dividends != 0) {
                userStorage.isDividendAdded[param.level] = true;                     
                if (!userStorage.userDividendPool[poolReserveId].isExist) {
                    DividendPool storage divPool = dividendPool[poolReserveId];   
                    UserDivPool storage _userReserve = userStorage.userDividendPool[poolReserveId];
                    Pool memory _pool = pools[findPool(poolReserveId)];
                    _userReserve.payoutsTo += (int256) (divPool.divPerShare * _pool.stakeAmt);
                    divPool.totalShares = divPool.totalShares.add(_pool.stakeAmt);
                    _userReserve.reserveAmt = _pool.stakeAmt;
                    _userReserve.isExist = true;
                }
                _addDivPool(
                    param.level,
                    level.dividends
                ); 
            }
            if (userStorage.currentLvl == levels.length) {
                activateReservePool(caller);
            }
        }
        require(totalCashOut != 0 || exceedDiv != 0, "cashOut: cashout is zero");
        userStorage.totalCashOut =  userStorage.totalCashOut.add(totalCashOut);
        _swapToBCP(caller, bcpPrice, totalCashOut);
        _swapToBCP(owner(), bcpPrice, exceedDiv);
    }

    function claimDividendPool(uint poolReserveId, uint bcpPrice, bytes memory signature, uint deadLine) public whenNotPaused {
        address caller = msg.sender;
        User storage userStorage = user[caller];
        DividendPool storage divPool = dividendPool[poolReserveId];
        UserDivPool storage userDivPool = userStorage.userDividendPool[poolReserveId];

        require(bcpPrice != 0, "claimReservePoolDividend: price is zero"); 
        require(deadLine > block.timestamp, "claimReservePoolDividend: dead line exceeds"); 
        require(!userStorage.reservePool.isActivated, "claimReservePoolDividend: total reserve is activated");
        require(userDivPool.isExist, "claimReservePoolDividend: reserve pool is not activated");
        uint256 dividends = (uint256) ((int256)(divPool.divPerShare * userDivPool.reserveAmt) - userDivPool.payoutsTo) / MAGNITUDE;
        require(dividends > 0, "claimReservePoolDividend: dividend is zero");
        bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), userStorage.userId, bcpPrice, deadLine));
        require(!isVerified[msgHash], "stake: already verifed");
        require(msgHash.isValidSignatureNow( signer,signature), "stake: incorrect signature");     

        isVerified[msgHash] = true;
        if (userDivPool.totalClaimed.add(dividends) > userDivPool.stakedAmount.mul(multiplier)) {
            dividends = (userDivPool.reserveAmt.mul(multiplier)).sub(userDivPool.totalClaimed);
        }
        if (dividends > 0) {
            userDivPool.totalClaimed += dividends;
            userDivPool.payoutsTo += (int256) (dividends * MAGNITUDE);
            userStorage.reservePool.totalReservePoolClaimed = userStorage.reservePool.totalReservePoolClaimed.add(dividends);
            _swapToBCP(
                caller, 
                bcpPrice,
                dividends
            );
            emit DividendPoolEvent (
                caller,
                poolReserveId,
                dividends,
                uint64(block.timestamp)
            );
        }
    }

    function claimReservePool(uint bcpPrice, bytes memory signature, uint deadLine) public whenNotPaused {
        address caller = msg.sender;
        User storage userStorage = user[caller];
        require(bcpPrice != 0, "claimReservePool: price is zero"); 
        require(deadLine > block.timestamp, "claimReservePool: dead line exceeds"); 
        require(userStorage.reservePool.isActivated, "claimTotalReservePoolDividend: not activated");
        require(userStorage.reservePool.dividend > 0, "claimTotalReservePoolDividend: dividend is zero");
        require(userStorage.reservePool.divClaimed < userStorage.reservePool.dividend, "claimTotalReservePoolDividend: claimed all dividends");
        require(userStorage.reservePool.lastClaimed.add(resPoolTimeStamp) < block.timestamp, "claimTotalReservePoolDividend: have to wait till time reached");
        bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), userStorage.userId, bcpPrice, deadLine));
        require(!isVerified[msgHash], "stake: already verifed");
        require(msgHash.isValidSignatureNow( signer,signature), "stake: incorrect signature");  
        
        isVerified[msgHash] = true;
        uint dividend = userStorage.reservePool.dividend.mul(resDividend).div(10000);
        uint months = (block.timestamp.sub(userStorage.reservePool.lastClaimed)).div(resPoolTimeStamp);
        dividend = dividend.mul(months);
        if (userStorage.reservePool.divClaimed.add(dividend) > userStorage.reservePool.dividend) {
            dividend = userStorage.reservePool.dividend.sub(userStorage.reservePool.divClaimed);
        }
        userStorage.reservePool.divClaimed = userStorage.reservePool.divClaimed.add(dividend);
        userStorage.reservePool.lastClaimed = userStorage.reservePool.lastClaimed.add(resPoolTimeStamp.mul(months));
        uint fee = dividend.mul(creatorFee).div(10000);
        dividend = dividend.sub(fee);
        _swapToBCP(caller, bcpPrice, dividend);
        _swapToBCP(owner(), bcpPrice, fee);
        emit DividendReservePoolEvent (
            caller,
            dividend,
            uint64(block.timestamp)
        );
    }

    function inCaseTokensGetStuck(address token, uint256 amount) public onlyOwner {
        require(token != address(0), "inCaseTokensGetStuck: Cannot be zero token");
        require(IBEP20(token).balanceOf(address(this)) >= amount, "inCaseTokensGetStuck: insufficient to recover");
        IBEP20(token).safeTransfer(_msgSender(),amount);
    }

    function inCaseBNBGetStuck(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "inCaseBNBGetStuck: insufficient to recover");
        payable(msg.sender).transfer(amount);
    }

    function _addDivPool(uint level, uint dividends) private {
        uint poolId = findReservePool(level);
        DividendPool storage divPool = dividendPool[poolId];
        if (poolId == 0 || dividendPool[poolId].totalShares == 0) {
            if (poolId != 0 && dividendPool[poolId].totalShares == 0) {
                divPool.divPerShare += dividends * MAGNITUDE;
            }
            return;
        }        
        divPool.divPerShare += dividends * MAGNITUDE / divPool.totalShares;
        divPool.totalDivShared += dividends;
        emit AddedDivToPoolEvent (
            poolId,
            dividends,
            uint64(block.timestamp)
        );
    }

    function activateReservePool(address caller) private {
        User storage userStorage = user[caller];
        require(!userStorage.reservePool.isActivated, "activateTotalReservePool: already activated");

        if (userStorage.reservePool.totalReservePoolClaimed < userStorage.reservePool.totalReservePool) {
            uint dividend = userStorage.reservePool.totalReservePool.sub(userStorage.reservePool.totalReservePoolClaimed);
            userStorage.reservePool.dividend = dividend;
        }
        userStorage.reservePool.lastClaimed = block.timestamp;
        userStorage.reservePool.isActivated = true;
        emit ReservePoolActivationEvent (
            caller,
            userStorage.reservePool.dividend,
            uint64(block.timestamp)
        );
    }

    function findReservePool(uint level) public pure returns (uint poolReserveId) {
        if (level >= 4 && level <= 6) {
            return level % level.sub(1);
        } 
        uint increment = 2;
        if (level >= 7) {
            for (uint i= 7; i<20;) {
                if (level >= i && level <= i.add(1)) {
                    return level % level.sub(increment);
                }
                increment++;
                i = i.add(2);
            }
        }
    }

    function findPool(uint reservePoolId) public pure returns (uint poolId) {
        if (reservePoolId == 0) {
            return 0;
        }
        if (reservePoolId == 1) {
            return 4;
        }
        uint pool = 7;
        for (uint i=2; i<=8;i++) {
            if(i == reservePoolId) {
                return pool;
            }
            pool = pool.add(2);
        }
    }

    function _sponsorShip(address caller, bool payWithBNB, bytes32 sponsorCode) private {
        address sponsor = sponsorCodeOwnership[sponsorCode];
        User storage sponsorStorage = user[sponsor];
        
        if (sponsorCode > 0) {
            require(sponsorStorage.registered, "register: sponsor not registered");
        }
        bool canSponsor = sponsorStorage.allowedSponsor > sponsorStorage.sponsors.length;
        if (canSponsor) {
            if (msg.value > 0) {
                require(payable(caller).send(msg.value), "register: BNB transfer failed!");
            }
            sponsorStorage.sponsors.push(caller);
        } else {
            _validatePayAmount(payWithBNB);
            if (payWithBNB) {
                _swapBNBForBUSD(msg.value);
            } else {
                BUSD.safeTransferFrom(caller, address(this), entryFee);
                if (msg.value > 0) {
                    require(payable(caller).send(msg.value), "register: BNB transfer failed!");
                }
            }
        }
    }

    function _swapBNBForBUSD(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        (bool success,) = address(router).call{value:amount}(
            abi.encodeWithSignature(
                "swapExactETHForTokens(uint256,address[],address,uint256)", 
                0,
                path, 
                address(this),
                block.timestamp 
            )
        );

        require(success, "_swapBNBForBUSD: failed");
    }

    function getBUSDPrice() public view returns (uint256[] memory amounts) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);
        amounts = router.getAmountsIn(
            entryFee, 
            path
        );
    }

    function _swapToBCP(address receiver, uint price, uint amount) private {
        amount = amount.mul(1 ether).div(price);
        if(amount == 0) {
            return;
        }
        require(BCP.balanceOf(address(this)) >= amount,"swapToBCP: not enough balance");
        BCP.safeTransfer(receiver,amount);
    }

    function initPools() private {
        uint256[2][8] memory _poolInfo = [
            [uint(100),uint(3)], 
            [uint(200),uint(6)], 
            [uint(500),uint(9)], 
            [uint(2000),uint(18)], 
            [uint(3000),uint(21)], 
            [uint(5000),uint(30)], 
            [uint(10000),uint(45)], 
            [uint(15000),uint(60)]
        ];

        Pool memory pool;
        uint8 poolIndex = 0;
        for (uint i=4; i<=20;) {
            pool.level = i;
            pool.stakeAmt = _poolInfo[poolIndex][0] * 1 ether;
            pool.affiliate = _poolInfo[poolIndex][1];
            pools[i] = pool;
            i = (i == 4) ? i + 3 : i + 2;
            poolIndex++;
        }
    }

    function initLevel() private {
        uint price = entryFee;
        Level memory level;

        for(uint i = 1;i<=20;i++) {
            if(i != 1) {
                price = price.mul(2);
            }
            level.levelPrice = price;
            
            if(i <= 3) {
                level.cashout = price;
            } else  {
                level.dividends = level.cashout = price.div(2);
            }
            levels.push(level);
        }
    }

    function getUserDetails(
        address userAddress
    ) 
        public
        view 
        returns(
            uint referenceId, 
            uint userId, 
            uint currentLvl, 
            uint totalCashOut, 
            uint allowedSponsor,
            bytes32 sponsorCode, 
            bool registered
        ) 
    {
        return (
            user[userAddress].referenceId, 
            user[userAddress].userId, 
            user[userAddress].currentLvl, 
            user[userAddress].totalCashOut, 
            user[userAddress].allowedSponsor,
            user[userAddress].sponsorCode, 
            user[userAddress].registered
        );
    }

    function getUserReferrals(address userAddress) public view returns (address[] memory referrals) {
        return user[userAddress].referrals;
    }

    function getUserReserveDetails(address userAddress) public view returns (UserResPool memory reservePool) {
        return user[userAddress].reservePool;
    }

    function getUserDividendDetails(address userAddress, uint poolId) public view returns (UserDivPool memory userDivPool) {
        return user[userAddress].userDividendPool[poolId];
    }

    function getUserLevelDivDetails(address userAddress, uint level) public view returns (bool isClaimed, bool isDividendAdded) {
        return (user[userAddress].isClaimed[level], user[userAddress].isDividendAdded[level]);
    }

    function isUserExistInPool(address userAddress, uint pool) public view returns (bool existInPool) {
        return user[userAddress].existInPool[pool];
    }

    function getUserSponsors(address userAddress) public view returns (address[] memory sponsors) {
        return user[userAddress].sponsors;
    }

    function sponsorCodeGenerator(address sponsor) private view returns(bytes32 _sponsorCode) {
        _sponsorCode = keccak256(abi.encodePacked(sponsor,address(this)));
    }

    function _validatePayAmount(bool payWithBNB) private {
        if (payWithBNB) {
            require(msg.value != 0, "bnb is zero");
        } else {
            require(msg.value == 0, "bnb is not zero");
        }
    }

    function levelCheckOut(address caller, uint level) private view returns (bool) {
        User storage userStorage = user[caller];
        if (userStorage.currentLvl == 1) {
            if (userStorage.currentLvl != level) {
                return true;
            }
            return false;
        } else {
            if (level != userStorage.currentLvl) {
                return true;
            }
            return false;
        }
    }
}