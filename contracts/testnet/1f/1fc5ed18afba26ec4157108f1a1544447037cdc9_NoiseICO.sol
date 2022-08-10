/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

    constructor () {
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

pragma solidity ^0.7.0;

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
        assembly { codehash := extcodehash(account) }
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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;
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
    constructor () {
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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    constructor (IERC20 token, address beneficiary, uint256 releaseTime) {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        _token.safeTransfer(_beneficiary, amount);
    }
}

pragma solidity ^0.7.3;

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

pragma solidity ^0.7.3;

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

pragma solidity ^0.7.3;


contract NoiseICO is Context, ReentrancyGuard, Ownable {
    using SafeMath for uint;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //===============================================//
    //          Contract Variables: Mainnet          //
    //===============================================//

    uint256 public MIN_CONTRIBUTION = 0.5 ether;
    uint256 public MAX_CONTRIBUTION = 10 ether;

    uint256 public HARD_CAP = 500 ether;

    uint256 constant NOISE_PER_BNB_ICO = 10000;
    uint256 constant NOISE_PER_BNB_LIST = 9500;

    uint256 public LP_BNB = 450 ether;
    uint256 public LP_NOISE;

    uint256 public constant UNLOCK_PERCENT_PRESALE_INITIAL = 50; //For presale buyers instant release
    uint256 public constant UNLOCK_PERCENT_PRESALE_SECOND = 30; //For presale buyers after 30 days
    uint256 public constant UNLOCK_PERCENT_PRESALE_FINAL = 20; //For presale buyers after 60 days

    uint256 public DURATION_REFUND = 120 days;
    uint256 public DURATION_LIQUIDITY_LOCK = 1095 days;

    uint256 public DURATION_TOKEN_DISTRIBUTION_ROUND_2 = 30 days;
    uint256 public DURATION_TOKEN_DISTRIBUTION_ROUND_3 = 60 days;    

    address NOISE_TOKEN_ADDRESS = 0x482859FbeA10246292e0061fbed9E39C3ef2e826; //NOISE Token address

    IUniswapV2Router02 constant PANCAKESWAP_V2_ADDRESS =  IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    IUniswapV2Factory constant pancakeswapFactory = IUniswapV2Factory(0x6725F303b657a9451d8BA641348b6761A6CC7a17); 


    //General variables

    IERC20 public NOISE_ERC20; //NOISE token address

    address public ERC20_pancakeswapV2Pair; //Pancakeswap Pair address

    TokenTimelock public LPTimeLock;

    
    uint256 public tokensBought; //Total tokens bought
    uint256 public tokensWithdrawn;  //Total tokens withdrawn by buyers

    bool public isStopped = false;
    bool public icoStarted = false;
    bool public pancakeswapPairCreated = false;
    bool public liquidityLocked = false;
    bool public bulkRefunded = false;

    bool public isNoiseDistributedR1 = false;
    bool public isNoiseDistributedR2 = false;
    bool public isNoiseDistributedR3 = false;



    uint256 public roundTwoUnlockTime; 
    uint256 public roundThreeUnlockTime; 
    
    bool liquidityAdded = false;

    address payable contract_owner;
    
    
    uint256 public liquidityUnlockTime;
    
    uint256 public bnbSent; //BNB Received
    
    uint256 public lockedLiquidityAmount;
    uint256 public refundTime; 

    mapping(address => uint) bnbSpent;
    mapping(address => uint) noiseBought;
    mapping(address => uint) noiseHolding;
    address[] public contributors;

    

    constructor() {
        contract_owner = _msgSender();
        LP_NOISE = LP_BNB.mul(NOISE_PER_BNB_LIST);
        NOISE_ERC20 = IERC20(NOISE_TOKEN_ADDRESS);
    }


    //@done
    receive() external payable {   
        buyTokens();
    }
    


    //@done
    function allowRefunds() external onlyOwner nonReentrant {

        isStopped = true;
    }

    //@done
    function buyTokens() public payable nonReentrant {
        require(_msgSender() == tx.origin);
        require(icoStarted == true, "ICO is paused");
        require(msg.value >= MIN_CONTRIBUTION, "Less than 0.5 BNB");
        require(msg.value <= MAX_CONTRIBUTION, "More than 10 BNB");
        require(bnbSent < HARD_CAP, "Hardcap reached");        
        require(msg.value.add(bnbSent) <= HARD_CAP, "Hardcap will reached");
        require(bnbSpent[_msgSender()].add(msg.value) <= MAX_CONTRIBUTION, "> 10 BNB");

        require(!isStopped, "ICO stopped"); //@todo

        
        uint256 tokens = msg.value.mul(NOISE_PER_BNB_ICO);
        require(NOISE_ERC20.balanceOf(address(this)) >= tokens, "Not enough tokens"); //@tod

        if(bnbSpent[_msgSender()] == 0) {
            contributors.push(_msgSender()); //Create list of contributors    
        }
        
        bnbSpent[_msgSender()] = bnbSpent[_msgSender()].add(msg.value);

        tokensBought = tokensBought.add(tokens);
        bnbSent = bnbSent.add(msg.value);

        noiseBought[_msgSender()] = noiseBought[_msgSender()].add(tokens); //Add noise bought by contributor

        noiseHolding[_msgSender()] = noiseHolding[_msgSender()].add(tokens); //Add noise Holding by contributor

    }

    //@done, create pair first. 
    function createPancakeSwapPair() external onlyOwner {
        require(!liquidityAdded, "liquidity Already added");
        require(!pancakeswapPairCreated, "Already Created PancakeSwap Pair");

        ERC20_pancakeswapV2Pair = pancakeswapFactory.createPair(address(NOISE_ERC20), PANCAKESWAP_V2_ADDRESS.WETH());

        pancakeswapPairCreated = true;
    }


   
    //@done
    function addLiquidity() external onlyOwner {
        require(!liquidityAdded, "liquidity Already added");
        require(bnbSent >= HARD_CAP, "Hard cap not reached");   
        require(pancakeswapPairCreated, "Pancakeswap pair not created");


        NOISE_ERC20.approve(address(PANCAKESWAP_V2_ADDRESS), LP_NOISE);
        
        PANCAKESWAP_V2_ADDRESS.addLiquidityETH{ value: LP_BNB } (
            address(NOISE_ERC20),
            LP_NOISE,
            LP_NOISE,
            LP_BNB,
            address(contract_owner),
            block.timestamp
        );
       
        liquidityAdded = true;
       
        if(!isStopped)
            isStopped = true;

        //Set duration for NOISE distribution 
        roundTwoUnlockTime = block.timestamp.add(DURATION_TOKEN_DISTRIBUTION_ROUND_2); 
        roundThreeUnlockTime = block.timestamp.add(DURATION_TOKEN_DISTRIBUTION_ROUND_3); 
    }

    //Lock the liquidity 
    function lockLiquidity() external onlyOwner {
        require(liquidityAdded, "Add Liquidity");
        require(!liquidityLocked, "Already Locked");
        //Lock the Liquidity 
        IERC20 liquidityTokens = IERC20(ERC20_pancakeswapV2Pair); //Get the BNB LP token
        if(liquidityUnlockTime <= block.timestamp) {
            liquidityUnlockTime = block.timestamp.add(DURATION_LIQUIDITY_LOCK);
        }
        LPTimeLock = new TokenTimelock(liquidityTokens, contract_owner, liquidityUnlockTime);
        liquidityLocked = true;
        lockedLiquidityAmount = liquidityTokens.balanceOf(contract_owner);
    }
    
    //Unlock it after 1 year
    function unlockLiquidity() external onlyOwner  {      
        LPTimeLock.release();
    }

    //Check when Pancakeswap V2 tokens are unlocked
    function unlockLiquidityTime() external view returns(uint256) {      
        return LPTimeLock.releaseTime();
    }
    
    //@done distribute first round of tokens
    function distributeTokensRoundOne() external onlyOwner {
        require(liquidityAdded, "Add BNB Liquidity");        
        require(!isNoiseDistributedR1, "Round 1 done");
        for (uint i=0; i<contributors.length; i++) {          
            if(noiseHolding[contributors[i]] > 0) {
                uint256 tokenAmount_ = noiseBought[contributors[i]];
                tokenAmount_ = tokenAmount_.mul(UNLOCK_PERCENT_PRESALE_INITIAL).div(100);
                noiseHolding[contributors[i]] = noiseHolding[contributors[i]].sub(tokenAmount_);
                // Transfer the $NOISE to the beneficiary
                NOISE_ERC20.safeTransfer(contributors[i], tokenAmount_);
                tokensWithdrawn = tokensWithdrawn.add(tokenAmount_);
            }
        }
        isNoiseDistributedR1 = true;
    }

    //Let any one call next 30% of distribution
    //@done
    function distributeTokensRoundTwo() external nonReentrant{
        require(liquidityAdded, "Add BNB Liquidity"); 
        require(isNoiseDistributedR1, "Do Round 1");
        require(block.timestamp >= roundTwoUnlockTime, "Timelocked");
        require(!isNoiseDistributedR2, "Round 2 done");

        for (uint i=0; i<contributors.length; i++) {
            if(noiseHolding[contributors[i]] > 0) {
                uint256 tokenAmount_ = noiseBought[contributors[i]];
                tokenAmount_ = tokenAmount_.mul(UNLOCK_PERCENT_PRESALE_SECOND).div(100);
                noiseHolding[contributors[i]] = noiseHolding[contributors[i]].sub(tokenAmount_);
                // Transfer the $NOISE to the beneficiary
                NOISE_ERC20.safeTransfer(contributors[i], tokenAmount_);
                tokensWithdrawn = tokensWithdrawn.add(tokenAmount_);
            }
        }
        isNoiseDistributedR2 = true;
    }

    //Let any one call final 20% of distribution
    //@done
    function distributeTokensRoundThree() external nonReentrant{
        require(liquidityAdded, "Add BNB Liquidity"); 
        require(isNoiseDistributedR2, "Do Round 2");
        require(block.timestamp >= roundThreeUnlockTime, "Timelocked");
        require(!isNoiseDistributedR3, "Round 3 done");

        for (uint i=0; i<contributors.length; i++) {
            if(noiseHolding[contributors[i]] > 0) {
                uint256 tokenAmount_ = noiseBought[contributors[i]];
                tokenAmount_ = tokenAmount_.mul(UNLOCK_PERCENT_PRESALE_FINAL).div(100);
                noiseHolding[contributors[i]] = noiseHolding[contributors[i]].sub(tokenAmount_);
                // Transfer the $NOISE to the beneficiary
                NOISE_ERC20.safeTransfer(contributors[i], tokenAmount_);
                tokensWithdrawn = tokensWithdrawn.add(tokenAmount_);
            }
        }
        isNoiseDistributedR3 = true;
    }
    


    //@done
    //Withdraw the collected remaining BNB
    function withdrawBNB(uint amount) external onlyOwner returns(bool){
        require(liquidityAdded,"After BNB LP");        
        require(amount <= address(this).balance);
        contract_owner.transfer(amount);
        return true;
    }    

    //@done
    //Allow admin to withdraw any pending NOISE after everyone withdraw, 60 days
    function withdrawNoise(uint amount) external onlyOwner returns(bool){
        require(liquidityAdded,"After BNB LP");
        require(isNoiseDistributedR3, "After distribute to buyers");
        NOISE_ERC20.safeTransfer(_msgSender(), amount);
        return true;
    }

    //@done
    function userNoiseBalance(address user) external view returns (uint256) {
        return noiseHolding[user];
    }

    //@done
    function userNoiseBought(address user) external view returns (uint256) {
        return noiseBought[user];
    }

    //@done
    function userBNBContribution(address user) external view returns (uint256) {
        return bnbSpent[user];
    }    

    //@done
    function getRefund() external nonReentrant {
        require(_msgSender() == tx.origin);
        require(isStopped, "Should be stopped");
        require(!liquidityAdded);
        // To get refund it not reached hard cap and 30 days had passed 
        require(bnbSent < HARD_CAP && block.timestamp >= refundTime, "Cannot refund");
        uint256 amount = bnbSpent[_msgSender()];
        require(amount > 0, "No BNB");
        address payable user = _msgSender();
        
        bnbSpent[user] = 0;
        noiseBought[user] = 0;
        noiseHolding[user] = 0;
        user.transfer(amount);
    }

    //@done let anyone call it
    function bulkRefund() external nonReentrant {
        require(!liquidityAdded);
        require(!bulkRefunded, "Already refunded");
        require(isStopped, "Should be stopped");
        // To get refund it not reached hard cap and 30 days had passed 
        require(bnbSent < HARD_CAP && block.timestamp >= refundTime, "Cannot refund");
        for (uint i=0; i<contributors.length; i++) {
            address payable user = payable(contributors[i]);
            uint256 amount = bnbSpent[user];
            if(amount > 0) {
                bnbSpent[user] = 0;
                noiseBought[user] = 0;
                noiseHolding[user] = 0;                
                user.transfer(amount);
            }
        }        
        bulkRefunded = true;
    }    
    
    //@done Call this to kickstart fundraise
    function startICO() external onlyOwner { 
        liquidityUnlockTime = block.timestamp.add(DURATION_LIQUIDITY_LOCK);
        refundTime = block.timestamp.add(DURATION_REFUND);        
        icoStarted = true;
    }
    
    //@done
    function pauseICO() external onlyOwner { 
        icoStarted = false;
    }


}