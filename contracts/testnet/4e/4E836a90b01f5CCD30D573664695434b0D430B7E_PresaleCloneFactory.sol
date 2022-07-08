// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

import "../IERC20Upgradeable.sol";
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PresaleMaster.sol";

contract PresaleCloneFactory is Ownable {
    /// referral implementation contract
    address immutable presaleImplementation;

    /// Address of the last clone created so that it
    // can be returned offchain through a view function
    address private newPresaleClone;


    /// event new presale event created
    event NewPresaleEvent(address indexed contractAddress);

    using Clones for address;

    /**
     * @notice Constructor
     * Only factory is deployed and it create an instance of de presale
     * implementation contract
     */
    constructor() {
        presaleImplementation = address(new PresaleMaster());
    }

    /**
     * @notice Creates and initialize a new Presale
     * @param _config Configuration adddress
     * @param _presaleMaxCap Max cap in BUSD for the whole sale
     * @param _presaleSupply Total supply of project tokens for the whole presale
     * @param _presaleStartTime Presale start time
     * @param _presaleEndTime Presale end time
     */
    function createPresale(
        address _config,
        uint256 _presaleMaxCap,
        uint256 _presaleSupply,
        uint256 _presaleStartTime,
        uint256 _presaleEndTime
    ) external onlyOwner {
        address clone = Clones.clone(presaleImplementation);
        newPresaleClone = clone;
        PresaleMaster(clone).initialize(
            owner(),
            _config,
            _presaleMaxCap,
            _presaleSupply,
            _presaleStartTime,
            _presaleEndTime
        );

        emit NewPresaleEvent(clone);
    }

    /**
     * @notice Address of the last presale clone created
     */
    function getNewPresaleClone() external view returns (address) {
        return newPresaleClone;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./interfaces/IElixirDefi.sol";
import "./PresaleMasterConfig.sol";

/**
 * @title Elixir Launchpad tokens pre-sale
 * @author Satoshis.games
 * @notice this contract manages the pre-sale of tokens at an Elixir Launchpad IGO event
 * @dev
 */
contract PresaleMaster is
    Initializable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// Configuration
    PresaleMasterConfig public config;

    /// PreSale number of tiers
    uint256 public noOfTiers;
    // Presale status
    bool private cancelledStatus;

    // ADDRESSES
    /// Elixir platform owner
    address public owner;

    // DATES
    /// start presale time
    uint256 public presaleStartTime;
    /// end presale time
    uint256 public presaleEndTime;

    /// Max cap in BUSD for the whole presale
    uint256 public presaleMaxCap;
    /// Total supply of project tokens for the whole presale
    uint256 public presaleSupply;
    // token unit price in BUSD (maxCap/supply)
    uint256 public tokenPrice;
    /// total presale BUSD received
    uint256 public totalBUSDCollected;
    /// total fees collected
    uint256 public totalFeesCollected;
    /// total user investors count
    uint256 public totalInvestors;
    /// default number of decimal places for ERC20 tokens
    uint256 public tokenDecimals;
    /// default precision for wei division
    uint256 public divPrecision;

    // TIERS AND USERS

    /// Info for each tier in the presale
    struct TiersInfo {
        uint256 maxSpots; // Maximum number of spots available in the Tier
        uint256 allocation; // Allocation per user
        uint256 energyThreshold; // Minimum amount of energy to participate in the Tier
        uint256 fee; // Tier Fee
        uint256 spotsCount; // Number of users in the tier
        uint256 amountRaised; // Amount raised in the tier
    }

    /// Info of each participant in the presale
    struct UserInfo {
        uint256 tier; // Tier to which the user belongs
        uint256 investedAmount; // Amount invested by the user
        uint256 tokensAmount; // Amount of tokens that correspond to the investment
    }

    /// Map of Tiers info
    mapping(uint256 => TiersInfo) public tierDetails;
    /// Map of investor user information
    mapping(address => UserInfo) public investorDetails;
    /// iterable array of participant users
    address[] public investorsList;

    // EVENTS
    event TiersUpdated(address _user, uint256 _timestamp);
    event EnergyParamsUpdated(address _user, uint256 _timestamp);
    event UserInvestment(address indexed _to, uint256 _amount);
    event PresaleCancelled(address _sender, uint256 _timestamp);
    event UserRefunded(address _user, uint256 _amount, uint256 _timestamp);
    event TokenDecimalsUpdated(uint256 _oldValue, uint256 _newValue);
    event PrecisionUpdated(uint256 _oldValue, uint256 _newValue);

    // MODIFIERS

    /**
     * @notice check if the caller is the owner of the contract
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @notice Make sure buyer has provided the right allowance
     * @param _allower: sender address
     * @param _amount: amount to transfer
     */
    modifier _hasAllowance(address _allower, uint256 _amount) {
        address _busd = config.getAddress(
            uint256(PresaleMasterConfigOptions.Addresses.BUSDToken)
        );
        uint256 ourAllowance = IERC20Upgradeable(_busd).allowance(
            _allower,
            address(this)
        );
        require(_amount <= ourAllowance, "buyTokens: Allowance is too low");
        _;
    }

    // INITIALIZATION

    /**
     * @notice IGO sale and tiers initilization
     * @param _owner  Elixir platform owner
     * @param _config Configuration address
     * @param _presaleMaxCap Max cap in BUSD for the whole sale
     * @param _presaleSupply Total supply of project tokens for the whole presale
     * @param _presaleStartTime Start sale time
     * @param _presaleEndTime End sale time
     */
    function initialize(
        address _owner,
        address _config,
        uint256 _presaleMaxCap,
        uint256 _presaleSupply,
        uint256 _presaleStartTime,
        uint256 _presaleEndTime
    ) public initializer {
        tokenDecimals = 18;
        divPrecision = 5;

        // addresses check
        require(_owner != address(0), "Zero address");
        owner = _owner;

        config = PresaleMasterConfig(_config);

        address _treasury = config.getAddress(
            uint256(PresaleMasterConfigOptions.Addresses.TreasuryAccount)
        );
        require(_treasury != address(0), "Zero treasury owner address");

        address _busd = config.getAddress(
            uint256(PresaleMasterConfigOptions.Addresses.BUSDToken)
        );
        require(_busd != address(0), "Zero token address");

        presaleMaxCap = _presaleMaxCap;
        presaleSupply = _presaleSupply;
        // Calculate the token price from the supply and cap
        tokenPrice = weiDivision(presaleMaxCap, presaleSupply);

        presaleStartTime = _presaleStartTime;
        presaleEndTime = _presaleEndTime;
        cancelledStatus = false;
    }

    // energy calculation and tier selection

    /**
     * @notice returns the calculation of energy for the user, necessary to define his tier
     * @param _user user address
     * @return energy energy calculated
     */
    function _getUserEnergy(address _user)
        private
        view
        returns (uint256 energy)
    {
        address[] memory _stakingContracts = config.getAddressArray(
            uint256(PresaleMasterConfigOptions.AddressArrays.StakingContracts)
        );
        address _farmingContract = config.getAddress(
            uint256(PresaleMasterConfigOptions.Addresses.FarmingContract)
        );
        uint256 _stakingWeight = config.getNumber(
            uint256(PresaleMasterConfigOptions.Numbers.StakingWeight)
        );
        uint256 _farmingWeight = config.getNumber(
            uint256(PresaleMasterConfigOptions.Numbers.FarmingWeight)
        );

        uint256 _stakedElixir = 0;
        for (uint256 i = 0; i < _stakingContracts.length; i++) {
            _stakedElixir += IElixirDefi(_stakingContracts[i]).getUserBalance(
                _user
            );
        }
        uint256 _stakedLPs = IElixirDefi(_farmingContract).getUserBalance(
            _user
        );

        return (_stakedElixir * _stakingWeight) + (_stakedLPs * _farmingWeight);
    }

    /**
     * @notice returns the the energy calculation, the tier that corresponds
     * to that energy and the allocation
     * @param _user user address
     * @return energy energy calculated
     * @return tier tier that corresponds to the calculated energy
     * @return allocation amount to be invested by the user
     */
    function getUserTier(address _user)
        public
        view
        returns (
            uint256 energy,
            uint256 tier,
            uint256 allocation
        )
    {
        energy = _getUserEnergy(_user);

        // Energy equal to 0 means the user is not staking or farming
        if (energy == 0) return (0, 0, 0);

        for (tier = 1; tier <= noOfTiers; tier++) {
            if (
                energy <= tierDetails[tier].energyThreshold || tier == noOfTiers
            ) {
                allocation = tierDetails[tier].allocation;
                break;
            }
        }

        return (energy, tier, allocation);
    }

    // tiers actions

    /**
     * @notice Creates or updates the tier info scheme
     * @param _maxSpots; // Maximum number of spots available in the Tier
     * @param _allocation; // Allocation in BUSD per user
     * @param _energyThreshold; // Minimum amount of energy to participate in the Tier
     * @param _fee; // Tier Fee
     * @dev
     */
    function updateTiers(
        uint256[] calldata _maxSpots,
        uint256[] calldata _allocation,
        uint256[] calldata _energyThreshold,
        uint256[] calldata _fee
    ) external nonReentrant onlyOwner {
        require(
            _maxSpots.length == _allocation.length &&
                _allocation.length == _energyThreshold.length &&
                _energyThreshold.length == _fee.length,
            "Presale: invalid tiers data"
        );

        noOfTiers = _maxSpots.length;

        for (uint i = 0; i < _maxSpots.length; i++) {
            require(_allocation[i] > 0, "Presale: invalid allocation amount");
            require(_energyThreshold[i] > 0, "Presale: invalid energy amount");

            // tiers no starts at 1, so is index +1
            tierDetails[i + 1] = TiersInfo({
                maxSpots: _maxSpots[i],
                allocation: _allocation[i],
                energyThreshold: _energyThreshold[i],
                fee: _fee[i],
                spotsCount: 0,
                amountRaised: 0
            });
        }
        emit TiersUpdated(msg.sender, block.timestamp);
    }

    /**
     * @notice Return the tiers scheme
     * @return the order of the returned arrays is:
     * @return maxSpots, minAllocation, maxAllocation, energyThreshold, fee
     * @dev
     */
    function getTierScheme()
        external
        view
        returns (
            uint[] memory,
            uint[] memory,
            uint[] memory,
            uint[] memory
        )
    {
        uint[] memory maxSpots = new uint[](noOfTiers);
        uint[] memory allocation = new uint[](noOfTiers);
        uint[] memory energyThreshold = new uint[](noOfTiers);
        uint[] memory fee = new uint[](noOfTiers);

        for (uint i = 0; i < noOfTiers; i++) {
            maxSpots[i] = tierDetails[i + 1].maxSpots;
            allocation[i] = tierDetails[i + 1].allocation;
            energyThreshold[i] = tierDetails[i + 1].energyThreshold;
            fee[i] = tierDetails[i + 1].fee;
        }

        return (maxSpots, allocation, energyThreshold, fee);
    }

    /**
     * @notice Returns the available spots in the informed tier
     * @param _tier tier number
     * @return uint256 available espots
     */
    function getAvailableSpot(uint256 _tier) public view returns (uint256) {
        return tierDetails[_tier].maxSpots - tierDetails[_tier].spotsCount;
    }

    // dates update functions

    /**
     * @notice Updates sale start date
     * @param _newSaleStart start sale time
     */
    function updateStartTime(uint256 _newSaleStart)
        external
        nonReentrant
        onlyOwner
    {
        require(presaleStartTime > block.timestamp, "Sale already started");
        require(
            _newSaleStart > block.timestamp,
            "The start date cannot be less than the current date"
        );
        require(
            _newSaleStart < presaleStartTime,
            "The start date cannot be greater than the end date"
        );
        presaleStartTime = _newSaleStart;
    }

    /**
     * @notice Updates sale end date
     * @param _newSaleEnd end sale time
     */
    function updateEndTime(uint256 _newSaleEnd)
        external
        nonReentrant
        onlyOwner
    {
        require(
            _newSaleEnd > presaleStartTime && _newSaleEnd > block.timestamp,
            "The end date of the sale cannot be less than the start date"
        );
        presaleEndTime = _newSaleEnd;
    }

    // Tokens Presale

    /**
     * @notice User chooses spot and pays the corresponding BUSD
     * allocation in a single transaction.
     * It sends collected BUSD to treasury address
     */
    function buyTokens() external nonReentrant whenNotPaused returns (bool) {
        // get user tier and allocation
        (, uint256 _tier, uint256 _amount) = getUserTier(msg.sender);

        // check tier
        require(_tier > 0 && _tier <= noOfTiers, "buyTokens: Invalid tier");

        // check deposit amount
        require(_amount > 0, "buyTokens: The amount must be greater than zero");

        // check if the deposit equals the tier allocation
        require(
            _amount == tierDetails[_tier].allocation,
            "buyTokens: investment does not correspond to the tier allocation"
        );

        address _treasury = config.getAddress(
            uint256(PresaleMasterConfigOptions.Addresses.TreasuryAccount)
        );
        address _busd = config.getAddress(
            uint256(PresaleMasterConfigOptions.Addresses.BUSDToken)
        );

        // check allowance
        uint256 ourAllowance = IERC20Upgradeable(_busd).allowance(
            msg.sender,
            address(this)
        );
        require(_amount <= ourAllowance, "buyTokens: Allowance is too low");

        // check dates
        require(
            block.timestamp >= presaleStartTime,
            "buyTokens: Presale not started yet"
        );
        require(block.timestamp <= presaleEndTime, "buyTokens: Presale ended");

        // check available spots in tier
        require(
            getAvailableSpot(_tier) > 0,
            "buyTokens: no more available spots"
        );

        // check if the user has already invested
        require(
            investorDetails[msg.sender].tier == 0,
            "buyTokens: The user already participated in the Presale"
        );

        // check if the deposit exceeds the sale max cap limit
        require(
            totalBUSDCollected + _amount <= presaleMaxCap,
            "buyTokens: purchase would exceed sale max cap"
        );

        // Calculates fee and net amount
        uint256 feeAmount = (_amount * tierDetails[_tier].fee) / 10000;
        uint256 netAmount = _amount - feeAmount;

        // update totals
        totalBUSDCollected += netAmount;
        totalFeesCollected += feeAmount;
        totalInvestors++;
        // update tier info
        tierDetails[_tier].amountRaised += netAmount;
        tierDetails[_tier].spotsCount++;
        // update investor info
        investorDetails[msg.sender].tier = _tier;
        investorDetails[msg.sender].investedAmount = netAmount;

        // get the amount of tokens that correspond to the user
        uint _tokensAmount = weiDivision(netAmount, tokenPrice);
        investorDetails[msg.sender].tokensAmount = _tokensAmount;

        // add address to iterable list
        investorsList.push(msg.sender);

        emit UserInvestment(msg.sender, _amount);

        // The full amount is transferred to the treasury account,
        // the contract keep records the fees calculated
        IERC20Upgradeable(_busd).safeTransferFrom(
            msg.sender,
            _treasury,
            _amount
        );

        return true;
    }

    /**
     * @notice returns the investors amount
     * @return uint256 number of investors users
     */
    function getInvestorsCount() public view returns (uint256) {
        return investorsList.length;
    }

    /**
     * @notice returns the investors in the Tier
     * @param _tier The tier from which users will be returned
     * @return array of investors users
     */
    function getInvestorsFromTier(uint256 _tier)
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        // check valid tier
        if (_tier == 0 || _tier > noOfTiers) {
            return new address[](0);
        }

        uint tierCount = tierDetails[_tier].spotsCount;
        address[] memory tierInvestors = new address[](tierCount);
        uint k = 0;
        for (uint i = 0; i < investorsList.length; i++) {
            if (investorDetails[investorsList[i]].tier == _tier) {
                tierInvestors[k] = investorsList[i];
                k++;
            }
        }
        return tierInvestors;
    }

    // Cancel and Refund

    /**
     * @notice Cancel the presale, trigger the stopped state and
     * set the presale end time to current timestamp.
     * @notice this action is irreversible.
     */
    function cancelPresale() external nonReentrant onlyOwner returns (bool) {
        presaleEndTime = block.timestamp;
        cancelledStatus = true;
        if (!paused()) _pause();
        emit PresaleCancelled(msg.sender, presaleEndTime);
        return true;
    }

    /**
     * @notice the user is refunded in the unfortunate event
     * that the presale is cancelled.
     * The amount to be reimbursed is the amount invested minus the fees.
     * @notice The canceled status must be true,
     * the pre-sale must be completed, and the contract must be paused.
     */
    function refund() external nonReentrant whenPaused returns (bool) {
        // check if presale is canceled
        require(cancelledStatus, "refund: The presale has not been canceled");
        require(
            presaleEndTime <= block.timestamp,
            "refund: The presale has not ended"
        );
        // check if the user has invested
        require(
            investorDetails[msg.sender].tier != 0,
            "refund: The user has not participated in the presale"
        );

        address _treasury = config.getAddress(
            uint256(PresaleMasterConfigOptions.Addresses.TreasuryAccount)
        );
        address _busd = config.getAddress(
            uint256(PresaleMasterConfigOptions.Addresses.BUSDToken)
        );

        // look for invested amount
        uint256 invested = investorDetails[msg.sender].investedAmount;

        // check if the contract has enough allowance to transfer to user
        uint256 allowance = IERC20Upgradeable(_busd).allowance(
            _treasury,
            address(this)
        );
        require(invested <= allowance, "refund: Allowance is too low");

        // reset user invest data
        investorDetails[msg.sender].investedAmount = 0;
        investorDetails[msg.sender].tokensAmount = 0;
        investorDetails[msg.sender].tier = 0;
        emit UserRefunded(msg.sender, invested, block.timestamp);

        // approve and transfer
        IERC20Upgradeable(_busd).approve(msg.sender, invested);
        IERC20Upgradeable(_busd).safeTransferFrom(
            _treasury,
            msg.sender,
            invested
        );

        return true;
    }

    // Util functions

    /**
     * @notice calculates the division of the passed values
     * taking into account the configured precision
     * @param _dividend dividend
     * @param _divisor divisor
     * @return _result quotient with the amount of decimal defined
     */
    function weiDivision(uint256 _dividend, uint256 _divisor)
        public
        view
        returns (uint256 _result)
    {
        _result =
            ((_dividend * 10**divPrecision) / _divisor) *
            10**(tokenDecimals - divPrecision);
    }

    /**
     * @notice In the case of working with ERC20 tokens with
     * a number of decimal places other than the default of 18
     * @param _newTokenDecimals new decimals amount
     * @dev Token decimals can't be less than the precision
     */
    function setTokenDecimals(uint256 _newTokenDecimals)
        external
        onlyOwner
        whenNotPaused
    {
        require(
            _newTokenDecimals >= divPrecision,
            "Token decimals is less than the precision"
        );
        emit TokenDecimalsUpdated(tokenDecimals, _newTokenDecimals);
        tokenDecimals = _newTokenDecimals;
    }

    /**
     * @notice set a new precision value for division calculation
     * @param _newPrecision new decimals amount
     * @dev Token decimals can't be less than the precision
     */
    function setDivPrecision(uint256 _newPrecision) public onlyOwner {
        require(
            tokenDecimals >= _newPrecision,
            "Token decimals is less than the precision"
        );
        emit PrecisionUpdated(divPrecision, _newPrecision);
        divPrecision = _newPrecision;
    }

    /**
     * @dev Triggers stopped state.
     * Requirements:
     * - The contract must not be paused.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     * Requirements:
     * - The contract must be paused.
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/PresaleMasterConfigOptions.sol";

/**
 * @title Presale Master Config
 * @author Satoshis.games
 * @notice
 * @dev
 */
contract PresaleMasterConfig is Ownable {
    /// Numbers storage
    mapping(uint256 => uint256) private _numbers;
    /// Addresses storage
    mapping(uint256 => address) private _addresses;
    /// Address arrays storage
    mapping(uint256 => address[]) private _addressArrays;

    // EVENTS
    event NumberUpdated(
        uint256 index,
        uint256 newValue
    );
    event AddressUpdated(
        uint256 index,
        address newValue
    );
    event AddressArrayUpdated(
        uint256 index,
        address[] newValue
    );

    /**
     * @notice Returns a number
     * @param _index: index of the Numbers enum
     * @return number
     */
    function getNumber(uint256 _index)
        public
        view
        returns (
            uint256
        )
    {
        return _numbers[_index];
    }

    /**
     * @notice Returns an address
     * @param _index: index of the Addresses enum
     * @return address
     */
    function getAddress(uint256 _index)
        public
        view
        returns (
            address
        )
    {
        return _addresses[_index];
    }

    /**
     * @notice Returns an address array
     * @param _index: index of the AddressArrays enum
     * @return address array
     */
    function getAddressArray(uint256 _index)
        public
        view
        returns (
            address[] memory
        )
    {
        return _addressArrays[_index];
    }

    /**
     * @notice Sets a number
     * @param _index: index of the Numbers enum
     * @param _newNumber: number to store
     */
    function setNumber(
        uint256 _index,
        uint256 _newNumber
    ) public onlyOwner {
        emit NumberUpdated(_index, _newNumber);
        _numbers[_index] = _newNumber;
    }

    /**
     * @notice Sets an address
     * @param _index: index of the Addresses enum
     * @param _newAddress: address to store
     */
    function setAddress(
        uint256 _index,
        address _newAddress
    ) public onlyOwner {
        emit AddressUpdated(_index, _newAddress);
        _addresses[_index] = _newAddress;
    }

    /**
     * @notice Sets an address array
     * @param _index: index of the AddressArrays enum
     * @param _newAddressArray: address array to store
     */
    function setAddressArray(
        uint256 _index,
        address[] calldata _newAddressArray
    ) public onlyOwner {
        emit AddressArrayUpdated(_index, _newAddressArray);
        _addressArrays[_index] = _newAddressArray;
    }

    /**
     * @notice Pushes an address to address array
     * @param _index: index of the AddressArrays enum
     * @param _newAddress: address to store
     */
    function pushToAddressArray(
        uint256 _index,
        address _newAddress
    ) public onlyOwner {
        address[] storage _orig = _addressArrays[_index];
        address[] memory _arr = new address[](_orig.length + 1);
        for (uint256 i = 0; i < _orig.length; i++) {
            _arr[i] = _orig[i];
        }
        _arr[_orig.length + 1] = _newAddress;
        emit AddressArrayUpdated(_index, _arr);
        _addressArrays[_index] = _arr;
    }
}

///SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IElixirDefi {

    /**
     *  @notice Returns the user's stalking amount
     *  @param _user User address
     *  @return uint256 User staked amount
     */
    function getUserBalance(address _user) external view returns (uint256);

    /**
     *  @notice Returns the user's rewards earned so far
     *  @param _user User address
     *  @return uint256 User earned rewards
     */
    function pendingRewards(address _user) external view returns (uint256);

    /**
     * @notice Stake tokens
     * @param _amount amount value of tokens to stake
     * @return bool staking succes
     */
    function deposit(uint256 _amount) external returns (bool);

    /**
     * @notice Stake all available tokens
     * @return bool staking succes
     */
    function depositAll() external returns (bool);

    /**
     * @notice Withdraw user staking tokens
     * @param _amount amount value of tokens
     * @return bool withdraw succes
     */
    function withdraw(uint256 _amount) external returns (bool);

    /**
     * @notice Withdraw all the user staking tokens
     * @return bool withdraw succes
     */
    function withdrawAll() external returns (bool);

    /**
     * @notice Withdraw user pending rewards
     * @return bool withdraw succes
     */
    function claim() external returns (bool);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

library PresaleMasterConfigOptions {
    enum Numbers {
        StakingWeight,
        FarmingWeight
    }
    enum Addresses {
        BUSDToken,
        TreasuryAccount,
        FarmingContract
    }
    enum AddressArrays {
        StakingContracts
    }
}