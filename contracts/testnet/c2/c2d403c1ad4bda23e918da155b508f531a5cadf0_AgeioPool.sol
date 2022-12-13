/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
interface ITDrop {
  function balanceOf(address account) external view returns (uint);
  function transfer(address dst, uint rawAmount) external returns (bool);
  function transferFrom(address src, address dst, uint rawAmount) external returns (bool);
  function stakeReward(address dst, uint rawAmount) external;
}
interface IAgeioController {

  function treasury() external view returns (address);
  function commissionFee() external view returns(uint256, uint256);
  
  function claimAgtReward(address chef, uint256 _amount) external;
  function swapAgtWithTfuel(uint256 amount) external payable returns (bool);
  function estTfuelAmount(uint256 agtAmount) external view returns(uint256);
  function estAgtAmount(uint256 tfuelAmount) external view returns(uint256);
  function getAgtAmountFromTfuel(uint256 tfuelAmount) external view returns(uint256);
}

contract AgeioPool is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 public tankFee;
  
  // staking tokens
  address public token;
  // reward tokens
  address public agtToken;
  ITDrop public tdrop;

  address public ageioController;

  struct PoolInfo {
    address tank;
    uint256 bonusMultiplier;
    uint256 totalDeposited;
    uint256 totalStakedOnGNode;
    bool    unstakingFromGNode;
    uint256 pendingWithdrawals;
    uint256 tfuelReward;
    uint256 tdropReward;
    uint256 depositRounds;
    uint256 updatedAt;
  }
  PoolInfo[] public poolInfo;

  // Info of each user
  struct UserInfo {
    uint256 amount;
    uint256 withdrawals;
    uint256 lastClaimedRound;
    uint256 tfuelRewardDebt;
    uint256 tdropRewardDebt;
  }
  mapping(uint256 => mapping(address => UserInfo)) public userInfo;

  modifier onlyTank(uint256 _pid) {
    require(_pid < poolInfo.length, "Tank: invalid tank");
    require(_msgSender() == poolInfo[_pid].tank, "Tank: wut?");
    _;
  }
  modifier onlyPool(uint256 _pid) {
    require(_pid < poolInfo.length, "Error: Invalid Pool");
    _;
  }

  constructor() {
    tankFee = 1*1e18;
  }
  function setToken(address _token) public onlyOwner {
    token = _token;
  }
  function setAgtToken(address _agtToken) public onlyOwner {
    agtToken = _agtToken;
  }
  function setAgeioController(address _controller) external onlyOwner {
    ageioController = _controller;
  }
  function setTdrop(address _tdrop) public onlyOwner {
    tdrop = ITDrop(_tdrop);
  }
  function changeTankFee(uint256 _tankFee) public onlyOwner {
    if (_tankFee > 0) tankFee = _tankFee;
  }
  function getMultiplier(uint256 _pid, uint256 _from, uint256 _to) public view returns(uint256) {
    return _to.sub(_from).mul(poolInfo[_pid].bonusMultiplier);
  }

  function poolLength() external view returns (uint256) {
    return poolInfo.length;
  }

  function add(address _tank, uint256 _bonusMultiplier) public onlyOwner {
    require(_tank != address(0) && _tank != owner(), "Error: invalid tank address.");
    poolInfo.push(PoolInfo({
      tank: _tank,
      bonusMultiplier: _bonusMultiplier,
      totalDeposited: 0,
      totalStakedOnGNode: 0,
      unstakingFromGNode: false,
      pendingWithdrawals: 0,
      tfuelReward: 0,
      tdropReward: 0,
      updatedAt: block.timestamp,
      depositRounds: 0
    }));
    IERC20(token).safeApprove(address(_tank), type(uint256).max);
  }
  function set(uint256 _pid, address _tank, uint256 _bonusMultiplier) public onlyOwner {
    require(_tank != address(0) && _tank != owner(), "Error: invalid tank address.");
    require(poolInfo[_pid].totalDeposited == 0, "Error: this pool is not able to change.");
    if (poolInfo[_pid].tank != _tank) {
      poolInfo[_pid].tank = _tank;
      IERC20(token).safeApprove(address(_tank), type(uint256).max);
    }
    if (_bonusMultiplier > 0) poolInfo[_pid].bonusMultiplier = _bonusMultiplier;
    poolInfo[_pid].updatedAt = block.timestamp;
  }

  event Deposited(uint256 pid, address user, uint256 amount);
  function deposit(uint256 _pid, uint256 amount) external payable onlyPool(_pid) {
    require(msg.value >= tankFee, "Deposit: Insufficient Tank Fee");
    require(IERC20(token).balanceOf(_msgSender()) >= amount, "Deposit: Insufficient Token Balance.");
    PoolInfo storage pool = poolInfo[_pid];
    require(pool.unstakingFromGNode == false, "Deposit: Not allow deposit now");
    UserInfo storage user = userInfo[_pid][_msgSender()];

    pool.totalDeposited = pool.totalDeposited.add(amount);

    // user info update
    user.amount = user.amount.add(amount);

    IERC20(token).safeTransferFrom(address(_msgSender()), address(this), amount);
    safeTransferTfuel(address(pool.tank), msg.value);
    emit Deposited(_pid, _msgSender(), amount);
  }
  /**
    *** When user tries to withdraw staked wtheta from Ageio Pool, it will not work instantly.
    *** Instead, it will be placed in the withdrawal queue and processed after the weekend.
   */
  event RequestedWithdraw(uint256 _pid, address user, uint256 amount, uint256 time);
  function requestWithdraw(uint256 _pid, uint256 amount) external onlyPool(_pid) {
    PoolInfo storage pool = poolInfo[_pid];
    require(pool.unstakingFromGNode == false, "Withdraw: Not allowed");
    require(amount >= 0, "Withdraw: amount should be greater than zero.");
    UserInfo storage user = userInfo[_pid][_msgSender()];
    require(user.amount >= amount, "Withdraw: Withdrawal amount exceed user balance.");
    _claimReward(_pid, _msgSender());
    user.amount = user.amount.sub(amount);
    pool.pendingWithdrawals = pool.pendingWithdrawals.add(amount);
    user.withdrawals = user.withdrawals.add(amount);

    emit RequestedWithdraw(_pid, _msgSender(), amount, block.timestamp);
  }
  event CancelWithdraw(uint256 pid, address user, uint256 amount);
  function cancelWithdraw(uint56 _pid) public payable onlyPool(_pid) {
    PoolInfo storage pool = poolInfo[_pid];
    require(pool.unstakingFromGNode == false, "CancelWithdraw: Not allowed");
    UserInfo storage user = userInfo[_pid][_msgSender()];
    require(user.withdrawals >= 0, "CancelWithdraw: Insufficient balance.");
    pool.totalDeposited = pool.totalDeposited.add(user.withdrawals);
    user.amount = user.amount.add(user.withdrawals);
    safeTransferTfuel(address(pool.tank), msg.value);
    emit CancelWithdraw(_pid, _msgSender(), user.withdrawals);
    user.withdrawals = 0;
  }

  event StakedTokenToGNode(uint256 pid, address tank, uint256 depositAmount, uint256 totalStakedAmount);
  function stakeTokenToGNode(uint256 _pid) external onlyTank(_pid) {
    PoolInfo storage pool = poolInfo[_pid];
    IERC20(token).safeTransfer(address(pool.tank), pool.totalDeposited);
    pool.totalStakedOnGNode = pool.totalStakedOnGNode.add(pool.totalDeposited);
    pool.totalDeposited = 0;
    pool.updatedAt = block.timestamp;
    emit StakedTokenToGNode(_pid, pool.tank, pool.totalDeposited, pool.totalStakedOnGNode);
  }

  function startWithdraw(uint256 _pid) public onlyTank(_pid) {
    poolInfo[_pid].unstakingFromGNode = true;
  }
  function endWithdraw(uint256 _pid, uint256 _amount) external onlyTank(_pid) {
    PoolInfo storage pool = poolInfo[_pid];
    require(_amount == pool.pendingWithdrawals, "EndWithdraw: Insufficient amount");
    IERC20(token).safeTransferFrom(address(pool.tank), address(this), pool.pendingWithdrawals);
    pool.unstakingFromGNode = false;
    
    pool.totalStakedOnGNode = pool.totalStakedOnGNode.sub(pool.pendingWithdrawals);
    pool.pendingWithdrawals = 0;
    //------------- need to check this function again again again ~~~~~~~~~~~~~~~~~~
  }
  event DepositedReward(uint256 pid, uint256 tfuelAmount, uint256 tdropAmount);
  function depositReward(uint256 _pid, uint256 _tdropReward) external payable onlyTank(_pid) {
    PoolInfo storage pool = poolInfo[_pid];
    pool.depositRounds++;
    require(msg.value > 0, "Error: Tfuel earned is zero");
    if (_tdropReward > 0) {
      tdrop.transferFrom(address(_msgSender()), address(this), _tdropReward);
    }
    pool.tfuelReward = pool.tfuelReward.add(msg.value);
    pool.tdropReward = pool.tdropReward.add(_tdropReward);

    emit DepositedReward(_pid, msg.value, _tdropReward);
  }
  
  //claim functions
  event ClaimedWithdraw(uint256 pid, address user, uint256 amount);
  function withdraw(uint256 _pid) public onlyPool(_pid) {
    PoolInfo storage pool = poolInfo[_pid];
    require(pool.unstakingFromGNode == false, "Claim Withdraw: Not allow now.");
    UserInfo storage user = userInfo[_pid][_msgSender()];
    require(user.withdrawals > 0, "Claim Withdraw: Insufficient Balance.");
    IERC20(token).safeTransfer(address(_msgSender()), user.withdrawals);
    emit ClaimedWithdraw(_pid, _msgSender(), user.withdrawals);
    user.withdrawals = 0;
  }
  function earnedReward(uint256 _pid, address _account) public view returns(uint256 agtEarned, uint256 tfuelEarned, uint256 tdropEarned) {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_account];
    if (user.amount == 0 || pool.totalStakedOnGNode == 0 || pool.tfuelReward == 0 || user.lastClaimedRound == pool.depositRounds || pool.depositRounds == 0) return (0, 0, 0);
    tfuelEarned = pool.tfuelReward.mul(user.amount).div(pool.totalStakedOnGNode);
    tfuelEarned = tfuelEarned.sub(user.tfuelRewardDebt);
    tdropEarned = pool.tdropReward.mul(user.amount).div(pool.totalStakedOnGNode);
    tdropEarned = tdropEarned.sub(user.tdropRewardDebt);
    // calculate agt reward from tfuelReward
    agtEarned = IAgeioController(ageioController).estAgtAmount(tfuelEarned);
    agtEarned = agtEarned.mul(pool.bonusMultiplier);
  }
  
  function claimReward(uint256 _pid) external {
    _claimReward(_pid, _msgSender());
  }
  event ClaimedReward(uint256 pid, address user, uint256 agtAmount, uint256 tfuelAmount, uint256 tdropAmount);
  function _claimReward(uint256 _pid, address account) internal {
    UserInfo storage user = userInfo[_pid][account];
    (, uint256 tfuelEarned, uint256 tdropEarned) = earnedReward(_pid, account);
    uint256 tdropAmount = 0;
    uint256 tfuelAmount = 0;
    uint256 agtEarned = 0;
    (uint256 treasuryFee, uint256 burnFee) = IAgeioController(ageioController).commissionFee();
    if (tfuelEarned > 0) {
      uint256 tfuelForTreasury = tfuelEarned.mul(treasuryFee).div(1e4);
      uint256 tfuelForAgt = tfuelEarned.mul(burnFee).div(1e4);
      tfuelAmount = tfuelEarned.sub(tfuelForTreasury.add(tfuelForAgt));

      safeTransferTfuel(IAgeioController(ageioController).treasury(), tfuelForTreasury);
      IAgeioController(ageioController).swapAgtWithTfuel{value: tfuelForAgt}(tfuelForAgt);
      safeTransferTfuel(address(account), tfuelAmount);
      
      user.tfuelRewardDebt = user.tfuelRewardDebt.add(tfuelAmount);
    
      agtEarned = IAgeioController(ageioController).estAgtAmount(tfuelAmount);
      IAgeioController(ageioController).claimAgtReward(address(account), agtEarned);
    }
    if (tdropEarned > 0) {
      uint256 tdropFee = tdropEarned.mul(treasuryFee.add(burnFee)).div(1e4);
      safeTransferTdrop(IAgeioController(ageioController).treasury(), tdropFee);
      tdropAmount = tdropEarned.sub(tdropFee);
      safeTransferTdrop(address(account), tdropAmount);
      user.tdropRewardDebt = user.tdropRewardDebt.add(tdropAmount);
    }

    emit ClaimedReward(_pid, account, agtEarned, tfuelAmount, tdropAmount);
  }
  
  function safeTransferTdrop(address to, uint256 amount) internal {
    uint256 sendAmount = (tdrop.balanceOf(address(this)) < amount) ? tdrop.balanceOf(address(this)) : amount;
    tdrop.transfer(to, sendAmount);
  }
  // Safe transfer tfuel
  function safeTransferTfuel(address to, uint256 amount) internal {
    uint256 amountBal = amount;
    if (address(this).balance <= amount) amountBal = address(this).balance;
    (bool success, ) = to.call{gas: 23000, value: amountBal}("");
    require(success, 'TransferHelper: TFUEL_TRANSFER_FAILED');
  }
  
  function closeAgeioPool() public onlyOwner {
    IERC20(agtToken).transfer(_msgSender(), IERC20(agtToken).balanceOf(address(this)));
    safeTransferTfuel(_msgSender(), address(this).balance);
  }

  receive() external payable {}
}