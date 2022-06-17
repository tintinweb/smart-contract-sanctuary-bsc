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
 * @title Elixir Staking
 * @author Satoshis.games
 * @notice This contract manages the staking of $ELIXIR tokens
 * @dev A new contract is deployed for each staking period, this is
 * specified in the contract name property
 */
contract ElixirStaking is IElixirDefi, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// contract name specifying the period
    string public name;
    /// $ELIXIR token address
    address public elixirAddress;
    /// token balances
    uint256 public stakedBalance;
    uint256 public rewardBalance;
    uint256 public stakedTotal;
    uint256 public totalReward;
    /// id of the interest rates mapping
    uint64 public index;
    uint64 public currentRate;
    /// locking period in hours
    uint256 public lockDuration;
    uint256 public totalParticipants;

    uint256 public constant interestRateConverter = 10000;

    // STAKING DATA AND INTEREST RATES

    /**
     *  @notice Struct to store user staking data.
     *  @dev userIndex - the index of the interest rate at the time of user stake.
     */
    struct Deposits {
        uint256 depositAmount;
        uint256 depositTime;
        uint256 endTime;
        uint256 lastHarvestTime;
        uint64 userIndex;
        uint256 rewards;
        bool paid;
    }

    /// Struct to store interest rate change.
    struct Rates {
        uint64 newInterestRate;
        uint256 timeStamp;
        uint256 timeStampEnd;
    }

    /// mapping of users and the information of their deposits
    mapping(address => Deposits) private deposits;

    /// interest rate mapping and its change over time
    mapping(uint64 => Rates) public rates;

    /// user mapping to check if they have already staked
    mapping(address => bool) private hasStaked;

    // EVENTS

    // Emitted when user stakes 'stakedAmount' value of tokens
    event Staked(
        address indexed token,
        address indexed staker,
        uint256 stakedAmount
    );

    // Emitted when user withdraws his stakings
    event PaidOut(
        address indexed token,
        address indexed staker,
        uint256 amount,
        uint256 reward
    );

    // Emitted when user withdraws rewards
    event Harvest(
        address indexed token,
        address indexed staker,
        uint256 reward
    );

    event RateAndLockduration(
        uint64 index,
        uint64 newRate,
        uint256 lockDuration,
        uint256 time
    );

    event RateUpdated(uint64 index, uint64 newRate, uint256 time);
    event RewardsAdded(uint256 rewards, uint256 time);
    event StakingStopped(bool status, uint256 time);

    // MODIFIERS

    /**
     * @notice validates that user is staking
     * @param _from: sender address
     */
    modifier _withdrawCheck(address _from) {
        require(hasStaked[_from], "No stakes found for user");
        require(
            block.timestamp >= deposits[_from].endTime,
            "Requesting before lock time"
        );
        _;
    }

    /**
     * @notice Make sure the allower has provided the right allowance.
     * @param _allower: sender address
     * @param _amount: amount to transfer
     */
    modifier _hasAllowance(address _allower, uint256 _amount) {
        uint256 ourAllowance = IERC20(elixirAddress).allowance(
            _allower,
            address(this)
        );
        require(_amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

    // INITIALIZATION

    /**
     * @notice New staking pool for the indicated period
     * @param _name name of the contract
     * @param _tokenAddress $ELIXIR token address
     * @param _rate rate multiplied by 100
     * @param _lockDuration duration in hours
     */
    constructor(
        string memory _name,
        address _tokenAddress,
        uint64 _rate,
        uint256 _lockDuration
    ) Ownable() {
        name = _name;
        require(_tokenAddress != address(0), "Zero token address");
        elixirAddress = _tokenAddress;
        lockDuration = _lockDuration;
        require(_rate != 0, "Zero interest rate");
        currentRate = _rate;
        rates[index] = Rates(_rate, block.timestamp, 0);
    }

    /**
     * @notice Set a new interest rate for a lock period in hours
     * @param _newRate New effective interest rate multiplied by 100
     */
    function setRate(uint64 _newRate) external onlyOwner {
        require(_newRate != 0, "Zero interest rate");
        currentRate = _newRate;
        uint256 timestamp = block.timestamp;
        rates[index].timeStampEnd = timestamp;
        index++;
        rates[index] = Rates(_newRate, timestamp, 0);
        emit RateUpdated(index, _newRate, timestamp);
    }

    // GETTERS FUNCTIONS

    /**
     *  @notice Returns if user is staking
     *  @param _user User wallet address
     *  @return bool true if user is staking
     */
    function isUserStaking(address _user) external view returns (bool) {
        return hasStaked[_user];
    }

    /**
     *  @notice Returns complete user staking data
     *  @param _user User wallet address
     *  @return uint256 user staking data
     */
    function getUserDeposits(address _user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        if (hasStaked[_user]) {
            return (
                deposits[_user].depositAmount,
                deposits[_user].depositTime,
                deposits[_user].endTime,
                deposits[_user].lastHarvestTime,
                deposits[_user].userIndex,
                deposits[_user].rewards,
                deposits[_user].paid
            );
        } else {
            return (0, 0, 0, 0, 0, 0, false);
        }
    }

    /**
     *  @notice Returns the user's stalking amount
     *  @param _user User address
     *  @return uint256 User staked amount
     */
    function getUserBalance(address _user) external view override returns (uint256) {
        return (deposits[_user].depositAmount);
    }

    /**
     *  @notice Returns the user's rewards earned so far
     *  @param _user User address
     *  @return uint256 User earned rewards
     */
    function pendingRewards(address _user) external view override returns (uint256) {
        return (_calculate(_user));
    }

    // STAKE AND WITHDRAW

    /**
     *  @notice Add rewards to the staking contract
     *  @param _rewardAmount rewards to be added to the staking contract
     *  @dev once the allowance is given to this contract for 'rewardAmount' by the user
     */
    function addReward(uint256 _rewardAmount)
        external
        nonReentrant
        whenNotPaused
        _hasAllowance(msg.sender, _rewardAmount)
        returns (bool)
    {
        require(_rewardAmount > 0, "Reward must be positive");
        totalReward += _rewardAmount;
        rewardBalance += _rewardAmount;
        emit RewardsAdded(_rewardAmount, block.timestamp);
        require(_payMe(msg.sender, _rewardAmount), "Payment failed");
        return true;
    }

    /**
     *  @notice Stake tokens
     *  @param _amount amount value of tokens
     *  @return bool staking succes
     *  @dev once the user has given allowance to the staking contract
     */
    function deposit(uint256 _amount)
        external
        override
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(_amount > 0, "Can't stake 0 amount");
        return (_stake(msg.sender, _amount));
    }

    /**
     *  @notice Stake tokens
     *  @return bool staking succes
     *  @dev once the user has given allowance to the staking contract
     */
    function depositAll()
        external
        override
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        uint256 _amount = IERC20(elixirAddress).balanceOf(msg.sender);
        require(_amount > 0, "Can't stake 0 amount");
        return (_stake(msg.sender, _amount));
    }

    /**
     *  @notice Private staking function
     *  @param _from user address
     *  @param _amount amount value of tokens
     *  @return bool staking succes
     *  @dev this is where the staking actually takes place
     *  @dev userIndex - the index of the interest rate at the time of user stake.
     */
    function _stake(address _from, uint256 _amount)
        private
        _hasAllowance(msg.sender, _amount)
        returns (bool)
    {
        // check if is new staking user
        if (!hasStaked[_from]) {
            hasStaked[_from] = true;

            deposits[_from] = Deposits(
                _amount,
                block.timestamp, // depositTime
                block.timestamp + (lockDuration * 3600), // endTime
                block.timestamp, // lastHarvestTime
                index,
                0, // rewards
                false
            );
            totalParticipants++;
        } else {
            // update existing stacking info
            // updates rewards and reset times
            require(
                block.timestamp < deposits[_from].endTime,
                "Lock expired, please withdraw and stake again"
            );
            uint256 newAmount = deposits[_from].depositAmount + _amount;
            uint256 rewards = _calculate(_from) + deposits[_from].rewards;
            deposits[_from] = Deposits(
                newAmount,
                block.timestamp,
                block.timestamp + (lockDuration * 3600),
                block.timestamp, // lastHarvestTime
                index,
                rewards,
                false
            );
        }
        stakedBalance += _amount;
        stakedTotal += _amount;
        emit Staked(elixirAddress, _from, _amount);
        require(_payMe(_from, _amount), "Payment failed");

        return true;
    }

    /**
     * @notice Withdraw user staking plus rewards after the lock period ends.
     * @return bool withdraw succes
     */
    function withdraw(uint256 _amount)
        external override
        nonReentrant
        whenNotPaused
        _withdrawCheck(msg.sender)
        returns (bool)
    {
        // this implementation always withdraw all
        _amount = 0;
        return (_withdraw(msg.sender));
    }

    /**
     * @notice Withdraw user staking plus rewards after the lock period ends.
     * @return bool withdraw succes
     */
    function withdrawAll()
        external override 
        nonReentrant
        whenNotPaused
        _withdrawCheck(msg.sender)
        returns (bool)
    {
        return (_withdraw(msg.sender));
    }

    /**
     *  @notice Withdraw user stakings + rewards after the lock period ends (private)
     *  @param _from user address
     *  @return bool withdraw succes
     *  @dev this is where the withdraw actually takes place
     */
    function _withdraw(address _from) private returns (bool) {
        // calculate rewards based on user staked amount
        uint256 reward = _calculate(_from);
        reward += deposits[_from].rewards;
        uint256 amount = deposits[_from].depositAmount;
        require(reward <= rewardBalance, "Not enough rewards balance");
        stakedBalance -= amount;
        rewardBalance -= reward;
        deposits[_from].paid = true;
        hasStaked[_from] = false;
        totalParticipants--;
        deposits[_from].lastHarvestTime = block.timestamp;
        emit PaidOut(elixirAddress, _from, amount, reward);
        // transfers amount + reward to user
        require(_payDirect(_from, amount + reward), "Error paying");

        return true;
    }

    /**
     * @notice Withdraw user pending rewards
     * @return bool withdraw succes
     */
    function claim() external override nonReentrant whenNotPaused returns (bool) {
        require(hasStaked[msg.sender], "No stakes found for user");
        return (_harvest(msg.sender));
    }

    /**
     *  @notice withdraw pending rewards (private)
     *  @return bool withdraw succes
     *  @dev this is where the harvest actually takes place
     */
    function _harvest(address _from) private returns (bool) {
        // calculate rewards based on user staked amount
        uint256 reward = _calculate(_from);
        reward += deposits[_from].rewards;
        require(reward <= rewardBalance, "Not enough rewards");
        rewardBalance -= reward;
        deposits[_from].lastHarvestTime = block.timestamp;
        emit Harvest(elixirAddress, _from, reward);
        require(_payDirect(_from, reward), "Error paying");

        return true;
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
        _withdrawCheck(msg.sender)
        returns (bool)
    {
        return (_emergencyWithdraw(msg.sender));
    }

    /**
     *  @notice emergency withdraw bypasses the harvesting of rewards,
     *  so only staked tokens are returned (private)
     *  @param _from user address
     *  @return bool emergency withdraw succes
     *  @dev this is where the emergency withdraw actually takes place
     */
    function _emergencyWithdraw(address _from) private returns (bool) {
        uint256 amount = deposits[_from].depositAmount;
        stakedBalance -= amount;
        deposits[_from].paid = true;
        hasStaked[_from] = false;
        totalParticipants--;
        emit PaidOut(elixirAddress, _from, amount, 0);
        require(_payDirect(_from, amount), "Error paying");

        return true;
    }

    /**
     *  @notice calculate the rewards based on user staked amount
     *  @param _from user address
     *  @return uint256 rewards amount
     *  @dev this is where the calculation of rewards actually takes place
     */
    function _calculate(address _from) private view returns (uint256) {
        // validate if user is staking
        if (!hasStaked[_from]) return 0;

        // Requesting rewards before the expiration date of the stacking period
        // will calculate rewards from last harvest to current time
        uint256 endTime = (block.timestamp >= deposits[_from].endTime)
            ? deposits[_from].endTime
            : block.timestamp;

        // If there wasn't a harvest before then the harvest time
        // will be equal to the deposit time.
        uint256 depositTime = deposits[_from].lastHarvestTime;

        uint256 amount = deposits[_from].depositAmount;
        uint64 userIndex = deposits[_from].userIndex;

        uint256 time;
        uint256 interest;
        uint256 ac_interest;
        uint256 _lockduration = lockDuration * 3600;

        for (uint64 i = userIndex; i < index; i++) {
            //loop runs till the latest index/interest rate change
            if (endTime < rates[i + 1].timeStamp) {
                //if the change occurs after the endTime loop breaks
                break;
            } else {
                time = (depositTime < rates[i + 1].timeStamp)
                    ? rates[i + 1].timeStamp - depositTime
                    : 0;
                interest =
                    (amount * rates[i].newInterestRate * time) /
                    (_lockduration * interestRateConverter);
                // if I add interest to the amount I would be calculating compound interest
                // amount += interest;
                ac_interest += interest; // interest acumulator
                depositTime = rates[i + 1].timeStamp;
                userIndex++;
            }
        }

        //final calculation for the remaining time period
        if (depositTime < endTime) {
            time = endTime - depositTime;
            ac_interest +=
                (time * amount * rates[userIndex].newInterestRate) /
                (_lockduration * interestRateConverter);
        }

        return (ac_interest);
    }

    /**
     *  @notice transfer tokens from user to this contract (private)
     *  @param _payer user address
     *  @param _amount token amount
     *  @return bool transfer success
     */
    function _payMe(address _payer, uint256 _amount) private returns (bool) {
        return _payTo(_payer, address(this), _amount);
    }

    /**
     *  @notice transfer tokens between two accounts (private)
     *  @param _allower from address
     *  @param _receiver to address
     *  @param _amount token amount
     *  @return bool transfer success
     */
    function _payTo(
        address _allower,
        address _receiver,
        uint256 _amount
    ) private _hasAllowance(_allower, _amount) returns (bool) {
        IERC20(elixirAddress).safeTransferFrom(_allower, _receiver, _amount);
        return true;
    }

    /**
     *  @notice transfer tokens to defined account (private)
     *  @param _to receiver address
     *  @param _amount token amount
     *  @return bool transfer success
     */
    function _payDirect(address _to, uint256 _amount) private returns (bool) {
        IERC20(elixirAddress).safeTransfer(_to, _amount);
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