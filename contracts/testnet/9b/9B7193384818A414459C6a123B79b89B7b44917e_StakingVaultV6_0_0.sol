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

//Created by Altrucoin.com - V6.0.0 Time Locking Vault

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
// import './interfaces/IRewardDistributor.sol';
import './interfaces/IFeeDistributor.sol';
import './interfaces/IRewardDistributor.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import 'hardhat/console.sol';

//deploying on 0.8.13 note update this
contract StakingVaultV6_0_0 is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct VaultVariables {
        uint256 totalShares;
        uint256 totalBoostDebt;
        uint256 totalLockedAmount;
        uint256 lastBlockDistributed;
        uint256 totalDualToken;
        uint256 rewardsPerBlock;
        uint256 dualRewardsPerBlock;
        uint256 dualTokenPerShare;
        uint256 apyTokenTracker;
    }

    struct Durations {
        uint256 withdrawFeePeriod;
        uint256 UNLOCK_FREE_DURATION;
        uint256 MIN_LOCK_DURATION;
        uint256 MIN_BONDING_LOCK_DURATION;
        uint256 MAX_LOCK_DURATION;
        uint256 DURATION_FACTOR;
        uint256 DURATION_FACTOR_OVERDUE;
    }

    struct Controls {
        bool disableDeposits;
        bool unstakeEarly;
        bool unstakeEarlyBonding;
        bool dualTokenVault;
        bool feeForDualToken;
        bool excludedFromFee;
        bool initRewardsSupplyed;
    }

    struct UserInfo1 {
        bool exists;
        uint256 index;
        uint256 shares;
        uint256 userBoostedShare;
        uint256 lockedAmount;
    }

    struct UserInfo2 {
        uint256 lastDepositedTime;
        uint256 tokensAtLastUserAction;
        uint256 lastUserActionTime;
        uint256 dualTokenDebt;
        uint256 lockEndTime;
    }

    //Chunk these tasks down further! Into individual steps
    /* Task Breakdown
        Voting token (optional - LATER)
        Misc
            //(LATER) voting token - custom vault only - have the balanceOf() function of the voting token check the vault address and pull that user info from the vault and set the balance of that user to the same amount in the vault. So no need to update manually (maybe send them 1 token on deposit or something)
            //(LATER) todo maybe add a new function called vaultBalance() to allow you to remove tokens from vault if needed
            //(LATER) note nft minting system in a separate contract. Users call a claim function after mining for a certain amount of time with a certain number of tokens. 
            //(LATER) note make all vaults use the same contract using a struct called vault that has all the main vault variables (token addresses, shares, etc). And make a function to add a new vault
            //todo Transfer ownership to hard coded address in constructor
            //note use earnedAmount to see how to calculate rewards only
            todo only owner for library (RewardDistributor), fee dist
            todo make distributor contracts pass ownership to team automatically in constructor
            //use non reentrant in distributor contracts
    */

    //Addresses
    address private partnerAdmin; //this is the partner company who vault is being created for, they have limited privliges
    address private bondingContract; //bonding system
    address public feeTracker;

    // Interfaces
    IRewardDistributorV6 private rewardDistributor; //block based distributor contract
    IFeeDistributorV6 private feeDistributor; //fee distribution contract

    // Tokens
    IERC20 private token; // staking token.
    IERC20 private dualToken; // 2nd Token in dual rewards system (can be any bep20 token)
    //IERC20 private teamPayoutToken; // Token type for Altrucoin team payments - moved to fee dist system
    uint256 private tokenDecimal; //todo use if needed
    uint256 private dualTokenDecimal; //todo use if needed
    //VotingToken private votingToken; // Placeholder token used to vote on voting app while staking //todo make voting token (future)

    // Vault Variables
    uint256 private totalShares; // total user shares, include boosts
    uint256 private totalBoostDebt; // total boost debt.
    uint256 private totalLockedAmount; // total lock amount.
    uint256 private lastBlockDistributed;
    uint256 private totalDualToken; //Manual tracker of dual token that has already beed distributed. Used for dualTokenPerShare
    uint256 private rewardsPerBlock; //distributor variable
    uint256 private dualRewardsPerBlock; //distributor variable
    uint256 private dualTokenPerShare; //dual tokens per user shares, used to calculate debt and rewards in dual tokens. Multiplied by 10 ** 28 for precision
    // add just a normal token tracker to see how many new rewards on every deposit and withdraw? (later?)

    //Mappings
    mapping(address => UserInfo) public userInfo;

    //Setting Bools

    bool private disableDeposits = false;
    bool private unstakeEarly = true;
    bool private unstakeEarlyBonding = false;
    bool private dualTokenVault = false; // Toggle dual token features
    bool private feeForDualToken = true; // Exit fee on second reward token
    bool private excludedFromFee = false;
    bool private initRewardsSupplyed = false;
    /*note add these to gets and sets bool private votingTokenEnabled = true; //Changing voting token mechanism
    bool private mintVTOnUpdate = true; // Mint voting token on update*/

    //Durations/Time limits

    uint256 private MIN_LOCK_DURATION = 1 days; // 1 week
    uint256 private MIN_BONDING_LOCK_DURATION = 30 days; // 365 days
    uint256 private MAX_LOCK_DURATION = 365 days; // 365 days
    uint256 private DURATION_FACTOR = 365 days; // 365 days, in order to calculate user additional boost.Generally equal to max_lock_duration

    uint256 private constant MAX_LOCK_DURATION_LIMIT = 1000 days; // 1000 days

    //Precision multipliers
    uint256 private constant PRECISION_FACTOR = 1e12; // precision factor. //todo check where this is used and make sure your new code uses it too - it is used when calculating overdue fee to remove extra 0s. does this work with tokens with diff decimals? it should
    uint256 private constant PRECISION_FACTOR_SHARE = 1e28; // precision factor for share.

    //Boost Weight
    uint256 private constant BOOST_WEIGHT_LIMIT = 5000 * 1e10; // 5000%
    uint256 private BOOST_WEIGHT = 2000 * 1e10; // 100%

    //Min deposit and withdraws
    uint256 private MIN_DEPOSIT_AMOUNT; //set in constructor based on token decimal
    uint256 private MIN_WITHDRAW_AMOUNT;

    //Fee threshold and
    uint256 private totalFeeSendThreshold = 1 * 10**16; // fee send out threshold todo set higher after testing
    uint256 private totalFeeTracker; //fee tracker to check against threshold
    uint256 private dualTotalFeeTracker;

    //Reward tracker - Tracks last 7 days of rewards from all sources for staking token
    uint256 private apyTokenTracker;
    uint256 public vaultOpenDate = block.timestamp;
    uint256 public lastVaultAction;
    uint256 private apyDualTokenTracker; //dual token

    //Address array variables
    address[] private addressIndexes;

    struct UserInfo {
        uint256[2] shares; // number of shares for a user. includes boost (boost or boost rewards?). shares are used to calc user % of pool and rewards after boost.
        uint256[2] userBoostedShare; // debt - boost shares are the number of shares that were added on top of the standard ones to produce boost for user (real+boost is saved in user.shares). Used in order to give the user higher reward. The user only enjoys the reward, so the boost amount needs to be recorded as a debt, that is this variable.
        uint256[2] lockedAmount; // amount deposited during lock period. This + reward is what the user actually has
        uint256[2] lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256[2] tokensAtLastUserAction; // keep track of tokens deposited at the last user action. Can be used to track tokens earned
        uint256[2] lastUserActionTime; // keep track of the last user action time.
        uint256[2] lockStartTime; // lock start time.
        uint256[2] lockEndTime; // lock end time.
        uint256[2] dualTokenDebt; //dualToken debt so users have 0 of the dualToken token rewards on deposit. It will be reset on ALL user deposits or withdraws from the vault. User dual token rewards is dualTokenPerShare * shares - dualTokenDebt
        uint256 index; //user position in vault
        bool exists;
        bool[2] locked; //lock status.
    }

    event Deposit(
        address indexed sender,
        uint256 amount,
        uint256 shares,
        uint256 duration,
        uint256 lastDepositedTime
    );
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event WithdrawDualToken(address indexed sender, uint256 amount);
    event Harvest(address indexed sender, uint256 amount, uint256 dualTokenAmount);
    event Pause();
    event Unpause();
    event Lock(
        address indexed sender,
        uint256 lockedAmount,
        uint256 shares,
        uint256 lockedDuration,
        uint256 blockTimestamp,
        uint256 slot
    );
    event Unlock(
        address indexed sender,
        uint256 amount,
        uint256 blockTimestamp,
        uint256 slot
    );
    event NewAdminBonding(address partnerAdmin, address bondingContract);

    event NewMinEntryExit(uint256 minDepositAmount, uint256 minWithdrawAmount);

    event NewMinMaxLockDuration(
        uint256 minLockDuration,
        uint256 minBondingLockDuration,
        uint256 maxLockDuration,
        uint256 durationFactor
    );

    event NewBoostWeight(uint256 boostWeight);

    //add events todo

    /**
     * @notice Constructor
     * @param _token: staking token contract
     * @param _partnerAdmin: address of the partnerAdmin
     todo add more params here, hardcode some stuff (during initialization^ and exclude from here)
     */
    constructor(
        //todo update
        IERC20 _token,
        IERC20 _dualToken,
        // address _bondingContract,
        // IRewardDistributorV6 _rewardDistributor,
        bool _dualTokenVault,
        uint256 _rewardsPerBlock,
        uint256 _dualRewardsPerBlock,
        uint256 _tokenDecimal,
        uint256 _dualTokenDecimal,
        address _partnerAdmin,
        uint256 boostWeight,
        uint256 minLock,
        uint256 maxLock,
        bool _unstakeEarly
    )
    //todo fix size issue and stack to deep issue here. Hard code addresses at initialization
    //VotingToken _votingToken
    {
        lastVaultAction = block.timestamp;
        _pause();
        token = _token;
        partnerAdmin = _partnerAdmin;
        tokenDecimal = _tokenDecimal; //todo use this varuable for token decimal related calculations (precicion)
        dualTokenDecimal = _dualTokenDecimal;
        dualToken = _dualToken;
        dualTokenVault = _dualTokenVault;
        // bondingContract = _bondingContract;
        // rewardDistributor = _rewardDistributor;
        rewardsPerBlock = _rewardsPerBlock;
        dualRewardsPerBlock = _dualRewardsPerBlock;
        //votingToken = _votingToken;
        BOOST_WEIGHT = boostWeight * 1000 * 10**10;
        lastBlockDistributed = block.number;
        MIN_DEPOSIT_AMOUNT = (10**tokenDecimal) / 10**5;
        MIN_WITHDRAW_AMOUNT = (10**tokenDecimal) / 10**5;
        MIN_LOCK_DURATION = minLock;
        MAX_LOCK_DURATION = maxLock;
        DURATION_FACTOR = maxLock;
        unstakeEarly = _unstakeEarly;

        //Set Owner
        //transferOwnership(); //todo hardcode address note change for mainnet
    }

    /*  ===============================
        Primary Functions - Deposit/Withdraw
        ===============================*/

    /**
     * @notice Deposit funds into the Tokens Pool.
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit (in CAKE)
     * @param _lockDuration: Token lock duration
     * @param _slot: 0 = staking,1 = bonding
     */
    function deposit(
        uint256 _amount,
        uint256 _lockDuration,
        uint256 _slot,
        address _user
    ) external whenNotPaused {
        whenEnabledDeposits();
        require(_amount > 0 || _lockDuration > 0, '0');
        if (_slot == 0) {
            depositOperation(_amount, _lockDuration, msg.sender, _slot);
        } else {
            require(msg.sender == bondingContract, 'notbond');
            depositOperation(_amount, _lockDuration, _user, _slot);
        }
    }

    /**
     * @notice The operation of deposit.
     * @param _amount: number of tokens to deposit (in CAKE)
     * @param _lockDuration: Token lock duration
     * @param _user: User address
     * @param _slot: 0 = staking,1 = bonding
     */
    function depositOperation(
        uint256 _amount,
        uint256 _lockDuration,
        address _user,
        uint256 _slot
    ) internal nonReentrant {
        // Set user info based on bonding or staking
        UserInfo storage user = userInfo[_user];
        lastVaultAction = block.timestamp;
        //require statements
        if (user.shares[_slot] == 0 || _amount > 0) {
            require(_amount > MIN_DEPOSIT_AMOUNT, '<min');
        }

        // Calculate the total lock duration and check whether the lock duration meets required conditions.
        uint256 totalLockDuration = _lockDuration;
        if (user.lockEndTime[_slot] >= block.timestamp) {
            // Adding funds during the lock duration is equivalent to re-locking the position, needs to update some variables.
            if (_amount > 0) {
                user.lockStartTime[_slot] = block.timestamp;
                totalLockedAmount -= user.lockedAmount[_slot];
                user.lockedAmount[_slot] = 0;
            }
            totalLockDuration += user.lockEndTime[_slot] - user.lockStartTime[_slot];
        }

        // More require statements based on total lock duration
        if (_slot == 0) {
            require(
                _lockDuration == 0 || totalLockDuration >= MIN_LOCK_DURATION,
                '<minlock'
            );
        } else {
            require(
                _lockDuration == 0 || totalLockDuration >= MIN_BONDING_LOCK_DURATION,
                '<minlock'
            );
        }
        require(totalLockDuration <= MAX_LOCK_DURATION, '>maxlock');

        //Get block based rewards from distributor contract
        distributeRewards();

        // Handle stock funds. Not sure what that means but this sends out all staking tokens if all users exit
        if (totalShares == 0) {
            //if no users
            uint256 stockAmount = available(); //balance of contract for staking token
            if (stockAmount > 0) {
                token.safeTransfer(owner(), stockAmount); //transfer any tokens on contract to the owner (collects fees address)
            }
            apyTokenTracker += _amount; //setting initial supply to track any addition rewards in the future
        }

        // Update user share.
        updateUserShareAndSendDualToken(_user, _slot); // this adds in previous users REWARDS to the users amount and then removes the boost to prepare for the new tokens. Boost re added later
        //note whenever this is called, user dual tokens need to be sent out and if user.shares is updated you can reset the debt to full.

        // Update lock duration.
        if (_lockDuration > 0) {
            if (user.lockEndTime[_slot] < block.timestamp) {
                user.lockStartTime[_slot] = block.timestamp;
                user.lockEndTime[_slot] = block.timestamp + _lockDuration; //already includes prev lock time?
            } else {
                user.lockEndTime[_slot] += _lockDuration;
            }
            user.locked[_slot] = true;
        }

        //Prep variables
        uint256 currentShares; //will be the shares conversion of the incoming tokens + the currently locked tokens
        uint256 currentAmount; //will be existing locked balance + new tokens in tokens (not shares)
        uint256 userCurrentLockedBalance;
        uint256 pool = balanceOf();

        // Transfer in tokens from user.
        if (_amount > 0) {
            // Change actual amount of tokens that the vault receives and set amount equal to the actual amount incoming
            uint256 beforeAmt = token.balanceOf(address(this));
            token.safeTransferFrom(_user, address(this), _amount);
            uint256 afterAmt = token.balanceOf(address(this));
            currentAmount = afterAmt - beforeAmt; //current amount = incoming tokens

            //check that tokenomics fees are off
            require(_amount == currentAmount, 'feeOn'); //only custom vaults can have fees on still

            //Set amount to real tokens sent to vault
            _amount = currentAmount;
        }

        //todo move fee calc to separate function
        // Entry fee calculations
        if (
            !feeDistributor.getFreeEntryExtiFeeUsers(_user) &&
            (feeDistributor.getEntryFee(_slot) != 0 ||
                feeDistributor.getEntryFeeContract() != 0)
        ) {
            uint256 feeRate = feeDistributor.getEntryFee(_slot);
            if (_isContract(_user) && _slot == 0) {
                //switch fee for contracts
                feeRate = feeDistributor.getEntryFeeContract();
            }
            uint256 stEntryFee = (_amount * feeRate) / 10000; // Entry fee
            _amount -= stEntryFee;
            currentAmount -= stEntryFee;
            totalFeeTracker += stEntryFee;
        }

        if (totalFeeTracker >= totalFeeSendThreshold) {
            uint256 tempTotalFeeTracker = totalFeeTracker;
            totalFeeTracker = 0;
            token.safeTransfer(address(feeDistributor), tempTotalFeeTracker);

            feeDistributor.payoutFees(); //Send out all fees in correct %s
        }

        // Calculate currently locked funds for user excluding boost, resets user shares to 0 to calcuate later,
        if (user.shares[_slot] > 0 && user.locked[_slot] && totalShares != 0) {
            userCurrentLockedBalance = (pool * user.shares[_slot]) / totalShares; //current user token balance, prev boost REWARDS were added in during updateUserShare() and boost amount reset to 0.
            currentAmount += userCurrentLockedBalance; //new tokens + prev locked balance
            totalShares -= user.shares[_slot]; //removes existing shares to re add in the user
            user.shares[_slot] = 0;

            // Update lock amount
            if (user.lockStartTime[_slot] == block.timestamp) {
                user.lockedAmount[_slot] = userCurrentLockedBalance; //sets new starting balance for user
                totalLockedAmount += user.lockedAmount[_slot];
            }
        }
        // Calculates base shares for user (excluding boost). (converting amount to shares)
        if (totalShares != 0) {
            currentShares =
                (currentAmount * totalShares) /
                (pool - userCurrentLockedBalance); //second part of equation is pool excluding the tokens of the user, to give more accurate % of pool?
        } else {
            //if first user, current shares just equals incoming amount
            currentShares = currentAmount;
        }

        // Calculate the new boost weight share.
        if (user.lockEndTime[_slot] > user.lockStartTime[_slot]) {
            // Calculate boost share.
            //boostWeight is a multiplier on user shares. So shares will equal (original shares) + (multiplier * original shares)
            uint256 boostWeight = ((user.lockEndTime[_slot] - user.lockStartTime[_slot]) *
                BOOST_WEIGHT) / DURATION_FACTOR; //if locked for 365, duration factor (365 days) is canceled out and boostweight = boost_factor
            uint256 boostShares = (boostWeight * currentShares) / PRECISION_FACTOR; //how much boost on top of original should user get. Removes percision_factor # of decimals
            currentShares += boostShares; //includes prev locked, new locked and new boost shares
            user.shares[_slot] += currentShares; //user shares includes boost
            user.dualTokenDebt[_slot] =
                (user.shares[_slot] * dualTokenPerShare) /
                PRECISION_FACTOR_SHARE; //set debt to full value so user has no new dual tokens

            // Calculate boost share , the user only enjoys the reward, so the principal (how much is boost) needs to be recorded as a debt.
            uint256 userBoostedShare = (boostWeight * currentAmount) / PRECISION_FACTOR; //user boosted share amount (in tokens instead of shares? this is user boosted share DEBT, used to remove boost fro user later
            user.userBoostedShare[_slot] += userBoostedShare;
            totalBoostDebt += userBoostedShare;

            // Update lock amount. (actual amount of tokens that came in)
            user.lockedAmount[_slot] += _amount;
            totalLockedAmount += _amount;

            emit Lock(
                _user,
                user.lockedAmount[_slot],
                user.shares[_slot],
                (user.lockEndTime[_slot] - user.lockStartTime[_slot]),
                block.timestamp,
                _slot
            );
        } else {
            user.shares[_slot] += currentShares;
            user.dualTokenDebt[_slot] =
                (user.shares[_slot] * dualTokenPerShare) /
                PRECISION_FACTOR_SHARE;
        }

        //set last deposit time
        if (_amount > 0 || _lockDuration > 0) {
            user.lastDepositedTime[_slot] = block.timestamp;
        }
        totalShares += currentShares; //add users new shares to total

        if (totalShares != 0) {
            user.tokensAtLastUserAction[_slot] =
                (user.shares[_slot] * balanceOf()) /
                totalShares -
                user.userBoostedShare[_slot]; //users tokens (excludes bonus) at last interaction
        } else {
            user.tokensAtLastUserAction[_slot] = 0;
        }
        user.lastUserActionTime[_slot] = block.timestamp;

        //Add any new tokens to apy tracker - todo this prob doesnt work because balanceOf includes boostdebt
        if ((apyTokenTracker + _amount) < available()) {
            feeDistributor.feeTracker(available() - (apyTokenTracker + _amount), false);
            apyTokenTracker = available();
        }

        //add user to index array
        addAddress(_user);

        emit Deposit(_user, _amount, currentShares, _lockDuration, block.timestamp);
    }

    /**
     * @notice Withdraw funds from the Tokens Pool.
     * @param _amount: Number of amount to withdraw
     * @param _slot: 0 = staking,1 = bonding
     */
    function withdrawByAmount(uint256 _amount, uint256 _slot) public whenNotPaused {
        require(_amount > MIN_WITHDRAW_AMOUNT, '<min');
        withdrawOperation(0, _amount, _slot);
    }

    /**
     * @notice Withdraw funds from the Tokens Pool.
     * @param _shares: Number of shares to withdraw
     * @param _slot: 0 = staking,1 = bonding
     */
    function withdraw(uint256 _shares, uint256 _slot) public whenNotPaused {
        require(_shares > 0, '0');
        withdrawOperation(_shares, 0, _slot);
    }

    /**
     * @notice The operation of withdraw.
     * @param _shares: Number of shares to withdraw - used in withdrawAll function (and withdrawAll button)
     * @param _amount: Number of amount to withdraw - normal withdraw method for UI input
     * @param _slot: 0 = staking,1 = bonding
     */
    function withdrawOperation(
        uint256 _shares,
        uint256 _amount,
        uint256 _slot
    ) internal nonReentrant {
        // Set user info based on bonding or staking
        UserInfo storage user = userInfo[msg.sender];
        lastVaultAction = block.timestamp;

        require(_shares <= user.shares[_slot], '>bal');
        if (
            (unstakeEarly == false && _slot == 0) ||
            (unstakeEarlyBonding == false && _slot == 1)
        ) {
            require(user.lockEndTime[_slot] < block.timestamp, 'timelock');
        }

        // Calculate the percent of withdraw shares. - When unlocking or calculating the Performance fee, the shares will be updated.
        uint256 currentShare = _shares;
        uint256 sharesPercent = (_shares * PRECISION_FACTOR_SHARE) / user.shares[_slot]; //finds % of this users stake being withdraw while adding additional precision that gets removed later

        //Get block based rewards from distributor contract
        distributeRewards();
        // Update user share. this merges in rewards and sets boost to 0. so user.shares includes everything and locking boost will be readded later
        updateUserShareAndSendDualToken(msg.sender, _slot);

        // Calculate currentShare from _amount or _shares (which was converted into sharesPercent)
        if (_shares == 0 && _amount > 0) {
            //withdraw is in amount not shares
            uint256 pool = balanceOf();
            currentShare = (_amount * totalShares) / pool; // Calculate equivalent shares
            if (currentShare > user.shares[_slot]) {
                currentShare = user.shares[_slot]; //max withdraw if calculation ended up producing too high of a share for user.
            }
        } else {
            //withdraw is in shares not amount
            currentShare = (sharesPercent * user.shares[_slot]) / PRECISION_FACTOR_SHARE; //removing precision added earlier
        }
        uint256 currentAmount = 0;
        if (totalShares != 0) {
            currentAmount = (balanceOf() * currentShare) / totalShares; //current shares into % of total pool balance
        }

        //At this point currentShare is the amount(in tokens) being withdraw regardless of if it was from shares, amount or withdrawAll function.
        user.shares[_slot] -= currentShare;
        totalShares -= currentShare;
        user.dualTokenDebt[_slot] =
            (user.shares[_slot] * dualTokenPerShare) /
            PRECISION_FACTOR_SHARE; //set debt to full value so user has no dual tokens, dual tokens were sent to user using updateUserShareAndSendDualToken a few lines ago

        // Calculate and take withdraw fee
        uint256 currentWithdrawFee = feeDistributor.calculateWithdrawFee(
            msg.sender,
            _slot,
            currentAmount,
            false,
            user.lastDepositedTime,
            user.lockEndTime,
            calculateTotalPendingTokensRewards(false),
            balanceOf()
        );
        if (currentWithdrawFee > 0) {
            totalFeeTracker += currentWithdrawFee;
            currentAmount -= currentWithdrawFee;
        }

        // Send out fees if past threshold
        if (totalFeeTracker >= totalFeeSendThreshold) {
            uint256 tempTotalFeeTracker = totalFeeTracker;
            totalFeeTracker = 0;
            token.safeTransfer(address(feeDistributor), tempTotalFeeTracker);

            feeDistributor.payoutFees();
        }

        token.safeTransfer(msg.sender, currentAmount); //send to user
        //for reward tracking update tokens at last interaction

        if (totalShares != 0) {
            user.tokensAtLastUserAction[_slot] =
                (user.shares[_slot] * balanceOf()) /
                totalShares -
                user.userBoostedShare[_slot];
        } else {
            user.tokensAtLastUserAction[_slot] = 0;
        }
        user.lastUserActionTime[_slot] = block.timestamp;

        //Add any new tokens to apy tracker
        if ((currentAmount + currentWithdrawFee) <= apyTokenTracker) {
            apyTokenTracker -= (currentAmount + currentWithdrawFee);
        } else {
            apyTokenTracker = 0;
        }
        if (apyTokenTracker < available()) {
            feeDistributor.feeTracker(available() - apyTokenTracker, false);
        }
        apyTokenTracker = available();

        // Removes user address from array of addresses if their balance is now 0
        if (user.shares[0] == 0 && user.shares[1] == 0) {
            (, uint256 y1) = calculateUserBalances(msg.sender, 0);
            (, uint256 y2) = calculateUserBalances(msg.sender, 1);
            if (y1 == 0 && y2 == 0) {
                deleteAddress();
            }
        }

        emit Withdraw(msg.sender, currentAmount, currentShare);
    }

    /**
     * @notice Withdraw all funds for a user
     * @param _slot: 0 = staking,1 = bonding
     */
    function withdrawAll(uint256 _slot) external whenNotPaused {
        withdraw(userInfo[msg.sender].shares[_slot], _slot);
    }

    /**
     * @notice UI harvest dual token external function (includes update user share at start)
     * @param _slot: 0 = staking,1 = bonding
     */
    function harvestUserDualTokenRewards(uint256 _slot)
        external
        whenNotPaused
        nonReentrant
    {
        //Get block based rewards from distributor contract
        distributeRewards();

        // update user shares and send dual tokens
        updateUserShareAndSendDualToken(msg.sender, _slot);
    }

    /**
     * @notice Sends out all dual token rewards for user
     * @param _slot: 0 = staking,1 = bonding
     */
    function sendDualTokenRewards(address _user, uint256 _slot) internal whenNotPaused {
        UserInfo storage user = userInfo[_user];
        (, uint256 dualTokenSendOutAmount) = calculateUserBalances(_user, _slot); //calc dt rewards

        if (
            balanceOfDualToken() >= dualTokenSendOutAmount && dualTokenSendOutAmount > 0
        ) {
            //safely send out tokens
            if (dualTokenSendOutAmount <= totalDualToken) {
                totalDualToken -= dualTokenSendOutAmount; //tracker for new dual token enter the vault
            } else {
                totalDualToken = 0;
            }

            user.dualTokenDebt[_slot] =
                (user.shares[_slot] * dualTokenPerShare) /
                PRECISION_FACTOR_SHARE; // set user dt rewards to 0

            // Calculate and take withdraw fee
            if (feeForDualToken == true) {
                uint256 currentWithdrawFee = feeDistributor.calculateWithdrawFee(
                    _user,
                    _slot,
                    dualTokenSendOutAmount,
                    false,
                    user.lastDepositedTime,
                    user.lockEndTime,
                    calculateTotalPendingTokensRewards(false),
                    balanceOf()
                );
                if (currentWithdrawFee > 0) {
                    dualTotalFeeTracker += currentWithdrawFee;
                    dualTokenSendOutAmount -= currentWithdrawFee;
                }
            }

            //send tokens to user
            if (address(dualToken) != address(0x0)) {
                dualToken.safeTransfer(_user, dualTokenSendOutAmount);
            } else {
                payable(_user).transfer(dualTokenSendOutAmount);
            }
        }

        //find any new dualtokens and add them to dual token reward tracker
        if (dualTokenSendOutAmount <= apyDualTokenTracker) {
            apyDualTokenTracker -= dualTokenSendOutAmount; //apy is equal to old balance of dual token. So this finds and new tokens that are from fee OR any other source.
        } else {
            apyDualTokenTracker = 0;
        }
        if (apyDualTokenTracker < balanceOfDualToken()) {
            feeDistributor.feeTracker(balanceOfDualToken() - apyDualTokenTracker, true);
        }
        apyDualTokenTracker = balanceOfDualToken();
        emit WithdrawDualToken(_user, dualTokenSendOutAmount);
    }

    /**
     * @notice calculates the user's balances for staking token and dual token
     * @param _slot: 0 = staking,1 = bonding
     */
    function calculateUserBalances(address _user, uint256 _slot)
        public
        view
        returns (uint256, uint256)
    {
        UserInfo storage user = userInfo[_user];
        uint256 balance = 0;
        if (totalShares != 0) {
            balance =
                (balanceOf() * (user.shares[_slot])) /
                totalShares -
                user.userBoostedShare[_slot];
        }
        return (
            balance,
            ((user.shares[_slot] * dualTokenPerShare) / PRECISION_FACTOR_SHARE) -
                user.dualTokenDebt[_slot]
        );
    }

    /*  ===============================
        Primary Functions - Internal
        ===============================*/

    /**
     * @notice Update user share When need to unlock or charges a fee. (must call)
     * @param _user: User address
     * @param _slot: 0 = staking,1 = bonding
     */
    function updateUserShareAndSendDualToken(address _user, uint256 _slot) internal {
        // Set user info based on bonding or staking
        UserInfo storage user = userInfo[_user];
        IFeeDistributorV6.UserInfo memory user_ = IFeeDistributorV6.UserInfo({
            shares: user.shares,
            userBoostedShare: user.userBoostedShare,
            lockedAmount: user.lockedAmount,
            lastDepositedTime: user.lastDepositedTime,
            tokensAtLastUserAction: user.tokensAtLastUserAction,
            lastUserActionTime: user.lastUserActionTime,
            lockStartTime: user.lockStartTime,
            lockEndTime: user.lockEndTime,
            dualTokenDebt: user.dualTokenDebt,
            index: user.index,
            exists: user.exists,
            locked: user.locked
        });
        if (user.shares[_slot] > 0) {
            //Overdue fee calculations for locked users
            if (user.locked[_slot]) {
                // Calculate the user's current token amount and update related parameters.
                uint256 currentOverdueFee = feeDistributor.calculateOverdueFee(
                    _user,
                    _slot,
                    false,
                    user_,
                    calculateTotalPendingTokensRewards(false),
                    balanceOf(),
                    totalShares,
                    PRECISION_FACTOR
                );
                uint256 currentAmount = (balanceOf() * (user.shares[_slot])) /
                    totalShares -
                    user.userBoostedShare[_slot];

                totalBoostDebt -= user.userBoostedShare[_slot];
                user.userBoostedShare[_slot] = 0;
                totalShares -= user.shares[_slot];

                totalFeeTracker += currentOverdueFee;
                currentAmount -= currentOverdueFee;

                // Recalculate the user's share from currentAmount
                uint256 pool = balanceOf();
                uint256 currentShares;
                if (totalShares != 0) {
                    currentShares =
                        (currentAmount * totalShares) /
                        (pool - currentAmount);
                } else {
                    currentShares = currentAmount;
                }

                (, uint256 dualTokensTemp) = calculateUserBalances(_user, _slot); //update dual token debt here because user shares are changing
                user.shares[_slot] = currentShares;
                user.dualTokenDebt[_slot] =
                    (user.shares[_slot] * dualTokenPerShare) /
                    PRECISION_FACTOR_SHARE; //set dual token debt equal to new debt minus token amount
                user.dualTokenDebt[_slot] -= dualTokensTemp; //giving user back their prev dual tokens
                totalShares += currentShares;

                // After the lock duration, update related parameters.
                if (user.lockEndTime[_slot] < block.timestamp) {
                    user.locked[_slot] = false;
                    user.lockStartTime[_slot] = 0;
                    user.lockEndTime[_slot] = 0;
                    totalLockedAmount -= user.lockedAmount[_slot];
                    user.lockedAmount[_slot] = 0;
                    emit Unlock(_user, currentAmount, block.timestamp, _slot);
                }
            }

            //Performance fee calculations (todo shouldn't this only occur if the user is withdrawing tokens?
            if (!feeDistributor.getFreePerformanceFeeUsers(_user)) {
                //calculate performance fees
                uint256 currentPerformanceFee = feeDistributor.calculatePerformanceFee(
                    _user,
                    _slot,
                    false,
                    user.shares,
                    user.locked,
                    user.tokensAtLastUserAction,
                    totalShares,
                    calculateTotalPendingTokensRewards(false),
                    balanceOf()
                );
                uint256 totalAmount = 0;
                if (totalShares != 0) {
                    totalAmount = (user.shares[_slot] * balanceOf()) / totalShares;
                }

                totalShares -= user.shares[_slot];
                user.shares[_slot] = 0;

                if (currentPerformanceFee > 0) {
                    totalFeeTracker += currentPerformanceFee;
                    totalAmount -= currentPerformanceFee;
                }
                // Recalculate the user's share.
                uint256 pool = balanceOf();
                uint256 newShares;
                if (totalShares != 0) {
                    newShares = (totalAmount * totalShares) / (pool - totalAmount);
                } else {
                    newShares = totalAmount;
                }
                (, uint256 dualTokensTemp) = calculateUserBalances(_user, _slot); //update dual token debt here because user shares are changing
                user.shares[_slot] = newShares;
                user.dualTokenDebt[_slot] =
                    (user.shares[_slot] * dualTokenPerShare) /
                    PRECISION_FACTOR_SHARE; //set dual token debt equal to new debt minus token amount
                user.dualTokenDebt[_slot] -= dualTokensTemp; //giving user back their prev dual tokens
                totalShares += newShares;
            }
        }

        if (dualTokenVault == true) {
            sendDualTokenRewards(_user, _slot);
        }
    }

    //An external non-reentrant version of distribute rewards
    function externalDistributeRewards() external whenNotPaused nonReentrant {
        distributeRewards();
    }

    /**
     * @notice Requests rewards from distributor based on blocks passed since last distribution
     */
    function distributeRewards() internal whenNotPaused {
        //skip if no new block
        if (block.number <= lastBlockDistributed) {
            return;
        }

        //skip if no tokens
        if (balanceOf() == 0 || totalShares == 0) {
            lastBlockDistributed = block.number;
            return;
        }

        //calculate number of blocks passed since last distribution
        uint256 blocksPassed = block.number - lastBlockDistributed;
        //update block number
        lastBlockDistributed = block.number;

        //withdraw rewards from distributor contract
        uint256 tokenHarvest;
        uint256 dualTokenHarvest;
        if (address(rewardDistributor) != address(0x0)) {
            if (rewardsPerBlock > 0) {
                tokenHarvest = rewardDistributor.withdraw(
                    blocksPassed * rewardsPerBlock,
                    false
                );
            }
            if (dualRewardsPerBlock > 0 && dualTokenVault == true) {
                dualTokenHarvest = rewardDistributor.withdraw(
                    blocksPassed * dualRewardsPerBlock,
                    true
                );
            }
        }

        // Calc new dual tokens received since last distribution
        uint256 newDualTokens = balanceOfDualToken();
        if (newDualTokens > totalDualToken) {
            newDualTokens -= totalDualToken;
        } else {
            newDualTokens = 0;
        }

        // update dualTokenPerShare
        uint256 newDualTokenPerShare = (newDualTokens * PRECISION_FACTOR_SHARE) /
            totalShares; //todo needs a percision multiplier
        dualTokenPerShare += newDualTokenPerShare;
        totalDualToken += (newDualTokenPerShare * totalShares) / PRECISION_FACTOR_SHARE; //adds new dual tokens to tracker only if they were enough to be > 0 in math calcs

        emit Harvest(msg.sender, tokenHarvest, dualTokenHarvest);
    }

    /**
     * @notice Adds new address to array of all vault holders
     */
    function addAddress(address userAddress) internal {
        UserInfo storage user = userInfo[userAddress];

        // If user already exists, skip. Otherwise add user to address list array
        if (user.exists == true) {
            return;
        } else {
            // else its new user
            addressIndexes.push(userAddress);
            if (addressIndexes.length > 0) {
                user.index = addressIndexes.length - 1;
            } else if (addressIndexes.length == 0) {
                user.index = addressIndexes.length;
            }
            user.exists = true;
        }
    }

    /**
     * @notice Deletes address to array of all vault holders
     */
    function deleteAddress() internal {
        // Checks if address exists
        if (userInfo[msg.sender].exists == true) {
            // Checks if index is not the last entry
            if (userInfo[msg.sender].index != addressIndexes.length - 1) {
                // Moves address from last slot to the slot of address going to be deleted, then deletes last slot.
                address lastAddress = addressIndexes[addressIndexes.length - 1];
                addressIndexes[userInfo[msg.sender].index] = lastAddress;
                userInfo[lastAddress].index = userInfo[msg.sender].index;
            }
            delete userInfo[msg.sender];
            addressIndexes.pop();
        }
    }

    /**
     * @notice Unlock user tokens funds. only callable by the owner of said tokens. No automated auto relockers?
     * @dev Only possible when contract not paused.
     * @param _user: User address
     * @param _slot: 0 = staking,1 = bonding
     */
    function unlock(address _user, uint256 _slot) external whenNotPaused {
        // Set user info based on bonding or staking
        require(msg.sender == _user || msg.sender == owner(), 'notuser');
        UserInfo storage user = userInfo[_user];
        require(
            user.locked[_slot] && user.lockEndTime[_slot] < block.timestamp,
            'timelock'
        );
        depositOperation(0, 0, _user, _slot);
    }

    /*  ===============================
        Set Functions 1/5 - Set Addresses/Wallets/Tokens
        ===============================*/

    // /**
    //  * @notice Set partnerAdmin address
    //  * @dev Only callable by the contract owner.
    //  */
    // function setAdminBonding(address _partnerAdmin, address _bondingContract)
    //     external
    //     onlyOwner
    // {
    //     require(_partnerAdmin != address(0), '0addr');
    //     require(_bondingContract != address(0), '0addr');
    //     partnerAdmin = _partnerAdmin;
    //     bondingContract = _bondingContract;
    //     emit NewAdminBonding(partnerAdmin, bondingContract);
    // }

    // // IS IT NECCESSARY ??? _________________________________
    // /**
    //  * @notice Sets interfance contracts
    //  * @dev Only callable by the contract owner.
    //  */
    // function setInterfaceContracts(
    //     IRewardDistributorV6 _rewardDistributor,
    //     IFeeDistributorV6 _feeDistributor
    // ) external onlyOwner {
    //     //uniswapV2Router = _uniswapV2Router;
    //     rewardDistributor = _rewardDistributor;
    //     feeDistributor = _feeDistributor;
    //     // todoemit something;
    // }

    // /**
    //  * @notice Sets voting token, altrucoin token and payout token, staking token, 2nd token
    //  * @dev Only callable by the contract owner.
    //  */
    // function setVaultTokens(IERC20 _token, IERC20 _dualToken) external onlyOwner {
    //     //note removed VotingToken _votingAddress, IERC20 _acAddress,
    //     //teamPayoutToken = _teamPayoutToken;
    //     token = _token;
    //     dualToken = _dualToken;
    //     //votingToken = _votingAddress;
    // }

    // IS IT NECCESSARY ??? _________________________________

    /*  ===============================
        Set Functions 2/5 - Fees and Expempt addresses
        ===============================*/

    function setFeeSendThreshold(uint256 _totalFeeSendThreshold) external onlyOwner {
        totalFeeSendThreshold = _totalFeeSendThreshold;
    }

    /*  ===============================
        Set Funcitons 3/5 - Bool/vault Controls
        ===============================*/

    /**
     * @notice Set enable/disable unstake early
     */
    function setVaultBools(
        bool _unstakeEarly,
        bool _unstakeEarlyBonding,
        bool _dualTokenVault,
        bool _feeForDualToken
    ) external onlyOwner {
        unstakeEarly = _unstakeEarly;
        unstakeEarlyBonding = _unstakeEarlyBonding;
        dualTokenVault = _dualTokenVault;
        feeForDualToken = _feeForDualToken;
    }

    /**
     * @notice Triggers deposit stopped state
     * @dev Only possible when contract not paused.
     */
    function setDisableDeposits(bool _disableDeposits) external {
        require(msg.sender == partnerAdmin);
        disableDeposits = _disableDeposits;
    }

    function setFeeTracker(address _feeTracker) external onlyOwner {
        feeTracker = _feeTracker;
    }

    function setFeeDistributor(address payable _feeDistributor) external onlyOwner {
        feeDistributor = IFeeDistributorV6(_feeDistributor);
    }

    function setRewardDistributor(address payable _rewardDistributor) external onlyOwner {
        rewardDistributor = IRewardDistributorV6(_rewardDistributor);
    }

    function setPartnerAdminWallet(address partnerAdmin_) external {
        require(msg.sender == partnerAdmin);
        feeDistributor.setPartnerAdminWallet(partnerAdmin_);
        partnerAdmin = partnerAdmin_;
    }

    /**
     * @notice sets number of tokens to distribute per block from distributor contract
     */
    function setRewardsPerBlock(uint256 _rewardsPerBlock, uint256 _dualRewardsPerBlock)
        external
        onlyOwner
    {
        dualRewardsPerBlock = _dualRewardsPerBlock;
        rewardsPerBlock = _rewardsPerBlock;
        lastBlockDistributed = block.number;
    }

    /**
     * @notice toggle using voting token
     */
    /*function setVotingTokenEnabled(bool _votingTokenEnabled,bool _mintVotingTokenOnUpdate) public onlyOwner {
        votingTokenEnabled = _votingTokenEnabled;
        mintVotingTokenOnUpdate = _mintVotingTokenOnUpdate;
    }*/

    /**
     * @notice sets number of tokens to distribute per block from distributor contract
     */
    function setMinDepositAndWithdraw(
        uint256 _min_deposit_amount,
        uint256 _min_withdraw_amount
    ) external onlyOwner {
        MIN_DEPOSIT_AMOUNT = _min_deposit_amount;
        MIN_WITHDRAW_AMOUNT = _min_withdraw_amount;
        emit NewMinEntryExit(MIN_DEPOSIT_AMOUNT, MIN_WITHDRAW_AMOUNT);
    }

    /*  ===============================
        Set Functions 4/5 - Durations
        ===============================*/

    /**
     * @notice Set MAX_LOCK_DURATION, values entered are in days
     * @dev Only callable by the contract owner.
     */
    function setMinMaxLockDuration(
        uint256 _minLockDuration,
        uint256 _minBondingLockDuration,
        uint256 _maxLockDuration,
        uint256 _durationFactor
    ) external onlyOwner {
        require(_minLockDuration * 1 days >= 1 days, '<min');
        require(_minBondingLockDuration * 1 days >= 1 days, '<bmin');
        require(_maxLockDuration * 1 days <= MAX_LOCK_DURATION_LIMIT, '>max');
        require(_durationFactor > 0, '!=0');

        MIN_LOCK_DURATION = _minLockDuration * 1 days;
        MIN_BONDING_LOCK_DURATION = _minBondingLockDuration * 1 days;
        MAX_LOCK_DURATION = _maxLockDuration * 1 days;
        DURATION_FACTOR = _durationFactor * 1 days; //usually equal to max lock

        emit NewMinMaxLockDuration(
            MIN_LOCK_DURATION,
            MIN_BONDING_LOCK_DURATION,
            MAX_LOCK_DURATION,
            DURATION_FACTOR
        );
    }

    //todo set bonding lock times min and max and make sure they are being used in deposit

    /*  ===============================
        Set Functions 5/5 - Boost Multiplier/Mics.
        ===============================*/

    /**
     * @notice Set BOOST_WEIGHT
     * @dev Only callable by the contract owner.
     */
    function setBoostWeight(uint256 _boostWeight) external onlyOwner {
        require(_boostWeight <= BOOST_WEIGHT_LIMIT, '>max');
        BOOST_WEIGHT = _boostWeight;
        emit NewBoostWeight(_boostWeight);
    }

    function checkFee() external returns (bool) {
        require(msg.sender == feeTracker);
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(feeTracker, address(this), 500);
        uint256 diff = token.balanceOf(address(this)) - balanceBefore;
        if (diff == 500) {
            _unpause();
            excludedFromFee = true;
            return true;
        }
        return false;
    }

    function supplyInitRewards() external {
        token.safeTransferFrom(
            msg.sender,
            address(rewardDistributor),
            rewardsPerBlock * 28800 * 30
        );
        initRewardsSupplyed = true;
    }

    /*  ===============================
        Emergency/Pause Function
        ===============================*/

    /**
     * @notice Withdraws tokens without caring about rewards. THIS CAN BREAK ALL VAULT MATH
     * @dev EMERGENCY ONLY. THIS CAN BREAK ALL VAULT MATH. Only callable by the contract owner.
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

    /**
     * @notice Trigger stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Return to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
        emit Unpause();
    }

    /*  ===============================
        View Functions 1 - Vault Info
        ===============================*/

    /**
     * @notice Returns all control bools of the vault
     */
    function getAllControls() external view returns (Controls memory) {
        Controls memory _controls = Controls({
            disableDeposits: disableDeposits,
            unstakeEarly: unstakeEarly,
            unstakeEarlyBonding: unstakeEarlyBonding,
            dualTokenVault: dualTokenVault,
            feeForDualToken: feeForDualToken,
            excludedFromFee: excludedFromFee,
            initRewardsSupplyed: initRewardsSupplyed
        });
        return _controls;
    }

    function getAddresses()
        external
        view
        returns (
            address,
            address,
            IFeeDistributorV6,
            IRewardDistributorV6
        )
    {
        //IUniswapV2Router02
        return (partnerAdmin, bondingContract, feeDistributor, rewardDistributor); //uniswapV2Router todo add more?
    }

    function getMinsAndBoostWeight()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (MIN_DEPOSIT_AMOUNT, MIN_WITHDRAW_AMOUNT, BOOST_WEIGHT);
    }

    function getTokens() external view returns (address, address) {
        return (address(token), address(dualToken)); // address(votingToken), address(teamPayoutToken)
    }

    function getDurations() external view returns (Durations memory) {
        (
            uint256 withdrawFeePeriod,
            uint256 UNLOCK_FREE_DURATION,
            uint256 DURATION_FACTOR_OVERDUE
        ) = feeDistributor.getDurations();
        Durations memory _durations = Durations({
            withdrawFeePeriod: withdrawFeePeriod,
            UNLOCK_FREE_DURATION: UNLOCK_FREE_DURATION,
            MIN_LOCK_DURATION: MIN_LOCK_DURATION,
            MIN_BONDING_LOCK_DURATION: MIN_BONDING_LOCK_DURATION,
            MAX_LOCK_DURATION: MAX_LOCK_DURATION,
            DURATION_FACTOR: DURATION_FACTOR,
            DURATION_FACTOR_OVERDUE: DURATION_FACTOR_OVERDUE
        });
        return (_durations); //address(votingToken)
    }

    function getVaultVariables() external view returns (VaultVariables memory) {
        VaultVariables memory _vaultVariables = VaultVariables({
            totalShares: totalShares,
            totalBoostDebt: totalBoostDebt,
            totalLockedAmount: totalLockedAmount,
            lastBlockDistributed: lastBlockDistributed,
            totalDualToken: totalDualToken,
            rewardsPerBlock: rewardsPerBlock,
            dualRewardsPerBlock: dualRewardsPerBlock,
            dualTokenPerShare: dualTokenPerShare,
            apyTokenTracker: apyTokenTracker
        });
        return _vaultVariables;
    }

    // ___________________________________

    /*  ===============================
        View Functions 2 - User Fees
        ===============================*/

    /**
     * @notice Returns staking fees
     */
    function getTotalFeesAndTrackers()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (totalFeeSendThreshold, totalFeeTracker, dualTotalFeeTracker);
    }

    /**
     * @notice Calculates the total pending rewards that can be harvested
     * @return Returns total pending cake rewards todo replace with your blockbased reward system todo also return pending dualtoken?
     */
    function calculateTotalPendingTokensRewards(bool _dualToken)
        public
        view
        returns (uint256)
    {
        if (block.number <= lastBlockDistributed) {
            return (0);
        }
        if (balanceOf() == 0 || totalShares == 0) {
            return (0);
        }
        uint256 blocksPassed = block.number - lastBlockDistributed;
        uint256 amount;
        if (_dualToken == false) {
            amount = rewardDistributor.pendingRewards();
        } else {
            amount = rewardDistributor.pendingRewards();
        }
        return amount;
    }

    /*  ===============================
        View Functions 3 - Token Amounts
        ===============================*/

    /**
     * @notice Current pool available balance
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() public view returns (uint256) {
        return token.balanceOf(address(this)) - totalFeeTracker;
    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and the boost debt amount. Excludes fees to go out.
     */
    function balanceOf() public view returns (uint256) {
        // if (totalFeeTracker >= token.balanceOf(address(this))) {
        //     return token.balanceOf(address(this)) + totalBoostDebt - totalFeeTracker;
        // }
        if (token.balanceOf(address(this)) + totalBoostDebt > totalFeeTracker) {
            return token.balanceOf(address(this)) + totalBoostDebt - totalFeeTracker;
        }
        return 0;
    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and the boost debt amount. Excludes fees to go out.
     */
    function balanceOfDualToken() public view returns (uint256) {
        if (address(dualToken) != address(0x0)) {
            //BEP20 Dual Token
            if (dualTotalFeeTracker >= dualToken.balanceOf(address(this))) {
                return dualToken.balanceOf(address(this)) - dualTotalFeeTracker;
            }
        } else {
            //BNB Dual Token
            if (dualTotalFeeTracker >= address(this).balance) {
                return address(this).balance - dualTotalFeeTracker;
            }
        }
        return 0;
    }

    /*  ===============================
        View Functions 4 - User Info
        ===============================*/

    /**
     * @notice Returns total number of users in the vault
     */
    function getTotalUsers() external view returns (uint256) {
        return addressIndexes.length;
    }

    /**
     * @notice gets all info for a specific user in the vault
     */
    function getUserInfo1(address _address, uint256 _slot)
        external
        view
        returns (UserInfo1 memory)
    {
        UserInfo storage user = userInfo[_address]; // Set user
        UserInfo1 memory _userInfo1 = UserInfo1({
            exists: user.exists,
            index: user.index,
            shares: user.shares[_slot],
            userBoostedShare: user.userBoostedShare[_slot],
            lockedAmount: user.lockedAmount[_slot]
        });

        return _userInfo1;
    }

    /**
     * @notice gets all info for a specific user in the vault
     */
    function getUserInfo2(address _address, uint256 _slot)
        external
        view
        returns (UserInfo2 memory)
    {
        UserInfo storage user = userInfo[_address]; // Set user
        UserInfo2 memory _userInfo2 = UserInfo2({
            lastDepositedTime: user.lastDepositedTime[_slot],
            tokensAtLastUserAction: user.tokensAtLastUserAction[_slot],
            lastUserActionTime: user.lastUserActionTime[_slot],
            dualTokenDebt: user.dualTokenDebt[_slot],
            lockEndTime: user.lockEndTime[_slot]
        });
        return _userInfo2;
    }

    // /**
    //  * @notice Gets users lock time remaining
    //  */
    // function getUserLockInfo(address _address, uint256 _slot)
    //     external
    //     view
    //     returns (
    //         int256,
    //         uint256,
    //         uint256,
    //         bool
    //     )
    // {
    //     UserInfo storage user = userInfo[_address];
    //     int256 timeInSeconds = int256(user.lockEndTime[_slot]) - int256(block.timestamp); //remove if needed to save space
    //     if (timeInSeconds <= 0) {
    //         timeInSeconds = 0;
    //     }

    //     return (
    //         timeInSeconds,
    //         user.lockStartTime[_slot],
    //         user.lockEndTime[_slot],
    //         user.locked[_slot]
    //     );
    // }

    // /**
    //  * @notice gets certain info of all users in the vault in a structured manner
    //  * @param _rangeMultiplier is which multiple of length to look at (ie, multiplier 2 of range 30000 will be addresses 60,000 -> 90,000)
    //  * @param _rangeLength is the number of users info to return. 30000 will return that many users. Adjustable to prevent function from failing
    //  */
    // function getAllUserInfoStructured(uint256 _rangeMultiplier, uint256 _rangeLength)
    //     external
    //     view
    //     onlyOwner
    //     returns (
    //         uint256[] memory,
    //         address[] memory,
    //         uint256[] memory,
    //         uint256[] memory,
    //         uint256[] memory,
    //         uint256[] memory
    //     )
    // {
    //     //initialize arrays
    //     uint256[] memory id = new uint256[](addressIndexes.length);
    //     address[] memory addresses = new address[](addressIndexes.length);
    //     uint256[] memory stakingBalance = new uint256[](addressIndexes.length);
    //     uint256[] memory bondingBalance = new uint256[](addressIndexes.length);
    //     uint256[] memory dualTokenBalance1 = new uint256[](addressIndexes.length);
    //     uint256[] memory dualTokenBalance2 = new uint256[](addressIndexes.length);

    //     //range calculations
    //     uint256 tempLengthStart;
    //     uint256 tempLengthEnd;
    //     if (addressIndexes.length <= _rangeLength) {
    //         tempLengthStart = 0;
    //         tempLengthEnd = addressIndexes.length;
    //     } else {
    //         tempLengthStart = _rangeLength * _rangeMultiplier;
    //         tempLengthEnd = tempLengthStart + _rangeLength;
    //     }

    //     //loop to gather info
    //     for (uint256 i = tempLengthStart; i <= tempLengthEnd; i++) {
    //         id[i] = i;
    //         addresses[i] = addressIndexes[i];
    //         stakingBalance[i] =
    //             userInfo[addressIndexes[i]].shares[0] -
    //             userInfo[addressIndexes[i]].userBoostedShare[0];
    //         bondingBalance[i] =
    //             userInfo[addressIndexes[i]].shares[1] -
    //             userInfo[addressIndexes[i]].userBoostedShare[1];
    //         dualTokenBalance1[i] =
    //             ((userInfo[addressIndexes[i]].shares[0] * dualTokenPerShare) /
    //                 PRECISION_FACTOR_SHARE) -
    //             userInfo[addressIndexes[i]].dualTokenDebt[0];
    //         dualTokenBalance2[i] =
    //             ((userInfo[addressIndexes[i]].shares[1] * dualTokenPerShare) /
    //                 PRECISION_FACTOR_SHARE) -
    //             userInfo[addressIndexes[i]].dualTokenDebt[1];
    //     }

    //     return (
    //         id,
    //         addresses,
    //         stakingBalance,
    //         bondingBalance,
    //         dualTokenBalance1,
    //         dualTokenBalance2
    //     );
    // }

    /**
     * @notice Returns address at index.
     */
    function getAddressAtIndex(uint256 _index) external view returns (address) {
        return addressIndexes[_index];
    }

    //This funciton should be used for UI. it would be user.shares (minus debt) * this value = user tokens held. note dual token is just user shares times dual token multiplier - user dual token debt
    function getPricePerFullShare() external view returns (uint256) {
        return
            totalShares == 0
                ? 1e18
                : (((balanceOf() + calculateTotalPendingTokensRewards(false)) * (1e18)) /
                    totalShares);
    } //todo add getting dual token too

    /*  ===============================
        Modifier functions
        ===============================*/

    /**
     * @notice checks that deposits are enabled
     */
    function whenEnabledDeposits() internal view {
        require(disableDeposits == false);
    }

    /**
     * @notice Checks if address is a contract
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /*  ===============================
        Misc. functions
        ===============================*/

    //set user info todo
    //todo bring in PCS functions but make them a library?
    //todo check all calls of these to make sure they are calling them correctly

    receive() external payable {}

    fallback() external payable {}
}

contract StakingFactoryV6 {
    address public creator;

    constructor(address creator_) {
        creator = creator_;
    }

    function createStaking(
        address token_,
        address dualToken_,
        bool dualTokenVault,
        uint256 rewardsPerBlock_,
        uint256 tokenDecimals_,
        uint256 dualTokenDecimals_,
        address partnerAdmin,
        uint256 boostWeight,
        uint256 minLock,
        uint256 maxLock,
        bool unstakeEarly
    ) external returns (address) {
        require(msg.sender == creator);
        StakingVaultV6_0_0 _staking = new StakingVaultV6_0_0(
            IERC20(token_),
            IERC20(dualToken_),
            dualTokenVault,
            rewardsPerBlock_,
            rewardsPerBlock_,
            tokenDecimals_,
            dualTokenDecimals_,
            partnerAdmin,
            boostWeight,
            minLock,
            maxLock,
            unstakeEarly
        );
        _staking.transferOwnership(msg.sender);
        return address(_staking);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

interface IFeeDistributorV6 {
    struct UserInfo {
        uint256[2] shares; // number of shares for a user. includes boost (boost or boost rewards?). shares are used to calc user % of pool and rewards after boost.
        uint256[2] userBoostedShare; // debt - boost shares are the number of shares that were added on top of the standard ones to produce boost for user (real+boost is saved in user.shares). Used in order to give the user higher reward. The user only enjoys the reward, so the boost amount needs to be recorded as a debt, that is this variable.
        uint256[2] lockedAmount; // amount deposited during lock period. This + reward is what the user actually has
        uint256[2] lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256[2] tokensAtLastUserAction; // keep track of tokens deposited at the last user action.
        uint256[2] lastUserActionTime; // keep track of the last user action time.
        uint256[2] lockStartTime; // lock start time.
        uint256[2] lockEndTime; // lock end time.
        uint256[2] dualTokenDebt; //dualToken debt so users have 0 of the dualToken token rewards on deposit. It will be reset on ALL user deposits or withdraws from the vault.
        uint256 index; //user position in vault
        bool exists;
        bool[2] locked; //lock status.
    }

    struct EntryExitFees {
        uint256 entryFee;
        uint256 withdrawFee;
        uint256 earlyWithdrawExtraFee;
    }

    struct APYData {
        uint256 totalRewards7Days;
        uint256 allTimeFeeTracker;
        uint256 dualTotalRewards7Days;
        uint256 allTimeFeeTracker2ndToken;
    }

    event DexSwap();
    event FreeFeeUser(
        address indexed user,
        bool performanceFree,
        bool overdueFree,
        bool entryExitFree
    );
    event NewDurationFactorOverdue(
        uint256 durationFactorOverdue,
        uint256 unlockFreeDuration
    );
    event NewEntryExitFees(
        uint256 entryFee,
        uint256 entryFeeContract,
        uint256 performanceFee,
        uint256 performanceFeeContract,
        uint256 withdrawFee,
        uint256 withdrawFeeContract,
        uint256 earlyWithdrawExtraFee,
        uint256 slot
    );
    event NewFeeWallets(
        address adminPayoutWallet,
        address platformWallet,
        address charityWallet,
        address bondingPayoutWallet,
        address rewardDistributor
    );
    event NewOverdueFee(uint256 overdueFee);
    event NewWithdrawFeePeriod(uint256 withdrawFeePeriod);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event PayoutFees();
    event Unpaused(address account);

    fallback() external payable;

    function adminFee() external view returns (uint256);

    function adminPayoutWallet() external view returns (address);

    function bondingFee() external view returns (uint256);

    function bondingPayoutWallet() external view returns (address);

    function burnFee() external view returns (uint256);

    function calculateOverdueFee(
        address _user,
        uint256 _slot,
        bool _fullAmountAndPending,
        IFeeDistributorV6.UserInfo memory user,
        uint256 _totalPendingTokens,
        uint256 _balance,
        uint256 _totalShares,
        uint256 _precisionFactor
    ) external view returns (uint256);

    function calculatePerformanceFee(
        address _user,
        uint256 _slot,
        bool _fullAmountAndPending,
        uint256[2] memory userShares,
        bool[2] memory userLocked,
        uint256[2] memory userTokensAtLastUserAction,
        uint256 _totalShares,
        uint256 _totalPendingTokens,
        uint256 _balance
    ) external view returns (uint256);

    function calculateWithdrawFee(
        address _user,
        uint256 _slot,
        uint256 _amount,
        bool _fullAmountAndPending,
        uint256[2] memory userLastDepositedTime,
        uint256[2] memory userLockEndTime,
        uint256 _totalPendingTokens,
        uint256 _balance
    ) external view returns (uint256);

    function charityFee() external view returns (uint256);

    function charityWallet() external view returns (address);

    function dualToken() external view returns (address);

    function dualTokenRunningTotal() external view returns (uint256);

    function dualTokenVault() external view returns (bool);

    function feeTracker(uint256 _feeTotal, bool _dualToken) external;

    function getEntryExitFees(uint256 slot) external view returns (EntryExitFees memory);

    function adminPayOutWallet() external view returns (address);

    function getAPYData()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getDurations()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getEntryFee(uint256 slot) external view returns (uint256);

    function getEntryFeeContract() external view returns (uint256);

    function getFreeEntryExtiFeeUsers(address user) external view returns (bool);

    function getFreePerformanceFeeUsers(address user) external view returns (bool);

    function getUserFeeExclusions(address _user)
        external
        view
        returns (
            bool,
            bool,
            bool
        );

    function owner() external view returns (address);

    function paused() external view returns (bool);

    function payoutFees() external;

    function platformFee() external view returns (uint256);

    function platformWallet() external view returns (address);

    function renounceOwnership() external;

    function rewardDistributor() external view returns (address);

    function rewardFee() external view returns (uint256);

    function setDEXRouter(address newDexAddress) external;

    function setDistributionFees(
        uint256 _platformFee,
        uint256 _rewardFee,
        uint256 _charityFee,
        uint256 _adminFee,
        uint256 _burnFee,
        uint256 _bondingFee
    ) external;

    function setEntryExitFees(
        uint256 _slot,
        uint256 _entryFee,
        uint256 _entryFeeContract,
        uint256 _performanceFee,
        uint256 _performanceFeeContract,
        uint256 _withdrawFee,
        uint256 _withdrawFeeContract,
        uint256 _earlyWithdrawExtraFee
    ) external;

    function setFeeBools(bool _performanceFeeOnLocked, bool _timeWithdrawFeeOnly)
        external;

    function setFeeWallets(
        address _adminPayoutWallet,
        address _platformWallet,
        address _charityWallet,
        address _bondingPayoutWallet,
        address _rewardDistributor
    ) external;

    function setFreeFeeUser(
        address _user,
        bool _PerformanceFree,
        bool _OverdueFree,
        bool _EntryExitFree
    ) external;

    function setOverdueDurations(
        uint256 _durationFactorOverdue,
        uint256 _unlockFreeDuration
    ) external;

    function emergencyWithdraw(
        address _randomToken,
        bool takeTokens,
        uint256 tokenAmount,
        bool takeBNB,
        uint256 bnbAmount,
        bool takeAllTokens,
        bool takeAllBNB
    ) external;

    function pendingRewards(
        uint256 _blocksPassed,
        uint256 _rewardsPerBlock,
        bool _dualToken
    ) external view returns (uint256);

    function runway(uint256 _rewardsPerBlock, bool _dualToken)
        external
        view
        returns (uint256);

    function withdraw(uint256 _amount, bool _dualTokenWithdraw)
        external
        returns (uint256);

    function setOverdueFee(uint256 _overdueFee) external;

    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external;

    function teamPayoutToken() external view returns (address);

    function token() external view returns (address);

    function tokenRunningTotal() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function uniswapV2Router() external view returns (address);

    function vault() external view returns (address);

    function setPartnerAdminWallet(address partnerAdmin_) external;

    function checkFee() external returns (bool);

    receive() external payable;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.12;

interface IRewardDistributorV6 {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event Unpaused(address account);

    function deposit(uint256 _amount, bool _dualTokenDeposit) external;

    function dualTokenRunningTotal() external view returns (uint256);

    function dualTokenVault() external view returns (bool);

    function emergencyWithdraw(
        address _randomToken,
        bool takeTokens,
        uint256 tokenAmount,
        bool takeBNB,
        uint256 bnbAmount,
        bool takeAllTokens,
        bool takeAllBNB
    ) external;

    function owner() external view returns (address);

    function paused() external view returns (bool);

    function pendingRewards() external view returns (uint256);

    function renounceOwnership() external;

    function runway() external view returns (uint256);

    function token() external view returns (address);

    function tokenRunningTotal() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function vault() external view returns (address);

    function withdraw(uint256 _amount, bool _dualTokenWithdraw)
        external
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}