/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via address(msg.sender) and msg.data, they should not be accessed in such a direct
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing BEP721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

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
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

/**
 * @title BEP20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IBEP20Metadata is IBEP20 {
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

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of BEP20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
abstract contract BEP20 is Context, IBEP20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
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
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
        uint256 amount
    ) internal virtual {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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
            require(
                currentAllowance >= amount,
                "BEP20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

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
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a pBEPentage of the total
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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

/**
 * ----------------------
 * SeedSale Launchpad contract
 * ----------------------
 * @author codethebasics
 */
contract EvocLaunchpad is Ownable, ReentrancyGuard {
    // SafeMath library And Address
    using SafeMath for uint256;
    using Address for address;

    //Ballances of tokens to Partners
    struct Balances {
        uint amount;
    }

    //System of Referal
    struct User_Config {
        mapping (string => Balances) payOut;
        uint256 balance;
        uint256 maxAmount;
        address referAddress;
        uint256 referReward;
        uint256 refersTotal;
        uint256 timestamp;
        bool claimTokens;
        bool exist;
    }
    
    //Partner values List
    struct Partner_Values {
        uint256 _softCap; //Min Amaunt to Sell
        uint256 _hardCap; //Max Amaunt to Sell
        uint256 _launchPriceRate; //Estimated launch price
        uint256 _listingPriceRate; //Estimated Price Listing Sale
        uint256 _totalRemaining; //Total token remaining for sale
        uint256 _totalTokenSold; //Total tokens sold
    }

    //Partner Status List
    struct Partner_Status {
        address _tokenPair;
        uint256 _liquidityPercentage;
        uint256 _timeInit;
        uint256 _timeEnd;
        bool _status;
    }

    //Partner Refer List
    struct Partner_Refer {
        uint256 _referBonusPercent;
        uint256 _referVesting;
        bool _referActive;
    }

    //Partner register List
    uint private partnerId_;
    struct Partner_register {
        address _OwnerAdd;
        address _contractAdd;
        uint256 _bonusPercent;
        uint256 _maxUserAmount; //Maximo Amount tokens buy for Users
        string[] _paymentType; //["BNB", "BUSD", "USDT", "PIX"]
        mapping (string => Balances) Balance;
        mapping (address => User_Config) UserConfig;
        Partner_Values PartnerValues;
        Partner_Status PartnerStatus;
        Partner_Refer PartnerRefer;
        bool isClaiming;
        bool exist;
    }
    mapping(uint => Partner_register) public PartnerRegister;

    //Token Project price
    uint256 private feeCreateProject;
    uint256 private feeTransPercent;
    mapping(address => bool) public isFeeExempt;

    //Address Managements
    address private bnbAddress_;
    address private busdAddress_;
    address private usdtAddress_;
    IUniswapV2Pair internal _bnbBusdPair;
    IUniswapV2Router02 internal pckRouterAddress_;
    IUniswapV2Router02 internal evcRouterAddress_;

    // Wallets For WithDraw
    address private _companyAddress;
    uint256 private _DECIMALFACTOR = 10**uint256(18);

    bool _pause = false;
    modifier isPausable() {
        require(!_pause, "The Contract is paused. Presale is paused");
        _;
    }

    //Lock in Swap Process
    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    uint256 private numTokensSellToAddToLiquidity;

    constructor(
        uint256 _feeCreateProject,
        uint256 _feeTransPercent,
        address _wBNBAddress,
        address _busdAddress,
        address _usdtAddress,
        address _BnbBusdPair,
        address _pckRouterAddress,
        address _evcRouterAddress
    ) {
        // Token owner
        _owner = msg.sender;
        _companyAddress = msg.sender;
        feeCreateProject = _feeCreateProject;
        feeTransPercent = _feeTransPercent;
        bnbAddress_ = _wBNBAddress;
        busdAddress_ = _busdAddress;
        usdtAddress_ = _usdtAddress;
        _bnbBusdPair = IUniswapV2Pair(_BnbBusdPair);
        pckRouterAddress_ = IUniswapV2Router02(_pckRouterAddress);
        evcRouterAddress_ = IUniswapV2Router02(_evcRouterAddress);        
    }

    function totalBalance() external view returns (uint256) {
        return payable(address(this)).balance;
    }

    function balanceOf(uint256 launchId, address account)
        public view returns (uint256 amount)
    {
        return PartnerRegister[launchId].UserConfig[account].balance;
    }

    function balanceOfPayment(uint256 launchId, address account, string memory tokenName)
        public view returns (uint256 amount)
    {
        return PartnerRegister[launchId].UserConfig[account].payOut[tokenName].amount;
    }

    function getCompanyAddress() public view returns (address) {
        return _companyAddress;
    }

    function getFeeCreateProject() public view returns (uint256) {
        return feeCreateProject;
    }

    function getFeeTransPercent() public view returns (uint256) {
        return feeTransPercent;
    }

    /*get getPartner Id*/
    function getCurrentPartnerId() public view returns(uint256 partnerId){
        return partnerId_;
    }

    function getPartnerIds(address ContractAddress)
        public view returns (uint256[] memory)
    {
        uint256[] memory partnerIds = new uint256[](partnerId_);
        for (uint256 i; i < partnerId_; i++) {
            if(address(PartnerRegister[i]._contractAdd) == address(ContractAddress)){
               partnerIds[i] = i;
            }
        }

        return partnerIds;
    }

    /*get getPartnerDetails*/
    function getPartnerDetails(uint PartnerId)
        public view returns (
            uint256 bonusPercent,
            address contractAdd,
            address ownerAddress,
            uint256 maxUserAmount,
            uint256 liquidityPercent,
            uint256 timeInit,
            uint256 timeEnd
        )
    {
        Partner_register storage item = PartnerRegister[PartnerId];
        return (
           item._bonusPercent,
           item._contractAdd,
           item._OwnerAdd,
           item._maxUserAmount,
           item.PartnerStatus._liquidityPercentage,
           item.PartnerStatus._timeInit,
           item.PartnerStatus._timeEnd
        );
    }

    function getPartnerValues(uint PartnerId) 
        public view returns (
            uint256 softCap,
            uint256 hardCap,
            uint256 launchPriceRate,
            uint256 listingPriceRate,
            uint256 totalRemaining,
            uint256 totalTokenSold
        )
    {
        Partner_register storage item = PartnerRegister[PartnerId];
        return (
            item.PartnerValues._softCap,
            item.PartnerValues._hardCap,
            item.PartnerValues._launchPriceRate,
            item.PartnerValues._listingPriceRate,
            item.PartnerValues._totalRemaining,
            item.PartnerValues._totalTokenSold
        );
    }

    function getPartnerReferConfig(uint PartnerId)
        public view returns (
            uint256 bonusReferPercent,
            uint256 referVesting,
            bool referActive
        )
    {
        Partner_register storage item = PartnerRegister[PartnerId];
        return (
            item.PartnerRefer._referBonusPercent,
            item.PartnerRefer._referVesting,
            item.PartnerRefer._referActive
        );
    }    

    function getPartnerStatus (uint256 PartnerId)
        public view returns (
            uint256 timeInit,
            uint256 timeEnd,
            bool status,
            bool isClaiming
        )
    {
        Partner_register storage item = PartnerRegister[PartnerId];
        return (
            item.PartnerStatus._timeInit,
            item.PartnerStatus._timeEnd,
            item.PartnerStatus._status,
            item.isClaiming
        );
    }

    function ContractStatusPause() public view returns (bool) {
        return _pause;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}

    function buyWithToken(
        uint PartnerId,
        uint256 tokenAmount,
        string memory tkName,
        address refer
    ) public nonReentrant isPausable {
        require(partnerStatus(PartnerId) == 1, "Launchpad Not Active");
        Partner_register storage item = PartnerRegister[PartnerId];
        require(tokenAmount > 0, "Insufficient amount for this transaction");
        if(!item.UserConfig[msg.sender].exist){
            item.UserConfig[msg.sender].maxAmount = tokenAmount;
            item.UserConfig[msg.sender].exist = true;
        }else{            
            item.UserConfig[msg.sender].maxAmount += tokenAmount;
        }

        require(
            item.UserConfig[msg.sender].maxAmount <= item._maxUserAmount,
            "Quantity requested exceeds maximum purchase limit"
        );
        
        address payAddress = _getPayAddress(tkName);
        require(
            payAddress != address(0),
            "The address is invalid, check the currency type."
        );

        uint256 tkAmount = item.PartnerValues._launchPriceRate.mul(tokenAmount);
        uint256 amountPrice = getPriceInBnb(tkAmount);

        item.Balance[tkName].amount += amountPrice;
        item.UserConfig[msg.sender].payOut[tkName].amount += amountPrice;

        IBEP20 ContractToken = IBEP20(payAddress);
        uint256 dexBalance = ContractToken.balanceOf(msg.sender);
        require(
            amountPrice > 0 && amountPrice <= dexBalance,
            "Insufficient amount for this transaction"
        );
        require(
            ContractToken.transferFrom(
                msg.sender,
                address(this),
                amountPrice
            ),
            "A transaction error has occurred. Check for approval."
        );

        // Increasing total raised
        item.PartnerValues._totalRemaining -= tokenAmount;
        item.PartnerValues._totalTokenSold += tokenAmount;
        uint256 bonusPercent = tokenAmount.mul(item._bonusPercent).div(100);
        uint256 newBalance = tokenAmount + bonusPercent;
        if(item.PartnerRefer._referActive){
            if(!item.UserConfig[refer].exist){
                item.UserConfig[refer].referAddress = refer;
                item.UserConfig[refer].refersTotal++;
                item.UserConfig[refer].timestamp = block.timestamp;
                item.UserConfig[refer].exist = true;
            }

            uint256 referReward = (tokenAmount * item.PartnerRefer._referBonusPercent).div(100);
            item.UserConfig[refer].balance += referReward;
            item.UserConfig[refer].referReward += referReward;
        }

        item.UserConfig[msg.sender].balance += newBalance;
        emit buyTokensSuccess(msg.sender, tokenAmount, amountPrice, tkName);
    }

    function buyWithBNB(
        uint PartnerId, 
        uint256 tokenAmount, 
        address refer
    ) public payable nonReentrant isPausable {
        require(partnerStatus(PartnerId) == 1, "Launchpad Not Active");
        Partner_register storage item = PartnerRegister[PartnerId];
        require(tokenAmount > 0, "Insufficient amount for this transaction");
        uint256 amount = item.PartnerValues._launchPriceRate.mul(tokenAmount);
        require(
            amount > 0 && msg.value >= amount,
            "Insufficient amount for this transaction"
        );

        if(!item.UserConfig[msg.sender].exist){
            item.UserConfig[msg.sender].maxAmount = tokenAmount;
            item.UserConfig[msg.sender].exist = true;
        }else{            
            item.UserConfig[msg.sender].maxAmount += tokenAmount;
        }
        
        item.Balance["BNB"].amount += amount;
        item.UserConfig[msg.sender].payOut["BNB"].amount += amount;
        payable(address(this)).transfer(amount);

        // Increasing total raised
        item.PartnerValues._totalRemaining -= tokenAmount;
        item.PartnerValues._totalTokenSold += tokenAmount;
        uint256 bonusPercent = tokenAmount.mul(item._bonusPercent).div(100);
        uint256 newBalance = tokenAmount + bonusPercent;
        if(item.PartnerRefer._referActive){
            if(!item.UserConfig[refer].exist){
                item.UserConfig[refer].referAddress = refer;
                item.UserConfig[refer].refersTotal++;
                item.UserConfig[refer].timestamp = block.timestamp;
                item.UserConfig[refer].exist = true;
            }

            uint256 referReward = (tokenAmount * item.PartnerRefer._referBonusPercent).div(100);
            item.UserConfig[refer].balance += referReward;
            item.UserConfig[refer].referReward += referReward;
        }

        item.UserConfig[msg.sender].balance += newBalance;
        emit buyTokensSuccess(msg.sender, tokenAmount, amount, "BNB");
    }

    function claimTokens(uint PartnerId)
        public nonReentrant isPausable
    {
        address wallet = msg.sender;
        Partner_register storage item = PartnerRegister[PartnerId];
        uint256 balance = balanceOf(PartnerId, wallet);
        require(
            wallet != address(0) && 
            item.UserConfig[wallet].exist,
            "To make the withdrawal, you need to register a valid address."
        );
        require(
            item.isClaiming && item.PartnerStatus._status,
            "The project has not yet been released to claim."
        );
        require(
            balance > 0,
            "You do not have enough balance for this withdrawal"
        );

        if(!item.PartnerRefer._referActive){
            IBEP20 tokenAddr = IBEP20(item._contractAdd);
            tokenAddr.transfer(wallet, balance);
            item.UserConfig[wallet].balance -= balance;
        }else if(
            item.PartnerRefer._referActive &&
            item.UserConfig[wallet].refersTotal > 0 &&
            item.UserConfig[wallet].timestamp <= block.timestamp
        ){
            uint256 amountClaim = balance.mul(item.PartnerRefer._referVesting).div(100);
            IBEP20 tokenAddr = IBEP20(item._contractAdd);
            tokenAddr.transfer(wallet, amountClaim);
            item.UserConfig[wallet].balance -= amountClaim;
            item.UserConfig[wallet].timestamp = block.timestamp+item.PartnerRefer._referVesting;
        }else{
            revert("You have not reached the venting deadline to claim.");
        }

        item.UserConfig[wallet].claimTokens = true;

        emit WithdrawnUser(
            wallet,
            balance,
            item._contractAdd
        );
    }

    function claimFunds(uint PartnerId)
        public nonReentrant isPausable
    {
        address wallet = msg.sender;
        Partner_register storage item = PartnerRegister[PartnerId];
        require(
            !item.PartnerStatus._status,
            "The project has not yet been released to claim."
        );
        require(
            !item.UserConfig[wallet].claimTokens,
            "Cannot redeem value, as you have already made token withdrawals."
        );
        require(
            wallet != address(0),
            "To make the withdrawal, you need to register a valid address."
        );

        for (uint i = 0; i < item._paymentType.length; i++) {
            uint256 balance = balanceOfPayment(PartnerId, wallet, item._paymentType[i]);
            if(balance > 0){
                if(_compareString(item._paymentType[i], "BNB")){
                    payable(wallet).transfer(balance);
                    item.UserConfig[wallet].payOut["BNB"].amount = 0;
                    emit WithdrawnUser(wallet, balance, item._contractAdd);
                }else{
                    IBEP20 ContractAdd = IBEP20(_getPayAddress(item._paymentType[i]));
                    uint256 dexBalance = ContractAdd.balanceOf(address(this));
                    require(
                        dexBalance > 0 && balance <= dexBalance,
                        "Contract does not have sufficient funds for this withdrawal."
                    );
                    ContractAdd.transfer(wallet, balance);
                    item.UserConfig[wallet].balance = 0;
                    item.UserConfig[wallet].payOut[item._paymentType[i]].amount = 0;
                    emit WithdrawnUser(wallet, balance, item._contractAdd);
                }
            }
        }
    }

    function _compareString(string memory s1, string memory s2)
        private pure returns (bool)
    {
        return (keccak256(bytes(s1)) == keccak256(bytes(s2)));
    }

    function _getPayAddress(string memory tkName)
        internal view returns(address payAdress)
    {
        if(_compareString(tkName, "BUSD")){
            return busdAddress_;
        }else if(_compareString(tkName, "USDT")){
            return usdtAddress_;
        }else if(_compareString(tkName, "BNB")){
            return bnbAddress_;
        }else{
            return address(0);
        }
    }

    /*
     * @dev System of Create/View/Update/Delete
     */
    function createPartner(
        uint256 _bonusPercent,
        address _contractAdd,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _listingPriceRate,
        uint256 _launchPriceRate,
        uint256 _maxUserAmount,
        string[] memory _paymentType,
        string memory _LiquidityTipe,
        uint256 _liquidityPercentage,
        uint256 _timeInit,
        uint256 _timeEnd
    ) public payable isPausable {
        require(
            _timeInit >= block.timestamp,
            "The start date must be greater than the current date"
        );
        require(
            _timeEnd > _timeInit && _timeEnd > block.timestamp,
            "The start date must be greater than the start date"
        );
        require(
            msg.value >= feeCreateProject,
            "The start date must be greater than the start date"
        );

        payable(_companyAddress).transfer(msg.value);
        _receiveTokensPatner(
            _companyAddress, 
            _hardCap, 
            _liquidityPercentage, 
            _launchPriceRate, 
            _listingPriceRate
        );

        partnerId_+=1;
        PartnerRegister[partnerId_]._bonusPercent = _bonusPercent;
        PartnerRegister[partnerId_]._OwnerAdd = msg.sender;
        PartnerRegister[partnerId_]._contractAdd = _contractAdd;
        PartnerRegister[partnerId_].PartnerValues._softCap = _softCap;
        PartnerRegister[partnerId_].PartnerValues._hardCap = _hardCap;
        PartnerRegister[partnerId_].PartnerValues._listingPriceRate = _listingPriceRate;
        PartnerRegister[partnerId_].PartnerValues._launchPriceRate = _launchPriceRate;
        PartnerRegister[partnerId_].PartnerValues._totalRemaining = _listingPriceRate.add(_launchPriceRate);
        PartnerRegister[partnerId_]._maxUserAmount = _maxUserAmount;
        PartnerRegister[partnerId_]._paymentType = _paymentType; //["BNB", "BUSD", "USDT"]
        PartnerRegister[partnerId_].PartnerStatus._liquidityPercentage = _liquidityPercentage;
        if(_compareString(_LiquidityTipe, "EVOC")){
            PartnerRegister[partnerId_].PartnerStatus._tokenPair = _getEvcPairAddress(_contractAdd);
        }else{
            PartnerRegister[partnerId_].PartnerStatus._tokenPair = _getPckPairAddress(_contractAdd);
        }
        PartnerRegister[partnerId_].PartnerStatus._timeInit = _timeInit;
        PartnerRegister[partnerId_].PartnerStatus._timeEnd = _timeEnd;
        PartnerRegister[partnerId_].PartnerStatus._status = true;
        PartnerRegister[partnerId_].isClaiming = false;
        PartnerRegister[partnerId_].exist = true;

        emit CreateLaunchpad(msg.sender, _contractAdd);
    }

    function updatePartner(
        uint PartnerId,
        uint256 _bonusPercent,
        address _OwnerAdd,
        uint256 _maxUserAmount
    ) public payable isPausable {
        require(
            PartnerRegister[PartnerId].exist,
            "A Partner does not exist, check the contract or create it first"
        );
        require(
            address(msg.sender) ==
                address(PartnerRegister[PartnerId]._OwnerAdd) ||
                address(msg.sender) == _owner,
            "You are not allowed to change this item, check Owner address"
        );

        payable(_companyAddress).transfer(msg.value);

        PartnerRegister[PartnerId]._bonusPercent = _bonusPercent;
        PartnerRegister[PartnerId]._OwnerAdd = _OwnerAdd;
        PartnerRegister[PartnerId]._maxUserAmount = _maxUserAmount;

        emit UpdateLaunchpad(msg.sender, PartnerRegister[PartnerId]._contractAdd);
    }

    function cancelPartner(
        uint PartnerId
    ) public payable isPausable {
        require(
            PartnerRegister[PartnerId].exist,
            "A Partner does not exist, check the contract or create it first"
        );
        require(
            address(msg.sender) ==
                address(PartnerRegister[PartnerId]._OwnerAdd) ||
                address(msg.sender) == _owner,
            "You are not allowed to change this item, check Owner address"
        );
        IBEP20 ContractAdd = IBEP20(PartnerRegister[PartnerId]._contractAdd);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        require(
            dexBalance > 0,
            "You do not have enough balance for this withdrawal"
        );
        ContractAdd.transfer(PartnerRegister[PartnerId]._OwnerAdd, dexBalance);
        PartnerRegister[PartnerId].PartnerStatus._status = false;
    }

    function configureReferSystem(
        uint PartnerId,
        uint256 _referBonusPercent,
        uint256 _referVesting,
        bool _referActive
    ) public isPausable {
        require(
            PartnerRegister[PartnerId].exist,
            "A Partner does not exist, check the contract or create it first"
        );
        require(
            address(msg.sender) ==
                address(PartnerRegister[PartnerId]._OwnerAdd) ||
                address(msg.sender) == _owner,
            "You are not allowed to change this item, check Owner address"
        );
        PartnerRegister[PartnerId].PartnerRefer._referBonusPercent = _referBonusPercent;
        PartnerRegister[PartnerId].PartnerRefer._referVesting = _referVesting;
        //Active System or disable
        PartnerRegister[PartnerId].PartnerRefer._referActive = _referActive;
    }

    function _receiveTokensPatner(
        address _contractAdd,
        uint256 _hardCap,
        uint256 _liquidityPercentage,
        uint256 _launchPriceRate,
        uint256 _listingPriceRate

    ) private nonReentrant {
        IBEP20 ContractToken = IBEP20(_contractAdd);
        uint256 dexBalance = ContractToken.balanceOf(msg.sender);
        uint256 liquidityAmount = (_hardCap*_liquidityPercentage).div(100);
        uint256 LiquifyBalance = (liquidityAmount).div(_listingPriceRate);
        uint256 tokensAmount = (_hardCap.div(_launchPriceRate)).add(LiquifyBalance);
        require(
            _listingPriceRate > 0 && LiquifyBalance <= dexBalance,
            "Insufficient amount of tokens for this transaction"
        );
        require(
            ContractToken.transferFrom(
                msg.sender,
                address(this),
                tokensAmount
            ),
            "A transaction error has occurred. Check for approval."
        );
    }

    function partnerStatus(uint PartnerId) public view returns (uint256) {
        Partner_register storage item = PartnerRegister[PartnerId];
        if(!item.PartnerStatus._status) {
            return 0; // is caceled Launch
        }
        if ((block.timestamp > item.PartnerStatus._timeEnd) && (item.PartnerValues._totalRemaining >= 0)) {
            return 0; // Failure
        }
        if (item.PartnerValues._totalRemaining <= 0 || item.PartnerValues._totalTokenSold >=  item.PartnerValues._listingPriceRate) {
            return 0; // Wonderful - reached to Hardcap
        }
        if ((block.timestamp >= item.PartnerStatus._timeEnd) && (item.PartnerValues._totalRemaining <= 0)) {
            return 0; // SUCCESS - Presale ended with reaching Softcap
        }
        if (
            (block.timestamp >= item.PartnerStatus._timeInit) &&
            (block.timestamp <= item.PartnerStatus._timeEnd) &&
            item.PartnerValues._totalTokenSold < item.PartnerValues._listingPriceRate
        ) {
            return 1; // ACTIVE - Deposits enabled, now in Presale
        }
        return 0; // QUED - Awaiting start block
    }

    /**
     * ----------------------
     * Set Claiming function
     * ----------------------
     */
    function setClaimingPartner(uint PartnerId) public nonReentrant isPausable {
        Partner_register storage item = PartnerRegister[PartnerId];
        require(
            item.exist &&  item.PartnerStatus._status,
            "A Partner does not exist, check the contract or create it first"
        );
        
        require(
            address(msg.sender) ==
                address(item._OwnerAdd) ||
                address(msg.sender) == _owner,
            "You are not allowed to change this item, check Owner address"
        );        

        if(
            item.PartnerValues._totalRemaining <= item.PartnerValues._softCap &&
            item.PartnerValues._totalTokenSold >= item.PartnerValues._softCap
        ){
            item.isClaiming = true;
            swapAndLiquify(PartnerId);

            for (uint i = 0; i < item._paymentType.length; i++) {
                uint256 balance = item.Balance[item._paymentType[i]].amount;
                if(balance > 0){
                    if(_compareString(item._paymentType[i], "BNB")){
                        payable(item._OwnerAdd).transfer(balance);
                        item.Balance[item._paymentType[i]].amount = 0;
                        emit WithdrawnUser(item._OwnerAdd, balance, item._contractAdd);
                    }else{
                        IBEP20 ContractAdd = IBEP20(_getPayAddress(item._paymentType[i]));
                        uint256 dexBalance = ContractAdd.balanceOf(address(this));
                        require(
                            dexBalance > 0 && dexBalance <= balance,
                            "You do not have enough balance for this withdrawal"
                        );
                        ContractAdd.transfer(item._OwnerAdd, balance);
                        item.Balance[item._paymentType[i]].amount = 0;
                        emit WithdrawnUser(item._OwnerAdd, balance, item._contractAdd);
                    }
                }
            }
            IBEP20 ContractAddr = IBEP20(item._contractAdd);
            uint256 dxBalance = ContractAddr.balanceOf(address(this));
            ContractAddr.transfer(item._OwnerAdd, dxBalance);
        }        
    }

    function swapAndLiquify(uint PartnerId) private lockTheSwap {
        Partner_register storage item = PartnerRegister[PartnerId];

        // Number of tokens sold divided by the percentage that will be added to liquidity.
        uint256 tokenAmount = item.PartnerValues._totalTokenSold.mul(item.PartnerStatus._liquidityPercentage).div(100);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        uint256 tokensSwapped;
        for (uint i = 0; i < item._paymentType.length; i++) {
            uint256 amount = item.Balance[item._paymentType[i]].amount;
            if(amount > 0){
                uint256 balance = amount.mul(item.PartnerStatus._liquidityPercentage).div(100);
                tokensSwapped+=balance;
                if(!_compareString(item._paymentType[i], "BNB")){
                    IBEP20 ContractAdd = IBEP20(_getPayAddress(item._paymentType[i]));
                    uint256 dexBalance = ContractAdd.balanceOf(address(this));
                    require(
                        dexBalance > 0 && balance <= dexBalance,
                        "Contract does not have sufficient funds for this withdrawal."
                    );
                    swapTokensForBNB(PartnerId, balance); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered;

                }
            }
        }

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 tokensReceived = (item.Balance["BNB"].amount).mul(item.PartnerStatus._liquidityPercentage).div(100);
        uint256 bnbAmount = tokensReceived.add(newBalance);
        
        // add liquidity to uniswap
        addLiquidity(PartnerId, bnbAmount, tokenAmount);

        emit SwapAndLiquify(tokensSwapped, bnbAmount, tokenAmount);
    }

    function swapTokensForBNB(uint PartnerId, uint256 tokenAmount) private {
        IUniswapV2Router02 routerAdress = IUniswapV2Router02(PartnerRegister[PartnerId].PartnerStatus._tokenPair);
        IBEP20 ContractToken = IBEP20(PartnerRegister[PartnerId]._contractAdd);

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = routerAdress.WETH();

        ContractToken.approve(address(routerAdress), tokenAmount);

        // make the swap
        routerAdress.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint PartnerId, uint256 bnbAmount, uint256 tokenAmount) private {
        IUniswapV2Router02 routerAdress = IUniswapV2Router02(PartnerRegister[PartnerId].PartnerStatus._tokenPair);
        IBEP20 ContractToken = IBEP20(PartnerRegister[PartnerId]._contractAdd);
        // approve token transfer to cover all possible scenarios
        ContractToken.approve(address(routerAdress), tokenAmount);

        // add the liquidity
        routerAdress.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    /*
     * @dev gets the price of Busd per BNB.
     */
    function getPriceInBnb(uint256 amount)
        public
        view
        virtual
        returns (uint256)
    {
        require(amount > 0, "Value is Invalid");
        uint256 ResBNB = 0;
        uint256 ResBUSD = 0;
        if (bnbAddress_ == _bnbBusdPair.token0()) {
            (ResBNB, ResBUSD, ) = _bnbBusdPair.getReserves();
            uint256 priceInBnb = ResBUSD.div(ResBNB);
            return amount.div(priceInBnb); //return amount of BUSD needed to buy tokens
        } else {
            (ResBUSD, ResBNB, ) = _bnbBusdPair.getReserves();
            uint256 priceInBnb = ResBUSD.div(ResBNB);
            return amount.div(priceInBnb); //return amount of BUSD needed to buy tokens
        }
    }

    function _getPckPairAddress(address tokenAddress) internal returns(address PairAdress){
        require(tokenAddress != address(0), "Should not be address 0");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(pckRouterAddress_);
        address tokenPair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(tokenAddress, _uniswapV2Router.WETH());
        /* Get a Pancakeswap pair for this new token */        
        if (tokenPair == address(0)) {
            tokenPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(tokenAddress, _uniswapV2Router.WETH());
        }

        return tokenPair;
    }

    function _getEvcPairAddress(address tokenAddress) internal returns(address PairAdress){
        require(tokenAddress != address(0), "Should not be address 0");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(evcRouterAddress_);
        address tokenPair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(tokenAddress, _uniswapV2Router.WETH());
        /* Get a Pancakeswap pair for this new token */        
        if (tokenPair == address(0)) {
            tokenPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(tokenAddress, _uniswapV2Router.WETH());
        }

        return tokenPair;
    }

    /* Function     : Set a new router if released  */
    /* Parameters   : New router Address */
    function setPckRouterAddress(address newRouter) public onlyOwner {
        require(newRouter != address(0), "Should not be address 0");
        pckRouterAddress_ = IUniswapV2Router02(newRouter);
        emit SetRouterAddressEvent(newRouter);
    }

    /* Function     : Set a new router if released  */
    /* Parameters   : New router Address */
    function setEvcRouterAddress(address newRouter) public onlyOwner {
        require(newRouter != address(0), "Should not be address 0");
        evcRouterAddress_ = IUniswapV2Router02(newRouter);
        emit SetRouterAddressEvent(newRouter);
    }

    function setCompanyAddress(address companyAddress) public onlyOwner {
        _companyAddress = companyAddress;
    }

    function setFeeCreateProject(uint256 _FeeCreateProject) public onlyOwner {
        feeCreateProject = _FeeCreateProject;
    }

    function setFeeTransPercent(uint256 _feeTransPercent) public onlyOwner {
        require(
            _feeTransPercent <= 100,
            "The fee percentage cannot be more than 100"
        );
        feeTransPercent = _feeTransPercent;
    }

    function setIsFeeExempt(address contractAddress, bool exempt) public onlyOwner {
        isFeeExempt[contractAddress] = exempt;
    }

    /*
     * @dev Update the BNB Address token
     * @param addr of the contract address
     */
    function setBnbAdress(address addr) public virtual onlyOwner {
        require(addr.isContract(), "The address entered is not valid");
        bnbAddress_ = addr;
    }

    /*
     * @dev Update the Busd Address token
     * @param addr of the contract address
     */
    function setBusdAdress(address addr) public virtual onlyOwner {
        require(addr.isContract(), "The address entered is not valid");
        busdAddress_ = addr;
    }

    /*
     * @dev Update the Usdt Address token
     * @param addr of the contract address
     */
    function setUsdtAdress(address addr) public virtual onlyOwner {
        require(addr.isContract(), "The address entered is not valid");
        usdtAddress_ = addr;
    }

    /*
     * @dev Update the Reserv pair Bnb/BUSD
     * @param addr of the contract address
     */
    function setBnbReserv(address BnbReserv) public virtual onlyOwner {
        require(BnbReserv.isContract(), "The address entered is not valid");
        _bnbBusdPair = IUniswapV2Pair(BnbReserv);
    }

    /**
     * ----------------------
     * Set Pause Contract function
     * ----------------------
     */
    function setPauseContract() public onlyOwner {
        if (_pause) {
            _pause = false;
        } else {
            _pause = true;
        }
    }

    /**
     * ----------------------
     * Withdrawal of funds from the contract
     * ----------------------
     */
    function withdToBNB() public onlyOwner {
        require(
            _companyAddress != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        require(
            this.totalBalance() > 0,
            "You do not have enough balance for this withdrawal"
        );
        payable(_companyAddress).transfer(this.totalBalance());
    }

    function withdTokens(address _contractAdd) public onlyOwner {
        require(
            _companyAddress != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        IBEP20 ContractAdd = IBEP20(_contractAdd);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        require(
            dexBalance > 0,
            "You do not have enough balance for this withdrawal"
        );
        ContractAdd.transfer(_companyAddress, dexBalance);
    }

    /**
     * ---------------
     * Buy token Event
     * ---------------
     */
    event buyTokensSuccess(
        address indexed _buyer,
        uint256 _receivedToken,
        uint256 _contractAdd,
        string _tkName
    );

    /**
     * ----------------------
     * PreSale token Claim Event
     * ----------------------
     */
    event WithdrawnUser(
        address indexed from,
        uint256 amount,
        address contractAdd
    );

    /**
     * ----------------------
     * Create Launch Project Event
     * ----------------------
     */
    event CreateLaunchpad(
        address indexed from,
        address contractAdd
    );

    /**
     * ----------------------
     * Update Launch Project Event
     * ----------------------
     */
    event UpdateLaunchpad(
        address indexed from,
        address contractAdd
    );

    /**
     * ----------------------
     * Received tokens transaction Event
     * ----------------------
     */
    event Received(
        address indexed from,
        uint256 amount,
        uint256 TokenPrice,
        address contractAddress
    );

    /**
     * ----------------------
     * Add Liquify in token of Project Event
     * ----------------------
     */
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 tokensReceived,
        uint256 tokensIntoLiqudity
    );

    event SetRouterAddressEvent(address value);
}