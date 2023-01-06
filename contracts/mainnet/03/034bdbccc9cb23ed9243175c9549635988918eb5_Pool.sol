/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

uint256 constant POS = 1;
uint256 constant NEG = 0;

/// SignedInt is integer number with sign. It value range is -(2 ^ 256 - 1) to (2 ^ 256 - 1)
struct SignedInt {
    /// @dev sig = 1 -> positive, sig = 0 is negative
    /// using uint256 which take up full word to optimize gas and contract size
    uint256 sig;
    uint256 abs;
}

library SignedIntOps {
    function add(SignedInt memory a, SignedInt memory b) internal pure returns (SignedInt memory) {
        if (a.sig == b.sig) {
            return SignedInt({sig: a.sig, abs: a.abs + b.abs});
        }

        if (a.abs == b.abs) {
            return SignedInt(POS, 0); // always return positive zero
        }

        unchecked {
            (uint256 sig, uint256 abs) = a.abs > b.abs ? (a.sig, a.abs - b.abs) : (b.sig, b.abs - a.abs);
            return SignedInt(sig, abs);
        }
    }

    function inv(SignedInt memory a) internal pure returns (SignedInt memory) {
        return a.abs == 0 ? a : (SignedInt({sig: 1 - a.sig, abs: a.abs}));
    }

    function sub(SignedInt memory a, SignedInt memory b) internal pure returns (SignedInt memory) {
        return add(a, inv(b));
    }

    function mul(SignedInt memory a, SignedInt memory b) internal pure returns (SignedInt memory) {
        uint256 sig = (a.sig + b.sig + 1) % 2;
        uint256 abs = a.abs * b.abs;
        return SignedInt(abs == 0 ? POS : sig, abs); // zero is alway positive
    }

    function div(SignedInt memory a, SignedInt memory b) internal pure returns (SignedInt memory) {
        uint256 sig = (a.sig + b.sig + 1) % 2;
        uint256 abs = a.abs / b.abs;
        return SignedInt(sig, abs);
    }

    function add(SignedInt memory a, uint256 b) internal pure returns (SignedInt memory) {
        return add(a, wrap(b));
    }

    function sub(SignedInt memory a, uint256 b) internal pure returns (SignedInt memory) {
        return sub(a, wrap(b));
    }

    function mul(SignedInt memory a, uint256 b) internal pure returns (SignedInt memory) {
        return mul(a, wrap(b));
    }

    function div(SignedInt memory a, uint256 b) internal pure returns (SignedInt memory) {
        return div(a, wrap(b));
    }

    function wrap(uint256 a) internal pure returns (SignedInt memory) {
        return SignedInt(POS, a);
    }

    function toUint(SignedInt memory a) internal pure returns (uint256) {
        require(a.sig == POS, "SignedInt: below zero");
        return a.abs;
    }

    function gt(SignedInt memory a, uint256 b) internal pure returns (bool) {
        return a.sig == POS && a.abs > b;
    }

    function lt(SignedInt memory a, uint256 b) internal pure returns (bool) {
        return a.sig == NEG || a.abs < b;
    }

    function isNeg(SignedInt memory a) internal pure returns (bool) {
        return a.sig == NEG;
    }

    function isPos(SignedInt memory a) internal pure returns (bool) {
        return a.sig == POS;
    }

    function frac(SignedInt memory a, uint256 num, uint256 denom) internal pure returns (SignedInt memory) {
        return div(mul(a, num), denom);
    }
}

library MathUtils {
    function diff(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a > b ? a - b : b - a;
        }
    }

    function zeroCapSub(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a > b ? a - b : 0;
        }
    }

    function frac(uint256 amount, uint256 num, uint256 denom) internal pure returns (uint256) {
        return amount * num / denom;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function addThenSubWithFraction(uint256 orig, uint256 add, uint256 sub, uint256 num, uint256 denum)
        internal
        pure
        returns (uint256)
    {
        return zeroCapSub(orig + MathUtils.frac(add, num, denum), MathUtils.frac(sub, num, denum));
    }
}

enum Side {
    LONG,
    SHORT
}

struct TokenWeight {
    address token;
    uint256 weight;
}

interface IPool {
    function increasePosition(
        address _account,
        address _indexToken,
        address _collateralToken,
        uint256 _sizeChanged,
        Side _side
    ) external;

    function decreasePosition(
        address _account,
        address _indexToken,
        address _collateralToken,
        uint256 _desiredCollateralReduce,
        uint256 _sizeChanged,
        Side _side,
        address _receiver
    ) external;

    function liquidatePosition(address _account, address _indexToken, address _collateralToken, Side _side) external;

    function validateToken(address indexToken, address collateralToken, Side side, bool isIncrease)
        external
        view
        returns (bool);

    function swap(address _tokenIn, address _tokenOut, uint256 _minOut, address _to, bytes calldata extradata)
        external;

    function addLiquidity(address _tranche, address _token, uint256 _amountIn, uint256 _minLpAmount, address _to)
        external;

    function removeLiquidity(address _tranche, address _tokenOut, uint256 _lpAmount, uint256 _minOut, address _to)
        external;

    // =========== EVENTS ===========
    event SetOrderManager(address indexed orderManager);
    event IncreasePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralValue,
        uint256 sizeChanged,
        Side side,
        uint256 indexPrice,
        uint256 feeValue
    );
    event UpdatePosition(
        bytes32 indexed key,
        uint256 size,
        uint256 collateralValue,
        uint256 entryPrice,
        uint256 entryInterestRate,
        uint256 reserveAmount,
        uint256 indexPrice
    );
    event DecreasePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        uint256 collateralChanged,
        uint256 sizeChanged,
        Side side,
        uint256 indexPrice,
        SignedInt pnl,
        uint256 feeValue
    );
    event ClosePosition(
        bytes32 indexed key,
        uint256 size,
        uint256 collateralValue,
        uint256 entryPrice,
        uint256 entryInterestRate,
        uint256 reserveAmount
    );
    event LiquidatePosition(
        bytes32 indexed key,
        address account,
        address collateralToken,
        address indexToken,
        Side side,
        uint256 size,
        uint256 collateralValue,
        uint256 reserveAmount,
        uint256 indexPrice,
        SignedInt pnl,
        uint256 feeValue
    );
    event DaoFeeWithdrawn(address indexed token, address recipient, uint256 amount);
    event DaoFeeReduced(address indexed token, uint256 amount);
    event FeeDistributorSet(address indexed feeDistributor);
    event LiquidityAdded(
        address indexed tranche, address indexed sender, address token, uint256 amount, uint256 lpAmount, uint256 fee
    );
    event LiquidityRemoved(
        address indexed tranche, address indexed sender, address token, uint256 lpAmount, uint256 amountOut, uint256 fee
    );
    event TokenWeightSet(TokenWeight[]);
    event Swap(
        address indexed sender, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut, uint256 fee
    );
    event PositionFeeSet(uint256 positionFee, uint256 liquidationFee);
    event DaoFeeSet(uint256 value);
    event SwapFeeSet(
        uint256 baseSwapFee, uint256 taxBasisPoint, uint256 stableCoinBaseSwapFee, uint256 stableCoinTaxBasisPoint
    );
    event InterestAccrued(address indexed token, uint256 borrowIndex);
    event MaxLeverageChanged(uint256 maxLeverage);
    event TokenWhitelisted(address indexed token);
    event TokenDelisted(address indexed token);
    event OracleChanged(address indexed oldOracle, address indexed newOracle);
    event InterestRateSet(uint256 interestRate, uint256 interval);
    event MaxPositionSizeSet(uint256 maxPositionSize);
    event PoolHookChanged(address indexed hook);
    event TrancheAdded(address indexed lpToken);
    event TokenRiskFactorUpdated(address indexed token);
    event PnLDistributed(address indexed asset, address indexed tranche, uint256 amount, bool hasProfit);
    event MaintenanceMarginChanged(uint256 ratio);
    event AddRemoveLiquidityFeeSet(uint256 value);
}

library PositionUtils {
    using SignedIntOps for SignedInt;

    function calcPnl(Side _side, uint256 _positionSize, uint256 _entryPrice, uint256 _indexPrice)
        internal
        pure
        returns (SignedInt memory)
    {
        if (_positionSize == 0) {
            return SignedIntOps.wrap(uint256(0));
        }
        if (_side == Side.LONG) {
            return SignedIntOps.wrap(_indexPrice).sub(_entryPrice).mul(_positionSize).div(_entryPrice);
        } else {
            return SignedIntOps.wrap(_entryPrice).sub(_indexPrice).mul(_positionSize).div(_entryPrice);
        }
    }

    /// @notice calculate new avg entry price when increase position
    /// @dev for longs: nextAveragePrice = (nextPrice * nextSize)/ (nextSize + delta)
    ///      for shorts: nextAveragePrice = (nextPrice * nextSize) / (nextSize - delta)
    function calcAveragePrice(
        Side _side,
        uint256 _lastSize,
        uint256 _nextSize,
        uint256 _entryPrice,
        uint256 _nextPrice,
        SignedInt memory _realizedPnL
    ) internal pure returns (uint256) {
        if (_nextSize == 0) {
            return 0;
        }
        if (_lastSize == 0) {
            return _nextPrice;
        }
        SignedInt memory pnl = calcPnl(_side, _lastSize, _entryPrice, _nextPrice).sub(_realizedPnL);
        SignedInt memory nextSize = SignedIntOps.wrap(_nextSize);
        SignedInt memory divisor = _side == Side.LONG ? nextSize.add(pnl) : nextSize.sub(pnl);
        return nextSize.mul(_nextPrice).div(divisor).toUint();
    }
}

interface ILevelOracle {
    function getPrice(address token, bool max) external view returns (uint256);
    function getMultiplePrices(address[] calldata tokens, bool max) external view returns (uint256[] memory);
}

interface ILPToken is IERC20 {
    function mint(address to, uint amount) external;

    function burnFrom(address account, uint256 amount) external;
}

interface IPoolHook {
    function postIncreasePosition(
        address owner,
        address indexToken,
        address collateralToken,
        Side side,
        bytes calldata extradata
    ) external;

    function postDecreasePosition(
        address owner,
        address indexToken,
        address collateralToken,
        Side side,
        bytes calldata extradata
    ) external;

    function postLiquidatePosition(
        address owner,
        address indexToken,
        address collateralToken,
        Side side,
        bytes calldata extradata
    ) external;

    function postSwap(address user, address tokenIn, address tokenOut, bytes calldata data) external;

    event PreIncreasePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PostIncreasePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PreDecreasePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PostDecreasePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PreLiquidatePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );
    event PostLiquidatePositionExecuted(
        address pool, address owner, address indexToken, address collateralToken, Side side, bytes extradata
    );

    event PostSwapExecuted(address pool, address user, address tokenIn, address tokenOut, bytes data);
}

// common precision for fee, tax, interest rate, maintenace margin ratio
uint256 constant PRECISION = 1e10;
uint256 constant LP_INITIAL_PRICE = 1e12; // fix to 1$
uint256 constant MAX_BASE_SWAP_FEE = 1e8; // 1%
uint256 constant MAX_TAX_BASIS_POINT = 1e8; // 1%
uint256 constant MAX_POSITION_FEE = 1e8; // 1%
uint256 constant MAX_LIQUIDATION_FEE = 10e30; // 10$
uint256 constant MAX_TRANCHES = 3;
uint256 constant MAX_ASSETS = 10;
uint256 constant MAX_INTEREST_RATE = 1e7; // 0.1%
uint256 constant MAX_MAINTENANCE_MARGIN = 5e8; // 5%

struct Fee {
    /// @notice charge when changing position size
    uint256 positionFee;
    /// @notice charge when liquidate position (in dollar)
    uint256 liquidationFee;
    /// @notice swap fee used when add/remove liquidity, swap token
    uint256 baseSwapFee;
    /// @notice tax used to adjust swapFee due to the effect of the action on token's weight
    /// It reduce swap fee when user add some amount of a under weight token to the pool
    uint256 taxBasisPoint;
    /// @notice swap fee used when add/remove liquidity, swap token
    uint256 stableCoinBaseSwapFee;
    /// @notice tax used to adjust swapFee due to the effect of the action on token's weight
    /// It reduce swap fee when user add some amount of a under weight token to the pool
    uint256 stableCoinTaxBasisPoint;
    /// @notice part of fee will be kept for DAO, the rest will be distributed to pool amount, thus
    /// increase the pool value and the price of LP token
    uint256 daoFee;
}

struct Position {
    /// @dev contract size is evaluated in dollar
    uint256 size;
    /// @dev collateral value in dollar
    uint256 collateralValue;
    /// @dev contract size in indexToken
    uint256 reserveAmount;
    /// @dev average entry price
    uint256 entryPrice;
    /// @dev last cumulative interest rate
    uint256 borrowIndex;
}

struct PoolTokenInfo {
    /// @notice amount reserved for fee
    uint256 feeReserve;
    /// @notice recorded balance of token in pool
    uint256 poolBalance;
    /// @notice last borrow index update timestamp
    uint256 lastAccrualTimestamp;
    /// @notice accumulated interest rate
    uint256 borrowIndex;
    /// @notice average entry price of all short position
    /// @deprecated avg short price must be calculate per tranche
    uint256 averageShortPrice;
}

struct AssetInfo {
    /// @notice amount of token deposited (via add liquidity or increase long position)
    uint256 poolAmount;
    /// @notice amount of token reserved for paying out when user decrease long position
    uint256 reservedAmount;
    /// @notice total borrowed (in USD) to leverage
    uint256 guaranteedValue;
    /// @notice total size of all short positions
    uint256 totalShortSize;
}

abstract contract PoolStorage {
    Fee public fee;

    address public feeDistributor;

    ILevelOracle public oracle;

    address public orderManager;

    // ========= Assets management =========
    mapping(address => bool) public isAsset;
    /// @notice A list of all configured assets
    /// @dev use a pseudo address for ETH
    /// Note that token will not be removed from this array when it was delisted. We keep this
    /// list to calculate pool value properly
    address[] public allAssets;

    mapping(address => bool) public isListed;

    mapping(address => bool) public isStableCoin;

    mapping(address => PoolTokenInfo) public poolTokens;

    /// @notice target weight for each tokens
    mapping(address => uint256) public targetWeights;

    mapping(address => bool) public isTranche;
    /// @notice risk factor of each token in each tranche
    /// @dev token => tranche => risk factor
    mapping(address => mapping(address => uint256)) public riskFactor;
    /// @dev token => total risk score
    mapping(address => uint256) public totalRiskFactor;

    address[] public allTranches;
    /// @dev tranche => token => asset info
    mapping(address => mapping(address => AssetInfo)) public trancheAssets;
    /// @notice position reserve in each tranche
    mapping(address => mapping(bytes32 => uint256)) public tranchePositionReserves;

    /// @notice interest rate model
    uint256 public interestRate;

    uint256 public accrualInterval;

    uint256 public totalWeight;
    // ========= Positions management =========
    /// @notice max leverage for each token
    uint256 public maxLeverage;
    /// @notice positions tracks all open positions
    mapping(bytes32 => Position) public positions;

    IPoolHook public poolHook;

    uint256 public maintenanceMargin;

    uint256 public addRemoveLiquidityFee;

    mapping(address => mapping(address => uint)) public averageShortPrices;
}

library PoolErrors {
    error UpdateCauseLiquidation();
    error InvalidTokenPair(address index, address collateral);
    error InvalidLeverage(uint256 size, uint256 margin, uint256 maxLeverage);
    error InvalidPositionSize();
    error OrderManagerOnly();
    error UnknownToken(address token);
    error AssetNotListed(address token);
    error InsufficientPoolAmount(address token);
    error ReserveReduceTooMuch(address token);
    error SlippageExceeded();
    error ValueTooHigh(uint256 maxValue);
    error InvalidInterval();
    error PositionNotLiquidated(bytes32 key);
    error ZeroAmount();
    error ZeroAddress();
    error RequireAllTokens();
    error DuplicateToken(address token);
    error FeeDistributorOnly();
    error InvalidMaxLeverage();
    error SameTokenSwap(address token);
    error InvalidTranche(address tranche);
    error TrancheAlreadyAdded(address tranche);
    error RemoveLiquidityTooMuch(address tranche, uint256 outAmount, uint256 trancheBalance);
    error CannotDistributeToTranches(
        address indexToken, address collateralToken, uint256 amount, bool CannotDistributeToTranches
    );
    error CannotSetRiskFactorForStableCoin(address token);
    error PositionNotExists(address owner, address indexToken, address collateralToken, Side side);
    error MaxNumberOfTranchesReached();
    error TooManyTokenAdded(uint256 number, uint256 max);
    error AddLiquidityNotAllowed(address tranche, address token);
}

struct IncreasePositionVars {
    uint256 reserveAdded;
    uint256 collateralAmount;
    uint256 collateralValueAdded;
    uint256 feeValue;
    uint256 daoFee;
    uint256 indexPrice;
    uint256 sizeChanged;
}

/// @notice common variable used accross decrease process
struct DecreasePositionVars {
    /// @notice santinized input: collateral value able to be withdraw
    uint256 collateralReduced;
    /// @notice santinized input: position size to decrease, caped to position's size
    uint256 sizeChanged;
    /// @notice current price of index
    uint256 indexPrice;
    /// @notice current price of collateral
    uint256 collateralPrice;
    /// @notice postion's remaining collateral value in USD after decrease position
    uint256 remainingCollateral;
    /// @notice reserve reduced due to reducion process
    uint256 reserveReduced;
    /// @notice total value of fee to be collect (include dao fee and LP fee)
    uint256 feeValue;
    /// @notice amount of collateral taken as fee
    uint256 daoFee;
    /// @notice real transfer out amount to user
    uint256 payout;
    SignedInt pnl;
    SignedInt poolAmountReduced;
}

contract Pool is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PoolStorage, IPool {
    using SignedIntOps for SignedInt;
    using SafeERC20 for IERC20;

    /* =========== MODIFIERS ========== */
    modifier onlyOrderManager() {
        _requireOrderManager();
        _;
    }

    modifier onlyAsset(address _token) {
        _validateAsset(_token);
        _;
    }

    modifier onlyListedToken(address _token) {
        _requireListedToken(_token);
        _;
    }

    /* ======== INITIALIZERS ========= */
    // comment out these statement to gain some space. This functions is not relevant anymore
    // function initialize(
    //     uint256 _maxLeverage,
    //     uint256 _positionFee,
    //     uint256 _liquidationFee,
    //     uint256 _interestRate,
    //     uint256 _accrualInterval,
    //     uint256 _maintainanceMargin
    // ) external initializer {
    //     __Ownable_init();
    //     __ReentrancyGuard_init();
    //     _setMaxLeverage(_maxLeverage);
    //     _setPositionFee(_positionFee, _liquidationFee);
    //     _setInterestRate(_interestRate, _accrualInterval);
    //     _setMaintenanceMargin(_maintainanceMargin);
    //     fee.daoFee = PRECISION;
    // }

    function init_fixShortPrice() external reinitializer(4) {
        for (uint256 i = 0; i < allTranches.length; i++) {
            address tranche = allTranches[i];
            for (uint256 j = 0; j < allAssets.length; j++) {
                address token = allAssets[j];
                if (!isStableCoin[token] && trancheAssets[tranche][token].totalShortSize != 0) {
                    averageShortPrices[tranche][token] = poolTokens[token].averageShortPrice;
                }
            }
        }
    }

    // ========= View functions =========

    function validateToken(address _indexToken, address _collateralToken, Side _side, bool _isIncrease)
        external
        view
        returns (bool)
    {
        return _validateToken(_indexToken, _collateralToken, _side, _isIncrease);
    }

    function getPoolAsset(address _token) external view returns (AssetInfo memory) {
        return _getPoolAsset(_token);
    }

    function getAllTranchesLength() external view returns (uint256) {
        return allTranches.length;
    }

    function getPoolValue(bool _max) external view returns (uint256) {
        return _getPoolValue(_max);
    }

    function getTrancheValue(address _tranche, bool _max) external view returns (uint256 sum) {
        _validateTranche(_tranche);
        return _getTrancheValue(_tranche, _max);
    }

    function calcSwapOutput(address _tokenIn, address _tokenOut, uint256 _amountIn)
        external
        view
        returns (uint256 amountOut, uint256 feeAmount)
    {
        return _calcSwapOutput(_tokenIn, _tokenOut, _amountIn);
    }

    function calcRemoveLiquidity(address _tranche, address _tokenOut, uint256 _lpAmount)
        external
        view
        returns (uint256 outAmount, uint256 outAmountAfterFee, uint256 feeAmount)
    {
        return _calcRemoveLiquidity(_tranche, _tokenOut, _lpAmount);
    }

    // ============= Mutative functions =============

    function addLiquidity(address _tranche, address _token, uint256 _amountIn, uint256 _minLpAmount, address _to)
        external
        nonReentrant
        onlyListedToken(_token)
    {
        _validateTranche(_tranche);
        _accrueInterest(_token);
        _amountIn = _requireAmount(_transferIn(_token, _amountIn));

        (uint256 amountInAfterFee, uint256 daoFee, uint256 lpAmount) = _calcAddLiquidity(_tranche, _token, _amountIn);
        if (lpAmount < _minLpAmount) {
            revert PoolErrors.SlippageExceeded();
        }

        poolTokens[_token].feeReserve += daoFee;
        trancheAssets[_tranche][_token].poolAmount += amountInAfterFee;

        ILPToken(_tranche).mint(_to, lpAmount);
        emit LiquidityAdded(_tranche, msg.sender, _token, _amountIn, lpAmount, daoFee);
    }

    function removeLiquidity(address _tranche, address _tokenOut, uint256 _lpAmount, uint256 _minOut, address _to)
        external
        nonReentrant
        onlyAsset(_tokenOut)
    {
        _validateTranche(_tranche);
        _accrueInterest(_tokenOut);
        _requireAmount(_lpAmount);
        ILPToken lpToken = ILPToken(_tranche);

        (uint256 outAmount, uint256 outAmountAfterFee, uint256 daoFee) =
            _calcRemoveLiquidity(_tranche, _tokenOut, _lpAmount);
        if (outAmountAfterFee < _minOut) {
            revert PoolErrors.SlippageExceeded();
        }

        uint256 trancheBalance = trancheAssets[_tranche][_tokenOut].poolAmount;
        if (trancheBalance < outAmount) {
            revert PoolErrors.RemoveLiquidityTooMuch(_tranche, outAmount, trancheBalance);
        }

        poolTokens[_tokenOut].feeReserve += daoFee;
        _decreaseTranchePoolAmount(_tranche, _tokenOut, outAmountAfterFee);

        lpToken.burnFrom(msg.sender, _lpAmount);
        _doTransferOut(_tokenOut, _to, outAmountAfterFee);
        emit LiquidityRemoved(_tranche, msg.sender, _tokenOut, _lpAmount, outAmountAfterFee, daoFee);
    }

    function swap(address _tokenIn, address _tokenOut, uint256 _minOut, address _to, bytes calldata extradata)
        external
        nonReentrant
        onlyListedToken(_tokenIn)
        onlyListedToken(_tokenOut)
    {
        if (_tokenIn == _tokenOut) {
            revert PoolErrors.SameTokenSwap(_tokenIn);
        }
        _accrueInterest(_tokenIn);
        _accrueInterest(_tokenOut);
        uint256 amountIn = _requireAmount(_getAmountIn(_tokenIn));
        (uint256 amountOutAfterFee, uint256 swapFee) = _calcSwapOutput(_tokenIn, _tokenOut, amountIn);
        if (amountOutAfterFee < _minOut) {
            revert PoolErrors.SlippageExceeded();
        }
        uint256 daoFee = _calcDaoFee(swapFee);
        poolTokens[_tokenIn].feeReserve += daoFee;
        _rebalanceTranches(_tokenIn, amountIn - daoFee, _tokenOut, amountOutAfterFee);
        _doTransferOut(_tokenOut, _to, amountOutAfterFee);
        emit Swap(msg.sender, _tokenIn, _tokenOut, amountIn, amountOutAfterFee, swapFee);
        if (address(poolHook) != address(0)) {
            poolHook.postSwap(_to, _tokenIn, _tokenOut, abi.encode(amountIn, amountOutAfterFee, extradata));
        }
    }

    function increasePosition(
        address _owner,
        address _indexToken,
        address _collateralToken,
        uint256 _sizeChanged,
        Side _side
    ) external onlyOrderManager {
        _requireValidTokenPair(_indexToken, _collateralToken, _side, true);
        IncreasePositionVars memory vars;
        vars.collateralAmount = _requireAmount(_getAmountIn(_collateralToken));
        uint256 collateralPrice = _getPrice(_collateralToken, false);
        vars.collateralValueAdded = collateralPrice * vars.collateralAmount;
        uint256 borrowIndex = _accrueInterest(_collateralToken);
        bytes32 key = _getPositionKey(_owner, _indexToken, _collateralToken, _side);
        Position memory position = positions[key];
        vars.indexPrice = _getPrice(_indexToken, _side, true);
        vars.sizeChanged = _sizeChanged;

        // update position
        vars.feeValue = _calcPositionFee(position, vars.sizeChanged, borrowIndex);
        vars.daoFee = _calcDaoFee(vars.feeValue) / collateralPrice;
        vars.reserveAdded = vars.sizeChanged / collateralPrice;
        position.entryPrice = PositionUtils.calcAveragePrice(
            _side,
            position.size,
            position.size + vars.sizeChanged,
            position.entryPrice,
            vars.indexPrice,
            SignedIntOps.wrap(0)
        );
        position.collateralValue =
            MathUtils.zeroCapSub(position.collateralValue + vars.collateralValueAdded, vars.feeValue);
        position.size = position.size + vars.sizeChanged;
        position.borrowIndex = borrowIndex;
        position.reserveAmount += vars.reserveAdded;

        _validatePosition(position, _collateralToken, _side, true, vars.indexPrice);

        // update pool assets
        _reservePoolAsset(key, vars, _indexToken, _collateralToken, _side);
        positions[key] = position;

        emit IncreasePosition(
            key,
            _owner,
            _collateralToken,
            _indexToken,
            vars.collateralAmount,
            vars.sizeChanged,
            _side,
            vars.indexPrice,
            vars.feeValue
            );

        emit UpdatePosition(
            key,
            position.size,
            position.collateralValue,
            position.entryPrice,
            position.borrowIndex,
            position.reserveAmount,
            vars.indexPrice
            );

        if (address(poolHook) != address(0)) {
            poolHook.postIncreasePosition(
                _owner, _indexToken, _collateralToken, _side, abi.encode(_sizeChanged, vars.collateralValueAdded)
            );
        }
    }

    function decreasePosition(
        address _owner,
        address _indexToken,
        address _collateralToken,
        uint256 _collateralChanged,
        uint256 _sizeChanged,
        Side _side,
        address _receiver
    ) external onlyOrderManager {
        _requireValidTokenPair(_indexToken, _collateralToken, _side, false);
        uint256 borrowIndex = _accrueInterest(_collateralToken);
        bytes32 key = _getPositionKey(_owner, _indexToken, _collateralToken, _side);
        Position memory position = positions[key];

        if (position.size == 0) {
            revert PoolErrors.PositionNotExists(_owner, _indexToken, _collateralToken, _side);
        }

        DecreasePositionVars memory vars =
            _calcDecreasePayout(position, _indexToken, _collateralToken, _side, _sizeChanged, _collateralChanged, false);

        vars.collateralReduced = position.collateralValue - vars.remainingCollateral;
        _releasePoolAsset(key, vars, _indexToken, _collateralToken, _side);
        position.size = position.size - vars.sizeChanged;
        position.borrowIndex = borrowIndex;
        position.reserveAmount = position.reserveAmount - vars.reserveReduced;
        // reset to actual reduced value instead of user input
        position.collateralValue = vars.remainingCollateral;

        _validatePosition(position, _collateralToken, _side, false, vars.indexPrice);

        emit DecreasePosition(
            key,
            _owner,
            _collateralToken,
            _indexToken,
            vars.collateralReduced,
            vars.sizeChanged,
            _side,
            vars.indexPrice,
            vars.pnl,
            vars.feeValue
            );
        if (position.size == 0) {
            emit ClosePosition(
                key,
                position.size,
                position.collateralValue,
                position.entryPrice,
                position.borrowIndex,
                position.reserveAmount
                );
            // delete position when closed
            delete positions[key];
        } else {
            emit UpdatePosition(
                key,
                position.size,
                position.collateralValue,
                position.entryPrice,
                position.borrowIndex,
                position.reserveAmount,
                vars.indexPrice
                );
            positions[key] = position;
        }
        _doTransferOut(_collateralToken, _receiver, vars.payout);

        if (address(poolHook) != address(0)) {
            poolHook.postDecreasePosition(
                _owner, _indexToken, _collateralToken, _side, abi.encode(vars.sizeChanged, vars.collateralReduced)
            );
        }
    }

    function liquidatePosition(address _account, address _indexToken, address _collateralToken, Side _side) external {
        _requireValidTokenPair(_indexToken, _collateralToken, _side, false);
        uint256 borrowIndex = _accrueInterest(_collateralToken);

        bytes32 key = _getPositionKey(_account, _indexToken, _collateralToken, _side);
        Position memory position = positions[key];
        uint256 markPrice = _getPrice(_indexToken, _side, false);
        if (!_liquidatePositionAllowed(position, _side, markPrice, borrowIndex)) {
            revert PoolErrors.PositionNotLiquidated(key);
        }

        DecreasePositionVars memory vars = _calcDecreasePayout(
            position, _indexToken, _collateralToken, _side, position.size, position.collateralValue, true
        );

        uint256 liquidationFee = fee.liquidationFee / vars.collateralPrice;
        vars.poolAmountReduced = vars.poolAmountReduced.add(liquidationFee);
        _releasePoolAsset(key, vars, _indexToken, _collateralToken, _side);

        emit LiquidatePosition(
            key,
            _account,
            _collateralToken,
            _indexToken,
            _side,
            position.size,
            position.collateralValue - vars.remainingCollateral,
            position.reserveAmount,
            vars.indexPrice,
            vars.pnl,
            vars.feeValue
            );

        delete positions[key];
        _doTransferOut(_collateralToken, _account, vars.payout);
        _doTransferOut(_collateralToken, msg.sender, liquidationFee);

        if (address(poolHook) != address(0)) {
            poolHook.postLiquidatePosition(
                _account, _indexToken, _collateralToken, _side, abi.encode(position.size, position.collateralValue)
            );
        }
    }

    // ========= ADMIN FUNCTIONS ========
    function addTranche(address _tranche) external onlyOwner {
        if (allTranches.length >= MAX_TRANCHES) {
            revert PoolErrors.MaxNumberOfTranchesReached();
        }
        _requireAddress(_tranche);
        if (isTranche[_tranche]) {
            revert PoolErrors.TrancheAlreadyAdded(_tranche);
        }
        isTranche[_tranche] = true;
        allTranches.push(_tranche);
        emit TrancheAdded(_tranche);
    }

    struct RiskConfig {
        address tranche;
        uint256 riskFactor;
    }

    function setRiskFactor(address _token, RiskConfig[] memory _config) external onlyOwner onlyAsset(_token) {
        if (isStableCoin[_token]) {
            revert PoolErrors.CannotSetRiskFactorForStableCoin(_token);
        }
        uint256 total = totalRiskFactor[_token];
        for (uint256 i = 0; i < _config.length; ++i) {
            (address tranche, uint256 factor) = (_config[i].tranche, _config[i].riskFactor);
            if (!isTranche[tranche]) {
                revert PoolErrors.InvalidTranche(tranche);
            }
            total = total + factor - riskFactor[_token][tranche];
            riskFactor[_token][tranche] = factor;
        }
        totalRiskFactor[_token] = total;
        emit TokenRiskFactorUpdated(_token);
    }

    function addToken(address _token, bool _isStableCoin) external onlyOwner {
        if (!isAsset[_token]) {
            isAsset[_token] = true;
            isListed[_token] = true;
            allAssets.push(_token);
            isStableCoin[_token] = _isStableCoin;
            if (allAssets.length > MAX_ASSETS) {
                revert PoolErrors.TooManyTokenAdded(allAssets.length, MAX_ASSETS);
            }
            emit TokenWhitelisted(_token);
            return;
        }

        if (isListed[_token]) {
            revert PoolErrors.DuplicateToken(_token);
        }

        // token is added but not listed
        isListed[_token] = true;
        emit TokenWhitelisted(_token);
    }

    function delistToken(address _token) external onlyOwner {
        if (!isListed[_token]) {
            revert PoolErrors.AssetNotListed(_token);
        }
        isListed[_token] = false;
        uint256 weight = targetWeights[_token];
        totalWeight -= weight;
        targetWeights[_token] = 0;
        emit TokenDelisted(_token);
    }

    function setMaxLeverage(uint256 _maxLeverage) external onlyOwner {
        _setMaxLeverage(_maxLeverage);
    }

    function setMaintenanceMargin(uint256 _margin) external onlyOwner {
        _setMaintenanceMargin(_margin);
    }

    function setOracle(address _oracle) external onlyOwner {
        _requireAddress(_oracle);
        address oldOracle = address(oracle);
        oracle = ILevelOracle(_oracle);
        emit OracleChanged(oldOracle, _oracle);
    }

    function setSwapFee(
        uint256 _baseSwapFee,
        uint256 _taxBasisPoint,
        uint256 _stableCoinBaseSwapFee,
        uint256 _stableCoinTaxBasisPoint
    ) external onlyOwner {
        _validateMaxValue(_baseSwapFee, MAX_BASE_SWAP_FEE);
        _validateMaxValue(_stableCoinBaseSwapFee, MAX_BASE_SWAP_FEE);
        _validateMaxValue(_taxBasisPoint, MAX_TAX_BASIS_POINT);
        _validateMaxValue(_stableCoinTaxBasisPoint, MAX_TAX_BASIS_POINT);
        fee.baseSwapFee = _baseSwapFee;
        fee.taxBasisPoint = _taxBasisPoint;
        fee.stableCoinBaseSwapFee = _stableCoinBaseSwapFee;
        fee.stableCoinTaxBasisPoint = _stableCoinTaxBasisPoint;
        emit SwapFeeSet(_baseSwapFee, _taxBasisPoint, _stableCoinBaseSwapFee, _stableCoinTaxBasisPoint);
    }

    function setAddRemoveLiquidityFee(uint256 _value) external onlyOwner {
        _validateMaxValue(_value, MAX_BASE_SWAP_FEE);
        addRemoveLiquidityFee = _value;
        emit AddRemoveLiquidityFeeSet(_value);
    }

    function setPositionFee(uint256 _positionFee, uint256 _liquidationFee) external onlyOwner {
        _setPositionFee(_positionFee, _liquidationFee);
    }

    function setDaoFee(uint256 _daoFee) external onlyOwner {
        _validateMaxValue(_daoFee, PRECISION);
        fee.daoFee = _daoFee;
        emit DaoFeeSet(_daoFee);
    }

    function setInterestRate(uint256 _interestRate, uint256 _accrualInterval) external onlyOwner {
        _setInterestRate(_interestRate, _accrualInterval);
    }

    function setOrderManager(address _orderManager) external onlyOwner {
        _requireAddress(_orderManager);
        orderManager = _orderManager;
        emit SetOrderManager(_orderManager);
    }

    function withdrawFee(address _token, address _recipient) external onlyAsset(_token) {
        _validateFeeDistributor();
        uint256 amount = poolTokens[_token].feeReserve;
        poolTokens[_token].feeReserve = 0;
        _doTransferOut(_token, _recipient, amount);
        emit DaoFeeWithdrawn(_token, _recipient, amount);
    }

    /// @notice reduce DAO fee by distributing to pool amount;
    function reduceDaoFee(address _token, uint256 _amount) external onlyAsset(_token) {
        _validateFeeDistributor();
        _amount = MathUtils.min(_amount, poolTokens[_token].feeReserve);
        uint256[] memory shares = _calcTrancheSharesAmount(_token, _token, _amount, false);
        for (uint256 i = 0; i < shares.length; ++i) {
            address tranche = allTranches[i];
            trancheAssets[tranche][_token].poolAmount += shares[i];
        }
        poolTokens[_token].feeReserve -= _amount;
        emit DaoFeeReduced(_token, _amount);
    }

    function setFeeDistributor(address _feeDistributor) external onlyOwner {
        _requireAddress(_feeDistributor);
        feeDistributor = _feeDistributor;
        emit FeeDistributorSet(feeDistributor);
    }

    function setTargetWeight(TokenWeight[] memory tokens) external onlyOwner {
        if (tokens.length != allAssets.length) {
            revert PoolErrors.RequireAllTokens();
        }
        uint256 total = 0;
        for (uint256 i = 0; i < tokens.length; ++i) {
            TokenWeight memory item = tokens[i];
            assert(isAsset[item.token]);
            // unlisted token always has zero weight
            uint256 weight = isListed[item.token] ? item.weight : 0;
            targetWeights[item.token] = weight;
            total += weight;
        }
        totalWeight = total;
        emit TokenWeightSet(tokens);
    }

    function setPoolHook(address _hook) external onlyOwner {
        poolHook = IPoolHook(_hook);
        emit PoolHookChanged(_hook);
    }

    // ======== internal functions =========
    function _setMaxLeverage(uint256 _maxLeverage) internal {
        if (_maxLeverage == 0) {
            revert PoolErrors.InvalidMaxLeverage();
        }
        maxLeverage = _maxLeverage;
        emit MaxLeverageChanged(_maxLeverage);
    }

    function _setMaintenanceMargin(uint256 _ratio) internal {
        _validateMaxValue(_ratio, MAX_MAINTENANCE_MARGIN);
        maintenanceMargin = _ratio;
        emit MaintenanceMarginChanged(_ratio);
    }

    function _setInterestRate(uint256 _interestRate, uint256 _accrualInterval) internal {
        if (_accrualInterval < 1) {
            revert PoolErrors.InvalidInterval();
        }
        _validateMaxValue(_interestRate, MAX_INTEREST_RATE);
        interestRate = _interestRate;
        accrualInterval = _accrualInterval;
        emit InterestRateSet(_interestRate, _accrualInterval);
    }

    function _setPositionFee(uint256 _positionFee, uint256 _liquidationFee) internal {
        _validateMaxValue(_positionFee, MAX_POSITION_FEE);
        _validateMaxValue(_liquidationFee, MAX_LIQUIDATION_FEE);
        fee.positionFee = _positionFee;
        fee.liquidationFee = _liquidationFee;
        emit PositionFeeSet(_positionFee, _liquidationFee);
    }

    function _validateToken(address _indexToken, address _collateralToken, Side _side, bool _isIncrease)
        internal
        view
        returns (bool)
    {
        if (!isAsset[_indexToken] || !isAsset[_collateralToken]) {
            return false;
        }

        if (_isIncrease && !isListed[_indexToken]) {
            return false;
        }

        return _side == Side.LONG ? _indexToken == _collateralToken : isStableCoin[_collateralToken];
    }

    function _calcAddLiquidity(address _tranche, address _token, uint256 _amountIn)
        internal
        view
        returns (uint256 amountInAfterFee, uint256 daoFee, uint256 lpAmount)
    {
        if (!isStableCoin[_token] && riskFactor[_token][_tranche] == 0) {
            revert PoolErrors.AddLiquidityNotAllowed(_tranche, _token);
        }
        uint256 tokenPrice = _getPrice(_token, false);
        uint256 valueChange = _amountIn * tokenPrice;
        uint256 _fee = _calcAddRemoveLPFee(_token, tokenPrice, valueChange, true);
        uint256 userAmount = MathUtils.frac(_amountIn, PRECISION - _fee, PRECISION);
        daoFee = _calcDaoFee(_amountIn - userAmount);
        amountInAfterFee = _amountIn - daoFee;

        uint256 poolValue = _getTrancheValue(_tranche, true);
        uint256 lpSupply = ILPToken(_tranche).totalSupply();
        if (lpSupply & poolValue == 0) {
            lpAmount = MathUtils.frac(userAmount, tokenPrice, LP_INITIAL_PRICE);
        } else {
            lpAmount = (userAmount * tokenPrice * lpSupply) / poolValue;
        }
    }

    function _calcRemoveLiquidity(address _tranche, address _tokenOut, uint256 _lpAmount)
        internal
        view
        returns (uint256 outAmount, uint256 outAmountAfterFee, uint256 daoFee)
    {
        uint256 tokenPrice = _getPrice(_tokenOut, true);
        uint256 poolValue = _getTrancheValue(_tranche, false);
        uint256 totalSupply = ILPToken(_tranche).totalSupply();
        uint256 valueChange = (_lpAmount * poolValue) / totalSupply;
        uint256 _fee = _calcAddRemoveLPFee(_tokenOut, tokenPrice, valueChange, false);
        outAmount = (_lpAmount * poolValue) / totalSupply / tokenPrice;
        outAmountAfterFee = MathUtils.frac(outAmount, PRECISION - _fee, PRECISION);
        daoFee = _calcDaoFee(outAmount - outAmountAfterFee);
    }

    function _transferIn(address _token, uint256 _amount) internal returns (uint256) {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        return _getAmountIn(_token);
    }

    function _calcSwapOutput(address _tokenIn, address _tokenOut, uint256 _amountIn)
        internal
        view
        returns (uint256 amountOutAfterFee, uint256 feeAmount)
    {
        uint256 priceIn = _getPrice(_tokenIn, false);
        uint256 priceOut = _getPrice(_tokenOut, true);
        uint256 valueChange = _amountIn * priceIn;
        uint256 feeIn = _calcSwapFee(_tokenIn, priceIn, valueChange, true);
        uint256 feeOut = _calcSwapFee(_tokenOut, priceOut, valueChange, false);
        uint256 _fee = feeIn > feeOut ? feeIn : feeOut;

        amountOutAfterFee = valueChange * (PRECISION - _fee) / priceOut / PRECISION;
        feeAmount = (valueChange * _fee) / priceIn / PRECISION;
    }

    function _getPositionKey(address _owner, address _indexToken, address _collateralToken, Side _side)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_owner, _indexToken, _collateralToken, _side));
    }

    function _validatePosition(
        Position memory _position,
        address _collateralToken,
        Side _side,
        bool _isIncrease,
        uint256 _indexPrice
    ) internal view {
        if ((_isIncrease && _position.size == 0)) {
            revert PoolErrors.InvalidPositionSize();
        }

        uint256 borrowIndex = poolTokens[_collateralToken].borrowIndex;
        if (_position.size < _position.collateralValue || _position.size > _position.collateralValue * maxLeverage) {
            revert PoolErrors.InvalidLeverage(_position.size, _position.collateralValue, maxLeverage);
        }
        if (_liquidatePositionAllowed(_position, _side, _indexPrice, borrowIndex)) {
            revert PoolErrors.UpdateCauseLiquidation();
        }
    }

    function _requireValidTokenPair(address _indexToken, address _collateralToken, Side _side, bool _isIncrease)
        internal
        view
    {
        if (!_validateToken(_indexToken, _collateralToken, _side, _isIncrease)) {
            revert PoolErrors.InvalidTokenPair(_indexToken, _collateralToken);
        }
    }

    function _validateAsset(address _token) internal view {
        if (!isAsset[_token]) {
            revert PoolErrors.UnknownToken(_token);
        }
    }

    function _validateTranche(address _tranche) internal view {
        if (!isTranche[_tranche]) {
            revert PoolErrors.InvalidTranche(_tranche);
        }
    }

    function _requireAddress(address _address) internal pure {
        if (_address == address(0)) {
            revert PoolErrors.ZeroAddress();
        }
    }

    function _requireAmount(uint256 _amount) internal pure returns (uint256) {
        if (_amount == 0) {
            revert PoolErrors.ZeroAmount();
        }

        return _amount;
    }

    function _requireListedToken(address _token) internal view {
        if (!isListed[_token]) {
            revert PoolErrors.AssetNotListed(_token);
        }
    }

    function _requireOrderManager() internal view {
        if (msg.sender != orderManager) {
            revert PoolErrors.OrderManagerOnly();
        }
    }

    function _validateFeeDistributor() internal view {
        if (msg.sender != feeDistributor) {
            revert PoolErrors.FeeDistributorOnly();
        }
    }

    function _validateMaxValue(uint256 _input, uint256 _max) internal pure {
        if (_input > _max) {
            revert PoolErrors.ValueTooHigh(_max);
        }
    }

    function _getAmountIn(address _token) internal returns (uint256 amount) {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        amount = balance - poolTokens[_token].poolBalance;
        poolTokens[_token].poolBalance = balance;
    }

    function _doTransferOut(address _token, address _to, uint256 _amount) internal {
        if (_amount != 0) {
            IERC20 token = IERC20(_token);
            token.safeTransfer(_to, _amount);
            poolTokens[_token].poolBalance = token.balanceOf(address(this));
        }
    }

    function _accrueInterest(address _token) internal returns (uint256) {
        PoolTokenInfo memory tokenInfo = poolTokens[_token];
        AssetInfo memory asset = _getPoolAsset(_token);
        uint256 _now = block.timestamp;
        if (tokenInfo.lastAccrualTimestamp & asset.poolAmount == 0) {
            tokenInfo.lastAccrualTimestamp = (_now / accrualInterval) * accrualInterval;
        } else {
            uint256 nInterval = (_now - tokenInfo.lastAccrualTimestamp) / accrualInterval;
            if (nInterval == 0) {
                return tokenInfo.borrowIndex;
            }

            tokenInfo.borrowIndex += (nInterval * interestRate * asset.reservedAmount) / asset.poolAmount;
            tokenInfo.lastAccrualTimestamp += nInterval * accrualInterval;
        }

        poolTokens[_token] = tokenInfo;
        emit InterestAccrued(_token, tokenInfo.borrowIndex);
        return tokenInfo.borrowIndex;
    }

    /// @notice calculate adjusted fee rate
    /// fee is increased or decreased based on action's effect to pool amount
    /// each token has their target weight set by gov
    /// if action make the weight of token far from its target, fee will be increase, vice versa
    function _calcSwapFee(address _token, uint256 _tokenPrice, uint256 _valueChange, bool _isSwapIn)
        internal
        view
        returns (uint256)
    {
        uint256 poolValue = _getPoolValue(_isSwapIn);
        (uint256 baseSwapFee, uint256 taxBasisPoint) = isStableCoin[_token]
            ? (fee.stableCoinBaseSwapFee, fee.stableCoinTaxBasisPoint)
            : (fee.baseSwapFee, fee.taxBasisPoint);
        return _calcFeeRate(poolValue, _token, _tokenPrice, _valueChange, baseSwapFee, taxBasisPoint, _isSwapIn);
    }

    function _calcAddRemoveLPFee(address _token, uint256 _tokenPrice, uint256 _valueChange, bool _isAdd)
        internal
        view
        returns (uint256)
    {
        return _calcFeeRate(
            _getPoolValue(_isAdd), _token, _tokenPrice, _valueChange, addRemoveLiquidityFee, fee.taxBasisPoint, _isAdd
        );
    }

    function _calcFeeRate(
        uint256 _poolValue,
        address _token,
        uint256 _tokenPrice,
        uint256 _valueChange,
        uint256 _baseFee,
        uint256 _taxBasisPoint,
        bool _isIncrease
    ) internal view returns (uint256) {
        uint256 _targetValue = totalWeight == 0 ? 0 : (targetWeights[_token] * _poolValue) / totalWeight;
        if (_targetValue == 0) {
            return _baseFee;
        }
        uint256 _currentValue = _tokenPrice * _getPoolAsset(_token).poolAmount;
        uint256 _nextValue = _isIncrease ? _currentValue + _valueChange : _currentValue - _valueChange;
        uint256 initDiff = MathUtils.diff(_currentValue, _targetValue);
        uint256 nextDiff = MathUtils.diff(_nextValue, _targetValue);
        if (nextDiff < initDiff) {
            uint256 feeAdjust = (_taxBasisPoint * initDiff) / _targetValue;
            return MathUtils.zeroCapSub(_baseFee, feeAdjust);
        } else {
            uint256 avgDiff = (initDiff + nextDiff) / 2;
            uint256 feeAdjust = avgDiff > _targetValue ? _taxBasisPoint : (_taxBasisPoint * avgDiff) / _targetValue;
            return _baseFee + feeAdjust;
        }
    }

    function _getPoolValue(bool _max) internal view returns (uint256 sum) {
        uint256[] memory prices = _getAllPrices(_max);
        for (uint256 i = 0; i < allTranches.length;) {
            sum += _getTrancheValue(allTranches[i], prices);
            unchecked {
                ++i;
            }
        }
    }

    function _getAllPrices(bool _max) internal view returns (uint256[] memory) {
        return oracle.getMultiplePrices(allAssets, _max);
    }

    function _getTrancheValue(address _tranche, bool _max) internal view returns (uint256 sum) {
        return _getTrancheValue(_tranche, _getAllPrices(_max));
    }

    function _getTrancheValue(address _tranche, uint256[] memory prices) internal view returns (uint256 sum) {
        SignedInt memory aum = SignedIntOps.wrap(uint256(0));

        for (uint256 i = 0; i < allAssets.length;) {
            address token = allAssets[i];
            assert(isAsset[token]); // double check
            AssetInfo memory asset = trancheAssets[_tranche][token];
            uint256 price = prices[i];
            if (isStableCoin[token]) {
                aum = aum.add(price * asset.poolAmount);
            } else {
                aum = aum.add(_calcManagedValue(_tranche, token, asset, price));
            }
            unchecked {
                ++i;
            }
        }

        // aum MUST not be negative. If it is, please debug
        return aum.toUint();
    }

    function _calcManagedValue(address _tranche, address _token, AssetInfo memory _asset, uint256 _price)
        internal
        view
        returns (SignedInt memory aum)
    {
        uint256 averageShortPrice = averageShortPrices[_tranche][_token];
        SignedInt memory shortPnl = _asset.totalShortSize == 0
            ? SignedIntOps.wrap(uint256(0))
            : SignedIntOps.wrap(averageShortPrice).sub(_price).mul(_asset.totalShortSize).div(averageShortPrice);

        aum = SignedIntOps.wrap(_asset.poolAmount).sub(_asset.reservedAmount).mul(_price).add(_asset.guaranteedValue);
        aum = aum.sub(shortPnl);
    }

    function _decreaseTranchePoolAmount(address _tranche, address _token, uint256 _amount) internal {
        AssetInfo memory asset = trancheAssets[_tranche][_token];
        asset.poolAmount -= _amount;
        if (asset.poolAmount < asset.reservedAmount) {
            revert PoolErrors.InsufficientPoolAmount(_token);
        }
        trancheAssets[_tranche][_token] = asset;
    }

    /// @notice return pseudo pool asset by sum all tranches asset
    function _getPoolAsset(address _token) internal view returns (AssetInfo memory asset) {
        for (uint256 i = 0; i < allTranches.length;) {
            address tranche = allTranches[i];
            asset.poolAmount += trancheAssets[tranche][_token].poolAmount;
            asset.reservedAmount += trancheAssets[tranche][_token].reservedAmount;
            asset.totalShortSize += trancheAssets[tranche][_token].totalShortSize;
            asset.guaranteedValue += trancheAssets[tranche][_token].guaranteedValue;
            unchecked {
                ++i;
            }
        }
    }

    /// @notice reserve asset when open position
    function _reservePoolAsset(
        bytes32 _key,
        IncreasePositionVars memory _vars,
        address _indexToken,
        address _collateralToken,
        Side _side
    ) internal {
        AssetInfo memory collateral = _getPoolAsset(_collateralToken);

        if (collateral.reservedAmount + _vars.reserveAdded > collateral.poolAmount) {
            revert PoolErrors.InsufficientPoolAmount(_collateralToken);
        }

        poolTokens[_collateralToken].feeReserve += _vars.daoFee;
        _reserveTrancheAsset(_key, _vars, _indexToken, _collateralToken, _side);
    }

    /// @notice release asset and take or distribute realized PnL when close position
    function _releasePoolAsset(
        bytes32 _key,
        DecreasePositionVars memory _vars,
        address _indexToken,
        address _collateralToken,
        Side _side
    ) internal {
        AssetInfo memory collateral = _getPoolAsset(_collateralToken);

        if (collateral.reservedAmount < _vars.reserveReduced) {
            revert PoolErrors.ReserveReduceTooMuch(_collateralToken);
        }

        poolTokens[_collateralToken].feeReserve += _vars.daoFee;

        _releaseTranchesAsset(_key, _vars, _indexToken, _collateralToken, _side);
    }

    function _reserveTrancheAsset(
        bytes32 _key,
        IncreasePositionVars memory _vars,
        address _indexToken,
        address _collateralToken,
        Side _side
    ) internal {
        uint256[] memory shares;
        uint256 totalShare;
        if (_vars.reserveAdded != 0) {
            totalShare = _vars.reserveAdded;
            shares = _calcTrancheSharesAmount(_indexToken, _collateralToken, totalShare, false);
        } else {
            totalShare = _vars.collateralAmount;
            shares = _calcTrancheSharesAmount(_indexToken, _collateralToken, totalShare, true);
        }

        for (uint256 i = 0; i < shares.length;) {
            address tranche = allTranches[i];
            uint256 share = shares[i];
            AssetInfo storage collateral = trancheAssets[tranche][_collateralToken];

            uint256 reserveAmount = MathUtils.frac(_vars.reserveAdded, share, totalShare);
            tranchePositionReserves[tranche][_key] += reserveAmount;
            collateral.reservedAmount += reserveAmount;

            if (_side == Side.LONG) {
                collateral.poolAmount = MathUtils.addThenSubWithFraction(
                    collateral.poolAmount, _vars.collateralAmount, _vars.daoFee, share, totalShare
                );
                // ajust guaranteed
                // guaranteed value = total(size - (collateral - fee))
                // delta_guaranteed value = sizechange + fee - collateral
                collateral.guaranteedValue = MathUtils.addThenSubWithFraction(
                    collateral.guaranteedValue,
                    _vars.sizeChanged + _vars.feeValue,
                    _vars.collateralValueAdded,
                    share,
                    totalShare
                );
            } else {
                AssetInfo storage indexAsset = trancheAssets[tranche][_indexToken];
                uint256 sizeChanged = MathUtils.frac(_vars.sizeChanged, share, totalShare);
                uint256 indexPrice = _vars.indexPrice;
                _updateGlobalShortPrice(tranche, _indexToken, sizeChanged, true, indexPrice, SignedIntOps.wrap(0));
                indexAsset.totalShortSize += sizeChanged;
            }
            unchecked {
                ++i;
            }
        }
    }

    function _releaseTranchesAsset(
        bytes32 _key,
        DecreasePositionVars memory _vars,
        address _indexToken,
        address _collateralToken,
        Side _side
    ) internal {
        uint256 totalShare = positions[_key].reserveAmount;

        for (uint256 i = 0; i < allTranches.length;) {
            address tranche = allTranches[i];
            uint256 share = tranchePositionReserves[tranche][_key];
            AssetInfo storage collateral = trancheAssets[tranche][_collateralToken];

            {
                uint256 reserveReduced = MathUtils.frac(_vars.reserveReduced, share, totalShare);
                tranchePositionReserves[tranche][_key] -= reserveReduced;
                collateral.reservedAmount -= reserveReduced;
            }
            collateral.poolAmount =
                SignedIntOps.wrap(collateral.poolAmount).sub(_vars.poolAmountReduced.frac(share, totalShare)).toUint();

            SignedInt memory pnl = _vars.pnl.frac(share, totalShare);
            if (_side == Side.LONG) {
                collateral.guaranteedValue = MathUtils.addThenSubWithFraction(
                    collateral.guaranteedValue, _vars.collateralReduced, _vars.sizeChanged, share, totalShare
                );
            } else {
                AssetInfo storage indexAsset = trancheAssets[tranche][_indexToken];
                uint256 sizeChanged = MathUtils.frac(_vars.sizeChanged, share, totalShare);
                uint256 indexPrice = _vars.indexPrice;
                _updateGlobalShortPrice(tranche, _indexToken, sizeChanged, false, indexPrice, pnl);
                indexAsset.totalShortSize = MathUtils.zeroCapSub(indexAsset.totalShortSize, sizeChanged);
            }
            emit PnLDistributed(_collateralToken, tranche, pnl.abs, pnl.isPos());
            unchecked {
                ++i;
            }
        }
    }

    /// @notice distributed amount of token to all tranches
    /// @param _indexToken the token of which risk factors is used to calculate ratio
    /// @param _collateralToken pool amount or reserve of this token will be changed. So we must cap the amount to be changed to the
    /// max available value of this token (pool amount - reserve) when _isIncreasePoolAmount set to false
    /// @param _isIncreasePoolAmount set to true when "increase pool amount" or "decrease reserve amount"
    function _calcTrancheSharesAmount(
        address _indexToken,
        address _collateralToken,
        uint256 _amount,
        bool _isIncreasePoolAmount
    ) internal view returns (uint256[] memory reserves) {
        uint256 nTranches = allTranches.length;
        reserves = new uint[](nTranches);
        uint256[] memory factors = new uint[](nTranches);
        uint256[] memory maxShare = new uint[](nTranches);

        for (uint256 i = 0; i < nTranches;) {
            address tranche = allTranches[i];
            AssetInfo memory asset = trancheAssets[tranche][_collateralToken];
            factors[i] = isStableCoin[_indexToken] ? 1 : riskFactor[_indexToken][tranche];
            maxShare[i] = _isIncreasePoolAmount ? type(uint256).max : asset.poolAmount - asset.reservedAmount;
            unchecked {
                ++i;
            }
        }

        uint256 totalFactor = isStableCoin[_indexToken] ? nTranches : totalRiskFactor[_indexToken];

        for (uint256 k = 0; k < nTranches;) {
            unchecked {
                ++k;
            }
            uint256 totalRiskFactor_ = totalFactor;
            for (uint256 i = 0; i < nTranches;) {
                uint256 riskFactor_ = factors[i];
                if (riskFactor_ != 0) {
                    uint256 shareAmount = MathUtils.frac(_amount, riskFactor_, totalRiskFactor_);
                    uint256 availableAmount = maxShare[i] - reserves[i];
                    if (shareAmount >= availableAmount) {
                        // skip this tranche on next rounds since it's full
                        shareAmount = availableAmount;
                        totalFactor -= riskFactor_;
                        factors[i] = 0;
                    }

                    reserves[i] += shareAmount;
                    _amount -= shareAmount;
                    totalRiskFactor_ -= riskFactor_;
                    if (_amount == 0) {
                        return reserves;
                    }
                }
                unchecked {
                    ++i;
                }
            }
        }

        revert PoolErrors.CannotDistributeToTranches(_indexToken, _collateralToken, _amount, _isIncreasePoolAmount);
    }

    /// @notice rebalance fund between tranches after swap token
    function _rebalanceTranches(address _tokenIn, uint256 _amountIn, address _tokenOut, uint256 _amountOut) internal {
        // amount devided to each tranche
        uint256[] memory outAmounts;

        if (!isStableCoin[_tokenIn] && isStableCoin[_tokenOut]) {
            // use token in as index
            outAmounts = _calcTrancheSharesAmount(_tokenIn, _tokenOut, _amountOut, false);
        } else {
            // use token out as index
            outAmounts = _calcTrancheSharesAmount(_tokenOut, _tokenOut, _amountOut, false);
        }

        for (uint256 i = 0; i < allTranches.length;) {
            address tranche = allTranches[i];
            trancheAssets[tranche][_tokenOut].poolAmount -= outAmounts[i];
            trancheAssets[tranche][_tokenIn].poolAmount += MathUtils.frac(_amountIn, outAmounts[i], _amountOut);
            unchecked {
                ++i;
            }
        }
    }

    function _liquidatePositionAllowed(Position memory _position, Side _side, uint256 _indexPrice, uint256 _borrowIndex)
        internal
        view
        returns (bool allowed)
    {
        if (_position.size == 0) {
            return false;
        }
        // calculate fee needed when close position
        uint256 feeValue = _calcPositionFee(_position, _position.size, _borrowIndex);
        SignedInt memory pnl = PositionUtils.calcPnl(_side, _position.size, _position.entryPrice, _indexPrice);
        SignedInt memory collateral = pnl.add(_position.collateralValue);

        // liquidation occur when collateral cannot cover margin fee or lower than maintenance margin
        return collateral.mul(PRECISION).lt(_position.size * maintenanceMargin)
            || collateral.lt(feeValue + fee.liquidationFee);
    }

    function _calcDecreasePayout(
        Position memory _position,
        address _indexToken,
        address _collateralToken,
        Side _side,
        uint256 _sizeChanged,
        uint256 _collateralChanged,
        bool isLiquidate
    ) internal view returns (DecreasePositionVars memory vars) {
        // clean user input
        vars.sizeChanged = MathUtils.min(_position.size, _sizeChanged);
        vars.collateralReduced = _position.collateralValue < _collateralChanged || _position.size == _sizeChanged
            ? _position.collateralValue
            : _collateralChanged;

        vars.indexPrice = _getPrice(_indexToken, _side, false);
        vars.collateralPrice = _getPrice(_collateralToken, false);

        uint256 borrowIndex = poolTokens[_collateralToken].borrowIndex;

        // vars is santinized, only trust these value from now on
        vars.reserveReduced = (_position.reserveAmount * vars.sizeChanged) / _position.size;
        vars.pnl = PositionUtils.calcPnl(_side, vars.sizeChanged, _position.entryPrice, vars.indexPrice);
        vars.feeValue = _calcPositionFee(_position, vars.sizeChanged, borrowIndex);
        vars.daoFee = vars.feeValue * fee.daoFee / vars.collateralPrice / PRECISION;

        SignedInt memory remainingCollateral = SignedIntOps.wrap(_position.collateralValue).sub(vars.collateralReduced);
        SignedInt memory payoutValue = vars.pnl.add(vars.collateralReduced).sub(vars.feeValue);
        if (isLiquidate) {
            payoutValue = payoutValue.sub(fee.liquidationFee);
        }
        if (payoutValue.isNeg()) {
            // deduct uncovered lost from collateral
            remainingCollateral = remainingCollateral.add(payoutValue);
            payoutValue = SignedIntOps.wrap(0);
        }

        vars.remainingCollateral = remainingCollateral.isNeg() ? 0 : remainingCollateral.abs;
        vars.payout = payoutValue.isNeg() ? 0 : payoutValue.abs / vars.collateralPrice;
        SignedInt memory poolValueReduced = _side == Side.LONG ? payoutValue.add(vars.feeValue) : vars.pnl;
        if (poolValueReduced.isNeg()) {
            // cap the value of pool amount change to collateral value after fee in case of lost
            uint256 totalFee = isLiquidate ? vars.feeValue + fee.liquidationFee : vars.feeValue;
            poolValueReduced.abs =
                MathUtils.min(poolValueReduced.abs, MathUtils.zeroCapSub(_position.collateralValue, totalFee));
        }
        vars.poolAmountReduced = poolValueReduced.div(vars.collateralPrice);
    }

    function _calcPositionFee(Position memory _position, uint256 _sizeChanged, uint256 _borrowIndex)
        internal
        view
        returns (uint256 feeValue)
    {
        uint256 borrowFee = ((_borrowIndex - _position.borrowIndex) * _position.size) / PRECISION;
        uint256 positionFee = (_sizeChanged * fee.positionFee) / PRECISION;
        feeValue = borrowFee + positionFee;
    }

    function _getPrice(address _token, Side _side, bool _isIncrease) internal view returns (uint256) {
        // max == (_isIncrease & _side = LONG) | (!_increase & _side = SHORT)
        // max = _isIncrease == (_side == Side.LONG);
        return _getPrice(_token, _isIncrease == (_side == Side.LONG));
    }

    function _getPrice(address _token, bool _max) internal view returns (uint256) {
        return oracle.getPrice(_token, _max);
    }

    function _updateGlobalShortPrice(
        address _tranche,
        address _indexToken,
        uint256 _sizeChanged,
        bool _isIncrease,
        uint256 _indexPrice,
        SignedInt memory _realizedPnl
    ) internal {
        uint256 lastSize = trancheAssets[_tranche][_indexToken].totalShortSize;
        uint256 nextSize = _isIncrease ? lastSize + _sizeChanged : MathUtils.zeroCapSub(lastSize, _sizeChanged);
        uint256 entryPrice = averageShortPrices[_tranche][_indexToken];
        averageShortPrices[_tranche][_indexToken] =
            PositionUtils.calcAveragePrice(Side.SHORT, lastSize, nextSize, entryPrice, _indexPrice, _realizedPnl);
    }

    function _calcDaoFee(uint256 _feeAmount) internal view returns (uint256) {
        return MathUtils.frac(_feeAmount, fee.daoFee, PRECISION);
    }
}