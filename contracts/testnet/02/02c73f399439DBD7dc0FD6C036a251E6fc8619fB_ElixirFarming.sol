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

///SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IElixirDefi.sol";

/**
 * @title Elixir Farming
 * @author Satoshis.games
 * @notice This contract manages the farming of the pair
 * $ELIXIR-BUSD from PancakeSwap
 */
contract ElixirFarming is IElixirDefi, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // token to stake: Cake-LP pair
    address public LPAddress;
    // farming reward: $ELIXIR token address
    address public elixirAddress;

    /// sum of staked LP tokens added through staking
    uint256 public stakedTotal;
    /// remaining amount of LP tokens after withdraws
    uint256 public stakedBalance;

    /// original amount of rewards added to the contract
    uint256 public rewardTotal;
    /// remaining amount of rewards after withdraws
    uint256 public rewardBalance;

    uint256 public startingBlock;
    uint256 public endingBlock;
    uint256 public period;

    // accumulated rewards per share (Elixir per LP)
    // accShare += (rewards * 1e6) / stakedBalance;
    uint256 public accShare;

    /// Block number of the last calculation of rewards and shares
    uint256 public lastRewardBlock;
    uint256 public totalParticipants;
    // Number of hours for which funds cannot be withdrawn
    uint256 public lockDuration;
    // Binance Smart Chain has a block time of around 3 seconds.
    uint256 public constant blocksPerHour = 1200;

    /**
     *  @notice Struct to store user staking data.
     *  @dev
     */
    struct Deposits {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 initialStake; // block number
        uint256 latestClaim; // block number
        uint256 userAccShare; // accShare at the deposit moment, used to calculate rewDebt
        uint256 currentPeriod;
    }

    /**
     *  @notice Struct to store period and rewards data.
     *  @dev
     */
    struct periodDetails {
        uint256 period;
        uint256 accShare;
        uint256 rewPerBlock;
        uint256 startingBlock;
        uint256 endingBlock;
        uint256 rewards;
    }

    mapping(address => Deposits) private deposits;
    mapping(address => bool) public isPaid;
    mapping(address => bool) public hasStaked;
    mapping(uint256 => periodDetails) public endAccShare;

    /**
     *
     * In this contract there is no fixed rewards per block, but it
     * is calculated in the rewPerBlock() function and is equal to the
     * total rewards deposited divided by the duration of the period
     * rewardperBlock = rewardTotal / (endingBlock - startingBlock);
     *
     * Basically, any point in time, the amount of ELIXIRs
     * entitled to a user but is pending to be distributed is:
     *
     *   pending reward = (user.amount * pool.accElixirPerShare) - user.rewardDebt
     *
     *   code:
     *   uint256 rewDebt = (deposits[from].amount * deposits[from].userAccShare) / 1e6;
     *   uint256 rew = ((deposits[from].amount * accShare) / 1e6) - rewDebt;
     *
     * Whenever a user _stake or withdraws LP tokens to a pool. Here's what happens:
     *
     *  If it is a new staking
     *      The pool's accumulated ELIXIR per share accShare (and lastRewardBlock) gets updated.
     *  If the user was already staking:
     *      If the user is staking in the current period
     *          call _claimRewards
     *          User receives the pending reward sent to his address.
     *      If the user was staking in a different (previous) period than the current one
     *          call _renew: deposit is renewed
     *      If the user has pending rewards from the previous period
     *          call claimOldRewards
     *          search for data in the history of periods: endAccShare
     *          User receives the pending reward sent to his address
     *          reset the deposits[from] data for the current period, but not the amount, just renew
     *  EndIF
     *  User's amount gets updated.
     *  pools's stakedBalance and stakedTotal gets updated.
     *  User's accShare gets updated.
     *
     */

    // EVENTS
    event NewPeriodSet(
        uint256 period,
        uint256 startBlock,
        uint256 endBlock,
        uint256 lockDuration,
        uint256 rewardAmount
    );
    event PeriodExtended(uint256 period, uint256 endBlock, uint256 rewards);
    event StakingStopped(bool status, uint256 time);
    event Staked(
        address indexed token,
        address indexed staker_,
        uint256 stakedAmount_
    );
    event PaidOut(
        address indexed token,
        address indexed rewardToken,
        address indexed staker_,
        uint256 amount_,
        uint256 reward_
    );

    // MODIFIERS

    /**
     * @notice Make sure the allower has provided the right allowance.
     * @param _allower: sender address
     * @param _amount: amount to transfer
     * @param _token token
     */
    modifier _hasAllowance(
        address _allower,
        uint256 _amount,
        address _token
    ) {
        require(
            _token == LPAddress || _token == elixirAddress,
            "Invalid token address"
        );
        uint256 ourAllowance = IERC20(_token).allowance(
            _allower,
            address(this)
        );
        require(_amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

    // INITIALIZATION

    /**
     * @notice New farming pool
     * @param _LPAddress token to stake: Cake-LP pair
     * @param _ElixirAddress farming reward: $ELIXIR token address
     */
    constructor(address _LPAddress, address _ElixirAddress) Ownable() {
        require(_LPAddress != address(0), "Zero token address");
        LPAddress = _LPAddress;
        require(_ElixirAddress != address(0), "Zero reward token address");
        elixirAddress = _ElixirAddress;
        // contract is paused until rewards are added and dates start and end setted
        if (!paused()) {
            _pause();
        }
    }

    /**
     *  @notice Resets the contract at the end of each period.
     *  @param _rewardAmount rewards to be added to the staking contract
     *  @param _start new period start block
     *  @param _end new period end block
     *  @param _lockDuration number of hours for which funds cannot be withdrawn
     *  @return bool reset success
     */
    function createFarm(
        uint256 _rewardAmount,
        uint256 _start,
        uint256 _end,
        uint256 _lockDuration
    ) external nonReentrant onlyOwner returns (bool) {
        require(
            _start > currentBlock(),
            "Start should be more than current block"
        );
        require(_end > _start, "End block should be greater than start");
        require(_rewardAmount > 0, "Reward must be positive");
        _reset();
        bool rewardAdded = _addReward(_rewardAmount);
        require(rewardAdded, "Rewards error");
        _setStartEnd(_start, _end);
        lockDuration = _lockDuration;
        totalParticipants = 0;
        emit NewPeriodSet(period, _start, _end, _lockDuration, _rewardAmount);
        return true;
    }

    /**
     *  @notice To set the start and end blocks for each period
     *  @param _start start block
     *  @param _end end block
     *  @dev private function called by resetAndsetStartEndBlock() function
     *  after this the contract is active: unPause
     */
    function _setStartEnd(uint256 _start, uint256 _end) private {
        require(rewardTotal > 0, "Add rewards for this period");
        startingBlock = _start;
        endingBlock = _end;
        period++;
        lastRewardBlock = _start;
        if (paused()) {
            _unpause();
        }
    }

    /**
     *  @notice Add rewards to the staking contract
     *  @param _rewardAmount rewards to be added to the staking contract
     *  @return bool rewards added succes
     *  @dev private function called by resetAndsetStartEndBlock() function
     */
    function _addReward(uint256 _rewardAmount)
        private
        _hasAllowance(msg.sender, _rewardAmount, elixirAddress)
        returns (bool)
    {
        rewardTotal += _rewardAmount;
        rewardBalance += _rewardAmount;
        if (!_payMe(msg.sender, _rewardAmount, elixirAddress)) {
            return false;
        }
        return true;
    }

    /**
     *  @notice Resets the contract at the end of each period.
     *  @dev private function called by resetAndsetStartEndBlock() function
     */
    function _reset() private {
        require(block.number > endingBlock, "Wait till end of this period");
        _updateShare();
        endAccShare[period] = periodDetails(
            period,
            accShare,
            rewardsPerBlock(),
            startingBlock,
            endingBlock,
            rewardBalance
        );
        rewardTotal = 0;
        stakedBalance = 0;
        if (!paused()) {
            _pause();
        }
    }

    /**
     * @notice Updates rewards, acc shares and the last reward block
     * @dev this function is called by several functions that can be
     * nested, so it checks blocknumber to avoid calling updateShare
     * more than once in the same block.
     */
    function _updateShare() private {
        if (block.number <= lastRewardBlock) {
            return;
        }
        if (stakedBalance == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 noOfBlocks;

        if (block.number >= endingBlock) {
            noOfBlocks = endingBlock - lastRewardBlock;
        } else {
            noOfBlocks = block.number - lastRewardBlock;
        }

        uint256 rewards = noOfBlocks * rewardsPerBlock();

        accShare += (rewards * 1e6) / stakedBalance;
        if (block.number >= endingBlock) {
            lastRewardBlock = endingBlock;
        } else {
            lastRewardBlock = block.number;
        }
    }

    // GETTERS FUNCTIONS

    /**
     * @notice Returns the amount of rewards per block
     * @return uint256 rewards per block amount
     * @dev In this contract there is no fixed rewards per block,
     * but it is calculated in the rewPerBlock() function and is
     * equal to the total rewards deposited divided by the duration
     * of the period
     */
    function rewardsPerBlock() public view returns (uint256) {
        if (rewardTotal == 0 || rewardBalance == 0) return 0;
        uint256 rewardperBlock = rewardTotal / (endingBlock - startingBlock);
        return (rewardperBlock);
    }

    /**
     *  @notice Returns user staking data
     *  @param _user User wallet address
     *  @return uint256 user staking amount
     *  @return uint256 user staking initialStake
     *  @return uint256 user staking latestClaim
     *  @return uint256 user staking currentPeriod
     */
    function getUserDeposits(address _user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (hasStaked[_user]) {
            return (
                deposits[_user].amount,
                deposits[_user].initialStake,
                deposits[_user].latestClaim,
                deposits[_user].currentPeriod
            );
        } else {
            return (0, 0, 0, 0);
        }
    }

    /**
     *  @notice Returns user shares percentaje
     *  @param _user User address
     *  @return uint256 shares precentaje
     *  @dev returns percentage upto 2 decimals
     */
    function getUserShare(address _user) public view returns (uint256) {
        if (
            hasStaked[_user] == false ||
            stakedBalance == 0 ||
            deposits[_user].amount == 0 ||
            deposits[_user].currentPeriod != period
        ) {
            // user is not staking
            // no stakes available
            // no active valid period
            return 0;
        }
        uint256 userAmount = deposits[_user].amount;
        //returns percentage upto 2 decimals
        return (userAmount * 10000) / stakedBalance;
    }

    /**
     * @notice checks if the user has pending rewards from the previous period
     *  @param _from user address
     *  @return uint256 rewards amount
     */
    function viewOldRewards(address _from)
        public
        view
        whenNotPaused
        returns (uint256)
    {
        if (
            hasStaked[_from] == false || deposits[_from].currentPeriod == period
        ) {
            // No stakings found
            // not current period
            return 0;
        }

        uint256 userPeriod = deposits[_from].currentPeriod;
        uint256 accShare1 = endAccShare[userPeriod].accShare;
        uint256 userAccShare = deposits[_from].userAccShare;

        if (
            deposits[_from].latestClaim >= endAccShare[userPeriod].endingBlock
        ) {
            return 0;
        }

        uint256 amount = deposits[_from].amount;
        uint256 rewDebt = (amount * userAccShare) / 1e6;
        uint256 oldReward = ((amount * accShare1) / 1e6) - rewDebt;

        return (oldReward);
    }

    /**
     *  @notice Returns the user's staking amount
     *  @param _user User address
     *  @return uint256 User staked amount
     */
    function getUserBalance(address _user)
        external
        view
        override
        returns (uint256)
    {
        return (deposits[_user].amount);
    }

    /**
     * @notice Returns the amount pending rewards to user
     * @param _from user address
     * @return uint256 pending rewards amount
     * @dev this is a view function, so it doesn't modified state variables
     */
    function pendingRewards(address _from)
        external
        view
        override
        returns (uint256)
    {
        if (getUserShare(_from) == 0) return 0;
        return (_calculate(_from));
    }

    /**
     * @notice Returns current block number
     * @return uint256 current block number
     */
    function currentBlock() public view returns (uint256) {
        return (block.number);
    }

    // STAKE AND WITHDRAW

    /**
     *  @notice Stake LP tokens
     *  @param _amount amount value of tokens
     *  @return bool staking succes
     *  @dev once the user has given allowance to the farming contract
     */
    function deposit(uint256 _amount)
        external
        override
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(
            block.number >= startingBlock && block.number < endingBlock,
            "Invalid period"
        );
        require(_amount > 0, "Can't stake 0 amount");
        return (_stake(msg.sender, _amount));
    }

    /**
     *  @notice Stake LP tokens
     *  @return bool staking succes
     *  @dev once the user has given allowance to the farming contract
     */
    function depositAll()
        external
        override
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(
            block.number >= startingBlock && block.number < endingBlock,
            "Invalid period"
        );
        uint256 _amount = IERC20(LPAddress).balanceOf(msg.sender);
        require(_amount > 0, "Can't stake 0 amount");
        return (_stake(msg.sender, _amount));
    }

    /**
     *  @notice Private staking function
     *  @param _from user address
     *  @param _amount amount value of tokens
     *  @return bool staking succes
     *  @dev this is where the staking actually takes place
     */
    function _stake(address _from, uint256 _amount)
        private
        _hasAllowance(msg.sender, _amount, LPAddress)
        returns (bool)
    {
        _updateShare();
        // check if is new staking user
        if (!hasStaked[_from]) {
            deposits[_from] = Deposits(
                _amount, // amount
                block.number, // initialStake
                block.number, // latestClaim
                accShare, // userAccShare
                period // currentPeriod
            );
            totalParticipants++;
            hasStaked[_from] = true;
        } else {
            // update existing stacking info
            if (deposits[_from].currentPeriod != period) {
                bool renew_ = _renew(_from);
                require(renew_, "Error renewing");
            } else {
                bool claim_ = _claimRewards(_from);
                require(claim_, "Error paying rewards");
            }

            uint256 userAmount = deposits[_from].amount;

            deposits[_from] = Deposits(
                userAmount + _amount,
                block.number, // initialStake
                block.number, // latestClaim
                accShare, // userAccShare
                period // currentPeriod
            );
        }
        stakedBalance += _amount;
        stakedTotal += _amount;
        if (!_payMe(_from, _amount, LPAddress)) {
            return false;
        }
        emit Staked(LPAddress, _from, _amount);
        return true;
    }

    /**
     * @notice Send pending rewards to user
     * @return bool claim succes
     * @dev if the user is staking in the current period
     * User receives the pending reward sent to his address.
     */
    function claim() external override whenNotPaused returns (bool) {
        require(getUserShare(msg.sender) > 0, "No stakes found for user");
        return (_claimRewards(msg.sender));
    }

    /**
     * @notice Send pending rewards to user
     * @param _from user address
     * @return bool claim succes
     * @dev if the user is staking in the current period
     * User receives the pending reward sent to his address.
     */
    function _claimRewards(address _from) private returns (bool) {
        uint256 userAccShare = deposits[_from].userAccShare;
        _updateShare();
        uint256 amount = deposits[_from].amount;
        uint256 rewDebt = (amount * userAccShare) / 1e6;
        uint256 rew = ((amount * accShare) / 1e6) - rewDebt;
        require(rew > 0, "No rewards generated");
        require(rew <= rewardBalance, "Not enough rewards in the contract");
        deposits[_from].userAccShare = accShare;
        deposits[_from].latestClaim = block.number;
        rewardBalance -= rew;
        bool payRewards = _payDirect(_from, rew, elixirAddress);
        require(payRewards, "Rewards transfer failed");
        emit PaidOut(LPAddress, elixirAddress, _from, amount, rew);
        return true;
    }

    /**
     * @notice Renews a deposit
     * @param _from user address
     * @return bool renewal succes
     * @dev if the user was staking in a different (previous)
     * period than the current one
     * If the user has pending rewards from the previous period
     *   call claimOldRewards
     *   search for data in the history of periods: endAccShare
     *   User receives the pending reward sent to his address
     *   Reset the deposits[from] data for the current period, but not the amount, just renew
     */
    function _renew(address _from) private returns (bool) {
        _updateShare();
        if (viewOldRewards(_from) > 0) {
            bool claimed = claimOldRewards();
            require(claimed, "Error paying old rewards");
        }
        deposits[_from].currentPeriod = period;
        deposits[_from].initialStake = block.number;
        deposits[_from].latestClaim = block.number;
        deposits[_from].userAccShare = accShare;
        stakedBalance += deposits[_from].amount;
        totalParticipants++;
        return true;
    }

    /**
     * @notice checks if the user has pending rewards from the previous period
     * User receives the pending rewards sent to his address
     *  @return bool Claim succes
     */
    function claimOldRewards() public whenNotPaused returns (bool) {
        require(hasStaked[msg.sender], "No stakings found, please stake");
        require(
            deposits[msg.sender].currentPeriod != period,
            "Already renewed"
        );

        uint256 userPeriod = deposits[msg.sender].currentPeriod;

        uint256 accShare1 = endAccShare[userPeriod].accShare;
        uint256 userAccShare = deposits[msg.sender].userAccShare;

        require(
            deposits[msg.sender].latestClaim <
                endAccShare[userPeriod].endingBlock,
            "Already claimed old rewards"
        );
        uint256 amount = deposits[msg.sender].amount;
        uint256 rewDebt = (amount * userAccShare) / 1e6;
        uint256 rew = ((amount * accShare1) / 1e6) - rewDebt;

        require(rew <= rewardBalance, "Not enough rewards");
        deposits[msg.sender].latestClaim = endAccShare[userPeriod].endingBlock;
        rewardBalance -= rew;
        bool paidOldRewards = _payDirect(msg.sender, rew, elixirAddress);
        require(paidOldRewards, "Error paying");
        emit PaidOut(LPAddress, elixirAddress, msg.sender, amount, rew);
        return true;
    }

    /**
     * @notice Returns the amount pending rewards to user
     * @param _from user address
     * @return uint256 pending rewards amount
     * @dev this is a view function, so it doesn't modified state variables
     * rewards, acc shares and the last reward block
     */
    function _calculate(address _from) private view returns (uint256) {
        uint256 userAccShare = deposits[_from].userAccShare;
        uint256 currentAccShare = accShare;
        //Simulating updateShare() to calculate rewards
        if (block.number <= lastRewardBlock) {
            return 0;
        }
        if (stakedBalance == 0) {
            return 0;
        }

        uint256 noOfBlocks;

        if (block.number >= endingBlock) {
            noOfBlocks = endingBlock - lastRewardBlock;
        } else {
            noOfBlocks = block.number - lastRewardBlock;
        }

        uint256 rewards = noOfBlocks * rewardsPerBlock();

        uint256 newAccShare = currentAccShare +
            ((rewards * 1e6) / stakedBalance);
        uint256 amount = deposits[_from].amount;
        uint256 rewDebt = (amount * userAccShare) / 1e6;
        uint256 rew = ((amount * newAccShare) / 1e6) - rewDebt;
        return (rew);
    }

    /**
     *  @notice emergency withdraw bypasses the harvesting of rewards,
     *  so only staked tokens are returned
     *  @return bool emergency withdraw succes
     */
    function emergencyWithdraw()
        external
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(getUserShare(msg.sender) > 0, "No stakes found for user");
        require(
            currentBlock() >
                deposits[msg.sender].initialStake +
                    (lockDuration * blocksPerHour),
            "Can't withdraw before lock duration"
        );
        require(!isPaid[msg.sender], "Already Paid");
        return (_withdraw(msg.sender, deposits[msg.sender].amount));
    }

    /**
     * @notice Withdraw user staking plus rewards after the lock period ends.
     * @param _amount amount value of tokens
     * @return bool withdraw succes
     */
    function withdraw(uint256 _amount)
        external
        override
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(getUserShare(msg.sender) > 0, "No stakes found for user");
        require(
            currentBlock() >
                deposits[msg.sender].initialStake +
                    (lockDuration * blocksPerHour),
            "Can't withdraw before lock duration"
        );
        require(_amount <= deposits[msg.sender].amount, "Wrong value");
        if (deposits[msg.sender].currentPeriod == period) {
            if (_calculate(msg.sender) > 0) {
                bool rewardsPaid = _claimRewards(msg.sender);
                require(rewardsPaid, "Error paying rewards");
            }
        }

        if (viewOldRewards(msg.sender) > 0) {
            bool oldRewardsPaid = claimOldRewards();
            require(oldRewardsPaid, "Error paying old rewards");
        }
        return (_withdraw(msg.sender, _amount));
    }

    /**
     * @notice Withdraw all user staking plus rewards after the lock period ends.
     * @return bool withdraw succes
     */
    function withdrawAll()
        external
        override
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(getUserShare(msg.sender) > 0, "No stakes found for user");
        require(
            currentBlock() >
                deposits[msg.sender].initialStake +
                    (lockDuration * blocksPerHour),
            "Can't withdraw before lock duration"
        );
        if (deposits[msg.sender].currentPeriod == period) {
            if (_calculate(msg.sender) > 0) {
                bool rewardsPaid = _claimRewards(msg.sender);
                require(rewardsPaid, "Error paying rewards");
            }
        }
        if (viewOldRewards(msg.sender) > 0) {
            bool oldRewardsPaid = claimOldRewards();
            require(oldRewardsPaid, "Error paying old rewards");
        }
        return (_withdraw(msg.sender, deposits[msg.sender].amount));
    }

    /**
     *  @notice Withdraw user stakings
     *  @param _from user address
     *  @param _amount amount value of tokens
     *  @return bool withdraw succes
     *  @dev this is where the withdraw actually takes place
     */
    function _withdraw(address _from, uint256 _amount) private returns (bool) {
        _updateShare();
        deposits[_from].amount -= _amount;
        if (deposits[_from].currentPeriod == period) {
            stakedBalance -= _amount;
        }
        bool paid = _payDirect(_from, _amount, LPAddress);
        require(paid, "Error during withdraw");
        if (deposits[_from].amount == 0) {
            isPaid[_from] = true;
            hasStaked[_from] = false;
            if (deposits[_from].currentPeriod == period) {
                totalParticipants--;
            }
            delete deposits[_from];
        }
        return true;
    }

    /**
     *  @notice Allows to extend the current period proportionally
     *  to the amount of rewards added
     *  @param _rewardsToBeAdded rewards to be added to the currend period
     *  @return bool period extend succes
     *  @dev The number of blocks the current period is extended by
     *  depends on the number of rewards to be added
     *  and the number of rewards being issued per block
     */
    function extendPeriod(uint256 _rewardsToBeAdded)
        external
        nonReentrant
        onlyOwner
        returns (bool)
    {
        require(
            currentBlock() > startingBlock && currentBlock() < endingBlock,
            "Invalid period"
        );
        require(_rewardsToBeAdded > 0, "Zero rewards");
        bool addedRewards = _payMe(
            msg.sender,
            _rewardsToBeAdded,
            elixirAddress
        );
        require(addedRewards, "Error adding rewards");
        endingBlock += _rewardsToBeAdded / rewardsPerBlock();
        rewardTotal += _rewardsToBeAdded;
        rewardBalance += _rewardsToBeAdded;
        emit PeriodExtended(period, endingBlock, _rewardsToBeAdded);
        return true;
    }

    /**
     *  @notice transfer tokens from user to this contract (private)
     *  @param _payer user address
     *  @param _amount token amount
     *  @param _token token to transfer
     *  @return bool transfer success
     */
    function _payMe(
        address _payer,
        uint256 _amount,
        address _token
    ) private returns (bool) {
        return _payTo(_payer, address(this), _amount, _token);
    }

    /**
     *  @notice Request to transfer amount from the contract to receiver. (private)
     *  @param _allower from address. Allower is the original owner.
     *  @param _receiver to address
     *  @param _amount token amount
     *  @param _token token to transfer
     *  @return bool transfer success
     *  @dev contract does not own the funds, so the allower must have
     *  added allowance to the contract
     */
    function _payTo(
        address _allower,
        address _receiver,
        uint256 _amount,
        address _token
    ) private returns (bool) {
        IERC20(_token).safeTransferFrom(_allower, _receiver, _amount);
        return true;
    }

    /**
     *  @notice transfer tokens to defined account (private)
     *  @param _to receiver address
     *  @param _amount token amount
     *  @param _token token to transfer
     *  @return bool transfer success
     */
    function _payDirect(
        address _to,
        uint256 _amount,
        address _token
    ) private returns (bool) {
        require(
            _token == LPAddress || _token == elixirAddress,
            "Invalid token address"
        );
        IERC20(_token).safeTransfer(_to, _amount);
        return true;
    }

    /**
     * @dev Triggers stopped state.
     * Requirements:
     * - The contract must not be paused.
     */
    function pause() external onlyOwner {
        _pause();
        emit StakingStopped(true, block.timestamp);
    }

    /**
     * @dev Returns to normal state.
     * Requirements:
     * - The contract must be paused.
     */
    function unpause() external onlyOwner {
        _unpause();
        emit StakingStopped(false, block.timestamp);
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