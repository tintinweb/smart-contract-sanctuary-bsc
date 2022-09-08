/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

/**
    @notice This contract is responsible for locking and unlocking users MRHB tokens to be used in staking.
            Deriving vMRHB balances for each user over the period of their stake as well as the total vMRHB
            balance of all users, extending the time lock on an existing stake and increasing the MRHB amount
            on an existing stake. As well as producing all the necessary view/getter functions to be used within the contract, FE and BE.
 */

contract Locker is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UnlockData {
        uint128 unlockableAmount;
        uint128 endWeek;
        uint256 startWeek;
    }

    // `weeklyWeightData` tracks the total lock weights for each user.
    // 65535 weeks 2^^16 - 1
    mapping(address => uint128[65535]) public weeklyWeightData;

    // "userUnlockData" shows the ending week of expiry and MRHB amount that can be freed
    mapping(address => UnlockData) public userUnlockData;

    // `weeklyTotalWeight` and `weeklyWeightOf` track the total lock weight for each week,
    // The array index corresponds to the number of the epoch week.
    uint128[65535] public weeklyTotalWeight;

    mapping(uint256 => uint256) public weeklyCoefficients;

    uint256 public immutable startTime;

    // Set the true when migrating to new locker contract
    // default to false, can be set by owner when migrating
    bool public migration;

    IERC20 public immutable MRHB_TOKEN;
    uint256 public immutable MAX_LOCK_WEEKS;
    uint256 constant WEEK = 86400 * 7;
    uint256 constant DAY = 86400;
    uint256 constant DENOMINATOR = 10_000;

    event NewLock(address indexed user, uint256 amount, uint256 lockWeeks);
    event ExtendLock(address indexed user, uint256 amount, uint256 weeksToExpiry);
    event IncreaseAmount(address indexed user, uint256 amount, uint256 weeksToExpiry);
    event Withdrawal(address indexed user, uint256 amount);
    event Sweeped(address indexed caller, address indexed token, uint256 amount);
    event MigrationActive(uint256 blockTime, bool migrationStatus);
    event MigrateWithdrawal(address indexed user, uint256 amount, uint256 weeksToExpiry);

    constructor(
        IERC20 _mrhbToken,
        uint256 _startTime,
        uint256 _maxLockWeeks
    ) {
        MAX_LOCK_WEEKS = _maxLockWeeks;

        MRHB_TOKEN = _mrhbToken;
        startTime = _startTime;

        weeklyCoefficients[13] = 1000;
        weeklyCoefficients[26] = 2100;
        weeklyCoefficients[52] = 4500;
        weeklyCoefficients[104] = 10_000;
    }

    /**
        @notice Gets the current epoch week
     */
    function getWeek() public view returns (uint256) {
        return (block.timestamp - startTime) / WEEK;
    }

    /**
        @notice Gets the epoch time passed from deployment of the contract
        @dev This function used to determine the users lock start week.
     */
    function getCurrentTime() public view returns (uint256) {
        return block.timestamp - startTime;
    }

    /**
        @notice Get the current lock weight for a user
     */
    function userWeight(address _user) public view returns (uint256) {
        return weeklyWeightOf(_user, getWeek());
    }

    /**
        @notice Get the lock weight for a user in a given week
     */
    function weeklyWeightOf(address _user, uint256 _week)
        public
        view
        returns (uint256)
    {
        return weeklyWeightData[_user][_week];
    }

    /**
        @notice Get the token balance and deadline week for an user
     */
    function unlockingInfo(address _user)
        public
        view
        returns (uint256 withdrawableAmount, uint256 deadlineWeek)
    {
        return (
            userUnlockData[_user].unlockableAmount,
            userUnlockData[_user].endWeek
        );
    }

    /**
        @notice Get the current total lock weight
     */
    function totalWeight() external view returns (uint256) {
        return weeklyTotalWeight[getWeek()];
    }

    /**
        @notice Get the user lock weight and total lock weight for the given week
     */
    function weeklyWeight(address _user, uint256 _week)
        external
        view
        returns (uint256, uint256)
    {
        return (weeklyWeightOf(_user, _week), weeklyTotalWeight[_week]);
    }

    /**
        @notice Gets the locked MRHB amount and weeks to expiry.
        @dev This function is meant to be only called whenever a user triggers
             'lock' or 'extendLock' functions. Subraph will listen these events
             and store the tier in the backend right after the event emitted.
        @param _user Address to get tier for
     */
    function getParamsForTier(address _user) external view returns (uint256, uint256) {
      UnlockData memory data = userUnlockData[_user];
      if (data.unlockableAmount > 0 && data.endWeek >= getWeek()) {
        return (data.unlockableAmount, data.endWeek - data.startWeek);
      }
      return (0,0);
    }

    /**
        @notice Gets the locked MRHB amount and weeks to expiry.
        @dev This function is meant to be only called whenever a user triggers
             'increaseAmount' function. Subraph will listen these events
             and store the tier in the backend right after the event emitted.
        @param _user Address to get tier for
     */
    function getTierIncrease(address _user) external view returns (uint256, uint256) {
      UnlockData memory data = userUnlockData[_user];
      if (data.unlockableAmount > 0 && data.endWeek >= getWeek()) {
        return (data.unlockableAmount, data.endWeek - getWeek() );
      }
      return (0,0);
    }

    /**
        @notice Sets the migration status.
        @dev This function is meant to be only called when MARHABA
              migrates to new locker contract. Setting this true
              means that users can withdraw their staked MRHB without
              waiting for their lock to expire by calling 'migrateWithdraw'.
        @param _migration Status of the migration to update.
     */
    function setMigration(bool _migration) external onlyOwner {
      migration = _migration;

      emit MigrationActive(block.timestamp, _migration);
    }

    /**
        @notice Deposit tokens into the contract to create a new lock.
        @param _user Address to make a lock for.
        @param _amount Amount of tokens to lock. This balance transfered from the caller.
        @param _weeks The number of weeks for the lock.
     */
    function lock(
        address _user,
        uint256 _amount,
        uint256 _weeks
    ) external nonReentrant {
        require(userUnlockData[_user].unlockableAmount == 0, "increase or extend");
        require(_amount > 0, "Amount must be nonzero");

        uint256 coefficient = weeklyCoefficients[_weeks];
        require(coefficient != 0, 'Wrong week number');

        uint256 currentWeek = getWeek();
        uint256 start;
        // week 0 no rewards so push user to week 1
        if (currentWeek == 0) {
            start = 1;
        // if user joined at the 1 day threshold for a week push him to current week
        } else if (getCurrentTime() - (currentWeek * WEEK) <= DAY) {
            start = currentWeek;
        } else start = currentWeek + 1;

        uint256 end = start + _weeks;
        _loop(_user, start, end, _amount, coefficient);

        userUnlockData[_user] = UnlockData(
            uint128(_amount),
            uint128(end),
            start
        );

        MRHB_TOKEN.safeTransferFrom(msg.sender, address(this), _amount);

        emit NewLock(_user, _amount, _weeks);
    }

    /**
        @notice Extend the length of an existing lock.
        @param _newWeeks The number of weeks to extend the lock.
     */
    function extendLock(uint256 _newWeeks) external nonReentrant {
        UnlockData storage unlockData = userUnlockData[msg.sender];
        require(unlockData.unlockableAmount > 0, "no lock to extend");

        uint256 start = getWeek();
        require(unlockData.endWeek > start, "lock is expired pls withdraw");

        uint256 coefficient = weeklyCoefficients[_newWeeks];
        require(coefficient != 0, 'Wrong week number');

        uint256 weeksLeftPrevious = unlockData.endWeek - start;
        require(_newWeeks + weeksLeftPrevious <= MAX_LOCK_WEEKS, "Exceeds MAX_LOCK_WEEKS"); // 2 years max

        uint256 end = userUnlockData[msg.sender].endWeek + _newWeeks;

        // The formula used for 'extendLock' in the documentation has been rearranged/altered here in order to
        // create some level of standardisation in the 'loop' function such that it can be used by all the
        // interacting functions. The 'loop' still derives the correct vMRHB balances that are consistent with the formulas.
        uint256 new_amount = (unlockData.unlockableAmount + (userWeight(msg.sender) * DENOMINATOR) / coefficient);
        _loop(msg.sender, start, end, new_amount, coefficient);

        unlockData.endWeek = uint128(end); // new endWeek
        unlockData.startWeek = start; // new startWeek updated for calculating tier in backend

        emit ExtendLock(msg.sender, unlockData.unlockableAmount, end - start);
    }

    /**
        @dev Increase the amount within a lock weight array over an existed lock period
     */
    function increaseAmount(uint256 _amount) external nonReentrant {
        UnlockData storage unlockData = userUnlockData[msg.sender];
        require(unlockData.unlockableAmount > 0, "no lock to increase");

        uint256 currentWeek = getWeek();
        uint256 endWeek = unlockData.endWeek;
        require(endWeek > currentWeek, "lock is expired pls withdraw");

        uint256 new_coef = (userWeight(msg.sender) * DENOMINATOR) / unlockData.unlockableAmount;

        // The formula used for 'increaseAmount' in the documentation has been rearranged/altered here in order to
        // create some level of standardisation in the 'loop' function such that it can be used by all the
        // interacting functions. The 'loop' still derives the correct vMRHB balances that are consistent with the formulas.
        uint256 new_amount = (unlockData.unlockableAmount + _amount);
        _loop(msg.sender, currentWeek, endWeek, new_amount, new_coef);

        unlockData.unlockableAmount += uint128(_amount);
        MRHB_TOKEN.safeTransferFrom(msg.sender, address(this), _amount);

        emit IncreaseAmount(msg.sender, unlockData.unlockableAmount, endWeek - currentWeek);
    }

    function _loop(address user, uint256 start, uint256 end, uint256 amount, uint256 coefficient) internal {
      uint128[65535] storage data = weeklyWeightData[user];

      for (uint256 i = start; i < end; i = unsafe_inc(i)) {
          uint256 ve_amount = (amount * (end - i) * coefficient) /
              (DENOMINATOR * (end - start));
          weeklyTotalWeight[i] += uint128(ve_amount - data[i]); // this will never underflow we can do this unchecked aswell but it's safer to keep it is.
          data[i] = uint128(ve_amount);
      }
    }

    function unsafe_inc(uint256 x) private pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    /**
        @notice Withdraws the locked MRHB from the contract
        @dev This function only go through if the '_user' lock ended.
        @param _user Address to withdraw MRHB amount locked
        @return Returns the MRHB amount withdrawn
     */
    function withdraw(address _user) external returns (uint256) {
        (uint256 withdrawableAmount, uint256 deadlineWeek) = unlockingInfo(
            _user
        );
        require(withdrawableAmount > 0, "no active lock existing");
        require(getWeek() >= deadlineWeek, "lock is not expired yet");

        userUnlockData[_user] = UnlockData(0, 0, 0);

        MRHB_TOKEN.safeTransfer(_user, withdrawableAmount);

        emit Withdrawal(_user, withdrawableAmount);
        return withdrawableAmount;
    }

    /**
        @notice Withdraws the locked MRHB from the contract
        @dev This function only go through if the 'migration' bool is true.
        @param _user Address to withdraw MRHB amount locked
        @return Returns the MRHB amount withdrawn
     */
    function migrationWithdraw(address _user) external returns (uint256) {
        require(migration, 'Migration is not active');

        (uint256 withdrawableAmount, ) = unlockingInfo(
            _user
        );
        // this can overflow in such cases but it is ok, if it overflows
        // then it basically means that the users lock is already finished
        // which user can withdraw funds by 'withdraw'.
        uint256 weeksToExpiry = userUnlockData[_user].endWeek - getWeek();

        userUnlockData[_user] = UnlockData(0, 0, 0);
        MRHB_TOKEN.safeTransfer(_user, withdrawableAmount);

        emit MigrateWithdrawal(_user, withdrawableAmount, weeksToExpiry);
        return withdrawableAmount;
    }

    /**
        @notice Sweeps any non-wanted from the contract and sends it to 'owner()'
        @dev 'owner()' can sweep any token except 'MRHB_TOKEN', any token except
              MRHB is not expected in this contract.
        @param _token ERC20 token to sweep from the contract
     */
     function sweepToken(IERC20 _token) external onlyOwner {
       require(_token != MRHB_TOKEN, 'Can not sweep MRHB');
       uint256 sweepable = IERC20(_token).balanceOf(address(this));
       IERC20(_token).safeTransfer(msg.sender, sweepable);

       emit Sweeped(msg.sender, address(_token), sweepable);
     }
}