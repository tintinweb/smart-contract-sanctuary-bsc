/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function feeToRate() external view returns (uint256);

    function initCodeHash() external view returns (bytes32);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setFeeToRate(uint256) external;

    function setInitCodeHash(bytes32) external;

    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);

    function pairFor(address tokenA, address tokenB) external view returns (address pair);

    function getReserves(address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


interface IPair {
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

    function price(address token, uint256 baseDecimal) external view returns (uint256);

    function initialize(address, address) external;
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapMining() external pure returns (address);

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

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external view returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

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


pragma solidity ^0.8.0;

interface IRepository {
    function withdraw(IERC20 _token, address _recipient) external returns(uint256 _balance);
}

interface ISF {
    function upline(address) external view returns(address);
}

pragma solidity ^0.8.0;

contract Repository  {

    address internal _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, "DENIED");
        _;

    }
    constructor(address __owner) {
        _owner = __owner;
    }

    receive() external payable {} 

    function withdraw(IERC20 _token, address _recipient) public onlyOwner() returns(uint256 _balance) {
        _balance = _token.balanceOf(address(this));
        _token.transfer(_recipient, _balance);
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
                /// @solidity memory-safe-assembly
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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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



// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    using Address for address;


    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 MAX = ~uint256(0);
    uint256 public BASEDIVIDE;

    address private manager;
    address private fund;
    address private uplineManager;
    address private nftManager;
    address private deflationManager;
    bool public isDeflation;

    mapping(address => bool) public tokenHold;
    address[] public tokenHolders;
    mapping(address => uint256) tokenHolderId;
    bool public enableAntiBot;
    mapping(address => uint256) private antiBot;
    uint256 botLimit;
    uint256 start;
    mapping(address => bool) except;

    struct Compound {
        uint256 dateRate;
        uint256 intervalRate;
        uint256 base;
        uint256 cycle;
        uint256 totalCompound;
        uint256 distributedCompound;
        uint256 accumulate;
        uint256 startEpoch;
        uint256 lastUpdate;
        uint256 interval;
        uint256 endEpoch;
    }

    Compound public compound;

    struct UserCompound {
        uint256 lastCalled;
        uint256 receivedCompound;
        uint256 unReceiveCompound;
    }

    mapping(address => UserCompound)  public userCompound;

    struct Rates {
        uint256 autoLpRate;
        uint256 uplineRate;
        uint256 burnRate;
        uint256 tBurnRate;
        uint256 managerRate;
        uint256 fundRate;
        uint256 nftRate;
        uint256 rateBase;
    }

    Rates rates;

    struct UpLine {
        uint256 level;
        uint256 firstLevelRate;
        uint256 otherLevelRate;
        uint256 rateBase;
        uint256 miniBalance;
    }

    UpLine public upLineData;
    ISF public sf;

    address public defaultRouter;
    mapping(address => bool) public isRouter;
    mapping(address => bool) public checkedIsNotRouter;
    mapping(address => bool) public isPair;
    mapping(address => bool) public checkedIsNotPair;
    mapping(address => address) public pairTokenB;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public autoAddLiquidityAmount;

    IRepository public repository;
    IPair public defaultPair;
    address public defaultWbnb;

    mapping(address => bool) public exclude;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 otherReceived,
        uint256 tokensIntoLiquidity
    );
    event GetReservesEvent(uint256 amout0out, uint256 amount1out);


        /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
                string memory name_, 
        string memory symbol_, 
        uint8 decimals_,
        uint256 totalSupply_,
        address manager_,
        address fund_,
        address uplineManager_,
        address nftManager_,
        address deflationManager_,
        address router_,
        address _sf
    ) {
        _initialize(
        name_,
        symbol_,
        decimals_,
        totalSupply_,
        manager_,
        fund_,
        uplineManager_,
        nftManager_,
        deflationManager_,
        router_,
        _sf
        );
    }

    receive() external payable {
    }

    modifier checkIsRouter(address _sender) {
        {
            if (!isRouter[_sender] && !checkedIsNotRouter[_sender]) {
                if (address(_sender).isContract()) {
                    IRouter _routerCheck = IRouter(
                        _sender
                    );
                    try _routerCheck.WETH() returns (address) {
                        try _routerCheck.factory() returns (address) {
                            isRouter[_sender] = true;
                        } catch {
                            checkedIsNotRouter[_sender] = true;
                        }
                    } catch {
                        checkedIsNotRouter[_sender] = true;
                    }
                } else {
                    checkedIsNotRouter[_sender] = true;
                }
            }
        }

        _;
    }

    modifier checkIsPair(address _sender) {
        {
            if (!isPair[_sender] && !checkedIsNotPair[_sender]) {
                if (_sender.isContract()) {
                    IPair _pairCheck = IPair(_sender);
                    try _pairCheck.token0() returns (address) {
                        try _pairCheck.token1() returns (address){
                            try _pairCheck.factory() returns (address) {
                                address _token0 = _pairCheck.token0();
                                address _token1 = _pairCheck.token1();
                                address this_token = address(this) == _token0 ? _token0 : address(this) == _token1 ? _token1 : address(0);
                                if(this_token != address(0)) {
                                    isPair[_sender] = true;
                                    pairTokenB[_sender] = address(this) == _token0 ? address(this) == _token1 ? _token1 : address(0) : _token0;
                                } else{
                                   checkedIsNotPair[_sender] = true; 
                                }

                            } catch {
                                checkedIsNotPair[_sender] = true;
                            }
                        } catch {
                            checkedIsNotPair[_sender] = true;
                        }

                    } catch {
                        checkedIsNotPair[_sender] = true;
                    }
                } else {
                    checkedIsNotPair[_sender] = true;
                }
            }
        }

        _;
    }

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier onlyInilized() {
        require(_initialized, "Initializable: contract is not initialized");
        _;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _currentTotalSupply();
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balanceOf(account);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) 
    public virtual override 
    checkIsPair(msg.sender)
    checkIsPair(to)
    returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount, true);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override 
    checkIsPair(msg.sender) checkIsPair(from) checkIsPair(to)
    returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount, false);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount,
        bool isT
    ) 
    internal virtual 
    checkIsRouter(msg.sender)
    checkIsRouter(from)
    checkIsRouter(to)
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _checkBefore(from, to);
        _autoSwap(from, to);


        (address user, uint256 uplineFee, uint256 lpFee, uint256 burnFee, uint256 tBurnFee, uint256 managerFee, uint256 fundFee, uint256 nftFee) = _caculateFees(from, to, amount, isT);

        _standardTransfer(from, to, amount);  

        if(isT && tBurnFee >0) {  
            _standardTransfer(user, deflationManager, tBurnFee);
        }     

        if(isT && lpFee >0) {
            _standardTransfer(user, address(this), lpFee);
        }

        if(isT && uplineFee >0){
            _divideDownlineFee(user, uplineFee);
        }

        if(!isT && burnFee >0) {
            _burn(user, burnFee);
        }

        if(!isT && managerFee >0) {
            _standardTransfer(user, manager, managerFee);
        }

        if(!isT && fundFee >0) {
            _standardTransfer(user, fund, fundFee);
        }

        if(!isT && nftFee >0) {
            _standardTransfer(user, nftManager, nftFee);
        }

        _checkAfter(from, to);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        // _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        // _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        // _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);

        // _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }


    function _standardTransfer(address from, address to, uint256 amount) internal {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }


    /*****************************************************************************************************************/
    /************************************************** other function ***********************************************/
    /*****************************************************************************************************************/

    // external
    function setSwapAndLiquifyEnabled(bool _enable) public returns(bool) {
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        swapAndLiquifyEnabled = _enable;
        emit SwapAndLiquifyEnabledUpdated(_enable);
        return true;
    }

    function setRates(uint256 _lpRate, uint256 _uplineRate, uint256 _burnRate, uint256 _tBurnRate, uint256 _managerRate, uint256 _fundRate, uint256 _nftRate) public returns(bool){
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        _setRates(BASEDIVIDE,  _lpRate, _uplineRate, _burnRate, _tBurnRate, _managerRate, _fundRate, _nftRate);
        return true;
    }
    
    function setStartCompoundEpoch(uint256 _startEpoch) public {
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        require(compound.startEpoch == 0, "Compound start time has beed set!");
        _setStartCompoundEpoch(_startEpoch, compound.cycle);
    }

    function setUplineLevel(uint256 _level) public {
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        require(_level >0, "level is zero");
        upLineData.level = _level;
    }

    function setSF(address _sf) public returns(bool){
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        sf = ISF(_sf);
        require(sf.upline(msg.sender)==address(0), "");
       return true;
    }

    function setStartDeflation(bool _start) public onlyInilized() returns(bool) {
        require(msg.sender == deflationManager || msg.sender == owner(), "Deined!");
        isDeflation = _start;
        return true;
    }
    
    function withdraw(address token_) public returns(bool) {
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        if(token_ == address(this)){
            _standardTransfer(address(this), manager, _balances[address(this)]);
            return true;
        }
        uint256 amount = IERC20Metadata(token_).balanceOf(address(this));
        IERC20Metadata(token_).transfer(manager, amount);

        return true;
    }

    function setEnableAntibot(bool _enable) public returns(bool){
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        enableAntiBot = _enable;
        return true;
    }

    function setAntibotLimit(uint256 _locktime) public returns(bool){
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        botLimit = _locktime;
        return true;
    }

    function setExcept(address _except, bool _enable) public returns(bool){
        require(msg.sender == manager || msg.sender == owner(), "Denied!");
        except[_except] = _enable;
        return true;
    }

    // internal 

    function _balanceOf(address account) internal view returns (uint256) {
        return _balances[account].add(_computeCompound(account));
    }

    function _checkBefore(address from, address to) internal {
        bool isT = !from.isContract() && !to.isContract() ? true : false;
        if(!(except[from] || except[to] || isT)){
            require(block.timestamp >= start, "ERROR:start time limited!");
        }
        if(isPair[to] && !isPair[from] && !isRouter[from] && from !=address(this) && enableAntiBot){
            require(antiBot[from].add(botLimit) < block.timestamp, "ERROR: anti bot!");
        }
        _updateTotal();
        _distributedCompound(from);
        _distributedCompound(to);
        if (!tokenHold[to] && !to.isContract()) {
            _addTokenHolder(to);            
        }
    }

    function _checkAfter(address from, address to) internal {
        if((isPair[from] || isRouter[from]) && !isPair[to] && !isRouter[to] && to !=address(this) && enableAntiBot){
            antiBot[from] = block.timestamp;
        }
        _updateTotal();
        _updateUserLastcall(from);
        _updateUserLastcall(to);
        if(!from.isContract() && _balances[from] == 0){
            _removeTokenHolder(from);   
        } 

    }
    
    function _autoSwap(address from, address to) internal {
        if(!swapAndLiquifyEnabled){
            return;
        }
        if(isPair[from]) {
            return;
        }
        address pair = isPair[from] ? from : isPair[to] ? to : address(defaultPair);
        if(!inSwapAndLiquify && _balances[address(this)] >= autoAddLiquidityAmount && IPair(pair).totalSupply() >0) {
            swapAndLiquify(IPair(pair), autoAddLiquidityAmount);
        }
    }

    function swapAndLiquify(IPair pair, uint256 contractTokenBalance) internal lockTheSwap {

        if(!isPair[address(pair)] || _balances[address(this)] < contractTokenBalance) {
            return;
        }

        address token0 = pair.token0();
        address token1 = pair.token1();
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        address tokenB = pairTokenB[address(pair)];
        if(tokenB == address(0)){
            tokenB = address(this) == token0 ? address(this) == token1 ? address(0) : token1 : token0;
        }
        if(tokenB == address(0)) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenB;
        uint256 initialBalance = IERC20(tokenB).balanceOf(address(this));

        _approve(address(this), address(defaultRouter), contractTokenBalance);
        address to = address(repository);
        IRouter(defaultRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            half,
            0, 
            path,
            to,
            block.timestamp+1000
        );
        uint256 otherAmount = repository.withdraw(IERC20(address(tokenB)), address(this));
        uint256 newBalance = IERC20(tokenB).balanceOf(address(this));
        newBalance = newBalance >= initialBalance ? newBalance.sub(initialBalance) : 0;
        newBalance = newBalance <= otherAmount ? newBalance : otherAmount;
        IERC20(tokenB).approve(defaultRouter, newBalance);
        IRouter(defaultRouter).addLiquidity(address(this), tokenB, otherHalf, newBalance, 0, 0, address(manager), block.timestamp + 1000);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function _initCompound(uint256 _maxTotal, uint256 _dateRate, uint256 _base, uint256 _cycle, uint256 _interval, uint256 _startEpoch) internal {
        require((_cycle.mod(1 days)) == 0, "Compound cycle must be mod day!");
        require(_dateRate < _base, "Compound rate exceed base!");
        uint256 oneDay = 1 days;
        require(_interval <= oneDay && oneDay.mod(_interval) == 0, "Compound reward interval exceed date rate or date rate cannot mod by interfal");
        compound.totalCompound = _maxTotal;
        compound.dateRate = _dateRate;
        compound.base = _base;
        compound.cycle = _cycle;
        compound.interval = _interval;
        compound.intervalRate = _dateRate.div(oneDay.div(_interval));
        _setStartCompoundEpoch(_startEpoch, _cycle);
    }

    function _addTokenHolder(address _user) internal {
        if(tokenHolderId[_user] ==0 || tokenHolderId[_user] == MAX){
            return;
        }
        tokenHold[_user] = true;
        tokenHolders.push(_user);
        tokenHolderId[_user] = tokenHolders.length;
    }

    function _removeTokenHolder(address _user) internal {
        tokenHold[_user] = false;
        tokenHolderId[_user] = MAX;
    }

    function _setStartCompoundEpoch(uint256 _startEpoch, uint256 _cycle) internal {
        compound.startEpoch = _startEpoch;
        compound.endEpoch = _startEpoch.add(_cycle);
        compound.lastUpdate = _startEpoch;
    }

    function _computeCompound(address _user) internal view returns(uint256) {
        uint256 current = block.timestamp;
        if(
            compound.startEpoch == 0 ||
            current <= compound.startEpoch.add(compound.interval) || 
            compound.distributedCompound >= compound.totalCompound ||
            compound.distributedCompound >= compound.totalCompound  ||
            current < userCompound[_user].lastCalled  || 
            _balances[_user] == 0
        ) {
            return 0;
        }

        uint256 lastcalled = userCompound[_user].lastCalled;
        if(lastcalled <= compound.startEpoch){
            lastcalled = compound.startEpoch;
        }

        address user = _user;
        uint256 userCompoundFee;
        uint256 userBalance = _balances[user];

        uint256 oneDay = 1 days;

        uint256 diff = current.sub(lastcalled);

        if(diff >= oneDay) {
            uint256 dayCount = diff.div(oneDay);
            for(uint i=0; i<dayCount; i++){
                uint256 temp = userBalance.mul(compound.dateRate).div(compound.base);
                userCompoundFee = userCompoundFee.add(temp);
                userBalance = userBalance.add(temp);
                diff = diff.sub(oneDay);
            }
        }

        if(diff > 0){
            uint256 count = diff.div(compound.interval);            
            
            for(uint c=0; c<count; c++) {
                uint256 temp = userBalance.mul(compound.intervalRate).div(compound.base);
                userCompoundFee = userCompoundFee.add(temp);
                userBalance = userBalance.add(temp);
            }
        }

        return userCompoundFee;
    }

    function _computeAccumulateCompound() internal view returns(uint256) {
        uint256 current = block.timestamp;
        uint256 compounds;
        if(current < compound.startEpoch.add(compound.interval)){
            return compounds = 0;
        }
        if(current >= compound.endEpoch){
            current = compound.endEpoch;
        }
        if(compound.distributedCompound >= compound.totalCompound){
            compounds = compound.totalCompound;
        } else {
            uint256 temp = _totalSupply;
            uint256 oneDay = 1 days;
            uint256 diff = current.sub(compound.lastUpdate);
            if(diff >= oneDay){
                uint256 oneDayCount = diff.div(oneDay);
                for(uint i=0; i<oneDayCount; i++) {
                    if(compounds >= compound.totalCompound) {
                        compounds = compound.totalCompound;
                        break;
                    }
                    uint256 tempFee = temp.mul(compound.dateRate).div(compound.base);
                    temp = temp.add(tempFee);
                    compounds = compounds.add(tempFee);
                    diff = diff.sub(oneDay);
                }
            }

            if(diff > 0){
                uint256 count = diff.div(compound.interval);
                
                for(uint i=0; i<count; i++) {
                    if(compounds >= compound.totalCompound) {
                        compounds = compound.totalCompound;
                        break;
                    }
                    uint256 tempFee = temp.mul(compound.intervalRate).div(compound.base);
                    temp = temp.add(tempFee);
                    compounds = compounds.add(tempFee);
                }
            }

        }
        return compounds;
        
    }

    function _currentTotalSupply() internal view returns(uint256) {
        return _totalSupply.add(_computeAccumulateCompound());
    }

    function _updateTotal() internal {
        compound.accumulate += _currentTotalSupply().sub(_totalSupply);
        _totalSupply = _currentTotalSupply();

        uint256 current = block.timestamp;
        uint256 count;
        if(current > compound.startEpoch){
            count = current.sub(compound.startEpoch).div(compound.interval);
        }
        
        compound.lastUpdate = compound.interval.mul(count).add(compound.startEpoch);
    }

    function _mintCompound(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _distributedCompound(address _user) internal {
        uint256 userBalance = _balanceOf(_user);
        if(userBalance > _balances[_user] && _balances[_user] >0){
            uint256 fee = userBalance.sub(_balances[_user]);
            _mintCompound(_user, fee);
            userCompound[_user].receivedCompound = userCompound[_user].receivedCompound.add(fee);
            compound.distributedCompound = compound.distributedCompound.add(fee);
        }

        _updateUserLastcall(_user);

    }

    function _updateUserLastcall(address _user) internal {
        uint256 current = block.timestamp;
        if(current > compound.startEpoch){
            uint256 count = current.sub(compound.startEpoch).div(compound.interval);
            userCompound[_user].lastCalled = compound.interval.mul(count).add(compound.startEpoch);
        } else {
            userCompound[_user].lastCalled = compound.startEpoch;
        }
    }

    function _setRates(uint256 _divBase, uint256 _lpRate, uint256 _uplineRate, uint256 _burnRate, uint256 _tBurnRate, uint256 _managerRate, uint256 _fundRate, uint256 _nftRate) internal {
        require(_divBase > _lpRate.add(_uplineRate.add(_burnRate.add(_tBurnRate.add(_managerRate.add(_fundRate.add(_nftRate)))))), "Total rate exceed rate base!");
        rates.rateBase = _divBase;
        rates.autoLpRate = _lpRate;
        rates.uplineRate = _uplineRate;
        rates.burnRate = _burnRate;
        rates.tBurnRate = _tBurnRate;
        rates.managerRate = _managerRate;
        rates.fundRate = _fundRate;
        rates.nftRate = _nftRate;
    }


    function _initUplineData(uint256 level, uint256 _minibalance, uint256 _firstLevelRate, uint256 _otherLeverRate, uint256 _base) internal {
        require(level >0, "Level is zero!") ;
        require(_firstLevelRate.add(_otherLeverRate) <= _base, "First upline rate exceed base rate!");
        upLineData.level = level;
        upLineData.miniBalance = _minibalance;
        upLineData.firstLevelRate = _firstLevelRate;
        upLineData.otherLevelRate = _otherLeverRate;
        upLineData.rateBase = _base;
    }

    function _divideDownlineFee(address _downline, uint256 _fees) internal{
        if(_balances[_downline] < _fees) {
            return ;
        }
        address sender = _downline;
        address down = _downline;
        address up;
        uint256 uplineLevel = upLineData.level;
        uint256 firstLevel = _fees.mul(upLineData.firstLevelRate).div(upLineData.rateBase);
        uint256 otherLevel = _fees.mul(upLineData.otherLevelRate).div(upLineData.rateBase);
        uint256 totalSend;
        for(uint i=0; i<uplineLevel; i++){
            up = address(sf) == address(0) ? address(0) :sf.upline(down);
            if(up == address(0)){
                break;
            }
            if(_balances[up] < upLineData.miniBalance){
                down = up;
                continue;
            }
            if(i==0){
                _standardTransfer(sender, up, firstLevel);
                totalSend = totalSend.add(firstLevel);
            } else{
                _standardTransfer(sender, up, otherLevel);
                totalSend = totalSend.add(otherLevel);
            }

            down = up;
        }

        if(_fees > totalSend){
            _standardTransfer(sender, uplineManager, _fees.sub(totalSend));
        }
        return ;
    }

    function _caculateFees(address from, address to, uint256 amount, bool isT) internal view returns(
        address user,
        uint256 uplineFee,
        uint256 lpFee,
        uint256 burnFee,
        uint256 tBurnFee,
        uint256 managerFee,
        uint256 fundFee,
        uint256 nftFee
        ) {
        user = isRouter[from] || isPair[from] ? isRouter[to] || isPair[to] ? address(0) : to : from ;
        if(inSwapAndLiquify || user == owner() || exclude[user] || user == address(0)) {
            return (user, 0, 0, 0, 0, 0, 0, 0);
        }

        if(isT && !from.isContract() && !to.isContract() && isDeflation){
            tBurnFee = amount.mul(rates.tBurnRate).div(rates.rateBase);
        } else if(isT && from.isContract() && to == tx.origin){
            lpFee = amount.mul(rates.autoLpRate).div(rates.rateBase);
            uplineFee = amount.mul(rates.uplineRate).div(rates.rateBase);       
        } else if(!isT && isRouter[msg.sender]){
            burnFee = amount.mul(rates.burnRate).div(rates.rateBase);
            managerFee = amount.mul(rates.managerRate).div(rates.rateBase);
            fundFee = amount.mul(rates.fundRate).div(rates.rateBase);
            nftFee = amount.mul(rates.nftRate).div(rates.rateBase);
        }
        
        uint256 totalfee = uplineFee.add(lpFee.add(burnFee.add(tBurnFee.add(managerFee.add(fundFee.add(nftFee))))));
        if(user != address(0) && totalfee >0 && user == from){
            require(amount.add(totalfee) <= _balances[user], "TOKEN TRANSFER: Insufficient balance!");
        }
    }

    /***********************************************************************************************************************/
    /********************************************************初始化*********************************************************/
    /***********************************************************************************************************************/

    function _initialize (
            string memory name_ ,     // 代币名称
            string memory symbol_ ,   // 代币符号
            uint8 decimals_ ,         // 代币精度
            uint256 totalSupply_ ,  // 发行总量
            address manager_ ,
            address fund_ ,
            address uplineManager_ ,
            address nftManager_ ,
            address deflationManager_ ,
            address router_ ,
            address _sf
        ) internal {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(msg.sender, totalSupply_.mul(10**_decimals));
        _initial();

        manager = manager_;
        fund = fund_;
        nftManager = nftManager_;
        uplineManager = uplineManager_;
        deflationManager = deflationManager_;
        sf = ISF(_sf);
        
        defaultRouter = router_;  
        repository = IRepository(address(new Repository(address(this))));
        defaultWbnb =  IRouter(defaultRouter).WETH();
        defaultPair = IPair(IFactory(IRouter(defaultRouter).factory()).createPair(address(this), defaultWbnb));
        pairTokenB[address(defaultPair)] = defaultWbnb;


        isPair[address(defaultPair)] = true;
        isRouter[router_] = true;
        checkedIsNotPair[_sf] = true;
        checkedIsNotRouter[_sf] = true;
        checkedIsNotPair[router_] = true;
        checkedIsNotPair[address(this)] = true;
        checkedIsNotRouter[address(this)] = true;
        checkedIsNotPair[address(msg.sender)] = true;
        checkedIsNotRouter[address(msg.sender)] = true;
        checkedIsNotPair[address(repository)] = true;
        checkedIsNotRouter[address(repository)] = true;
        checkedIsNotRouter[manager_] = true;
        checkedIsNotPair[manager_] = true;
        checkedIsNotPair[defaultWbnb] = true;
        checkedIsNotRouter[defaultWbnb] = true;
        checkedIsNotPair[uplineManager] = true;
        checkedIsNotRouter[uplineManager] = true;

        exclude[msg.sender] = true;
        exclude[manager] = true;
        exclude[fund] = true;
        exclude[nftManager]  = true;
        exclude[address(repository)] = true;
        exclude[uplineManager] = true;
        exclude[_sf] = true;
        _initialized = true;
        
    }

    function _initial() internal {
        uint256 oneToken = 1*10**_decimals;

        autoAddLiquidityAmount = 5*oneToken; 
        enableAntiBot = true;
        botLimit = 30 seconds;
        start = 1675340880;
        except[_msgSender()] = true;

        uint256 _startEpoch = 1672545600 + ((block.timestamp - 1672545600)/1 days +1) * 1 days; 
        _initCompound(MAX, 218 * oneToken, 10000 * oneToken, 540 days, 1 days, _startEpoch);

        BASEDIVIDE = 10000 * oneToken;
        uint256 uplineLevel = 15;
        uint256 firstLevelRate = 300 * oneToken;
        uint256 otherLevelRate = 50 * oneToken; 

        uint256 _uplineRate = firstLevelRate + otherLevelRate * (uplineLevel - 1); 
        uint256 _lpRate = 500 * oneToken;     
        uint256 _burnRate = 250 * oneToken;     
        uint256 _tBurnRate = 1500 * oneToken;   
        uint256 _managerRate = 250 * oneToken;   
        uint256 _fundRate = 580 * oneToken;      
        uint256 _nftRate = 500 * oneToken;

        _initUplineData(uplineLevel, 0, firstLevelRate, otherLevelRate, _uplineRate);       
        _setRates(BASEDIVIDE, _lpRate, _uplineRate, _burnRate, _tBurnRate,_managerRate, _fundRate, _nftRate);
    }

}

contract SunFlower is ERC20 {
    constructor () ERC20(
        "SunFlower",
        "SF", 
        18, 
        25* 1e7, 
        address(0x843A7F4875fBc8d6f0b1E80C381095B60167a9e3),
        address(0xA7237cC3150c802D8812Fa8A83d71c374CC32c60),
        address(0xA29899666c253DbD28C2eA7F5395fc09E0112998),
        address(0xBA84608d1CAF94d8b6642C4EA11b2DEC899299e8),
        address(0x3A5445a73C260bA0C95C2a3Ef40CD09422B0c39a),
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x8FE3416BC1193B655761fcb36A1493a29f6eD409) 
    ){

    }
}