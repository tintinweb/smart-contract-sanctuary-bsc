// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

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
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Whitelist.sol";

contract PreSalePool is Initializable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    IERC20 public BUSDToken;
    IERC20 public preSaleToken;
    AggregatorV3Interface internal priceFeed;

    struct SalePhase {
        uint256 startTime;
        uint256 endTime;
        uint256[] claimTime;
        uint256[] claimRate;
        bool isNoBuyLimit;
        uint256 maxBUSDUserCanSpend;
        uint256 preSaleTokenPrice; // in BUSD
        uint256 maxPreSaleAmount;
        uint256 totalSoldAmount;
        uint256 totalClaimedAmount;
        address treasuryAddress;
        mapping(address => uint256) BUSDUserSpent;
        mapping(address => uint256) userPurchasedAmount;
        mapping(address => uint256) userClaimedAmount;
    }

    uint8 public totalSalePhase;
    uint8 public currentSalePhase;

    mapping(uint8 => SalePhase) public salePhaseStatistics;

    address public superAdmin;
    mapping(address => bool) public subAdmins;

    address public signer;
    mapping(address => uint256) public nonces;

    /*---------- CONSTANTS -----------*/
    uint256 public constant MULTIPLIER = 1e18;
    uint256 public constant ONE_HUNDRED_PERCENT = 10000;
    uint256 public constant TAX = 225; // 2.25%

    /*---------- EVENTS -----------*/
    event PoolCreated(address _superAdmin, address _signer);
    event PreSaleTokenSet(IERC20 _preSaleToken);
    event BUSDTokenSet(IERC20 _BUSDToken);

    event NewSalePhaseDeployed(
        uint8 _salePhase,
        uint256 _startTime,
        uint256 _endTime,
        uint256[] _claimTime,
        uint256[] _claimRate,
        bool _isNoBuyLimit,
        uint256 _maxBUSDUserCanSpend,
        uint256 _maxPreSaleAmount,
        uint256 _preSaleTokenPrice,
        address _treasuryAddress
    );

    event SubAdminsAdded(address _subAdmin);
    event SubAdminsRemoved(address _subAdmin);
    event NewSignerSet(address _signer);
    event PriceFeedSet(address _priceFeed);
    event SuperAdminChanged(address _superAdmin);
    event BuyTokenWithExactlyBUSD(address indexed _candidate, uint256 _BUSDAmount);
    event BuyTokenWithExactlyBNB(address indexed _candidate, uint256 _BNBAmount);
    event BuyTokenWithoutFee(address indexed _candidate, uint256 _TokenAmount);
    event TokenClaimed(address indexed _candidate, uint256 _tokenAmount, uint8 _salePhase);
    event WithdrawPresaleToken(uint256 _tokenAmount);

    /**
     * @dev fallback function
     */
    fallback() external {
        revert();
    }

    /**
     * @dev fallback function
     */
    receive() external payable {
        revert();
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _signer,
        IERC20 _BUSDToken,
        IERC20 _GXZToken
    ) public initializer {
        require(_signer != address(0), "POOL: INVALID SIGNER");
        require(address(_BUSDToken) != address(0), "POOL: INVALID BUSD TOKEN");
        require(address(_GXZToken) != address(0), "POOL: INVALID GXZ TOKEN");

        __Pausable_init();
        __ReentrancyGuard_init();

        superAdmin = msg.sender;
        signer = _signer;
        BUSDToken = _BUSDToken;
        preSaleToken = _GXZToken;

        /**
         * Network: BSC Mainnet
         * Aggregator: BUSD/BNB
         * Address: 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941
         */
        priceFeed = AggregatorV3Interface(0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941);

        emit PoolCreated(msg.sender, _signer);
    }

    /*---------- MODIFIERS -----------*/
    modifier onlyAdmin() {
        require(msg.sender == superAdmin || isSubAdmin(msg.sender), "POOL: UNAUTHORIZED");
        _;
    }

    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "POOL: UNAUTHORIZED");
        _;
    }

    modifier inSalePhase() {
        require(block.timestamp <= salePhaseStatistics[currentSalePhase].endTime, "POOL: NOT IN SALE PHASE");
        require(block.timestamp >= salePhaseStatistics[currentSalePhase].startTime, "POOL: NOT IN SALE PHASE");
        _;
    }

    /*---------- CONFIG FUNCTIONS -----------*/
    function setPreSaleToken(IERC20 _preSaleToken) external onlyAdmin {
        require(address(_preSaleToken) != address(0), "POOL: INVALID PRESALE TOKEN");
        preSaleToken = _preSaleToken;
        emit PreSaleTokenSet(_preSaleToken);
    }

    function setBUSDToken(IERC20 _BUSDToken) external onlyAdmin {
        require(address(_BUSDToken) != address(0), "POOL: INVALID BUSD TOKEN");
        BUSDToken = _BUSDToken;
        emit BUSDTokenSet(_BUSDToken);
    }

    function deployNewSalePhase(
        uint8 _salePhase,
        uint256 _startTime,
        uint256 _endTime,
        uint256[] memory _claimTime,
        uint256[] memory _claimRate,
        bool _isNoBuyLimit,
        uint256 _maxBUSDUserCanSpend,
        uint256 _preSaleTokenPrice, // in BUSD
        uint256 _maxPreSaleAmount,
        address _treasuryAddress
    ) external onlyAdmin {
        require(salePhaseStatistics[_salePhase].startTime == 0, "POOL: SALE PHASE ALREADY EXIST");
        require(
            _startTime >= block.timestamp && _startTime >= salePhaseStatistics[currentSalePhase].endTime,
            "POOL: INVALID START TIME"
        );
        require(block.timestamp >= salePhaseStatistics[currentSalePhase].endTime, "POOL: CURRENT SALE PHASE NOT ENDED");
        require(_endTime > _startTime, "POOL: INVALID END TIME");
        require(isClaimTimeValid(_claimTime, _claimRate, _endTime), "POOL: INVALID CLAIM TIME OR RATE");
        if (!_isNoBuyLimit) {
            require(_maxBUSDUserCanSpend > 0, "POOL: INVALID MAX BUSD USER CAN SPEND");
        }
        require(_maxPreSaleAmount > 0, "POOL: INVALID MAX PRESALE AMOUNT");
        require(_preSaleTokenPrice >= 0, "POOL: INVALID PRESALE TOKEN PRICE");
        require(_treasuryAddress != address(0), "POOL: INVALID TREASURY ADDRESS");

        SalePhase storage newSalePhase = salePhaseStatistics[_salePhase];
        newSalePhase.startTime = _startTime;
        newSalePhase.endTime = _endTime;

        newSalePhase.claimTime = _claimTime;
        newSalePhase.claimRate = _claimRate;

        newSalePhase.isNoBuyLimit = _isNoBuyLimit;
        newSalePhase.maxBUSDUserCanSpend = _maxBUSDUserCanSpend;

        newSalePhase.maxPreSaleAmount = _maxPreSaleAmount;
        newSalePhase.preSaleTokenPrice = _preSaleTokenPrice;
        newSalePhase.totalSoldAmount = 0;
        newSalePhase.totalClaimedAmount = 0;
        newSalePhase.treasuryAddress = _treasuryAddress;

        totalSalePhase++;
        currentSalePhase = _salePhase;
        emit NewSalePhaseDeployed(
            _salePhase,
            _startTime,
            _endTime,
            _claimTime,
            _claimRate,
            _isNoBuyLimit,
            _maxBUSDUserCanSpend,
            _maxPreSaleAmount,
            _preSaleTokenPrice,
            _treasuryAddress
        );
    }

    function addSubAdmin(address _subAdmin) external onlySuperAdmin {
        require(_subAdmin != address(0), "POOL: ZERO ADDRESS");
        require(!isSubAdmin(_subAdmin), "POOL: ALREADY SUB ADMIN");
        require(_subAdmin != superAdmin, "POOL: ALREADY SUPER ADMIN");
        subAdmins[_subAdmin] = true;

        emit SubAdminsAdded(_subAdmin);
    }

    function removeSubAdmin(address _subAdmin) external onlySuperAdmin {
        require(isSubAdmin(_subAdmin), "POOL: NOT SUB ADMIN");
        subAdmins[_subAdmin] = false;

        emit SubAdminsRemoved(_subAdmin);
    }

    function setSigner(address _signer) external onlyAdmin {
        require(_signer != address(0), "POOL: ZERO ADDRESS");
        signer = _signer;
        emit NewSignerSet(_signer);
    }

    function pause() external onlyAdmin {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }

    function changeSuperAdmin(address _newSuperAdmin) external onlySuperAdmin {
        require(_newSuperAdmin != address(0), "POOL: INVALID NEW SUPER ADMIN");
        if (isSubAdmin(_newSuperAdmin)) {
            subAdmins[_newSuperAdmin] = false;
        }
        superAdmin = _newSuperAdmin;

        emit SuperAdminChanged(_newSuperAdmin);
    }

    function setPriceFeed(address _priceFeed) external onlyAdmin {
        require(_priceFeed != address(0), "POOL: INVALID PRICE FEED");
        priceFeed = AggregatorV3Interface(_priceFeed);
        emit PriceFeedSet(_priceFeed);
    }

    /*---------- HELPER FUNCTIONS -----------*/
    function getTokenAmountFromBUSD(uint256 _BUSDAmount, uint256 _tokenPriceInBUSD) public pure returns (uint256) {
        return (_BUSDAmount * MULTIPLIER) / _tokenPriceInBUSD;
    }

    function getBUSDAmountFromToken(uint256 _tokenAmount, uint256 _tokenPriceInBUSD) public pure returns (uint256) {
        return (_tokenAmount * _tokenPriceInBUSD) / MULTIPLIER;
    }

    function convertBUSDToBNB(uint256 _BUSDAmount) public view returns (uint256) {
        int256 BNBPerBUSD = getLatestPrice();
        require(BNBPerBUSD > 0, "POOL: INVALID BNB/BUSD PRICE");
        uint8 decimals = getPriceFeedDecimals();
        uint256 BNBPerBUSDInUint256 = uint256(BNBPerBUSD);
        return (_BUSDAmount * BNBPerBUSDInUint256) / (10**decimals);
    }

    function convertBNBToBUSD(uint256 _BNBAmount) public view returns (uint256) {
        int256 BNBPerBUSD = getLatestPrice();
        require(BNBPerBUSD > 0, "POOL: INVALID BNB/BUSD PRICE");
        uint8 decimals = getPriceFeedDecimals();
        uint256 BNBPerBUSDInUint256 = uint256(BNBPerBUSD);
        return (_BNBAmount * (10**decimals)) / BNBPerBUSDInUint256;
    }

    function isSubAdmin(address _address) private view returns (bool) {
        return subAdmins[_address];
    }

    function canBuyMoreToken(address _candidate, uint256 _BUSDAmount) private view returns (bool) {
        if (_BUSDAmount == 0) return false;

        uint256 maxPreSaleAmount = salePhaseStatistics[currentSalePhase].maxPreSaleAmount;
        uint256 totalSoldAmount = salePhaseStatistics[currentSalePhase].totalSoldAmount;

        uint256 tokenAmountUserCanBuy = getTokenAmountFromBUSD(
            _BUSDAmount,
            salePhaseStatistics[currentSalePhase].preSaleTokenPrice
        );
        if (tokenAmountUserCanBuy + totalSoldAmount > maxPreSaleAmount) return false;

        bool isNoBuyLimit = salePhaseStatistics[currentSalePhase].isNoBuyLimit;
        if (!isNoBuyLimit) {
            uint256 maxBUSDUserCanSpend = salePhaseStatistics[currentSalePhase].maxBUSDUserCanSpend;

            uint256 totalBUSDUserSpent = salePhaseStatistics[currentSalePhase].BUSDUserSpent[_candidate];
            return totalBUSDUserSpent + _BUSDAmount <= maxBUSDUserCanSpend;
        }

        return true;
    }

    function getClaimableAmount(address _candidate, uint8 _salePhase) private view returns (uint256) {
        require(block.timestamp >= salePhaseStatistics[_salePhase].claimTime[0], "POOL: CLAIM IS NOT AVAILABLE");

        uint256 totalPurchasedAmount = salePhaseStatistics[_salePhase].userPurchasedAmount[_candidate];
        uint256 totalClaimedAmount = salePhaseStatistics[_salePhase].userClaimedAmount[_candidate];

        uint256[] memory claimTime = salePhaseStatistics[_salePhase].claimTime;
        uint256[] memory claimRate = salePhaseStatistics[_salePhase].claimRate;
        uint256 claimableRate = 0;
        for (uint256 i = 0; i < claimTime.length; i++) {
            if (block.timestamp >= claimTime[i]) {
                claimableRate += claimRate[i];
            }
        }
        return ((totalPurchasedAmount * claimableRate) / ONE_HUNDRED_PERCENT) - totalClaimedAmount;
    }

    function verifyWhitelist(
        uint256 _nonce,
        uint8 _salePhase,
        address _candidate,
        uint256 _BUSDAmount,
        bytes memory _signature
    ) private view returns (bool) {
        require(msg.sender == _candidate, "POOL: WRONG CANDIDATE");
        return (Whitelist.verifySignature(_nonce, _salePhase, signer, _candidate, _BUSDAmount, _signature));
    }

    function getTaxAmount(uint256 _BUSDAmount) public pure returns (uint256) {
        return (_BUSDAmount * TAX) / ONE_HUNDRED_PERCENT;
    }

    function isClaimTimeValid(
        uint256[] memory _claimTime,
        uint256[] memory _claimRate,
        uint256 _endTime
    ) private pure returns (bool) {
        if (_claimTime.length == 0) return false;
        if (_claimTime.length != _claimRate.length) return false;
        // check if claim time is after end time
        if (_claimTime[0] < _endTime) return false;
        // check if claim time is in order
        for (uint256 i = 0; i < _claimTime.length - 1; i++) {
            if (_claimTime[i] >= _claimTime[i + 1]) return false;
        }
        // check if total claim rate is 100%
        uint256 totalClaimRate = 0;
        for (uint256 i = 0; i < _claimRate.length; i++) {
            totalClaimRate += _claimRate[i];
        }
        if (totalClaimRate != ONE_HUNDRED_PERCENT) return false;
        return true;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() private view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }

    function getPriceFeedDecimals() private view returns (uint8) {
        return priceFeed.decimals();
    }

    /*---------- BUY FUNCTIONS -----------*/
    function buyTokenWithExactlyBUSD(
        uint8 _salePhase,
        address _candidate,
        uint256 _BUSDAmount,
        bytes memory _signature
    ) external inSalePhase whenNotPaused nonReentrant {
        require(_salePhase == currentSalePhase, "POOL: WRONG SALE PHASE");
        require(
            verifyWhitelist(nonces[_candidate], _salePhase, _candidate, _BUSDAmount, _signature),
            "POOL: NOT IN WHITELIST"
        );
        require(canBuyMoreToken(_candidate, _BUSDAmount), "POOL: CANNOT BUY MORE TOKEN");

        uint256 taxAmount = getTaxAmount(_BUSDAmount);
        require(BUSDToken.balanceOf(msg.sender) >= _BUSDAmount + taxAmount, "POOL: NOT ENOUGH BUSD");

        uint256 amountUserCanBuy = getTokenAmountFromBUSD(
            _BUSDAmount,
            salePhaseStatistics[currentSalePhase].preSaleTokenPrice
        );

        salePhaseStatistics[currentSalePhase].userPurchasedAmount[msg.sender] += amountUserCanBuy;
        salePhaseStatistics[currentSalePhase].totalSoldAmount += amountUserCanBuy;
        salePhaseStatistics[currentSalePhase].BUSDUserSpent[msg.sender] += _BUSDAmount;

        BUSDToken.safeTransferFrom(
            msg.sender,
            salePhaseStatistics[currentSalePhase].treasuryAddress,
            _BUSDAmount + taxAmount
        );
        nonces[_candidate]++;

        emit BuyTokenWithExactlyBUSD(msg.sender, _BUSDAmount);
    }

    function buyTokenWithExactlyBNB(
        uint8 _salePhase,
        address _candidate,
        bytes memory _signature
    ) external payable inSalePhase whenNotPaused nonReentrant {
        require(_salePhase == currentSalePhase, "POOL: WRONG SALE PHASE");
        uint256 BUSDAmount = convertBNBToBUSD(msg.value);
        require(
            verifyWhitelist(nonces[_candidate], _salePhase, _candidate, BUSDAmount, _signature),
            "POOL: NOT IN WHITELIST"
        );
        require(msg.value > 0, "POOL: INVALID BNB AMOUNT");

        require(canBuyMoreToken(_candidate, BUSDAmount), "POOL: CANNOT BUY MORE TOKEN");

        uint256 taxAmount = getTaxAmount(BUSDAmount);
        require(BUSDToken.balanceOf(msg.sender) >= taxAmount, "POOL: NOT ENOUGH BUSD");
        BUSDToken.safeTransferFrom(msg.sender, salePhaseStatistics[currentSalePhase].treasuryAddress, taxAmount);

        uint256 amountUserCanBuy = getTokenAmountFromBUSD(
            BUSDAmount,
            salePhaseStatistics[currentSalePhase].preSaleTokenPrice
        );

        salePhaseStatistics[currentSalePhase].userPurchasedAmount[msg.sender] += amountUserCanBuy;
        salePhaseStatistics[currentSalePhase].totalSoldAmount += amountUserCanBuy;
        salePhaseStatistics[currentSalePhase].BUSDUserSpent[msg.sender] += BUSDAmount;

        Address.sendValue(payable(salePhaseStatistics[currentSalePhase].treasuryAddress), msg.value);
        nonces[_candidate]++;

        emit BuyTokenWithExactlyBNB(msg.sender, msg.value);
    }

    function buyTokenWithoutFee(
        uint8 _salePhase,
        address _candidate,
        uint256 _numberOfCandidate,
        bytes memory _signature
    ) external inSalePhase whenNotPaused nonReentrant {
        require(salePhaseStatistics[currentSalePhase].preSaleTokenPrice == 0, "POOL: NOT IN FREE PHASE");
        require(_salePhase == currentSalePhase, "POOL: WRONG SALE PHASE");
        require(_numberOfCandidate > 0, "POOL: INVALID NUMBER OF CANDIDATE");
        require(
            verifyWhitelist(nonces[_candidate], _salePhase, _candidate, _numberOfCandidate, _signature),
            "POOL: NOT IN WHITELIST"
        );
        uint256 userPurchasedAmount = getUserClaimedAmount(msg.sender, _salePhase);
        uint256 maxTokenAmountUserCanBuy = salePhaseStatistics[currentSalePhase].maxPreSaleAmount / _numberOfCandidate;
        require(userPurchasedAmount <= maxTokenAmountUserCanBuy, "POOL: CANNOT BUY MORE TOKEN");

        salePhaseStatistics[currentSalePhase].userPurchasedAmount[msg.sender] += maxTokenAmountUserCanBuy;
        salePhaseStatistics[currentSalePhase].totalSoldAmount += maxTokenAmountUserCanBuy;
        nonces[_candidate]++;

        emit BuyTokenWithoutFee(msg.sender, maxTokenAmountUserCanBuy);
    }

    /*---------- CLAIM FUNCTIONS -----------*/
    function claimPurchasedToken(uint8 _salePhase) external whenNotPaused nonReentrant {
        uint256 claimableAmount = getClaimableAmount(msg.sender, _salePhase);
        require(claimableAmount > 0, "POOL: NOTHING TO CLAIM");
        salePhaseStatistics[_salePhase].userClaimedAmount[msg.sender] += claimableAmount;
        salePhaseStatistics[_salePhase].totalClaimedAmount += claimableAmount;

        preSaleToken.safeTransfer(msg.sender, claimableAmount);

        emit TokenClaimed(msg.sender, claimableAmount, _salePhase);
    }

    /*---------- WITHDRAW FUNCTIONS -----------*/
    function withdrawPresaleToken() external whenNotPaused nonReentrant onlySuperAdmin {
        preSaleToken.safeTransferFrom(address(this), msg.sender, preSaleToken.balanceOf(address(this)));
        emit WithdrawPresaleToken(preSaleToken.balanceOf(address(this)));
    }

    /*---------- GETTERS -----------*/
    function getUserPurchasedAmount(address _candidate, uint8 _salePhase) public view returns (uint256) {
        return salePhaseStatistics[_salePhase].userPurchasedAmount[_candidate];
    }

    function getUserClaimedAmount(address _candidate, uint8 _salePhase) public view returns (uint256) {
        return salePhaseStatistics[_salePhase].userClaimedAmount[_candidate];
    }

    function getUserTotalSpentBUSD(address _candidate, uint8 _salePhase) external view returns (uint256) {
        return salePhaseStatistics[_salePhase].BUSDUserSpent[_candidate];
    }

    function getRemainingClaimableAmount(address _candidate, uint8 _salePhase) external view returns (uint256) {
        return getUserPurchasedAmount(_candidate, _salePhase) - getUserClaimedAmount(_candidate, _salePhase);
    }

    function getClaimInfo(uint8 _salePhase) external view returns (uint256[] memory, uint256[] memory) {
        return (salePhaseStatistics[_salePhase].claimTime, salePhaseStatistics[_salePhase].claimRate);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library Whitelist {
    function verifySignature(
        uint256 _nonce,
        uint8 _salePhase,
        address _signer,
        address _candidate,
        uint256 _BUSDAmount,
        bytes memory _signature
    ) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(_nonce, _salePhase, _signer, _candidate, _BUSDAmount);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        address signerAddress = getSignerAddress(ethSignedMessageHash, _signature);
        return signerAddress == _signer;
    }

    function getMessageHash(
        uint256 _nonce,
        uint8 _salePhase,
        address _signer,
        address _candidate,
        uint256 _BUSDAmount
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_nonce, _salePhase, _signer, _candidate, _BUSDAmount));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        return ECDSA.toEthSignedMessageHash(_messageHash);
    }

    function getSignerAddress(bytes32 _messageHash, bytes memory _signature) internal pure returns (address) {
        return ECDSA.recover(_messageHash, _signature);
    }
}