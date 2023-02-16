/**
 *Submitted for verification at BscScan.com on 2023-02-15
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

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
        (value == 0) || (token.allowance(address(this), spender) == 0),
        "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
        token,
        abi.encodeWithSelector(token.approve.selector, spender, value)
        );
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

abstract contract ReentrancyGuard {
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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
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

contract BNBCashPoolMlm is Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint;
    using SafeBEP20 for IBEP20;
    using SignatureChecker for bytes32;

    IBEP20 public BCP;
    IBEP20 public BUSD;
    address public signer;
    IUniswapV2Router02 public router; //0x9ac64cc6e4415144c455bd8e4837fea55603e5c3

    uint public currReferenceId = 0;
    uint public totalReferenceId = 0;
    uint public entryFee = 50 ether;
    uint public multiplier = 4;
    uint public withdrawFee = 800;
    uint public divDistribute = 30 days;
    uint public lastDivDistribution;

    uint constant REQUIRED_DOWNLNES = 3;
    uint256 constant internal MAGNITUDE = 2 ** 64;

    struct Level {
        uint levelPrice;
        uint cashout;
        uint dividends;
        uint restartPool;
        uint jackpotPool ;
        uint globalPool;
        uint villaPool;
        uint projectCreator;
        uint affiliate;
    }

    struct User {
        uint referenceId;
        uint userId;
        uint currentLvl;
        uint totalCashOut;
        address[] referrals;
        address[] sponsors;
        bytes32 sponsorCode;
        bool registered;
        mapping(uint => UserDivPool) userDividendPool;
        mapping(uint => UserLvlInfo) levelInfo;
    }

    struct UserLvlInfo {
        bool isClaimed;
        bool isDividendAdded;
        bool isRestartPoolAdded;
        bool isJackpotPoolAdded;
        bool isGlobalPoolAdded;
        bool isVillaPoolAdded;
        bool isProjectCreatorAdded;
    }
    
    struct UserDivPool {
        int256 payoutsTo;
        uint totalClaimed;
        uint poolAmount;
        bool isExist;
    }
    
    struct PoolWallet {
        address restartPool;
        address jackpotPool;
        address globalPool;
        address villaPool;
        address projectCreator;
    }
    
    struct Pool {
        uint level;
        uint globalDiv;
    }
    
    struct DividendPool {
        uint totalShares;
        uint totalDivShared;
        uint dividends;
        uint divPerShare;
    }
    
    struct CashOut {
        uint level;
        bytes signature;
        uint deadLine;
    }

    Level[] public levels;
    PoolWallet public poolWallets;

    mapping(address => User) private user;
    mapping(uint => address) public userByRefId;
    mapping(bytes32 => bool) public isVerified;
    mapping(uint => Pool) public pools;
    mapping(uint => DividendPool) public dividendPool;
    mapping(bytes32 => address) public sponsorCodeOwnership;

    event RegisteredEvent(
        address indexed upline,
        address indexed user,
        address indexed referredBy,
        uint entryFees,
        uint64 timestamp
    );
    event CashOutEvent(
        address indexed caller,
        uint indexed level,
        uint claimed,
        uint64 timestamp
    );
    event DividendPoolEvent (
        address indexed caller,
        uint indexed poolId,
        uint dividend,
        uint64 timestamp
    );
    event AddedDivToPoolEvent (
        uint indexed poolId,
        uint dividend,
        uint64 timestamp
    );

    constructor(IBEP20 bcp, IBEP20 busd, address signerAddress, PoolWallet memory poolWallet) {
        require(bcp != IBEP20(address(0)), "BNBCashPoolMlm: bcp is zero");
        require(busd != IBEP20(address(0)), "BNBCashPoolMlm: bcp is zero");
        require(signerAddress != address(0), "BNBCashPoolMlm: signerAddress is zero");
        BCP = bcp;
        BUSD = busd;
        signer = signerAddress;
        lastDivDistribution = block.timestamp;
        Level memory level;
        levels.push(level);
        poolWallets = poolWallet;
        
        router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        
        initLevel();
        initPools();

        BCP.safeApprove(
            address(router),
            type(uint).max
        );    
    }

    receive() external payable {}

    function updateBCP(IBEP20 newBCP) external onlyOwner {
        require(address(newBCP) != address(0), "updateBCP: newBCP is zero");
        BCP = newBCP;
        BCP.safeApprove(
            address(router),
            type(uint).max
        );
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

    function updateWithdrawFee(uint newWithdrawFee) external onlyOwner {
        withdrawFee = newWithdrawFee;
    }

    function updateRouter(IUniswapV2Router02 newRouter) external onlyOwner {
        router = newRouter;
    }

    function updateRestartPool(address newRestartPool) external onlyOwner {
        require(newRestartPool != address(0), "updateRestartPool: newRestartPool is zero");
        poolWallets.restartPool = newRestartPool;
    }

    function updateJackpotPool(address newJackpotPool) external onlyOwner {
        require(newJackpotPool != address(0), "updateJackpotPool: newJackpotPool is zero");
        poolWallets.jackpotPool = newJackpotPool;
    }

    function updateGlobalPool(address newGlobalPool) external onlyOwner {
        require(newGlobalPool != address(0), "updateRestartPool: newGlobalPool is zero");
        poolWallets.globalPool = newGlobalPool;
    }

    function updateVillaPool(address newVillaPool) external onlyOwner {
        require(newVillaPool != address(0), "updateVillaPool: newVillaPool is zero");
        poolWallets.villaPool = newVillaPool;
    }

    function updateProjectCreator(address newProjectCreator) external onlyOwner {
        require(newProjectCreator != address(0), "updateProjectCreator: projectCreator is zero");
        poolWallets.projectCreator = newProjectCreator;
    }

    function updateLevelAffiliate(uint level, uint newAffiliate) external onlyOwner {
        levels[level].affiliate = newAffiliate;
    }

    function updateLevelCashOut(uint level, uint newCashout) external onlyOwner {
        levels[level].cashout = newCashout;
    }

    function updateLevelDividends(uint level, uint newDividends) external onlyOwner {
        levels[level].dividends = newDividends;
    }

    function updateLevelRestartPool(uint level, uint newRestartPool) external onlyOwner {
        levels[level].restartPool = newRestartPool;
    }

    function updateLevelJackpotPool(uint level, uint newJackpotPool) external onlyOwner {
        levels[level].jackpotPool = newJackpotPool;
    }

    function updateLevelGlobalPool(uint level, uint newGlobalPool) external onlyOwner {
        levels[level].globalPool = newGlobalPool;
    }

    function updateLevelVillaPool(uint level, uint newVillaPool) external onlyOwner {
        levels[level].villaPool = newVillaPool;
    }

    function updateLevelProjectCreator(uint level, uint newProjectCreator) external onlyOwner {
        levels[level].projectCreator = newProjectCreator;
    }

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function register(bytes32 sponsorCode, bool payWithBNB) public payable whenNotPaused {
        address caller = _msgSender();
        User storage userStorage = user[caller];
        require(address(BCP) != address(0), "register: BCP is zero");
        require(address(BUSD) != address(0), "register: BUSD is zero");
        require(!userStorage.registered, "register: caller already registered");
        _pay(
            caller,
            payWithBNB
        );
        address upline;
        uint referenceId = currReferenceId;
        address sponsor = sponsorCodeOwnership[sponsorCode];
        if (currReferenceId != 0 && totalReferenceId != 0) {
            upline = userByRefId[referenceId];
            User storage uplineStorage = user[upline];
            if (uplineStorage.registered) {
                uplineStorage.referrals.push(caller);
                if (uplineStorage.referrals.length == REQUIRED_DOWNLNES) {
                    currReferenceId++;
                    uplineStorage.currentLvl = 1;
                }
            } else {
                revert("invalid current referrence id");
            }
        }
        if (currReferenceId == 0) {
            currReferenceId = 1;
        }
        if (sponsor != address(0)) {
            user[sponsor].sponsors.push(caller);
        }
        totalReferenceId++;
        userStorage.registered = true;
        userStorage.referenceId = referenceId;
        userStorage.userId = totalReferenceId;
        userByRefId[totalReferenceId] = caller;
        userStorage.sponsorCode = genSponsorCode(caller);
        sponsorCodeOwnership[userStorage.sponsorCode] = caller;
        emit RegisteredEvent(
            upline,
            caller,
            sponsor,
            entryFee,
            uint64(block.timestamp)
        );
    }

    function cashOut(CashOut[] memory params) public whenNotPaused nonReentrant {
        address caller = _msgSender();
        User storage userStorage = user[caller];
        require(userStorage.currentLvl != 0, "cashOut: register before cashout");
        require(userStorage.registered, "cashOut: register before cashout");
        require(params.length <= levels.length, "cashOut: level mismatch");
        uint[] memory amounts = new uint[](6);
        uint fees;
        _setDivPerShare();
        for(uint index = 0; index < params.length; index++) {
            CashOut memory param = params[index];
            bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), param.level, param.deadLine));
            if (!msgHash.isValidSignatureNow(signer,param.signature) ||
                param.deadLine < block.timestamp ||
                isVerified[msgHash]) {
                    if (!isVerified[msgHash]) {
                        isVerified[msgHash] = true;
                    }
                    revert("Invalid signer or deadline exceeds");
            }
            isVerified[msgHash] = true;
            if (param.level == 0 ||
                param.level > levels.length ||
                _levelCheckOut(caller, param.level)) {
                revert("Invalid level or not eligible to claim");
            }
            userStorage.currentLvl = userStorage.currentLvl.add(1);
            Level memory level = levels[param.level];
            UserLvlInfo memory userLvlInfo =  userStorage.levelInfo[param.level];
            if (!userLvlInfo.isClaimed && level.cashout != 0) {
                userLvlInfo.isClaimed = true;
                uint fee = level.cashout.mul(withdrawFee).div(10000);
                uint cashout = level.cashout.sub(fee);
                fees = fees.add(fee);
                amounts[0] = amounts[0].add(cashout);
                emit CashOutEvent(
                    caller,
                    param.level,
                    level.cashout,
                    uint64(block.timestamp)
                );
            }
            if (!userLvlInfo.isDividendAdded && level.dividends != 0) {
                userLvlInfo.isDividendAdded = true;
                UserDivPool storage userDividendPool = userStorage.userDividendPool[param.level];
                if (!userDividendPool.isExist) {
                    userDividendPool.isExist = true;
                    userDividendPool.poolAmount = pools[param.level].globalDiv;
                    userDividendPool.payoutsTo += (int256) (dividendPool[param.level].divPerShare * userDividendPool.poolAmount);
                    dividendPool[param.level].totalShares = dividendPool[param.level].totalShares.add(userDividendPool.poolAmount);
                }
                _addDivPool(
                    param.level,
                    level.dividends
                );
            }
            if (!userLvlInfo.isRestartPoolAdded && level.restartPool != 0) {
                userLvlInfo.isRestartPoolAdded = true;
                amounts[1] = amounts[1].add(level.restartPool);
            }
            if (!userLvlInfo.isJackpotPoolAdded && level.jackpotPool != 0) {
                userLvlInfo.isJackpotPoolAdded = true;
                amounts[2] = amounts[2].add(level.jackpotPool);
            }
            if (!userLvlInfo.isGlobalPoolAdded && level.globalPool != 0) {
                userLvlInfo.isGlobalPoolAdded = true;
                amounts[3] = amounts[3].add(level.globalPool);
            }
            if (!userLvlInfo.isVillaPoolAdded && level.villaPool != 0) {
                userLvlInfo.isVillaPoolAdded = true;
                amounts[4] = amounts[4].add(level.villaPool);
            }
            if (!userLvlInfo.isProjectCreatorAdded && level.projectCreator != 0) {
                userLvlInfo.isProjectCreatorAdded = true;
                amounts[5] = amounts[5].add(level.projectCreator);
            }
        }
        require(
            amounts[0] != 0 || amounts[1] != 0 ||
            amounts[2] != 0 || amounts[3] != 0 ||
            amounts[4] != 0 || amounts[5] != 0 ||
            fees != 0,
            "cashOut: cashout is zero"
        );
        userStorage.totalCashOut =  userStorage.totalCashOut.add(amounts[0]);
        _multiBUSDSender(caller, amounts);
        _transferBUSD(owner(),fees);
    }

    function claimDividendPool(uint level, bytes memory signature, uint deadLine) public whenNotPaused nonReentrant {
        address caller = msg.sender;
        User storage userStorage = user[caller];
        DividendPool storage divPool = dividendPool[level];
        UserDivPool storage userDivPool = userStorage.userDividendPool[level];        
        require(deadLine > block.timestamp, "claimDividendPool: dead line exceeds");
        require(userDivPool.isExist, "claimDividendPool: pool is not activated");
        uint256 dividends = (uint256) ((int256)(divPool.divPerShare * userDivPool.poolAmount) - userDivPool.payoutsTo) / MAGNITUDE;
        require(dividends > 0, "claimDividendPool: dividend is zero");        
        bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), level, deadLine));
        require(!isVerified[msgHash], "claimDividendPool: already verifed");
        require(msgHash.isValidSignatureNow( signer,signature), "claimDividendPool: incorrect signature");
        isVerified[msgHash] = true;
        if (userDivPool.totalClaimed.add(dividends) >= userDivPool.poolAmount.mul(multiplier)) {
            if (userDivPool.totalClaimed < userDivPool.poolAmount.mul(multiplier)) {
                dividends = (userDivPool.poolAmount.mul(multiplier)).sub(userDivPool.totalClaimed);
            } else {
                dividends = 0;
                divPool.totalShares = (divPool.totalShares >= userDivPool.poolAmount) ? divPool.totalShares.sub(userDivPool.poolAmount) : 0;
                userDivPool.isExist = false;
                return;
            }
            divPool.totalShares = (divPool.totalShares >= userDivPool.poolAmount) ? divPool.totalShares.sub(userDivPool.poolAmount) : 0;
            userDivPool.isExist = false;
        }        
        require(dividends > 0, "claimDividendPool: no available dividend to claim");
        userDivPool.totalClaimed += dividends;
        userDivPool.payoutsTo += (int256) (dividends * MAGNITUDE);
        _transferBUSD(
            caller,
            dividends
        );
        emit DividendPoolEvent (
            caller,
            level,
            dividends,
            uint64(block.timestamp)
        );
    }

    function setGlobalPoolDiv() public nonReentrant {
        require(lastDivDistribution.add(divDistribute) < block.timestamp, "setGlobalPoolDiv: distribution not yet started");
        _setDivPerShare();
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
        DividendPool storage divPool = dividendPool[level];
        divPool.dividends += dividends;
        divPool.totalDivShared += dividends;
        emit AddedDivToPoolEvent (
            level,
            dividends,
            uint64(block.timestamp)
        );
    }

    function _setDivPerShare() private {
        if (lastDivDistribution.add(divDistribute) > block.timestamp) {
            return;
        }
        for (uint level = 0; level<=levels.length; level++) {
            DividendPool storage divPool = dividendPool[level.add(1)];
            if (divPool.dividends == 0) {
                continue;
            }
            uint dividend = divPool.dividends;
            divPool.dividends = 0;
            divPool.divPerShare += dividend * MAGNITUDE / (divPool.totalShares);
        }
        lastDivDistribution = block.timestamp;
    }

    function _pay(address caller, bool payWithBNB) private {
        _validatePayAmount(payWithBNB);
        if (payWithBNB) {
            _swapBNBForBUSD(msg.value);
        } else {
            uint[] memory amountsIn = getBUSDPriceForBCP();
            BCP.safeTransferFrom(caller, address(this), amountsIn[0]);
            _swapBCPForBUSD(amountsIn[0]);
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

    function _swapBCPForBUSD(uint256 amountIn) private {
        address[] memory path = new address[](3);
        path[0] = address(BCP);
        path[1] = router.WETH();
        path[2] = address(BUSD);
        (bool success,) = address(router).call{value:0}(
            abi.encodeWithSignature(
                "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
                amountIn,
                0,
                path,
                address(this),
                block.timestamp
            )
        );
        require(success, "_swapBNBForBUSD: failed");
    }

    function _multiBUSDSender(address caller, uint[] memory amounts) private {
        address[6] memory addresses = [
            caller,
            poolWallets.restartPool,
            poolWallets.jackpotPool,
            poolWallets.globalPool,
            poolWallets.villaPool,
            poolWallets.projectCreator
        ];
        for (uint i=0; i<addresses.length; i++) {
            _transferBUSD(addresses[i], amounts[i]);
        }
    }

    function _transferBUSD(address receiver, uint amount) private {
        if(amount == 0) {
            return;
        }
        require(BUSD.balanceOf(address(this)) >= amount,"transferBUSD: not enough balance");
        BUSD.safeTransfer(receiver,amount);
    }

    function initPools() private {
        pools[5].globalDiv = pools[6].globalDiv = pools[7].globalDiv = 50 ether;
        pools[8].globalDiv = pools[9].globalDiv = 100 ether;
        pools[10].globalDiv = pools[11].globalDiv = pools[12].globalDiv = 250 ether;
        pools[13].globalDiv = pools[14].globalDiv = 500 ether;
        pools[15].globalDiv = pools[16].globalDiv = pools[17].globalDiv = 1000 ether;
        pools[18].globalDiv = pools[19].globalDiv = 5000 ether;
        pools[20].globalDiv = 10000 ether;
    }

    function initLevel() private {
        levels.push(Level(50 ether, 50 ether, 0, 0, 0, 0, 0, 25 ether, 1)); // 1
        levels.push(Level(75 ether, 56.25 ether, 0, 0, 0, 0, 0, 56.25 ether, 1)); //2
        levels.push(Level(112.5 ether, 84.37 ether, 0, 0, 0, 0, 0, 56.25 ether, 2)); // 3
        levels.push(Level(168.75 ether, 125.5625 ether, 0, 0, 0, 0, 0, 125.5625 ether, 2)); //4
        levels.push(Level(253.125 ether, 240 ether, 100 ether, 19.8 ether, 9.95 ether, 0, 0, 9.95 ether, 2));// 5
        levels.push(Level(379.68 ether, 284.75 ether, 150 ether, 44.9 ether, 44.9 ether, 0, 0, 44.9 ether, 2)); // 6
        levels.push(Level(569.53 ether, 427.14 ether, 150 ether, 100 ether, 59.04 ether, 59.04 ether, 0, 59.04 ether, 2)); // 7
        levels.push(Level(854.29 ether,640.71 ether, 300 ether, 100 ether, 70.35 ether, 100 ether, 0, 70.35 ether,3)); // 8
        levels.push(Level(1281.44 ether,961.08 ether, 400 ether, 150 ether, 130.54 ether, 150 ether, 0, 130.54 ether, 3)); // 9
        levels.push(Level(1922.16 ether,1441.62 ether, 600 ether, 150 ether, 180.54 ether, 150 ether, 180.54 ether, 180.54 ether, 3)); // 10
        levels.push(Level(2883.25 ether,2162.43 ether, 800 ether, 300 ether, 187.47 ether, 500 ether, 187.47 ether, 187.47 ether, 3)); // 11
        levels.push(Level(4324.87 ether,3243.65 ether, 1500 ether, 600 ether, 147.88 ether, 700 ether, 147.88 ether, 147.88 ether, 6)); // 12
        levels.push(Level(6487.31 ether,4865.48 ether, 2000 ether, 700 ether, 388.49 ether, 1000 ether, 388.49 ether, 388.49 ether, 8)); // 13
        levels.push(Level(9730.97 ether,7298.23 ether, 4000 ether, 1000 ether, 266.07 ether, 1500 ether, 266.07 ether, 266.07 ether, 10)); // 14
        levels.push(Level(14596.46 ether,10947.34 ether, 6000 ether, 1500 ether, 482.44 ether, 2000 ether, 482.44 ether, 482.44 ether, 15)); // 15
        levels.push(Level(21894.69 ether,16421.02 ether, 8000 ether, 2000 ether, 1140.34 ether, 3000 ether, 1140.34 ether, 1140.34 ether, 20)); // 16
        levels.push(Level(32842.04 ether,24631.53 ether, 10000 ether, 4000 ether, 1877.17 ether, 5000 ether, 1877.17 ether, 1877.17 ether, 25)); // 17
        levels.push(Level(49263.06 ether,36947.29 ether, 10000 ether, 6000 ether, 3649.09 ether, 10000 ether, 3649.09 ether, 3649.09 ether, 35)); // 18
        levels.push(Level(73894.59 ether,55420.94 ether, 15000 ether, 10000 ether, 3473.64 ether, 15000 ether, 8473.64 ether, 3473.64 ether, 50)); // 19
        levels.push(Level(110841.89 ether,83131.41 ether, 20000 ether, 10000 ether, 11043.80 ether, 20000 ether, 21043.80 ether, 11043.80 ether, 100)); // 20
    }

    function _validatePayAmount(bool payWithBNB) private {
        if (payWithBNB) {
            require(msg.value != 0, "bnb is zero");
        } else {
            require(msg.value == 0, "bnb is not zero");
        }
    }

    function getBUSDPriceForBCP() public view returns (uint256[] memory amounts) {
        address[] memory path = new address[](3);
        path[0] = address(BCP);
        path[1] = router.WETH();
        path[2] = address(BUSD);
        amounts = router.getAmountsIn(
            entryFee,
            path
        );
    }

    function getBUSDPriceForBNB() public view returns (uint256[] memory amounts) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);
        amounts = router.getAmountsIn(
            entryFee,
            path
        );
    }

    function genSponsorCode(address sponsor) public view returns(bytes32 sponsorCode) {
        sponsorCode = keccak256(abi.encodePacked(sponsor,address(this)));
    }

    function getPoolDividend(address caller, uint level) public view returns (uint) {
        User storage userStorage = user[caller];
        DividendPool storage divPool = dividendPool[level];
        UserDivPool storage userDivPool = userStorage.userDividendPool[level];
        if(!userDivPool.isExist) {
            return 0;
        }
        uint256 dividends = (uint256) ((int256)(divPool.divPerShare * userDivPool.poolAmount) - userDivPool.payoutsTo) / MAGNITUDE;
        if (userDivPool.totalClaimed.add(dividends) > userDivPool.poolAmount.mul(multiplier)) {
            if (userDivPool.totalClaimed < userDivPool.poolAmount.mul(multiplier)) {
                dividends = (userDivPool.poolAmount.mul(multiplier)).sub(userDivPool.totalClaimed);
            } else {
                dividends = 0;
            }
        }
        return dividends;
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
            bytes32 sponsorCode,
            bool registered
        )
    {
        return (
            user[userAddress].referenceId,
            user[userAddress].userId,
            user[userAddress].currentLvl,
            user[userAddress].totalCashOut,
            user[userAddress].sponsorCode,
            user[userAddress].registered
        );
    }

    function getUserReferrals(
        address userAddress
    )
        public
        view
        returns(
            address[] memory referrals,
            address[] memory sponsors
        )
    {
        return (
            user[userAddress].referrals,
            user[userAddress].sponsors
        );
    }

    function getUserLevelInfo(
        address userAddress,
        uint level
    )
        public
        view
        returns (UserLvlInfo memory userLevelInfo)
    {
        return user[userAddress].levelInfo[level];
    }

    function getUserDivPoolInfo(
        address userAddress,
        uint level
    )
        public
        view
        returns (UserDivPool memory userPool)
    {
        return user[userAddress].userDividendPool[level];
    }

    function _levelCheckOut(address caller, uint level) private view returns (bool) {
        User storage userStorage = user[caller];
        if (level != userStorage.currentLvl || userStorage.sponsors.length < levels[level].affiliate) {
            return true;
        }
        return false;
    }
}