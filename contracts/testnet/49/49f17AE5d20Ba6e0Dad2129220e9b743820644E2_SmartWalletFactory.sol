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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

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
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
import {DecimalERC20} from "./utils/DecimalERC20.sol";

import {IAmm} from "./interface/IAmm.sol";
import {IClearingHouse} from "./interface/IClearingHouse.sol";
import {ISmartWallet} from "./interface/ISmartWallet.sol";
import {ISmartWalletFactory} from "./interface/ISmartWalletFactory.sol";
import {ILimitOrderBook} from "./interface/ILimitOrderBook.sol";

contract SmartWallet is DecimalERC20, Initializable, ISmartWallet, Pausable {
    using Decimal for Decimal.decimal;
    using SignedDecimal for SignedDecimal.signedDecimal;
    using Address for address;
    using SafeERC20 for IERC20;

    event ExecuteMarketOrder(
        address indexed trader,
        address asset,
        SignedDecimal.signedDecimal orderSize,
        Decimal.decimal collateral,
        Decimal.decimal leverage,
        Decimal.decimal slippage
    );

    event ExecuteClosePosition(address indexed trader, address asset);

    // Store addresses of smart contracts that we will be interacting with
    ILimitOrderBook public orderBook;
    ISmartWalletFactory public factory;
    IClearingHouse public clearingHouse;

    address private owner;

    function initialize(
        address _clearingHouse,
        address _limitOrderBook,
        address _owner
    ) external override initializer {
        clearingHouse = IClearingHouse(_clearingHouse);
        orderBook = ILimitOrderBook(_limitOrderBook);
        factory = ISmartWalletFactory(msg.sender);
        owner = _owner;
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
        require(target.isContract(), "call to non-contract");
        require(factory.isWhitelisted(target), "Invalid target contract");
        return target.functionCallWithValue(callData, value);
    }

    function executeMarketOrder(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage
    ) external override onlyOwner whenNotPaused {
        _handleOpenPositionWithApproval(
            _asset,
            _orderSize,
            _collateral,
            _leverage,
            _slippage
        );

        emit ExecuteMarketOrder(
            owner,
            address(_asset),
            _orderSize,
            _collateral,
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
        _handleClosePositionWithApproval(_asset, _slippage);

        emit ExecuteClosePosition(owner, address(_asset));
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
    function executeOrder(uint256 order_id) external override whenNotPaused {
        //Only the LimitOrderBook can call this function
        require(
            msg.sender == address(orderBook),
            "Only execute from the order book"
        );
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
            "Incorrect smart wallet"
        );
        //Make sure that the order hasn't expired
        require(
            ((_expiry == 0) || (block.timestamp < _expiry)),
            "Order expired"
        );
        //Make sure the order is still valid
        require(_stillValid, "Order no longer valid");
        //Perform function depending on the type of order

        if (_orderType == ILimitOrderBook.OrderType.LIMIT) {
            _executeLimitOrder(order_id);
        } else if (_orderType == ILimitOrderBook.OrderType.STOPMARKET) {
            _executeStopOrder(order_id);
        } else if (_orderType == ILimitOrderBook.OrderType.STOPLIMIT) {
            _executeStopLimitOrder(order_id);
        } else if (_orderType == ILimitOrderBook.OrderType.TRAILINGSTOPMARKET) {
            _executeStopOrder(order_id);
        } else if (_orderType == ILimitOrderBook.OrderType.TRAILINGSTOPLIMIT) {
            _executeStopLimitOrder(order_id);
        }
    }

    function minD(Decimal.decimal memory a, Decimal.decimal memory b)
        internal
        pure
        returns (Decimal.decimal memory)
    {
        return (a.cmp(b) >= 1) ? b : a;
    }

    function _handleOpenPositionWithApproval(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage
    ) internal {
        //Get cost of placing order (fees)
        (Decimal.decimal memory toll, Decimal.decimal memory spread) = _asset
            .calcFee(_collateral.mulD(_leverage));
        Decimal.decimal memory totalCost = _collateral.addD(toll).addD(spread);

        IERC20 quoteAsset = _asset.quoteAsset();
        _approve(quoteAsset, address(clearingHouse), totalCost);

        //Establish how much leverage will be needed for that order based on the
        //amount of collateral and the maximum leverage the user was happy with.
        bool _isLong = _orderSize.isNegative() ? false : true;

        Decimal.decimal memory _size = _orderSize.abs();
        Decimal.decimal memory _quote = (
            IAmm(_asset).getOutputPrice(
                _isLong ? IAmm.Dir.REMOVE_FROM_AMM : IAmm.Dir.ADD_TO_AMM,
                _size
            )
        );
        Decimal.decimal memory _offset = Decimal.decimal(1); //Need to add one wei for rounding
        _leverage = minD(_quote.divD(_collateral).addD(_offset), _leverage);

        clearingHouse.openPosition(
            _asset,
            _isLong ? IClearingHouse.Side.BUY : IClearingHouse.Side.SELL,
            _collateral,
            _leverage,
            _slippage
        );
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

    function _handleClosePositionWithApproval(
        IAmm _asset,
        Decimal.decimal memory _slippage
    ) internal {
        //Need to calculate trading fees to close position (no margin required)
        IClearingHouse.Position memory oldPosition = clearingHouse.getPosition(
            _asset,
            address(this)
        );
        SignedDecimal.signedDecimal memory oldPositionSize = oldPosition.size;
        Decimal.decimal memory _quoteAsset = _asset.getOutputPrice(
            oldPositionSize.toInt() > 0
                ? IAmm.Dir.ADD_TO_AMM
                : IAmm.Dir.REMOVE_FROM_AMM,
            oldPositionSize.abs()
        );
        (Decimal.decimal memory toll, Decimal.decimal memory spread) = _asset
            .calcFee(_quoteAsset);
        Decimal.decimal memory totalCost = toll.addD(spread);

        IERC20 quoteAsset = _asset.quoteAsset();
        _approve(quoteAsset, address(clearingHouse), totalCost);

        clearingHouse.closePosition(_asset, _slippage);
    }

    /*
     * @notice check what this order should do if it is reduceOnly
     *  To clarify, only reduceOnly orders should call this function:
     *    If it returns true, then the order should close the position rather than
     *    opening one.
     * @param _asset the AMM for the asset
     * @param _orderSize the size of the order (note: negative are SELL/SHORt)
     */
    function _shouldCloseReduceOnly(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize
    ) internal view returns (bool) {
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
            if (_orderSize.abs().cmp(_currentSize.abs()) != -1) {
                return true;
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
    function _executeLimitOrder(uint256 order_id) internal {
        //Get information of limit order
        (
            ,
            Decimal.decimal memory _limitPrice,
            SignedDecimal.signedDecimal memory _orderSize,
            Decimal.decimal memory _collateral,
            Decimal.decimal memory _leverage,
            Decimal.decimal memory _slippage,
            ,
            address _asset,
            bool _reduceOnly
        ) = orderBook.getLimitOrderPrices(order_id);

        //Check whether we need to close position or open position
        bool closePosition = false;
        if (_reduceOnly) {
            closePosition = _shouldCloseReduceOnly(IAmm(_asset), _orderSize);
        }

        //Establish whether long or short
        bool isLong = _orderSize.isNegative() ? false : true;
        //Get the current spot price of the asset
        Decimal.decimal memory _markPrice = IAmm(_asset).getSpotPrice();
        require(
            _markPrice.cmp(Decimal.zero()) >= 1,
            "Error getting mark price"
        );

        //Check whether price conditions have been met:
        //  LIMIT BUY: mark price < limit price
        //  LIMIT SELL: mark price > limit price
        require(
            (_limitPrice.cmp(_markPrice)) == (isLong ? int128(1) : -1),
            "Invalid limit order condition"
        );

        if (closePosition) {
            Decimal.decimal memory quoteAssetLimit = _calcQuoteAssetAmountLimit(
                IAmm(_asset),
                _limitPrice,
                isLong,
                _slippage
            );
            _handleClosePositionWithApproval(IAmm(_asset), quoteAssetLimit);
        } else {
            //openPosition using the values calculated above
            Decimal.decimal memory baseAssetLimit = _calcBaseAssetAmountLimit(
                _orderSize.abs(),
                isLong,
                _slippage
            );
            _handleOpenPositionWithApproval(
                IAmm(_asset),
                _orderSize,
                _collateral,
                _leverage,
                baseAssetLimit
            );
        }
    }

    function _executeStopOrder(uint256 order_id) internal {
        //Get information of stop order
        (
            Decimal.decimal memory _stopPrice,
            ,
            SignedDecimal.signedDecimal memory _orderSize,
            Decimal.decimal memory _collateral,
            Decimal.decimal memory _leverage,
            ,
            ,
            address _asset,
            bool _reduceOnly
        ) = orderBook.getLimitOrderPrices(order_id);

        //Check whether we need to close position or open position
        bool closePosition = false;
        if (_reduceOnly) {
            closePosition = _shouldCloseReduceOnly(IAmm(_asset), _orderSize);
        }

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
            (_markPrice.cmp(_stopPrice)) == (isLong ? int128(1) : -1),
            "Invalid stop order conditions"
        );

        //Strictly speaking, stop orders cannot have slippage as by definition they
        //will get executed at the next available price. Restricting them with slippage
        //will turn them into stop limit orders.
        if (closePosition) {
            _handleClosePositionWithApproval(IAmm(_asset), Decimal.decimal(0));
        } else {
            _handleOpenPositionWithApproval(
                IAmm(_asset),
                _orderSize,
                _collateral,
                _leverage,
                Decimal.decimal(0)
            );
        }
    }

    function _executeStopLimitOrder(uint256 order_id) internal {
        //Get information of stop limit order
        (
            Decimal.decimal memory _stopPrice,
            Decimal.decimal memory _limitPrice,
            SignedDecimal.signedDecimal memory _orderSize,
            Decimal.decimal memory _collateral,
            Decimal.decimal memory _leverage,
            Decimal.decimal memory _slippage,
            ,
            address _asset,
            bool _reduceOnly
        ) = orderBook.getLimitOrderPrices(order_id);

        //Check whether we need to close position or open position
        bool closePosition = false;
        if (_reduceOnly) {
            closePosition = _shouldCloseReduceOnly(IAmm(_asset), _orderSize);
        }

        //Establish whether long or short
        bool isLong = _orderSize.isNegative() ? false : true;
        //Get the current spot price of the asset
        Decimal.decimal memory _markPrice = IAmm(_asset).getSpotPrice();
        require(
            _markPrice.cmp(Decimal.zero()) >= 1,
            "Error getting mark price"
        );
        //Check whether price conditions have been met:
        //  STOP LIMIT BUY: limit price > mark price > stop price
        //  STOP LIMIT SELL: limit price < mark price < stop price
        require(
            (_limitPrice.cmp(_markPrice)) == (isLong ? int128(1) : -1) &&
                (_markPrice.cmp(_stopPrice)) == (isLong ? int128(1) : -1),
            "Invalid stop-limit condition"
        );
        if (closePosition) {
            Decimal.decimal memory quoteAssetLimit = _calcQuoteAssetAmountLimit(
                IAmm(_asset),
                _limitPrice,
                isLong,
                _slippage
            );
            _handleClosePositionWithApproval(IAmm(_asset), quoteAssetLimit);
        } else {
            //openPosition using the values calculated above
            Decimal.decimal memory baseAssetLimit = _calcBaseAssetAmountLimit(
                _orderSize.abs(),
                isLong,
                _slippage
            );
            _handleOpenPositionWithApproval(
                IAmm(_asset),
                _orderSize,
                _collateral,
                _leverage,
                baseAssetLimit
            );
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

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SmartWallet} from "./SmartWallet.sol";
import {ISmartWalletFactory} from "./interface/ISmartWalletFactory.sol";

contract SmartWalletFactory is ISmartWalletFactory, Ownable {
    event Created(address indexed owner, address indexed smartWallet);

    mapping(address => address) public override getSmartWallet;
    mapping(address => bool) public override isWhitelisted;

    address public immutable limitOrderBook;
    address public immutable clearingHouse;

    constructor(address _clearingHouse, address _limitOrderBook) {
        clearingHouse = _clearingHouse;
        limitOrderBook = _limitOrderBook;
    }

    /*
     * @notice Create and deploy a smart wallet for the user and stores the address
     */
    function spawn() external returns (address smartWallet) {
        require(
            getSmartWallet[msg.sender] == address(0),
            "Already has smart wallet"
        );

        bytes memory bytecode = type(SmartWallet).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender));
        assembly {
            smartWallet := create2(
                0,
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )
        }

        emit Created(msg.sender, smartWallet);
        SmartWallet(smartWallet).initialize(
            clearingHouse,
            limitOrderBook,
            msg.sender
        );
        getSmartWallet[msg.sender] = smartWallet;
    }

    function addToWhitelist(address _contract) external onlyOwner {
        isWhitelisted[_contract] = true;
    }

    function removeFromWhitelist(address _contract) external onlyOwner {
        isWhitelisted[_contract] = false;
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

    function calcFee(Decimal.decimal calldata _quoteAssetAmount)
        external
        view
        returns (Decimal.decimal memory, Decimal.decimal memory);

    //
    // VIEW
    //

    function isOverFluctuationLimit(
        Dir _dirOfBase,
        Decimal.decimal memory _baseAssetAmount
    ) external view returns (bool);

    function calcBaseAssetAfterLiquidityMigration(
        SignedDecimal.signedDecimal memory _baseAssetAmount,
        Decimal.decimal memory _fromQuoteReserve,
        Decimal.decimal memory _fromBaseReserve
    ) external view returns (SignedDecimal.signedDecimal memory);

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

    // overridden by state variable
    function quoteAsset() external view returns (IERC20);

    function open() external view returns (bool);

    // can not be overridden by state variable due to type `Deciaml.decimal`
    function getSettlementPrice()
        external
        view
        returns (Decimal.decimal memory);

    function getBaseAssetDeltaThisFundingPeriod()
        external
        view
        returns (SignedDecimal.signedDecimal memory);

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

import {Decimal} from "../utils/Decimal.sol";
import {SignedDecimal} from "../utils/SignedDecimal.sol";
import {IAmm} from "./IAmm.sol";

interface IClearingHouse {
    enum Side {
        BUY,
        SELL
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
    ) external;

    function closePosition(
        IAmm _amm,
        Decimal.decimal calldata _quoteAssetAmountLimit
    ) external;

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
    event OrderFilled(address indexed trader, uint256 order_id);
    event OrderChanged(address indexed trader, uint256 order_id);
    event OrderCancelled(address indexed trader, uint256 order_id);

    event TrailingOrderCreated(uint256 order_id, uint256 snapshotIndex);
    event TrailingOrderFilled(uint256 order_id);
    event TrailingOrderChanged(uint256 order_id);
    event TrailingOrderCancelled(uint256 order_id);
    event ContractPoked(uint256 order_id, uint256 reserve_index);

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
        STOPMARKET,
        STOPLIMIT,
        TRAILINGSTOPMARKET,
        TRAILINGSTOPLIMIT,
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
     * @param stopPrice is the trigger price for any stop order. A stop BUY can
     *   only be executed above this price, whilst a stop SELL is executed below
     * @param limitPrice is the trigger price for any limit order. a limit BUY can
     *   only be executed below this price, whilst a limit SELL is executed above
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
        Decimal.decimal stopPrice;
        Decimal.decimal limitPrice;
        SignedDecimal.signedDecimal orderSize;
        Decimal.decimal collateral;
        Decimal.decimal leverage;
        Decimal.decimal slippage;
        Decimal.decimal tipFee;
    }

    /*
     * @notice Additional information is stored for trailing orders below
     * @param witnessPrice is either the highest or lowest price witnessed by an order.
     *    The trailing stop/limit trigger prices are calculated from this value.
     * @param trail is the absolute difference between the witnessPrice and stop price
     * @param trailPct is a percentage (number between 0 and 1) that is used to
     *    calculate a relative stop price
     * @param gap is the absolute difference between the witnessPrice and limit price
     * @param gapPct is a percentage (number between 0 and 1) that is used to
     *    calculate a relative limit price
     * @param usePct whether the trigger prices are calculated relatively or absolutely
     * @param snapshotCreated the index of reserveSnapshotted on AMM contract when
     *    the trailing order was created
     * @param snapshotLastUpdated the index when the witness price was last updated
     * @param snapshotTimestamp the timestamp when the order was last updated
     * @param lastUpdatedKeeper the last address that successfully updated the witness
     *    price. This address will be paid on execution of the order
     */
    struct TrailingOrderData {
        Decimal.decimal witnessPrice;
        Decimal.decimal trail;
        Decimal.decimal trailPct;
        Decimal.decimal gap;
        Decimal.decimal gapPct;
        uint256 snapshotCreated;
        uint256 snapshotLastUpdated;
        uint256 snapshotTimestamp;
        address lastUpdatedKeeper;
        bool usePct;
    }

    function getLimitOrderPrices(uint256 id)
        external
        view
        returns (
            Decimal.decimal memory,
            Decimal.decimal memory,
            SignedDecimal.signedDecimal memory,
            Decimal.decimal memory,
            Decimal.decimal memory,
            Decimal.decimal memory,
            Decimal.decimal memory,
            address,
            bool
        );

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

    function executeCall(
        address target,
        bytes calldata callData,
        uint256 value
    ) external payable returns (bytes memory);

    function executeMarketOrder(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage
    ) external;

    function executeClosePosition(IAmm _asset, Decimal.decimal memory _slippage)
        external;

    function executeOrder(uint256 order_id) external;
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

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Decimal} from "./Decimal.sol";

abstract contract DecimalERC20 {
    using Decimal for Decimal.decimal;

    mapping(address => uint256) private decimalMap;

    //◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤ add state variables below ◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤//

    //◢◣◢◣◢◣◢◣◢◣◢◣◢◣◢◣ add state variables above ◢◣◢◣◢◣◢◣◢◣◢◣◢◣◢◣//

    //
    // INTERNAL functions
    //

    // CAUTION: do not input _from == _to s.t. this function will always fail
    function _transfer(
        IERC20 _token,
        address _to,
        Decimal.decimal memory _value
    ) internal {
        _updateDecimal(address(_token));
        Decimal.decimal memory balanceBefore = _balanceOf(_token, _to);
        uint256 roundedDownValue = _toUint(_token, _value);

        // solhint-disable avoid-low-level-calls
        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(
                _token.transfer.selector,
                _to,
                roundedDownValue
            )
        );

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "DecimalERC20: transfer failed"
        );
        _validateBalance(_token, _to, roundedDownValue, balanceBefore);
    }

    function _transferFrom(
        IERC20 _token,
        address _from,
        address _to,
        Decimal.decimal memory _value
    ) internal {
        _updateDecimal(address(_token));
        Decimal.decimal memory balanceBefore = _balanceOf(_token, _to);
        uint256 roundedDownValue = _toUint(_token, _value);

        // solhint-disable avoid-low-level-calls
        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(
                _token.transferFrom.selector,
                _from,
                _to,
                roundedDownValue
            )
        );

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "DecimalERC20: transferFrom failed"
        );
        _validateBalance(_token, _to, roundedDownValue, balanceBefore);
    }

    function _approve(
        IERC20 _token,
        address _spender,
        Decimal.decimal memory _value
    ) internal {
        _updateDecimal(address(_token));
        // to be compatible with some erc20 tokens like USDT
        __approve(_token, _spender, Decimal.zero());
        __approve(_token, _spender, _value);
    }

    //
    // VIEW
    //
    function _allowance(
        IERC20 _token,
        address _owner,
        address _spender
    ) internal view returns (Decimal.decimal memory) {
        return _toDecimal(_token, _token.allowance(_owner, _spender));
    }

    function _balanceOf(IERC20 _token, address _owner)
        internal
        view
        returns (Decimal.decimal memory)
    {
        return _toDecimal(_token, _token.balanceOf(_owner));
    }

    function _totalSupply(IERC20 _token)
        internal
        view
        returns (Decimal.decimal memory)
    {
        return _toDecimal(_token, _token.totalSupply());
    }

    function _toDecimal(IERC20 _token, uint256 _number)
        internal
        view
        returns (Decimal.decimal memory)
    {
        uint256 tokenDecimals = _getTokenDecimals(address(_token));
        if (tokenDecimals >= 18) {
            return Decimal.decimal(_number / (10**(tokenDecimals - 18)));
        }

        return Decimal.decimal(_number * (10**(uint256(18) - tokenDecimals)));
    }

    function _toUint(IERC20 _token, Decimal.decimal memory _decimal)
        internal
        view
        returns (uint256)
    {
        uint256 tokenDecimals = _getTokenDecimals(address(_token));
        if (tokenDecimals >= 18) {
            return _decimal.toUint() * (10**(tokenDecimals - 18));
        }
        return _decimal.toUint() / (10**(uint256(18) - tokenDecimals));
    }

    function _getTokenDecimals(address _token) internal view returns (uint256) {
        uint256 tokenDecimals = decimalMap[_token];
        if (tokenDecimals == 0) {
            (bool success, bytes memory data) = _token.staticcall(
                abi.encodeWithSignature("decimals()")
            );
            require(
                success && data.length != 0,
                "DecimalERC20: get decimals failed"
            );
            tokenDecimals = abi.decode(data, (uint256));
        }
        return tokenDecimals;
    }

    //
    // PRIVATE
    //
    function _updateDecimal(address _token) private {
        uint256 tokenDecimals = _getTokenDecimals(_token);
        if (decimalMap[_token] != tokenDecimals) {
            decimalMap[_token] = tokenDecimals;
        }
    }

    function __approve(
        IERC20 _token,
        address _spender,
        Decimal.decimal memory _value
    ) private {
        // solhint-disable avoid-low-level-calls
        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(
                _token.approve.selector,
                _spender,
                _toUint(_token, _value)
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "DecimalERC20: approve failed"
        );
    }

    // To prevent from deflationary token, check receiver's balance is as expectation.
    function _validateBalance(
        IERC20 _token,
        address _to,
        uint256 _roundedDownValue,
        Decimal.decimal memory _balanceBefore
    ) private view {
        require(
            _balanceOf(_token, _to).cmp(
                _balanceBefore.addD(_toDecimal(_token, _roundedDownValue))
            ) == 0,
            "DecimalERC20: balance inconsistent"
        );
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

    /// @dev Adds x and y, assuming they are both fixed point with 18 decimals.
    function addd(uint256 x, uint256 y) internal pure returns (uint256) {
        return x + y;
    }

    /// @dev Subtracts y from x, assuming they are both fixed point with 18 decimals.
    function subd(uint256 x, uint256 y) internal pure returns (uint256) {
        return x - y;
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

    /// @dev Adds x and y, assuming they are both fixed point with 18 decimals.
    function addd(int256 x, int256 y) internal pure returns (int256) {
        return x + y;
    }

    /// @dev Subtracts y from x, assuming they are both fixed point with 18 decimals.
    function subd(int256 x, int256 y) internal pure returns (int256) {
        return x - y;
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