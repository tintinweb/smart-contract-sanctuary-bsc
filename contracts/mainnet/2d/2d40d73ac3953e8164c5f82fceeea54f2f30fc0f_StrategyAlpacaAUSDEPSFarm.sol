/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File @openzeppelin/contracts/math/[email protected]

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity >=0.6.0 <0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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


// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity >=0.6.0 <0.8.0;



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


// File @openzeppelin/contracts/proxy/[email protected]



// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}


// File contracts/interfaces/VaultAPI.sol


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

struct StrategyParams {
  uint256 performanceFee;
  uint256 activation;
  uint256 debtRatio;
  uint256 rateLimit;
  uint256 lastReport;
  uint256 totalDebt;
  uint256 totalGain;
  uint256 totalLoss;
}

interface VaultAPI is IERC20 {

  function apiVersion() external view returns (string memory);

  function withdraw(uint256 shares, address recipient, uint256 maxLoss) external;

  function token() external view returns (address);

  function strategies(address _strategy) external view returns (StrategyParams memory);

  function creditAvailable(address _strategy) external view returns (uint256);

  function debtOutstanding(address _strategy) external view returns (uint256);

  function expectedReturn(address _strategy) external view returns (uint256);

  function report(
    uint256 _gain,
    uint256 _loss,
    uint256 _debtPayment
  ) external returns (uint256);

  function revokeStrategy(address _strategy) external;

  function governance() external view returns (address);

}


// File contracts/strategies/BaseStrategy.sol


pragma solidity 0.6.12;




/**
 *  BaseStrategy implements all of the required functionality to interoperate
 *  closely with the Vault contract. This contract should be inherited and the
 *  abstract methods implemented to adapt the Strategy to the particular needs
 *  it has to create a return.
 *
 *  Of special interest is the relationship between `harvest()` and
 *  `vault.report()'. `harvest()` may be called simply because enough time has
 *  elapsed since the last report, and not because any funds need to be moved
 *  or positions adjusted. This is critical so that the Vault may maintain an
 *  accurate picture of the Strategy's performance. See  `vault.report()`,
 *  `harvest()`, and `harvestTrigger()` for further details.
 */
abstract contract BaseStrategy is Initializable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  VaultAPI public vault;
  
  address public strategist;
  address public rewards;
  address public keeper;


  IERC20 public want;

  // The maximum number of seconds between harvest calls.
  uint256 public maxReportDelay;    // maximum report delay

  // The minimum multiple that `callCost` must be above the credit/profit to
  // be "justifiable". See `setProfitFactor()` for more details.
  uint256 public profitFactor;

  // Use this to adjust the threshold at which running a debt causes a
  // harvest trigger. See `setDebtThreshold()` for more details.
  uint256 public debtThreshold;

  bool public emergencyExit;

  mapping (address => bool) public protected;
  
  event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);
  
  event UpdatedReportDelay(uint256 delay);
  
  event UpdatedProfitFactor(uint256 profitFactor);
  
  event UpdatedDebtThreshold(uint256 debtThreshold);
  
  event UpdatedStrategist(address newStrategist);

  event UpdatedKeeper(address newKeeper);

  event UpdatedRewards(address rewards);

  event EmergencyExitEnabled();

  modifier onlyKeepers() {
    require(msg.sender == keeper || msg.sender == strategist || msg.sender == governance(), "!keeper & !strategist & !governance");
    _;
  }

  modifier onlyAuthorized() {
    require(msg.sender == strategist || msg.sender == governance(), "!strategist & !governance");
    _;
  }

  modifier onlyGovernance() {
    require(msg.sender == governance(), "!authorized");
    _;
  }

  modifier onlyStrategist() {
    require(msg.sender == strategist, "!strategist");
    _;
  }

  function initialize(
    address _vault
  ) public initializer {
    
    vault = VaultAPI(_vault);
    want = IERC20(VaultAPI(_vault).token());
    
    IERC20(VaultAPI(_vault).token()).safeApprove(_vault, uint256(-1));
    
    strategist = msg.sender;
    rewards = msg.sender;
    keeper = msg.sender;
    
    setProtectedTokens();
    
    profitFactor = 100;
    debtThreshold = 0;
    maxReportDelay = 86400;
  }
  
  function apiVersion() external pure returns (string memory) {
    return '0.1.0';
  }

  function name() external virtual view returns (string memory);

  function delegatedAssets() external virtual pure returns (uint256) {
    return 0;
  }

  function setStrategist(address _strategist) external onlyAuthorized {
    require(_strategist != address(0), "zero address");
    strategist = _strategist;
    emit UpdatedStrategist(_strategist);
  }

  function setKeeper(address _keeper) external onlyAuthorized {
    require(_keeper != address(0), "zero address");
    keeper = _keeper;
    emit UpdatedKeeper(_keeper);
  }

  function setRewards(address _rewards) external onlyStrategist {
    require(_rewards != address(0), "zero address");
    rewards = _rewards;
    emit UpdatedRewards(_rewards);
  }

  function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
    profitFactor = _profitFactor;
    emit UpdatedProfitFactor(_profitFactor);
  }

  function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
    debtThreshold = _debtThreshold;
    emit UpdatedDebtThreshold(_debtThreshold);
  }

  function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
    maxReportDelay = _delay;
    emit UpdatedReportDelay(_delay);
  }

  /** 
   * @notice
   * Harvest the strategy.
   * This function can be called only by governance, the strategist or the keeper
   * harvest function is called in order to take in profits, to borrow newly available funds from the vault, or adjust the position
   */

  function harvest() external onlyKeepers {
    _harvest();
  }

  // withdraw assets to the vault
  function withdraw(uint256 _amountNeeded) external returns (uint256 amountFreed, uint256 _loss) {
    require(msg.sender == address(vault), "!vault");
    (amountFreed, _loss) = liquidatePosition(_amountNeeded);
    want.safeTransfer(msg.sender, amountFreed);
  }

  
  /**
   * Transfer all assets from current strategy to new strategy
   */
  function migrate(address _newStrategy) external {
    require(msg.sender == address(vault) || msg.sender == governance(), "!vault or !governance");
    require(BaseStrategy(_newStrategy).vault() == vault, "vault address is not the same");
    prepareMigration(_newStrategy);
    want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
  }

  /**
   * @notice
   * Activates emergency exit. The strategy will be rovoked and withdraw all funds to the vault.
   * This may only be called by governance or the strategist.
   */

  function setEmergencyExit() external onlyAuthorized {
    emergencyExit = true;
    vault.revokeStrategy(address(this));

    emit EmergencyExitEnabled();
  }

  // Removes tokens from this strategy that are not the type of tokens managed by this strategy
  function sweep(address _token) external onlyGovernance {
    require(_token != address(want), "!want");
    require(_token != address(vault), "!shares");
    require(!protected[_token], "!protected");

    IERC20(_token).safeTransfer(governance(), IERC20(_token).balanceOf(address(this)));
  }

  /**
   * @notice
   *  Provide an accurate estimate for the total amount of assets
   *  (principle + return) that this Strategy is currently managing,
   *  denominated in terms of `want` tokens.
   * @return The estimated total assets in this Strategy.
   */
  function estimatedTotalAssets() external view returns (uint256) {
    return _estimatedTotalAssets();
  }

  /**
   * @notice
   *  Provide an indication of whether this strategy is currently "active"
   *  in that it is managing an active position, or will manage a position in
   *  the future. This should correlate to `harvest()` activity, so that Harvest
   *  events can be tracked externally by indexing agents.
   * @return True if the strategy is actively managing a position.
   */
  function isActive() external view returns (bool) {
    return vault.strategies(address(this)).debtRatio > 0 || _estimatedTotalAssets() > 0;
  }

  function harvestTrigger(uint256 callCost) external virtual view returns (bool) {
    StrategyParams memory params = vault.strategies(address(this));

    if (params.activation == 0) return false;

    if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;

    uint256 outstanding = vault.debtOutstanding(address(this));
    if (outstanding > debtThreshold) return true;

    uint256 total = _estimatedTotalAssets();

    if (total.add(debtThreshold) < params.totalDebt) return true;

    uint256 profit = 0;
    if (total > params.totalDebt) profit = total.sub(params.totalDebt);

    uint256 credit = vault.creditAvailable(address(this));
    return (profitFactor.mul(callCost) < credit.add(profit));
  }

  function governance() internal view returns (address) {
    return vault.governance();
  }

  function _estimatedTotalAssets() internal virtual view returns (uint256);

  /**
   * Perform any Strategy unwinding or other calls necessary to capture the
   * "free return" this Strategy has generated since the last time its core
   * position(s) were adjusted. Examples include unwrapping extra rewards.
   * This call is only used during "normal operation" of a Strategy, and
   * should be optimized to minimize losses as much as possible.
   *
   * This method returns any realized profits and/or realized losses
   * incurred, and should return the total amounts of profits/losses/debt
   * payments (in `want` tokens) for the Vault's accounting (e.g.
   * `want.balanceOf(this) >= _debtPayment + _profit - _loss`).
   */
  function prepareReturn(uint256 _debtOutstanding) internal virtual returns (
    uint256 _profit,
    uint256 _loss,
    uint256 _debtPayment
  );

  /**
   * Perform any adjustments to the core position(s) of this Strategy given
   * what change the Vault made in the "investable capital" available to the
   * Strategy. Note that all "free capital" in the Strategy after the report
   * was made is available for reinvestment. Also note that this number
   * could be 0, and you should handle that scenario accordingly.
   */
  function adjustPosition(uint256 _debtOutstanding) internal virtual;

  /**
   * Liquidate up to `_amountNeeded` of `want` of this strategy's positions,
   * irregardless of slippage. Any excess will be re-invested with `adjustPosition()`.
   * This function should return the amount of `want` tokens made available by the
   * liquidation. If there is a difference between them, `_loss` indicates whether the
   * difference is due to a realized loss, or if there is some other sitution at play
   * (e.g. locked funds). This function is used during emergency exit instead of
   * `prepareReturn()` to liquidate all of the Strategy's positions back to the Vault.
   */
  function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);

  /**
   *  `Harvest()` calls this function after shares are created during
   *  `vault.report()`. You can customize this function to any share
   *  distribution mechanism you want.
   */
  function distributeRewards() internal virtual {
    uint256 balance = vault.balanceOf(address(this));
    if (balance > 0) {
      IERC20(vault).safeTransfer(rewards, balance);
    }
  }

  function _harvest() internal {
    uint256 _profit = 0;
    uint256 _loss = 0;
    uint256 _debtOutstanding = vault.debtOutstanding(address(this));
    uint256 _debtPayment = 0;

    if (emergencyExit) {
      uint256 totalAssets = _estimatedTotalAssets();     // accurated estimate for the total amount of assets that the strategy is managing in terms of want token.
      (_debtPayment, _loss) = liquidatePosition(totalAssets > _debtOutstanding ? totalAssets : _debtOutstanding);
      if (_debtPayment > _debtOutstanding) {
        _profit = _debtPayment.sub(_debtOutstanding);
        _debtPayment = _debtOutstanding;
      }
    } else {
      (_profit, _loss, _debtPayment) = prepareReturn(_debtOutstanding);
    }

    // returns available free tokens of this strategy
    // this debtOutstanding becomes prevDebtOutstanding - debtPayment
    _debtOutstanding = vault.report(_profit, _loss, _debtPayment);

    distributeRewards();
    adjustPosition(_debtOutstanding);

    emit Harvested(_profit, _loss, _debtPayment, _debtOutstanding);
  }

  /**
   * Do anything necessary to prepare this Strategy for migration, such as
   * transferring any reserve or LP tokens, CDPs, or other tokens or stores of
   * value.
   */
  function prepareMigration(address _newStrategy) internal virtual;

  function setProtectedTokens() internal virtual;
}


// File contracts/interfaces/alpaca/IAlpacaVault.sol


pragma solidity 0.6.12;

interface IAlpacaVault is IERC20 {
  function deposit(uint256 amountToken) external payable;
  function withdraw(uint256 share) external;
  function totalToken() external view returns (uint256);
}


// File contracts/interfaces/alpaca/IProxyWalletRegistry.sol


pragma solidity 0.6.12;


interface IProxyWalletRegistry {
  function build() external returns (address payable _proxy);
}

interface IProxyWallet {
  function execute(address target, bytes memory _data) external payable returns (address _target, bytes memory _response);
}

interface IPositionManager {
  function positions(uint256 positionId) external view returns (address positionHandler);
  function ownerFirstPositionId(address owner) external view returns (uint256);
  function collateralPoolConfig() external view returns (address);
}

interface IBookKeeper {
  function positions(bytes32 collateralPoolId, address positionAddress) external view returns (
    uint256 lockedCollateral, // [wad]
    uint256 debtShare // [wad]
  );

  function collateralPoolConfig() external view returns (address);
}

interface IIbTokenAdapter {
  function netPendingRewards(address positionHandler) external view returns (uint256);
}

interface IStableSwapModule {
  function swapTokenToStablecoin(address _usr,uint256 _tokenAmount) external;
}

interface ICollateralPoolConfig {
  struct CollateralPool {
    uint256 totalDebtShare; // Total debt share of Alpaca Stablecoin of this collateral pool              [wad]
    uint256 debtAccumulatedRate; // Accumulated rates (equivalent to ibToken Price)                       [ray]
    uint256 priceWithSafetyMargin; // Price with safety margin (taken into account the Collateral Ratio)  [ray]
    uint256 debtCeiling; // Debt ceiling of this collateral pool                                          [rad]
    uint256 debtFloor; // Position debt floor of this collateral pool                                     [rad]
    address priceFeed; // Price Feed
    uint256 liquidationRatio; // Liquidation ratio or Collateral ratio                                    [ray]
    uint256 stabilityFeeRate; // Collateral-specific, per-second stability fee debtAccumulatedRate or mint interest debtAccumulatedRate [ray]
    uint256 lastAccumulationTime; // Time of last call to `collect`                                       [unix epoch time]
    address adapter;
    uint256 closeFactorBps; // Percentage (BPS) of how much  of debt could be liquidated in a single liquidation
    uint256 liquidatorIncentiveBps; // Percentage (BPS) of how much additional collateral will be given to the liquidator incentive
    uint256 treasuryFeesBps; // Percentage (BPS) of how much additional collateral will be transferred to the treasury
    address strategy; // Liquidation strategy for this collateral pool
  }

  function collateralPools(bytes32 _collateralPoolId) external view returns (CollateralPool memory);

  function getDebtAccumulatedRate(bytes32 _collateralPoolId) external view returns (uint256);

  function getPriceFeed(bytes32 _collateralPoolId) external view returns (address);

  function getLiquidationRatio(bytes32 _collateralPoolId) external view returns (uint256);

  function getStabilityFeeRate(bytes32 _collateralPoolId) external view returns (uint256);
}


// File contracts/interfaces/alpaca/IAlpacaFarm.sol


pragma solidity 0.6.12;

interface IAlpacaFarm {
  function userInfo(uint256 _pid, address user) external view returns (uint256, uint256, uint256, address);
  function pendingAlpaca(uint256 _pid, address user) external view returns (uint256);
  function deposit(address _for, uint256 _pid, uint256 _amount) external;
  function withdraw(address _for, uint256 _pid, uint256 _amount) external;
  function withdrawAll(address _for, uint256 _pid) external;
  function harvest(uint256 pid) external;
}


// File contracts/interfaces/uniswap/IUniswapV2Router.sol


pragma solidity 0.6.12;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB, uint liquidity);
  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB);
  function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  ) external returns (uint amountToken, uint amountETH);
  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountA, uint amountB);
  function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax, uint8 v, bytes32 r, bytes32 s
  ) external returns (uint amountToken, uint amountETH);
  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);
  function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

  function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

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


// File contracts/interfaces/ellipsis/IZap.sol


pragma solidity 0.6.12;

interface IZap {
  function calc_withdraw_one_coin(address pool, uint256 token_amount, int128 index) external view returns (uint256);
  function calc_token_amount(address pool, uint256[4] memory amounts, bool is_deposit) external view returns (uint256);
  function add_liquidity(address pool, uint256[4] memory deposit_amounts, uint256 min_mint_amount) external returns (uint256);
  function remove_liquidity_one_coin(address pool, uint256 burn_amount, int128 i, uint256 min_amount) external returns (uint256);
}


// File contracts/interfaces/ellipsis/IStableSwap.sol


pragma solidity 0.6.12;

interface IStableSwap {
  function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 dy) external returns (uint256);
  function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns (uint256);
}


// File contracts/strategies/AlpacaAusdEpsStrategy.sol


pragma solidity 0.6.12;








contract StrategyAlpacaAUSDEPSFarm is BaseStrategy {
  using Address for address;

  uint256 constant MAX_BPS = 10_000;
  address constant zap = 0xB15bb89ed07D2949dfee504523a6A12F90117d18;
  address constant proxyWalletRegistry = 0x13e3Bc3c6A96aE3beaDD1B08531Fde979Dd30aEa;
  address constant proxyActions = 0x1391FB5efc2394f33930A0CfFb9d407aBdbf1481;
  address constant positionManager = 0xABA0b03eaA3684EB84b51984add918290B41Ee19;
  address constant stabilityFeeCollector = 0x45040e48C00b52D9C0bd11b8F577f188991129e6;
  address constant tokenAdapter = 0x4f56a92cA885bE50E705006876261e839b080E36;
  address constant stablecoinAdapter = 0xD409DA25D32473EFB0A1714Ab3D0a6763bCe4749;
  address constant bookKeeper = 0xD0AEcee1520B5F9925D952405F9A06Dcd8fd6e6C;
  address constant stableSwapModule = 0xd16004424b9C3f0A7C74C4c8dcDa0D8C4D513fAC;
  bytes32 constant collateralPoolId = 0x6962425553440000000000000000000000000000000000000000000000000000;

  address public constant alpacaToken = address(0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F);
  IAlpacaFarm public constant alpacaFarm = IAlpacaFarm(0xA625AB01B08ce023B2a342Dbb12a16f2C8489A8F);
  address public constant wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
  address public constant ausd = address(0xDCEcf0664C33321CECA2effcE701E710A2D28A3F);
  address public constant ausd3eps = address(0xae70E3f6050d6AB05E03A50c655309C2148615bE);
  uint256 public constant poolId = 25;        // AUSD-3EPS pool id of alpaca farm contract
  address public constant pool = 0xa74077EB97778F4E94D79eA60092D0F4831d05A6;    // AUSD-3EPS pool address on Ellipsis
  uint256 public collateralFactor;
  IAlpacaVault public ibToken;
  IProxyWallet public proxyWallet;
  address[] public path;              // disposal path for alpaca token on uniswap

  address public constant uniswapRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public constant curveRouter = address(0xa74077EB97778F4E94D79eA60092D0F4831d05A6);

  uint256 public minAlpacaToSell;
  bool public forceMigrate;
  bool private adjusted;              // flag whether position adjusting was done in prepareReturn 

  modifier management(){
    require(msg.sender == governance() || msg.sender == strategist, "!management");
    _;
  }

  function initialize(
    address _vault, 
    address _ibToken,
    address[] memory _path
  ) public initializer {
    
    super.initialize(_vault);

    ibToken = IAlpacaVault(_ibToken);
    path = _path;

    minAlpacaToSell = 1e10;
    collateralFactor = 8750;

    proxyWallet = IProxyWallet(IProxyWalletRegistry(proxyWalletRegistry).build());

    want.safeApprove(address(ibToken), uint256(-1));
    want.safeApprove(address(curveRouter), uint256(-1));
    want.safeApprove(address(stableSwapModule), uint256(-1));
    want.safeApprove(address(proxyWallet), uint256(-1));
    IERC20(alpacaToken).safeApprove(address(uniswapRouter), uint256(-1));
    IERC20(ausd).safeApprove(address(zap), uint256(-1));
    IERC20(ausd3eps).safeApprove(address(zap), uint256(-1));
    IERC20(ausd3eps).safeApprove(address(alpacaFarm), uint256(-1));
  }

  function name() external override view returns (string memory) {
    return "StrategyAlpacaAUSDEPSFarm";
  }

  function setForceMigrate(bool _force) external onlyGovernance {
    forceMigrate = _force;
  }

  function setMinAutoToSell(uint256 _minAlpacaToSell) external management {
    minAlpacaToSell = _minAlpacaToSell;
  }

  function setDisposalPath(address[] memory _path) external management {
    path = _path;
  }

  /**
   * View how much the vault expect this strategy to return at the current block, based on its present performance (since its last report)
   */
  function expectedReturn() external view returns (uint256) {
    uint256 estimatedAssets = _estimatedTotalAssets();

    uint256 debt = vault.strategies(address(this)).totalDebt;
    if (debt >= estimatedAssets) {
      return 0;
    } else {
      return estimatedAssets - debt;
    }
  }

  /**
   * @notice
   *  Provide a signal to the keeper that harvest should be called.
   *  The keeper will provide the estimated gas cost that they would pay to call
   *  harvest() function.
   */
  function harvestTrigger(uint256 gasCost) external override view returns (bool) {
    StrategyParams memory params = vault.strategies(address(this));
    
    if (params.activation == 0) return false;

    // trigger if hadn't been called in a while
    if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;

    uint256 wantGasCost = _priceCheck(wbnb, address(want), gasCost);
    uint256 alpacaGasCost = _priceCheck(wbnb, alpacaToken, gasCost);

    (, , uint256 claimable) = _getCurrentPosition();
    uint256 _claimableAlpaca = claimable.add(IERC20(alpacaToken).balanceOf(address(proxyWallet))).add(alpacaFarm.pendingAlpaca(poolId, address(this)));

    if (_claimableAlpaca > minAlpacaToSell) {
      // trigger harvest if AUTO token balance is worth to do swap
      if (_claimableAlpaca.add(IERC20(alpacaToken).balanceOf(address(this))) > alpacaGasCost.mul(profitFactor)) {
        return true;
      }
    }

    uint256 outstanding = vault.debtOutstanding(address(this));
    if (outstanding > wantGasCost.mul(profitFactor)) return true;

    uint256 total = _estimatedTotalAssets();
    uint256 profit = 0;
    if (total > params.totalDebt) profit = total.sub(params.totalDebt);

    uint256 credit = vault.creditAvailable(address(this)).add(profit);
    return (wantGasCost.mul(profitFactor) < credit);
  }

  function farm() external {
    _claimAlpaca();
    _disposeAlpaca();

    (, uint256 debt, ) = _getCurrentPosition();
    (uint256 stakedBalance, , , ) = alpacaFarm.userInfo(poolId, address(this));
    uint256 lpValue = IZap(zap).calc_withdraw_one_coin(pool, stakedBalance, 0);
    if (debt > lpValue) {
      _mintAndStakeAusd(debt.sub(lpValue), true);
    }

    _farm(IERC20(want).balanceOf(address(this)));
  }

  function setCollateralFactor(uint256 _collateralFactor) external management {
    require(_collateralFactor > 0, "!zero");
    collateralFactor = _collateralFactor;
    
  }

  //////////////////////////////////
  ////    Internal Functions    ////
  //////////////////////////////////

  function _estimatedTotalAssets() internal override view returns (uint256) {
    (uint256 collateral, uint256 debt, uint256 claimable) = _getCurrentPosition();
    
    // add up alpaca rewards from alpaca farm and ausd farm
    // alpaca rewards of ausd farm distributed in two places, one is proxyWallet and the other is reward generation
    uint256 claimableAlpaca = claimable.add(IERC20(alpacaToken).balanceOf(address(proxyWallet))).add(alpacaFarm.pendingAlpaca(poolId, address(this)));
    uint256 currentAlpaca = IERC20(alpacaToken).balanceOf(address(this));
    uint256 claimableValue = _priceCheck(alpacaToken, address(want), claimableAlpaca.add(currentAlpaca));
    claimableValue = claimableValue.mul(9).div(10);      // remaining 10% will be used for compensate offset

    (uint256 stakedBalance, , , ) = alpacaFarm.userInfo(poolId, address(this));
    uint256 lpValue = IZap(zap).calc_withdraw_one_coin(pool, stakedBalance, 0);

    uint256 _assets = collateral.add(lpValue).add(claimableValue).sub(debt);
    return _assets;
  }

  function _getCurrentPosition() internal view returns (uint256 lockedCollateralValue, uint256 debt, uint256 claimable) {
    uint256 positionId = IPositionManager(positionManager).ownerFirstPositionId(address(proxyWallet));
    address positionHandler = IPositionManager(positionManager).positions(positionId);
    (uint256 lockedCollateral, uint256 debtShare) = IBookKeeper(bookKeeper).positions(collateralPoolId, positionHandler);
    lockedCollateralValue = lockedCollateral.mul(ibToken.totalToken()).div(ibToken.totalSupply());
    uint256 _debtAccumulatedRate = ICollateralPoolConfig(IBookKeeper(bookKeeper).collateralPoolConfig()).getDebtAccumulatedRate(collateralPoolId);
    debt = debtShare.mul(_debtAccumulatedRate).div(1e27);
    claimable = IIbTokenAdapter(tokenAdapter).netPendingRewards(positionHandler);
  }

  function prepareReturn(uint256 _debtOutstanding) internal override returns (
    uint256 _profit,
    uint256 _loss,
    uint256 _debtPayment
  ) {

    (uint256 collateral, uint256 debt, ) = _getCurrentPosition();
    if (collateral < minAlpacaToSell) {
      uint256 wantBalance = want.balanceOf(address(this));
      _debtPayment = _min(wantBalance, _debtOutstanding);
      return (_profit, _loss, _debtPayment);
    }

    _claimAlpaca();
    _disposeAlpaca();

    // match debt to staked amount of ausd of ausd3eps
    (uint256 stakedBalance, , , ) = alpacaFarm.userInfo(poolId, address(this));
    uint256 lpValue = IZap(zap).calc_withdraw_one_coin(pool, stakedBalance, 0);
    if (debt > lpValue) {
      _mintAndStakeAusd(debt.sub(lpValue), true);
    }

    uint256 wantBalance = want.balanceOf(address(this));
    
    (stakedBalance, , , ) = alpacaFarm.userInfo(poolId, address(this));
    lpValue = IZap(zap).calc_withdraw_one_coin(pool, stakedBalance, 0);
    
    uint256 assetBalance = collateral.add(wantBalance).add(lpValue).sub(debt);
    uint256 totalDebt = vault.strategies(address(this)).totalDebt;

    if (assetBalance > totalDebt) {
      _profit = assetBalance.sub(totalDebt);
    } else {
      _loss = totalDebt.sub(assetBalance);
    }

    if (wantBalance < _profit.add(_debtOutstanding)) {
      liquidatePosition(_profit.add(_debtOutstanding));
      adjusted = true;
      wantBalance = want.balanceOf(address(this));
      if (wantBalance >= _profit.add(_debtOutstanding)) {
        _debtPayment = _debtOutstanding;
        if (_profit.add(_debtOutstanding).sub(_debtPayment) < _profit) {
          _profit = _profit.add(_debtOutstanding).sub(_debtPayment);
        }
      } else {
        if (wantBalance < _debtOutstanding) {
          _debtPayment = wantBalance;
          _profit = 0;
        } else {
          _debtPayment = _debtOutstanding;
          _profit = wantBalance.sub(_debtPayment);
        }
      }
    } else {
      _debtPayment = _debtOutstanding;
      if (_profit.add(_debtOutstanding).sub(_debtPayment) < _profit) {
        _profit = _profit.add(_debtOutstanding).sub(_debtPayment);
      }
    }
  }

  function adjustPosition(uint256 _debtOutstanding) internal override {
    if (adjusted) {
      adjusted = false;
      return;
    }

    if (emergencyExit) {
      return;
    }

    uint256 _wantBal = want.balanceOf(address(this));
    if (_wantBal < _debtOutstanding) {
      uint256 _needed = _debtOutstanding.sub(_wantBal);
      _withdrawSome(_needed);
      return;
    }

    _farm(_wantBal - _debtOutstanding);
  }

  function _farm(uint256 amount) internal {
    if (amount == 0) return;

    (uint256 collateral, uint256 debt, ) = _getCurrentPosition();
    
    uint256 desiredCollateralValue = collateral.add(amount);
    uint256 desiredDebt = desiredCollateralValue.mul(collateralFactor).div(MAX_BPS);
    uint256 borrow = desiredDebt.sub(debt);
    convertLockTokenAndDraw(amount, borrow, true);
    
    uint256 depositAmount = IERC20(ausd).balanceOf(address(this));
    IZap(zap).add_liquidity(pool, [depositAmount, 0, 0, 0], 0);
    
    alpacaFarm.deposit(address(this), poolId, IERC20(ausd3eps).balanceOf(address(this)));
  }

  function _withdrawSome(uint256 _amount) internal {
    (uint256 collateral, uint256 debt, ) = _getCurrentPosition();
    if (_amount > collateral) {
      _amount = collateral;
    }
    uint256 desiredCollateralValue = collateral.sub(_amount);
    uint256 desiredDebt = desiredCollateralValue.mul(collateralFactor).div(MAX_BPS);
    if (desiredDebt <= 500e18) {
      (uint256 stakedLp, , , ) = alpacaFarm.userInfo(poolId, address(this));
      alpacaFarm.withdraw(address(this), poolId, stakedLp);
      IZap(zap).remove_liquidity_one_coin(pool, stakedLp, 0, 0);
      uint256 ausdBal = IERC20(ausd).balanceOf(address(this));
      if (ausdBal < debt) {
        _claimAlpaca();
        _disposeAlpaca();
        _mintAndStakeAusd(debt.sub(ausdBal), false);
      }
      convertLockTokenAndDraw(collateral.mul(ibToken.totalSupply()).div(ibToken.totalToken()).add(1), uint256(-1), false);
    } else {
      uint256 repay = debt.sub(desiredDebt);

      uint256 lpToWithdraw = IZap(zap).calc_token_amount(pool, [repay, 0, 0, 0], true);
      (uint256 stakedLp, , , ) = alpacaFarm.userInfo(poolId, address(this));
      if (lpToWithdraw > stakedLp) {
        lpToWithdraw = stakedLp;
      }
      
      alpacaFarm.withdraw(address(this), poolId, lpToWithdraw);
      IZap(zap).remove_liquidity_one_coin(pool, lpToWithdraw, 0, 0);
      convertLockTokenAndDraw(_amount.mul(ibToken.totalSupply()).div(ibToken.totalToken()), _min(IERC20(ausd).balanceOf(address(this)), repay), false);
    }
  }


  function convertLockTokenAndDraw(uint256 amount, uint256 stablecoinAmount, bool flag) internal {
    uint256 positionId = IPositionManager(positionManager).ownerFirstPositionId(address(proxyWallet));
    bytes memory _data;
    if (flag) {
      if (positionId == 0) {
        _data = abi.encodeWithSignature(
          "convertOpenLockTokenAndDraw(address,address,address,address,address,bytes32,uint256,uint256,bytes)", 
          ibToken, 
          positionManager,
          stabilityFeeCollector,
          tokenAdapter,
          stablecoinAdapter,
          collateralPoolId,
          amount,
          stablecoinAmount,
          abi.encode(address(this))
        );
      } else {
        _data = abi.encodeWithSignature(
          "convertLockTokenAndDraw(address,address,address,address,address,uint256,uint256,uint256,bytes)",
          ibToken,
          positionManager,
          stabilityFeeCollector,
          tokenAdapter,
          stablecoinAdapter,
          positionId,
          amount,
          stablecoinAmount,
          abi.encode(address(this))
        );
      }
    } else {
      IERC20(ausd).safeApprove(address(proxyWallet), uint256(-1));
      IERC20(ibToken).safeApprove(address(proxyWallet), uint256(-1));
      if (stablecoinAmount == uint256(-1)) {
        _data = abi.encodeWithSignature(
          "wipeAllUnlockTokenAndConvert(address,address,address,address,uint256,uint256,bytes)", 
          ibToken, 
          positionManager,
          tokenAdapter,
          stablecoinAdapter,
          positionId,
          amount,
          abi.encode(address(this))
        );
      } else {
        _data = abi.encodeWithSignature(
          "wipeUnlockTokenAndConvert(address,address,address,address,uint256,uint256,uint256,bytes)",
          ibToken,
          positionManager,
          tokenAdapter,
          stablecoinAdapter,
          positionId,
          amount,
          stablecoinAmount,
          abi.encode(address(this))
        );
      }
    }
    
    proxyWallet.execute(proxyActions, _data);
  }

  function _mintAndStakeAusd(uint256 amount, bool flag) internal {
    if (amount < minAlpacaToSell) {
      return;
    }
    uint256 est = IStableSwap(curveRouter).get_dy_underlying(1, 0, amount);
    if (est > amount) {
      IStableSwap(curveRouter).exchange_underlying(1, 0, amount, 0);
    } else {
      IStableSwapModule(stableSwapModule).swapTokenToStablecoin(address(this), amount);
    }

    if (flag) {
      uint256 depositAmount = IERC20(ausd).balanceOf(address(this));
      IZap(zap).add_liquidity(pool, [depositAmount, 0, 0, 0], 0);
      alpacaFarm.deposit(address(this), poolId, IERC20(ausd3eps).balanceOf(address(this)));
    }
  }

  // claims Alpaca reward token
  function _claimAlpaca() internal {
    alpacaFarm.harvest(poolId);

    uint256 positionId = IPositionManager(positionManager).ownerFirstPositionId(address(proxyWallet));
    address[] memory _tokenAdapters = new address[](1);
    uint256[] memory _positionIds = new uint256[](1);
    _tokenAdapters[0] = tokenAdapter;
    _positionIds[0] = positionId;
    bytes memory _data = abi.encodeWithSignature(
      "harvestMultiple(address,address[],uint256[],address)",
      positionManager,
      _tokenAdapters,
      _positionIds,
      alpacaToken
    );
    proxyWallet.execute(proxyActions, _data);
  }

  // sell harvested Alpaca token
  function _disposeAlpaca() internal {
    uint256 _alpaca = IERC20(alpacaToken).balanceOf(address(this));

    if (_alpaca > minAlpacaToSell) {

      uint256[] memory amounts = IUniswapV2Router02(uniswapRouter).getAmountsOut(_alpaca, path);
      uint256 estimatedWant = amounts[amounts.length - 1];
      uint256 conservativeWant = estimatedWant.mul(9).div(10);      // remaining 10% will be used for compensate offset

      IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(_alpaca, conservativeWant, path, address(this), now);
    }
  }

  function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _amountFreed, uint256 _loss) {
    uint256 balance = want.balanceOf(address(this));
    (uint256 collateral, , ) = _getCurrentPosition();
    uint256 assets = collateral.add(balance);

    uint256 debtOutstanding = vault.debtOutstanding(address(this));
    if (debtOutstanding > assets) {
      _loss = debtOutstanding - assets;
    }
    
    if (balance < _amountNeeded) {
      _withdrawSome(_amountNeeded.sub(balance));
      _amountFreed = _min(_amountNeeded, want.balanceOf(address(this)));
    } else {
      _amountFreed = _amountNeeded;
    }
  }

  /**
   * Do anything necessary to prepare this Strategy for migration, such as transferring any reserve.
   * This is used to migrate and withdraw assets from alpaca protocol under the ordinary condition.
   * Generally, `forceMigrate` is false so it forces to withdraw all assets from alpaca protocol and do migration.
   * but when facing issue with alpaca protocol so can't withdraw assets, then set forceMigrate true, so do migration without withdrawing assets from alpaca protocol
   */
  function prepareMigration(address _newStrategy) internal override {
    if (!forceMigrate) {
      alpacaFarm.withdrawAll(address(this), poolId);
      IZap(zap).remove_liquidity_one_coin(pool, IERC20(ausd3eps).balanceOf(address(this)), 0, 0);
      
      uint256 _alpacaBalance = IERC20(alpacaToken).balanceOf(address(this));
      if (_alpacaBalance > 0) {
        IERC20(alpacaToken).safeTransfer(_newStrategy, _alpacaBalance);
      }
    }
  }
  

  function _priceCheck(address start, address end, uint256 _amount) internal view returns (uint256) {
    if (_amount < minAlpacaToSell) {
      return 0;
    }

    address[] memory _path;
    if (start == wbnb) {
      _path = new address[](2);
      _path[0] = wbnb;
      _path[1] = end;
    } else {
      _path = new address[](3);
      _path[0] = start;
      _path[1] = wbnb;
      _path[2] = end;
    }

    uint256[] memory amounts = IUniswapV2Router02(uniswapRouter).getAmountsOut(_amount, _path);
    return amounts[amounts.length - 1];
  }

  function setProtectedTokens() internal override {
    protected[alpacaToken] = true;
  }

  function _min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

}