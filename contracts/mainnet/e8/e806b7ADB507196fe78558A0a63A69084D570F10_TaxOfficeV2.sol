/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IOracle

interface IOracle {
    function update() external;

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut);

    function twap(address _token, uint256 _amountIn) external view returns (uint144 _amountOut);
}

// Part: IUniswapV2Router

interface IUniswapV2Router {
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

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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

// Part: openzeppelin/[email protected]/Context

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
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

// Part: IERC20Taxable

interface IERC20Taxable is IERC20 {

    function taxOffice() external returns(address);

    function staticTaxRate() external returns(uint256);

    function dynamicTaxRate() external returns(uint256);
    
    function getCurrentTaxRate() external returns(uint256);

    function setTaxOffice(address _taxOffice) external; 

    function setStaticTaxRate(uint256 _taxRate) external;

    function setEnableDynamicTax(bool _enableDynamicTax) external;
    
    function setWhitelistType(address _token, uint8 _type) external;

    function isWhitelistedSender(address _account) external view returns(bool isWhitelisted);

    function isWhitelistedRecipient(address _account) external view returns(bool isWhitelisted);

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external;
    
}

// Part: openzeppelin/[email protected]/Ownable

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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

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

// Part: MultipleOperator

contract MultipleOperator is Context, Ownable {
    mapping(address => bool) private _operator;

    event OperatorStatusChanged(address indexed _operator, bool _operatorStatus);

    constructor() internal {
        _operator[_msgSender()] = true;
        emit OperatorStatusChanged(_msgSender(), true);
    }

    modifier onlyOperator() {
        require(_operator[msg.sender] == true, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _operator[_msgSender()];
    }

    function isOperator(address _account) public view returns (bool) {
        return _operator[_account];
    }

    function setOperatorStatus(address _account, bool _operatorStatus) public onlyOwner {
        _setOperatorStatus(_account, _operatorStatus);
    }

    function setOperatorStatus(address[] memory _accounts, bool _operatorStatus) external onlyOperator {
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            _setOperatorStatus(_accounts[idx], _operatorStatus);
        }
    }

    function setShareTokenWhitelistType(address[] memory _accounts, bool[] memory _operatorStatuses) external onlyOperator {
        require(_accounts.length == _operatorStatuses.length, "Error: Account and OperatorStatuses lengths not equal");
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            _setOperatorStatus(_accounts[idx], _operatorStatuses[idx]);
        }
    }

    function _setOperatorStatus(address _account, bool _operatorStatus) internal {
        _operator[_account] = _operatorStatus;
        emit OperatorStatusChanged(_account, _operatorStatus);
    }
}

// Part: TaxOffice

contract TaxOffice is MultipleOperator {
    using SafeMath for uint256;

    event HandledMainTokenTax(address indexed _origin, address indexed _account, uint256 _amount, uint256 _timestamp);
    event HandledShareTokenTax(address indexed _origin, address indexed _account, uint256 _amount, uint256 _timestamp);

    IERC20Taxable public mainToken;
    IERC20Taxable public shareToken;
    IOracle public mainTokenOracle;

    uint256 public constant BASIS_POINTS_DENOM = 10_000;

    uint256[] public mainTokenTaxTwapTiers = [
        0, 5e17, 6e17, 7e17, 8e17, 9e17, 9.5e17, 1e18, 1.05e18, 1.10e18, 1.20e18, 1.30e18, 1.40e18, 1.50e18
    ];
    uint256[] public mainTokenTaxRateTiers = [
        2000, 1900, 1800, 1700, 1600, 1500, 1500, 1500, 1500, 1400, 900, 400, 200, 100
    ];

    uint256[] public shareTokenTaxTwapTiers = [
        0, 5e17, 6e17, 7e17, 8e17, 9e17, 9.5e17, 1e18, 1.05e18, 1.10e18, 1.20e18, 1.30e18, 1.40e18, 1.50e18
    ];
    uint256[] public shareTokenTaxRateTiers = [
        2000, 1900, 1800, 1700, 1600, 1500, 1500, 1500, 1500, 1400, 900, 400, 200, 100
    ];

    mapping(address => mapping(address => uint256)) public taxDiscount;

    constructor(
        address _mainToken,
        address _shareToken,
        address _mainTokenOracle
    ) public {
        mainToken = IERC20Taxable(_mainToken);
        shareToken = IERC20Taxable(_shareToken);
        mainTokenOracle = IOracle(_mainTokenOracle);
    }

    /*
    Uses the oracle to fire the 'consult' method and get the price of tomb.
    */
    function _getMainTokenPrice() internal view returns (uint256) {
        try mainTokenOracle.consult(address(mainToken), 1e18) returns (uint144 _price) {
            return uint256(_price);
        } catch {
            revert("Erro: failed to fetch Main Token price from Oracle");
        }
    }

    function assertMonotonicity(uint256[] memory _monotonicArray) internal pure {
        uint8 endIdx = uint8(_monotonicArray.length.sub(1));
        for (uint8 idx = 0; idx <= endIdx; idx++) {
            if (idx > 0) {
                require(
                    _monotonicArray[idx] > _monotonicArray[idx - 1],
                    "Error: TWAP tiers sequence are not monotonic"
                );
            }
            if (idx < endIdx) {
                require(
                    _monotonicArray[idx] < _monotonicArray[idx + 1],
                    "Error: TWAP tiers sequence are not monotonic"
                );
            }
        }
    }

    function setMainTokenTaxTiers(
        uint256[] calldata _mainTokenTaxTwapTiers,
        uint256[] calldata _mainTokenTaxRateTiers
    ) external onlyOperator {
        require(
            _mainTokenTaxTwapTiers.length == _mainTokenTaxRateTiers.length,
            "Error: vector lengths are not the same."    
        );

        //Require monotonicity of TWAP tiers.
        assertMonotonicity(_mainTokenTaxTwapTiers);

        //Set values.
        mainTokenTaxTwapTiers = _mainTokenTaxTwapTiers;
        mainTokenTaxRateTiers = _mainTokenTaxRateTiers;
    }

    function setShareTokenTaxTiers(
        uint256[] calldata _shareTokenTaxTwapTiers,
        uint256[] calldata _shareTokenTaxRateTiers
    ) external onlyOperator {
        require(
            _shareTokenTaxTwapTiers.length == _shareTokenTaxRateTiers.length,
            "Error: vector lengths are not the same."    
        );

        //Require monotonicity of TWAP tiers.
        assertMonotonicity(_shareTokenTaxTwapTiers);

        //Set values.
        shareTokenTaxTwapTiers = _shareTokenTaxTwapTiers;
        shareTokenTaxRateTiers = _shareTokenTaxRateTiers;
    }

    function searchSorted(uint256[] memory _monotonicArray, uint256 _value) internal pure returns(uint8) {
        uint8 endIdx = uint8(_monotonicArray.length.sub(1));
        for (uint8 tierIdx = endIdx; tierIdx >= 0; --tierIdx) {
            if (_value >= _monotonicArray[tierIdx]) {
                return tierIdx;                
            }
        }
    }

    function calculateMainTokenTax() external view returns(uint256 taxRate){
        uint256 mainTokenPrice = _getMainTokenPrice();
        uint8 taxTierIdx = searchSorted(mainTokenTaxTwapTiers, mainTokenPrice);
        taxRate = mainTokenTaxRateTiers[taxTierIdx];
    }

    function calculateShareTokenTax() external view returns(uint256 taxRate){
        uint256 mainTokenPrice = _getMainTokenPrice();
        uint8 taxTierIdx = searchSorted(shareTokenTaxTwapTiers, mainTokenPrice);
        taxRate = shareTokenTaxRateTiers[taxTierIdx];
    }

    function withdraw(address _token, address _recipient, uint256 _amount) external onlyOperator {
        IERC20(_token).transfer(_recipient, _amount);
    }   

    function handleMainTokenTax(uint256 _amount) external virtual {
        emit HandledMainTokenTax(tx.origin, msg.sender, _amount, block.timestamp);
    }

    function handleShareTokenTax(uint256 _amount) external virtual{
        emit HandledShareTokenTax(tx.origin, msg.sender, _amount, block.timestamp);
    }

    /* ========== SET VARIABLES ========== */

    function setMainTokenStaticTaxRate(uint256 _taxRate) external onlyOperator {
        mainToken.setStaticTaxRate(_taxRate);
    }

    function setMainTokenEnableDynamicTax(bool _enableDynamicTax) external onlyOperator {
        mainToken.setEnableDynamicTax(_enableDynamicTax);
    }
    
    function setMainTokenWhitelistType(address _account, uint8 _type) external onlyOperator {
        mainToken.setWhitelistType(_account, _type);
    }

    function setMainTokenWhitelistType(address[] memory _accounts, uint8 _type) external onlyOperator {
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            mainToken.setWhitelistType(_accounts[idx], _type);
        }
    }

    function setMainTokenWhitelistType(address[] memory _accounts, uint8[] memory _types) external onlyOperator {
        require(_accounts.length == _types.length, "Error: Account and Types lengths not equal");
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            mainToken.setWhitelistType(_accounts[idx], _types[idx]);
        }
    }

    function setShareTokenStaticTaxRate(uint256 _taxRate) external onlyOperator {
        shareToken.setStaticTaxRate(_taxRate);
    }

    function setShareTokenEnableDynamicTax(bool _enableDynamicTax) external onlyOperator {
        shareToken.setEnableDynamicTax(_enableDynamicTax);
    }
    
    function setShareTokenWhitelistType(address _account, uint8 _type) external onlyOperator {
        shareToken.setWhitelistType(_account, _type);
    }

    function setShareTokenWhitelistType(address[] memory _accounts, uint8 _type) external onlyOperator {
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            shareToken.setWhitelistType(_accounts[idx], _type);
        }
    }

    function setShareTokenWhitelistType(address[] memory _accounts, uint8[] memory _types) external onlyOperator {
        require(_accounts.length == _types.length, "Error: Account and Types lengths not equal");
        for (uint8 idx = 0; idx < _accounts.length; ++idx) {
            shareToken.setWhitelistType(_accounts[idx], _types[idx]);
        }
    }

    function setTaxDiscount(address _sender, address _recipient, uint256 _amount) external onlyOwner {
        require(_amount <= BASIS_POINTS_DENOM, "Error: Discount rate too high.");
        taxDiscount[_sender][_recipient] = _amount;
    }

    function setMainTokenOracle(address _mainTokenOracle) external onlyOperator {
        require(_mainTokenOracle != address(0), "Error: Oracle address cannot be 0 address");
        mainTokenOracle = IOracle(_mainTokenOracle);
    }

}

// File: TaxOfficeV2.sol

contract TaxOfficeV2 is TaxOffice {
    using SafeERC20 for IERC20;

    address public router;
    address[] public shareToMainTokenSwapPath;

    constructor(
        address _mainToken,
        address _shareToken,
        address _mainTokenOracle,
        address _router,
        address[] memory _shareToMainTokenSwapPath
    ) public TaxOffice(_mainToken, _shareToken, _mainTokenOracle) {
        router = _router;
        shareToMainTokenSwapPath = _shareToMainTokenSwapPath;
    }

    function setShareToMainTokenSwapPath(
        address[] calldata _shareToMainTokenSwapPath
    ) external onlyOperator {
        shareToMainTokenSwapPath = _shareToMainTokenSwapPath;
    }

    function handleShareTokenTax(uint256 _amount) external override onlyOperator {
        //Check _amount of share token to be handled is available.
        uint256 tokenBalance = IERC20(shareToken).balanceOf(address(this));
        if (_amount > tokenBalance) { _amount = tokenBalance; }
        
        //Swap from share token to main token.
        IERC20(shareToken).safeIncreaseAllowance(router, _amount);
        IUniswapV2Router(router).swapExactTokensForTokens(
            _amount, 
            0, 
            shareToMainTokenSwapPath,
            address(this), 
            block.timestamp+40
        );

        //Emit event.
        emit HandledShareTokenTax(tx.origin, msg.sender, _amount, block.timestamp);
    }
}