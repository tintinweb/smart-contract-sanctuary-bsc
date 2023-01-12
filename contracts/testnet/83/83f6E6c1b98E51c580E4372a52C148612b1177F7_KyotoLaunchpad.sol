// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProofUpgradeable {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

contract KyotoLaunchpad is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    uint256 public constant PERCENT_DENOMINATOR = 10000;

    struct IDO {
        address idoOwner; // Address of the IDO owner
        uint256 targetAmount; // Funds targeted to be raised for the project
        uint256 minimumInvestment; // Minimum investment amount for the project
        address idoToken; // Address of the IDO token
        uint256 tokensForDistribution; // Number of tokens to be distributed
        uint256 tokenPrice; // Token price in payment token (Decimals same as payment token)
        uint256 winnersOutTimestamp; // Timestamp at which winners are announced
        uint256 investmentStartTimestamp; // Timestamp at which the IDO is open
        uint256 idoCloseTimestamp; // Timestamp at which the IDO is closed
        bool cancelled; // Boolean indicating if investors have been rewarded
    }

    struct IDOInvestment {
        uint256 totalInvestment; // Total investment in payment token
        uint256 totalIDOTokensClaimed; // Total number of IDO tokens claimed
        uint256 totalInvestors; // Total number of investors
        bool collected; // Boolean indicating if the investment raised in IDO collected
    }

    struct Investor {
        uint256 investment; // Amount of payment tokens invested by the investor
        bool claimed; // Boolean indicating if user has claimed IDO tokens
        bool refunded; // Boolean indicating if user is refunded
    }

    address public owner; // Owner of the Smart Contract
    address public potentialOwner; // Potential owner's address

    uint256 public feePercentage; // Percentage of Funds raised to be paid as fee
    uint256 public ETHFromFailedTransfers; // ETH left in the contract from failed transfers

    mapping(string => IDO) private _idos; // IDO ID => IDO{}
     
    mapping(string => bytes32) private _idoMerkleRoots; // IDO ID => Its Merkle Root

    mapping(string => IDOInvestment) private _idoInvestments; // IDO ID => IDOInvestment{}

    mapping(string => mapping(address => Investor)) private _idoInvestors; // IDO ID => userAddress => Investor{}

    /* Events */
    event OwnerChanged(address newOwner);
    event NominateOwner(address potentialOwner);
    event SetFeePercentage(uint256 feePercentage);
    event SetMerkleRoot(string indexed idoID, bytes32 merkleRoot);
    event IDOAdded(string idoID, address idoOwner, address idoToken);
    event IDOCancelled(string idoID);
    event IDOInvestementCollected(string idoID);
    event IDOInvested(
        string idoID,
        address indexed investor,
        uint256 investment
    );
    event IDOInvestmentClaimed(
        string idoID,
        address indexed investor,
        uint256 tokenAmount
    );
    event IDOInvestmentRefunded(
        string idoID,
        address indexed investor,
        uint256 refundAmount
    );
    event TransferOfETHFailed(address indexed receiver, uint256 indexed amount);

    /* Modifiers */
    modifier onlyOwner() {
        require(owner == msg.sender, "KyotoLaunchpad: Only owner allowed");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {}

    function initialize() public initializer {
        owner = msg.sender;
    }

    /* Owner Functions */

    /**
     * @notice This function is used to add a potential owner of the contract
     * @dev Only the owner can call this function
     * @param _potentialOwner Address of the potential owner
     */
    function addPotentialOwner(address _potentialOwner) external onlyOwner {
        require(
            _potentialOwner != address(0),
            "KyotoLaunchpad: potential owner zero"
        );
        require(
            _potentialOwner != owner,
            "KyotoLaunchpad: potential owner same as owner"
        );
        potentialOwner = _potentialOwner;
        emit NominateOwner(_potentialOwner);
    }

    /**
     * @notice This function is used to accept ownership of the contract
     */
    function acceptOwnership() external {
        require(
            msg.sender == potentialOwner,
            "KyotoLaunchpad: only potential owner"
        );
        owner = potentialOwner;
        delete potentialOwner;
        emit OwnerChanged(owner);
    }

    /**
     * @notice This method is used to set Merkle Root of an IDO
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     * @param merkleRoot Merkle Root of the IDO
     */
    function addMerkleRoot(string calldata idoID, bytes32 merkleRoot) 
        external 
        onlyOwner{
        require(
            _idos[idoID].idoToken != address(0),
            "KyotoLaunchpad: project does not exist"
        );
        require(
            _idos[idoID].winnersOutTimestamp <= block.timestamp,
            "KyotoLaunchPad: cannot update before whitelisting closes"
        );
        require(
            _idoMerkleRoots[idoID] == bytes32(0),
            "KyotoLaunchPad: merkle root already added"
        );
        _idoMerkleRoots[idoID] = merkleRoot;
        emit SetMerkleRoot(idoID, merkleRoot);
    }

    /**
     * @notice This method is used to set commission percentage for the launchpad
     * @param _feePercentage Percentage from raised funds to be set as fee
     */
    function setFee(uint256 _feePercentage) external onlyOwner {
        require(
            _feePercentage <= 10000,
            "KyotoLaunchpad: fee Percentage should be less than 10000"
        );
        feePercentage = _feePercentage;
        emit SetFeePercentage(_feePercentage);
    }

    /* Helper Functions */
    /**
     * @dev This helper method is used to validate the user whether the address is a whitelisted address or not
     * @param merkleRoot Merkle Root of the IDO
     * @param merkleProof Merkle Proof of the user for that IDO
     */
    function _isWhitelisted(bytes32 merkleRoot, bytes32[] calldata merkleProof)
        private
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProofUpgradeable.verify(merkleProof, merkleRoot, leaf);
    }

    /**
     * @notice Helper function to transfer BNB
     * @param receiver Address of the receiver
     * @param amount BNB to transfer
     */

    function transferBNB(
        address receiver,
        uint256 amount
    ) internal {
        require(amount != 0, "KyotoLaunchpad : amount cannot be zero");
        (bool success, ) = payable(receiver).call{value: amount}("");
        if (!success) {
            ETHFromFailedTransfers += amount;
            emit TransferOfETHFailed(receiver, amount);
        }    
    }

    /**
     * @notice Helper function to calculate IDO token amount for payment
     * @param amount Amount of payment tokens
     * @param idoToken Address of the IDO token
     * @param tokenPrice Price for IDO token
     */

    function calculateIDOTokens(
        address idoToken,
        uint256 tokenPrice,
        uint256 amount
    ) public view returns (uint256 idoTokenCount) {
        uint256 idoTokenDecimals = uint256(
            IERC20MetadataUpgradeable(idoToken).decimals()
        );

        idoTokenCount = (amount * 10**idoTokenDecimals) / tokenPrice;
    }

    /* IDO */
    /**
     * @notice This method is used to check if an IDO exist
     * @param idoID ID of the IDO
     */
    function idoExist(string calldata idoID) public view returns (bool) {
        return _idos[idoID].idoToken != address(0) ? true : false;
    }

    /**
     * @notice This method is used to get IDO details
     * @param idoID ID of the IDO
     */
    function getIDO(string calldata idoID) external view returns (IDO memory) {
        require(idoExist(idoID), "KyotoLaunchpad: IDO doesn't exist");
        return _idos[idoID];
    }

    /**
     * @notice This method is used to get IDO Investment details
     * @param idoID ID of the IDO
     */
    function getIDOInvestment(string calldata idoID)
        external
        view
        returns (IDOInvestment memory)
    {
        require(idoExist(idoID), "KyotoLaunchpad: IDO doesn't exist");
        return _idoInvestments[idoID];
    }

    /**
     * @notice This method is used to get IDO Investment details of an investor
     * @param idoID ID of the IDO
     * @param investor Address of the investor
     */
    function getInvestor(string calldata idoID, address investor)
        external
        view
        returns (Investor memory)
    {
        require(idoExist(idoID), "KyotoLaunchpad: IDO doesn't exist");
        return _idoInvestors[idoID][investor];
    }

    /**
     * @notice This method is used to add a new IDO project
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO to be added
     * @param idoOwner Address of the IDO owner
     * @param targetAmount Targeted amount to be raised in IDO
     * @param minimumInvestment Minimum investment amount for the project
     * @param idoToken Address of IDO token
     * @param tokensForDistribution Number of IDO tokens to be distributed
     * @param tokenPrice IDO token price in terms of payment token
     * @param investmentStartTimestamp IDO open timestamp
     * @param idoCloseTimestamp IDO close timestamp
     */
    function addIDO(
        string calldata idoID,
        address idoOwner,
        uint256 targetAmount,
        uint256 minimumInvestment,
        address idoToken,
        uint256 tokensForDistribution,
        uint256 tokenPrice,
        uint256 winnersOutTimestamp,
        uint256 investmentStartTimestamp,
        uint256 idoCloseTimestamp
    ) external onlyOwner {
        require(!idoExist(idoID), "KyotoLaunchpad: IDO id already exist");
        require(idoOwner != address(0), "KyotoLaunchpad: IDO owner zero");
        require(targetAmount != 0, "KyotoLaunchpad: target amount zero");
        require(minimumInvestment != 0, "KyotoLaunchpad: minimum amount zero");
        require(idoToken != address(0), "KyotoLaunchpad: IDO token address zero");
        require(tokenPrice != 0, "KyotoLaunchpad: token price zero");
        require(
            tokensForDistribution >=
                calculateIDOTokens(idoToken, tokenPrice, targetAmount),
            "KyotoLaunchpad: tokensForDistribution would not suffice"
        );
        require(
            block.timestamp < winnersOutTimestamp &&
            winnersOutTimestamp <= investmentStartTimestamp &&
            investmentStartTimestamp < idoCloseTimestamp,
            "KyotoLaunchpad: IDO invalid timestamps"
        );

        _idos[idoID] = IDO(
            idoOwner,
            targetAmount,
            minimumInvestment,
            idoToken,
            tokensForDistribution,
            tokenPrice,
            winnersOutTimestamp,
            investmentStartTimestamp,
            idoCloseTimestamp,
            false
        );

        IERC20Upgradeable(_idos[idoID].idoToken).safeTransferFrom(
            idoOwner,
            address(this),
            tokensForDistribution
        );
        emit IDOAdded(idoID, idoOwner, idoToken);
    }

    /**
     * @notice This method is used to cancel an IDO
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     */
    function cancelIDO(string calldata idoID) external onlyOwner {
        require(idoExist(idoID), "KyotoLaunchpad: IDO doesn't exist");

        IDO memory ido = _idos[idoID];
        require(!ido.cancelled, "KyotoLaunchpad: IDO already cancelled");
        require(
            block.timestamp < ido.idoCloseTimestamp,
            "KyotoLaunchpad: IDO is closed"
        );

        _idos[idoID].cancelled = true;

        IERC20Upgradeable(ido.idoToken).safeTransfer(
            ido.idoOwner,
            ido.tokensForDistribution
        );

        emit IDOCancelled(idoID);
    }

    /**
     * @notice This method is used to distribute investment raised in IDO
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     */
    function collectIDOInvestment(string calldata idoID) external onlyOwner {
        require(idoExist(idoID), "KyotoLaunchpad: IDO doesn't exist");

        IDO memory ido = _idos[idoID];
        require(!ido.cancelled, "KyotoLaunchpad: IDO is cancelled");
        require(
            block.timestamp > ido.idoCloseTimestamp,
            "KyotoLaunchpad: IDO is open"
        );

        IDOInvestment memory idoInvestment = _idoInvestments[idoID];

        require(
            !idoInvestment.collected,
            "KyotoLaunchpad: IDO investment already collected"
        );
        require(
            idoInvestment.totalInvestment != 0,
            "KyotoLaunchpad: IDO investment zero"
        );

        uint256 platformShare = feePercentage == 0
            ? 0
            : (feePercentage * idoInvestment.totalInvestment) /
                PERCENT_DENOMINATOR;

        _idoInvestments[idoID].collected = true;

        transferBNB(owner, platformShare);
        transferBNB(
            ido.idoOwner,
            idoInvestment.totalInvestment - platformShare
        );

        uint256 idoTokensLeftover = ido.tokensForDistribution -
            calculateIDOTokens(
                ido.idoToken,
                ido.tokenPrice,
                idoInvestment.totalInvestment
            );
        IERC20Upgradeable(ido.idoToken).safeTransfer(ido.idoOwner, idoTokensLeftover);
        emit IDOInvestementCollected(idoID);
    }

    /**
     * @notice This method is used to invest in an IDO
     * @dev User must send _amount in order to invest
     * @param idoID ID of the IDO
     */
    function invest(string calldata idoID, bytes32[] calldata merkleProof, uint256 _amount) 
    external payable {
        require(idoExist(idoID), "KyotoLaunchpad: IDO doesn't exist");
        require(_amount != 0, "KyotoLaunchpad: investment zero");

        IDO memory ido = _idos[idoID];
        require(
            block.timestamp >= ido.investmentStartTimestamp,
            "KyotoLaunchpad: IDO is not open"
        );
        require(
            block.timestamp < ido.idoCloseTimestamp,
            "KyotoLaunchpad: IDO has closed"
        );
        require(!ido.cancelled, "KyotoLaunchpad: IDO cancelled");
        require(
            _amount >= ido.tokenPrice,
            "KyotoLaunchpad: amount less than token price"
        );
        require(_amount > ido.minimumInvestment, "KyotoLaunchpad: amount less than minimum");
        IDOInvestment memory idoInvestment = _idoInvestments[idoID];

        require(
            ido.targetAmount >= idoInvestment.totalInvestment + _amount,
            "KyotoLaunchpad: amount exceeds target"
        );
        require(
            _idoMerkleRoots[idoID] != bytes32(0),
            "KyotoLaunchPad: whitelist not approved by admin yet"
        );
        require(
            _isWhitelisted(_idoMerkleRoots[idoID], merkleProof),
            "KyotoLaunchPad: user is not whitelisted"
        );

        require(
            msg.value == _amount,
            "KyotoLaunchpad: msg.value not equal to amount"
        );

        idoInvestment.totalInvestment += _amount;
        if (_idoInvestors[idoID][msg.sender].investment == 0)
            ++idoInvestment.totalInvestors;
        _idoInvestments[idoID] = idoInvestment;
        _idoInvestors[idoID][msg.sender].investment += _amount;

        emit IDOInvested(idoID, msg.sender, _amount);
    }

    /**
     * @notice This method is used to refund investment to investor if IDO is cancelled
     * @param idoID ID of the IDO
     * @param merkleProof merkle proof to prove whitelist status
     */
    function refundInvestment(string calldata idoID, bytes32[] calldata merkleProof) external {
        require(idoExist(idoID), "KyotoLaunchpad: IDO doesn't exist");
        require(
            _isWhitelisted(_idoMerkleRoots[idoID], merkleProof),
            "KyotoLaunchPad: user not whitelisted"
        );

        IDO memory ido = _idos[idoID];
        require(ido.cancelled, "KyotoLaunchpad: IDO is not cancelled");

        Investor memory user = _idoInvestors[idoID][msg.sender];
        require(!user.refunded, "KyotoLaunchpad: already refunded");
        require(user.investment != 0, "KyotoLaunchpad: no investment found");

        _idoInvestors[idoID][msg.sender].refunded = true;
        transferBNB(msg.sender, user.investment);

        emit IDOInvestmentRefunded(idoID, msg.sender, user.investment);
    }

    /**
     * @notice This method is used to claim project tokens after project is closed
     * @param idoID ID of the IDO
     * @param merkleProof merkle proof to prove whitelist status
     */

    function claimIDOTokens(string calldata idoID, bytes32[] calldata merkleProof) external {
        require(idoExist(idoID), "KyotoLaunchpad: IDO doesn't exist");
        require(
            _isWhitelisted(_idoMerkleRoots[idoID], merkleProof),
            "KyotoLaunchPad: user is not whitelisted"
        );
        IDO memory ido = _idos[idoID];

        require(!ido.cancelled, "KyotoLaunchpad: IDO is cancelled");
        require(
            block.timestamp > ido.idoCloseTimestamp,
            "KyotoLaunchpad: IDO not closed yet"
        );

        Investor memory user = _idoInvestors[idoID][msg.sender];
        require(!user.claimed, "KyotoLaunchpad: already claimed");
        require(user.investment != 0, "KyotoLaunchpad: no investment found");

        uint256 idoTokens = calculateIDOTokens(
            ido.idoToken,
            ido.tokenPrice,
            user.investment
        );
        _idoInvestors[idoID][msg.sender].claimed = true;
        _idoInvestments[idoID].totalIDOTokensClaimed += idoTokens;

        IERC20Upgradeable(ido.idoToken).safeTransfer(msg.sender, idoTokens);

        emit IDOInvestmentClaimed(idoID, msg.sender, idoTokens);
    }

    /**
     * @notice This method is to collect any ETH left from failed transfers.
     * @dev This method can only be called by the contract owner
     */
    function collectETHFromFailedTransfers() external onlyOwner {
        uint256 ethToSend = ETHFromFailedTransfers;
        ETHFromFailedTransfers = 0;
        (bool success, ) = payable(owner).call{value: ethToSend}("");
        require(success, "KyotoLaunchpad: BNB transfer failed");
    }
}