// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    error InvalidAccount();

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

error TokenAddressIsZero();
error TokenNotSupported();
error CannotBridgeToSameNetwork();
error ZeroPostSwapBalance();
error NoSwapDataProvided();
error NativeValueWithERC();
error ContractCallNotAllowed();
error NullAddrIsNotAValidSpender();
error NullAddrIsNotAnERC20Token();
error NoTransferToNullAddress();
error NativeAssetTransferFailed();
error InvalidBridgeConfigLength();
error InvalidAmount();
error InvalidContract();
error InvalidConfig();
error UnsupportedChainId(uint256 chainId);
error InvalidReceiver();
error InvalidDestinationChain();
error InvalidSendingToken();
error InvalidCaller();
error AlreadyInitialized();
error NotInitialized();
error OnlyContractOwner();
error CannotAuthoriseSelf();
error RecoveryAddressCannotBeZero();
error CannotDepositNativeToken();
error InvalidCallData();
error NativeAssetNotSupported();
error UnAuthorized();
error NoSwapFromZeroBalance();
error InvalidFallbackAddress();
error CumulativeSlippageTooHigh(uint256 minAmount, uint256 receivedAmount);
error InsufficientBalance(uint256 required, uint256 balance);
error ZeroAmount();
error ZeroAddress();
error InvalidFee();
error InformationMismatch();
error LengthMissmatch();
error NotAContract();
error NotEnoughBalance(uint256 requested, uint256 available);
error InsufficientMessageValue();
error ExternalCallFailed();
error ReentrancyError();

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/// @title Reentrancy Guard
/// @notice Abstract contract to provide protection against reentrancy
abstract contract ReentrancyGuard {
    /// Storage ///

    bytes32 private constant NAMESPACE =
        keccak256("com.rubic.reentrancyguard");

    /// Types ///

    struct ReentrancyStorage {
        uint256 status;
    }

    /// Errors ///

    error ReentrancyError();

    /// Constants ///

    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    /// Modifiers ///

    modifier nonReentrant() {
        ReentrancyStorage storage s = reentrancyStorage();
        if (s.status == _ENTERED) revert ReentrancyError();
        s.status = _ENTERED;
        _;
        s.status = _NOT_ENTERED;
    }

    /// Private Methods ///

    /// @dev fetch local storage
    function reentrancyStorage()
        private
        pure
        returns (ReentrancyStorage storage data)
    {
        bytes32 position = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data.slot := position
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC173 } from "../Interfaces/IERC173.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";

contract TransferrableOwnership is IERC173 {
    address public owner;
    address public pendingOwner;

    /// Errors ///
    error UnAuthorized();
    error NoNullOwner();
    error NewOwnerMustNotBeSelf();
    error NoPendingOwnershipTransfer();
    error NotPendingOwner();

    /// Events ///
    event OwnershipTransferRequested(
        address indexed _from,
        address indexed _to
    );

    constructor(address initialOwner) {
        owner = initialOwner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert UnAuthorized();
        _;
    }

    /// @notice Initiates transfer of ownership to a new address
    /// @param _newOwner the address to transfer ownership to
    function transferOwnership(address _newOwner) external onlyOwner {
        if (_newOwner == LibAsset.NULL_ADDRESS) revert NoNullOwner();
        if (_newOwner == msg.sender) revert NewOwnerMustNotBeSelf();
        pendingOwner = _newOwner;
        emit OwnershipTransferRequested(msg.sender, pendingOwner);
    }

    /// @notice Cancel transfer of ownership
    function cancelOwnershipTransfer() external onlyOwner {
        if (pendingOwner == LibAsset.NULL_ADDRESS)
            revert NoPendingOwnershipTransfer();
        pendingOwner = LibAsset.NULL_ADDRESS;
    }

    /// @notice Confirms transfer of ownership to the calling address (msg.sender)
    function confirmOwnershipTransfer() external {
        address _pendingOwner = pendingOwner;
        if (msg.sender != _pendingOwner) revert NotPendingOwner();
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = LibAsset.NULL_ADDRESS;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title ERC-173 Contract Ownership Standard
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
/* is ERC165 */
interface IERC173 {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @notice Get the address of the owner
    /// @return owner_ The address of the owner.
    function owner() external view returns (address owner_);

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20Proxy {
    function transferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IFeesFacet {
    struct IntegratorFeeInfo {
        bool isIntegrator; // flag for setting 0 fees for integrator      - 1 byte
        uint32 tokenFee; // total fee percent gathered from user          - 4 bytes
        uint32 RubicTokenShare; // token share of platform commission     - 4 bytes
        uint32 RubicFixedCryptoShare; // native share of fixed commission - 4 bytes
        uint128 fixedFeeAmount; // custom fixed fee amount                - 16 bytes
    }

    /**
     * @dev Initializes the FeesFacet with treasury address and max fee amount
     * No need to check initialized status because if max fee is 0 than there is no token fees
     * @param _feeTreasure Address to send fees to
     * @param _maxRubicPlatformFee Max value of Tubic token fees
     */
    function initialize(
        address _feeTreasure,
        uint256 _maxRubicPlatformFee,
        uint256 _maxFixedNativeFee
    ) external;

    /**
     * @dev Sets fee info associated with an integrator
     * @param _integrator Address of the integrator
     * @param _info Struct with fee info
     */
    function setIntegratorInfo(
        address _integrator,
        IntegratorFeeInfo memory _info
    ) external;

    /**
     * @dev Sets address of the treasure
     * @param _feeTreasure Address of the treasure
     */
    function setFeeTreasure(address _feeTreasure) external;

    /**
     * @dev Sets fixed crypto fee
     * @param _fixedNativeFee Fixed crypto fee
     */
    function setFixedNativeFee(uint256 _fixedNativeFee) external;

    /**
     * @dev Sets Rubic token fee
     * @notice Cannot be higher than limit set only by an admin
     * @param _platformFee Fixed crypto fee
     */
    function setRubicPlatformFee(uint256 _platformFee) external;

    /**
     * @dev Sets the limit of Rubic token fee
     * @param _maxFee The limit
     */
    function setMaxRubicPlatformFee(uint256 _maxFee) external;

    /// VIEW FUNCTIONS ///

    function calcTokenFees(
        uint256 _amount,
        address _integrator
    )
        external
        view
        returns (uint256 totalFee, uint256 RubicFee, uint256 integratorFee);

    function fixedNativeFee() external view returns (uint256 _fixedNativeFee);

    function RubicPlatformFee()
        external
        view
        returns (uint256 _RubicPlatformFee);

    function maxRubicPlatformFee()
        external
        view
        returns (uint256 _maxRubicPlatformFee);

    function maxFixedNativeFee()
        external
        view
        returns (uint256 _maxFixedNativeFee);

    function feeTreasure() external view returns (address feeTreasure);

    function integratorToFeeInfo(
        address _integrator
    ) external view returns (IFeesFacet.IntegratorFeeInfo memory _info);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IRubic {
    /// Structs ///

    struct BridgeData {
        bytes32 transactionId;
        string bridge;
        address integrator;
        address referrer;
        address sendingAssetId;
        address receivingAssetId;
        address receiver;
        uint256 minAmount;
        uint256 destinationChainId;
        bool hasSourceSwaps;
        bool hasDestinationCall;
    }

    /// Events ///

    event RubicTransferStarted(IRubic.BridgeData bridgeData);

    event RubicTransferCompleted(
        bytes32 indexed transactionId,
        address receivingAssetId,
        address receiver,
        uint256 amount,
        uint256 timestamp
    );

    event RubicTransferRecovered(
        bytes32 indexed transactionId,
        address receivingAssetId,
        address receiver,
        uint256 amount,
        uint256 timestamp
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            uint256 twos = (0 - denominator) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import { InsufficientBalance, NullAddrIsNotAnERC20Token, NullAddrIsNotAValidSpender, NoTransferToNullAddress, InvalidAmount, NativeValueWithERC, NativeAssetTransferFailed } from "../Errors/GenericErrors.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20Proxy } from "../Periphery/ERC20Proxy.sol";
import { LibSwap } from "./LibSwap.sol";
import { LibFees } from "./LibFees.sol";

/// @title LibAsset
/// @notice This library contains helpers for dealing with onchain transfers
///         of assets, including accounting for the native asset `assetId`
///         conventions and any noncompliant ERC20 transfers
library LibAsset {
    bytes32 internal constant LIB_ASSET_STORAGE_POSITION =
        keccak256("rubic.library.asset");
    uint256 private constant MAX_UINT = type(uint256).max;

    address internal constant NULL_ADDRESS = address(0);

    /// @dev All native assets use the empty address for their asset id
    ///      by convention

    address internal constant NATIVE_ASSETID = NULL_ADDRESS; //address(0)

    /// @dev Fetch local storage
    function getERC20proxy() internal view returns (ERC20Proxy erc20proxy) {
        bytes32 position = LIB_ASSET_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            erc20proxy := sload(position)
        }
    }

    /// @notice Gets the balance of the inheriting contract for the given asset
    /// @param assetId The asset identifier to get the balance of
    /// @return Balance held by contracts using this library
    function getOwnBalance(address assetId) internal view returns (uint256) {
        return
            assetId == NATIVE_ASSETID
                ? address(this).balance
                : IERC20(assetId).balanceOf(address(this));
    }

    /// @notice Transfers ether from the inheriting contract to a given
    ///         recipient
    /// @param recipient Address to send ether to
    /// @param amount Amount to send to given recipient
    function transferNativeAsset(
        address payable recipient,
        uint256 amount
    ) internal {
        if (recipient == NULL_ADDRESS) revert NoTransferToNullAddress();
        if (amount > address(this).balance)
            revert InsufficientBalance(amount, address(this).balance);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = recipient.call{ value: amount }("");
        if (!success) revert NativeAssetTransferFailed();
    }

    /// @notice If the current allowance is insufficient, the allowance for a given spender
    /// is set to MAX_UINT.
    /// @param assetId Token address to transfer
    /// @param spender Address to give spend approval to
    /// @param amount Amount to approve for spending
    function maxApproveERC20(
        IERC20 assetId,
        address spender,
        uint256 amount
    ) internal {
        if (address(assetId) == NATIVE_ASSETID) return;
        if (spender == NULL_ADDRESS) revert NullAddrIsNotAValidSpender();
        uint256 allowance = assetId.allowance(address(this), spender);

        if (allowance < amount)
            SafeERC20.safeIncreaseAllowance(
                IERC20(assetId),
                spender,
                MAX_UINT - allowance
            );
    }

    /// @notice Transfers tokens from the inheriting contract to a given
    ///         recipient
    /// @param assetId Token address to transfer
    /// @param recipient Address to send token to
    /// @param amount Amount to send to given recipient
    function transferERC20(
        address assetId,
        address recipient,
        uint256 amount
    ) internal {
        if (isNativeAsset(assetId)) revert NullAddrIsNotAnERC20Token();
        uint256 assetBalance = IERC20(assetId).balanceOf(address(this));
        if (amount > assetBalance)
            revert InsufficientBalance(amount, assetBalance);
        SafeERC20.safeTransfer(IERC20(assetId), recipient, amount);
    }

    /// @notice Transfers tokens from a sender to a given recipient
    /// @param assetId Token address to transfer
    /// @param from Address of sender/owner
    /// @param to Address of recipient/spender
    /// @param amount Amount to transfer from owner to spender
    function transferFromERC20(
        address assetId,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (assetId == NATIVE_ASSETID) revert NullAddrIsNotAnERC20Token();
        if (to == NULL_ADDRESS) revert NoTransferToNullAddress();

        IERC20 asset = IERC20(assetId);
        uint256 prevBalance = asset.balanceOf(to);
        SafeERC20.safeTransferFrom(asset, from, to, amount);
        if (asset.balanceOf(to) - prevBalance != amount)
            revert InvalidAmount();
    }

    /// @dev Deposits asset for bridging and accrues fixed and token fees
    /// @param assetId Address of asset to deposit
    /// @param amount Amount of asset to bridge
    /// @param extraNativeAmount Amount of native token to send to a bridge
    /// @param integrator Integrator for whom to count the fees
    /// @return amountWithoutFees Amount of tokens to bridge minus fees
    function depositAssetAndAccrueFees(
        address assetId,
        uint256 amount,
        uint256 extraNativeAmount,
        address integrator
    ) internal returns (uint256 amountWithoutFees) {
        uint256 accruedFixedNativeFee = LibFees.accrueFixedNativeFee(
            integrator
        );
        // Check that msg value is at least greater than fixed native fee + extra fee sending to bridge
        if (msg.value < accruedFixedNativeFee + extraNativeAmount)
            revert InvalidAmount();

        amountWithoutFees = _depositAndAccrueTokenFee(
            assetId,
            amount,
            accruedFixedNativeFee,
            extraNativeAmount,
            integrator
        );
    }

    /// @dev Deposits assets for each swap that requires and accrues fixed and token fees
    /// @param swaps Array of swap datas
    /// @param integrator Integrator for whom to count the fees
    /// @return amountWithoutFees Array of swap datas with updated amounts
    function depositAssetsAndAccrueFees(
        LibSwap.SwapData[] memory swaps,
        address integrator
    ) internal returns (LibSwap.SwapData[] memory) {
        uint256 accruedFixedNativeFee = LibFees.accrueFixedNativeFee(
            integrator
        );
        if (msg.value < accruedFixedNativeFee) revert InvalidAmount();
        for (uint256 i = 0; i < swaps.length; ) {
            LibSwap.SwapData memory swap = swaps[i];
            if (swap.requiresDeposit) {
                swap.fromAmount = _depositAndAccrueTokenFee(
                    swap.sendingAssetId,
                    swap.fromAmount,
                    accruedFixedNativeFee,
                    0,
                    integrator
                );
            }
            swaps[i] = swap;
            unchecked {
                i++;
            }
        }

        return swaps;
    }

    function _depositAndAccrueTokenFee(
        address assetId,
        uint256 amount,
        uint256 accruedFixedNativeFee,
        uint256 extraNativeAmount,
        address integrator
    ) private returns (uint256 amountWithoutFees) {
        if (isNativeAsset(assetId)) {
            // Check that msg value greater than sending amount + fixed native fees + extra fees sending to bridge
            if (msg.value < amount + accruedFixedNativeFee + extraNativeAmount)
                revert InvalidAmount();
        } else {
            if (amount == 0) revert InvalidAmount();
            uint256 balance = IERC20(assetId).balanceOf(msg.sender);
            if (balance < amount) revert InsufficientBalance(amount, balance);
            getERC20proxy().transferFrom(
                assetId,
                msg.sender,
                address(this),
                amount
            );
        }

        amountWithoutFees = LibFees.accrueTokenFees(
            integrator,
            amount,
            assetId
        );
    }

    /// @notice Determines whether the given assetId is the native asset
    /// @param assetId The asset identifier to evaluate
    /// @return Boolean indicating if the asset is the native asset
    function isNativeAsset(address assetId) internal pure returns (bool) {
        return assetId == NATIVE_ASSETID;
    }

    /// @notice Wrapper function to transfer a given asset (native or erc20) to
    ///         some recipient. Should handle all non-compliant return value
    ///         tokens as well by using the SafeERC20 contract by open zeppelin.
    /// @param assetId Asset id for transfer (address(0) for native asset,
    ///                token address for erc20s)
    /// @param recipient Address to send asset to
    /// @param amount Amount to send to given recipient
    function transferAsset(
        address assetId,
        address payable recipient,
        uint256 amount
    ) internal {
        (assetId == NATIVE_ASSETID)
            ? transferNativeAsset(recipient, amount)
            : transferERC20(assetId, recipient, amount);
    }

    /// @dev Checks whether the given address is a contract and contains code
    function isContract(address _contractAddr) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(_contractAddr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library LibBytes {
    // solhint-disable no-inline-assembly

    // LibBytes specific errors
    error SliceOverflow();
    error SliceOutOfBounds();
    error AddressOutOfBounds();
    error UintOutOfBounds();

    // -------------------------

    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    ) internal pure returns (bytes memory) {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(
                0x40,
                and(
                    add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                    not(31) // Round down to the nearest 32 bytes.
                )
            )
        }

        return tempBytes;
    }

    function concatStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    ) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(
                and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)),
                2
            )
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        if (_length + 31 < _length) revert SliceOverflow();
        if (_bytes.length < _start + _length) revert SliceOutOfBounds();

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(
                    add(tempBytes, lengthmod),
                    mul(0x20, iszero(lengthmod))
                )
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(
                        add(
                            add(_bytes, lengthmod),
                            mul(0x20, iszero(lengthmod))
                        ),
                        _start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (address) {
        if (_bytes.length < _start + 20) {
            revert AddressOutOfBounds();
        }
        address tempAddress;

        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }

    function toUint8(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (uint8) {
        if (_bytes.length < _start + 1) {
            revert UintOutOfBounds();
        }
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (uint16) {
        if (_bytes.length < _start + 2) {
            revert UintOutOfBounds();
        }
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (uint32) {
        if (_bytes.length < _start + 4) {
            revert UintOutOfBounds();
        }
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (uint64) {
        if (_bytes.length < _start + 8) {
            revert UintOutOfBounds();
        }
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (uint96) {
        if (_bytes.length < _start + 12) {
            revert UintOutOfBounds();
        }
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (uint128) {
        if (_bytes.length < _start + 16) {
            revert UintOutOfBounds();
        }
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (uint256) {
        if (_bytes.length < _start + 32) {
            revert UintOutOfBounds();
        }
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (bytes32) {
        if (_bytes.length < _start + 32) {
            revert UintOutOfBounds();
        }
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(
        bytes memory _preBytes,
        bytes memory _postBytes
    ) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                    // the next line is the loop condition:
                    // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    ) internal view returns (bool) {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(
                and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)),
                2
            )
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        // solhint-disable-next-line no-empty-blocks
                        for {

                        } eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function getFirst4Bytes(
        bytes memory data
    ) internal pure returns (bytes4 outBytes4) {
        if (data.length == 0) {
            return 0x0;
        }

        assembly {
            outBytes4 := mload(add(data, 32))
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IFeesFacet } from "../Interfaces/IFeesFacet.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { FullMath } from "../Libraries/FullMath.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";

/// Implementation of EIP-2535 Diamond Standard
/// https://eips.ethereum.org/EIPS/eip-2535
library LibFees {
    bytes32 internal constant FFES_STORAGE_POSITION =
        keccak256("rubic.library.fees.v2");
    // Denominator for setting fees
    uint256 internal constant DENOMINATOR = 1e6;

    // ----------------

    event FixedNativeFee(
        uint256 RubicPart,
        uint256 integratorPart,
        address indexed integrator
    );
    event FixedNativeFeeCollected(uint256 amount, address collector);
    event TokenFee(
        uint256 RubicPart,
        uint256 integratorPart,
        address indexed integrator,
        address token
    );
    event IntegratorTokenFeeCollected(
        uint256 amount,
        address indexed integrator,
        address token
    );

    struct FeesStorage {
        mapping(address => IFeesFacet.IntegratorFeeInfo) integratorToFeeInfo;
        uint256 maxRubicPlatformFee; // sets while initialize
        uint256 maxFixedNativeFee; // sets while initialize & cannot be changed
        uint256 RubicPlatformFee;
        // Rubic fixed fee for swap
        uint256 fixedNativeFee;
        address feeTreasure;
        bool initialized;
    }

    function feesStorage() internal pure returns (FeesStorage storage fs) {
        bytes32 position = FFES_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            fs.slot := position
        }
    }

    /**
     * @dev Calculates and accrues fixed crypto fee
     * @param _integrator Integrator's address if there is one
     * @return The amount of fixedNativeFee
     */
    function accrueFixedNativeFee(
        address _integrator
    ) internal returns (uint256) {
        uint256 _fixedNativeFee;
        uint256 _RubicPart;

        FeesStorage storage fs = feesStorage();
        IFeesFacet.IntegratorFeeInfo memory _info = fs.integratorToFeeInfo[
            _integrator
        ];

        if (_info.isIntegrator) {
            _fixedNativeFee = uint256(_info.fixedFeeAmount);

            if (_fixedNativeFee > 0) {
                _RubicPart =
                    (_fixedNativeFee * _info.RubicFixedCryptoShare) /
                    DENOMINATOR;

                if (_fixedNativeFee - _RubicPart > 0)
                    LibAsset.transferNativeAsset(
                        payable(_integrator),
                        _fixedNativeFee - _RubicPart
                    );
            }
        } else {
            _fixedNativeFee = fs.fixedNativeFee;
            _RubicPart = _fixedNativeFee;
        }

        if (_RubicPart > 0)
            LibAsset.transferNativeAsset(payable(fs.feeTreasure), _RubicPart);

        emit FixedNativeFee(
            _RubicPart,
            _fixedNativeFee - _RubicPart,
            _integrator
        );

        return _fixedNativeFee;
    }

    /**
     * @dev Calculates token fees and accrues them
     * @param _integrator Integrator's address if there is one
     * @param _amountWithFee Total amount passed by the user
     * @param _token The token in which the fees are collected
     * @return Amount of tokens without fee
     */
    function accrueTokenFees(
        address _integrator,
        uint256 _amountWithFee,
        address _token
    ) internal returns (uint256) {
        FeesStorage storage fs = feesStorage();
        IFeesFacet.IntegratorFeeInfo memory _info = fs.integratorToFeeInfo[
            _integrator
        ];

        (uint256 _totalFees, uint256 _RubicFee) = _calculateFee(
            fs,
            _amountWithFee,
            _info
        );

        if (_integrator != address(0)) {
            if (_totalFees - _RubicFee > 0)
                LibAsset.transferAsset(
                    _token,
                    payable(_integrator),
                    _totalFees - _RubicFee
                );
        }
        if (_RubicFee > 0)
            LibAsset.transferAsset(_token, payable(fs.feeTreasure), _RubicFee);

        emit TokenFee(_RubicFee, _totalFees - _RubicFee, _integrator, _token);

        return _amountWithFee - _totalFees;
    }

    /// PRIVATE ///

    /**
     * @dev Calculates fee amount for integrator and rubic, used in architecture
     * @param _amountWithFee the users initial amount
     * @param _info the struct with data about integrator
     * @return _totalFee the amount of Rubic + integrator fee
     * @return _RubicFee the amount of Rubic fee only
     */
    function _calculateFeeWithIntegrator(
        uint256 _amountWithFee,
        IFeesFacet.IntegratorFeeInfo memory _info
    ) private pure returns (uint256 _totalFee, uint256 _RubicFee) {
        if (_info.tokenFee > 0) {
            _totalFee = FullMath.mulDiv(
                _amountWithFee,
                _info.tokenFee,
                DENOMINATOR
            );

            _RubicFee = FullMath.mulDiv(
                _totalFee,
                _info.RubicTokenShare,
                DENOMINATOR
            );
        }
    }

    function _calculateFee(
        FeesStorage storage _fs,
        uint256 _amountWithFee,
        IFeesFacet.IntegratorFeeInfo memory _info
    ) internal view returns (uint256 _totalFee, uint256 _RubicFee) {
        if (_info.isIntegrator) {
            (_totalFee, _RubicFee) = _calculateFeeWithIntegrator(
                _amountWithFee,
                _info
            );
        } else {
            _totalFee = FullMath.mulDiv(
                _amountWithFee,
                _fs.RubicPlatformFee,
                DENOMINATOR
            );

            _RubicFee = _totalFee;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAsset } from "./LibAsset.sol";
import { LibUtil } from "./LibUtil.sol";
import { InvalidContract, NoSwapFromZeroBalance, InsufficientBalance, UnAuthorized } from "../Errors/GenericErrors.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibSwap {
    struct SwapData {
        address callTo;
        address approveTo;
        address sendingAssetId;
        address receivingAssetId;
        uint256 fromAmount;
        bytes callData;
        bool requiresDeposit;
    }

    event AssetSwapped(
        bytes32 transactionId,
        address dex,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 timestamp
    );

    function swap(bytes32 transactionId, SwapData memory _swap) internal {
        if (!LibAsset.isContract(_swap.callTo)) revert InvalidContract();
        if (_swap.callTo == address(LibAsset.getERC20proxy()))
            revert UnAuthorized();
        uint256 fromAmount = _swap.fromAmount;
        if (fromAmount == 0) revert NoSwapFromZeroBalance();
        uint256 nativeValue = LibAsset.isNativeAsset(_swap.sendingAssetId)
            ? _swap.fromAmount
            : 0;
        uint256 initialSendingAssetBalance = LibAsset.getOwnBalance(
            _swap.sendingAssetId
        );
        uint256 initialReceivingAssetBalance = LibAsset.getOwnBalance(
            _swap.receivingAssetId
        );

        if (nativeValue == 0) {
            LibAsset.maxApproveERC20(
                IERC20(_swap.sendingAssetId),
                _swap.approveTo,
                _swap.fromAmount
            );
        }

        if (initialSendingAssetBalance < _swap.fromAmount) {
            revert InsufficientBalance(
                _swap.fromAmount,
                initialSendingAssetBalance
            );
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory res) = _swap.callTo.call{
            value: nativeValue
        }(_swap.callData);
        if (!success) {
            string memory reason = LibUtil.getRevertMsg(res);
            revert(reason);
        }

        uint256 newBalance = LibAsset.getOwnBalance(_swap.receivingAssetId);

        emit AssetSwapped(
            transactionId,
            _swap.callTo,
            _swap.sendingAssetId,
            _swap.receivingAssetId,
            _swap.fromAmount,
            newBalance > initialReceivingAssetBalance
                ? newBalance - initialReceivingAssetBalance
                : newBalance,
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./LibBytes.sol";

library LibUtil {
    using LibBytes for bytes;

    function getRevertMsg(
        bytes memory _res
    ) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_res.length < 68) return "Transaction reverted silently";
        bytes memory revertData = _res.slice(4, _res.length - 4); // Remove the selector which is the first 4 bytes
        return abi.decode(revertData, (string)); // All that remains is the revert string
    }

    /// @notice Determines whether the given address is the zero address
    /// @param addr The address to verify
    /// @return Boolean indicating if the address is the zero address
    function isZeroAddress(address addr) internal pure returns (bool) {
        return addr == address(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";

/// @title ERC20 Proxy
/// @notice Proxy contract for safely transferring ERC20 tokens for swaps/executions
contract ERC20Proxy is Ownable {
    /// Storage ///
    mapping(address => bool) public authorizedCallers;

    /// Errors ///
    error UnAuthorized();

    /// Events ///
    event AuthorizationChanged(address indexed caller, bool authorized);

    /// Constructor
    constructor(address _owner) {
        transferOwnership(_owner);
    }

    /// @notice Sets whether or not a specified caller is authorized to call this contract
    /// @param caller the caller to change authorization for
    /// @param authorized specifies whether the caller is authorized (true/false)
    function setAuthorizedCaller(
        address caller,
        bool authorized
    ) external onlyOwner {
        authorizedCallers[caller] = authorized;
        emit AuthorizationChanged(caller, authorized);
    }

    /// @notice Transfers tokens from one address to another specified address
    /// @param tokenAddress the ERC20 contract address of the token to send
    /// @param from the address to transfer from
    /// @param to the address to transfer to
    /// @param amount the amount of tokens to send
    function transferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount
    ) external {
        if (!authorizedCallers[msg.sender]) revert UnAuthorized();

        LibAsset.transferFromERC20(tokenAddress, from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC20 } from "@axelar-network/axelar-cgp-solidity/contracts/interfaces/IERC20.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { IRubic } from "../Interfaces/IRubic.sol";
import { IERC20Proxy } from "../Interfaces/IERC20Proxy.sol";
import { TransferrableOwnership } from "../Helpers/TransferrableOwnership.sol";

/// @title Executor
/// @notice Arbitrary execution contract used for cross-chain swaps and message passing
contract Executor is IRubic, ReentrancyGuard, TransferrableOwnership {
    /// Storage ///

    /// @notice The address of the ERC20Proxy contract
    IERC20Proxy public erc20Proxy;

    /// Errors ///
    error ExecutionFailed();
    error InvalidCaller();

    /// Events ///
    event ERC20ProxySet(address indexed proxy);

    /// Modifiers ///

    /// @dev Sends any leftover balances back to the user
    modifier noLeftovers(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver
    ) {
        uint256 numSwaps = _swaps.length;
        if (numSwaps != 1) {
            uint256[] memory initialBalances = _fetchBalances(_swaps);
            address finalAsset = _swaps[numSwaps - 1].receivingAssetId;
            uint256 curBalance = 0;

            _;

            for (uint256 i = 0; i < numSwaps - 1; ) {
                address curAsset = _swaps[i].receivingAssetId;
                // Handle multi-to-one swaps
                if (curAsset != finalAsset) {
                    curBalance = LibAsset.getOwnBalance(curAsset);
                    if (curBalance > initialBalances[i]) {
                        LibAsset.transferAsset(
                            curAsset,
                            _leftoverReceiver,
                            curBalance - initialBalances[i]
                        );
                    }
                }
                unchecked {
                    ++i;
                }
            }
        } else {
            _;
        }
    }

    /// Constructor
    /// @notice Initialize local variables for the Executor
    /// @param _owner The address of owner
    /// @param _erc20Proxy The address of the ERC20Proxy contract
    constructor(
        address _owner,
        address _erc20Proxy
    ) TransferrableOwnership(_owner) {
        owner = _owner;
        erc20Proxy = IERC20Proxy(_erc20Proxy);

        emit ERC20ProxySet(_erc20Proxy);
    }

    /// External Methods ///

    /// @notice set ERC20 Proxy
    /// @param _erc20Proxy The address of the ERC20Proxy contract
    function setERC20Proxy(address _erc20Proxy) external onlyOwner {
        erc20Proxy = IERC20Proxy(_erc20Proxy);
        emit ERC20ProxySet(_erc20Proxy);
    }

    /// @notice Performs a swap before completing a cross-chain transaction
    /// @param _transactionId the transaction id for the swap
    /// @param _swapData array of data needed for swaps
    /// @param _transferredAssetId token received from the other chain
    /// @param _receiver address that will receive tokens in the end
    function swapAndCompleteBridgeTokens(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address _transferredAssetId,
        address payable _receiver
    ) external payable nonReentrant {
        _processSwaps(
            _transactionId,
            _swapData,
            _transferredAssetId,
            _receiver,
            0,
            true
        );
    }

    /// @notice Performs a series of swaps or arbitrary executions
    /// @param _transactionId the transaction id for the swap
    /// @param _swapData array of data needed for swaps
    /// @param _transferredAssetId token received from the other chain
    /// @param _receiver address that will receive tokens in the end
    /// @param _amount amount of token for swaps or arbitrary executions
    function swapAndExecute(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address _transferredAssetId,
        address payable _receiver,
        uint256 _amount
    ) external payable nonReentrant {
        _processSwaps(
            _transactionId,
            _swapData,
            _transferredAssetId,
            _receiver,
            _amount,
            false
        );
    }

    /// Private Methods ///

    /// @notice Performs a series of swaps or arbitrary executions
    /// @param _transactionId the transaction id for the swap
    /// @param _swapData array of data needed for swaps
    /// @param _transferredAssetId token received from the other chain
    /// @param _receiver address that will receive tokens in the end
    /// @param _amount amount of token for swaps or arbitrary executions
    /// @param _depositAllowance If deposit approved amount of token
    function _processSwaps(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address _transferredAssetId,
        address payable _receiver,
        uint256 _amount,
        bool _depositAllowance
    ) private {
        uint256 startingBalance;
        uint256 finalAssetStartingBalance;
        address finalAssetId = _swapData[_swapData.length - 1]
            .receivingAssetId;
        if (!LibAsset.isNativeAsset(finalAssetId)) {
            finalAssetStartingBalance = LibAsset.getOwnBalance(finalAssetId);
        } else {
            finalAssetStartingBalance =
                LibAsset.getOwnBalance(finalAssetId) -
                msg.value;
        }

        if (!LibAsset.isNativeAsset(_transferredAssetId)) {
            startingBalance = LibAsset.getOwnBalance(_transferredAssetId);
            if (_depositAllowance) {
                uint256 allowance = IERC20(_transferredAssetId).allowance(
                    msg.sender,
                    address(this)
                );
                LibAsset.transferFromERC20(
                    _transferredAssetId,
                    msg.sender,
                    address(this),
                    allowance
                );
            } else {
                erc20Proxy.transferFrom(
                    _transferredAssetId,
                    msg.sender,
                    address(this),
                    _amount
                );
            }
        } else {
            startingBalance =
                LibAsset.getOwnBalance(_transferredAssetId) -
                msg.value;
        }

        _executeSwaps(_transactionId, _swapData, _receiver);

        uint256 postSwapBalance = LibAsset.getOwnBalance(_transferredAssetId);
        if (postSwapBalance > startingBalance) {
            LibAsset.transferAsset(
                _transferredAssetId,
                _receiver,
                postSwapBalance - startingBalance
            );
        }

        uint256 finalAssetPostSwapBalance = LibAsset.getOwnBalance(
            finalAssetId
        );

        if (finalAssetPostSwapBalance > finalAssetStartingBalance) {
            LibAsset.transferAsset(
                finalAssetId,
                _receiver,
                finalAssetPostSwapBalance - finalAssetStartingBalance
            );
        }

        emit RubicTransferCompleted(
            _transactionId,
            _transferredAssetId,
            _receiver,
            finalAssetPostSwapBalance,
            block.timestamp
        );
    }

    /// @dev Executes swaps one after the other
    /// @param _transactionId the transaction id for the swap
    /// @param _swapData Array of data used to execute swaps
    /// @param _leftoverReceiver Address to receive lefover tokens
    function _executeSwaps(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swapData,
        address payable _leftoverReceiver
    ) private noLeftovers(_swapData, _leftoverReceiver) {
        uint256 numSwaps = _swapData.length;
        for (uint256 i = 0; i < numSwaps; ) {
            // call to the ERC20Proxy is blocked inside LibSwap.swap
            LibSwap.SwapData calldata currentSwapData = _swapData[i];
            LibSwap.swap(_transactionId, currentSwapData);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Fetches balances of tokens to be swapped before swapping.
    /// @param _swapData Array of data used to execute swaps
    /// @return uint256[] Array of token balances.
    function _fetchBalances(
        LibSwap.SwapData[] calldata _swapData
    ) private view returns (uint256[] memory) {
        uint256 numSwaps = _swapData.length;
        uint256[] memory balances = new uint256[](numSwaps);
        address asset;
        for (uint256 i = 0; i < numSwaps; ) {
            asset = _swapData[i].receivingAssetId;
            balances[i] = LibAsset.getOwnBalance(asset);

            if (LibAsset.isNativeAsset(asset)) {
                balances[i] -= msg.value;
            }

            unchecked {
                ++i;
            }
        }

        return balances;
    }

    /// @dev required for receiving native assets from destination swaps
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}