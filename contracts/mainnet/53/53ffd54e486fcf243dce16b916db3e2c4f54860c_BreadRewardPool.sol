/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: openzeppelin/[email protected]/Address

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// Part: openzeppelin/[email protected]/IERC20

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// Part: openzeppelin/[email protected]/ReentrancyGuard

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
contract ReentrancyGuard {
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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

// Part: openzeppelin/[email protected]/SafeMath

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// Part: openzeppelin/[email protected]/SafeERC20

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: BreadRewardPool.sol

// Note that this pool has no minter key of bread (rewards).
// Instead, the governance will call bread distributeReward method and send reward to this pool at the beginning.
contract BreadRewardPool is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Governance
    address public operator;
    address public taxWallet;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 vestedAmount; //How many LP tokens the user has provided and can withdraw w/o incurring an early tax penalty.
        uint256 lastDepositTime; //Last time the user deposited into this pool (limits withdrawals to vested amounts).
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 token; // Address of LP token contract.
        uint256 earlyWithdrawTaxRate; //Tax rate applied if withdrawing before deposit vesting time finishes.
        uint256 vestingDuration; //Time taken for deposit pools to fully vest
        bool isRebatePool; //Flag to determine if this pool should be used for rebates.
    }

    struct PoolTokenInfo {
        uint256 allocPoint; // How many allocation points assigned to this pool. TOAST to distribute.
        uint256 lastRewardTime; // Last time that bread distribution occurs.
        uint256 accBreadPerShare; // Accumulated bread per share, times 1e18. See below.
        bool isStarted; // if lastRewardBlock has passed.
    }

    IERC20 public bread;

    //Mapping to store permitted contract users.
    mapping(address => bool) public permittedUsers;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    // The time when bread mining starts and ends.
    uint256 public poolStartTime;
    uint256 public immutable poolEndTime;
    
    uint256 public constant TOTAL_REWARDS = 29_999 ether;
    uint256 public constant runningTime = 350 days;
    uint256 public immutable breadPerSecond;

    uint256 public baselineTaxRate = 0;

    uint256 public constant MAX_BASELINE_TAX_RATE = 300;
    uint256 public constant MAX_EARLYWITHDRAW_TAX_RATE = 2_000;
    uint256 public constant MAX_DEPOSIT_VESTING_TIME = 14 days;
    uint256 public constant BASIS_POINTS_DENOM = 10_000;

    mapping(address => PoolTokenInfo) public poolTokens;
    mapping(address => bool) public excludedAddresses;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);
    event EarlyWithdrawTaxPaid(address indexed user, uint256 _amount);
    event WithdrawTaxPaid(address indexed user, uint256 _amount);

    constructor(
        address _bread,
        uint256 _poolStartTime
    ) public {
        require(block.timestamp < _poolStartTime, "late");
        if (_bread != address(0)) bread = IERC20(_bread);
        poolStartTime = _poolStartTime;
        poolEndTime = poolStartTime.add(runningTime);

        operator = msg.sender;
        taxWallet = msg.sender;

        breadPerSecond = TOTAL_REWARDS.div(runningTime);
    }

    modifier onlyOperator() {
        require(operator == msg.sender, "BreadRewardPool: caller is not the operator");
        _;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        uint256 _allocPoint,
        IERC20 _token,
        uint256 _lastRewardTime,
        uint256 _earlyWithdrawTaxRate,
        uint256 _vestingDuration,
        bool _isRebatePool
    ) public onlyOperator {
        require(_earlyWithdrawTaxRate < MAX_EARLYWITHDRAW_TAX_RATE, "Error: Withdraw tax rate too high");
        require(_vestingDuration <= MAX_DEPOSIT_VESTING_TIME, "Error: Vesting time too long");
        require(_vestingDuration > 3 hours, "Error: Vesting time too short");

        massUpdatePools();

        if (block.timestamp < poolStartTime) {
            // chef is sleeping
            if (_lastRewardTime == 0) {
                _lastRewardTime = poolStartTime;
            } else {
                if (_lastRewardTime < poolStartTime) {
                    _lastRewardTime = poolStartTime;
                }
            }
        } else {
            // chef is cooking
            if (_lastRewardTime == 0 || _lastRewardTime < block.timestamp) {
                _lastRewardTime = block.timestamp;
            }
        }

        bool _isStarted = (_lastRewardTime <= poolStartTime) || (_lastRewardTime <= block.timestamp);

        poolInfo.push(PoolInfo({
            token : _token,
            earlyWithdrawTaxRate: _earlyWithdrawTaxRate,
            vestingDuration: _vestingDuration,
            isRebatePool: _isRebatePool
        }));

        //Check for exising pool Token.
        PoolTokenInfo storage poolToken = poolTokens[address(_token)];
        if (poolToken.lastRewardTime == 0) {

            //If new token and started the add total point allocation.
            if (_isStarted) {
                totalAllocPoint = totalAllocPoint.sub(poolToken.allocPoint).add(_allocPoint);
            }

            poolToken.allocPoint = _allocPoint;
            poolToken.lastRewardTime = _lastRewardTime;
            poolToken.accBreadPerShare = 0;
            poolToken.isStarted = _isStarted;

            
        //Update pool allocs.
        } else {
            //NB: Purposefully limited the ability to change the start time of pool tokens.
            // & pools have been updated so totalAllocation is correct.
            if (poolToken.isStarted) {
                totalAllocPoint = totalAllocPoint.sub(poolToken.allocPoint).add(_allocPoint);
            }
            poolToken.allocPoint = _allocPoint;
        }
    }

    // Update the given pool's bread allocation point. Can only be called by the owner.
    function set(
        uint256 _pid, 
        uint256 _allocPoint,
        uint256 _earlyWithdrawTaxRate,
        uint256 _vestingDuration
    ) external onlyOperator {
        require(_earlyWithdrawTaxRate < MAX_EARLYWITHDRAW_TAX_RATE, "Error: Withdraw tax rate too high");
        require(_vestingDuration <= MAX_DEPOSIT_VESTING_TIME, "Error: Vesting time too long");
        require(_vestingDuration > 3 hours, "Error: Vesting time too short");
        
        massUpdatePools();
        PoolInfo storage pool = poolInfo[_pid];
        PoolTokenInfo storage poolToken = poolTokens[address(pool.token)];

        if (poolToken.isStarted) {
            totalAllocPoint = totalAllocPoint.sub(poolToken.allocPoint).add(_allocPoint);
        }
        poolToken.allocPoint = _allocPoint;
        pool.earlyWithdrawTaxRate = _earlyWithdrawTaxRate;
        pool.vestingDuration = _vestingDuration;
    }

    // Returns the accumulated shared rewards across all pools for: _from to _to block.
    function getGeneratedReward(uint256 _fromTime, uint256 _toTime) public view returns (uint256) {
        if (_fromTime >= _toTime) return 0;
        if (_toTime >= poolEndTime) {
            if (_fromTime >= poolEndTime) return 0;
            if (_fromTime <= poolStartTime) return poolEndTime.sub(poolStartTime).mul(breadPerSecond);
            return poolEndTime.sub(_fromTime).mul(breadPerSecond);
        } else {
            if (_toTime <= poolStartTime) return 0;
            if (_fromTime <= poolStartTime) return _toTime.sub(poolStartTime).mul(breadPerSecond);
            return _toTime.sub(_fromTime).mul(breadPerSecond);
        }
    }

    function getVestedAmount(uint256 _pid, address _user) public view returns(uint256 vestedAmount) {
        UserInfo memory user = userInfo[_pid][_user];
        //Perform calculations if user has deposited & pool has started.- Otherwise return 0.
        if (user.lastDepositTime == 0) { return vestedAmount; }
        if (block.timestamp <= poolStartTime) { return vestedAmount; }

        //Extract the from time.
        uint256 fromTime = poolStartTime > user.lastDepositTime ? poolStartTime : user.lastDepositTime;

        //Calculate the new vested amount applicable for baseline tax.
        uint256 timeElapsed = block.timestamp.sub(fromTime);
        vestedAmount = user.amount.mul(timeElapsed).div(poolInfo[_pid].vestingDuration).add(user.vestedAmount);
        if (vestedAmount > user.amount) {vestedAmount = user.amount;}
    }

    // View function to see pending Bread on frontend.
    function pendingShare(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        PoolTokenInfo memory poolToken = poolTokens[address(pool.token)];

        uint256 accBreadPerShare = poolToken.accBreadPerShare;
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (block.timestamp > poolToken.lastRewardTime && tokenSupply != 0) {
            uint256 _generatedReward = getGeneratedReward(poolToken.lastRewardTime, block.timestamp);
            uint256 _breadReward = _generatedReward.mul(poolToken.allocPoint).div(totalAllocPoint);
            accBreadPerShare = accBreadPerShare.add(_breadReward.mul(1e18).div(tokenSupply));
        }
        return user.amount.mul(accBreadPerShare).div(1e18).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo memory pool = poolInfo[_pid];
        PoolTokenInfo storage poolToken = poolTokens[address(pool.token)];

        //Early return if no rewards present.
        if (block.timestamp <= poolToken.lastRewardTime) {
            return;
        }

        //If no tokens then update reward time and return early.
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) {
            poolToken.lastRewardTime = block.timestamp;
            return;
        }

        //Start unstarted pool token emissions.
        if (!poolToken.isStarted) {
            poolToken.isStarted = true;
            totalAllocPoint = totalAllocPoint.add(poolToken.allocPoint);
        }

        //If pool tokens has an allocation -> update stats.
        if (totalAllocPoint > 0) {
            uint256 _generatedReward = getGeneratedReward(poolToken.lastRewardTime, block.timestamp);
            uint256 _breadReward = _generatedReward.mul(poolToken.allocPoint).div(totalAllocPoint);

            //Add (rewards/tokensInPool) to the accumulated Bread per Share. Based in ether - hence .div(1e18) later on.
            poolToken.accBreadPerShare = poolToken.accBreadPerShare.add(_breadReward.mul(1e18).div(tokenSupply));
        }
        poolToken.lastRewardTime = block.timestamp;
    }

    function deposit(
        uint256 _pid,
        uint256 _amount
    ) external {
        if (Address.isContract(msg.sender) || tx.origin != msg.sender) {
            require(permittedUsers[msg.sender], "Error: Contract address is not a permitted user");
        }

        _deposit(
            _pid,
            _amount,
            msg.sender,
            msg.sender
        );
    }

    //NB: Required to be a contract so the front end cannot just switch the intended recipient for the reward pool.
    //I.e. the user would see that the front end is attempting to connect to a contract other than the reward pool.
    function depositFor(
        uint256 _pid,
        uint256 _amount,
        address _recipient
    ) external {
        require(Address.isContract(msg.sender) || tx.origin != msg.sender, "Error: User is not a contract");
        require(permittedUsers[msg.sender], "Error: Contract address is not a permitted user");

        _deposit(
            _pid,
            _amount,
            msg.sender,
            _recipient
        );
    }

    // Deposit tokens.
    function _deposit(
        uint256 _pid,
        uint256 _amount,
        address _sender,
        address _recipient
    ) internal nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        PoolTokenInfo storage poolToken = poolTokens[address(pool.token)];
        UserInfo storage user = userInfo[_pid][_recipient];

        updatePool(_pid);

        //Calculate and withdraw pending rewards.
        uint256 _pending = user.amount.mul(poolToken.accBreadPerShare).div(1e18).sub(user.rewardDebt);
        if (_pending > 0) {
            safeBreadTransfer(_recipient, _pending);
            emit RewardPaid(_recipient, _pending);
        }

        //Set the tax free withdrawal amount. (Before user.amount is updated)
        user.vestedAmount = getVestedAmount(_pid, _recipient);
        user.lastDepositTime = block.timestamp;

        //If a deposit is made then actually alter user info.
        if (_amount > 0) {
            //Deposit amount that accounts for transfer tax on taxable tokens.
            uint256 tokenBalanceBefore = pool.token.balanceOf(address(this));
            pool.token.safeTransferFrom(_sender, address(this), _amount);
            _amount = pool.token.balanceOf(address(this)).sub(tokenBalanceBefore);
            
            user.amount = user.amount.add(_amount);
        }

        //Edit reward debt after the user amount has finished updating.
        user.rewardDebt = user.amount.mul(poolToken.accBreadPerShare).div(1e18);
        emit Deposit(_recipient, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        _withdraw(_pid, _amount, msg.sender);
    } 

    function withdrawVestedAmount(uint256 _pid) external {
        _withdraw(_pid, getVestedAmount(_pid, msg.sender), msg.sender);
    }

    // Withdraw staking tokens.
    function _withdraw(uint256 _pid, uint256 _amount, address _sender) internal nonReentrant {
        PoolTokenInfo storage poolToken = poolTokens[address(poolInfo[_pid].token)];
        UserInfo storage user = userInfo[_pid][_sender];

        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);

        //Calculate the pending amount and update reward info accordingly.
        uint256 _pending = user.amount.mul(poolToken.accBreadPerShare).div(1e18).sub(user.rewardDebt);
        if (_pending > 0) {
            safeBreadTransfer(_sender, _pending);
            emit RewardPaid(_sender, _pending);
        }
        
        //Handle withdrawal tax logic.
        _handleWithdrawTaxes(_pid, _amount, _sender);

        emit Withdraw(_sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;

        //Handle withdrawal tax logic.
        _handleWithdrawTaxes(_pid, _amount, msg.sender);

        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    function _handleWithdrawTaxes(
        uint256 _pid, 
        uint256 _amount, 
        address _sender
    ) internal {
        PoolInfo memory pool = poolInfo[_pid];
        PoolTokenInfo memory poolToken = poolTokens[address(pool.token)];
        UserInfo storage user = userInfo[_pid][_sender];

        //Set the vested withdrawal amount. (Before user.amount is updated and lastDepositTime is updated)
        user.vestedAmount = getVestedAmount(_pid, _sender);
        user.lastDepositTime = block.timestamp;
        
        if (_amount > 0) {

            //Limit the pool withdrawal amount if a rebate pool.
            if (pool.isRebatePool && _amount > user.vestedAmount) {
                _amount = user.vestedAmount;
            }

            //Withdraw full _amount from user pool balance.
            user.amount = user.amount.sub(_amount);

            //Apply tax to withdrawals if _sender address is not excluded.
            if (!excludedAddresses[_sender]) {

                uint256 vestedAmountWithdrawn = _amount > user.vestedAmount ? user.vestedAmount : _amount;
                
                //Apply early withdraw tax.
                uint256 taxedAmount;
                if (_amount > user.vestedAmount) {
                    uint256 taxableAmount = _amount.sub(user.vestedAmount);
                    taxedAmount = taxableAmount.mul(pool.earlyWithdrawTaxRate).div(BASIS_POINTS_DENOM);
                    pool.token.safeTransfer(taxWallet, taxedAmount);
                    _amount = _amount.sub(taxedAmount);
                    emit EarlyWithdrawTaxPaid(_sender ,taxedAmount);
                }

                //Deduct tax free amount variable.
                user.vestedAmount = user.vestedAmount.sub(vestedAmountWithdrawn);

                //Apply baseline tax rate.
                taxedAmount = vestedAmountWithdrawn.mul(baselineTaxRate).div(BASIS_POINTS_DENOM);
                pool.token.safeTransfer(taxWallet, taxedAmount);
                _amount = _amount.sub(taxedAmount);
                emit WithdrawTaxPaid(_sender, taxedAmount);
            }

            //Transfer token.
            pool.token.safeTransfer(_sender, _amount);
        }

        //Update the user reward debt.
        user.rewardDebt = user.amount.mul(poolToken.accBreadPerShare).div(1e18);
    }

    // Safe bread transfer function, just in case if rounding error causes pool to not have enough bread.
    function safeBreadTransfer(address _to, uint256 _amount) internal {
        uint256 _breadBal = bread.balanceOf(address(this));
        if (_breadBal > 0) {
            if (_amount > _breadBal) {
                bread.safeTransfer(_to, _breadBal);
            } else {
                bread.safeTransfer(_to, _amount);
            }
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    //Sets permitted users allowed to deposit.
    function setPermittedUser(address _user, bool _isPermitted) external onlyOperator {
        require(Address.isContract(_user), "Error: Address is not a contract.");
        permittedUsers[_user] = _isPermitted;
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 amount,
        address to
    ) external onlyOperator {
        require(block.timestamp > poolEndTime.add(40 days),  "Error: I dont want your tokens.");
        _token.safeTransfer(to, amount);
    }

    function setExcludedAddress(address _account, bool _isExcluded) external onlyOperator {
        excludedAddresses[_account] = _isExcluded;
    }

    function setBaselineTaxRate(uint256 _baselineTaxRate) external onlyOperator {
        require(_baselineTaxRate <= MAX_BASELINE_TAX_RATE, "Error: baseline tax rate too high.");
        baselineTaxRate = _baselineTaxRate;
    }

    function setTaxWallet(address _taxWallet) external onlyOperator {
        taxWallet = _taxWallet;
    }
}