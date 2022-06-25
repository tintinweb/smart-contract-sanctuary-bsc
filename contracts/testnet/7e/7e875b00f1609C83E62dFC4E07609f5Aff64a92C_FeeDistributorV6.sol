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

//Created by Altrucoin.com - Block based fee distributor for V6.0.0 Vault

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import './interfaces/IFeeDistributor.sol';
import './interfaces/IUniswapV2Router01.sol';
import './interfaces/IUniswapV2Router02.sol';
import 'hardhat/console.sol';

/*
    implementation steps: todo
        Get fee variables (make public or bring get functions too)
        Make a distribute fees functions that is external
*/

contract FeeDistributorV6 is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct FeeInputs {
        uint256 burnFee;
        uint256 charityFee;
        uint256 earlyWithdrawFee;
        uint256 rewardFee;
        uint256 entryFee;
        uint256 exitFee;
    }

    address public partnerAdmin;

    //Initialize Variables
    address public vault; //has permission to call fee distribution functions
    IERC20 public token; // staking token.
    IERC20 public dualToken; // 2nd Token in dual rewards system (can be any bep20 token)
    IERC20 public teamPayoutToken; // Token type for Altrucoin team payments

    // Control Bools
    bool public dualTokenVault = false;

    //Payout Wallet Adresses
    address public platformWallet; // Altrucoin Team wallet for platform fee
    address public adminPayoutWallet; // Partner dev wallet, not used in decentralized onboarding
    address public charityWallet;
    address public bondingPayoutWallet; //bonding system funding address
    address public rewardDistributor; //block based distributor contract

    //Interfaces
    IUniswapV2Router02 public uniswapV2Router; //PancakeSwap Interface

    //Fee distributions // _slot 0 is staking, _slot 1 is bonding
    uint256 public platformFee = 150; // 150 = 1.5%
    uint256 public rewardFee = 350; // 350 = 3.5%
    uint256 public charityFee = 0; // 100 = 1% pool charity fee
    uint256 public adminFee = 0;
    uint256 public burnFee = 0;
    uint256 public bondingFee = 0; // fee of tokens sent to a bonding system? for AC this is going to be 0 and for other vaults the platform fee will go to the AC bonding system. This is just for partner vault -> partner bonding system

    //TODO add max fee constants

    //Total fees and trackers
    uint256 private totalFee = 500; // 500= 5% all distribution fees together, used to calculate fee tracker distribution
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

    uint256[2] private entryFee = [0, 0]; // 500 = 5% (all entry fees in one)
    uint256[2] private withdrawFee = [500, 500]; // 500% (all exit fees in one)
    uint256[2] private earlyWithdrawExtraFee = [1000, 1000]; // 1500 = 15% + normal withdraw = 20%

    uint256 private entryFeeContract = 0; // 10% (all entry fees in one)
    uint256 private withdrawFeeContract = 500; // 10% (all exit fees in one)
    uint256 private overdueFee = 100 * 1e10; // 100% this was created by pcs

    uint256 private UNLOCK_FREE_DURATION = 1 weeks; // 1 week - This is the amount of time after tokens unlock before overdue fee starts.

    // ??
    uint256[2] private performanceFee = [200, 200]; // 2% //This applies to gains only
    uint256 private performanceFeeContract = 200; // 2%
    bool private performanceFeeOnLocked = true;
    uint256 private withdrawFeePeriod = 72 hours; // 3 days
    mapping(address => bool) private freeEntryExitFeeUsers; // free entry/withdraw fee users.
    //Distribution Running Totals
    uint256 public tokenRunningTotal; //lifetime number of tokens distributed
    uint256 public dualTokenRunningTotal;

    //todo make these variables changeable (set functions)

    uint256 private constant MAX_PERFORMANCE_FEE = 2000; // 20%
    uint256 private constant MAX_WITHDRAW_FEE = 1000; // 5%
    uint256 private constant MAX_EARLY_WITHDRAW_FEE = 5000; // 50%
    uint256 private constant MAX_OVERDUE_FEE = 100 * 1e10; // 100%
    uint256 private DURATION_FACTOR_OVERDUE = 180 days; // 180 days, MAX overdue fee time. At this amount of time the full overdue fee applies to

    mapping(address => bool) private freePerformanceFeeUsers; // free performance fee users.
    mapping(address => bool) private freeOverdueFeeUsers; // free overdue fee users.
    bool private timedWithdrawFeeOnly = false; //only apply withdraw fee if withdraw within withdrawFeePeriod

    // make emits:
    event DexSwap();
    event NewFeeWallets(
        address adminPayoutWallet,
        address platformWallet,
        address charityWallet,
        address bondingPayoutWallet,
        address rewardDistributor
    );
    event PayoutFees();
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
    event NewOverdueFee(uint256 overdueFee);
    event FreeFeeUser(
        address indexed user,
        bool performanceFree,
        bool overdueFree,
        bool entryExitFree
    );
    event NewWithdrawFeePeriod(uint256 withdrawFeePeriod);
    event NewDurationFactorOverdue(
        uint256 durationFactorOverdue,
        uint256 unlockFreeDuration
    );

    /**
     * @notice Constructor
     * @param _token: staking token contract
     * @param _token: dual token contract
     */
    constructor(
        IERC20 _token,
        IERC20 _dualToken,
        bool _dualTokenVault, //addresses, Hard code?
        address router,
        address _partnerAdmin,
        FeeInputs memory _feeInputs,
        IERC20 _teamPayOutToken
    ) {
        token = _token;
        dualToken = _dualToken;
        dualTokenVault = _dualTokenVault;
        partnerAdmin = _partnerAdmin;
        burnFee = _feeInputs.burnFee;
        charityFee = _feeInputs.charityFee;
        rewardFee = _feeInputs.rewardFee;
        earlyWithdrawExtraFee[0] = _feeInputs.earlyWithdrawFee;
        entryFee[0] = _feeInputs.entryFee;
        withdrawFee[0] = _feeInputs.exitFee;
        teamPayoutToken = _teamPayOutToken;
        //transferOwnership(hardcode address); //todo set this to

        // Set Pancakeswap Router for token swapping
        // MAINNET PCS Router: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // TESTNET PCS Router: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        uniswapV2Router = IUniswapV2Router02(router);
    }

    /*  ===============================
        Primary Functions - Deposit/Withdraw
        =============================== */

    /**
     * @notice Pays out team, admin, charity, etc. fees if threshold is met
     */
    function payoutFees() external whenNotPaused nonReentrant {
        //note probably can convert this to a loop to save on space. Could make fees an array
        if (
            token.balanceOf(address(this)) == 0 && dualToken.balanceOf(address(this)) == 0
        ) {
            return;
        }
        uint256 tempTotalFeeTracker;
        uint256 balanceBf;
        uint256 balanceAf;
        if (token.balanceOf(address(this)) > 0) {
            tempTotalFeeTracker = token.balanceOf(address(this));

            tokenRunningTotal += tempTotalFeeTracker;

            //Send out each fee
            if (platformFee > 0) {
                uint256 platformFeeOut = (tempTotalFeeTracker * platformFee) / totalFee;
                balanceBf = teamPayoutToken.balanceOf(address(this));
                swapBEP20TokenForBEP20Token(platformFeeOut, token, teamPayoutToken);
                balanceAf = teamPayoutToken.balanceOf(address(this)) - balanceBf;
                if (balanceAf > 0) {
                    teamPayoutToken.safeTransfer(platformWallet, balanceAf);
                }
                //completed earlier tokenRunningTotal += platformFeeOut;
            }
            if (charityFee > 0) {
                uint256 charityFeeOut = (tempTotalFeeTracker * charityFee) / totalFee;
                balanceBf = teamPayoutToken.balanceOf(address(this));
                swapBEP20TokenForBEP20Token(charityFeeOut, token, teamPayoutToken);
                balanceAf = teamPayoutToken.balanceOf(address(this)) - balanceBf;
                if (balanceAf > 0) {
                    teamPayoutToken.safeTransfer(charityWallet, balanceAf);
                }
                //completed earlier tokenRunningTotal += charityFeeOut;
            }
            if (adminFee > 0) {
                uint256 adminFeeOut = (tempTotalFeeTracker * adminFee) / totalFee;
                token.safeTransfer(adminPayoutWallet, adminFeeOut);
                //completed earlier tokenRunningTotal += adminFeeOut;
            }
            if (rewardFee > 0) {
                uint256 rewardFeeOut = (tempTotalFeeTracker * rewardFee) / totalFee; //left here or sent to distributor
                if (address(rewardDistributor) != address(0x0)) {
                    token.safeTransfer(address(rewardDistributor), rewardFeeOut);
                }
                //completed earlier tokenRunningTotal += rewardFeeOut;
            }
            if (burnFee > 0) {
                uint256 burnFeeOut = (tempTotalFeeTracker * burnFee) / totalFee;
                token.safeTransfer(
                    address(0x000000000000000000000000000000000000dEaD),
                    burnFeeOut
                );
                //completed earlier tokenRunningTotal += burnFeeOut;
            }
            if (bondingFee > 0) {
                uint256 bondingFeeOut = (tempTotalFeeTracker * bondingFee) / totalFee;
                token.safeTransfer(bondingPayoutWallet, bondingFeeOut);
                //completed earlier tokenRunningTotal += bondingFeeOut;
            }
        }

        // Fee on Dual token vaults
        if (dualTokenVault == true && dualToken.balanceOf(address(this)) > 0) {
            tempTotalFeeTracker = dualToken.balanceOf(address(this));

            dualTokenRunningTotal += tempTotalFeeTracker;

            // Send out each fee
            if (platformFee > 0) {
                uint256 platformFeeOutDual = (tempTotalFeeTracker * platformFee) /
                    totalFee;
                if (address(dualToken) != address(0x0)) {
                    balanceBf = teamPayoutToken.balanceOf(address(this));
                    swapBEP20TokenForBEP20Token(
                        platformFeeOutDual,
                        dualToken,
                        teamPayoutToken
                    );
                    balanceAf = teamPayoutToken.balanceOf(address(this)) - balanceBf;
                    if (balanceAf > 0) {
                        teamPayoutToken.safeTransfer(platformWallet, balanceAf);
                    }
                } else {
                    balanceBf = teamPayoutToken.balanceOf(address(this));
                    swapBNBForTokens(platformFeeOutDual, teamPayoutToken);
                    balanceAf = teamPayoutToken.balanceOf(address(this)) - balanceBf;
                    if (balanceAf > 0) {
                        teamPayoutToken.safeTransfer(platformWallet, balanceAf);
                    }
                }
                //dualTokenRunningTotal += platformFeeOutDual; done earlier
            }

            if (charityFee > 0) {
                uint256 charityFeeOutDual = (tempTotalFeeTracker * charityFee) / totalFee;
                if (address(dualToken) != address(0x0)) {
                    balanceBf = teamPayoutToken.balanceOf(address(this));
                    swapBEP20TokenForBEP20Token(
                        charityFeeOutDual,
                        dualToken,
                        teamPayoutToken
                    );
                    balanceAf = teamPayoutToken.balanceOf(address(this)) - balanceBf;
                    if (balanceAf > 0) {
                        teamPayoutToken.safeTransfer(charityWallet, balanceAf);
                    }
                } else {
                    balanceBf = teamPayoutToken.balanceOf(address(this));
                    swapBNBForTokens(charityFeeOutDual, teamPayoutToken);
                    balanceAf = teamPayoutToken.balanceOf(address(this)) - balanceBf;
                    if (balanceAf > 0) {
                        teamPayoutToken.safeTransfer(charityWallet, balanceAf);
                    }
                }
                //dualTokenRunningTotal += charityFeeOutDual; done earlier
            }

            if (adminFee > 0) {
                uint256 adminFeeOutDual = (tempTotalFeeTracker * adminFee) / totalFee;
                if (address(dualToken) != address(0x0)) {
                    dualToken.safeTransfer(adminPayoutWallet, adminFeeOutDual);
                } else {
                    payable(adminPayoutWallet).transfer(adminFeeOutDual);
                }
                //dualTokenRunningTotal += adminFeeOutDual; done earlier
            }

            if (rewardFee > 0) {
                //calc reward fee, include bonding and burn fee
                uint256 rewardFeeOutDual = (tempTotalFeeTracker * rewardFee) / totalFee; //reward fee is converted to main token and left in vault
                uint256 burnFeeOutDual = (tempTotalFeeTracker * burnFee) / totalFee; //no burn on second token, added back to rewards
                uint256 bondingFeeOutDual = (tempTotalFeeTracker * bondingFee) / totalFee; //no bonding on second token, added back to rewards
                rewardFeeOutDual += burnFeeOutDual + bondingFeeOutDual; //no burn on second token (can send to distributor as well? Or leave in vault?)

                balanceBf = token.balanceOf(address(this));
                if (address(dualToken) != address(0x0)) {
                    swapBEP20TokenForBEP20Token(rewardFeeOutDual, dualToken, token);
                } else {
                    swapBNBForTokens(rewardFeeOutDual, token);
                }

                //Send to distributor if it exists
                balanceAf = token.balanceOf(address(this)) - balanceBf;
                if (address(rewardDistributor) != address(0x0)) {
                    token.safeTransfer(address(rewardDistributor), balanceAf);
                }

                //dualTokenRunningTotal += rewardFeeOutDual; done earlier
            }
        }
    }

    /*  ===============================
        Set Functions
        ===============================*/

    /**
     * @notice Sets fee payout wallets for admin, platform and charity fees
     * @dev Only callable by the contract admin.
     */
    function setFeeWallets(
        address _adminPayoutWallet,
        address _platformWallet,
        address _charityWallet,
        address _bondingPayoutWallet,
        address _rewardDistributor
    ) external onlyOwner {
        adminPayoutWallet = _adminPayoutWallet;
        platformWallet = _platformWallet;
        charityWallet = _charityWallet;
        bondingPayoutWallet = _bondingPayoutWallet;
        rewardDistributor = _rewardDistributor;
        emit NewFeeWallets(
            adminPayoutWallet,
            platformWallet,
            charityWallet,
            bondingPayoutWallet,
            rewardDistributor
        );
    }

    function setDistributionFees(
        uint256 _platformFee,
        uint256 _rewardFee,
        uint256 _charityFee,
        uint256 _adminFee,
        uint256 _burnFee,
        uint256 _bondingFee
    ) external onlyOwner {
        //Distribution fees
        platformFee = _platformFee;
        rewardFee = _rewardFee;
        charityFee = _charityFee;
        adminFee = _adminFee;
        burnFee = _burnFee;
        bondingFee = _bondingFee;

        //Set total fee divisor
        totalFee = platformFee + rewardFee + charityFee + adminFee + burnFee + bondingFee;

        // todo emit NewDistributionFees(platformFee, rewardFee, charityFee, adminFee, burnFee, bondingFee, totalFee);
    }

    /*============================================
    /   DEX Swapping Functions
    /=============================================*/

    // NOT USED ???
    // /**
    //  * @notice Swaps tokens on the contract for BNB using Pancakeswap. Unused in the ALTRU vault
    //  */
    // function swapTokensForBNB(uint256 tokenAmount, IERC20 tokenToSell) internal {
    //     // Generate the uniswap pair path of token -> WETH
    //     address[] memory path = new address[](2);
    //     path[0] = address(tokenToSell);
    //     path[1] = uniswapV2Router.WETH();
    //     tokenToSell.approve(address(uniswapV2Router), tokenAmount); //todo does this work?
    //     // Make the swap
    //     uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         tokenAmount,
    //         0, // Accept any amount of ETH
    //         path,
    //         address(this), // The contract	todo switch to the vault contract? pass in?
    //         (block.timestamp + 600)
    //     );

    //     //emit todo DexSwap(tokenAmount, path);
    // }

    /**
     * @notice Converts staking tokens to a new token type using Pancakeswap
     */
    function swapBEP20TokenForBEP20Token(
        uint256 amount,
        IERC20 startingToken,
        IERC20 endingToken
    ) internal {
        // Generate the pancakeswap pair path of token -> WETH -> new token
        address[] memory path = new address[](3);
        path[0] = address(startingToken);
        path[1] = uniswapV2Router.WETH();
        path[2] = address(endingToken);
        startingToken.approve(address(uniswapV2Router), amount);
        // Make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // Accept any amount of Tokens
            path,
            address(this), // Vault address
            (block.timestamp + 600)
        );
        //emit DexSwap(amount, path);
    }

    /**
     * @notice Funciton to exchange BNB for staking tokens
     */
    function swapBNBForTokens(uint256 amount, IERC20 purchasedToken) internal {
        // Generate the pancakeswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(purchasedToken);
        // Make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // Accept any amount of Tokens
            path,
            address(this), // Vault address
            (block.timestamp + 600)
        );

        //emit DexSwap(amount, path);
    }

    /**
     * @notice Change DEX router in case PCS updates. Best to pause vault before using.
     * @dev Only callable by the contract owner.
     */
    function setDEXRouter(IUniswapV2Router02 newDexAddress) external onlyOwner {
        uniswapV2Router = newDexAddress;
    }

    /**
     * @notice Totals up rewards from the last 7 days.
     */
    function feeTracker(uint256 _feeTotal, bool _dualToken) external {
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
     * @notice Calculate Performance fee. Performance fee is fee on only earned tokens
     * @param _user: User address
     * @return Returns Performance fee.
     * @param _slot: 0 = staking,1 = bonding
     * @param _fullAmountAndPending: find fee on full amount + pending rewards?
     */
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
    ) public view returns (uint256) {
        if (performanceFee[_slot] == 0 && performanceFeeContract == 0) {
            return 0;
        }
        // Set user info based on bonding or staking
        if (
            userShares[_slot] > 0 &&
            !freePerformanceFeeUsers[_user] &&
            (performanceFeeOnLocked || userLocked[_slot] == false) // this section is togglable to effect locked tokens
        ) {
            uint256 pool;
            if (_fullAmountAndPending) {
                pool = _balance + _totalPendingTokens;
            } else {
                pool = _balance;
            } //Note User balances would be calculated in front end based on user.shares *( balance + pending rewards). enable it in other calc func too then and add one for withdraw taht includes pending

            //convert from shares to tokens for user
            uint256 totalAmount = (userShares[_slot] * pool) / _totalShares;
            uint256 earnAmount = totalAmount - userTokensAtLastUserAction[_slot]; //only take fee from rewards //note this is how to calculate user rewards

            //set fee rate for normal or contract transaction
            uint256 feeRate = performanceFee[_slot];
            if (_isContract(_user) && _slot == 0) {
                feeRate = performanceFeeContract; //Different fee for contracts
            }
            uint256 currentPerformanceFee = (earnAmount * feeRate) / 10000;
            return currentPerformanceFee;
        }
        return 0;
    }

    /**
     * @notice Calculate withdraw fee. - slightly different that the other fee functions because they always apply on full amount, withdraw does not.
     * @param _user: User address
     * @return Returns withdraw fee based on amount
     * @param _slot: 0 = staking,1 = bonding
     * @param _fullAmountAndPending: find fee on full amount + pending rewards?
     */
    function calculateWithdrawFee(
        address _user,
        uint256 _slot,
        uint256 _amount,
        bool _fullAmountAndPending,
        uint256[2] memory userLastDepositedTime,
        uint256[2] memory userLockEndTime,
        uint256 _totalPendingTokens,
        uint256 _balance
    ) public view returns (uint256) {
        if (
            withdrawFee[_slot] == 0 &&
            earlyWithdrawExtraFee[_slot] == 0 &&
            withdrawFeeContract == 0
        ) {
            return 0;
        }

        // Calculate and take withdraw fee
        bool takeWithdrawFees = false;
        if (timedWithdrawFeeOnly == true) {
            //Withdraw fee only for withdraw within withdrawFeePeriod (72hrs)
            if (
                !freeEntryExitFeeUsers[_user] &&
                (block.timestamp < userLastDepositedTime[_slot] + withdrawFeePeriod)
            ) {
                takeWithdrawFees = true;
            }
        } else if (!freeEntryExitFeeUsers[_user]) {
            //withdraw fee on everyone
            takeWithdrawFees = true;
        }

        uint256 pool;
        if (_fullAmountAndPending) {
            pool = _balance + _totalPendingTokens; //include pending cake for UI
        } else {
            pool = _balance;
        }

        uint256 currentWithdrawFee;
        if (takeWithdrawFees == true) {
            uint256 feeRate = withdrawFee[_slot];
            if (_isContract(_user)) {
                //switch fee for contracts
                feeRate = withdrawFeeContract;
            }
            currentWithdrawFee = (_amount * feeRate) / 10000;

            //Early withdraw fee staking todo exclude early withdraw from fullAmountAndPending true (as that is used for UI)
            if (
                earlyWithdrawExtraFee[_slot] != 0 &&
                userLockEndTime[_slot] < block.timestamp
            ) {
                currentWithdrawFee += (_amount * earlyWithdrawExtraFee[_slot]) / 10000;
            }
        }

        return currentWithdrawFee;
    }

    /**
     * @notice Calculate overdue fee.
     * @param _user: User address
     * @return Returns Overdue fee.
     * @param _slot: 0 = staking,1 = bonding
     * @param _fullAmountAndPending: find fee on full amount + pending rewards?
     */
    function calculateOverdueFee(
        address _user,
        uint256 _slot,
        bool _fullAmountAndPending,
        IFeeDistributorV6.UserInfo memory user,
        uint256 _totalPendingTokens,
        uint256 _balance,
        uint256 _totalShares,
        uint256 _precisionFactor
    ) public view returns (uint256) {
        //Charge a overdue fee after the free duration has expired. This encourages people to re lock their tokens. This is why: "after burning" https://docs.pancakeswap.finance/products/syrup-pool/new-cake-pool/cake-syrup-pool-faq

        if (overdueFee == 0) {
            return 0;
        }

        // Set user info based on bonding or staking
        if (
            user.shares[_slot] > 0 &&
            user.locked[_slot] &&
            !freeOverdueFeeUsers[_user] &&
            ((user.lockEndTime[_slot] + UNLOCK_FREE_DURATION) < block.timestamp)
        ) {
            uint256 pool;
            if (_fullAmountAndPending) {
                pool = _balance + _totalPendingTokens;
            } else {
                pool = _balance;
            }
            uint256 currentAmount = (pool * (user.shares[_slot])) /
                _totalShares -
                user.userBoostedShare[_slot]; //calculates user's share of tokens and then removes the boosted shares. imagine a ')' after totalShares
            uint256 earnAmount = currentAmount - user.lockedAmount[_slot]; //Calculate rewards, overduefees are only taken from rewards
            uint256 overdueDuration = block.timestamp -
                user.lockEndTime[_slot] -
                UNLOCK_FREE_DURATION; //calculates how far past the free duration the user is.
            //there is a max over duration amount, if it is past that set it equal to max:
            if (overdueDuration > DURATION_FACTOR_OVERDUE) {
                overdueDuration = DURATION_FACTOR_OVERDUE;
            }
            // Rates are calculated based on the user's overdue duration.
            uint256 overdueWeight = (overdueDuration * overdueFee) /
                DURATION_FACTOR_OVERDUE;
            uint256 currentOverdueFee = (earnAmount * overdueWeight) / _precisionFactor;
            return currentOverdueFee;
        }
        return 0;
    }

    // /**
    //  * @notice Calculate Performance Fee Or Overdue Fee
    //  * @param _user: User address
    //  * @return Returns  Performance Fee Or Overdue Fee.
    //  * @param _slot: 0 = staking,1 = bonding
    //  */
    // function calculatePerformanceOverdueWithdrawFee(address _user, uint256 _slot)
    //     internal
    //     view
    //     returns (uint256)
    // {
    //     return
    //         calculatePerformanceFee(_user, _slot, true) +
    //         calculateOverdueFee(_user, _slot, true) +
    //         calculateWithdrawFee(_user, _slot, 0, true);
    // }

    /**
     * @notice Set performance fee, entry and withdraw fees. Set to 0 for whichever is not used
     * @dev Only callable by the contract admin.
     * @param _slot: 0 = staking,1 = bonding
     */
    function setEntryExitFees(
        uint256 _slot,
        uint256 _entryFee,
        uint256 _entryFeeContract,
        uint256 _performanceFee,
        uint256 _performanceFeeContract,
        uint256 _withdrawFee,
        uint256 _withdrawFeeContract,
        uint256 _earlyWithdrawExtraFee
    ) external onlyOwner {
        //Entry Fees
        entryFee[_slot] = _entryFee;
        entryFeeContract = _entryFeeContract;

        //Performance Fees
        require(
            _performanceFee <= MAX_PERFORMANCE_FEE &&
                _performanceFeeContract <= MAX_PERFORMANCE_FEE,
            'pmax'
        );
        performanceFee[_slot] = _performanceFee;
        performanceFeeContract = _performanceFeeContract;

        //Withdraw Fees
        require(
            _withdrawFee <= MAX_WITHDRAW_FEE && _withdrawFeeContract <= MAX_WITHDRAW_FEE,
            'wmax'
        );
        withdrawFeeContract = _withdrawFeeContract;
        withdrawFee[_slot] = _withdrawFee;

        //Early Withdrawfee
        require(_earlyWithdrawExtraFee <= MAX_EARLY_WITHDRAW_FEE, 'ewmax');
        earlyWithdrawExtraFee[_slot] = _earlyWithdrawExtraFee;

        emit NewEntryExitFees(
            entryFee[_slot],
            entryFeeContract,
            performanceFee[_slot],
            performanceFeeContract,
            withdrawFee[_slot],
            withdrawFeeContract,
            earlyWithdrawExtraFee[_slot],
            _slot
        );
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
        Set Functions
        ===============================*/

    /**
     * @notice Set free performance fee address
     * @dev Only callable by the contract admin.
     * @param _user: User address
     * @param _PerformanceFree: true:free false:not free, same for others
     */
    function setFreeFeeUser(
        address _user,
        bool _PerformanceFree,
        bool _OverdueFree,
        bool _EntryExitFree
    ) external onlyOwner {
        require(_user != address(0), '0addr');
        freePerformanceFeeUsers[_user] = _PerformanceFree;
        freeOverdueFeeUsers[_user] = _OverdueFree;
        freeEntryExitFeeUsers[_user] = _EntryExitFree;
        emit FreeFeeUser(_user, _PerformanceFree, _OverdueFree, _EntryExitFree);
    }

    /**
     * @notice Set overdue fee
     * @dev Only callable by the contract admin. todo merge into above?
     */
    function setOverdueFee(uint256 _overdueFee) external onlyOwner {
        require(_overdueFee <= MAX_OVERDUE_FEE, 'omax');
        overdueFee = _overdueFee;
        emit NewOverdueFee(_overdueFee);
    }

    /**
     * @notice Set fee bools
     */
    function setFeeBools(bool _performanceFeeOnLocked, bool _timeWithdrawFeeOnly)
        external
        onlyOwner
    {
        performanceFeeOnLocked = _performanceFeeOnLocked;
        timedWithdrawFeeOnly = _timeWithdrawFeeOnly;
    }

    /**
     * @notice Set withdraw fee period
     * @dev Only callable by the contract admin. note can be merged into another funciton to save space
     */
    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external onlyOwner {
        withdrawFeePeriod = _withdrawFeePeriod;
        emit NewWithdrawFeePeriod(withdrawFeePeriod);
    }

    /**
     * @notice Set DURATION_FACTOR_OVERDUE
     * @dev Only callable by the contract admin.
     */
    function setOverdueDurations(
        uint256 _durationFactorOverdue,
        uint256 _unlockFreeDuration
    ) external onlyOwner {
        require(_durationFactorOverdue > 0, '!=0');
        DURATION_FACTOR_OVERDUE = _durationFactorOverdue;

        require(_unlockFreeDuration > 0, '!=0');
        UNLOCK_FREE_DURATION = _unlockFreeDuration;
        emit NewDurationFactorOverdue(DURATION_FACTOR_OVERDUE, UNLOCK_FREE_DURATION);
    }

    /*  ===============================
        Get Functions
        ===============================*/

    function getDurations()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (withdrawFeePeriod, UNLOCK_FREE_DURATION, DURATION_FACTOR_OVERDUE);
    }

    function getUserFeeExclusions(address _user)
        external
        view
        returns (
            bool,
            bool,
            bool
        )
    {
        return (
            freePerformanceFeeUsers[_user],
            freeOverdueFeeUsers[_user],
            freeEntryExitFeeUsers[_user]
        );
    }

    // --------------

    function getFreeEntryExtiFeeUsers(address user) external view returns (bool) {
        return freeEntryExitFeeUsers[user];
    }

    function getEntryExitFees(uint256 slot)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (entryFee[slot], withdrawFee[slot], earlyWithdrawExtraFee[slot]);
    }

    function getEntryFee(uint256 slot) external view returns (uint256) {
        return (entryFee[slot]);
    }

    function getEntryFeeContract() external view returns (uint256) {
        return entryFeeContract;
    }

    function getFreePerformanceFeeUsers(address user) external view returns (bool) {
        return freePerformanceFeeUsers[user];
    }

    /**
     * @notice Calculates the rewards for the last 7 days. Used for apy calculations in front end
     */
    function getAPYData()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
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

        return (
            totalRewards7Days,
            allTimeFeeTracker,
            dualTotalRewards7Days,
            allTimeFeeTracker2ndToken
        );
    }

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
        return _amount;
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

    /*  ===============================
        View/Misc Functions - Deposit/Withdraw
        =============================== */

    /**
     * @notice Checks how many more blocks the rewards here will cover for staking token or dual token
     * @param _rewardsPerBlock: Number of tokens to be distributed per block //todo this is so simple does it need a function?
     */
    function runway(uint256 _rewardsPerBlock, bool _dualToken)
        public
        view
        returns (uint256)
    {
        if (_dualToken == false) {
            return IERC20(token).balanceOf(address(this)) / _rewardsPerBlock; //todo make this get automatically from other contract?
        } else {
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

    function setVault(address _vault) external {
        vault = _vault;
    }

    /**
     * @notice checks that address is vault or owner
     */
    modifier onlyOwnerorVault() {
        require(msg.sender == vault || msg.sender == owner(), 'not admin/owner');
        _;
    }

    receive() external payable {}

    fallback() external payable {}
}

contract FeeDistributorFactory is Ownable {
    address public creator;

    constructor(address creator_) {
        creator = creator_;
    }

    function createFeeDistributor(
        address _token,
        address _dualToken,
        bool _dualTokenVault,
        address router,
        address partnerAdmin,
        FeeDistributorV6.FeeInputs memory _feeInputs,
        address teamPayOutToken
    ) external returns (address) {
        require(msg.sender == creator);
        FeeDistributorV6 _feeDistributor = new FeeDistributorV6(
            IERC20(_token),
            IERC20(_dualToken),
            _dualTokenVault,
            router,
            partnerAdmin,
            _feeInputs,
            IERC20(teamPayOutToken)
        );
        _feeDistributor.transferOwnership(msg.sender);
        return address(_feeDistributor);
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

    receive() external payable;
}

pragma solidity >=0.6.2;

//SPDX-License-Identifier: UNLICENSED

interface IUniswapV2Router01 {
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

pragma solidity >=0.6.2;
//SPDX-License-Identifier: UNLICENSED
import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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