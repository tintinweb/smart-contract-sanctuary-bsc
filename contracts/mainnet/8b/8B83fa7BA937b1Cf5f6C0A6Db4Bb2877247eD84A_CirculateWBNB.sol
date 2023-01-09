/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

// Part: IUniswapV2Pair

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// Part: IUniswapV2Router01

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

interface ISwapHelper{
    function swaptoToken( address fromToken, address toToken, uint256 _amountIn ) external returns (uint256 _amountOut);
    function TradingInfo( address fromToken, address toToken ) external view returns (uint256 _MaxStartMLimit, uint256 _MaxEndMLimit, uint256 _MinCollateralLimit, uint256 _MaxLoanLimit, uint256 _MaxTotalTradingLimit, uint256 _DailyLoanInterestRate, uint256 _LiquidationLimitRate, uint256 _LoanDivCollateral );
    function getSwapOut( address fromToken, address toToken, uint256 _amountIn ) external view returns (uint256 _amountOut);
}

contract CirculateWBNB  is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public SwapHelper;
    uint256 public developerFee = 300; // 300 : 3 %. 10000 : 100 %
    uint256 public rewardPeriod = 1 days;
    uint256 public withdrawPeriod = 4 weeks;
    uint256 public apr = 150; // 150 : 1.5 %. 10000 : 100 %
    uint256 public ferralfee = 200;
    uint256 public percentRate = 10000;
    uint256 public totalDepositLimit = 1e24;

    uint256 public _currentDepositID = 0;
    uint256 public _currentTradeID = 0;
    uint256 public _currentProfitID = 0;


    uint256 public totalInvestors = 0;
    uint256 public totalReward = 0;
    uint256 public totalInvested = 0;
    uint256 public staticProfit = 0;

    bool startDateEnable = true;
    uint256 public startDate = 100; //1673290800
    
    address[] public tradersArray;
    address[] public autoStartersArray;
    address[] public autoEndersArray;

    address public AutoStartOperator = 0x9017fbCF2987FDD470Aa1d849C131a97983C860A;
    address public AutoEndOperator = 0x9017fbCF2987FDD470Aa1d849C131a97983C860A;
    address private devWallet = 0x5695Ef5f2E997B2e142B38837132a6c3Ddc463b7;
    address public WBNBContract = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 

    struct DepositStruct{
        address investor;
        uint256 depositAmount;
        uint256 depositAt; // deposit timestamp
        uint256 claimedAmount; // claimed wbnb amount
        bool state; // withdraw capital state. false if withdraw capital
    }

    struct AprStruct{
        uint256 id_apr;
        uint256 lastUpdateTime;
    }


    struct InvestorStruct{
        address investor;
        uint256 totalLocked;
        uint256 startTime;
        uint256 lastCalculationDate;
        uint256 claimableAmount;
        uint256 claimedAmount;
        address referrer;
    }


    struct DebtorStruct{
        bool tradingState;
        uint256 collateralAmount;
        uint256 debtAmount;
        uint256 startTime;
        uint256 swappedAmount;
        address swappedToken;
        uint256 withdrawableAmount;
    }

    struct AutoStarterStruct{
        bool state;
        address swappedToken;
        uint256 debtAmount;
        uint256 downLimit;
        uint256 upLimit;
    }

    struct AutoEnderStruct{
        bool state;
        uint256 downLimit;
        uint256 upLimit;
    }

    struct TradeInfoStruct{
        bool startstate;
        uint256 totalTradeAmount;
        uint256 totalTradeProfit;
        uint256 lastTradeTime;
    }



    struct ProfitHistory{
        uint256 profitTime;
        uint256 kind;
        address lev_trader;
        uint256 profit;
    }

    ProfitHistory[] public profitHistory;
    AprStruct[] public aprState;

    // mapping from depost Id to DepositStruct
    mapping(uint256 => DepositStruct) public depositState;

    // mapping form investor to deposit IDs
    mapping(address => uint256[]) public ownedDeposits;

    //mapping from address to investor
    mapping(address => InvestorStruct) public investors;
    

    //mapping from address to debtor
    mapping(address => DebtorStruct) public debtors;

    //mapping from address to autoStarter
    mapping(address => AutoStarterStruct) public autoStarters;

    //mapping from address to autoEnder
    mapping(address => AutoEnderStruct) public autoEnders;

    mapping(address => TradeInfoStruct) public tradeInfo;
    

    // mapping(address => uint256) public MaxLoanLimit; // 1e23

    mapping(address => uint256) public lastStartMID; // ID of last minute of start trading
    mapping(address => uint256) public lastStartMBorrowAmount; // sum of borrow funds amount for last 1 minute start Trading
    mapping(address => uint256) public lastEndMID;  // ID of last minute of end trading
    mapping(address => uint256) public lastEndMBorrowAmount; // sum of borrow funds amount for last 1 minute end Trading
    mapping(address => uint256) public totalTradingAmount; 
    mapping(address => uint256) public totalReferralAmount; 
    mapping(address => uint256) public totalReferralCount;

    constructor( address _SwapHelper) {
        SwapHelper = _SwapHelper;
    }


    function updateApr( uint256  _apr ) public onlyOwner {
        apr = _apr;
        aprState.push(AprStruct({
            id_apr : _apr,
            lastUpdateTime : block.timestamp
        }));
    }
    
    function updateSwapHelper( address  _helper ) public onlyOwner {
        SwapHelper = _helper;
    }

    function DisableUpdateStartDate() public onlyOwner {
        startDateEnable = false;
    }

    function updateStartDate( uint256  _date ) public onlyOwner {
        if(startDateEnable){
            startDate = _date;
        }

    }

    function UpdateDepositLimit(uint256 _totalDepositLimit) public onlyOwner {
        totalDepositLimit = _totalDepositLimit;
    }
    function UpdateDevWallet(address _devWallet) public onlyOwner {
        require(_devWallet!=address(0),"Please provide a valid address");
        devWallet = _devWallet;
    }
    function UpdateAutoStartOperator(address _wallet) public onlyOwner {
        require(_wallet!=address(0),"Please provide a valid address");
        AutoStartOperator = _wallet;
    }
    function UpdateAutoEndOperator(address _wallet) public onlyOwner {
        require(_wallet!=address(0),"Please provide a valid address");
        AutoEndOperator = _wallet;
    }
    function changeWBNBContractAddress(address _wbnbContract) public onlyOwner{
        require(_wbnbContract!=address(0),"Please provide a valid address");
        WBNBContract = _wbnbContract;
    }

    function _getNextDepositID() private view returns (uint256) {
        return _currentDepositID + 1;
    }

    function _incrementDepositID() private {
        _currentDepositID++;
    }


    function deposit(uint256 _amount, address _referrer) external {
        require(block.timestamp>=startDate,"Cannot deposit at this moment");
        require(_amount > 0, "you can deposit more than 0 wbnb");
        require( getBalance() + _amount <=  totalDepositLimit, "Overflow Deposit Limit" );

        IERC20(WBNBContract).safeTransferFrom(msg.sender,address(this),_amount);

        uint256 _id = _getNextDepositID();
        _incrementDepositID();

        uint256 depositFee = (_amount * developerFee).div(percentRate);
        // transfer 3% fee to dev wallet
        IERC20(WBNBContract).safeTransfer(devWallet,depositFee);

        depositState[_id].investor = msg.sender;
        depositState[_id].depositAmount = _amount - depositFee;
        depositState[_id].depositAt = block.timestamp;
        depositState[_id].state = true;

        if(investors[msg.sender].investor==address(0)){
            totalInvestors = totalInvestors.add(1);

            investors[msg.sender].investor = msg.sender;
            investors[msg.sender].startTime = block.timestamp;
            investors[msg.sender].lastCalculationDate = block.timestamp;
        }

        uint256 lastRoiTime = block.timestamp - investors[msg.sender].lastCalculationDate;
        uint256 allClaimableAmount = (lastRoiTime *
            investors[msg.sender].totalLocked *
            apr).div(percentRate * rewardPeriod);

        investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.add(allClaimableAmount);
        investors[msg.sender].totalLocked = investors[msg.sender].totalLocked.add( _amount - depositFee);
        investors[msg.sender].lastCalculationDate = block.timestamp;

        ownedDeposits[msg.sender].push(_id);

        // reward for referrer
        if(investors[msg.sender].referrer==address(0) && _referrer!=msg.sender){
            investors[msg.sender].referrer = _referrer;
            totalReferralCount[_referrer] += 1;
        }
    }

    // claim all rewards of user
    function claimAllReward() public nonReentrant {
        require(ownedDeposits[msg.sender].length > 0, "you can deposit once at least");
            
        uint256 lastRoiTime = block.timestamp - investors[msg.sender].lastCalculationDate;
        uint256 allClaimableAmount = (lastRoiTime *
            investors[msg.sender].totalLocked *
            apr).div(percentRate * rewardPeriod);
         investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.add(allClaimableAmount);

        uint256 amountToSend = investors[msg.sender].claimableAmount;
        
        if(getBalance()<amountToSend){
            amountToSend = getBalance();
        }
        
        investors[msg.sender].claimableAmount = investors[msg.sender].claimableAmount.sub(amountToSend);
        investors[msg.sender].claimedAmount = investors[msg.sender].claimedAmount.add(amountToSend);
        investors[msg.sender].lastCalculationDate = block.timestamp;
        IERC20(WBNBContract).safeTransfer(msg.sender,amountToSend);
        totalReward = totalReward.add(amountToSend);

        // claim reward for referrer
        if(investors[msg.sender].referrer!=address(0)){
            IERC20(WBNBContract).safeTransfer(investors[msg.sender].referrer,(amountToSend*ferralfee).div(percentRate));
            totalReferralAmount[investors[msg.sender].referrer] += (amountToSend*ferralfee).div(percentRate);
        }
    }

    // withdraw capital by deposit id
    function withdrawCapital(uint256 id) public nonReentrant {
        require(
            depositState[id].investor == msg.sender,
            "only investor of this id can claim reward"
        );
        require(
            block.timestamp - depositState[id].depositAt > withdrawPeriod,
            "withdraw lock time is not finished yet"
        );
        require(depositState[id].state, "you already withdrawed capital");

        uint256 claimableReward = getAllClaimableReward(msg.sender);

        require(
            depositState[id].depositAmount + claimableReward <= getBalance(),
            "no enough wbnb in pool"
        );


        investors[msg.sender].claimableAmount = 0;
        investors[msg.sender].claimedAmount = investors[msg.sender].claimedAmount.add(claimableReward);
        investors[msg.sender].lastCalculationDate = block.timestamp;
        investors[msg.sender].totalLocked = investors[msg.sender].totalLocked.sub(depositState[id].depositAmount);

        uint256 amountToSend = depositState[id].depositAmount + claimableReward;

        // transfer capital to the user
        IERC20(WBNBContract).safeTransfer(msg.sender,amountToSend);
        totalReward = totalReward.add(claimableReward);

        depositState[id].state = false;

        // claim reward for referrer
        if(investors[msg.sender].referrer!=address(0)){
            IERC20(WBNBContract).safeTransfer(investors[msg.sender].referrer,(claimableReward*ferralfee).div(percentRate));
            totalReferralAmount[investors[msg.sender].referrer] += (claimableReward*ferralfee).div(percentRate);
        }
    }

    function getOwnedDeposits(address investor) public view returns (uint256[] memory) {
        return ownedDeposits[investor];
    }

    function getAllClaimableReward(address _investor) public view returns (uint256) {
         uint256 lastRoiTime = block.timestamp - investors[_investor].lastCalculationDate;
          uint256 allClaimableAmount = (lastRoiTime *
            investors[_investor].totalLocked *
            apr).div(percentRate * rewardPeriod);

         return investors[_investor].claimableAmount.add(allClaimableAmount);
    }

    function getBalance() public view returns(uint256) {
        return IERC20(WBNBContract).balanceOf(address(this));
    }

    // calculate total rewards
    function getTotalRewards() public view returns (uint256) {
        return totalReward;
    }

    // calculate total assets
    function getTotalAssets(address _otherToken) public view returns (uint256) {
        uint256 otherBalance = IERC20(_otherToken).balanceOf(address(this));
        uint256 otherAssets = ( otherBalance * ISwapHelper(SwapHelper).getSwapOut( _otherToken, WBNBContract, 1e6) ).div(1e6);
        uint256 mainAssets = IERC20(WBNBContract).balanceOf(address(this));
        return otherAssets + mainAssets ;
    }

    function getInvestor(address _investorAddress) public view returns(
        address investor,
        uint256 totalLocked,
        uint256 startTime,
        uint256 lastCalculationDate,
        uint256 claimableAmount,
        uint256 claimedAmount 
        )
    {
        investor = _investorAddress;
        totalLocked = investors[_investorAddress].totalLocked;
        startTime = investors[_investorAddress].startTime;
        lastCalculationDate = investors[_investorAddress].lastCalculationDate;
        claimableAmount = getAllClaimableReward(_investorAddress);
        claimedAmount = investors[_investorAddress].claimedAmount;
    }

    function getDepositState(uint256 _id) public view returns(address investor,uint256 depositAmount,uint256 depositAt, uint256 claimedAmount,bool state){
        investor = depositState[_id].investor;
        depositAmount = depositState[_id].depositAmount;
        depositAt = depositState[_id].depositAt;
        state = depositState[_id].state;
        claimedAmount = investors[investor].claimedAmount;
    }

    function depositCollateralFunds(uint256 _amount) external {
        require(block.timestamp>=startDate,"Cannot deposit at this moment");
        require(_amount > 0, "you can deposit more than 0 wbnb");

        IERC20(WBNBContract).safeTransferFrom(msg.sender,address(this),_amount);

        debtors[msg.sender].collateralAmount += _amount;
        debtors[msg.sender].withdrawableAmount += _amount;
    }

    function depositFunds(uint256 _amount) external onlyOwner returns(bool) {
        require(_amount > 0, "you can deposit more than 0 WBNB");
        IERC20(WBNBContract).safeTransferFrom(msg.sender,address(this),_amount);

        staticProfit += _amount;

        profitHistory.push(ProfitHistory({
            profitTime : block.timestamp,
            kind : 0,
            lev_trader : address(0),
            profit : _amount
        }));
        return true;
    }

    function getBorrowableAmount(address _toToken, address _trader) public view returns(uint256 _amount){
        (uint256 MaxStartMLimit,,, uint256 MaxLoanLimit, uint256 MaxTotalTradingLimit,,,uint256 LoanDivCollateral) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract,_toToken );
        if(lastStartMID[_toToken] != currentMinuteID())
            _amount = MaxStartMLimit;
        else
            _amount = MaxStartMLimit.sub(lastStartMBorrowAmount[_toToken]);
        if(_amount > MaxLoanLimit)
            _amount = MaxLoanLimit;
        if(MaxTotalTradingLimit > totalTradingAmount[_toToken]){
            if(_amount > MaxTotalTradingLimit - totalTradingAmount[_toToken])
                _amount = MaxTotalTradingLimit - totalTradingAmount[_toToken];
        }
        else
            _amount = 0;
        if(_amount>debtors[_trader].collateralAmount * LoanDivCollateral)
            _amount = debtors[_trader].collateralAmount * LoanDivCollateral;
        uint256 _bal = getBalance();
        if(_amount > _bal){
            _amount = _bal;
        }
    }

    function startTrading(address _trader, uint256 _borrowAmount, address _swappedToken) public {
        require( msg.sender ==  _trader || msg.sender == AutoStartOperator, "You don't have permission" );
        if(lastStartMID[_swappedToken] != currentMinuteID())
            lastStartMBorrowAmount[_swappedToken] = 0;
        (,, uint256 MinCollateralLimit,,,uint256 DailyLoanInterestRate,,) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract,_swappedToken );
        uint256 _borrowableAmount = getBorrowableAmount(_swappedToken, _trader);
        require( _borrowAmount <= _borrowableAmount, "Over full borrowable amount limit" );
        require( debtors[_trader].collateralAmount >= MinCollateralLimit, "Cannot trade without depositing collateral funds more than MinCollateralLimit" );
        require( debtors[_trader].tradingState == false, "Trading has already started" );

        totalTradingAmount[_swappedToken] += _borrowAmount;
        lastStartMBorrowAmount[_swappedToken] += _borrowAmount;
        IERC20(WBNBContract).safeApprove(SwapHelper, _borrowAmount);
        uint256 swapOutAmount = ISwapHelper(SwapHelper).swaptoToken( WBNBContract,_swappedToken, _borrowAmount);
        debtors[_trader].tradingState = true;
        debtors[_trader].debtAmount = _borrowAmount;
        debtors[_trader].swappedAmount = swapOutAmount;
        debtors[_trader].swappedToken = _swappedToken;
        debtors[_trader].startTime = block.timestamp;
        debtors[_trader].withdrawableAmount = 0;
        addTrader(_trader);

        lastStartMID[_swappedToken] = currentMinuteID();
        unsetAutoStartTrading(_trader);

        // calculate the total profit
        if(tradeInfo[_swappedToken].startstate==false){
            tradeInfo[_swappedToken].startstate = true;
            tradeInfo[_swappedToken].lastTradeTime = block.timestamp;
        }
        tradeInfo[_swappedToken].totalTradeProfit += (tradeInfo[_swappedToken].totalTradeAmount * ( block.timestamp - tradeInfo[_swappedToken].lastTradeTime ) * DailyLoanInterestRate).div(percentRate * rewardPeriod);
        tradeInfo[_swappedToken].totalTradeAmount += _borrowAmount;
        tradeInfo[_swappedToken].lastTradeTime = block.timestamp;

    }

    function getTotalProfit(address _token) public view returns(uint256) {
        (,,,,,uint256 DailyLoanInterestRate,,) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract, _token );
        return staticProfit + tradeInfo[_token].totalTradeProfit + (tradeInfo[_token].totalTradeAmount * ( block.timestamp - tradeInfo[_token].lastTradeTime ) * DailyLoanInterestRate).div(percentRate * rewardPeriod);
    }

    function currentMinuteID() public view returns(uint256){
        return (block.timestamp).div(60000);
    }

    function currentTimeStamp() public view returns(uint256){
        return block.timestamp;
    }

    function withdrawCollateralFunds(uint256 _amount) external nonReentrant {
        require( debtors[msg.sender].tradingState == false, "You can withdraw collateral funds after ending the trading." );
        require( autoStarters[msg.sender].state == false, "You can withdraw collateral funds after unsetting the auto start trading."  );
        require( debtors[msg.sender].withdrawableAmount > 0, "There is nothing funds to withdraw." );
        debtors[msg.sender].withdrawableAmount -= _amount;
        debtors[msg.sender].collateralAmount -= _amount;
        IERC20(WBNBContract).safeTransfer(msg.sender,_amount);
    }
    function getSwapBackAmount(address _trader) public view returns(uint256){
        if(debtors[_trader].tradingState){
            address _swappedToken = debtors[_trader].swappedToken;
            return ISwapHelper(SwapHelper).getSwapOut( _swappedToken, WBNBContract, debtors[_trader].swappedAmount);
        }
        else
            return 0;
    }
    function getLoanInterestAmount(address _trader)public view returns (uint256){
        if(debtors[_trader].tradingState){
            address _swappedToken = debtors[_trader].swappedToken;
            (,,,,,uint256 DailyLoanInterestRate,,) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract,_swappedToken );
            return ( (block.timestamp - debtors[_trader].startTime) * debtors[_trader].debtAmount * DailyLoanInterestRate ).div( percentRate * (1 days) );
        }
        else
            return 0;
    }
    function getUserBenefit(address _trader) public view returns(int256 _withdrawableAmount){
        if(debtors[_trader].tradingState){
            address _swappedToken = debtors[_trader].swappedToken;
            (,,,,,uint256 DailyLoanInterestRate,,) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract,_swappedToken );
            uint256 swapOutAmount = ISwapHelper(SwapHelper).getSwapOut( _swappedToken, WBNBContract, debtors[_trader].swappedAmount);
            _withdrawableAmount = int256(swapOutAmount) - int256( debtors[_trader].debtAmount + ( ( block.timestamp - debtors[_trader].startTime ) * debtors[_trader].debtAmount * DailyLoanInterestRate ).div(percentRate * (1 days)) ) ;
        }
        else
            _withdrawableAmount = 0;
    }
    function endTrading( address _trader ) public {
        require( msg.sender ==  _trader || msg.sender == AutoEndOperator, "You don't have permission"  );
        require( debtors[_trader].tradingState , "Trading has not been started");
        address _swappedToken = debtors[_trader].swappedToken;
        if(lastEndMID[_swappedToken] != currentMinuteID())
            lastEndMBorrowAmount[_swappedToken] = 0;
        (,uint256 MaxEndMLimit,,,,uint256 DailyLoanInterestRate,,) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract,_swappedToken );
        lastEndMBorrowAmount[_swappedToken] += debtors[_trader].debtAmount;
        require( lastEndMBorrowAmount[_swappedToken] < MaxEndMLimit, "Over Full End Trading Borrow Amount");
        debtors[_trader].tradingState = false;
        IERC20(_swappedToken).safeApprove(SwapHelper, debtors[_trader].swappedAmount);
        uint256 swapOutAmount = ISwapHelper(SwapHelper).swaptoToken( _swappedToken, WBNBContract, debtors[_trader].swappedAmount);
        int256 _withdrawableAmount = int256(debtors[_trader].collateralAmount + swapOutAmount) - int256( debtors[_trader].debtAmount + ( ( block.timestamp - debtors[_trader].startTime ) * debtors[_trader].debtAmount * DailyLoanInterestRate ).div(percentRate * (1 days)) ) ;
        if ( _withdrawableAmount < 0 )
            _withdrawableAmount = 0;
        debtors[_trader].withdrawableAmount = uint256(_withdrawableAmount);
        debtors[_trader].collateralAmount = uint256(_withdrawableAmount);
        
        debtors[_trader].swappedAmount = 0;
        removeTrader(_trader);

        totalTradingAmount[_swappedToken] -= debtors[_trader].debtAmount;
        lastEndMID[_swappedToken] = currentMinuteID();
        unsetAutoEndTrading(_trader);

        // calculate total profit
        tradeInfo[_swappedToken].totalTradeProfit += (tradeInfo[_swappedToken].totalTradeAmount * ( block.timestamp - tradeInfo[_swappedToken].lastTradeTime ) * DailyLoanInterestRate).div(percentRate * rewardPeriod);
        tradeInfo[_swappedToken].totalTradeAmount -= debtors[_trader].debtAmount;
        tradeInfo[_swappedToken].lastTradeTime = block.timestamp;

        profitHistory.push(ProfitHistory({
            profitTime : block.timestamp,
            kind : 1,
            lev_trader : _trader,
            profit : ( ( block.timestamp - debtors[_trader].startTime ) * debtors[_trader].debtAmount * DailyLoanInterestRate ).div(percentRate * (1 days))
        }));

        debtors[_trader].debtAmount = 0;
    }

    function IsNeededLiquidation(address _trader) public view returns (bool) {
        address _swappedToken = debtors[_trader].swappedToken;
        (,,,,,uint256 DailyLoanInterestRate,uint256 LiquidationLimitRate,) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract,_swappedToken );
        if( debtors[_trader].tradingState == false )
            return false;
        uint256 estSwapOut = ISwapHelper(SwapHelper).getSwapOut(debtors[_trader].swappedToken , WBNBContract, debtors[_trader].swappedAmount );

        if ( int256( debtors[_trader].collateralAmount + estSwapOut ) - int256( debtors[_trader].debtAmount + ( (block.timestamp - debtors[_trader].startTime) * debtors[_trader].debtAmount * DailyLoanInterestRate ).div( percentRate * (1 days) ) ) < int256( ( debtors[_trader].debtAmount * LiquidationLimitRate ).div(percentRate) ) )
            return true;
        else
            return false;
    }

    function IsNeededLiquidation_Parameters(address _trader) public view returns (int256 _plus1, int256 _plus2, int256 _minus) {
        address _swappedToken = debtors[_trader].swappedToken;
        (,,,,,uint256 DailyLoanInterestRate,uint256 LiquidationLimitRate,) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract,_swappedToken );
        require( debtors[_trader].tradingState == false );
            
        uint256 estSwapOut = ISwapHelper(SwapHelper).getSwapOut(debtors[_trader].swappedToken, WBNBContract,debtors[_trader].swappedAmount );

        _plus1 = int256( debtors[_trader].collateralAmount + estSwapOut ) ; 
        _plus2 = int256( debtors[_trader].debtAmount + ( (block.timestamp - debtors[_trader].startTime) * debtors[_trader].debtAmount * DailyLoanInterestRate ).div( percentRate * (1 days) ) );
        _minus = int256( ( debtors[_trader].debtAmount * LiquidationLimitRate ).div(percentRate) );
    }
    function setAutoStartTrading( uint256 _borrowAmount, address _swappedToken, uint256 swappedDownLimit, uint256 swappedUpLimit ) external {
        require( swappedDownLimit < swappedUpLimit, "swappedDownLimit should be smaller than swappedUpLimit" );
        require( debtors[msg.sender].tradingState == false, "Trading has been already started" );
        uint256 _borrowableAmount = getBorrowableAmount(_swappedToken, msg.sender);
        require( _borrowAmount <= _borrowableAmount, "Over full borrowable amount limit" );
        (,, uint256 MinCollateralLimit,,,,,) = ISwapHelper(SwapHelper).TradingInfo( WBNBContract,_swappedToken );
        require( debtors[msg.sender].collateralAmount >= MinCollateralLimit, "Cannot trade without depositing collateral funds more than MinCollateralLimit" );

        autoStarters[msg.sender].swappedToken = _swappedToken;
        autoStarters[msg.sender].state = true;
        autoStarters[msg.sender].downLimit = swappedDownLimit;
        autoStarters[msg.sender].upLimit = swappedUpLimit;
        autoStarters[msg.sender].debtAmount = _borrowAmount;
        addAutoStarter(msg.sender);
    }
    function unsetAutoStartTrading(address _trader) public{
        require( msg.sender ==  _trader || msg.sender == AutoStartOperator, "You don't have permission in unset" );
        autoStarters[msg.sender].swappedToken = address(0);
        autoStarters[_trader].state = false;
        autoStarters[_trader].downLimit = 0;
        autoStarters[_trader].upLimit = 0;
        autoStarters[_trader].debtAmount = 0;
        removeAutoStarter(_trader);
    }
    function checkAutoStarting(address _trader) public view returns(bool){
        uint256 estSwapOut = ISwapHelper(SwapHelper).getSwapOut( WBNBContract, autoStarters[_trader].swappedToken, autoStarters[_trader].debtAmount );
        return (estSwapOut > autoStarters[_trader].upLimit || estSwapOut < autoStarters[_trader].downLimit);
    }
    function autoStartTrading( address _trader ) external {
        require( msg.sender == AutoStartOperator, "Permission Error" );
        startTrading(_trader, autoStarters[_trader].debtAmount, autoStarters[_trader].swappedToken);
    }
    function setAutoEndTrading(uint256 swapbackDownLimit, uint256 swapbackUpLimit) external{
        require( swapbackDownLimit < swapbackUpLimit, "swapbackDownLimit should be smaller than swapbackUpLimit" );
        require( debtors[msg.sender].tradingState, "Trading has not been started" );
        autoEnders[msg.sender].state = true;
        autoEnders[msg.sender].downLimit = swapbackDownLimit;
        autoEnders[msg.sender].upLimit = swapbackUpLimit;
        addAutoEnder(msg.sender);
    }
    function unsetAutoEndTrading(address _trader) public {
        require( msg.sender ==  _trader || msg.sender == AutoEndOperator, "You don't have permission in unset" );
        autoEnders[_trader].state = false;
        autoEnders[_trader].downLimit = 0;
        autoEnders[_trader].upLimit = 0;
        removeAutoEnder(_trader);
    }
    function autoEndTrading( address _trader) external{
        require( msg.sender == AutoEndOperator, "Permission Error" );
        endTrading(_trader);
    }
    function checkAutoEnding(address _trader) public view returns(bool){
        uint256 estSwapOut = ISwapHelper(SwapHelper).getSwapOut( debtors[_trader].swappedToken, WBNBContract, debtors[_trader].swappedAmount );
        return (estSwapOut > autoEnders[_trader].upLimit || estSwapOut < autoEnders[_trader].downLimit);
    }


  // Array Add/Remove ########################
    // autoStarters Array
    function getAutoStarter(uint256 i) public view returns (address) {
        return autoStartersArray[i];
    }
    function getAutoStarters() public view returns (address[] memory) {
        return autoStartersArray;
    }
    function addAutoStarter(address elmt) private {
        bool repeatflg = false;
        for (uint i = 0; i < autoStartersArray.length; i++) {
            if ( autoStartersArray[i] == elmt ){
                repeatflg = true;
            }                
        }
        if( !repeatflg )
            autoStartersArray.push(elmt);
    }
    function getLength_AutoStarters() public view returns (uint256) {
        return autoStartersArray.length;
    }
    function removeAutoStarter(address elmt) private {
        uint _index;
        for ( _index = 0; _index < autoStartersArray.length ; _index ++){
            if(autoStartersArray[_index]==elmt){
                break;
            }
        }
        if(_index < autoStartersArray.length){
            for (uint i = _index; i < autoStartersArray.length - 1; i++) {
                autoStartersArray[i] = autoStartersArray[i + 1];
            }
            autoStartersArray.pop();
        }
    }
    // autoEnders Array
    function getAutoEnder(uint256 i) public view returns (address) {
        return autoEndersArray[i];
    }
    function getAutoEnders() public view returns (address[] memory) {
        return autoEndersArray;
    }
    function addAutoEnder(address elmt) private {
        bool repeatflg = false;
        for (uint i = 0; i < autoEndersArray.length; i++) {
            if ( autoEndersArray[i] == elmt ){
                repeatflg = true;
            }                
        }
        if( !repeatflg )
            autoEndersArray.push(elmt);
    }
    function getLength_AutoEnders() public view returns (uint256) {
        return autoEndersArray.length;
    }
    function removeAutoEnder(address elmt) private {
        uint _index;
        for ( _index = 0; _index < autoEndersArray.length ; _index ++){
            if(autoEndersArray[_index]==elmt){
                break;
            }
        }
        if(_index < autoEndersArray.length){
            for (uint i = _index; i < autoEndersArray.length - 1; i++) {
                autoEndersArray[i] = autoEndersArray[i + 1];
            }
            autoEndersArray.pop();
        }
    }
    // tradersArray Array
    function getTrader(uint256 i) public view returns (address) {
        return tradersArray[i];
    }
    function getTraders() public view returns (address[] memory) {
        return tradersArray;
    }
    function addTrader(address elmt) private {
        bool repeatflg = false;
        for (uint i = 0; i < tradersArray.length; i++) {
            if ( tradersArray[i] == elmt ){
                repeatflg = true;
            }                
        }
        if( !repeatflg )
            tradersArray.push(elmt);
    }
    function getLength_Traders() public view returns (uint256) {
        return tradersArray.length;
    }
    function removeTrader(address elmt) private {
        uint _index;
        for ( _index = 0; _index < tradersArray.length ; _index ++){
            if(tradersArray[_index]==elmt){
                break;
            }
        }
        if(_index < tradersArray.length){
            for (uint i = _index; i < tradersArray.length - 1; i++) {
                tradersArray[i] = tradersArray[i + 1];
            }
            tradersArray.pop();
        }
    }
    // get all profit history
    function getAllProfitHistory() public view returns(ProfitHistory[] memory) {
        return profitHistory;
    }
    function getAprHistory() public view returns( AprStruct[] memory ){
        return aprState;
    }
}