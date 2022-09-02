// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

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
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
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

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

import {Decimal} from "./utils/Decimal.sol";
import {SignedDecimal} from "./utils/SignedDecimal.sol";
import {MixedDecimal} from "./utils/MixedDecimal.sol";

import {IAmm} from "./interface/IAmm.sol";
import {IClearingHouse} from "./interface/IClearingHouse.sol";
import {ISmartWallet} from "./interface/ISmartWallet.sol";
import {ISmartWalletFactory} from "./interface/ISmartWalletFactory.sol";
import {ILimitOrderBook} from "./interface/ILimitOrderBook.sol";

contract SmartWallet is Initializable, ISmartWallet, Pausable {
    using Decimal for Decimal.decimal;
    using SignedDecimal for SignedDecimal.signedDecimal;
    using Address for address;
    using SafeERC20 for IERC20;

    event ExecuteMarketOrder(
        address indexed trader,
        address indexed asset,
        SignedDecimal.signedDecimal orderSize,
        Decimal.decimal collateral,
        Decimal.decimal leverage,
        Decimal.decimal slippage
    );

    event ExecuteClosePosition(
        address indexed trader,
        address indexed asset,
        Decimal.decimal percentage,
        SignedDecimal.signedDecimal exchangedPositionSize,
        Decimal.decimal exchangedQuoteAmount
    );

    // Store addresses of smart contracts that we will be interacting with
    ILimitOrderBook public orderBook;
    ISmartWalletFactory public factory;
    IClearingHouse public clearingHouse;
    IERC20 public quoteToken;

    address public override owner;

    modifier onlyOrderBook() {
        require(
            msg.sender == address(orderBook),
            "SmartWallet: caller is not order book"
        );
        _;
    }

    function initialize(
        address _clearingHouse,
        address _limitOrderBook,
        address _owner
    ) external override initializer {
        clearingHouse = IClearingHouse(_clearingHouse);
        orderBook = ILimitOrderBook(_limitOrderBook);
        factory = ISmartWalletFactory(msg.sender);
        owner = _owner;

        quoteToken = clearingHouse.quoteToken();
        quoteToken.safeIncreaseAllowance(_clearingHouse, type(uint256).max);
        quoteToken.safeIncreaseAllowance(
            address(_limitOrderBook),
            type(uint256).max
        );
    }

    /*
     * @notice allows the owner of the smart wallet to execute any transaction
     *  on an external smart contract. The external smart contract must be whitelisted
     *  otherwise this function will revert
     *  This utilises functions from OpenZeppelin's Address.sol
     * @param target the address of the smart contract to interact with (will revert
     *    if this is not a valid smart contract)
     * @param callData the data bytes of the function and parameters to execute
     *    Can use encodeFunctionData() from ethers.js
     * @param value the ether value to attach to the function call (can be 0)
     */

    function executeCall(
        address target,
        bytes calldata callData,
        uint256 value
    ) external payable override onlyOwner returns (bytes memory) {
        require(target.isContract(), "SmartWallet: call to non-contract");
        require(factory.isWhitelisted(target), "SmartWallet: not whitelisted");
        require(value == msg.value, "SmartWallet: incorrect value");
        return target.functionCallWithValue(callData, value);
    }

    function executeMarketOrder(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage
    ) external override onlyOwner whenNotPaused {
        (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        ) = _handleOpenPosition(
                _asset,
                _orderSize,
                Decimal.decimal(0),
                _leverage,
                _slippage,
                true
            );

        emit ExecuteMarketOrder(
            owner,
            address(_asset),
            exchangedPositionSize,
            exchangedQuoteAmount.divD(_leverage),
            _leverage,
            _slippage
        );
    }

    function executeClosePosition(IAmm _asset, Decimal.decimal memory _slippage)
        external
        override
        onlyOwner
        whenNotPaused
    {
        (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        ) = _handleClosePosition(_asset, Decimal.one(), _slippage);

        emit ExecuteClosePosition(
            owner,
            address(_asset),
            Decimal.one(),
            exchangedPositionSize,
            exchangedQuoteAmount
        );
    }

    function executeClosePartialPosition(
        IAmm _asset,
        Decimal.decimal memory _percentage,
        Decimal.decimal memory _slippage
    ) external override onlyOwner whenNotPaused {
        (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        ) = _handleClosePosition(_asset, _percentage, _slippage);

        emit ExecuteClosePosition(
            owner,
            address(_asset),
            _percentage,
            exchangedPositionSize,
            exchangedQuoteAmount
        );
    }

    function executeAddMargin(
        IAmm _asset,
        Decimal.decimal calldata _addedMargin
    ) external override onlyOwner whenNotPaused {
        _handleAddMargin(_asset, _addedMargin);
    }

    function executeRemoveMargin(
        IAmm _asset,
        Decimal.decimal calldata _removedMargin
    ) external override onlyOwner whenNotPaused {
        _handleRemoveMargin(_asset, _removedMargin);
    }

    function pauseWallet() external onlyOwner {
        _pause();
    }

    function unpauseWallet() external onlyOwner {
        _unpause();
    }

    /*
     * @notice Will execute an order from the limit order book. Note that the only
     *  way to call this function is via the LimitOrderBook where you call execute().
     * @param order_id is the ID of the order to execute
     */
    function executeOrder(uint256 order_id, Decimal.decimal memory maxNotional)
        external
        virtual
        override
        whenNotPaused
        onlyOrderBook
        returns (SignedDecimal.signedDecimal memory, Decimal.decimal memory)
    {
        //Get some of the parameters
        (
            ,
            address _trader,
            ILimitOrderBook.OrderType _orderType,
            ,
            bool _stillValid,
            uint256 _expiry
        ) = orderBook.getLimitOrderParams(order_id);
        //Make sure that the order belongs to this smart wallet
        require(
            factory.getSmartWallet(_trader) == address(this),
            "SmartWallet: incorrect smart wallet"
        );
        //Make sure that the order hasn't expired
        require(
            ((_expiry == 0) || (block.timestamp < _expiry)),
            "SmartWallet: order expired"
        );
        //Make sure the order is still valid
        require(_stillValid, "SmartWallet: Order no longer valid");
        //Perform function depending on the type of order

        if (_orderType == ILimitOrderBook.OrderType.LIMIT) {
            return _executeLimitOrder(order_id, maxNotional);
        } else if (_orderType == ILimitOrderBook.OrderType.STOPLOSS) {
            return _executeStopOrder(order_id, maxNotional);
        }
    }

    function minD(Decimal.decimal memory a, Decimal.decimal memory b)
        internal
        pure
        returns (Decimal.decimal memory)
    {
        return (a.cmp(b) >= 1) ? b : a;
    }

    function _handleOpenPosition(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage,
        bool isMarketOrder
    )
        internal
        returns (SignedDecimal.signedDecimal memory, Decimal.decimal memory)
    {
        IAmm _asset_ = _asset;
        SignedDecimal.signedDecimal memory _orderSize_ = _orderSize;
        Decimal.decimal memory _collateral_ = _collateral;
        Decimal.decimal memory _leverage_ = _leverage;
        Decimal.decimal memory _slippage_ = _slippage;

        //Establish how much leverage will be needed for that order based on the
        //amount of collateral and the maximum leverage the user was happy with.
        bool _isLong = _orderSize_.isNegative() ? false : true;

        {
            Decimal.decimal memory _size = _orderSize_.abs();
            Decimal.decimal memory _quote = (
                _asset_.getOutputPrice(
                    _isLong ? IAmm.Dir.REMOVE_FROM_AMM : IAmm.Dir.ADD_TO_AMM,
                    _size
                )
            );
            if (isMarketOrder) {
                _collateral_ = _quote.divD(_leverage_);
            } else {
                Decimal.decimal memory _offset = Decimal.decimal(1); //Need to add one wei for rounding
                _leverage_ = minD(
                    _quote.divD(_collateral_).addD(_offset),
                    _leverage_
                );
            }
        }

        (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        ) = clearingHouse.openPosition(
                _asset_,
                _isLong ? IClearingHouse.Side.BUY : IClearingHouse.Side.SELL,
                _collateral_,
                _leverage_,
                _slippage_
            );

        return (exchangedPositionSize, exchangedQuoteAmount);
    }

    function _handleAddMargin(
        IAmm _asset,
        Decimal.decimal calldata _addedMargin
    ) internal {
        clearingHouse.addMargin(_asset, _addedMargin);
    }

    function _handleRemoveMargin(
        IAmm _asset,
        Decimal.decimal calldata _removedMargin
    ) internal {
        clearingHouse.removeMargin(_asset, _removedMargin);
    }

    function _calcBaseAssetAmountLimit(
        Decimal.decimal memory _positionSize,
        bool _isLong,
        Decimal.decimal memory _slippage
    ) internal pure returns (Decimal.decimal memory) {
        if (_slippage.cmp(Decimal.one()) == 0) {
            return Decimal.decimal(0);
        }
        Decimal.decimal memory factor;
        require(_slippage.cmp(Decimal.one()) == -1, "Slippage must be %");
        if (_isLong) {
            //base amount must be greater than base amount limit
            factor = Decimal.one().subD(_slippage);
        } else {
            //base amount must be less than base amount limit
            factor = Decimal.one().addD(_slippage);
        }
        return factor.mulD(_positionSize);
    }

    /*
        OPEN LONG
        BASE ASSET LIMIT = POSITION SIZE - SLIPPAGE
        OPEN SHORT
        BASE ASSET LIMIT = POSITION SIZE + SLIPPAGE
        CLOSE LONG
        QUOTE ASSET LIMIT = VALUE - SLIPPAGE
        CLOSE SHORT
        QUOTE ASSET LIMIT = VALUE + SLIPPAGE
    */

    function _calcQuoteAssetAmountLimit(
        IAmm _asset,
        Decimal.decimal memory _targetPrice,
        bool _isLong,
        Decimal.decimal memory _slippage
    ) internal view returns (Decimal.decimal memory) {
        IClearingHouse.Position memory oldPosition = clearingHouse.getPosition(
            _asset,
            address(this)
        );
        SignedDecimal.signedDecimal memory oldPositionSize = oldPosition.size;
        Decimal.decimal memory value = oldPositionSize.abs().mulD(_targetPrice);
        Decimal.decimal memory factor;
        if (_slippage.cmp(Decimal.one()) == 0) {
            return Decimal.decimal(0);
        }
        require(_slippage.cmp(Decimal.one()) == -1, "Slippage must be %");
        if (_isLong) {
            //quote amount must be less than quote amount limit
            factor = Decimal.one().addD(_slippage);
        } else {
            //quote amount must be greater than quote amount limit
            factor = Decimal.one().subD(_slippage);
        }
        return factor.mulD(value);
    }

    function _handleClosePosition(
        IAmm _asset,
        Decimal.decimal memory _percentage,
        Decimal.decimal memory _slippage
    )
        internal
        returns (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        )
    {
        require(
            _percentage.cmp(Decimal.one()) <= 0,
            "SmartWallet: Invalid percentage"
        );

        (exchangedPositionSize, exchangedQuoteAmount) = clearingHouse
            .closePartialPosition(_asset, _percentage, _slippage);
    }

    /*
     * @notice Get close position percentage
     * @param _asset the AMM for the asset
     * @param _orderSize the size of the order (note: negative are SELL/SHORT)
     */
    function _closePositionPercentage(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize
    ) internal view returns (Decimal.decimal memory) {
        //Get the size of the users current position
        IClearingHouse.Position memory _currentPosition = clearingHouse
            .getPosition(IAmm(_asset), address(this));
        SignedDecimal.signedDecimal memory _currentSize = _currentPosition.size;
        //If the user has no position for this asset, then cannot execute a reduceOnly order
        require(
            _currentSize.abs().toUint() != 0,
            "#reduceOnly: current size is 0"
        );
        //If the direction of the order is opposite to the users current position
        if (_orderSize.isNegative() != _currentSize.isNegative()) {
            //The size of the order is large enough to open a reverse position,
            //therefore we should close it instead
            if (_orderSize.abs().cmp(_currentSize.abs()) == -1) {
                return _orderSize.abs().divD(_currentSize.abs());
            } else {
                return Decimal.one();
            }
        } else {
            //User is trying to increase the size of their position
            revert("#reduceOnly: cannot increase size of position");
        }
    }

    /*
     * @notice internal position to execute limit order - note that you need to
     *  check that this is a limit order before calling this function
     */
    function _executeLimitOrder(
        uint256 order_id,
        Decimal.decimal memory maxNotional
    )
        internal
        returns (SignedDecimal.signedDecimal memory, Decimal.decimal memory)
    {
        //Get information of limit order
        (
            Decimal.decimal memory _limitPrice,
            SignedDecimal.signedDecimal memory _orderSize,
            Decimal.decimal memory _collateral,
            Decimal.decimal memory _leverage,
            ,
            address _asset,
            bool _reduceOnly
        ) = _getOrderDetails(order_id);

        Decimal.decimal memory _maxNotional = maxNotional;

        //Establish whether long or short
        bool isLong = _orderSize.isNegative() ? false : true;
        //Get the current spot price of the asset
        Decimal.decimal memory _markPrice = IAmm(_asset).getSpotPrice();
        require(
            _markPrice.cmp(Decimal.zero()) >= 1,
            "SmartWallet: Error getting mark price"
        );

        //Check whether price conditions have been met:
        //  LIMIT BUY: mark price <= limit price
        //  LIMIT SELL: mark price >= limit price
        require(
            (_limitPrice.cmp(_markPrice)) != (isLong ? -1 : int128(1)),
            "SmartWallet: Invalid limit order condition"
        );

        return
            _openOrClosePosition(
                _asset,
                _orderSize,
                _collateral,
                _leverage,
                _maxNotional,
                _reduceOnly
            );
    }

    function _executeStopOrder(
        uint256 order_id,
        Decimal.decimal memory maxNotional
    )
        internal
        returns (SignedDecimal.signedDecimal memory, Decimal.decimal memory)
    {
        //Get information of stop order
        (
            Decimal.decimal memory _limitPrice,
            SignedDecimal.signedDecimal memory _orderSize,
            Decimal.decimal memory _collateral,
            Decimal.decimal memory _leverage,
            ,
            address _asset,
            bool _reduceOnly
        ) = _getOrderDetails(order_id);

        Decimal.decimal memory _maxNotional = maxNotional;

        //Establish whether long or short
        bool isLong = _orderSize.isNegative() ? false : true;
        //Get the current spot price of the asset
        Decimal.decimal memory _markPrice = IAmm(_asset).getSpotPrice();
        require(
            _markPrice.cmp(Decimal.zero()) >= 1,
            "Error getting mark price"
        );
        //Check whether price conditions have been met:
        //  STOP BUY: mark price > stop price
        //  STOP SELL: mark price < stop price
        require(
            (_markPrice.cmp(_limitPrice)) != (isLong ? -1 : int128(1)),
            "SmartWallet: Invalid stop order condition"
        );

        return
            _openOrClosePosition(
                _asset,
                _orderSize,
                _collateral,
                _leverage,
                _maxNotional,
                _reduceOnly
            );
    }

    function _openOrClosePosition(
        address _asset,
        SignedDecimal.signedDecimal memory _orderSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory maxNotional,
        bool _close
    )
        internal
        returns (SignedDecimal.signedDecimal memory, Decimal.decimal memory)
    {
        SignedDecimal.signedDecimal memory _orderSize_ = _orderSize;
        if (_close) {
            IAmm.Dir _dirOfQuote = _orderSize.isNegative()
                ? IAmm.Dir.REMOVE_FROM_AMM
                : IAmm.Dir.ADD_TO_AMM;
            if (maxNotional.toUint() != 0) {
                Decimal.decimal memory maxBaseAsset = IAmm(_asset)
                    .getInputPrice(_dirOfQuote, maxNotional);
                if (_orderSize_.abs().cmp(maxBaseAsset) == 1) {
                    if (_orderSize.isNegative()) {
                        _orderSize_ = MixedDecimal
                            .fromDecimal(maxBaseAsset)
                            .mulScalar(-1);
                    } else {
                        _orderSize_ = MixedDecimal.fromDecimal(maxBaseAsset);
                    }
                }
            }

            return
                _handleClosePosition(
                    IAmm(_asset),
                    _closePositionPercentage(IAmm(_asset), _orderSize_),
                    Decimal.decimal(0)
                );
        } else {
            Decimal.decimal memory totalNotional = _collateral.mulD(_leverage);
            if (
                maxNotional.toUint() != 0 &&
                maxNotional.cmp(totalNotional) == -1
            ) {
                Decimal.decimal memory percentage = maxNotional.divD(
                    totalNotional
                );
                _orderSize = _orderSize.mulD(
                    MixedDecimal.fromDecimal(percentage)
                );
                _collateral = _collateral.mulD(percentage);
            }
            return
                _handleOpenPosition(
                    IAmm(_asset),
                    _orderSize_,
                    _collateral,
                    _leverage,
                    Decimal.decimal(0),
                    false
                );
        }
    }

    function _getOrderDetails(uint256 order_id)
        internal
        view
        returns (
            Decimal.decimal memory limitPrice,
            SignedDecimal.signedDecimal memory orderSize,
            Decimal.decimal memory collateral,
            Decimal.decimal memory leverage,
            Decimal.decimal memory slippage,
            address asset,
            bool reduceOnly
        )
    {
        (
            ILimitOrderBook.LimitOrder memory _limitOrder,
            ILimitOrderBook.RemainingOrderInfo memory _remainingOrder
        ) = orderBook.getLimitOrder(order_id);

        limitPrice = _limitOrder.limitPrice;
        leverage = _limitOrder.leverage;
        slippage = _limitOrder.slippage;
        asset = _limitOrder.asset;
        reduceOnly = _limitOrder.reduceOnly;
        if (_remainingOrder.remainingOrderSize.toInt() == 0) {
            orderSize = _limitOrder.orderSize;
            collateral = _limitOrder.collateral;
        } else {
            orderSize = _remainingOrder.remainingOrderSize;
            collateral = _remainingOrder.remainingCollateral;
        }
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Decimal} from "../utils/Decimal.sol";
import {SignedDecimal} from "../utils/SignedDecimal.sol";

interface IAmm {
    /**
     * @notice asset direction, used in getInputPrice, getOutputPrice, swapInput and swapOutput
     * @param ADD_TO_AMM add asset to Amm
     * @param REMOVE_FROM_AMM remove asset from Amm
     */
    enum Dir {
        ADD_TO_AMM,
        REMOVE_FROM_AMM
    }

    //
    // enum and struct
    //
    struct ReserveSnapshot {
        Decimal.decimal quoteAssetReserve;
        Decimal.decimal baseAssetReserve;
        uint256 timestamp;
        uint256 blockNumber;
    }

    // internal usage
    enum QuoteAssetDir {
        QUOTE_IN,
        QUOTE_OUT
    }
    // internal usage
    enum TwapCalcOption {
        RESERVE_ASSET,
        INPUT_ASSET
    }

    // To record current base/quote asset to calculate TWAP

    struct TwapInputAsset {
        Dir dir;
        Decimal.decimal assetAmount;
        QuoteAssetDir inOrOut;
    }

    struct TwapPriceCalcParams {
        TwapCalcOption opt;
        uint256 snapshotIndex;
        TwapInputAsset asset;
    }

    struct LiquidityChangedSnapshot {
        SignedDecimal.signedDecimal cumulativeNotional;
        // the base/quote reserve of amm right before liquidity changed
        Decimal.decimal quoteAssetReserve;
        Decimal.decimal baseAssetReserve;
        // total position size owned by amm after last snapshot taken
        // `totalPositionSize` = currentBaseAssetReserve - lastLiquidityChangedHistoryItem.baseAssetReserve + prevTotalPositionSize
        SignedDecimal.signedDecimal totalPositionSize;
    }

    function swapInput(
        Dir _dir,
        Decimal.decimal calldata _quoteAssetAmount,
        Decimal.decimal calldata _baseAssetAmountLimit,
        bool _canOverFluctuationLimit
    ) external returns (Decimal.decimal memory);

    function swapOutput(
        Dir _dir,
        Decimal.decimal calldata _baseAssetAmount,
        Decimal.decimal calldata _quoteAssetAmountLimit
    ) external returns (Decimal.decimal memory);

    function shutdown() external;

    function settleFunding()
        external
        returns (SignedDecimal.signedDecimal memory);

    //
    // VIEW
    //

    function isOverFluctuationLimit(
        Dir _dirOfBase,
        Decimal.decimal memory _baseAssetAmount
    ) external view returns (bool);

    function getInputTwap(Dir _dir, Decimal.decimal calldata _quoteAssetAmount)
        external
        view
        returns (Decimal.decimal memory);

    function getOutputTwap(Dir _dir, Decimal.decimal calldata _baseAssetAmount)
        external
        view
        returns (Decimal.decimal memory);

    function getInputPrice(Dir _dir, Decimal.decimal calldata _quoteAssetAmount)
        external
        view
        returns (Decimal.decimal memory);

    function getOutputPrice(Dir _dir, Decimal.decimal calldata _baseAssetAmount)
        external
        view
        returns (Decimal.decimal memory);

    function getInputPriceWithReserves(
        Dir _dir,
        Decimal.decimal memory _quoteAssetAmount,
        Decimal.decimal memory _quoteAssetPoolAmount,
        Decimal.decimal memory _baseAssetPoolAmount
    ) external pure returns (Decimal.decimal memory);

    function getOutputPriceWithReserves(
        Dir _dir,
        Decimal.decimal memory _baseAssetAmount,
        Decimal.decimal memory _quoteAssetPoolAmount,
        Decimal.decimal memory _baseAssetPoolAmount
    ) external pure returns (Decimal.decimal memory);

    function getSpotPrice() external view returns (Decimal.decimal memory);

    function getLiquidityHistoryLength() external view returns (uint256);

    function open() external view returns (bool);

    // can not be overridden by state variable due to type `Deciaml.decimal`
    function getSettlementPrice()
        external
        view
        returns (Decimal.decimal memory);

    function getCumulativeNotional()
        external
        view
        returns (SignedDecimal.signedDecimal memory);

    function getMaxHoldingBaseAsset()
        external
        view
        returns (Decimal.decimal memory);

    function getOpenInterestNotionalCap()
        external
        view
        returns (Decimal.decimal memory);

    function getLiquidityChangedSnapshots(uint256 i)
        external
        view
        returns (LiquidityChangedSnapshot memory);

    function getBaseAssetDelta()
        external
        view
        returns (SignedDecimal.signedDecimal memory);

    function getUnderlyingPrice()
        external
        view
        returns (Decimal.decimal memory);

    function isOverSpreadLimit() external view returns (bool);

    function getSnapshotLen() external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Decimal} from "../utils/Decimal.sol";
import {SignedDecimal} from "../utils/SignedDecimal.sol";
import {IAmm} from "./IAmm.sol";

interface IClearingHouse {
    //
    // Struct and Enum
    //

    enum Side {
        BUY,
        SELL
    }

    enum PnlCalcOption {
        SPOT_PRICE,
        TWAP,
        ORACLE
    }

    /// @param MAX_PNL most beneficial way for traders to calculate position notional
    /// @param MIN_PNL least beneficial way for traders to calculate position notional
    enum PnlPreferenceOption {
        MAX_PNL,
        MIN_PNL
    }

    /// @notice This struct records personal position information
    /// @param size denominated in amm.baseAsset
    /// @param margin isolated margin
    /// @param openNotional the quoteAsset value of position when opening position. the cost of the position
    /// @param lastUpdatedCumulativePremiumFraction for calculating funding payment, record at the moment every time when trader open/reduce/close position
    /// @param liquidityHistoryIndex
    /// @param blockNumber the block number of the last position
    struct Position {
        SignedDecimal.signedDecimal size;
        Decimal.decimal margin;
        Decimal.decimal openNotional;
        SignedDecimal.signedDecimal lastUpdatedCumulativePremiumFraction;
        uint256 liquidityHistoryIndex;
        uint256 blockNumber;
    }

    function addMargin(IAmm _amm, Decimal.decimal calldata _addedMargin)
        external;

    function removeMargin(IAmm _amm, Decimal.decimal calldata _removedMargin)
        external;

    function settlePosition(IAmm _amm) external;

    function openPosition(
        IAmm _amm,
        Side _side,
        Decimal.decimal calldata _quoteAssetAmount,
        Decimal.decimal calldata _leverage,
        Decimal.decimal calldata _baseAssetAmountLimit
    )
        external
        returns (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        );

    function closePosition(
        IAmm _amm,
        Decimal.decimal calldata _quoteAssetAmountLimit
    )
        external
        returns (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        );

    function closePartialPosition(
        IAmm _amm,
        Decimal.decimal memory _percentage,
        Decimal.decimal memory _quoteAssetAmountLimit
    )
        external
        returns (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        );

    function liquidate(IAmm _amm, address _trader) external;

    function payFunding(IAmm _amm) external;

    // VIEW FUNCTIONS
    function getMarginRatio(IAmm _amm, address _trader)
        external
        view
        returns (SignedDecimal.signedDecimal memory);

    function getPosition(IAmm _amm, address _trader)
        external
        view
        returns (Position memory);

    function getPositionNotionalAndUnrealizedPnl(
        IAmm _amm,
        address _trader,
        PnlCalcOption _pnlCalcOption
    )
        external
        view
        returns (
            Decimal.decimal memory positionNotional,
            SignedDecimal.signedDecimal memory unrealizedPnl
        );

    function getLatestCumulativePremiumFraction(IAmm _amm)
        external
        view
        returns (SignedDecimal.signedDecimal memory);

    function quoteToken() external view returns (IERC20);

    function calcFee(Decimal.decimal calldata _quoteAssetAmount, address _user)
        external
        view
        returns (Decimal.decimal memory);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {Decimal} from "../utils/Decimal.sol";
import {SignedDecimal} from "../utils/SignedDecimal.sol";

interface ILimitOrderBook {
    /*
     * EVENTS
     */

    event OrderCreated(address indexed trader, uint256 order_id);
    event OrderFilled(
        address indexed trader,
        address indexed operator,
        uint256 order_id,
        bool filledAll,
        int256 exchangedPositionSize,
        uint256 exchangedQuoteSize
    );
    event OrderCancelled(address indexed trader, uint256 order_id);

    /*
     * ENUMS
     */

    /*
     * Order types that the user is able to create.
     * Note that market orders are actually executed instantly on clearing house
     * therefore there should never actually be a market order in the LOB
     */
    enum OrderType {
        MARKET,
        LIMIT,
        STOPLOSS,
        CLOSEPOSITION
    }

    /*
     * STRUCTS
     */

    /*
     * @notice Every order is stored within a limit order struct (regardless of
     *    the type of order)
     * @param asset is the address of the perp AMM for that particular asset
     * @param trader is the user that created the order - note that the order will
     *   actually be executed on their smart wallet (as stored in the factory)
     * @param orderType represents the order type
     * @param reduceOnly whether the order is reduceOnly or not. A reduce only order
     *   will never increase the size of a position and will either reduce the size
     *   or close the position.
     * @param stillValid whether the order can be executed. There are two conditions
     *   where an order is no longer valid: the trader cancels the order, or the
     *   order gets executed (to prevent double spend)
     * @param expiry is the blockTimestamp when this order expires. If this value
     *   is 0 then the order will not expire
     * @param limitPrice is the trigger price for any limit order. a limit BUY can
     *   only be executed below/above this price, whilst a limit SELL is executed above/below
     * @param orderSize is the size of the order (denominated in the base asset)
     * @param collateral is the amount of collateral or margin that will be used
     *   for this order. This amount is guaranteed ie an order with 300 USDC will
     *   always use 300 USDC.
     * @param leverage is the maximum amount of leverage that the trader will accept.
     * @param slippage is the minimum amount of ASSET that the user will accept.
     *   The trader will usually achieve the amount specified by orderSize. This
     *   parameter allows the user to specify their tolerance to price impact / frontrunning
     * @param tipFee is the fee that goes to the keeper for executing the order.
     *   This fee is taken when the order is created, and paid out when executing.
     */
    struct LimitOrder {
        address asset;
        address trader;
        bool reduceOnly;
        bool stillValid;
        OrderType orderType;
        uint256 expiry;
        Decimal.decimal limitPrice;
        SignedDecimal.signedDecimal orderSize;
        Decimal.decimal collateral;
        Decimal.decimal leverage;
        Decimal.decimal slippage;
        Decimal.decimal tipFee;
    }

    struct RemainingOrderInfo {
        SignedDecimal.signedDecimal remainingOrderSize;
        Decimal.decimal remainingCollateral;
        Decimal.decimal remainingTipFee;
    }

    function getLimitOrder(uint256 id)
        external
        view
        returns (LimitOrder memory, RemainingOrderInfo memory);

    function getLimitOrderParams(uint256 id)
        external
        view
        returns (
            address,
            address,
            OrderType,
            bool,
            bool,
            uint256
        );
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {IAmm} from "./IAmm.sol";
import {Decimal} from "../utils/Decimal.sol";
import {SignedDecimal} from "../utils/SignedDecimal.sol";

interface ISmartWallet {
    function initialize(
        address _clearingHouse,
        address _limitOrderBook,
        address _owner
    ) external;

    function owner() external view returns (address);

    function executeCall(
        address target,
        bytes calldata callData,
        uint256 value
    ) external payable returns (bytes memory);

    function executeMarketOrder(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage
    ) external;

    function executeClosePosition(IAmm _asset, Decimal.decimal memory _slippage)
        external;

    function executeClosePartialPosition(
        IAmm _asset,
        Decimal.decimal memory _percentage,
        Decimal.decimal memory _slippage
    ) external;

    function executeOrder(uint256 order_id, Decimal.decimal memory maxNotional)
        external
        returns (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        );

    function executeAddMargin(
        IAmm _asset,
        Decimal.decimal calldata _addedMargin
    ) external;

    function executeRemoveMargin(
        IAmm _asset,
        Decimal.decimal calldata _removedMargin
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface ISmartWalletFactory {
    function getSmartWallet(address) external returns (address);

    function isWhitelisted(address) external returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {DecimalMath} from "./DecimalMath.sol";

library Decimal {
    using DecimalMath for uint256;

    struct decimal {
        uint256 d;
    }

    function zero() internal pure returns (decimal memory) {
        return decimal(0);
    }

    function one() internal pure returns (decimal memory) {
        return decimal(DecimalMath.unit(18));
    }

    function toUint(decimal memory x) internal pure returns (uint256) {
        return x.d;
    }

    function modD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        return decimal((x.d * DecimalMath.unit(18)) % y.d);
    }

    function cmp(decimal memory x, decimal memory y)
        internal
        pure
        returns (int8)
    {
        if (x.d > y.d) {
            return 1;
        } else if (x.d < y.d) {
            return -1;
        }
        return 0;
    }

    /// @dev add two decimals
    function addD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d + y.d;
        return t;
    }

    /// @dev subtract two decimals
    function subD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d - y.d;
        return t;
    }

    /// @dev multiple two decimals
    function mulD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d.muld(y.d);
        return t;
    }

    /// @dev multiple a decimal by a uint256
    function mulScalar(decimal memory x, uint256 y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d * y;
        return t;
    }

    /// @dev divide two decimals
    function divD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d.divd(y.d);
        return t;
    }

    /// @dev divide a decimal by a uint256
    function divScalar(decimal memory x, uint256 y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d / y;
        return t;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

/// @dev Implements simple fixed point math add, sub, mul and div operations.
/// @author Alberto Cuesta Cañada
library DecimalMath {
    /// @dev Returns 1 in the fixed point representation, with `decimals` decimals.
    function unit(uint8 decimals) internal pure returns (uint256) {
        return 10**uint256(decimals);
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with 18 digits.
    function muld(uint256 x, uint256 y) internal pure returns (uint256) {
        return muld(x, y, 18);
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with `decimals` digits.
    function muld(
        uint256 x,
        uint256 y,
        uint8 decimals
    ) internal pure returns (uint256) {
        return (x * y) / unit(decimals);
    }

    /// @dev Divides x between y, assuming they are both fixed point with 18 digits.
    function divd(uint256 x, uint256 y) internal pure returns (uint256) {
        return divd(x, y, 18);
    }

    /// @dev Divides x between y, assuming they are both fixed point with `decimals` digits.
    function divd(
        uint256 x,
        uint256 y,
        uint8 decimals
    ) internal pure returns (uint256) {
        return (x * unit(decimals)) / y;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Decimal} from "./Decimal.sol";
import {SignedDecimal} from "./SignedDecimal.sol";

/// @dev To handle a signedDecimal add/sub/mul/div a decimal and provide convert decimal to signedDecimal helper
library MixedDecimal {
    using SignedDecimal for SignedDecimal.signedDecimal;

    uint256 private constant _INT256_MAX = 2**255 - 1;
    string private constant ERROR_NON_CONVERTIBLE =
        "MixedDecimal: uint value is bigger than _INT256_MAX";

    modifier convertible(Decimal.decimal memory x) {
        require(_INT256_MAX >= x.d, ERROR_NON_CONVERTIBLE);
        _;
    }

    function fromDecimal(Decimal.decimal memory x)
        internal
        pure
        convertible(x)
        returns (SignedDecimal.signedDecimal memory)
    {
        return SignedDecimal.signedDecimal(int256(x.d));
    }

    function toUint(SignedDecimal.signedDecimal memory x)
        internal
        pure
        returns (uint256)
    {
        return x.abs().d;
    }

    function addD(
        SignedDecimal.signedDecimal memory x,
        Decimal.decimal memory y
    )
        internal
        pure
        convertible(y)
        returns (SignedDecimal.signedDecimal memory)
    {
        SignedDecimal.signedDecimal memory t;
        t.d = x.d + int256(y.d);
        return t;
    }

    function subD(
        SignedDecimal.signedDecimal memory x,
        Decimal.decimal memory y
    )
        internal
        pure
        convertible(y)
        returns (SignedDecimal.signedDecimal memory)
    {
        SignedDecimal.signedDecimal memory t;
        t.d = x.d - int256(y.d);
        return t;
    }

    /// @dev multiple a SignedDecimal.signedDecimal by Decimal.decimal
    function mulD(
        SignedDecimal.signedDecimal memory x,
        Decimal.decimal memory y
    )
        internal
        pure
        convertible(y)
        returns (SignedDecimal.signedDecimal memory)
    {
        SignedDecimal.signedDecimal memory t;
        t = x.mulD(fromDecimal(y));
        return t;
    }

    /// @dev multiple a SignedDecimal.signedDecimal by a uint256
    function mulScalar(SignedDecimal.signedDecimal memory x, uint256 y)
        internal
        pure
        returns (SignedDecimal.signedDecimal memory)
    {
        require(_INT256_MAX >= y, ERROR_NON_CONVERTIBLE);
        SignedDecimal.signedDecimal memory t;
        t = x.mulScalar(int256(y));
        return t;
    }

    /// @dev divide a SignedDecimal.signedDecimal by a Decimal.decimal
    function divD(
        SignedDecimal.signedDecimal memory x,
        Decimal.decimal memory y
    )
        internal
        pure
        convertible(y)
        returns (SignedDecimal.signedDecimal memory)
    {
        SignedDecimal.signedDecimal memory t;
        t = x.divD(fromDecimal(y));
        return t;
    }

    /// @dev divide a SignedDecimal.signedDecimal by a uint256
    function divScalar(SignedDecimal.signedDecimal memory x, uint256 y)
        internal
        pure
        returns (SignedDecimal.signedDecimal memory)
    {
        require(_INT256_MAX >= y, ERROR_NON_CONVERTIBLE);
        SignedDecimal.signedDecimal memory t;
        t = x.divScalar(int256(y));
        return t;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {SignedDecimalMath} from "./SignedDecimalMath.sol";
import {Decimal} from "./Decimal.sol";

library SignedDecimal {
    using SignedDecimalMath for int256;

    struct signedDecimal {
        int256 d;
    }

    function zero() internal pure returns (signedDecimal memory) {
        return signedDecimal(0);
    }

    function toInt(signedDecimal memory x) internal pure returns (int256) {
        return x.d;
    }

    function isNegative(signedDecimal memory x) internal pure returns (bool) {
        if (x.d < 0) {
            return true;
        }
        return false;
    }

    function abs(signedDecimal memory x)
        internal
        pure
        returns (Decimal.decimal memory)
    {
        Decimal.decimal memory t;
        if (x.d < 0) {
            t.d = uint256(0 - x.d);
        } else {
            t.d = uint256(x.d);
        }
        return t;
    }

    /// @dev add two decimals
    function addD(signedDecimal memory x, signedDecimal memory y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d + y.d;
        return t;
    }

    /// @dev subtract two decimals
    function subD(signedDecimal memory x, signedDecimal memory y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d - y.d;
        return t;
    }

    /// @dev multiple two decimals
    function mulD(signedDecimal memory x, signedDecimal memory y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d.muld(y.d);
        return t;
    }

    /// @dev multiple a signedDecimal by a int256
    function mulScalar(signedDecimal memory x, int256 y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d * y;
        return t;
    }

    /// @dev divide two decimals
    function divD(signedDecimal memory x, signedDecimal memory y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d.divd(y.d);
        return t;
    }

    /// @dev divide a signedDecimal by a int256
    function divScalar(signedDecimal memory x, int256 y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d / y;
        return t;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

/// @dev Implements simple signed fixed point math add, sub, mul and div operations.
library SignedDecimalMath {
    /// @dev Returns 1 in the fixed point representation, with `decimals` decimals.
    function unit(uint8 decimals) internal pure returns (int256) {
        return int256(10**uint256(decimals));
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with 18 digits.
    function muld(int256 x, int256 y) internal pure returns (int256) {
        return muld(x, y, 18);
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with `decimals` digits.
    function muld(
        int256 x,
        int256 y,
        uint8 decimals
    ) internal pure returns (int256) {
        return (x * y) / unit(decimals);
    }

    /// @dev Divides x between y, assuming they are both fixed point with 18 digits.
    function divd(int256 x, int256 y) internal pure returns (int256) {
        return divd(x, y, 18);
    }

    /// @dev Divides x between y, assuming they are both fixed point with `decimals` digits.
    function divd(
        int256 x,
        int256 y,
        uint8 decimals
    ) internal pure returns (int256) {
        return (x * unit(decimals)) / y;
    }
}