// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

// EIP-712 is Final as of 2022-08-11. This file is deprecated.

import "./EIP712Upgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
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
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
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

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
 *
 * @custom:storage-size 52
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

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
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
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
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
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

import "./math/MathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
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
            return toHexString(value, MathUpgradeable.log256(value) + 1);
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
pragma solidity ^0.8.15;

interface IAmountsDistributor {
    function distributeAmounts(uint256 _amount, uint8 _operationType, address _user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC165 {
    /**
     * @notice Returns weather contract supports fiven interface
     * @dev This contract supports ERC165 and ERC721 interfaces
     * @param _interfaceId id of the interface which is checked to be supported
     * @return true - given interface is supported, false - given interface is not supported
     */
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

import "./IERC165.sol";
import "./IERC721Lockable.sol";
import "./IERC721Metadata.sol";

pragma solidity ^0.8.15;

interface IERC721Base is IERC165, IERC721Lockable, IERC721Metadata {
    /**
     * @dev This event is emitted when token is transfered
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /**
     * @dev This event is emitted when user is approved for token
     * @param _owner address of the owner of the token
     * @param _approval address of the user who gets approved
     * @param _tokenId id of the token that gets approved
     */
    event Approval(address indexed _owner, address indexed _approval, uint256 indexed _tokenId);

    /**
     * @dev This event is emitted when an address is approved/disapproved for another user's tokens
     * @param _owner address of the user whos tokens are being approved/disapproved to be used
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Total amount of nft tokens in circulation
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gives the number of nft tokens that a given user owns
     * @param _owner address of the user who's token's count will be returned
     * @return amount of tokens given user owns
     */
    function balanceOf(address _owner) external view returns (uint256);

    /**
     * @notice Tells weather a token exists
     * @param _tokenId id of the token who's existence is returned
     * @return true - exists, false - does not exist
     */
    function exists(uint256 _tokenId) external view returns (bool);

    /**
     * @notice Gives owner address of a given token
     * @param _tokenId id of the token who's owner address is returned
     * @return address of the given token owner
     */
    function ownerOf(uint256 _tokenId) external view returns (address);

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes "_data" from this function arguments
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     * @param _data argument which will be passed to "onERC721Received" function
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external;

    /**
     * @notice Transfers token and checkes weather it was recieved if reciver is ERC721Reciver contract
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev When calling "onERC721Received" function passes an empty string for "data" parameter
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Transfers token without checking weather it was recieved
     *         Only authorized users can call this function
     *         Only unlocked tokens can be used to transfer
     * @dev Does not call "onERC721Received" function even if the reciver is ERC721TokenReceiver
     * @param _from address of the user from whom token is transfered
     * @param _to address of the user who will recive the token
     * @param _tokenId id of the token which will be transfered
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    /**
     * @notice Approves an address to use given token
     *         Only authorized users can call this function
     * @dev Only one user can be approved at any given moment
     * @param _approved address of the user who gets approved
     * @param _tokenId id of the token the given user get aproval on
     */
    function approve(address _approved, uint256 _tokenId) external;

    /**
     * @notice Approves or disapproves an address to use all tokens of the caller
     * @param _operator address of the user who gets approved/disapproved
     * @param _approved true - approves, false - disapproves
     */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
     * @notice Gives the approved address of the given token
     * @param _tokenId id of the token who's approved user is returned
     * @return address of the user who is approved for the given token
     */
    function getApproved(uint256 _tokenId) external view returns (address);

    /**
     * @notice Tells weather given user (_operator) is approved to use tokens of another given user (_owner)
     * @param _owner address of the user who's tokens are checked to be aproved to another user
     * @param _operator address of the user who's checked to be approved by owner of the tokens
     * @return true - approved, false - disapproved
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    /**
     * @notice Tells weather given user (_operator) is approved to use given token (_tokenId)
     * @param _operator address of the user who's checked to be approved for given token
     * @param _tokenId id of the token for which approval will be checked
     * @return true - approved, false - disapproved
     */
    function isAuthorized(address _operator, uint256 _tokenId) external view returns (bool);

    /// @notice Returns the purchase date for this NFT
    function getUserPurchaseTime(address _user) external view returns (uint256[2] memory);

    /// @notice Returns all the token IDs belonging to this user
    function tokensOf(address _owner) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC721Lockable {
    /**
     * @dev Event that is emitted when token lock status is set
     * @param _tokenId id of the token who's lock status is set
     * @param _lock true - is locked, false - is not locked
     */
    event LockStatusSet(uint256 _tokenId, bool _lock);

    /**
     * @notice Tells weather a token is locked
     * @param _tokenId id of the token who's lock status is returned
     * @return true - is locked, false - is not locked
     */
    function isLocked(uint256 _tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function baseURI() external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IMinerNFT {
    function mint(address) external returns (uint256);
    function hashrate() external pure returns (uint256);
    function lastMinerId() external returns(uint256);
    function mintMiners(address _user, uint256 _count) external returns(uint256, uint256);
    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IMining {
    function deposit(address _user, uint256 _miner, uint256 _hashRate) external;
    function depositMiners(address _user, uint256 _firstMinerId, uint256 _minersCount, uint256 _hashRate) external;
    function withdraw(address _user,uint256 _miner) external;
    function getMinersCount(address _user) external view returns (uint256);
    function repairMiners(address _user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface INetGymStreet {
    function addGymMlm(address _user, uint256 _referrerId) external;

    function distributeRewards(
        uint256 _wantAmt,
        address _wantAddr,
        address _user
    ) external;

    function getUserCurrentLevel(address _user) external view returns (uint256);

    function updateAdditionalLevel(address _user, uint256 _level) external;
    function getInfoForAdditionalLevel(address _user) external view returns (uint256 _termsTimestamp, uint256 _level);

    function lastPurchaseDateERC(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../Municipality.sol";

interface IParcelInterface {
    function mint(address user, uint256 x, uint256 y, uint256 landType) external returns (uint256);
    function parcelExists(uint256 x, uint256 y, uint256 landType) external view returns(bool);
    function getParcelId(uint256 x, uint256 y, uint256 landType) external pure returns (uint256);
    function isParcelUpgraded(uint256 tokenId) external view returns (bool);
    function upgradeParcel(uint256 tokenId) external;
    function upgradeParcels(uint256[] memory tokenIds) external;
    function mintParcels(address _user, Municipality.Parcel[] calldata parcels) external returns(uint256[] memory);
    function requireNFTsBelongToUser(uint256[] memory nftIds, address userWalletAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "../Municipality.sol";

interface ISignatureValidator {
    function verifySigner(Municipality.ParcelsMintSignature memory mintParcelSignature) external view returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "../Municipality.sol";

interface ISignatureValidatorKB {
    function verifySigner(Municipality.SeededDataSignature memory seededDataSignature) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/ISignatureValidatorKB.sol";
import "./interfaces/ISignatureValidator.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IParcelInterface.sol";
import "./interfaces/INetGymStreet.sol";
import "./interfaces/IERC721Base.sol";
import "./interfaces/IMinerNFT.sol";
import "./interfaces/IMining.sol";
import "./interfaces/IAmountsDistributor.sol";

contract Municipality is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct AttachedMiner {
        uint256 parcelId;
        uint256 minerId;
    }

    struct Parcel {
        uint16 x;
        uint16 y;
        uint8 parcelType;
        uint8 parcelLandType;
    }
    
    // bundlePrice is not used anymore
    struct BundleInfo {
        uint256 parcelsAmount;
        uint256 minersAmount;
        uint256 bundlePrice;
        uint256 discountPct;
    }

    struct SuperBundleInfo {
        uint256 parcelsAmount;
        uint256 minersAmount;
        uint256 upgradesAmount;
        uint256 discountPct;
    }

    struct ParcelsMintSignature {
        Parcel[] parcels;
        bytes[] signatures;
    }
   
    struct UserMintableNFTAmounts {
        uint256 parcels;
        uint256 miners;
        uint256 upgrades;
    }

    struct LastPurchaseData {
        uint256 lastPurchaseDate;
        uint256 expirationDate;
        uint256 dollarValue;
    }

    struct SeededDataSignature {
        UserMintableNFTAmounts seedingMintableNFTAmounts;
        bytes signature;
    }

    uint8 private constant OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS = 10;
    uint8 private constant OPERATION_TYPE_MINT_MINERS = 20;

    uint8 private constant MINER_STATUS_DETACHED = 10;
    uint8 private constant MINER_STATUS_ATTACHED = 20;

    uint8 private constant PARCEL_TYPE_STANDARD = 10;

    uint8 private constant PARCEL_LAND_TYPE_NEXT_TO_OCEAN = 10;
    uint8 private constant PARCEL_LAND_TYPE_NEAR_OCEAN = 20;
    uint8 private constant PARCEL_LAND_TYPE_INLAND = 30;

    uint8 private constant BUNDLE_TYPE_PARCELS_MINERS_1 = 0;
    uint8 private constant BUNDLE_TYPE_PARCELS_1 = 1;
    uint8 private constant BUNDLE_TYPE_PARCELS_2 = 2;
    uint8 private constant BUNDLE_TYPE_PARCELS_3 = 3;
    uint8 private constant BUNDLE_TYPE_PARCELS_4 = 4;
    uint8 private constant BUNDLE_TYPE_PARCELS_5 = 5;
    uint8 private constant BUNDLE_TYPE_PARCELS_6 = 6;
    uint8 private constant BUNDLE_TYPE_MINERS_1 = 7;
    uint8 private constant BUNDLE_TYPE_MINERS_2 = 8;
    uint8 private constant BUNDLE_TYPE_MINERS_3 = 9;
    uint8 private constant BUNDLE_TYPE_MINERS_4 = 10;
    uint8 private constant BUNDLE_TYPE_MINERS_5 = 11;
    uint8 private constant BUNDLE_TYPE_MINERS_6 = 12;
    uint8 private constant BUNDLE_TYPE_SUPER_1 = 13;
    uint8 private constant BUNDLE_TYPE_SUPER_2 = 14;
    uint8 private constant BUNDLE_TYPE_SUPER_3 = 15;
    uint8 private constant BUNDLE_TYPE_SUPER_4 = 16;

    uint8 private constant PURCHASE_TYPE_MINER = 0;
    uint8 private constant PURCHASE_TYPE_PARCEL = 1;
    uint8 private constant PURCHASE_TYPE_BUNDLE = 2;
    uint8 private constant PURCHASE_TYPE_SUPER_BUNDLE = 3;
    uint8 private constant PURCHASE_TYPE_MINERS_BUNDLE = 5;
    uint8 private constant PURCHASE_TYPE_PARCELS_BUNDLE = 6;
    uint8 private constant PURCHASE_TYPE_UPGRADE_STANDARD_PARCEL = 7;
    uint8 private constant PURCHASE_TYPE_UPGRADE_STANDARD_PARCELS_GROUP = 8;
    uint8 private constant PURCHASE_TYPE_PARCELS = 9;
    uint8 private constant PURCHASE_TYPE_MINERS = 10;

    /// @notice Indicator if the sales can happen
    bool public isSaleActive;

    /// @notice Pricing information (in BUSD)
    uint256 public upgradePrice;
    uint256 public minerPrice;

    /// @notice Addresses of Gymstreet smart contracts
    address public standardParcelNFTAddress;
    address public minerV1NFTAddress;
    address public miningAddress;
    address public busdAddress;
    address public netGymStreetAddress;
    address public signatureValidatorAddress;
    address public amountsDistributorAddress;

    mapping(address => uint256) public userToPurchasedAmountMapping;

    /// @notice Parcels pricing changes per percentage
    uint256 public currentlySoldStandardParcelsCount;

    /// @notice Parcel <=> Miner attachments and Parcel/Miner properties
    mapping(uint256 => uint256[]) public parcelMinersMapping;
    mapping(uint256 => uint256) public minerParcelMapping;
    uint8 public standardParcelSlotsCount;
    uint8 public upgradedParcelSlotsCount;
    
    /// @notice Array of all available bundles
    BundleInfo[13] public newBundles;

    
    mapping(address => LastPurchaseData) public lastPurchaseData;
    SuperBundleInfo[4] public superBundlesInfos;
    mapping(address => UserMintableNFTAmounts) public usersMintableNFTAmounts;
    address public web2BackendAddress;
    address public signitureValidatorKBAddress;
    mapping(bytes => bool) public SeededUserSignature;

    // ------------------------------------ EVENTS ------------------------------------ //

    event BundlesSet(BundleInfo[13] indexed bundles);
    event SuperBundlesSet(SuperBundleInfo[4] indexed bundles);
    event ParcelsSlotsCountSet(
        uint8 indexed standardParcelSlotsCount,
        uint8 indexed upgradedParcelSlotsCount
    );
    event PurchasePricesSet(
        uint256 upgradePrice,
        uint256 minerPrice
    );
    event SaleActivationSet(bool indexed saleActivation);
    event BundlePurchased(address indexed user, uint256 indexed bundleType);
    event SuperBundlePurchased(address indexed user, uint256 indexed bundleType);
    event MinerAttached(address user, uint256 indexed parcelId, uint256 indexed minerId);
    event MinerDetached(address indexed user, uint256 indexed parcelId, uint256 indexed minerId);
    event NFTContractAddressesSet(address[7] indexed _nftContractAddresses);
    event PurchaseMade(address indexed user, uint8 indexed purchaseType, uint256[] nftId, uint256 purchasePrice);
    event NFTGranted(address indexed user, uint256 parcelsCount, uint256 minersCount, uint256 upgradesCount);
    event BalanceUpdated(address indexed user, uint256 parcelCount, uint256 minerCount, uint256 upgradeCount, bool isNegative);

    /// @notice Modifier for 0 address check
    modifier notZeroAddress() {
        require(address(0) != msg.sender, "Municipality: Caller can not be address 0");
        _;
    }

    /// @notice Modifier not to allow sales when it is made inactive
    modifier onlySaleActive() {
        require(isSaleActive, "Municipality: Sale is deactivated now");
        _;
    }

    /// @notice Access to only the miner public building
    modifier onlyWeb2Backend() {
        require(msg.sender == web2BackendAddress, "Municipality: This function is available only to a miner public building");
        _;
    }

    // @notice Proxy SC support - initialize internal state
    function initialize(
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    receive() external payable {}

    fallback() external payable {}

    /// @notice Public interface

    /// @notice Update bundles
    function setBundles(BundleInfo[13] calldata _bundles) external onlyOwner notZeroAddress {
        newBundles = _bundles;
        emit BundlesSet(_bundles);
    }

    function setCurrentlySoldStandardParcelsCount(uint256 _currentlySoldStandardParcelsCount) external onlyOwner {
        currentlySoldStandardParcelsCount = _currentlySoldStandardParcelsCount;
    }

    function getNewBundlesArray() external view returns(BundleInfo[13] memory) {
        return newBundles;
    }

    /// @notice Set Super Bundles
    function setSuperBundles(SuperBundleInfo[4] calldata _bundles) external onlyOwner notZeroAddress {
        superBundlesInfos = _bundles;
        emit SuperBundlesSet(_bundles);
    }

    function getSuperBundlesArray() external view returns(SuperBundleInfo[4] memory) {
        return superBundlesInfos;
    }

    function getBundles() external view returns (uint256[6][17] memory bundleStats) {
        BundleInfo[13] memory bundle = newBundles;
        SuperBundleInfo[4] memory superBundle = superBundlesInfos;
        for (uint8 i = 0; i < 17; i++) {
            if (i < 13) {
                (uint256 discountPrice, uint256 price) = _getPriceForBundle(i);
                bundleStats[i] = [i, bundle[i].parcelsAmount, bundle[i].minersAmount, 0, discountPrice, price];
            } else {
                (uint256 discountPrice, uint256 price) = _getPriceForSuperBundle(i);
                bundleStats[i] = [i, superBundle[i-13].parcelsAmount, superBundle[i-13].minersAmount, superBundle[i-13].upgradesAmount, discountPrice, price];
            }    
        }
    }

    /// @notice Set contract addresses for all NFTs we currently have
    /// @notice Get price for mintParcels and purchaseParcels for Gymnet use purposes
    /// returns  priceForMinting, priceForSinglePurchase, rawParcelsPrice
    function getPriceForPurchaseParcels (address _user, uint256 _parcelsCount) external view returns(uint256, uint256, uint256) {
        return _getPriceForPurchaseParcels (_user, _parcelsCount);
    }

    /// @notice Get price for mintMiners and purchaseMiners for Gymnet use purposes
    /// returns priceForMinting, priceForSinglePurchase, rawParcelsPrice
    function getPriceForPurchaseMiners(address _user, uint256 _minersCount) external view returns(uint256, uint256, uint256) {
        return _getPriceForPurchaseMiners(_user, _minersCount);
    }

    function setNFTContractAddresses(address[7] calldata _nftContractAddresses) external onlyOwner {
        standardParcelNFTAddress = _nftContractAddresses[0];
        minerV1NFTAddress = _nftContractAddresses[1];
        miningAddress = _nftContractAddresses[2];
        busdAddress = _nftContractAddresses[3];
        netGymStreetAddress = _nftContractAddresses[4];
        signatureValidatorAddress = _nftContractAddresses[5];
        amountsDistributorAddress = _nftContractAddresses[6];
        emit NFTContractAddressesSet(_nftContractAddresses);
    }
    
    function setWeb2BackendAddress(address _web2BackendAddress) external onlyOwner {
        web2BackendAddress = _web2BackendAddress;
    }

    /// @notice Set the number of slots available for the miners for standard and upgraded parcels
    function setParcelsSlotsCount(uint8[2] calldata _parcelsSlotsCount) external onlyOwner {
        standardParcelSlotsCount = _parcelsSlotsCount[0];
        upgradedParcelSlotsCount = _parcelsSlotsCount[1];

        emit ParcelsSlotsCountSet(_parcelsSlotsCount[0], _parcelsSlotsCount[1]);
    }

    /// @notice Set the prices for all different entities we currently sell
    function setPurchasePrices(uint256[2] calldata _purchasePrices) external onlyOwner {
        upgradePrice = _purchasePrices[0];
        minerPrice = _purchasePrices[1];

        emit PurchasePricesSet(
            _purchasePrices[0],
            _purchasePrices[1]
        );
    }

    /// @notice Activate/Deactivate sales
    function setSaleActivation(bool _saleActivation) external onlyOwner {
        isSaleActive = _saleActivation;
        emit SaleActivationSet(_saleActivation);
    }
    
    function setSignitureValidatorKBAddress (address _signitureValidatorKBAddress) external onlyOwner {
        signitureValidatorKBAddress = _signitureValidatorKBAddress;
    }

    function seedUserNFTBalance(SeededDataSignature memory _seedingSignature) external {
        require(!SeededUserSignature[_seedingSignature.signature], "Municipality: The balance of the curent user has been already seeded");
        require(ISignatureValidatorKB(signitureValidatorKBAddress).verifySigner(_seedingSignature), "Municipality: Not authorized signer");
        usersMintableNFTAmounts[msg.sender].parcels = _seedingSignature.seedingMintableNFTAmounts.parcels;
        usersMintableNFTAmounts[msg.sender].miners = _seedingSignature.seedingMintableNFTAmounts.miners;
        usersMintableNFTAmounts[msg.sender].upgrades = _seedingSignature.seedingMintableNFTAmounts.upgrades;
        SeededUserSignature[_seedingSignature.signature] = true;

    }

    // @notice (Purchase) Generic minting functionality for parcels, regardless the currency
    function mintParcels(ParcelsMintSignature calldata _mintingSignature, uint256 _referrerId)
        external
        onlySaleActive
        notZeroAddress
    {
        require(ISignatureValidator(signatureValidatorAddress).verifySigner(_mintingSignature), "Municipality: Not authorized signer");
        uint256 parcelsLength = _mintingSignature.parcels.length;
        require(parcelsLength > 0, "Municipality: Can not mint 0 parcels");
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        (uint256 price,,) = _getPriceForPurchaseParcels(msg.sender, parcelsLength);
        if(price > 0) {
            _transferToContract(price);
            IAmountsDistributor(amountsDistributorAddress).distributeAmounts(price, OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS, msg.sender);
            userToPurchasedAmountMapping[msg.sender] += price;
            _updateAdditionLevel(msg.sender);
            lastPurchaseData[msg.sender].dollarValue += price;
            _lastPurchaseDateUpdate(msg.sender);
            emit BalanceUpdated(msg.sender, usersMintableNFTAmounts[msg.sender].parcels, 0, 0, true);
            usersMintableNFTAmounts[msg.sender].parcels = 0;
        } else {
            usersMintableNFTAmounts[msg.sender].parcels -= parcelsLength;
            emit BalanceUpdated(msg.sender, parcelsLength, 0, 0, true);
        }
        uint256[] memory parcelIds = IParcelInterface(standardParcelNFTAddress).mintParcels(msg.sender, _mintingSignature.parcels);
        currentlySoldStandardParcelsCount += parcelsLength;
        if (price > 0) {
            emit PurchaseMade(msg.sender, PURCHASE_TYPE_PARCEL, parcelIds, price);
        }
    }

    // @notice (Purchase) Mint the given amount of miners
    function mintMiners(uint256 _count, uint256 _referrerId) external onlySaleActive notZeroAddress returns(uint256, uint256)
    {
        require(_count > 0, "Municipality: Can not mint 0 miners");
        INetGymStreet(netGymStreetAddress).addGymMlm(msg.sender, _referrerId);
        (uint256 price,,) = _getPriceForPurchaseMiners(msg.sender, _count);
        if(price > 0) {
            _transferToContract(price);
            userToPurchasedAmountMapping[msg.sender] += price;
            _updateAdditionLevel(msg.sender);
            lastPurchaseData[msg.sender].dollarValue += price;
            _lastPurchaseDateUpdate(msg.sender);
            IAmountsDistributor(amountsDistributorAddress).distributeAmounts(price, OPERATION_TYPE_MINT_MINERS, msg.sender);
            emit BalanceUpdated(msg.sender, 0, usersMintableNFTAmounts[msg.sender].miners, 0, true);
            usersMintableNFTAmounts[msg.sender].miners = 0;
        } else {
            usersMintableNFTAmounts[msg.sender].miners -= _count;
            emit BalanceUpdated(msg.sender, 0, _count, 0, true);
        }
        (uint256 firstMinerId, uint256 count) = IMinerNFT(minerV1NFTAddress).mintMiners(msg.sender, _count);
        uint256[] memory minerIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            minerIds[i] = firstMinerId + i;
        }
        if (price > 0) {
            emit PurchaseMade(msg.sender, PURCHASE_TYPE_MINER, minerIds, price);
        }
        return (firstMinerId, count);
    }

    ///@notice purchase Parcels balance (without minting) from Gymnet Side
    function purchaseParcels(uint256 _parcelsAmount, uint256 _referrerId) external onlySaleActive notZeroAddress {
        _purchaseParcels(_parcelsAmount, _referrerId, msg.sender);
    }

    ///@notice purchase Parcels balance (without minting) via Web2 
    function web2PurchaseParcels(uint256 _parcelsAmount, uint256 _referrerId, address _user) external onlySaleActive onlyWeb2Backend {
        _purchaseParcels(_parcelsAmount, _referrerId, _user);
    }


    ///@notice purchase Miners balance (without minting) from Gymnet Side
    function purchaseMiners(uint256 _minersCount, uint256 _referrerId) external onlySaleActive notZeroAddress {
        _purchaseMiners(_minersCount, _referrerId, msg.sender);
    }

    ///@notice purchase Miners balance (without minting) via Web2
    function web2PurchaseMiners(uint256 _minersCount, uint256 _referrerId, address _user) external onlySaleActive onlyWeb2Backend {
        _purchaseMiners(_minersCount, _referrerId, _user);
    }

    function purchaseBasicBundle(uint8 _bundleType, uint256 _referrerId) external onlySaleActive notZeroAddress {
        _purchaseBasicBundle(_bundleType, _referrerId, msg.sender);
    }

    ///@notice purchase basic bundle via web2
    function web2PurchaseBasicBundle(uint8 _bundleType, uint256 _referrerId, address _user) external onlySaleActive onlyWeb2Backend {
        _purchaseBasicBundle(_bundleType, _referrerId, _user);
    }
    
    function purchaseSuperBundle(uint8 _bundleType, uint256 _referrerId) external onlySaleActive notZeroAddress {
       _purchaseSuperBundle(_bundleType, _referrerId, msg.sender);
    }

    ///@notice purchase super bundle via web2
    function web2PurchaseSuperBundle(uint8 _bundleType, uint256 _referrerId, address _user) external onlySaleActive onlyWeb2Backend {
       _purchaseSuperBundle(_bundleType, _referrerId, _user);
    }

    function purchaseParcelsBundle(uint8 _bundleType, uint256 _referrerId) external onlySaleActive notZeroAddress {
        _purchaseParcelsBundle(_bundleType, _referrerId, msg.sender);
    }

    function web2PurchaseParcelsBundle(uint8 _bundleType, uint256 _referrerId, address _user) external onlySaleActive onlyWeb2Backend {
        _purchaseParcelsBundle(_bundleType, _referrerId, _user);
    }

    function purchaseMinersBundle(uint8 _bundleType, uint256 _referrerId) external onlySaleActive notZeroAddress {
        _purchaseMinersBundle(_bundleType, _referrerId, msg.sender);
    }

    function web2PurchaseMinersBundle(uint8 _bundleType, uint256 _referrerId, address _user) external onlySaleActive onlyWeb2Backend {
        _purchaseMinersBundle(_bundleType, _referrerId, _user);
    }

    // granting free NFTs and upgrades to selected user 
    function grantNFTs(uint256 _parcelsAmount, uint256 _minersAmount, uint256 _upgradesAmount, uint256 _referrerId, address _user) external onlyOwner {
        if(_referrerId != 0) {
            INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        }
        usersMintableNFTAmounts[_user].parcels += _parcelsAmount;
        usersMintableNFTAmounts[_user].miners += _minersAmount;
        usersMintableNFTAmounts[_user].upgrades += _upgradesAmount;
        emit NFTGranted(_user, _parcelsAmount,  _minersAmount, _upgradesAmount);
        emit BalanceUpdated(_user, _parcelsAmount, _minersAmount, _upgradesAmount, false);
    }
        
    // @notice Attach/Detach the miners
    function attachDetachMinersToParcel(uint256[] calldata minersToAttach, uint256 parcelId) external notZeroAddress {
        require(IERC721Base(standardParcelNFTAddress).exists(parcelId), "Municipality: Parcel doesnt exist");
        _requireMinersCountMatchingWithParcelSlots(parcelId, minersToAttach.length);
        require(
            IERC721Base(standardParcelNFTAddress).ownerOf(parcelId) == msg.sender,
            "Municipality: Invalid parcel owner"
        );
        IMinerNFT(minerV1NFTAddress).requireNFTsBelongToUser(minersToAttach, msg.sender);
        _attachDetachMinersToParcel(minersToAttach, parcelId);
    }

    /// @notice define the price for Parcels upgrade

    function getParcelsUpgradePrice(uint256 numParcels, address _user) external view returns(uint256) {
        uint256 _totalUpgradePrice;
        if(usersMintableNFTAmounts[_user].upgrades >= numParcels) {
            _totalUpgradePrice = 0;
        } else {
            _totalUpgradePrice = (numParcels - usersMintableNFTAmounts[_user].upgrades) * upgradePrice;
        }
        return _totalUpgradePrice;
    }
    

    /// @notice Upgrade a group of standard parcels
    function upgradeStandardParcelsGroup(uint256[] memory _parcelIds) external onlySaleActive {
        uint256 _totalUpgradePrice = _parcelIds.length * upgradePrice;
        uint256 upgradeBalanceChange;
        for(uint256 i = 0; i < _parcelIds.length; ++i) {
            require(
                IERC721Base(standardParcelNFTAddress).ownerOf(_parcelIds[i]) == msg.sender,
                "Municipality: Invalid NFT owner"
            );
            require(!IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelIds[i]),
                "Municipality: Parcel is already upgraded");
            if(usersMintableNFTAmounts[msg.sender].upgrades > 0) {
                usersMintableNFTAmounts[msg.sender].upgrades--;
                _totalUpgradePrice -= upgradePrice;
                upgradeBalanceChange++;
            }
        }
        if(_totalUpgradePrice > 0) {
            _transferToContract(_totalUpgradePrice);
            IAmountsDistributor(amountsDistributorAddress).distributeAmounts(_totalUpgradePrice, OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS, msg.sender);
            LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
            userToPurchasedAmountMapping[msg.sender] += _totalUpgradePrice;
            _updateAdditionLevel(msg.sender);
            lastPurchase.dollarValue += _totalUpgradePrice;
            _lastPurchaseDateUpdate(msg.sender);
        }
        IParcelInterface(standardParcelNFTAddress).upgradeParcels(_parcelIds);
        emit PurchaseMade(msg.sender, PURCHASE_TYPE_UPGRADE_STANDARD_PARCELS_GROUP, _parcelIds, _totalUpgradePrice);
        emit BalanceUpdated(msg.sender, 0, 0, upgradeBalanceChange, true);
    }

    /// @notice Upgrade the standard parcel
    function upgradeStandardParcel(uint256 _parcelId) external onlySaleActive {
        require(
            IERC721Base(standardParcelNFTAddress).ownerOf(_parcelId) == msg.sender,
            "Municipality: Invalid NFT owner"
        );
        bool isParcelUpgraded = IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelId);
        require(!isParcelUpgraded, "Municipality: Parcel is already upgraded");
        if(usersMintableNFTAmounts[msg.sender].upgrades > 0) {
            usersMintableNFTAmounts[msg.sender].upgrades--;
            emit BalanceUpdated(msg.sender, 0, 0, 1, true);
        } else {
            _transferToContract(upgradePrice);
            IAmountsDistributor(amountsDistributorAddress).distributeAmounts(upgradePrice, OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS, msg.sender);
            LastPurchaseData storage lastPurchase = lastPurchaseData[msg.sender];
            userToPurchasedAmountMapping[msg.sender] += upgradePrice;
            _updateAdditionLevel(msg.sender);
            lastPurchase.dollarValue += upgradePrice;
            _lastPurchaseDateUpdate(msg.sender);
        }
        IParcelInterface(standardParcelNFTAddress).upgradeParcel(_parcelId);
        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = _parcelId;
        emit PurchaseMade(msg.sender, PURCHASE_TYPE_UPGRADE_STANDARD_PARCEL, nftIds, upgradePrice);
    }

    function getPriceForSuperBundle(uint8 _bundleType) external view returns(uint256,uint256) {
        return _getPriceForSuperBundle(_bundleType);
    }

    function getPriceForBundle(uint8 _bundleType) external view returns(uint256, uint256) {
        return _getPriceForBundle(_bundleType);
    }

    function getUserPriceForParcels(address _user, uint256 _parcelsCount) external view returns(uint256) {
        return(_getUserPriceForParcels(_user, _parcelsCount));
    }

    function getUserPriceForMiners(address _user, uint256 _minersCount) external view returns(uint256) {
        return(_getUserPriceForMiners(_user, _minersCount));
    }
    // @notice App will use this function to get the price for the selected parcels
    function getPriceForParcels(Parcel[] calldata parcels) external view returns (uint256, uint256) {
        (uint256 price, uint256 unitPrice) = _getPriceForParcels(parcels.length);
        return (price, unitPrice);
    }
    
    function getUserMiners(address _user) external view returns (AttachedMiner[] memory) {
        uint256[] memory userMiners = IERC721Base(minerV1NFTAddress).tokensOf(_user);
        AttachedMiner[] memory result = new AttachedMiner[](userMiners.length);
        for (uint256 i = 0; i < userMiners.length; ++i) {
            uint256 minerId = userMiners[i];
            uint256 parcelId = minerParcelMapping[minerId];
            result[i] = AttachedMiner(parcelId, minerId);
        }
        return result;
    }
    // TODO: This function should be removed after 30 days from upgrade as the expiration date is in mapping lastPurchaseData
    function getNFTPurchaseExpirationDate(address _user) external view returns(uint256) {
        return lastPurchaseData[_user].expirationDate;
    }

    function isTokenLocked(address _tokenAddress, uint256 _tokenId) external view returns(bool) { 
        if(_tokenAddress == minerV1NFTAddress) {
            return minerParcelMapping[_tokenId] > 0;
        } else if(_tokenAddress == standardParcelNFTAddress) {
            return parcelMinersMapping[_tokenId].length > 0;
        } else {
            revert("Municipality: Unsupported NFT token address");
        }
    }

    /// @notice automatically attach free miners to parcels
    function automaticallyAttachMinersToParcels(uint256 numMiners) external {
        _automaticallyAttachMinersToParcels(
            IERC721Base(standardParcelNFTAddress).tokensOf(msg.sender),
            IERC721Base(minerV1NFTAddress).tokensOf(msg.sender),
            numMiners);
    }

    /// @notice Private interface
    function _purchaseMinersBundle(uint8 _bundleType, uint256 _referrerId, address _user) private {
        _validateMinersBundleType(_bundleType);
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        BundleInfo memory bundle = newBundles[_bundleType];
        (uint256 bundlePurchasePrice, ) = _getPriceForBundle(_bundleType);
        _transferToContract(bundlePurchasePrice);
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        userToPurchasedAmountMapping[_user] += bundlePurchasePrice;
        _updateAdditionLevel(_user);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(_user);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(bundlePurchasePrice, OPERATION_TYPE_MINT_MINERS, _user);
        usersMintableNFTAmounts[_user].miners += bundle.minersAmount;
        uint256[] memory nftIds = new uint256[](0);
        emit PurchaseMade(_user, PURCHASE_TYPE_MINERS_BUNDLE, nftIds, bundlePurchasePrice);
        emit BundlePurchased(_user, _bundleType);
        emit BalanceUpdated(_user, 0, bundle.minersAmount, 0, false);
    }

    function _purchaseParcelsBundle(uint8 _bundleType, uint256 _referrerId, address _user) private {
        _validateParcelsBundleType(_bundleType);
        BundleInfo memory bundle = newBundles[_bundleType];
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        (uint256 bundlePurchasePrice, ) = _getPriceForBundle(_bundleType);
        _transferToContract(bundlePurchasePrice);
        userToPurchasedAmountMapping[_user] += bundlePurchasePrice;
        _updateAdditionLevel(_user);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(_user);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(
            bundlePurchasePrice,
            OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS,
            _user
        );
        usersMintableNFTAmounts[_user].parcels += bundle.parcelsAmount;
        uint256[] memory nftIds = new uint256[](0);
        emit PurchaseMade(_user, PURCHASE_TYPE_PARCELS_BUNDLE, nftIds, bundlePurchasePrice);
        emit BundlePurchased(_user, _bundleType);
        emit BalanceUpdated(_user, bundle.parcelsAmount, 0, 0, false);
    }

    function _purchaseSuperBundle(uint8 _bundleType, uint256 _referrerId, address _user) private {
        _validateSuperBundleType(_bundleType);
        SuperBundleInfo memory bundle = superBundlesInfos[_bundleType - BUNDLE_TYPE_SUPER_1];
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        (uint256 bundlePurchasePrice,) = _getPriceForSuperBundle(_bundleType);
        _transferToContract(bundlePurchasePrice);
        userToPurchasedAmountMapping[_user] += bundlePurchasePrice;
        _updateAdditionLevel(_user);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(_user);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(
            bundlePurchasePrice,
            OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS,
            _user
        );
        usersMintableNFTAmounts[_user].parcels += bundle.parcelsAmount;
        usersMintableNFTAmounts[_user].upgrades += bundle.upgradesAmount;
        usersMintableNFTAmounts[_user].miners += bundle.minersAmount;
        uint256[] memory nftIds = new uint256[](0);
        emit PurchaseMade(_user, PURCHASE_TYPE_SUPER_BUNDLE, nftIds, bundlePurchasePrice);
        emit SuperBundlePurchased(_user, _bundleType);
        emit BalanceUpdated(_user, bundle.parcelsAmount, bundle.minersAmount, bundle.upgradesAmount, false);
    }

    function _purchaseBasicBundle(uint8 _bundleType, uint256 _referrerId, address _user) private {
        _validateBasicBundleType(_bundleType);
        BundleInfo memory bundle = newBundles[_bundleType];
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        (uint256 bundlePurchasePrice, ) = _getPriceForBundle(_bundleType);
        _transferToContract(bundlePurchasePrice);
        userToPurchasedAmountMapping[_user] += bundlePurchasePrice;
        _updateAdditionLevel(_user);
        lastPurchase.dollarValue += bundlePurchasePrice;
        _lastPurchaseDateUpdate(_user);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(
            bundlePurchasePrice,
            OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS,
            _user
        );
        usersMintableNFTAmounts[_user].parcels += bundle.parcelsAmount;
        usersMintableNFTAmounts[_user].miners += bundle.minersAmount;
        uint256[] memory nftIds = new uint256[](0);
        emit PurchaseMade(_user, PURCHASE_TYPE_BUNDLE, nftIds, bundlePurchasePrice);
        emit BundlePurchased(_user, _bundleType);
        emit BalanceUpdated(_user, bundle.parcelsAmount, bundle.minersAmount, 0, false);
    }

    function _purchaseParcels(uint256 _parcelsAmount, uint256 _referrerId, address _user) private {
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        (,uint256 priceForSinglePurchase, ) = _getPriceForPurchaseParcels(_user, _parcelsAmount);
        _transferToContract(priceForSinglePurchase);
        userToPurchasedAmountMapping[_user] += priceForSinglePurchase;
        _updateAdditionLevel(_user);
        lastPurchase.dollarValue += priceForSinglePurchase;
        _lastPurchaseDateUpdate(_user);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(
            priceForSinglePurchase,
            OPERATION_TYPE_MINT_OR_UPGRADE_PARCELS,
            _user
        );
        usersMintableNFTAmounts[_user].parcels += _parcelsAmount;
        uint256[] memory nftIds = new uint256[](0);
        emit PurchaseMade(_user, PURCHASE_TYPE_PARCELS, nftIds, priceForSinglePurchase);
        emit BalanceUpdated(_user, _parcelsAmount,0,0, false);
    }

    function _purchaseMiners(uint256 _minersCount, uint256 _referrerId, address _user) private {
        INetGymStreet(netGymStreetAddress).addGymMlm(_user, _referrerId);
        (,uint256 priceForSinglePurchase,) = _getPriceForPurchaseMiners(_user, _minersCount);
        _transferToContract(priceForSinglePurchase);
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        userToPurchasedAmountMapping[_user] += priceForSinglePurchase;
        _updateAdditionLevel(_user);
        lastPurchase.dollarValue += priceForSinglePurchase;
        _lastPurchaseDateUpdate(_user);
        IAmountsDistributor(amountsDistributorAddress).distributeAmounts(priceForSinglePurchase, OPERATION_TYPE_MINT_MINERS, _user);
        usersMintableNFTAmounts[_user].miners += _minersCount;
        uint256[] memory nftIds = new uint256[](0);
        emit PurchaseMade(_user, PURCHASE_TYPE_MINERS, nftIds, priceForSinglePurchase);
        emit BalanceUpdated(_user, 0, _minersCount, 0, false);
    }

    /// @notice Get price for mintParcels and purchaseParcels for Gymnet use purposes
    /// priceForMinting is used in mintParcels taking into account the unpaidCount if balance
    /// priceForSinglePurchase is used in purchaseParcels and Frontend to show the price of parcels that are going to be bought from gymnet and added as balance
    function _getPriceForPurchaseParcels (address _user, uint256 _parcelsCount) private view returns(uint256, uint256, uint256) {
        (uint256 rawParcelsPrice, ) = _getPriceForParcels(_parcelsCount);
        uint256 priceForMinting;
        if(usersMintableNFTAmounts[_user].parcels >= _parcelsCount)
            priceForMinting = 0;
        else {
            uint256 unpaidCount = _parcelsCount - usersMintableNFTAmounts[_user].parcels;
            (priceForMinting,) = _getPriceForParcels(unpaidCount);
            priceForMinting = _discountPrice(priceForMinting, _oldBundlePercentage(unpaidCount));
        }
        uint256 priceForSinglePurchase = _discountPrice(rawParcelsPrice, _oldBundlePercentage(_parcelsCount));
        return (priceForMinting, priceForSinglePurchase, rawParcelsPrice);
    }

    /// @notice Get price for mintMiners and purchaseMiners for Gymnet use purposes
    /// priceForMinting is used in mintMiners taking into account the unpaidCount if balance
    /// priceForSinglePurchase is used in purchaseMiners and Frontend to show the price of miners that are going to be bought from gymnet and added as balance
    function _getPriceForPurchaseMiners(address _user, uint256 _minersCount) private view returns(uint256, uint256, uint256) {
        uint256 rawMinersPrice = _minersCount * minerPrice;
        uint256 priceForMinting;
        if(usersMintableNFTAmounts[_user].miners >= _minersCount)
            priceForMinting = 0;
        else {
            uint256 unpaidCount = _minersCount - usersMintableNFTAmounts[_user].miners;
            priceForMinting = _discountPrice(minerPrice * unpaidCount, _oldBundlePercentage(unpaidCount));
        }
        uint256 priceForSinglePurchase = _discountPrice(rawMinersPrice,  _oldBundlePercentage(_minersCount));
        return (priceForMinting, priceForSinglePurchase, rawMinersPrice);
    }

    function _oldBundlePercentage(uint256 _count) private pure returns(uint256) {
        uint256 percentage;
        if(_count >= 240) {
        percentage = 18000;
        } else if(_count >= 140) {
            percentage = 16000;
        } else if(_count >= 80) {
            percentage = 12000;
        } else if(_count >= 40) {
            percentage = 10000;
        } else if(_count >= 10) {
            percentage = 8000;
        } else if(_count >= 4) {
            percentage = 5000;
        }
        return percentage; 
    }

    function _getPriceForSuperBundle(uint8 _bundleType) private view returns(uint256, uint256) {
        _validateSuperBundleType(_bundleType);
        SuperBundleInfo memory bundle = superBundlesInfos[_bundleType- BUNDLE_TYPE_SUPER_1];
        (uint256 parcelPrice, ) = _getPriceForParcels(bundle.parcelsAmount);
        uint256 bundlePrice = parcelPrice + bundle.minersAmount * minerPrice;
        return (_discountPrice(bundlePrice, bundle.discountPct), bundlePrice);
    }

    function _getPriceForBundle (uint8 _bundleType) private view returns(uint256, uint256) {
        BundleInfo memory bundle = newBundles[_bundleType];
        (uint256 parcelPrice, ) = _getPriceForParcels(bundle.parcelsAmount);
        uint256 bundlePrice = parcelPrice + bundle.minersAmount * minerPrice;
        return (_discountPrice(bundlePrice, bundle.discountPct), bundlePrice);
    }

    function _getUserPriceForParcels(address _user, uint256 _parcelsCount) private view returns(uint256) {
        if(usersMintableNFTAmounts[_user].parcels >= _parcelsCount)
            return 0;
        else {
            uint256 unpaidCount = _parcelsCount - usersMintableNFTAmounts[_user].parcels;
            (uint256 price,) = _getPriceForParcels(unpaidCount);
            uint256 percentage;
            if(unpaidCount >= 90) {
                percentage = 35187;
            } else if(unpaidCount >= 35) {
                percentage = 28577;
            } else if(unpaidCount >= 16) {
                percentage = 21875;
            } else if(unpaidCount >= 3) {
                percentage = 16667;
            }
            uint256 discountedPrice = _discountPrice(price, percentage);
            return discountedPrice;
        }
    }

    function _getUserPriceForMiners(address _user, uint256 _minersCount) private view returns(uint256) {
        if(usersMintableNFTAmounts[_user].miners >= _minersCount)
            return 0;
        else {
            uint256 unpaidCount = _minersCount - usersMintableNFTAmounts[_user].miners;
            uint256 price = unpaidCount * minerPrice;
            uint256 percentage;
            if(unpaidCount >= 360) {
                percentage = 35187;
            } else if(unpaidCount >= 140) {
                percentage = 28577;
            } else if(unpaidCount >= 64) {
                percentage = 21875;
            } else if(unpaidCount >= 12) {
                percentage = 16667;
            }
            uint256 discountedPrice = _discountPrice(price, percentage);
            return discountedPrice;
        }
    }

  
    
    function _automaticallyAttachMinersToParcels(uint256[] memory parcelIds, uint256[] memory userMiners, uint256 numMiners) private {
        uint256 lastAvailableMinerIndex = 0;
        for(uint256 i = 0; i < parcelIds.length && lastAvailableMinerIndex < userMiners.length && numMiners > 0; ++i) {
            uint256 availableSize = IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(parcelIds[i]) ?
                upgradedParcelSlotsCount - parcelMinersMapping[parcelIds[i]].length :
                standardParcelSlotsCount - parcelMinersMapping[parcelIds[i]].length;
            if(availableSize > 0) {
                for(uint256 j = 0; j < availableSize; ++j) {
                    if(numMiners != 0) {
                        for(uint256 k = lastAvailableMinerIndex; k < userMiners.length; ++k) {
                            lastAvailableMinerIndex = k + 1;
                            if(minerParcelMapping[userMiners[k]] == 0) {
                                parcelMinersMapping[parcelIds[i]].push(userMiners[k]);
                                minerParcelMapping[userMiners[k]] = parcelIds[i];
                                IMining(miningAddress).deposit(msg.sender, userMiners[k], 1000);
                                emit MinerAttached(msg.sender, parcelIds[i], userMiners[k]);
                                --numMiners;
                                break;
                            }
                        }

                    }
                }
            }
        }
    }

    /// @notice Transfers the given BUSD amount to distributor contract
    function _transferToContract(uint256 _amount) private {
        IERC20Upgradeable(busdAddress).safeTransferFrom(
            address(msg.sender),
            address(amountsDistributorAddress),
            _amount
        );
    }

    /// @notice Checks if the miner is in the given list
    function _isMinerInList(uint256 _tokenId, uint256[] memory _minersList) private pure returns (bool) {
        for (uint256 index; index < _minersList.length; index++) {
            if (_tokenId == _minersList[index]) {
                return true;
            }
        }
        return false;
    }

    /// @notice Validates if the bundle corresponds to a type from this smart contract
    function _validateBasicBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_PARCELS_MINERS_1,
            "Municipality: Invalid bundle type"
        );
    }
    function _validateSuperBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_SUPER_1 ||
            _bundleType == BUNDLE_TYPE_SUPER_2 ||
            _bundleType == BUNDLE_TYPE_SUPER_3 ||
            _bundleType == BUNDLE_TYPE_SUPER_4,
            "Municipality: Invalid super bundle type"
        );
    }

    function _validateParcelsBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_PARCELS_1 ||
            _bundleType == BUNDLE_TYPE_PARCELS_2 ||
            _bundleType == BUNDLE_TYPE_PARCELS_3 ||
            _bundleType == BUNDLE_TYPE_PARCELS_4 ||
            _bundleType == BUNDLE_TYPE_PARCELS_5 ||
            _bundleType == BUNDLE_TYPE_PARCELS_6,
            "Municipality: Invalid bundle type"
        );
    }

    /// @notice Validates if the bundle corresponds to a type from this smart contract
    function _validateMinersBundleType(uint8 _bundleType) private pure {
        require
        (
            _bundleType == BUNDLE_TYPE_MINERS_1 ||
            _bundleType == BUNDLE_TYPE_MINERS_2 ||
            _bundleType == BUNDLE_TYPE_MINERS_3 ||
            _bundleType == BUNDLE_TYPE_MINERS_4 ||
            _bundleType == BUNDLE_TYPE_MINERS_5 ||
            _bundleType == BUNDLE_TYPE_MINERS_6,
            "Municipality: Invalid bundle type"
        );
    }

    /// @notice Requires the miner status to match with the given by a function argument status
    function _requireMinerStatus(uint256 miner, uint8 status, uint256 attachedParcelId) private view {
        if (status == MINER_STATUS_ATTACHED) {
            require(minerParcelMapping[miner] == attachedParcelId, "Municipality: Miner not attached to this parcel");
        } else if (status == MINER_STATUS_DETACHED) {
            uint256 attachedParcel = minerParcelMapping[miner];
            require(attachedParcel == 0, "Municipality: Miner is not detached");
        }
    }

    /// @notice Attach or detach the miners from/to parcel
    function _attachDetachMinersToParcel(uint256[] memory newMiners, uint256 parcelId) private {
        uint256[] memory oldMiners = parcelMinersMapping[parcelId];
        for (uint256 index; index < oldMiners.length; index++) {
            uint256 tokenId = oldMiners[index];
            if (!_isMinerInList(tokenId, newMiners)) {
                _requireMinerStatus(tokenId, MINER_STATUS_ATTACHED, parcelId);
                minerParcelMapping[tokenId] = 0;
                IMining(miningAddress).withdraw(msg.sender,tokenId);
                emit MinerDetached(msg.sender, parcelId, tokenId);
            }
        }
        uint256 minerHashrate = IMinerNFT(minerV1NFTAddress).hashrate();
        for (uint256 index; index < newMiners.length; index++) {
            uint256 tokenId = newMiners[index];
            if (!_isMinerInList(tokenId, oldMiners)) {
                _requireMinerStatus(tokenId, MINER_STATUS_DETACHED, parcelId);
                minerParcelMapping[tokenId] = parcelId;
                IMining(miningAddress).deposit(msg.sender, tokenId, minerHashrate);
                emit MinerAttached(msg.sender, parcelId, tokenId);
            }
        }
        parcelMinersMapping[parcelId] = newMiners;
    }

    /// @notice Require that the count of the miners match with the slots that are on a parcel (4 or 10)
    function _requireMinersCountMatchingWithParcelSlots(uint256 _parcelId, uint256 _count)
        private
        view
    {
        bool isParcelUpgraded = IParcelInterface(standardParcelNFTAddress).isParcelUpgraded(_parcelId);
        require(
            isParcelUpgraded
                ? _count <= upgradedParcelSlotsCount
                : _count <= standardParcelSlotsCount,
            "Municipality: Miners count exceeds parcel's slot count"
        );
    }

    /// @notice Returns the price of a given parcels
    function _getPriceForParcels(uint256 parcelsCount) private view returns (uint256, uint256) {
        uint256 price = parcelsCount * 100000000000000000000;
        uint256 unitPrice = 100000000000000000000;
        uint256 priceBefore = 0;
        uint256 totalParcelsToBuy = currentlySoldStandardParcelsCount + parcelsCount;
        if(totalParcelsToBuy > 240000) {
            unitPrice = 301000000000000000000;
            if (currentlySoldStandardParcelsCount > 240000) {
                price = parcelsCount * 301000000000000000000;
            } else {
                price = (parcelsCount + currentlySoldStandardParcelsCount - 240000) * 301000000000000000000;
                priceBefore = (240000 - currentlySoldStandardParcelsCount) * 209000000000000000000;
            }
        } else if(totalParcelsToBuy > 160000) {
            unitPrice = 209000000000000000000;
             if (currentlySoldStandardParcelsCount > 160000) {
                price = parcelsCount * 209000000000000000000;
            } else {
                price = (parcelsCount + currentlySoldStandardParcelsCount - 160000) * 209000000000000000000;
                priceBefore = (160000 - currentlySoldStandardParcelsCount) * 144000000000000000000;
            }
        } else if(totalParcelsToBuy > 80000) {
            unitPrice = 144000000000000000000;
            if (currentlySoldStandardParcelsCount > 80000) {
                price = parcelsCount * 144000000000000000000;
            } else {
                price = (parcelsCount + currentlySoldStandardParcelsCount - 80000) * 144000000000000000000;
                priceBefore = (80000 - currentlySoldStandardParcelsCount) * 116000000000000000000;
            }
        } else if(totalParcelsToBuy > 32000) {
             unitPrice = 116000000000000000000;
            if (currentlySoldStandardParcelsCount > 32000) {
                price = parcelsCount * 116000000000000000000; 
            } else {
                price = (parcelsCount + currentlySoldStandardParcelsCount - 32000) * 116000000000000000000;
                priceBefore = (32000 - currentlySoldStandardParcelsCount) * 100000000000000000000;
            }
            
        }
        return (priceBefore + price, unitPrice);
    }

    /// @notice Returns the discounted price of the bundle
    function _discountPrice(uint256 _price, uint256 _percentage) private pure returns (uint256) {
        return _price - (_price * _percentage) / 100000;
    }

     /**
     * @notice Private function to update additional level in GymStreet
     * @param _user: user address
     */
    function _updateAdditionLevel(address _user) private {
        uint256 _additionalLevel;
        (uint256 termTimestamp, uint256 _gymLevel) = INetGymStreet(netGymStreetAddress).getInfoForAdditionalLevel(_user);
        // if (termTimestamp + 2505600 > block.timestamp){ // 30 days
            uint256[] memory sb = new uint256[](4);
            for (uint8 i = 0; i < 4; i++) {
                (sb[i], ) = _getPriceForSuperBundle(i+13);
            }
            if (userToPurchasedAmountMapping[_user] >= sb[3]) {
                _additionalLevel = 21;
            } else if (userToPurchasedAmountMapping[_user] >= sb[2]) {
                _additionalLevel = 14;
            } else if (userToPurchasedAmountMapping[_user] >= sb[1]) {
                _additionalLevel = 9;
            } else if (userToPurchasedAmountMapping[_user] >= sb[0]) {
                _additionalLevel = 5;
            }  

            if (_additionalLevel > _gymLevel) {
            INetGymStreet(netGymStreetAddress).updateAdditionalLevel(_user, _additionalLevel);
            }
        // }
    }

    /**
     * @notice Private function to update last purchase date
     * @param _user: user address
     */
    function _lastPurchaseDateUpdate(address _user) private {
        LastPurchaseData storage lastPurchase = lastPurchaseData[_user];
        lastPurchase.lastPurchaseDate = block.timestamp;
        if (lastPurchase.dollarValue >= (100 * 1e18)) {
            lastPurchase.expirationDate = lastPurchase.lastPurchaseDate + 30 days;
            lastPurchase.dollarValue = 0;     
        }
    }
}

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Municipality.sol";

pragma solidity ^0.8.15;

contract SignatureValidator is OwnableUpgradeable, ReentrancyGuardUpgradeable, EIP712Upgradeable {

    string private constant SIGNING_DOMAIN = "SIGNATURE_VALIDATOR";
    string private constant SIGNATURE_VERSION = "1";

    address private ourSignerAddress;
    address public municipalityAddress;

    modifier onlyMunicipality() {
        require(msg.sender == municipalityAddress, "SignatureValidator: Only Municipality contract is authorized to call this function");
        _;
    }

    function initialize(
        address _ourSignerAddress
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __EIP712_init(SIGNING_DOMAIN, SIGNATURE_VERSION);
        ourSignerAddress = _ourSignerAddress;
    }

    function setMunicipalityAddress(address _municipalityAddress) external onlyOwner {
        municipalityAddress = _municipalityAddress;
    }

    function setSignerAddress(address  _ourSignerAddress) external onlyOwner {
        ourSignerAddress = _ourSignerAddress;
    }

    function verifySigner(Municipality.ParcelsMintSignature memory mintParcelSignature) external  view onlyMunicipality returns (bool){
        require(
            mintParcelSignature.parcels.length == mintParcelSignature.signatures.length,
            "SignatureValidator: Number of signuatures does not match number of parcels"
        );
        for (uint256 index; index < mintParcelSignature.parcels.length; index++) {
            bytes32 _digest = _hash(mintParcelSignature.parcels[index]);
            address signer = ECDSAUpgradeable.recover(
                _digest,
                mintParcelSignature.signatures[index]
            );
            if(signer != ourSignerAddress) {
                return false;
            }
        }
        return true;
    }

    function _hash(Municipality.Parcel memory parcel) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "Parcel(uint16 x,uint16 y,uint8 parcelType,uint8 parcelLandType)"
                        ),
                        parcel
                    )
                )
            );
    }
}