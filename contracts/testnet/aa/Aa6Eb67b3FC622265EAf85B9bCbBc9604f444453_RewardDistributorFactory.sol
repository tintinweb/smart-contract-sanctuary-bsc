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

//Created by Altrucoin.com - Block based reward distributor for V6.0.0 Vault

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

/*
    implementation steps: todo
        set functions
*/

contract RewardDistributorV6 is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct APYData {
        uint256 totalRewards7Days;
        uint256 allTimeFeeTracker;
        uint256 dualTotalRewards7Days;
        uint256 allTimeFeeTracker2ndToken;
    }

    //Initialize Variables
    address public vault; //permissions to call withdraw function
    //address public feeDistributor;
    IERC20 public token; // staking token.
    IERC20 public dualToken; // 2nd Token in dual rewards system (can be any bep20 token) //todo make set function
    address public partnerAdmin;
    address public feeTrackerContract;

    // Control Bools
    bool public dualTokenVault = false;
    bool public highAPYVault = false;

    //Distribution Running Totals
    uint256 public tokenRunningTotal; //lifetime number of tokens distributed
    uint256 public dualTokenRunningTotal;

    // Reward APY tracking variables	
    uint256 private allTimeFeeTracker; // Vault total lifetime rewards tracker	
    uint256 private resetTracker;	
    uint256 private resetTracker2ndToken = 0;	
    uint256 private blockTimeTracker2ndToken = block.timestamp;	
    uint256 private allTimeFeeTracker2ndToken = 0; // Vault total lifetime rewards tracker	
    uint256[7] private feeTracker7days2ndToken = [0, 0, 0, 0, 0, 0, 0];	
    uint256[7] private dayTracker2ndToken = [0, 0, 0, 0, 0, 0, 0];	
    uint256[7] private dayTracker = [0, 0, 0, 0, 0, 0, 0];	
    uint256[7] private feeTracker7days = [0, 0, 0, 0, 0, 0, 0]; //rewards from the last 7 days	
    uint256 private blockTimeTracker = block.timestamp;	


    //todo make these variables changeable
    //todo make timestamp rather than block based

    /**
     * @notice Constructor
     * @param _token: staking token contract
     * @param _token: dual token contract
     * @param _vault: address of the staking vault that will be calling this contract for rewards
     */
    constructor(
        IERC20 _token,
        IERC20 _dualToken,
        address _vault,
        //address _feeDistributor,
        address _feeTracker,
        bool _dualTokenVault,
        bool _highAPYVault
    ) {
        require(_token != _dualToken, "token = dual token");
        token = _token;
        dualToken = _dualToken;
        vault = _vault;
        dualTokenVault = _dualTokenVault;
        //feeDistributor = _feeDistributor;
        feeTrackerContract = _feeTracker;
        highAPYVault = _highAPYVault;
        
    }

    /*  ===============================
        Primary Functions - Deposit/Withdraw
        =============================== */

    /**
     * @notice Deposit funds into the block based Tokens reward Pool. note function not really needed, they can just send tokens tbh
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit
     * @param _dualTokenDeposit: main token or dual token deposit?
     */
    function deposit(uint256 _amount, bool _dualTokenDeposit) external whenNotPaused {
        if (_dualTokenDeposit == false) {
            token.safeTransferFrom(msg.sender, address(this), _amount);
        } else {
            if (address(dualToken) != address(0x0)) {
                dualToken.safeTransferFrom(msg.sender, address(this), _amount);
            }
        }
    }

    /**
     * @notice Withdraw funds from the block based token reward pool to the vault.
     * @param _amount: Number of tokens to withdraw
     */
    function withdraw(uint256 _amount, bool _dualTokenWithdraw)
        external
        whenNotPaused
        onlyOwnerorVault
        nonReentrant
        returns (uint256)
    {
        if(highAPYVault == false){
            if (_dualTokenWithdraw == false) {
                if (_amount > IERC20(token).balanceOf(address(this))) {
                    _amount = IERC20(token).balanceOf(address(this));
                }
                if (_amount > 0) {
                    token.safeTransfer(vault, _amount);
                    tokenRunningTotal += _amount;
                }
            } else if (_dualTokenWithdraw == true) {
                if (address(dualToken) == address(0x0)) {
                    if (_amount > address(this).balance) {
                        _amount = address(this).balance;
                    }
                    if (_amount > 0) {
                        payable(vault).transfer(_amount);
                        dualTokenRunningTotal += _amount;
                    }
                } else {
                    if (_amount > IERC20(dualToken).balanceOf(address(this))) {
                        _amount = IERC20(dualToken).balanceOf(address(this));
                    }
                    if (_amount > 0) {
                        dualToken.safeTransfer(vault, _amount);
                        dualTokenRunningTotal += _amount;
                    }
                }
            }
        } else {
            if (_dualTokenWithdraw == false && IERC20(token).balanceOf(address(this)) > 0){
                tokenRunningTotal += IERC20(token).balanceOf(address(this));
                token.safeTransfer(vault, IERC20(token).balanceOf(address(this)));
            } else {
                if (dualTokenVault = true){
                    if (address(dualToken) == address(0x0) && address(this).balance > 0) {
                        dualTokenRunningTotal += address(this).balance;
                        payable(vault).transfer(address(this).balance);
                    } 
                    else if (IERC20(dualToken).balanceOf(address(this)) > 0){
                        dualTokenRunningTotal += IERC20(dualToken).balanceOf(address(this));
                        dualToken.safeTransfer(vault, IERC20(dualToken).balanceOf(address(this)));
                    }
                }
            }
        }
        return _amount;
    }

    /**	
     * @notice Totals up rewards from the last 7 days.	
     */	
    function rewardTracker(uint256 _feeTotal, bool _dualToken) external {
        require (msg.sender == vault);
        //check if staking token or dual token	
        if (_dualToken == false) {	
            // 7 day reset tracker	
            if (block.timestamp > blockTimeTracker + 7 days) {	
                resetTracker += 1;	
                blockTimeTracker += 7 days;	
            }	
            // Loop to save rewards to the appropriate slot in the 7 day array	
            for (uint256 i = 0; i < 7; i++) {	
                if (	
                    block.timestamp >= blockTimeTracker + (i * 1 days) &&	
                    block.timestamp < blockTimeTracker + ((i + 1) * 1 days)	
                ) {	
                    //finds which day it is	
                    if (resetTracker != dayTracker[i]) {	
                        //checks to make sure a week hasn't passed	
                        for (uint256 j = 0; j <= i; j++) {	
                            // cycles days	
                            if (dayTracker[j] != resetTracker) {	
                                //if day didn't have an update	
                                dayTracker[j] = resetTracker; //set to new day tracker	
                                feeTracker7days[j] = 0; //set that day to 0	
                            }	
                        }	
                    }	
                    feeTracker7days[i] = feeTracker7days[i] + (_feeTotal);	
                    break;	
                }	
            }	
            // Lifetime reward tracker	
            allTimeFeeTracker = allTimeFeeTracker + (_feeTotal);	
        }	
        //Dual token rewards	
        if (_dualToken == true) {	
            if (block.timestamp > blockTimeTracker2ndToken + (7 days)) {	
                resetTracker2ndToken = resetTracker2ndToken + (1);	
                blockTimeTracker2ndToken = blockTimeTracker2ndToken + (7 days);	
            }	
            for (uint256 i = 0; i < 7; i++) {	
                if (	
                    block.timestamp >= blockTimeTracker2ndToken + (i * 1 days) &&	
                    block.timestamp < blockTimeTracker2ndToken + ((i + (1)) * 1 days)	
                ) {	
                    if (resetTracker2ndToken != dayTracker2ndToken[i]) {	
                        for (uint256 j = 0; j <= i; j++) {	
                            if (dayTracker2ndToken[j] != resetTracker2ndToken) {	
                                dayTracker2ndToken[j] = resetTracker2ndToken;	
                                feeTracker7days2ndToken[j] = 0;	
                            }	
                        }	
                    }	
                    feeTracker7days2ndToken[i] += (_feeTotal);	
                    break;	
                }	
            }	
            allTimeFeeTracker2ndToken += (_feeTotal);	
        }	
    }

    /**
     * @notice Withdraws tokens without caring about rewards. THIS CAN BREAK ALL VAULT MATH
     * @dev EMERGENCY ONLY. Only callable by the contract owner.
     */
    function emergencyWithdraw(
        address _randomToken,
        bool takeTokens,
        uint256 tokenAmount,
        bool takeBNB,
        uint256 bnbAmount,
        bool takeAllTokens,
        bool takeAllBNB
    ) external onlyOwner {
        if (address(this).balance > 0 && takeAllBNB == true) {
            payable(msg.sender).transfer(address(this).balance);
        }
        if (address(this).balance > 0 && takeBNB == true) {
            payable(msg.sender).transfer(bnbAmount);
        }
        if (IERC20(_randomToken).balanceOf(address(this)) > 0 && takeAllTokens == true) {
            uint256 amount = IERC20(_randomToken).balanceOf(address(this));
            IERC20(_randomToken).safeTransfer(msg.sender, amount);
        }
        if (IERC20(_randomToken).balanceOf(address(this)) > 0 && takeTokens == true) {
            IERC20(_randomToken).safeTransfer(msg.sender, tokenAmount);
        }
    }

    // function checkFee() external returns (bool) {	
    //     require(msg.sender == feeTrackerContract);	
    //     uint256 balanceBefore = token.balanceOf(address(this));	
    //     token.safeTransferFrom(feeTrackerContract, address(this), 500);	
    //     uint256 diff = token.balanceOf(address(this)) - balanceBefore;	
    //     if (diff == 500) {	
    //         return (true);	
    //     }	
    //     return false;	
    // }
    
    function checkFee() external returns (bool) {
        require(msg.sender == feeTrackerContract);
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(feeTrackerContract, address(this), 500);
        uint256 diff = token.balanceOf(address(this)) - balanceBefore;
        if (diff == 500) {
            if (dualTokenVault == true){
                balanceBefore = dualToken.balanceOf(address(this));
                dualToken.safeTransferFrom(feeTrackerContract, address(this), 500);
                diff = dualToken.balanceOf(address(this)) - balanceBefore;
                if (diff != 500){
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    /*  ===============================
        View/Misc Functions - Deposit/Withdraw
        =============================== */

    /**
     * @notice Checks how many more blocks the rewards here will cover for staking token or dual token
     * @param _rewardsPerBlock: Number of tokens to be distributed per block //todo this is so simple does it need a function?
     */
    function runway(uint256 _rewardsPerBlock, bool _checkDualToken, uint256 _blocksPassed) public view returns (uint256) {	
        if(highAPYVault == true){
            return 0;
        }
        if (_rewardsPerBlock == 0){
            return 0;
        }
        uint256 _pendingRewards = pendingRewards(_blocksPassed, _rewardsPerBlock, _checkDualToken);
        uint256 _bal = IERC20(token).balanceOf(address(this));
        if (_checkDualToken == false) {
            if (_bal >= _pendingRewards){
                return (_bal - _pendingRewards) / _rewardsPerBlock; //todo make this get automatically from other contract? getVaultVariables()
            } else {
                return 0;
            }
        }
        else {
            if (dualTokenVault == false) {
                return 0;
            }
            if (address(dualToken) == address(0x0)) {
                return address(this).balance / _rewardsPerBlock;
            } else {
                return IERC20(dualToken).balanceOf(address(this)) / _rewardsPerBlock;
            }
        }
    }

    function pendingRewards(
        uint256 _blocksPassed,
        uint256 _rewardsPerBlock,
        bool _dualToken
    ) public view returns (uint256) {
        uint256 expectedToken = _blocksPassed * _rewardsPerBlock;
        if(highAPYVault == true){
            expectedToken = 0;
        }
        //if not enough tokens in distributor return total in distributor
        if (_dualToken == false) {
            if (expectedToken > token.balanceOf(address(this))) {
                expectedToken = token.balanceOf(address(this));
            }
            return expectedToken;
        } else {
            if (address(dualToken) == address(0x0)) {
                if (expectedToken > address(this).balance) {
                    expectedToken = address(this).balance;
                }
            } else {
                if (expectedToken > dualToken.balanceOf(address(this))) {
                    expectedToken = dualToken.balanceOf(address(this));
                }
            }
            return expectedToken;
        }
    }

    /**	
     * @notice Calculates the rewards for the last 7 days. Used for apy calculations in front end	
     */	
    function getAPYData() external view returns (APYData memory) {	
        uint256 totalRewards7Days = 0;	
        for (uint256 i = 0; i < 7; i++) {	
            totalRewards7Days += feeTracker7days[i];	
        }	
        uint256 dualTotalRewards7Days = 0;	
        if (dualTokenVault == true) {	
            for (uint256 i = 0; i < 7; i++) {	
                dualTotalRewards7Days += feeTracker7days2ndToken[i];	
            }	
        }	
        APYData memory _apyData = APYData({	
            totalRewards7Days: totalRewards7Days,	
            allTimeFeeTracker: allTimeFeeTracker,	
            dualTotalRewards7Days: dualTotalRewards7Days,	
            allTimeFeeTracker2ndToken: allTimeFeeTracker2ndToken	
        });	
        return _apyData;	
    }

    // Set Functions

    function setFeeTrackerContract(address _feeTrackerContract) external onlyOwner {
        feeTrackerContract = _feeTrackerContract;
    }

    function setVault(address _vault) external onlyOwner {
        vault = _vault;
    }

    function setPartnerAdminWallet(address partnerAdmin_) external {
        require(msg.sender == vault);
        partnerAdmin = partnerAdmin_;
    }

    function setTokens(IERC20 _token, IERC20 _dualToken) external onlyOwner {	
        token = _token;	
        dualToken = _dualToken;	
    }	

    function setDualTokenVault(bool _dualTokenVault) external onlyOwner {	
        dualTokenVault = _dualTokenVault;
    }

    function setHighAPYVault(bool _highAPYVault) external onlyOwner {	
        highAPYVault = _highAPYVault;
    }

    /**
     * @notice Trigger stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
        //emit Pause();
    }

    /**
     * @notice Return to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
        //emit Unpause();
    }

    /**
     * @notice checks that address is vault or owner
     */
    modifier onlyOwnerorVault() {
        require(msg.sender == vault || msg.sender == owner(), 'not admin/owner');
        _;
    }
}

contract RewardDistributorFactory {
    address public creator;

    constructor(address creator_) {
        creator = creator_;
    }

    function createRewardDistributor(
        address token,
        address dualToken,
        address _vault,
        //address _feeDistributor,
        address _feeTracker,
        bool _dualTokenVault,
        bool _highApyVault
    ) external returns (address) {
        RewardDistributorV6 _rewardDistributor = new RewardDistributorV6(
            IERC20(token),
            IERC20(dualToken),
            _vault,
            //_feeDistributor,
            _feeTracker,
            _dualTokenVault,
            _highApyVault
        );
        _rewardDistributor.transferOwnership(msg.sender);
        //rewardDistributor[token] = address(_rewardDistributor);	

        return address(_rewardDistributor);
    }
}