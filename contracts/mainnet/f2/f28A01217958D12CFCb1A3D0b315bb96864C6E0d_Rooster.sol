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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.17;

//---------------------------------------------------------
// Imports
//---------------------------------------------------------
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

//---------------------------------------------------------
// Contract
//---------------------------------------------------------
contract Rooster is Ownable, ReentrancyGuard, Pausable
{
	using SafeERC20 for IERC20;

	struct UserInfo
	{
		uint256 staked_amount;
		uint256 locked_reward_amount;
		uint256 paid_reward_amount;
		uint256 next_harvest_time;
		
		uint256 deposit_time; // block timestamp unit is seconds
		uint256 withdraw_locking_period;
	}

	struct PoolInfo
	{
		address address_stake_token; // Target
		address address_reward_token; // Arrow or BUSD

		uint256 last_rewarded_block_id;
		uint256 accu_reward_amount_per_share_e12;
		uint256 reward_per_block_min;
		uint256 reward_per_block_max;
	}

	address public address_operator;
	uint256 public reward_mint_start_block_id;

	// withdraw_locking_period
	// 디파짓이 0일때만 기간 설정 가능
	// 추가로 돈 넣으면 여태 지나간 시간 리셋

	uint256 constant MAX_WITHDRAW_LOCK = 30 days;

	uint256 public locking_period_mim = 7 days;
	uint256 public locking_period_max = 30 days;
	
	PoolInfo[] public pool_info; // pool_id / pool_info, reward_info
	mapping(address => mapping(address => bool)) public is_pool_exist; // stake / reward
	mapping(uint256 => mapping(address => UserInfo)) public user_info; // pool_id / user_adddress / user_info

	//---------------------------------------------------------------
	// Front-end connectors
	//---------------------------------------------------------------
	event PauseCB(address indexed operator);
	event ResumeCB(address indexed operator);
	event SetOperatorCB(address indexed operator, address _new_operator);
	event UpdateEmissionRateCB(address indexed operator, uint256 _reward_per_block_min, uint256 _reward_per_block_max);
	event SetLockingPeriodCB(address indexed operator, uint256 _min_time, uint256 _max_time);
	event MakePoolCB(address indexed operator, uint256 _new_pool_id);
	event DepositCB(address indexed _user, uint256 _pool_id, uint256 _amount);
	event WithdrawCB(address indexed _user, uint256 _pool_id, uint256 _amount);
	event HarvestCB(address indexed _user, uint256 _pool_id, uint256 _amount);

	event EmergencyWithdrawCB(address indexed user, uint256 _pool_id, uint256 _amount);
	event HandleStuckCB(address indexed _user, uint256 _amount);

	//---------------------------------------------------------------
	// Modifier
	//---------------------------------------------------------------
	modifier uniquePool(address _address_stake_token, address _address_reward_token) {
		require(is_pool_exist[_address_stake_token][_address_reward_token] == false, "uniquePool: duplicated"); _; }

	//---------------------------------------------------------------
	// Variable Interfaces
	//---------------------------------------------------------------
	function update_emission_rate(uint256 _pool_id, uint256 _reward_per_block_min,
		uint256 _reward_per_block_max) public onlyOwner
	{
		require(_pool_id < pool_info.length, "update_emission_rate: Wrong pool id.");
		require(_reward_per_block_min <= _reward_per_block_max, "update_emission_rate: Wrong reward amount");

		refresh_reward_per_share_all();

		pool_info[_pool_id].reward_per_block_min = _reward_per_block_min;
		pool_info[_pool_id].reward_per_block_max = _reward_per_block_max;
		emit UpdateEmissionRateCB(msg.sender, _reward_per_block_min, _reward_per_block_max);
	}

	function get_pool_count() external view returns(uint256)
	{
		return pool_info.length;
	}

	function set_locking_period_range(uint256 _min_time, uint256 _max_time) external onlyOwner
	{
		require(_max_time <= MAX_WITHDRAW_LOCK, "set_locking_period: Wrong locking period");
		locking_period_mim = _min_time;
		locking_period_max = _max_time;
		emit SetLockingPeriodCB(msg.sender, _min_time, _max_time);
	}

	//---------------------------------------------------------------
	// External Methodd
	//---------------------------------------------------------------
	constructor(uint256 _reward_mint_start_block_id)
	{
		address_operator = msg.sender;
		reward_mint_start_block_id = _reward_mint_start_block_id;
	}

	function make_pool(address _address_stake_token, address _address_reward_token,
		uint256 _reward_per_block_min, uint256 _reward_per_block_max, bool _refresh_reward)
		public onlyOwner uniquePool(_address_stake_token, _address_reward_token) returns (uint256)
	{
		if(_refresh_reward)
			refresh_reward_per_share_all();

		is_pool_exist[_address_stake_token][_address_reward_token] = true;

		uint256 _last_rewarded_block_id = (block.number > reward_mint_start_block_id)? block.number : reward_mint_start_block_id;
		pool_info.push(PoolInfo({
			address_stake_token: _address_stake_token,
			address_reward_token: _address_reward_token,
			last_rewarded_block_id: _last_rewarded_block_id,
			accu_reward_amount_per_share_e12: 0,
			reward_per_block_min: _reward_per_block_min,
			reward_per_block_max: _reward_per_block_max
		}));

		uint new_pool_id = pool_info.length-1;
		emit MakePoolCB(msg.sender, new_pool_id);
		return new_pool_id;
	}

	function deposit(uint256 _pool_id, uint256 _amount, uint256 _period) public nonReentrant whenNotPaused
	{
		require(_pool_id < pool_info.length, "deposit: Wrong pool id");
		refresh_reward_per_share(_pool_id);

		require(_period >= locking_period_mim, "deposit: Wrong locking period");
		require(_period <= locking_period_max, "deposit: Wrong locking period");

		address address_user = msg.sender;
		UserInfo storage user = user_info[_pool_id][address_user];
		PoolInfo storage pool = pool_info[_pool_id];

		_collect_reward(pool, user, address_user);

		if(_amount > 0)
		{
			require(_period != user.withdraw_locking_period && user.staked_amount < 100, "deposit: Unstake previous all amount first."); // 100 wei is nearly zero.

			// User -> Rooster
			IERC20 lp_token = IERC20(pool.address_stake_token);
			lp_token.safeTransferFrom(address_user, address(this), _amount);

			// Write down deposit amount on Rooter's ledger
			user.staked_amount += _amount;
			user.deposit_time = block.timestamp;
			user.withdraw_locking_period = _period;
		}

		emit DepositCB(address_user, _pool_id, user.staked_amount);
	}

	function withdraw(uint256 _pool_id, uint256 _amount) public nonReentrant whenNotPaused
	{
		require(_pool_id < pool_info.length, "withdraw: Wrong pool id.");

		refresh_reward_per_share(_pool_id);

		address address_user = msg.sender;
		PoolInfo storage pool = pool_info[_pool_id];
		UserInfo storage user = user_info[_pool_id][address_user];

		require(user.staked_amount >= _amount, "withdraw: insufficient amount");

		uint256 unlock_time = user.deposit_time + user.withdraw_locking_period;
		require(block.timestamp >= unlock_time, "withdraw: withdraw is locked.");

		_collect_reward(pool, user, address_user);

		if(_amount > 0)
		{
			user.staked_amount -= _amount;
			IERC20(pool.address_stake_token).safeTransfer(address(address_user), _amount);
		}

		emit WithdrawCB(address_user, _pool_id, _amount);
	}

	function refresh_reward_per_share_all() public
	{
		for(uint256 pid = 0; pid < pool_info.length; pid++)
			refresh_reward_per_share(pid);
	}

	function refresh_reward_per_share(uint256 _pool_id) public
	{
		require(_pool_id < pool_info.length, "refresh_reward_per_share: Wrong pool id.");

		PoolInfo storage pool = pool_info[_pool_id];
		if(block.number <= pool.last_rewarded_block_id)
			return;

		uint256 elapsed_block_count = block.number - pool.last_rewarded_block_id;
		uint256 total_staked_amount = IERC20(pool.address_stake_token).balanceOf(address(this));
		if(total_staked_amount > 0 && elapsed_block_count > 0)
		{
			uint256 max_reward_amount = elapsed_block_count * pool.reward_per_block_max;
			pool.accu_reward_amount_per_share_e12 += (max_reward_amount * 1e12 / total_staked_amount);
			pool.last_rewarded_block_id = block.number;
		}
	}

	function harvest(uint256 _pool_id) public nonReentrant whenNotPaused
	{
		require(_pool_id < pool_info.length, "harvest: Wrong pool id.");

		refresh_reward_per_share(_pool_id);

		address address_user = msg.sender;
		PoolInfo storage pool = pool_info[_pool_id];
		UserInfo storage user = user_info[_pool_id][address_user];

		uint256 amount = _collect_reward(pool, user, address_user);
		
		emit HarvestCB(address_user, _pool_id, amount);
	}

	function emergency_withdraw(uint256 _pool_id) public nonReentrant
	{
		require(_pool_id < pool_info.length, "emergency_withdraw: Wrong pool id.");

		address address_user = msg.sender;
		PoolInfo storage pool = pool_info[_pool_id];
		UserInfo storage user = user_info[_pool_id][address_user];

		uint256 amount = user.staked_amount;
		user.staked_amount = 0;
		user.paid_reward_amount = 0;

		IERC20 stake_token = IERC20(pool.address_stake_token);
		stake_token.safeTransfer(address_user, amount);

		emit EmergencyWithdrawCB(address_user, _pool_id, amount);
	}

	function handle_stuck(address _address_token, uint256 _amount) public onlyOwner nonReentrant
	{
		for(uint16 i=0; i<pool_info.length; i++)
			require(_address_token != pool_info[i].address_reward_token, "handle_stuck: Wrong token address");

		address address_user = msg.sender;
		IERC20(_address_token).safeTransfer(address_user, _amount);
		emit HandleStuckCB(address_user, _amount);
	}

	function pause() external onlyOwner
	{ 
		_pause(); 
		emit PauseCB(msg.sender);
	}
	
	function resume() external onlyOwner
	{ 
		_unpause();
		emit ResumeCB(msg.sender);
	}

	//---------------------------------------------------------------
	// Internal Method
	//---------------------------------------------------------------
	function _collect_reward(PoolInfo storage _pool, UserInfo storage _user, address _address_user) internal returns(uint256)
	{
		if(_user.staked_amount == 0)
			return 0;
		
		uint256 min_max_ratio_e12 = _pool.reward_per_block_max * 1e12 / _pool.reward_per_block_min;
		uint256 period_weight_e12 = min_max_ratio_e12 * _user.withdraw_locking_period / locking_period_max;

		uint256 total_user_reward_amount = _user.staked_amount * _pool.accu_reward_amount_per_share_e12 / 1e12;
		total_user_reward_amount = (total_user_reward_amount * period_weight_e12) / 1e12;

		uint256 pending_reward_amount = total_user_reward_amount - _user.paid_reward_amount;
		if(pending_reward_amount > 0)
		{
			if(_pool.address_reward_token != address(0))
				_safe_reward_transfer(_pool.address_reward_token, _address_user, pending_reward_amount);

			_user.paid_reward_amount += pending_reward_amount;
		}

		return pending_reward_amount;
	}

	function _safe_reward_transfer(address _address_reward_token, address _to, uint256 _amount) internal
	{
		// Rooster -> User
		IERC20 reward_token = IERC20(_address_reward_token);
		uint256 cur_reward_balance = reward_token.balanceOf(address(this));

		if(_amount > cur_reward_balance)
			reward_token.safeTransfer(_to, cur_reward_balance);
		else
			reward_token.safeTransfer(_to, _amount);
	}
}