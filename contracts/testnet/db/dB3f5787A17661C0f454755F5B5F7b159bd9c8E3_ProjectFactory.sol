// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
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
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

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
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
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
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface IUserLevel {
    struct BonusInfo {
        uint[] level;
        uint[] bonus;
    }

    struct UserInfo {
        uint level;
        uint exp;
    }

    function getUserLevel(address _user) external view returns(uint);
    function getUserExp(address _user) external view returns(uint);
    function getUserInfo(address _user) external view returns(UserInfo memory);
    function nonces(address _user) external view returns (uint256);
    function getBonus(address _user, address _contract) external view returns(uint, uint);
    function updateUserExp(uint _exp, uint _expiredTime, address[] memory lStaking, uint[] memory pIds, bytes[] memory signature) external;
    function listValidator() external view returns(address[] memory);
    function estimateExpNeed(uint _level) external view returns(uint);
    function estimateLevel(uint _exp) external view returns(uint);
    function configBaseLevel(uint _baseLevel) external;
    function configBonus(address _contractAddress, uint[] memory _bonus, uint[] memory _level) external;
    function addValidator(address[] memory _validator) external;
    function removeValidator(address[] memory _validator) external;
    function setNftRouterAddress(address _nftRouter) external;
    function setFarmingAddress(address _farming) external;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IUserLevel.sol";

interface Decimal {
    function decimals() external view returns(uint8);
}

contract IdoProjectV2 is ReentrancyGuard, Initializable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using ECDSA for bytes;


    struct Cliff {
        uint timeStamp;
        uint percentage;
    }

    struct ClaimInfo {
        uint8 lastClaim;
        uint totalToken;
        uint totalTokenClaimed;
        bool finish;
    }

    //constant
    uint public constant ONE_HUNDRED_PERCENT = 10000;

    // address verify
    address public admin;

    //setting
    uint public projectId;
    uint public registerStartTime;
    uint public calculationTime;
    uint public fcfsStartTime;
    uint public rate; // multiple with decimals token
    uint public totalSlot;
    uint public totalWhiteList;

    //vesting
    Cliff[] public vestingInfo;

    //info
    IERC20 public currency;
    IERC20 public tokenSale;
    uint public tokenSaleDecimal;

    // storage
    mapping(address => ClaimInfo) public claimInfo; // user address => ClaimInfo data
    mapping(address => uint) public commit;  // user address => committed amount

    //list user
    EnumerableSet.AddressSet users;
    EnumerableSet.AddressSet winners;
    EnumerableSet.AddressSet whiteList;
    EnumerableSet.AddressSet whiteListSubmitted;
    EnumerableSet.AddressSet fcfsSubmitted;
    // allocation
    uint public maxAllocation;
    uint public fcfsAllocation;

    // total tokens for fcfs
    uint public fcfsSupply;
    // totol tokens fcfs bought
    uint public fcfsBought;
    mapping(address => uint) public userAllocation;

    //control
    bool public poolEnd = false;
    bool public settingProject = false;

    //operator
    address public operator;

    //user level
    address public userLevel;

    //total token currency receiver
    uint public totalReceive;
    uint totalWithdraw;



    //===================EVENTS===================//
    modifier onlyOperator() {
        require(msg.sender == operator, "!Operator");
        _;
    }

    modifier onPoolSale() {
        require(block.timestamp >= registerStartTime && block.timestamp <= calculationTime, "!Time pool");
        require(!users.contains(msg.sender), "User has registered");
        _;
    }

    modifier afterSale() {
        require(block.timestamp > calculationTime, "!After pool");
        require(!poolEnd, "!pool End");
        _;
    }

    modifier checkSigner(bytes memory _signature, uint256 _slot, uint _userLevel) {
        require(_slot > 0, "_slot minimum is 1");
        bytes32 _hash = keccak256(abi.encodePacked(projectId, msg.sender, address(this), _slot, _userLevel)).toEthSignedMessageHash();
        require(_hash.recover(_signature) == admin, "!verify");
        _;
    }

    modifier isWithdrawable() {
        bool check = block.timestamp > calculationTime && poolEnd && !winners.contains(msg.sender);
        require(check, "!check");
        _;
    }

    modifier isClaimable() {
        bool check = block.timestamp > calculationTime && poolEnd && (winners.contains(msg.sender) || whiteListSubmitted.contains(msg.sender) || fcfsSubmitted.contains(msg.sender));
        require(check, "!check");
        _;
    }

    modifier isWithdrawableAdmin() {
        bool check = block.timestamp > calculationTime;
        require(check, "!check");
        _;
    }

    modifier isFCFS() {
        require(poolEnd, "All pool did not finish yet");
        require(block.timestamp < vestingInfo[0].timeStamp, "FCFS has finished");
        require(block.timestamp >= fcfsStartTime, "FCFS did not start");
        _;
    }

    //===================EVENTS===================
    event Setting(
        uint indexed projectId,
        bool indexed update,
        uint _registerStartTime,
        uint _calculationTime,
        uint _rate,
        address _currency,
        address _tokenSale,
        address _admin,
        uint _allocation,
        uint[]  timestamps,
        uint[]  percentages,
        uint _totalSlot,
        uint _whiteList
    );
    event ProjectCreated(uint indexed projectId, address indexed contractAddress);
    event Register(address indexed user, uint indexed projectId, uint indexed allocation, uint slot, uint userLevel);
    event Withdraw(address indexed user, uint indexed amount, uint indexed projectId);
    event Claim(address indexed user,uint indexed projectId, uint indexed amount);
    event WinnerMember(address indexed user, uint indexed projectId, uint indexed pool, uint amount);
    event PoolEnd(bool indexed _slot, uint indexed projectId);
    event CreateRandom(uint indexed number, uint indexed projectId);


    // initialize
    function initialize(uint _projectId, address _operator, address _userLevel) public initializer returns (bool) {
        require(_operator != address(0), "!zero");
        projectId = _projectId;
        operator = _operator;
        userLevel = _userLevel;
        emit ProjectCreated(projectId, address(this));
        return true;
    }


    //====================== Internal =====================//
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    //=================== External ===================== //
    function registerProject(bytes memory _signature, uint256 _slot, uint _userLevel, uint _pool) external onPoolSale checkSigner(_signature, _slot, _userLevel) {
        require(_pool == 1 || _pool == 2, "_pool not support");
        // white list
        if(_pool == 1) {
            require(whiteList.contains(msg.sender), "User not in white list");
            currency.safeTransferFrom(msg.sender, address(this), maxAllocation);
            _execute(msg.sender, maxAllocation, _pool);
        }
        // other
        if( _pool == 2) {
            require(!users.contains(msg.sender), "User already register");
            currency.safeTransferFrom(msg.sender, address(this), maxAllocation * _slot);
            commit[msg.sender] = maxAllocation * _slot;
            users.add(msg.sender);
        }
        emit Register(msg.sender, projectId, maxAllocation * _slot, _slot, _userLevel);
    }

    function withdraw() external isWithdrawable nonReentrant {
        uint _amount = 0;
        _amount = commit[msg.sender];
        commit[msg.sender] = 0;
        currency.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount, projectId);
    }

    function claim() external isClaimable nonReentrant {
        uint _amount = 0;
        ClaimInfo storage _user = claimInfo[msg.sender];
        (,bool _finish,bool _claimable,uint _totalClaim,uint8 _lastClaim) = getClaimInfo(_user.totalToken, _user.lastClaim);
        require(_claimable, "!Claimable");
        _amount = _totalClaim;
        if (_finish) {
            _user.finish = _finish;
            _amount = _user.totalToken - _user.totalTokenClaimed;
        }
        _user.lastClaim = _lastClaim;
        _user.totalTokenClaimed += _amount;
        require(_user.totalTokenClaimed <= _user.totalToken, "Overflow claimable");
        tokenSale.safeTransfer(msg.sender, _amount);
        emit Claim(msg.sender, projectId, _amount);
    }

    function withdrawAdmin() external onlyOperator isWithdrawableAdmin() nonReentrant {
        uint currentWithdraw = totalReceive - totalWithdraw;
        require(currentWithdraw > 0, "No token to withdraw");
        currency.safeTransfer(msg.sender, currentWithdraw);
        totalWithdraw += currentWithdraw;
        emit Withdraw(msg.sender, currentWithdraw, projectId);
    }

    function setting(
        uint[] memory _dataUint,
        IERC20[] memory _dataErc20,
        uint[] memory _timestamps,
        uint[] memory _percentages,
        address _admin,
        bool _update
    ) external onlyOperator {
        require(!settingProject || _update, "Project first time setting");
        require(_dataUint.length == 7, "Not enough");
        require(_dataUint[0] > block.timestamp, "_registerStartTime in pass");
        require(_dataUint[0] < _dataUint[1], "_registerStartTime < _calculationTime");
        require(_dataUint[1] < _dataUint[6], "_calculationTime > _fcfsTime");
        require(_dataUint[2] > 0, "Rate can not zero");
        require(_dataUint[3] > 0, "allocation can not zero");

        if(_update) {
            require(block.timestamp < registerStartTime, "Can not update after start");
        }

        require(address(_dataErc20[0]) != address(0), "!zero address");
        require(address(_dataErc20[1]) != address(0), "!zero address");
        require(address(_admin) != address(0), "!zero address");

        rate = _dataUint[2];
        maxAllocation = _dataUint[3];

        if(!_update) {
            registerStartTime = _dataUint[0];
            calculationTime = _dataUint[1];
            fcfsStartTime = _dataUint[6];
        }

        currency = _dataErc20[0];
        tokenSale = _dataErc20[1];
        tokenSaleDecimal = Decimal(address(tokenSale)).decimals();
        admin = _admin;
        totalSlot = _dataUint[4]; // total slot
        totalWhiteList = _dataUint[5]; // total allow list
        _setCliffInfo(_timestamps, _percentages, _update);
        settingProject = true;
        emit Setting(projectId, _update, registerStartTime, calculationTime, rate, address(currency), address(tokenSale), admin, maxAllocation, _timestamps, _percentages, totalSlot, totalWhiteList);
    }

    function setPoolEnd() external onlyOperator {
        require(block.timestamp > calculationTime && !poolEnd, "Before calculation time");
        poolEnd = true;
        fcfsSupply = (totalSlot - winners.length() + totalWhiteList - whiteListSubmitted.length()) * maxAllocation;
        emit PoolEnd(poolEnd, projectId);
    }

    function addWhiteList(address[] memory _users) external onlyOperator {
        require(_users.length > 0, "_users empty");
        require(_users.length + whiteList.length() <= totalWhiteList, "white list full");
        require( block.timestamp < registerStartTime, "Must be added white list before start");
        for(uint i = 0; i < _users.length; i++) {
            whiteList.add(_users[i]);
        }
    }

    function submitWinners(address[] memory _users) external onlyOperator {
        require(block.timestamp > calculationTime, "Before calculation time");
        require(!poolEnd, "!poolEnd");
        require(winners.length() + _users.length  <= totalSlot, "Slot over flow");
        for(uint i = 0; i < _users.length; i++ ){
            address _user = _users[i];
            require(users.contains(_user), "User not register");
            uint _allocation = commit[_user];
            _execute(_user, _allocation, 2);
        }
        if(winners.length() == totalSlot) {
            poolEnd = true;
            fcfsSupply = (totalSlot - winners.length() + totalWhiteList - whiteListSubmitted.length()) * maxAllocation;
            emit PoolEnd(poolEnd, projectId);
        }
    }

    function setOperator(address _newOperator) external onlyOperator {
        require(_newOperator != address(0), "!zero");
        operator = _newOperator;
    }

    function removeWhiteList(address _user) external onlyOperator {
        require(block.timestamp < registerStartTime, "Must be added white list before start");
        whiteList.remove(_user);
    }

    // withdraw when transfer token failed
    function emergencyWithdraw(address _token, address _receiver) external onlyOperator {
        require(_receiver != address(0) && _token != address(0), "zero address");
        require(block.timestamp < vestingInfo[0].timeStamp , "Can not withdraw after user vesting");
        IERC20 _erc20 = IERC20(_token);
        _erc20.transfer(_receiver, _erc20.balanceOf(address(this)));
    }

    function settingFCFS(uint _value, uint _start) external onlyOperator {
        require(_value > 0, "!zero");
        require(_start > calculationTime, "fcfs start time must be greater than calculation time");
        fcfsAllocation = _value;
        fcfsStartTime = _start;
    }

    function buyFCFS(uint _amount) external isFCFS {
        uint _allocation = fcfsAllocation > 0 ? fcfsAllocation : maxAllocation;
        userAllocation[msg.sender] += _amount;
        require(userAllocation[msg.sender] <= _allocation, "amount > allocation");
        currency.safeTransferFrom(msg.sender, address(this), _amount);

        // token bought
        fcfsBought += _amount;
        require(fcfsBought <= fcfsSupply, "Not enough token for sale");
        _execute(msg.sender, _amount, 3);
    }


    //=================== internal ======================//
    function _execute(address _user, uint _allocation, uint _pool) internal {
        // set claim info
        ClaimInfo storage _data = claimInfo[_user];
        _data.totalToken += _allocation * 10 ** tokenSaleDecimal / rate;

        // change state
        totalReceive += _allocation;
        commit[_user] = 0;

        bool check;
        // add to winner
        if(_pool == 1) {
            check = whiteListSubmitted.add(_user);
        } else if(_pool == 2){
            check = winners.add(_user);
        } else if(_pool == 3) {
            fcfsSubmitted.add(_user);
            check = true;
        }
        require(check, "User already added");
        emit WinnerMember(_user, projectId, _pool, _allocation);
    }

    function _setCliffInfo(uint[] memory _timestamps, uint[] memory _percentages, bool _deleted) internal onlyOperator {
        require(_timestamps.length == _percentages.length, "length must be equal");
        uint256 sum;
        if(_deleted) {
            delete vestingInfo;
        }
        for (uint256 i = 0; i < _timestamps.length; i ++) {
            require(_percentages[i] <= ONE_HUNDRED_PERCENT, "percentage over 100 %");
            Cliff memory _cliffInfo;
            _cliffInfo.percentage = _percentages[i];
            _cliffInfo.timeStamp = _timestamps[i];
            vestingInfo.push(_cliffInfo);
            sum += _percentages[i];
        }
        require(sum == ONE_HUNDRED_PERCENT, "total percentage is not 100%");
    }

    //=============== Views ==================//
    function getClaimInfo(uint256 _totalToken, uint8 _claimTimes) public view returns (uint amountClaim, bool finish, bool claimable, uint totalClaim, uint8 lastCliff) {
        lastCliff = _claimTimes;
        uint totalPercentage = 0;
        finish = false;
        amountClaim = 0;
        totalClaim = 0;
        for (uint i = _claimTimes; i < vestingInfo.length; i++) {
            if (vestingInfo[i].timeStamp <= block.timestamp) {
                totalPercentage += vestingInfo[i].percentage;
                lastCliff += 1;
            }
        }
        amountClaim = vestingInfo[_claimTimes].percentage * _totalToken / ONE_HUNDRED_PERCENT;
        totalClaim = _totalToken * totalPercentage / ONE_HUNDRED_PERCENT;
        claimable = totalPercentage > 0;
        if (lastCliff == vestingInfo.length) {
            finish = true;
        }
    }

    function getCliffInfo(uint256 _index) public view returns (uint256 _percentage, uint256 _timestamp) {
        if (_index < vestingInfo.length) {
            Cliff memory _cliffInfo = vestingInfo[_index];
            _percentage = _cliffInfo.percentage;
            _timestamp = _cliffInfo.timeStamp;
        }
    }


    function getUsers(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = users.length();
        uint _to = _min((_page + 1) * _limit, users.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = users.at(_from);
            ++_from;
        }
        return (_result, _length);
    }


    function getWinners(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = winners.length();
        uint _to = _min((_page + 1) * _limit, winners.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = winners.at(_from);
            ++_from;
        }
        return (_result, _length);
    }

    function getWinnersWhitelist(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = whiteListSubmitted.length();
        uint _to = _min((_page + 1) * _limit, whiteListSubmitted.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = whiteListSubmitted.at(_from);
            ++_from;
        }
        return (_result, _length);
    }

    function getFCFSUser(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = fcfsSubmitted.length();
        uint _to = _min((_page + 1) * _limit, fcfsSubmitted.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = fcfsSubmitted.at(_from);
            ++_from;
        }
        return (_result, _length);
    }

    function checkUserInPool(address _user) external view returns (bool isRegistered, bool isWinner, bool isWhiteList, bool isWhiteListSubmitted) {
        return (users.contains(_user), winners.contains(_user), whiteList.contains(_user), whiteListSubmitted.contains(_user));
    }

    function fcfsStatus(address _user) external view returns(uint _availableAllocation, bool _status, uint _availableFCFS){
        uint _allocation = fcfsAllocation > 0 ? fcfsAllocation : maxAllocation;
        _availableAllocation = _allocation - userAllocation[_user];
        _status = fcfsSubmitted.contains(_user);
        _availableFCFS = fcfsSupply - fcfsBought;
    }

    function getProgress() external view returns (uint _numerator, uint _denominator) {
        _numerator = 0;
        _denominator = 1;
        if (rate > 0) {
            _numerator = (winners.length() + whiteListSubmitted.length())* maxAllocation / rate ;
            _denominator = (totalSlot + totalWhiteList)* maxAllocation / rate; //total token receive
        }
    }

    function verifySignature(bytes memory _signature, address _sampleAddress, uint _slot, uint _userLevel) external view returns (bool) {
        bytes32 _hash = keccak256(abi.encodePacked(projectId, _sampleAddress, address(this), _slot, _userLevel)).toEthSignedMessageHash();
        return _hash.recover(_signature) == admin;
    }

    function estimateTransfer() external view returns(uint) {
        return totalReceive * 10 ** Decimal(address(tokenSale)).decimals() / rate;
    }

    function totalCliff() external view returns(uint) {
        return vestingInfo.length;
    }

    function isWhiteList(address _user) external view returns(bool) {
        return whiteList.contains(_user);
    }

    function getWhiteList() external view returns(address[] memory) {
        return whiteList.values();
    }

    // ====================== TESTING ======================== //
    function changeTime(uint _registerTime, uint _calculationTime) external onlyOperator {
        require( _registerTime > block.timestamp &&  _calculationTime > _registerTime, "Time setting not in correct");
        registerStartTime = _registerTime;
        calculationTime = _calculationTime;
    }

    function changeCalculationTime(uint _calculationTime) external onlyOperator {
        require(_calculationTime > registerStartTime, "Time setting not in correct");
        calculationTime = _calculationTime;
    }

    function updateVestingInfo(uint[] memory timestamps, uint[] memory percentages) external onlyOperator {
        require(block.timestamp > calculationTime && block.timestamp < vestingInfo[0].timeStamp, "Invalid time");
        delete vestingInfo;
        _setCliffInfo(timestamps, percentages, true);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import  "./IdoProjectV2.sol";

contract ProjectFactory {

    function createProject(uint _projectId, address _operator, address _userLevel) external returns(address) {
        bytes memory bytecode = type(IdoProjectV2).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_projectId, _operator));
        address _projectAddress = Create2.deploy(0, salt, bytecode);
        bool check = IdoProjectV2(_projectAddress).initialize(_projectId, _operator, _userLevel);
        require(check, "deploy failed");
        return _projectAddress;
    }
}