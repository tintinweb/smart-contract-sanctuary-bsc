/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT
// File: contracts\libs\IUniswapAmm.sol

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: contracts\libs\Context.sol

pragma solidity ^0.8.0;

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
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts\libs\Ownable.sol

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\libs\SafeMath.sol

pragma solidity ^0.8.0;

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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts\libs\Address.sol

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
        // solhint-disable-next-line no-inline-assembly
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
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

// File: contracts\libs\IBEP20.sol

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// File: contracts\libs\SafeBEP20.sol

pragma solidity ^0.8.0;




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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// File: contracts\libs\IERC165.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts\libs\IERC721.sol

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: contracts\libs\IERC721Receiver.sol

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: contracts\libs\IERC1155.sol

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: contracts\libs\IERC1155Receiver.sol

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}




contract NxnxNftStaking is Ownable, IERC721Receiver, IERC1155Receiver {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    enum WithdrawLockProperty {
        NO_LOCK, // No withdraw lock
        NEVER_UNLOCKABLE, // Never withdrawable until lock finished
        UNLOCKABLE_WITH_FEE // Withdrawable with fee
    }

    enum NftStakeProperty {
        NO_STAKED, // No nft staked yet
        ERC721_STAKED, // ERC721 staked
        ERC1155_STAKED // ERC1155 staked
    }

    // Whether it is initialized
    bool public isInitialized;
    // The staked token
    IBEP20 public stakedToken;
    // The reward token
    IBEP20 public rewardToken;
    // Reward start / end block
    uint256 public rewardStartBlock;
    uint256 public rewardEndBlock;
    // Freeze start / end block
    uint256 public freezeStartBlock;
    uint256 public freezeEndBlock;
    // The staking max / min limit per user
    uint256 public minStakingPerUser;
    uint256 public maxStakingPerUser;
    // max staking limit
    uint256 public maxStakings;

    // Harvest lock configuration
    uint256 public harvestInterval = 0;
    bool public harvestLockOn = false;
    uint256 public totalLockedUpRewards;

    // Withdraw lock configuration
    WithdrawLockProperty public withdrawLockMethod =
        WithdrawLockProperty.NO_LOCK;
    uint256 public withdrawLockPeriod = 0; // in seconds
    uint16 public withdrawFee = 8000; // 100x multied, 80% default
    uint16 public constant MAX_WITHDRAW_FEE = 8000; // max 80%

    uint256 public PRECISION_FACTOR; // The precision factor

    // Marketing address
    address public marketingAddress;

    // Deposit whitelist configuration
    bool public depositWhitelistOn = false;
    mapping(address => bool) public depositWhitelist;

    uint256 public rewardPerBlock; // reward distributed per block
    uint256 public lastRewardBlock; // Last block number that reward distribution occurs
    uint256 public accRewardPerShare; // Accumlated rewards per share

    uint256 public totalStakings; // Total staking tokens
    uint256 public etmTotalStakings; // Total staking tokens by nft-boosting estimated
    // Extra boost percent by staking NFT
    // mapping(contract_address => mapping (token_id => boostinfo))
    mapping(address => mapping(uint256 => BoostInfo)) private extraBoosts;
    uint256 public constant DEFAULT_BOOST_PERCENT = 1000; // Default amount boost percent for staking nft 10%

    // Stakers
    address[] public userList;
    mapping(address => UserInfo) public userInfo;

    struct BoostInfo {
        uint256 boostPercent; // boost percentage with this nft
        uint256 stakedAmount; // total staked token amount with this nft boosted
    }

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt.
        bool registered; // it will add user in address list on first deposit
        address addr; //address of user
        uint256 rewardLocked; // Reward locked up.
        uint256 lastHarvestedAt; // Last harvested time
        uint256 lastDepositedAt; // Last withdrawn time
        NftStakeProperty nftStakeStatus; // Nft staking will lead apr increase
        address nftAddress;
        uint256 nftTokenId;
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event NftDeposited(
        address indexed account,
        bool isERC721,
        address nftAddress,
        uint256 nftTokenId
    );
    event Deposited(address indexed account, uint256 amount);
    event NftWithdrawn(
        address indexed account,
        bool isERC721,
        address nftAddress,
        uint256 nftTokenId
    );
    event Withdrawn(address indexed account, uint256 amount);
    event UserRewarded(address indexed account, uint256 amount);
    event RewardLocked(address indexed account, uint256 amount);
    event EmergencyWithdrawn(address indexed account, uint256 amount);
    event EmergencyRewardWithdrawn(address indexed account, uint256 amount);

    modifier whenNotFrozen() {
        require(!isFrozen(), "Frozen...");
        _;
    }

    /**
     * @notice Initialize the contract
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block
     * @param _rewardStartBlock: start block
     * @param _rewardEndBlock: end block
     * @param _maxStakingPerUser: max limit per user in stakedToken (if any, else 0)
     * @param _minStakingPerUser: min limit per user in stakedToken (if any, else 0)
     * @param _maxStakings: max limit totalStaking (if any, else 0)
     * @param _admin: admin address with ownership
     */
    function initialize(
        IBEP20 _stakedToken,
        IBEP20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _rewardStartBlock,
        uint256 _rewardEndBlock,
        uint256 _maxStakingPerUser,
        uint256 _minStakingPerUser,
        uint256 _maxStakings,
        address _admin
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");
        require(_rewardPerBlock > 0, "Invalid rewardPerBlock");
        require(
            block.number < _rewardStartBlock &&
                _rewardStartBlock <= _rewardEndBlock,
            "Invalid blocks"
        );

        require(
            _maxStakingPerUser == 0 || _minStakingPerUser <= _maxStakingPerUser,
            "Invalid staking limits"
        );

        // Make this contract initialized
        isInitialized = true;

        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        rewardStartBlock = _rewardStartBlock;
        rewardEndBlock = _rewardEndBlock;
        minStakingPerUser = _minStakingPerUser;
        maxStakingPerUser = _maxStakingPerUser;
        maxStakings = _maxStakings;

        uint256 decimalsRewardToken = uint256(rewardToken.decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");

        PRECISION_FACTOR = uint256(10**(uint256(30).sub(decimalsRewardToken)));

        lastRewardBlock = _rewardStartBlock; // Set the last reward block as the start block

        // Transfer ownership to the admin address who becomes owner of the contract
        transferOwnership(_admin);
    }

    function balanceOf(address _account) external view returns (uint256) {
        UserInfo storage user = userInfo[_account];
        return user.amount;
    }

    /**
     * @notice get boosted user balance with nft staked
     */
    function getEtmBalance(
        uint256 _amount,
        bool _nftBoosted,
        address _nftAddress,
        uint256 _nftTokenId
    ) private view returns (uint256) {
        if (!_nftBoosted || _amount == 0) {
            return _amount;
        }

        // calculate boosted amount when a nft is staked
        uint256 boostMultiplier = 10000;
        if (extraBoosts[_nftAddress][_nftTokenId].boostPercent > 0) {
            boostMultiplier = boostMultiplier.add(
                extraBoosts[_nftAddress][_nftTokenId].boostPercent
            );
        } else {
            boostMultiplier = boostMultiplier.add(DEFAULT_BOOST_PERCENT);
        }
        return _amount.mul(boostMultiplier).div(10000);
    }

    /**
     * @notice Deposit nft, then the staked token amount will be boosted
     */
    function depositNft(
        address _nftAddress,
        uint256 _nftTokenId,
        bool _isERC721
    ) external whenNotFrozen {
        require(
            depositWhitelistOn == false ||
                depositWhitelist[_msgSender()] == true,
            "Address not in whitelist"
        );

        UserInfo storage user = userInfo[_msgSender()];
        require(
            user.nftStakeStatus == NftStakeProperty.NO_STAKED,
            "Another NFT staked already"
        );

        updatePool();
        payOrLockupPendingReward();

        if (_isERC721) {
            require(
                IERC721(_nftAddress).isApprovedForAll(
                    _msgSender(),
                    address(this)
                ),
                "NFT not approved for the staking contract"
            );
            IERC721(_nftAddress).safeTransferFrom(
                _msgSender(),
                address(this),
                _nftTokenId
            );
            user.nftStakeStatus = NftStakeProperty.ERC721_STAKED;
        } else {
            require(
                IERC1155(_nftAddress).isApprovedForAll(
                    _msgSender(),
                    address(this)
                ),
                "NFT not approved for the staking contract"
            );
            IERC1155(_nftAddress).safeTransferFrom(
                _msgSender(),
                address(this),
                _nftTokenId,
                1,
                ""
            );
            user.nftStakeStatus = NftStakeProperty.ERC1155_STAKED;
        }
        user.nftAddress = _nftAddress;
        user.nftTokenId = _nftTokenId;
        // increase stakedAmount for nft address + token id
        extraBoosts[_nftAddress][_nftTokenId].stakedAmount = extraBoosts[
            _nftAddress
        ][_nftTokenId].stakedAmount.add(user.amount);
        // handle with nft boosted amount
        uint256 etmAmount = getEtmBalance(
            user.amount,
            true,
            _nftAddress,
            _nftTokenId
        );
        etmTotalStakings = etmTotalStakings.add(etmAmount).sub(user.amount);
        user.rewardDebt = etmAmount.mul(accRewardPerShare).div(
            PRECISION_FACTOR
        );

        emit NftDeposited(_msgSender(), _isERC721, _nftAddress, _nftTokenId);
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function deposit(uint256 _amount) external whenNotFrozen {
        require(
            depositWhitelistOn == false ||
                depositWhitelist[_msgSender()] == true,
            "Address not in whitelist"
        );

        UserInfo storage user = userInfo[_msgSender()];
        require(
            _amount.add(user.amount) >= minStakingPerUser,
            "User amount below minimum"
        );
        require(
            maxStakingPerUser == 0 ||
                _amount.add(user.amount) <= maxStakingPerUser,
            "User amount above maximum"
        );
        require(
            maxStakings == 0 ||
                totalStakings.add(_amount) <= maxStakings,
            "Pool is Full"
        );

        updatePool();
        payOrLockupPendingReward();

        if (user.amount == 0 && user.registered == false) {
            userList.push(msg.sender);
            user.registered = true;
            user.addr = address(msg.sender);
        }

        if (_amount > 0) {
            // Every time when there is a new deposit, reset last withdrawn time
            user.lastDepositedAt = block.timestamp;

            uint256 balanceBefore = stakedToken.balanceOf(address(this));
            stakedToken.safeTransferFrom(
                address(_msgSender()),
                address(this),
                _amount
            );
            _amount = stakedToken.balanceOf(address(this)).sub(balanceBefore);

            user.amount = user.amount.add(_amount);
            totalStakings = totalStakings.add(_amount);

            if (user.nftStakeStatus != NftStakeProperty.NO_STAKED) {
                extraBoosts[user.nftAddress][user.nftTokenId]
                    .stakedAmount = extraBoosts[user.nftAddress][
                    user.nftTokenId
                ].stakedAmount.add(_amount); // add staked amount for the nftAddress + tokenId
                _amount = getEtmBalance(
                    _amount,
                    true,
                    user.nftAddress,
                    user.nftTokenId
                );
            }
            etmTotalStakings = etmTotalStakings.add(_amount);

            emit Deposited(msg.sender, _amount);
        }
        uint256 userAmount = getEtmBalance(
            user.amount,
            user.nftStakeStatus != NftStakeProperty.NO_STAKED,
            user.nftAddress,
            user.nftTokenId
        );
        user.rewardDebt = userAmount.mul(accRewardPerShare).div(
            PRECISION_FACTOR
        );
    }

    function withdrawNft() external whenNotFrozen {
        UserInfo storage user = userInfo[_msgSender()];
        require(
            user.nftStakeStatus != NftStakeProperty.NO_STAKED,
            "No nft staked yet"
        );

        updatePool();
        payOrLockupPendingReward();

        if (user.nftStakeStatus == NftStakeProperty.ERC721_STAKED) {
            IERC721(user.nftAddress).safeTransferFrom(
                address(this),
                _msgSender(),
                user.nftTokenId
            );
        } else {
            IERC1155(user.nftAddress).safeTransferFrom(
                address(this),
                _msgSender(),
                user.nftTokenId,
                1,
                ""
            );
        }

        emit NftWithdrawn(
            _msgSender(),
            user.nftStakeStatus == NftStakeProperty.ERC721_STAKED,
            user.nftAddress,
            user.nftTokenId
        );

        // It should update etmTotalStakings because nft is unstaked, user etmBalance will be lowered
        uint256 userAmount = getEtmBalance(
            user.amount,
            true,
            user.nftAddress,
            user.nftTokenId
        );
        etmTotalStakings = etmTotalStakings.add(user.amount).sub(userAmount);

        user.nftStakeStatus = NftStakeProperty.NO_STAKED;
        user.nftAddress = address(0);
        user.nftTokenId = 0;

        user.rewardDebt = user.amount.mul(accRewardPerShare).div(
            PRECISION_FACTOR
        );
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external whenNotFrozen {
        require(_amount > 0, "zero amount");
        UserInfo storage user = userInfo[_msgSender()];
        require(user.amount >= _amount, "Amount to withdraw too high");
        require(totalStakings >= _amount, "Exceed total staking amount");

        updatePool();
        payOrLockupPendingReward();

        (bool withdrawAvailable, uint256 feeAmount) = canWithdraw(
            _msgSender(),
            _amount
        );
        require(withdrawAvailable, "Withdraw locked");
        if (withdrawAvailable) {
            user.amount = user.amount.sub(_amount);
            totalStakings = totalStakings.sub(_amount);

            if (feeAmount > 0 && marketingAddress != address(0)) {
                stakedToken.safeTransfer(marketingAddress, feeAmount);
                _amount = _amount.sub(feeAmount);
            }

            if (_amount > 0) {
                stakedToken.safeTransfer(_msgSender(), _amount);
            }

            emit Withdrawn(_msgSender(), _amount);

            if (user.nftStakeStatus != NftStakeProperty.NO_STAKED) {
                extraBoosts[user.nftAddress][user.nftTokenId]
                    .stakedAmount = extraBoosts[user.nftAddress][
                    user.nftTokenId
                ].stakedAmount.sub(_amount);
                _amount = getEtmBalance(
                    _amount,
                    true,
                    user.nftAddress,
                    user.nftTokenId
                );
            }
            etmTotalStakings = etmTotalStakings.sub(_amount);
        }
        uint256 userAmount = getEtmBalance(
            user.amount,
            user.nftStakeStatus != NftStakeProperty.NO_STAKED,
            user.nftAddress,
            user.nftTokenId
        );
        user.rewardDebt = userAmount.mul(accRewardPerShare).div(
            PRECISION_FACTOR
        );
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external whenNotFrozen {
        UserInfo storage user = userInfo[_msgSender()];

        uint256 userAmount = getEtmBalance(
            user.amount,
            user.nftStakeStatus != NftStakeProperty.NO_STAKED,
            user.nftAddress,
            user.nftTokenId
        );
        etmTotalStakings = etmTotalStakings.sub(userAmount);
        user.rewardDebt = 0;

        if (user.amount > 0) {
            stakedToken.safeTransfer(_msgSender(), user.amount);
            totalStakings = totalStakings.sub(user.amount);

            emit EmergencyWithdrawn(_msgSender(), user.amount);
            user.amount = 0;
        }

        if (user.nftStakeStatus != NftStakeProperty.NO_STAKED) {
            if (user.nftStakeStatus == NftStakeProperty.ERC721_STAKED) {
                IERC721(user.nftAddress).safeTransferFrom(
                    address(this),
                    _msgSender(),
                    user.nftTokenId
                );
            } else {
                IERC1155(user.nftAddress).safeTransferFrom(
                    address(this),
                    _msgSender(),
                    user.nftTokenId,
                    1,
                    ""
                );
            }

            emit NftWithdrawn(
                _msgSender(),
                user.nftStakeStatus == NftStakeProperty.ERC721_STAKED,
                user.nftAddress,
                user.nftTokenId
            );

            user.nftStakeStatus = NftStakeProperty.NO_STAKED;
            user.nftAddress = address(0);
            user.nftTokenId = 0;
        }
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        uint256 availableRewardAmount = rewardToken.balanceOf(address(this));
        // when staked token and reward token same, it should not occupy the staked amount
        if (address(stakedToken) == address(rewardToken)) {
            availableRewardAmount = availableRewardAmount.sub(totalStakings);
        }
        require(availableRewardAmount >= _amount, "Too much amount");

        rewardToken.safeTransfer(_msgSender(), _amount);
        emit EmergencyRewardWithdrawn(_msgSender(), _amount);
    }

    /**
     * @notice View function to see if user can withdraw.
     */
    function canWithdraw(address _user, uint256 _amount)
        public
        view
        returns (bool _available, uint256 _feeAmount)
    {
        UserInfo storage user = userInfo[_user];
        _available =
            user.amount >= _amount &&
            !(withdrawLockMethod == WithdrawLockProperty.NEVER_UNLOCKABLE &&
                block.timestamp < user.lastDepositedAt.add(withdrawLockPeriod));
        if (
            withdrawLockMethod == WithdrawLockProperty.UNLOCKABLE_WITH_FEE &&
            block.timestamp < user.lastDepositedAt.add(withdrawLockPeriod)
        ) {
            _feeAmount = _amount.mul(withdrawFee).div(10000);
        }
    }

    /**
     * @notice View function to see if user can harvest.
     */
    function canHarvest(address _user) public view returns (bool) {
        UserInfo storage user = userInfo[_user];
        return
            !harvestLockOn ||
            block.timestamp >= user.lastHarvestedAt.add(harvestInterval);
    }

    /**
     * @notice Pay or lockup pending rewards.
     */
    function payOrLockupPendingReward() internal {
        UserInfo storage user = userInfo[_msgSender()];

        uint256 pending = pendingReward(_msgSender());
        if (user.amount == 0) {
            user.lastHarvestedAt = block.timestamp;
        }
        if (canHarvest(_msgSender())) {
            if (pending > 0) {
                // Safe transfer rewards
                uint256 rewardTokenBal = rewardToken.balanceOf(address(this));
                uint256 rewardTransferred = pending > rewardTokenBal
                    ? rewardTokenBal
                    : pending;

                if (rewardTransferred > 0) {
                    rewardToken.safeTransfer(_msgSender(), rewardTransferred);
                    emit UserRewarded(_msgSender(), rewardTransferred);
                    user.lastHarvestedAt = block.timestamp;
                }
                if (pending > rewardTransferred) {
                    emit RewardLocked(
                        _msgSender(),
                        pending.sub(rewardTransferred)
                    );
                }
                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards
                    .add(pending)
                    .sub(user.rewardLocked)
                    .sub(rewardTransferred);
                user.rewardLocked = pending.sub(rewardTransferred);
            }
        } else if (pending > 0) {
            user.rewardLocked = user.rewardLocked.add(pending);
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLocked(_msgSender(), pending);
        }
    }

    /**
     * @notice Update reward variables of the pool to be up-to-date.
     */
    function updatePool() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }

        if (totalStakings == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
        uint256 rewardAccum = multiplier.mul(rewardPerBlock);
        accRewardPerShare = accRewardPerShare.add(
            rewardAccum.mul(PRECISION_FACTOR).div(etmTotalStakings)
        ); // formula changed from totalStakings to etmTotalStakings
        lastRewardBlock = block.number;
    }

    /**
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= rewardEndBlock) {
            return _to.sub(_from);
        } else if (_from >= rewardEndBlock) {
            return 0;
        } else {
            return rewardEndBlock.sub(_from);
        }
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _account: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _account)
        public
        view
        returns (uint256 rewardAmount)
    {
        UserInfo storage user = userInfo[_account];
        uint256 adjustedTokenPerShare = accRewardPerShare;
        if (etmTotalStakings > 0 && block.number > lastRewardBlock) {
            uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
            uint256 rewardAccum = multiplier.mul(rewardPerBlock);
            adjustedTokenPerShare = accRewardPerShare.add(
                rewardAccum.mul(PRECISION_FACTOR).div(etmTotalStakings)
            );
        }
        uint256 userAmount = getEtmBalance(
            user.amount,
            user.nftStakeStatus != NftStakeProperty.NO_STAKED,
            user.nftAddress,
            user.nftTokenId
        );

        rewardAmount = userAmount.mul(adjustedTokenPerShare).div(
            PRECISION_FACTOR
        );
        // Always rewardAmount > user.rewardDebt, but when nft boost percent lowered, it might rewardAmount < user.rewardDebt
        if (rewardAmount > user.rewardDebt) {
            rewardAmount = rewardAmount.sub(user.rewardDebt);
        } else {
            rewardAmount = 0;
        }
        rewardAmount = rewardAmount.add(user.rewardLocked);
    }

    /**
     * @dev Update the reward per block
     * Can only be called by the owner.
     */
    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        require(_rewardPerBlock > 0, "Invalid rewardPerBlock");
        rewardPerBlock = _rewardPerBlock;
    }

    /**
     * @notice Update additional boost percentage for the specific nft and id
     * @dev Can only be called by the owner
     */
    function updateExtraBoost(
        address _nftAddress,
        uint256 _nftTokenId,
        uint256 _percent
    ) external onlyOwner {
        require(_percent > 0, "Invalid boost percent");
        uint256 _etmTotalStakings = etmTotalStakings; // gas savings
        uint256 oldPercent = extraBoosts[_nftAddress][_nftTokenId].boostPercent;
        if (oldPercent == 0) {
            oldPercent = DEFAULT_BOOST_PERCENT;
        }
        uint256 stakedAmountWithThisNft = extraBoosts[_nftAddress][_nftTokenId]
            .stakedAmount;
        _etmTotalStakings = _etmTotalStakings.add(
            stakedAmountWithThisNft.mul(_percent).div(10000)
        ); // add the boosted amount with new percent
        _etmTotalStakings = _etmTotalStakings.sub(
            stakedAmountWithThisNft.mul(oldPercent).div(10000)
        ); // susstrat the boosted amount with old percent
        extraBoosts[_nftAddress][_nftTokenId].boostPercent = _percent;
        etmTotalStakings = _etmTotalStakings;
        updatePool();
    }

    /*
     * @notice isFrozed returns if contract is frozen, user cannot call deposit, withdraw, emergencyWithdraw function
     */
    function isFrozen() public view returns (bool) {
        return
            block.number >= freezeStartBlock && block.number <= freezeEndBlock;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(stakedToken) &&
                _tokenAddress != address(rewardToken),
            "Cannot be staked token"
        );

        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner
     */
    function stopReward() external onlyOwner {
        require(rewardEndBlock > block.number, "Already stopped");
        rewardEndBlock = block.number;
    }

    /*
     * @notice Stop Freeze
     * @dev Only callable by owner
     */
    function stopFreeze() external onlyOwner {
        freezeStartBlock = 0;
        freezeEndBlock = 0;
    }

    /*
     * @notice Enable/disable deposit whitelist
     * @dev Only callable by owner
     */
    function enableDepositWhitelist(bool _on) external onlyOwner {
        depositWhitelistOn = _on;
    }

    /*
     * @notice Add/remove address from whitelist
     * @dev Only callable by owner
     */
    function updateDepositWhitelist(address _address, bool _on)
        external
        onlyOwner
    {
        depositWhitelist[_address] = _on;
    }

    /**
     * @dev Update harvest lock configuration
     * @dev Only callable by owner
     */
    function configureHarvestLock(bool _lockOn, uint256 _interval)
        external
        onlyOwner
    {
        if (_lockOn) {
            require(_interval > 0, "Invalid interval in lock mode");
        }
        harvestLockOn = _lockOn;
        harvestInterval = _interval;
    }

    /**
     * @notice Update withdraw configuration
     * @dev Only callable by owner
     */
    function configureWithdrawLock(
        WithdrawLockProperty _method,
        uint256 _period,
        uint16 _fee
    ) external onlyOwner {
        require(_fee <= MAX_WITHDRAW_FEE, "Invalid fee");
        if (_method != WithdrawLockProperty.NO_LOCK) {
            require(_period > 0, "Invalid interval in lock mode");
        }
        withdrawLockMethod = _method;
        withdrawLockPeriod = _period;
        withdrawFee = _fee;
    }

    /*
     * @notice Update marketing address
     * @dev Only callable by owner
     */
    function updateMarketingAddress(address _marketingAddress)
        external
        onlyOwner
    {
        require(_marketingAddress != address(0), "");
        marketingAddress = _marketingAddress;
    }

    /*
     * @notice Update staking limit per user
     * @dev Only callable by owner.
     * @param _minStakingPerUser: min staking limit per user
     * @param _maxStakingPerUser: max staking limit per user
     */
    function updateStakingLimitPerUser(
        uint256 _minStakingPerUser,
        uint256 _maxStakingPerUser
    ) external onlyOwner {
        require(
            _maxStakingPerUser == 0 || _minStakingPerUser <= _maxStakingPerUser,
            "Invalid limit values"
        );
        minStakingPerUser = _minStakingPerUser;
        maxStakingPerUser = _maxStakingPerUser;
    }

    /**
     * @notice It allows the admin to update start and end blocks
     * @dev This function is only callable by owner.
     * @param _rewardStartBlock: the new start block
     * @param _rewardEndBlock: the new end block
     */
    function updateRewardBlocks(
        uint256 _rewardStartBlock,
        uint256 _rewardEndBlock
    ) external onlyOwner {
        require(block.number < rewardStartBlock, "Pool started already");
        require(
            _rewardStartBlock < _rewardEndBlock,
            "Start block must be before end block"
        );
        require(
            block.number < _rewardStartBlock,
            "Start block must be after now"
        );

        rewardStartBlock = _rewardStartBlock;
        rewardEndBlock = _rewardEndBlock;
    }

    /**
     * @notice It allows the admin to update freeze start and end blocks
     * @dev This function is only callable by owner.
     * @param _freezeStartBlock: the new freeze start block
     * @param _freezeEndBlock: the new freeze end block
     */
    function updateFreezeBlocks(
        uint256 _freezeStartBlock,
        uint256 _freezeEndBlock
    ) external onlyOwner {
        require(
            _freezeStartBlock < _freezeEndBlock,
            "Freeze start block must be before end block"
        );
        require(
            block.number < _freezeStartBlock,
            "Free start block must be after now"
        );

        freezeStartBlock = _freezeStartBlock;
        freezeEndBlock = _freezeEndBlock;
    }

    /*
     * @notice return length of user addresses
     */
    function getUserListLength() external view returns (uint256) {
        return userList.length;
    }

    /*
     * @notice View function to get users.
     * @param _offset: offset for paging
     * @param _limit: limit for paging
     * @return get users, next offset and total users
     */
    function getUsersPaging(uint256 _offset, uint256 _limit)
        public
        view
        returns (
            UserInfo[] memory users,
            uint256 nextOffset,
            uint256 total
        )
    {
        total = userList.length;
        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > total.sub(_offset)) {
            _limit = total.sub(_offset);
        }
        nextOffset = _offset.add(_limit);

        users = new UserInfo[](_limit);
        for (uint256 i = 0; i < _limit; i++) {
            users[i] = userInfo[userList[_offset.add(i)]];
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*id*/
        uint256, /*value*/
        bytes calldata /*data*/
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address, /*from*/
        uint256[] calldata, /*ids*/
        uint256[] calldata, /*values*/
        bytes calldata /*data*/
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 /*interfaceId*/
    ) public view virtual override returns (bool) {
        return false;
    }
}