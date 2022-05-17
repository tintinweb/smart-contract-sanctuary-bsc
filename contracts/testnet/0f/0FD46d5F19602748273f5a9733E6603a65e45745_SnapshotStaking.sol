// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "../libraries/DateTimeLib.sol";
import "../interfaces/ISnapshotStaking.sol";
import "../interfaces/IGovernance.sol";

contract SnapshotStaking is ISnapshotStaking, Context {
    using SafeERC20 for IERC20;
    using Address for address;

    struct UserInfo {
        uint256 amount;    // How many LP token the user has provided
        uint256 rewardPending;
        uint256 lastRewardBlock;    // Last block number that Rewards distribution occurs.
        //
        // We do some fancy math here. Basically, any point in time, the amount of LP token
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.apr * multiplier) + user.rewardPending
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //  (Only happened step 1 only if the user were performed withdraws operation)
        //   1. User receives the pending reward sent to his/her address. 
        //   2. User's `amount` gets updated.
        //   3. User's `rewardPending` gets updated.
        //   4. User's `lastRewardBlock` gets updated.
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        IERC20 rewardToken; // Address of reward token.
        uint256 poolSize;   // The capital of LP token in this pool.
        uint256 poolBalance;   // The balance of LP token in this pool.
        uint256 startTime;  // The timestamp when staking has started.
        uint256 endTime;    // The timestamp when staking has ended.
        uint256 snapshotTime;   // The snapshot time when determine VIP Level
        uint256 apr;    // Anual percentage rate of this pool.
    }

    IGovernance public governance;

    uint256 public constant APR_DENOMINATION = 1e4; //  APR = pool.apr / APR_DENOMINATION
    // Info of each pool.
    PoolInfo[] public poolInfo;
     // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    modifier _positive(uint256 amount) {
        require(amount != 0, "Negative amount");
        _;
    }

    modifier onlyManager() {
        require(_msgSender() == governance.manager(), "Caller don't have permission");
        _;
    }

    constructor(
        address _governance,
        address _lpToken,
        address _rewardToken,
        uint256 _poolSize,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _snapshotTime,
        uint256 _apr
    ) {
        require(_startTime < _endTime, "Start time must be less than End time");
        require(_snapshotTime > _startTime, "Snapshot time must be greater than Start time");
        require(_lpToken.isContract(), "LP Token is invalid");
        require(_rewardToken.isContract(), "Reward Token is invalid");
        require(_poolSize > 0, "Pool size must be greater than 0");
        require(_apr >= 0 && _apr <= APR_DENOMINATION, "apr is out of range");

        governance = IGovernance(_governance);

        // staking pool
        poolInfo.push(
            PoolInfo({
                lpToken: IERC20(_lpToken),
                rewardToken: IERC20(_rewardToken),
                poolSize: _poolSize,
                poolBalance: 0,
                startTime: _startTime,
                endTime: _endTime,
                snapshotTime: _snapshotTime,
                apr: _apr
            })
        );
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Update governance can lead to change treasury, verifier and manger
    // Dev need to be carefully when call this function
    function updateGovernance(address newGovernance) external onlyManager {
        require(newGovernance != address(0), "Set ZERO address");
        require(newGovernance != address(governance), "Nothing to be updated");
        governance = IGovernance(newGovernance);
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        address _lpToken,
        address _rewardToken,
        uint256 _poolSize,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _snapshotTime,
        uint256 _apr
    ) external _positive(_poolSize) onlyManager {
        _startTime = block.timestamp >= _startTime ? block.timestamp : _startTime;
        require(_startTime < _endTime, "Start time must be less than End time");
        require(_snapshotTime > _startTime, "Snapshot time must be greater than Start time");
        require(_lpToken.isContract(), "LP Token is invalid");
        require(_rewardToken.isContract(), "Reward Token is invalid");
        require(_apr >= 0 && _apr <= APR_DENOMINATION, "apr is out of range");

        // staking pool
        poolInfo.push(
            PoolInfo({
                lpToken: IERC20(_lpToken),
                rewardToken: IERC20(_rewardToken),
                poolSize: _poolSize,
                poolBalance: 0,
                startTime: _startTime,
                endTime: _endTime,
                snapshotTime: _snapshotTime,
                apr: _apr
            })
        );
    }

    // View function to see pending CAKEs on frontend.
    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 lpSupply = user.amount;
        uint256 reward;

        if (block.timestamp > user.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                user.lastRewardBlock,
                block.timestamp
            );
            reward = lpSupply * multiplier * pool.apr / (APR_DENOMINATION * 365);
        }
        return reward + user.rewardPending;
    }

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function stake(uint256 _pid, uint256 _amount) external _positive(_amount) {
        address sender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.startTime <= block.timestamp, "Pool has not started");
        require(block.timestamp <= pool.endTime, "Pool has ended");
        UserInfo storage user = userInfo[_pid][sender];

        // Total staking balance do not exceed pool size
        uint256 poolBalance = pool.poolBalance;
        uint256 poolSize = pool.poolSize;
        if (poolSize > 0 && _amount > (poolSize - poolBalance)) {
            _amount = poolSize - poolBalance;
        }

        require(_amount > 0, "Staking cap is filled");
        pool.lpToken.safeTransferFrom(sender, governance.treasury(), _amount);
        updateUser(_pid, sender, false);
        user.amount += _amount;
        pool.poolBalance += _amount;

        emit Deposit(sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function unStake(uint256 _pid, uint256 _amount) external _positive(_amount) {
        address sender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.startTime <= block.timestamp, "Pool has not started");
        UserInfo storage user = userInfo[_pid][sender];
        require(user.amount >= _amount, "withdraw: not good");

        updateUser(_pid, sender, true);
        uint256 pending = user.rewardPending;
        if(pending > 0) {
            user.rewardPending = 0;
            pool.rewardToken.safeTransferFrom(governance.treasury(), sender, pending);
        }
        if(_amount > 0) {
            user.amount -= _amount;
            pool.poolBalance -= _amount;
            pool.lpToken.safeTransferFrom(governance.treasury(), sender, _amount);
        }
        emit Withdraw(sender, _pid, _amount);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updateUser(uint256 _pid, address _user, bool isUnStake) public {
        uint256 currentRewardBlock = block.timestamp; 
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        if (currentRewardBlock <= user.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = user.amount;
        if (lpSupply == 0) {
            user.lastRewardBlock = block.timestamp;
            return;
        }

        if(isUnStake) {
            currentRewardBlock -= DateTimeLib.DAY_IN_SECONDS;
        }

        uint256 multiplier = getMultiplier(user.lastRewardBlock, currentRewardBlock);
        uint256 reward = lpSupply * multiplier * pool.apr / (APR_DENOMINATION * 365);
        user.rewardPending += reward;
        user.lastRewardBlock = currentRewardBlock;
    }

     // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        uint256 numDays = (_to - _from) / DateTimeLib.DAY_IN_SECONDS;
        uint256 remainSeconds = (_to - _from) % DateTimeLib.DAY_IN_SECONDS;
        DateTimeLib.DateTime memory dt = DateTimeLib.parseTimestamp(_from);

        uint256 accumulatedSeconds = uint256(dt.hour) * DateTimeLib.HOUR_IN_SECONDS
            + uint256(dt.minute) * DateTimeLib.MINUTE_IN_SECONDS 
            + uint256(dt.second) + remainSeconds;
        if(accumulatedSeconds >= DateTimeLib.DAY_IN_SECONDS) {
            numDays += 1;
        }
        return numDays;
    }

    receive() external payable {
        revert("Can't not use this feature");
    }

    fallback() external payable {
        revert("Can't not use this feature");
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library DateTimeLib {
    /*
     *  Date and Time utilities for ethereum contracts
     *
     *  address: TODO
     */
    struct DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint256 public constant DAY_IN_SECONDS = 86400;
    uint256 public constant YEAR_IN_SECONDS = 31536000;
    uint256 public constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint256 public constant HOUR_IN_SECONDS = 3600;
    uint256 public constant MINUTE_IN_SECONDS = 60;

    uint16 public constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint16 year) public pure returns (uint16) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year)
        public
        pure
        returns (uint8)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }

    function parseTimestamp(uint256 timestamp)
        public
        pure
        returns (DateTime memory dt)
    {
        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint256 secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        // Day
        buf = getDaysInMonth(dt.month, dt.year);
        for (i = 1; i <= buf; i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }

        // Hour
        dt.hour = getHour(timestamp);

        // Minute
        dt.minute = getMinute(timestamp);

        // Second
        dt.second = getSecond(timestamp);

        // Day of week.
        dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint256 timestamp) public pure returns (uint16) {
        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor +=
            YEAR_IN_SECONDS *
            (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint256 timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint256 timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint256 timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint256 timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint256 timestamp) public pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint256 timestamp) public pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day
    ) public pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour
    ) public pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute
    ) public pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute,
        uint8 second
    ) public pure returns (uint256 timestamp) {
        uint8 i;
        uint256 numLeapYears;

        // Year
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
        timestamp += LEAP_YEAR_IN_SECONDS * numLeapYears;
        timestamp += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        // Month
        for (i = 1; i < month; i++) {
            timestamp += DAY_IN_SECONDS * getDaysInMonth(i, year);
        }

        // Day
        timestamp += DAY_IN_SECONDS * (day - 1);

        // Hour
        timestamp += HOUR_IN_SECONDS * (hour);

        // Minute
        timestamp += MINUTE_IN_SECONDS * (minute);

        // Second
        timestamp += second;

        return timestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ISnapshotStaking {
    function poolLength() external view returns (uint256);
    function pendingReward(uint256 _pid, address _user) external view returns (uint256);
    function add(
        address _lpToken, 
        address _rewardToken, 
        uint256 _poolSize, 
        uint256 _startTime, 
        uint256 _endTime, 
        uint256 _snapshotTime, 
        uint256 _apr
    ) external;
    function stake(uint256 _pid, uint256 _amount) external;
    function unStake(uint256 _pid, uint256 _amount) external;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IGovernance {
    function treasury() external view returns (address);
    function verifier() external view returns (address);
    function manager() external view returns (address);
    function acceptedPayments(address token_) external view returns (bool);

    event UpdateTreasury(address indexed oldTreasury, address indexed newTreasury);
    event UpdateVerifier(address indexed oldVerifier, address indexed newVerifier);
    event UpdateManager(address indexed oldManager, address indexed newManager);
    event UpdateAcceptedPayment(address indexed token, bool isRegist);
}