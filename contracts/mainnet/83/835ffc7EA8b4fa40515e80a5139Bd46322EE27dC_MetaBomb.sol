/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

// SPDX-License-Identifier: GPL-3.0
// File: @openzeppelin/contracts/utils/math/SafeMath.sol



pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
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

// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity ^0.8.0;

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
        assembly {
            size := extcodesize(account)
        }
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/*
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

// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity ^0.8.0;


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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/interfaces/IFactory.sol



pragma solidity ^0.8.0;

interface IFactory
{
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
// File: contracts/interfaces/IRouter.sol



pragma solidity ^0.8.0;

interface IUniRouterV1
{
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

interface IUniRouterV2 is IUniRouterV1
{
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
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



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

// File: contracts/interfaces/IDividendDistributor.sol



pragma solidity 0.8.11;


interface IDividendDistributor
{
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address _shareholder, uint256 _amount) external;

    function claimDividend() external;
    function claimDividend(address _shareholder) external;

    function deposit() external payable;
    function process(uint256 _gas) external;

    function rewardToken() external returns (IERC20);
    function getUnpaidEarnings(address _shareholder) external returns (uint256);
}
// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol



pragma solidity ^0.8.0;



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

// File: contracts/interfaces/IDividendToken.sol



pragma solidity 0.8.11;


interface IDividendToken is IERC20
{
    function owner() external returns (address);
}
// File: contracts/DividendDistributor.sol



pragma solidity 0.8.11;








contract DividendDistributor is IDividendDistributor
{
    //========================
    // LIBS
    //========================

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //========================
    // STRUCTS
    //========================

    struct Share
    {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    //========================
    // ATTRIBUTES
    //========================
    
    //general
    IDividendToken public dividendToken;
    IUniRouterV2 public router;
    IERC20 public override rewardToken;
    uint256 public currentIndex;   
    
    //shareholders
    address[] private shareholders;
    mapping (address => uint256) private shareholderIndexes;
    mapping (address => uint256) private shareholderClaims;
    mapping (address => Share) public shares;    

    //shares
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    //settings
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 0.1 ether;    

    //========================
    // CREATE
    //========================

    constructor(
        IUniRouterV2 _router,
        IERC20 _rewardToken)
    {
        router = _router;
        rewardToken = _rewardToken;
        dividendToken = IDividendToken(msg.sender);
    }

    //========================
    // CONFIG FUNCTIONS
    //========================

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken
    {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    //========================
    // PROCESS & DEPOSIT FUNCTIONS
    //========================

    function deposit() external payable override
    {
        uint256 addedReward = msg.value;
        if (address(rewardToken) != address(0))
        {
            //make swap path
            address[] memory swapPath = new address[](2);
            swapPath[0] = router.WETH();
            swapPath[1] = address(rewardToken);

            //swap to reward token
            uint256 rewardBefore = rewardToken.balanceOf(address(this));
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(
                0,
                swapPath,
                address(this),
                block.timestamp);
            uint256 rewardAfter = rewardToken.balanceOf(address(this));
            addedReward = rewardAfter.sub(rewardBefore);
        }

        totalDividends = totalDividends.add(addedReward);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(addedReward).div(totalShares));
    }

    function manualProcess(uint256 _gas) external onlyOwner
    {
        _process(_gas);
    }

    function process(uint256 _gas) external override onlyToken
    {
        _process(_gas);
    }

    function _process(uint256 _gas) private
    {
        //check shareholders
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0)
        {
            return;
        }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        while (gasUsed < _gas
            && iterations < shareholderCount)
        {
            if (currentIndex >= shareholderCount)
            {
                //start at 0 again
                currentIndex = 0;
            }

            //distribute
            if (shouldDistribute(shareholders[currentIndex]))
            {
                distributeDividend(shareholders[currentIndex]);
            }

            //update gas / index
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    //========================
    // SHAREHOLDER FUNCTIONS
    //========================

    function setShare(address _shareholder, uint256 _amount) external override onlyToken
    {
        //distribute dividende
        if (shares[_shareholder].amount > 0)
        {
            distributeDividend(_shareholder);
        }

        //add / remove shareholder
        if (_amount > 0
            && shares[_shareholder].amount == 0)
        {
            addShareholder(_shareholder);
        }
        else if (_amount == 0
            && shares[_shareholder].amount > 0)
        {
            removeShareholder(_shareholder);
        }

        //updates shares
        totalShares = totalShares.sub(shares[_shareholder].amount).add(_amount);
        shares[_shareholder].amount = _amount;
        shares[_shareholder].totalExcluded = getCumulativeDividends(shares[_shareholder].amount);
    }    

    function addShareholder(address _shareholder) internal
    {
        shareholderIndexes[_shareholder] = shareholders.length;
        shareholders.push(_shareholder);
    }

    function removeShareholder(address _shareholder) internal
    {
        shareholders[shareholderIndexes[_shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[_shareholder];
        shareholders.pop();
    }

    //========================
    // DISTRIBUTE FUNCTIONS
    //========================
    
    function shouldDistribute(address _shareholder) internal view returns (bool)
    {
        return (shareholderClaims[_shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(_shareholder) > minDistribution);
    }

    function distributeDividend(address _shareholder) internal
    {
        //check shares
        if (shares[_shareholder].amount == 0)
        {
            return;
        }

        uint256 amount = getUnpaidEarnings(_shareholder);
        if (amount > 0)
        {
            totalDistributed = totalDistributed.add(amount);

            //distribute
            if (address(rewardToken) != address(0))
            {
                //token
                rewardToken.safeTransfer(_shareholder, amount);
            }
            else
            {
                //ETH
                (bool success, ) = payable(_shareholder).call{ value: amount, gas: 30000 }("");
                success = false;
            }

            //update
            shareholderClaims[_shareholder] = block.timestamp;
            shares[_shareholder].totalRealised = shares[_shareholder].totalRealised.add(amount);
            shares[_shareholder].totalExcluded = getCumulativeDividends(shares[_shareholder].amount);
        }
    }
    
    function claimDividend() external override
    {
        claimDividend(msg.sender);
    }

    function claimDividend(address _shareholder) public override
    {
        require(shouldDistribute(_shareholder), "Too soon. Need to wait!");
        distributeDividend(_shareholder);
    }

    function getUnpaidEarnings(address _shareholder) public override view returns (uint256)
    {
        if (shares[_shareholder].amount == 0)
        {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[_shareholder].amount);
        uint256 shareholderTotalExcluded = shares[_shareholder].totalExcluded;
        if (shareholderTotalDividends <= shareholderTotalExcluded)
        {
            return 0;
        }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 _share) internal view returns (uint256)
    {
        return _share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    //========================
    // MODIFIERS
    //========================

    modifier onlyOwner()
    {
        require(dividendToken.owner() == msg.sender, "Caller is not owner");
        _;
    }

    modifier onlyToken()
    {
        require(msg.sender == address(dividendToken));
        _;
    }
}
// File: contracts/DividendToken.sol



pragma solidity 0.8.11;









contract DividendToken is IDividendToken, Ownable
{
    //========================
    // LIBS
    //========================

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //========================
    // STRUCT
    //========================

    struct FeeInfo
    {
        uint256 liquidityFee;
        uint256 rewardFee;
        uint256 marketingFee;
        uint256 teamFee;
    }

    //========================
    // CONSTANTS
    //========================
    
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;    
    uint256 private constant FEE_DENOMINATOR = 10000;
    uint256 private constant MAX_FEE = 2000;
    uint256 private constant ANTI_SNIPER_DURATION = 10 minutes;

    //========================
    // ATTRIBUTES
    //========================

    //ERC20
    string _name;
    string _symbol;
    uint8 immutable _decimals;
    uint256 _totalSupply;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    //limits
    uint256 public _maxTxAmount;
    uint256 public _walletMax;    
    bool public restrictWhales = false;

    //exempt
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isBlacklisted;

    //fees
    FeeInfo public buyFee;
    FeeInfo public sellFee;
    FeeInfo public p2pFee;
    FeeInfo public feeBalance;

    //wallets
    address public autoLiquidityReceiver;
    address public marketingWallet;
    address public teamWallet;    

    //vested liquidity
    uint256 public vestedUntil;
    uint256 public vestingPeriod;   

    //router + pair
    IUniRouterV2 public router;
    address public pair;

    //dividend distributor
    DividendDistributor public immutable dividendDistributor;
    uint256 distributorGas = 500000;

    //settings
    uint256 public launchedAt;
    bool public tradingOpen;    

    //liquify
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly;
    uint256 public swapTokensAtHigh; //liquify trigger high
    uint256 public swapTokensAtLow; //liquify trigger high

    //misc
    uint256 private nonce;

    //========================
    // EVENTS
    //========================

    event AutoLiquify(uint256 amountETH, uint256 amountBOG);

    //========================
    // CREATE
    //========================

    constructor(
        address _router,
        address _rewardToken,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals,
        uint256 _tokenTotalSupply,
        address _owner)
    {   
        //ERC20 (change)
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _decimals = _tokenDecimals;
        _totalSupply = _tokenTotalSupply; 

        //limits (change)        
        swapTokensAtHigh = _totalSupply.mul(1).div(1000);
        swapTokensAtLow = swapTokensAtHigh.mul(200).div(1000);
        _maxTxAmount = _totalSupply.mul(10).div(100); 
        _walletMax = _totalSupply.mul(10).div(100);    

        //vesting (change)
        vestingPeriod = 90 days;
        vestedUntil = block.timestamp + vestingPeriod;

        //router + pair + dividende distributor
        router = IUniRouterV2(_router);
        pair = IFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        dividendDistributor = new DividendDistributor(router, IERC20(_rewardToken));

        //exempt fee
        isFeeExempt[_owner] = true;
        isFeeExempt[address(this)] = true;

        //exempt tx limit
        isTxLimitExempt[_owner] = true;
        isTxLimitExempt[pair] = true;

        //exempt dividend
        isDividendExempt[pair] = true;
        isDividendExempt[_owner] = true;        
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[marketingWallet] = true;
        isDividendExempt[teamWallet] = true;       

        //set owner and send initial supply to owner
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    function owner() public view override(Ownable, IDividendToken) returns (address)
    {
        return Ownable.owner();
    }

    //========================
    // CONFIG FUNCTIONS
    //========================

    function setTxLimit(uint256 _limit) public onlyOwner
    {
        _maxTxAmount = _limit;
    }

    function setWalletLimit(uint256 _limit) public onlyOwner
    {
        _walletMax  = _limit;
    }

    function setRestrictWhales(bool _value) public onlyOwner
    {
       restrictWhales = _value;
    }
    
    function setIsFeeExempt(address _holder, bool _exempt) public onlyOwner
    {
        isFeeExempt[_holder] = _exempt;
    }

    function setIsTxLimitExempt(address _holder, bool _exempt) public onlyOwner
    {
        isTxLimitExempt[_holder] = _exempt;
    }

    function setIsBlacklisted(address _holder, bool _blacklisted) public onlyOwner
    {
        require(
            (_holder != DEAD
                && _holder != ZERO
                && _holder != address(this)
                && _holder != address(router)
                && _holder != address(pair))
            , "Invalid Holder");
        isBlacklisted[_holder] = _blacklisted;
    }

    function setIsDividendExempt(address _holder, bool _exempt) public onlyOwner
    {
        require(_holder != address(this) && _holder != pair, "Invalid Holder");

        //set
        isDividendExempt[_holder] = _exempt;
        
        //set share
        if (_exempt)
        {
            dividendDistributor.setShare(_holder, 0);
        }
        else
        {
            dividendDistributor.setShare(_holder, _balances[_holder]);
        }
    }

    function setSwapTokensAtAmount(uint256 _low, uint256 _high) public onlyOwner
    {
        require(_high > _low, "High must be more than low");
        swapTokensAtLow = _low;
        swapTokensAtHigh = _high;
    }

    function setLiquidityFee(int8 _feeType, uint256 _fee) external onlyOwner
    {
        FeeInfo memory fees = getFee(_feeType);
        _setFees(_feeType, _fee, fees.rewardFee, fees.teamFee, fees.marketingFee);
    }   

    function setRewardFee(int8 _feeType, uint256 _fee) external onlyOwner
    {
        FeeInfo memory fees = getFee(_feeType);
        _setFees(_feeType, fees.liquidityFee, _fee, fees.teamFee, fees.marketingFee);
    }    

    function setTeamFee(int8 _feeType, uint256 _fee) external onlyOwner
    {
        FeeInfo memory fees = getFee(_feeType);
        _setFees(_feeType, fees.liquidityFee, fees.liquidityFee, _fee, fees.marketingFee);
    }    

    function setMarketingFee(int8 _feeType, uint256 _fee) external onlyOwner
    {
        FeeInfo memory fees = getFee(_feeType);
        _setFees(_feeType, fees.liquidityFee, fees.liquidityFee, fees.teamFee, _fee);
    }    

    function setFees(int8 _feeType, uint256 _liquidityFee, uint256 _rewardFee, uint256 _teamFee, uint256 _marketingFee) public onlyOwner
    {
        _setFees(_feeType, _liquidityFee, _rewardFee, _teamFee, _marketingFee);
    }    

    function setFeeReceivers(address _liquidityReceiver, address _marketingWallet, address _teamWallet) public onlyOwner
    {
        autoLiquidityReceiver = _liquidityReceiver;
        marketingWallet = _marketingWallet;
        teamWallet = _teamWallet;
    }

    function setSwapBackSettings(bool _enableSwapBack, bool _swapByLimitOnly) public onlyOwner
    {
        swapAndLiquifyEnabled  = _enableSwapBack;
        swapAndLiquifyByLimitOnly = _swapByLimitOnly;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) public onlyOwner
    {
        dividendDistributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 _gas) public onlyOwner
    {
        require(_gas < 750000, "Gas to high");
        distributorGas = _gas;
    }        

    function setTradingStatus(bool _status) public onlyOwner
    {
        tradingOpen = _status;
    }

    //========================
    // INFO FUNCTIONS
    //========================

    function claimDividend() external
    {
        dividendDistributor.claimDividend(msg.sender);
    }

    function getUnpaidEarnings(address _shareholder) external view returns (uint256)
    {
        return dividendDistributor.getUnpaidEarnings(_shareholder);
    }

    //========================
    // FEE FUNCTIONS
    //========================

    function _setFees(int8 _feeType, uint256 _liquidityFee, uint256 _rewardFee, uint256 _teamFee, uint256 _marketingFee) private
    {
        if (_feeType < 0)
        {
            //sell
            sellFee.liquidityFee    = _liquidityFee;
            sellFee.rewardFee       = _rewardFee;
            sellFee.teamFee         = _teamFee;
            sellFee.marketingFee    = _marketingFee;
        }
        else if (_feeType > 0)
        {
            //buy
            buyFee.liquidityFee     = _liquidityFee;
            buyFee.rewardFee        = _rewardFee;
            buyFee.teamFee          = _teamFee;
            buyFee.marketingFee     = _marketingFee;
        }
        else
        {
            //p2p
            p2pFee.liquidityFee     = _liquidityFee;
            p2pFee.rewardFee        = _rewardFee;
            p2pFee.teamFee          = _teamFee;
            p2pFee.marketingFee     = _marketingFee;
        }        

        //check
        require(getTotalFee(getFee(_feeType)) <= MAX_FEE, "Fees to high");
    }

    function getFee(int8 _feeType) private view returns (FeeInfo memory)
    {
        if (_feeType < 0)
        {
            return sellFee;
        }
        else if (_feeType > 0)
        {
            return buyFee;
        }

        return p2pFee;
    }

    function getFeeBalanceShares(uint256 _amount, uint256 _total) private view returns (FeeInfo memory)
    {
        return FeeInfo(
        {
            liquidityFee: feeBalance.liquidityFee.mul(_amount).div(_total),
            rewardFee: feeBalance.rewardFee.mul(_amount).div(_total),
            marketingFee: feeBalance.marketingFee.mul(_amount).div(_total),
            teamFee: feeBalance.teamFee.mul(_amount).div(_total)
        });
    }

    function getTotalFee(FeeInfo memory _fee) private pure returns (uint256)
    {
        return _fee.liquidityFee
            .add(_fee.rewardFee)
            .add(_fee.teamFee)
            .add(_fee.marketingFee);
    }

    function getDynamicFee(address _from, address _to) private view returns (FeeInfo memory)
    {
        bool useAntiSniperFee;
        FeeInfo memory fee;
        if (_from == pair)
        {
            //buy
            fee = getFee(1);
            useAntiSniperFee = true;
        }
        else if (_to == pair)
        {
            //sell
            fee = getFee(-1);
            useAntiSniperFee = true;
        }
        else
        {
            //p2p
            fee = getFee(0);
        }

        if (useAntiSniperFee)
        {           
            //anti sniper fee
            uint256 endingTime = launchedAt.add(ANTI_SNIPER_DURATION);
            if (endingTime > block.timestamp)
            {
                uint256 remainingTime = endingTime.sub(block.timestamp);     
                uint256 totalFeeWithtoutMarketing = getTotalFee(fee).sub(fee.marketingFee);
                fee = FeeInfo(
                {
                    marketingFee: fee.marketingFee
                        .add(
                            uint256(9900)
                                .sub(totalFeeWithtoutMarketing)
                                .mul(remainingTime)
                                .div(ANTI_SNIPER_DURATION)),
                    teamFee: fee.teamFee,
                    rewardFee: fee.rewardFee,
                    liquidityFee: fee.liquidityFee
                });
            }
        }

        return fee;
    }

    function takeFee(address _from, address _to, uint256 _amount) private returns (uint256)
    {   
        if (isFeeExempt[_from]
            || isFeeExempt[_to])
        {
            return _amount;
        }

        FeeInfo memory fee = getDynamicFee(_from, _to);
        uint256 totalFee = getTotalFee(fee);
        uint256 feeAmount = _amount.mul(totalFee).div(FEE_DENOMINATOR);

        //transfer
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(_from, address(this), feeAmount);

        //get fee shares
        uint256 marketingShare = feeAmount.mul(fee.marketingFee).div(totalFee);
        uint256 teamShare = feeAmount.mul(fee.teamFee).div(totalFee);
        uint256 rewardShare = feeAmount.mul(fee.rewardFee).div(totalFee);
        uint256 liquidityShare = feeAmount.sub(marketingShare).sub(teamShare).sub(rewardShare);

        //adjust fee balances
        feeBalance.marketingFee = feeBalance.marketingFee.add(marketingShare);
        feeBalance.teamFee = feeBalance.teamFee.add(teamShare);
        feeBalance.rewardFee = feeBalance.rewardFee.add(rewardShare);
        feeBalance.liquidityFee = feeBalance.liquidityFee.add(liquidityShare);

        return _amount.sub(feeAmount);
    }

    //========================
    // SWAP FUNCTIONS
    //========================    

    receive() external payable {}

    function getSwapAmount() private returns (uint256)
    {
        if (!swapAndLiquifyByLimitOnly)
        {
            return _balances[address(this)];
        }
        uint256 pr = uint256(keccak256(abi.encodePacked(tx.origin, block.timestamp, nonce++)));
        return swapTokensAtLow.add(pr.mod(swapTokensAtHigh.sub(swapTokensAtLow)));
    }

    function manualSwapBack(uint256 _amount) external onlyOwner
    {
        swapBack(_amount);
    }

    function swapBack() private
    {        
        uint256 tokensToLiquify = getSwapAmount();
        swapBack(tokensToLiquify);
    }

    function swapBack(uint256 _amount) private lockTheSwap
    {
        require(_amount <= _balances[address(this)], "Insufficient balance for swap");
        FeeInfo memory swapAmounts = getFeeBalanceShares(_amount, _balances[address(this)]);
        uint256 amountToLiquify = swapAmounts.liquidityFee.div(2);
        uint256 amountToSwap = _amount.sub(amountToLiquify);

        //make swap path from token to ETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        //swap to ETH
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        //reduce fee balances
        feeBalance.liquidityFee = feeBalance.liquidityFee.sub(swapAmounts.liquidityFee);
        feeBalance.rewardFee = feeBalance.rewardFee.sub(swapAmounts.rewardFee);
        feeBalance.teamFee = feeBalance.teamFee.sub(swapAmounts.teamFee);
        feeBalance.marketingFee = feeBalance.marketingFee.sub(swapAmounts.marketingFee);

        //swap
        swapBackFees(swapAmounts, amountToLiquify);        
    }

    function swapBackFees(FeeInfo memory _swapAmounts, uint256 _tokensToLiquify) private
    {
        //get shares
        _swapAmounts.liquidityFee = _swapAmounts.liquidityFee.sub(_tokensToLiquify);
        uint256 totalAmount = getTotalFee(_swapAmounts);

        //calcute payout shares
        uint256 amountETH = address(this).balance;           
        uint256 amountETHReward = amountETH.mul(_swapAmounts.rewardFee).div(totalAmount);           
        uint256 amountETHTeam = amountETH.mul(_swapAmounts.teamFee).div(totalAmount);     
        uint256 amountETHMarketing = amountETH.mul(_swapAmounts.marketingFee).div(totalAmount);
        uint256 amountETHLiquidity = amountETH.sub(amountETHReward).sub(amountETHTeam).sub(amountETHMarketing);

        //distribute to wallets       
        bool success;
        if (amountETHMarketing > 0)
        {
            (success, ) = payable(marketingWallet).call{ value: amountETHMarketing, gas: 30000 }("");
        }
        if (amountETHTeam > 0)
        {
            (success, ) = payable(teamWallet).call{ value: amountETHTeam, gas: 30000 }("");
        }        
        success; //to prevent warning

        //add liquidity
        if (_tokensToLiquify > 0
            && amountETHLiquidity > 0)
        {
            router.addLiquidityETH{ value: amountETHLiquidity }(
                address(this),
                _tokensToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, _tokensToLiquify);
        }

        //dividends
        if (address(this).balance > 0)
        {
            try dividendDistributor.deposit{ value: amountETHReward }() {} catch {}
        }
    }

    //========================
    // ERC20 FUNCTIONS
    //========================

    function name() external view returns (string memory)
    {
        return _name;
    }

    function symbol() external view returns (string memory)
    {
        return _symbol;    
    }

    function decimals() external view returns (uint8)
    {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256)
    {
        return _totalSupply;
    }

    function getCirculatingSupply() public view returns (uint256)
    {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function balanceOf(address _account) public view override returns (uint256)
    {
        return _balances[_account];
    }

    function allowance(address _holder, address _spender) external view override returns (uint256)
    {
        return _allowances[_holder][_spender];
    }

    function approve(address _spender, uint256 _amount) public override returns (bool)
    {
        _allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function approveMax(address _spender) external returns (bool)
    {
        return approve(_spender, type(uint256).max);
    }

    //========================
    // TRANSFER FUNCTIONS
    //========================    
    
    function transfer(address _recipient, uint256 _amount) external override returns (bool)
    {
        return _transferFrom(msg.sender, _recipient, _amount);
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) external override returns (bool)
    {        
        if (_allowances[_sender][msg.sender] != type(uint256).max)
        {
            _allowances[_sender][msg.sender] = _allowances[_sender][msg.sender].sub(_amount, "Insufficient Allowance");
        }
        return _transferFrom(_sender, _recipient, _amount);
    }

    function _transferFrom(address _sender, address _recipient, uint256 _amount) internal returns (bool)
    {
        require(!isBlacklisted[_sender], "Sender is blacklisted");
        require(!isBlacklisted[_recipient], "Recipient is blacklisted");

        //check if in liquify
        if (inSwapAndLiquify)
        {
            return _basicTransfer(_sender, _recipient, _amount);
        }

        //check
        if (_sender != owner()
            && _recipient != owner())
        {
            require(tradingOpen, "Trading not open yet");
        }
        require(_amount <= _maxTxAmount || isTxLimitExempt[_sender], "TX Limit Exceeded");

        //swap & liquify
        if (msg.sender != pair
            && !inSwapAndLiquify
            && swapAndLiquifyEnabled
            && _balances[address(this)] >= swapTokensAtHigh)
        {
            swapBack();
        }

        //check if launched
        if (!launched()
            && _recipient == pair)
        {
            require(_balances[_sender] > 0);
            launch();
        }

        //exchange tokens
        _balances[_sender] = _balances[_sender].sub(_amount, "Insufficient Balance");                
        uint256 finalAmount = takeFee(_sender, _recipient, _amount);        
        if (!isTxLimitExempt[_recipient]
            && restrictWhales)
        {
            require(_balances[_recipient].add(finalAmount) <= _walletMax, "Wallet is at whale limit");
        }
        _balances[_recipient] = _balances[_recipient].add(finalAmount);

        //track dividends & process
        if (!isDividendExempt[_sender])
        {
            try dividendDistributor.setShare(_sender, _balances[_sender]) {} catch {}
        }
        if (!isDividendExempt[_recipient])
        {
            try dividendDistributor.setShare(_recipient, _balances[_recipient]) {} catch {} 
        }
        try dividendDistributor.process(distributorGas) {} catch {}

        //event
        emit Transfer(_sender, _recipient, finalAmount);
        return true;
    }
    
    function _basicTransfer(address _sender, address _recipient, uint256 _amount) internal returns (bool)
    {
        _balances[_sender] = _balances[_sender].sub(_amount, "Insufficient Balance");
        _balances[_recipient] = _balances[_recipient].add(_amount);
        emit Transfer(_sender, _recipient, _amount);
        return true;
    }

    //========================
    // MODIFIERS
    //========================

    modifier lockTheSwap
    {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    //========================
    // HELPER FUNCTIONS
    //========================
    
    function launched() internal view returns (bool)
    {
        return (launchedAt != 0);
    }

    function launch() internal
    {
        launchedAt = block.timestamp;        
        tradingOpen = true;
    }
    
    //========================
    // VESTING FUNCTIONS
    //======================== 

    function withdrawVestedLiquidity() external onlyOwner
    {
        require(block.timestamp >= vestedUntil, "Liquidity still locked");
        IERC20(pair).safeTransfer(msg.sender, IERC20(pair).balanceOf(address(this)));
    }

    function increaseVesting() external onlyOwner
    {
        vestedUntil += vestingPeriod;
    }

    //========================
    // EMERGENCY FUNCTIONS
    //======================== 

    function adminEmergencyWithdrawETH() external onlyOwner
    {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(msg.sender).call{ value: balance, gas: 30000 }("");
        success; //prevent warning
    }

    function adminEmergencyWithdrawToken(IERC20 _token) external onlyOwner
    {
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(msg.sender, balance);
    }   
}
// File: contracts/interfaces/IToken.sol



pragma solidity 0.8.11;


interface IToken is IERC20
{
	function decimals() external view returns (uint8);	
	function symbol() external view returns (string memory);
	function name() external view returns (string memory);
}
// File: contracts/Customers/MetaBomb.sol



pragma solidity 0.8.11;




contract MetaBomb is DividendToken
{
    constructor()
    DividendToken(
        0x10ED43C718714eb63d5aA57B78B54704E256024E, //PCS router
        0x55d398326f99059fF775485246999027B3197955, //USDT reward
        "Meta Bomb",
        "MBOMB",
        18,
        (10 ** 6) * 1 ether,
        0xEed86AB9A43288d9300B748B9e30A8890ADAaC25 //owner
    )
    {
        //fees & wallet
        setFees(
            1, //buy
            200, //liquidity
            500, //reward
            100, //marketing
            200 //team
        );
        setFees(
            -1, //sell
            200, //liquidity
            500, //reward
            100, //marketing
            200 //team
        );
        setFeeReceivers(
            0xEed86AB9A43288d9300B748B9e30A8890ADAaC25, //auto liquidity
            0xAD98652013784B7Ee3CEa8F80EFd7Aa95Ca7166d, //marketing
            0xf941051A81D4203Cf34cB43D2D18C2c113937c49 //team
        );

        //dividends
        setDistributionCriteria(
            24 hours,
            (10 ** IToken(address(dividendDistributor.rewardToken())).decimals()) * 5 / 10000 //50 cent
        );

        vestingPeriod = 0;
        setSwapBackSettings(true, true);
    }
}