/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        (bool success, ) = recipient.call{value: amount}("");
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    function _TAX_FEE() external view returns (uint256);

    function _BURN_FEE() external view returns (uint256);

    function _CHARITY_FEE() external view returns (uint256);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract ReentrancyGuard {
    bool private guardLocked;

    modifier noReentry() {
        require(!guardLocked, "Prevented by noReentry in ReentrancyGuard");
        guardLocked = true;
        _;
        guardLocked = false;
    }
}

contract LockedStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct TrancheInfo {
        uint32 trancheId;
        Status status;
        bool taxBenefit;
        string trancheName;
        uint256 APY;
        uint256 poolSize;
        uint256 minTokenAllowed;
        uint256 maxTokenAllowed;
        uint256 endDate;
        uint256 remainingPoolSize;
        uint256 rewardTokens;
    }

    struct UserStakeInfo {
        address userAddress;
        uint256 amount;
        uint256 startDate;
    }

    enum Status {
        NEW,
        ACTIVE,
        INACTIVE,
        EXPIRED,
        CLOSED
    }

    address public immutable stakeTokenAddr;
    uint256 private immutable DECIMALFACTOR;
    uint32 private constant SECONDSINDAY = 86400;
    uint16 private constant DAYSINYEAR = 365;
    uint16 private constant GRANULARITY = 1000;

    uint32 public totalTranches;
    uint32 public totalActiveTranches;
    uint256 public totalTokensPoolSize;
    uint256 public totalTokensStaked;
    uint256 public totalTokensRewarded;
    uint256 public totalRewardTokensRequired; // to be reduced when staking is closed
    uint256 public totalRewardTokensBalance; // to be reduced whenever rewards are awarded

    mapping(uint32 => TrancheInfo) public mapTranches; // map(trancheId => TrancheInfo)
    mapping(address => mapping(uint32 => UserStakeInfo)) public mapUserInfo; // map(user => map(trancheId => UserStakeInfo))
    mapping(uint32 => address[]) public mapTranceUsers; // map(trancheId => address[])

    // Constructor
    constructor(address _tokenAddr, uint256 _tokenDecimals) {
        stakeTokenAddr = _tokenAddr;
        DECIMALFACTOR = 10**_tokenDecimals;
        _owner = _msgSender();
    }

    // Modifiers
    modifier validTranche(uint32 _tid) {
        require(_tid > 0 && mapTranches[_tid].trancheId > 0, "Tranche does not exists.");
        _;
    }

    modifier inStatus(uint32 _tid, Status _status) {
        require(mapTranches[_tid].status == _status, "Invalid tranche status.");
        _;
    }

    modifier expiredTranche(uint32 _tid) {
        _;
        if (block.timestamp > mapTranches[_tid].endDate) {
            mapTranches[_tid].status = Status.EXPIRED;
            totalActiveTranches--;
            emit ETrancheStatus(address(0x0), _tid, uint256(Status.EXPIRED));
        }
    }

    // Events
    event ETranche(
        address userAddress,
        uint32 trancheId,
        string trancheName,
        uint256 poolSize,
        uint256 minTokenAllowed,
        uint256 maxTokenAllowed,
        uint256 APY,
        uint256 endDate,
        bool taxBenefit,
        uint256 trancheStatusId
    );

    event ETrancheStatus(address userAddress, uint32 trancheId, uint256 trancheStatusId);

    event EStaking(address userAddress, uint32 trancheId, uint256 amount);

    event EUnStaking(address userAddress, uint32 trancheId, uint256 exitAmount);

    event ECloseTranche(address userAddress, uint32 trancheId);

    event ECloseStaking(address userAddress, uint256 amount);

    // Functions
    function addTranche(
        string memory _name,
        uint256 _poolSize,
        uint256 _minTokenAllowed,
        uint256 _maxTokenAllowed,
        uint256 _endDate,
        uint256 _APY,
        bool _taxBenefit
    ) external onlyOwner {
        require(_poolSize > 0, "Size should be greater than 0.");
        require(
            _minTokenAllowed >= 0 && _minTokenAllowed <= _maxTokenAllowed && _maxTokenAllowed <= _poolSize,
            "Invalid min/max tokenAllowed argument."
        );
        require(
            _endDate > block.timestamp && _endDate < block.timestamp + 180 days, // ???
            "End date should be greater than current time."
        );

        uint256 maxRewards = calculateMaxRewards(_poolSize, _APY, _endDate, _taxBenefit);

        uint256 rewardTokensToTransfer = totalRewardTokensRequired.add(maxRewards).sub(totalRewardTokensBalance);
        if (rewardTokensToTransfer > 0) {
            IBEP20(stakeTokenAddr).safeTransferFrom(
                _msgSender(),
                address(this),
                rewardTokensToTransfer.mul(DECIMALFACTOR)
            );
            totalRewardTokensBalance = totalRewardTokensBalance.add(rewardTokensToTransfer);
        }

        totalRewardTokensRequired = totalRewardTokensRequired.add(maxRewards);

        uint32 tid = ++totalTranches;

        TrancheInfo storage tranche = mapTranches[tid];
        tranche.trancheId = tid;
        tranche.trancheName = _name;
        tranche.APY = _APY;
        tranche.poolSize = _poolSize;
        tranche.minTokenAllowed = _minTokenAllowed;
        tranche.maxTokenAllowed = _maxTokenAllowed;
        tranche.endDate = _endDate;
        tranche.remainingPoolSize = _poolSize;
        tranche.taxBenefit = _taxBenefit;
        tranche.rewardTokens = maxRewards;
        tranche.status = Status.NEW;

        totalTokensPoolSize = totalTokensPoolSize.add(_poolSize);
        totalActiveTranches++;

        emit ETranche(
            _msgSender(),
            tid,
            _name,
            _poolSize,
            _minTokenAllowed,
            _maxTokenAllowed,
            _APY,
            _endDate,
            _taxBenefit,
            uint256(Status.ACTIVE)
        );
    }

    function enableTranche(uint32 _tid) external onlyOwner validTranche(_tid) {
        require(
            (mapTranches[_tid].status == Status.NEW || mapTranches[_tid].status == Status.INACTIVE),
            "Invalid tranche status."
        );
        require(block.timestamp < mapTranches[_tid].endDate, "Tranche is expired.");
        mapTranches[_tid].status = Status.ACTIVE;
        emit ETrancheStatus(_msgSender(), _tid, uint256(Status.ACTIVE));
    }

    function disableTranche(uint32 _tid) external onlyOwner validTranche(_tid) inStatus(_tid, Status.ACTIVE) {
        mapTranches[_tid].status = Status.INACTIVE;
        emit ETrancheStatus(_msgSender(), _tid, uint256(Status.INACTIVE));
    }

    function enterStaking(uint32 _tid, uint256 _amount)
        external
        validTranche(_tid)
        expiredTranche(_tid)
        inStatus(_tid, Status.ACTIVE)
    {
        require(mapUserInfo[_msgSender()][_tid].amount == 0, "User already in tranche.");
        require(_amount > 0, "Amount should be greater than 0.");

        TrancheInfo storage tranche = mapTranches[_tid];
        require(_amount >= tranche.minTokenAllowed, "Amount less than the minimum required.");
        require(_amount <= tranche.maxTokenAllowed, "Amount more than the maximum allowed.");
        require(_amount <= tranche.remainingPoolSize, "Remaining pool size is smaller than the amount.");

        IBEP20(stakeTokenAddr).safeTransferFrom(_msgSender(), address(this), _amount.mul(DECIMALFACTOR));

        UserStakeInfo storage user = mapUserInfo[_msgSender()][_tid];
        user.userAddress = _msgSender();
        user.amount = _amount;
        user.startDate = block.timestamp;

        mapTranceUsers[_tid].push(_msgSender());
        totalTokensStaked = totalTokensStaked.add(_amount);

        tranche.remainingPoolSize = tranche.remainingPoolSize.sub(_amount);
        if (tranche.remainingPoolSize < tranche.minTokenAllowed) {
            tranche.status = Status.INACTIVE;
            emit ETrancheStatus(address(0x0), _tid, uint256(Status.INACTIVE));
        }

        emit EStaking(_msgSender(), _tid, _amount);
    }

    function exitStaking(uint32 _tid) external validTranche(_tid) expiredTranche(_tid) noReentry {
        require(mapUserInfo[_msgSender()][_tid].amount > 0, "User not in tranche.");
        require(block.timestamp > mapTranches[_tid].endDate, "Lock in period not over.");

        uint256 totalRewards = calculateTotalRewards(_tid, _msgSender());
        uint256 amountToTransfer = mapUserInfo[_msgSender()][_tid].amount.add(totalRewards);

        IBEP20(stakeTokenAddr).safeTransfer(_msgSender(), amountToTransfer.mul(DECIMALFACTOR));

        delete (mapUserInfo[_msgSender()][_tid]);
        totalTokensRewarded = totalTokensRewarded.add(totalRewards);
        totalRewardTokensBalance = totalRewardTokensBalance.sub(totalRewards);

        address[] storage arrAddress = mapTranceUsers[_tid];
        uint32 index;
        for (uint32 i = 0; i < arrAddress.length; i++) {
            if (arrAddress[i] == _msgSender()) {
                index = i;
                break;
            }
        }
        arrAddress[index] = arrAddress[arrAddress.length - 1];
        arrAddress.pop();

        emit EUnStaking(_msgSender(), _tid, amountToTransfer);
    }

    function getCurrentBalance(uint32 _tid) external view returns (uint256, uint256) {
        uint256 noOfDays;
        if (block.timestamp > mapTranches[_tid].endDate) {
            noOfDays = (mapTranches[_tid].endDate.sub(mapUserInfo[_msgSender()][_tid].startDate)).div(SECONDSINDAY);
        } else {
            noOfDays = (block.timestamp.sub(mapUserInfo[_msgSender()][_tid].startDate)).div(SECONDSINDAY);
        }
        uint256 rewardAmount = calculateReward(mapUserInfo[_msgSender()][_tid].amount, mapTranches[_tid].APY, noOfDays);
        return (mapUserInfo[_msgSender()][_tid].amount, rewardAmount);
    }

    function closeTranche(uint32 _tid) external inStatus(_tid, Status.EXPIRED) onlyOwner noReentry {
        address[] storage arrAddress = mapTranceUsers[_tid];
        uint256 totalRewards;
        uint256 arrLength = arrAddress.length;
        address addr;

        for (uint256 index = arrLength; index > 0; index--) {
            addr = arrAddress[index - 1];

            totalRewards = calculateTotalRewards(_tid, addr);
            IBEP20(stakeTokenAddr).safeTransfer(
                addr,
                mapUserInfo[addr][_tid].amount.add(totalRewards).mul(DECIMALFACTOR)
            );

            delete (mapUserInfo[arrAddress[index]][_tid]);
            totalTokensRewarded = totalTokensRewarded.add(totalRewards);
            totalRewardTokensBalance = totalRewardTokensBalance.sub(totalRewards);

            arrAddress.pop();
            arrLength = arrAddress.length;
        }

        totalRewardTokensRequired = totalRewardTokensRequired.sub(mapTranches[_tid].rewardTokens);

        mapTranches[_tid].status = Status.CLOSED;
        emit ETrancheStatus(_msgSender(), _tid, uint256(Status.CLOSED));
        emit ECloseTranche(_msgSender(), _tid);
    }

    function closeStaking() external onlyOwner {
        require(totalActiveTranches == 0, "Active tranches available.");

        uint256 currentBalance = IBEP20(stakeTokenAddr).balanceOf(address(this));

        IBEP20(stakeTokenAddr).safeTransfer(owner(), currentBalance);
        totalRewardTokensRequired = 0;
        totalRewardTokensBalance = 0;

        emit ECloseStaking(_msgSender(), currentBalance.div(DECIMALFACTOR));
    }

    function calculateMaxRewards(
        uint256 _amount,
        uint256 _APY,
        uint256 _endDate,
        bool _taxBenefit
    ) private view returns (uint256) {
        uint256 noOfDays = (_endDate.sub(block.timestamp)).div(SECONDSINDAY);
        uint256 totalRewardAmount = calculateReward(_amount, _APY, noOfDays);

        uint256 totalTaxRefundAmount = 0;
        if (_taxBenefit) {
            totalTaxRefundAmount = calculateTaxRefund(_amount.add(totalRewardAmount));
        }

        return totalRewardAmount.add(totalTaxRefundAmount);
    }

    function calculateTotalRewards(uint32 _tid, address userAddress) private view returns (uint256) {
        UserStakeInfo memory userInfo = mapUserInfo[userAddress][_tid];

        uint256 noOfDays = (mapTranches[_tid].endDate.sub(userInfo.startDate)).div(SECONDSINDAY);

        uint256 rewardAmount = calculateReward(mapUserInfo[userAddress][_tid].amount, mapTranches[_tid].APY, noOfDays);
        uint256 taxRefundAmount = 0;
        if (mapTranches[_tid].taxBenefit) {
            taxRefundAmount = calculateTaxRefund(userInfo.amount.add(rewardAmount));
        }

        return rewardAmount.add(taxRefundAmount);
    }

    function calculateReward(
        uint256 _amount,
        uint256 _APY,
        uint256 _noOfDays
    ) private pure returns (uint256) {
        uint256 totalRewards = _amount.mul(_APY).mul((_noOfDays.mul(GRANULARITY)).div(DAYSINYEAR));
        totalRewards = (totalRewards.div(GRANULARITY)).div(100);
        return totalRewards;
    }

    function calculateTaxRefund(uint256 _amount) private view returns (uint256) {
        uint256 txFees = IBEP20(stakeTokenAddr)._TAX_FEE().add(IBEP20(stakeTokenAddr)._BURN_FEE()).add(
            IBEP20(stakeTokenAddr)._CHARITY_FEE()
        );
        return (_amount.mul(txFees)).div(10000); // 100*100
    }
}