/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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
abstract contract BEP20 is Context, IBEP20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;

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

    //System of Referal
    struct Afiliate_System {
        address userAddress;
        address referAddress;
        uint256 rewards;
        uint256 timestamp;
        bool exist;
    }
    mapping(address => Afiliate_System) public AfiliateSystem;

    //Partner register List
    struct Partner_register {
        string _name;
        string _simbol;
        uint256 _bonusPercent;
        address _OwnerAdd;
        address _contractAdd;
        uint256 _tokenValueDollar;
        uint256 _totalOnPreSale; //Total tokens available for sale
        uint256 _totalRemaining; //Total token remaining for sale
        uint256 _totalTokenSold; //Total tokens sold
        uint256[] _paymentType; //["BNB", "BUSD", "USDT", "EVOC+", "PIX"]
        uint256 _referBonusPercent;
        uint256 _referVesting;
        bool _useReferal;
        uint256 _timeInit;
        uint256 _timeEnd;
        bool isClaiming;
        bool exist;
    }
    mapping(address => Partner_register) private PartnerRegister;

    //Project account balances
    mapping(address => mapping(address => uint256)) private pendingBalance;

    //Token Project price
    uint256 private feeCreateProject;
    uint256 private feeTransPercent;
    mapping(address => bool) public isFeeExempt;

    address private bnbAddress_;
    address private busdAddress_;
    address private usdtAddress_;
    address private evocAddress_;
    IUniswapV2Pair internal _bnbBusdPair;
    IUniswapV2Pair internal _EvocReserv;

    // Wallets For WithDraw
    address private _companyAddress;
    uint256 private _DECIMALFACTOR = 10**uint256(18);

    bool _pause = false;
    modifier isPausable() {
        require(!_pause, "The Contract is paused. Presale is paused");
        _;
    }

    constructor(
        address _OwnerAddr,
        uint256 _feeCreateProject,
        uint256 _feeTransPercent,
        address _wBNBAddress,
        address _busdAddress,
        address _usdtAddress,
        address _BnbBusdPair,
        address _evocAddress,
        address _evocReserv
    ) {
        // Token owner
        _owner = _OwnerAddr;
        _companyAddress = _OwnerAddr;
        feeCreateProject = _feeCreateProject;
        feeTransPercent = _feeTransPercent;
        bnbAddress_ = _wBNBAddress;
        busdAddress_ = _busdAddress;
        usdtAddress_ = _usdtAddress;
        _bnbBusdPair = IUniswapV2Pair(_BnbBusdPair);
        evocAddress_ = _evocAddress;
        _EvocReserv = IUniswapV2Pair(_evocReserv);
    }

    function totalBalance() external view returns (uint256) {
        return payable(address(this)).balance;
    }

    function balanceOf(address account, address PartnerAddress)
        public view returns (uint256 amount)
    {
        return pendingBalance[account][PartnerAddress];
    }

    function ContractStatusPause() public view returns (bool) {
        return _pause;
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

    /*get getPartnerDetails*/
    function getPartnerDetails(address PartnerAddress)
        public view
        returns (
            string memory name,
            string memory simbolo,
            uint256 bonusPercent,
            address contractAdd,
            address ownerAddress,
            uint256 tokenValueDollar,
            uint256 totalOnPreSale,
            uint256 totalRemaining,
            uint256 totalTokenSold,
            bool isClaiming,
            uint256 timeInit,
            uint256 timeEnd
        )
    {
        Partner_register storage item = PartnerRegister[PartnerAddress];
        return (
            item._name,
            item._simbol,
            item._bonusPercent,
            item._contractAdd,
            item._OwnerAdd,
            item._tokenValueDollar,
            item._totalOnPreSale,
            item._totalRemaining,
            item._totalTokenSold,
            item.isClaiming,
            item._timeInit,
            item._timeEnd
        );
    }

    function getPartnerReferConfig(address PartnerAddress)
        public view
        returns (
            uint256 bonusReferPercent,
            uint256 referVesting
        )
    {
        Partner_register storage item = PartnerRegister[PartnerAddress];
        return (item._referBonusPercent, item._referVesting);
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}

    function buyWithToken(
        uint256 tokenAmount,
        address contractAdd,
        string memory tkName,
        address refer
    ) public isPausable {
        require(contractAdd.isContract(), "The address entered is not valid");
        Partner_register storage item = PartnerRegister[contractAdd];
        require(tokenAmount > 0, "Insufficient amount for this transaction");
        address payAddress = _getPayAddress(tkName);
        require(
            payAddress != address(0),
            "The address is invalid, check the currency type."
        );
        uint256 tkAmount = item._tokenValueDollar.mul(tokenAmount);

        if (_compareString(tkName, "EVOC+")) {
            tkAmount = getEvocPrice(tkAmount);
        }

        IBEP20 ContractToken = IBEP20(payAddress);
        uint256 dexBalance = ContractToken.balanceOf(msg.sender);
        require(
            tkAmount > 0 && tkAmount <= dexBalance,
            "Insufficient amount for this transaction"
        );

        if (isFeeExempt[contractAdd]) {
            require(
                ContractToken.transferFrom(
                    msg.sender,
                    item._OwnerAdd,
                    tkAmount
                ),
                "A transaction error has occurred. Check for approval."
            );
        } else {
            uint256 feeTransaction = tokenAmount.mul(feeTransPercent).div(100);
            uint256 AmountTk = tokenAmount.sub(feeTransaction);

            require(
                ContractToken.transferFrom(
                    msg.sender,
                    item._OwnerAdd,
                    AmountTk.mul(_DECIMALFACTOR)
                ),
                "A transaction error has occurred. Check for approval."
            );
            
            require(
                ContractToken.transferFrom(
                    msg.sender,
                    _companyAddress,
                    feeTransaction
                ),
                "A transaction error has occurred. Check for approval."
            );
        }

        // Increasing total raised
        item._totalRemaining.sub(tokenAmount);
        item._totalTokenSold.add(tokenAmount);
        uint256 bonusPercent = tokenAmount.mul(item._bonusPercent).div(100);
        uint256 newBalance = tokenAmount + bonusPercent;
        if(item._useReferal){
            if(!AfiliateSystem[refer].exist){
                AfiliateSystem[refer].userAddress = msg.sender;
                AfiliateSystem[refer].referAddress = refer;
                AfiliateSystem[refer].timestamp = block.timestamp;
                AfiliateSystem[refer].exist = true;
            }

            uint256 referReward = (tokenAmount * item._referBonusPercent).div(100);
            AfiliateSystem[refer].rewards += referReward;
            pendingBalance[AfiliateSystem[refer].referAddress][contractAdd] += referReward;
        }

        if (item.isClaiming) {
            IBEP20 ContractAdd = IBEP20(contractAdd);
            ContractAdd.transfer(msg.sender, newBalance);
        } else {
            pendingBalance[msg.sender][contractAdd] += tokenAmount;
        }

        emit buyTokensSuccess(msg.sender, tokenAmount, tkAmount);
    }

    function buyWithBNB(uint256 tokenAmount, address contractAdd, address refer)
        public
        payable
        isPausable
    {
        require(contractAdd.isContract(), "The address entered is not valid");
        Partner_register storage item = PartnerRegister[contractAdd];
        require(tokenAmount > 0, "Insufficient amount for this transaction");
        uint256 amount = getTokenPrice(item._tokenValueDollar.mul(tokenAmount));

        require(
            amount > 0 &&
                msg.value >= amount,
            "Insufficient amount for this transaction"
        );

        if (isFeeExempt[contractAdd]) {
            payable(item._OwnerAdd).transfer(amount);
        } else {
            uint256 feeTransaction = tokenAmount.mul(feeTransPercent).div(100);
            uint256 AmountTk = tokenAmount.sub(feeTransaction);
            payable(item._OwnerAdd).transfer(AmountTk);
            payable(_companyAddress).transfer(feeTransaction);
        }

        // Increasing total raised
        item._totalRemaining.sub(tokenAmount);
        item._totalTokenSold.add(tokenAmount);
        uint256 bonusPercent = tokenAmount.mul(item._bonusPercent).div(100);
        uint256 newBalance = tokenAmount + bonusPercent;
        if(item._useReferal){
            if(!AfiliateSystem[refer].exist){
                AfiliateSystem[refer].userAddress = msg.sender;
                AfiliateSystem[refer].referAddress = refer;
                AfiliateSystem[refer].timestamp = block.timestamp;
                AfiliateSystem[refer].exist = true;
            }

            uint256 referReward = (tokenAmount * item._referBonusPercent).div(100);
            AfiliateSystem[refer].rewards += referReward;
            pendingBalance[AfiliateSystem[refer].referAddress][contractAdd] += referReward;
        }

        if (item.isClaiming) {
            IBEP20 ContractAdd = IBEP20(contractAdd);
            ContractAdd.transfer(msg.sender, newBalance);
        } else {
            pendingBalance[msg.sender][contractAdd] += tokenAmount;
        }

        emit buyTokensSuccess(msg.sender, tokenAmount, amount);
    }

    function claimTokens(address contractAdd)
        public
        isPausable
    {
        address wallet = msg.sender;
        uint256 balance = balanceOf(wallet, contractAdd);
        Partner_register storage item = PartnerRegister[contractAdd];
        require(
            item.isClaiming,
            "The project has not yet been released to claim."
        );
        require(
            wallet != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        require(
            balance > 0,
            "You do not have enough balance for this withdrawal"
        );

        if(item._useReferal && AfiliateSystem[msg.sender].exist && AfiliateSystem[msg.sender].timestamp <= block.timestamp){
            uint256 amountClaim = balance.mul(item._referVesting).div(100);
            IBEP20 tokenAddr = IBEP20(contractAdd);
            tokenAddr.transfer(wallet, amountClaim);
            pendingBalance[wallet][contractAdd] -= amountClaim;
            AfiliateSystem[msg.sender].timestamp = block.timestamp+item._referVesting;
        }else{
            IBEP20 tokenAddr = IBEP20(contractAdd);
            tokenAddr.transfer(wallet, balance);
            pendingBalance[wallet][contractAdd] -= balance;
        }

        emit WithdrawnUser(
            wallet,
            balance,
            contractAdd
        );
    }

    /*
     * @dev gets the price of BNB per EVOC.
     */
    function getEvocPrice(uint256 amount)
        public view virtual
        returns (uint256)
    {
        require(amount > 0, "Value is Invalid");
        uint256 tokenAmount = getTokenPrice(amount);
        if (bnbAddress_ == _EvocReserv.token0()) {
            (uint256 ResBNB, uint256 ResTOKEN, ) = _EvocReserv.getReserves();
            uint256 pricebnb = ResTOKEN.div(ResBNB);
            return (tokenAmount).mul(pricebnb); // return amount of BNB needed to buy tokens
        } else {
            (uint256 ResTOKEN, uint256 ResBNB, ) = _EvocReserv.getReserves();
            uint256 pricebnb = ResTOKEN.div(ResBNB);
            return (tokenAmount).mul(pricebnb); // return amount of BNB needed to buy tokens
        }
    }

    /*
     * @dev gets the price of BUSD per BNB .
     */
    function getTokenPrice(uint256 amount)
        public view virtual
        returns (uint256)
    {
        require(amount > 0, "Value is Invalid");
        if (bnbAddress_ == _bnbBusdPair.token0()) {
            (uint256 ResBNB, uint256 ResBUSD, ) = _bnbBusdPair.getReserves();
            uint256 pricebnb = ResBUSD.div(ResBNB);
            return (amount).div(pricebnb); // return amount of BNB needed to buy tokens
        } else {
            (uint256 ResBUSD, uint256 ResBNB, ) = _bnbBusdPair.getReserves();
            uint256 pricebnb = ResBUSD.div(ResBNB);
            return (amount).div(pricebnb); // return amount of BNB needed to buy tokens
        }
    }

    function _compareString(string memory s1, string memory s2)
        private pure
        returns (bool)
    {
        return (keccak256(bytes(s1)) == keccak256(bytes(s2)));
    }

    function _getPayAddress(string memory tkName) internal view returns(address payAdress){
        if(_compareString(tkName, "EVOC+")){
            return evocAddress_;
        }else if(_compareString(tkName, "BUSD")){
            return busdAddress_;
        }else if(_compareString(tkName, "USDT")){
            return usdtAddress_;
        }else{
            return address(0);
        }
    }

    /*
     * @dev System of Create/View/Update/Delete
     */
    function createPartner(
        string memory _name,
        string memory _simbol,
        uint256 _bonusPercent,
        address _contractAdd,
        uint256 _tokenValueDollar,
        uint256 _totalOnPreSale,
        uint256[] memory _paymentType,
        uint256 _timeInit,
        uint256 _timeEnd,
        bool isClaiming
    ) public payable isPausable {
        require(
            !PartnerRegister[_contractAdd].exist,
            "A Partner already exists, created"
        );
        require(
            _timeInit > block.timestamp,
            "The start date must be greater than the current date"
        );
        require(
            _timeEnd > _timeInit,
            "The start date must be greater than the start date"
        );
        require(
            msg.value >= feeCreateProject,
            "The start date must be greater than the start date"
        );

        payable(_companyAddress).transfer(msg.value);

        PartnerRegister[_contractAdd]._name = _name;
        PartnerRegister[_contractAdd]._simbol = _simbol;
        PartnerRegister[_contractAdd]._bonusPercent = _bonusPercent;
        PartnerRegister[_contractAdd]._OwnerAdd = msg.sender;
        PartnerRegister[_contractAdd]._contractAdd = _contractAdd;
        PartnerRegister[_contractAdd]._tokenValueDollar = _tokenValueDollar;
        PartnerRegister[_contractAdd]._totalOnPreSale = _totalOnPreSale;
        PartnerRegister[_contractAdd]._totalRemaining = _totalOnPreSale;
        PartnerRegister[_contractAdd]._totalTokenSold = 0;
        PartnerRegister[_contractAdd]._paymentType = _paymentType; //["BNB", "BUSD", "USDT", "EVOC+", "PIX"]
        PartnerRegister[_contractAdd]._timeInit = _timeInit;
        PartnerRegister[_contractAdd]._timeEnd = _timeEnd;
        PartnerRegister[_contractAdd].isClaiming = isClaiming;
        PartnerRegister[_contractAdd].exist = true;

        emit CreateLaunchpad(msg.sender, _contractAdd, _name);
    }

    function updatePartner(
        string memory _name,
        string memory _simbol,
        uint256 _bonusPercent,
        address _OwnerAdd,
        address _contractAdd,
        uint256 _tokenValueDollar,
        uint256 _totalOnPreSale,
        uint256[] memory _paymentType,
        uint256 _timeEnd,
        bool isClaiming
    ) public isPausable {
        require(
            PartnerRegister[_contractAdd].exist,
            "A Partner does not exist, check the contract or create it first"
        );
        require(
            address(msg.sender) ==
                address(PartnerRegister[_contractAdd]._OwnerAdd) ||
                address(msg.sender) == _owner,
            "You are not allowed to change this item, check Owner address"
        );
        require(
            _timeEnd <= block.timestamp,
            "The start date must be greater than the start date"
        );

        PartnerRegister[_contractAdd]._name = _name;
        PartnerRegister[_contractAdd]._simbol = _simbol;
        PartnerRegister[_contractAdd]._bonusPercent = _bonusPercent;
        PartnerRegister[_contractAdd]._OwnerAdd = _OwnerAdd;
        PartnerRegister[_contractAdd]._contractAdd = _contractAdd;
        PartnerRegister[_contractAdd]._tokenValueDollar = _tokenValueDollar;
        PartnerRegister[_contractAdd]._totalOnPreSale = _totalOnPreSale;
        PartnerRegister[_contractAdd]._paymentType = _paymentType; //["BNB", "BUSD", "USDT", "EVOC+", "PIX"]
        PartnerRegister[_contractAdd]._timeEnd = _timeEnd;
        PartnerRegister[_contractAdd].isClaiming = isClaiming;

        emit UpdateLaunchpad(msg.sender, _contractAdd, _name);
    }

    function deletePartner(address _contractAdd) public onlyOwner {
        Partner_register storage item = PartnerRegister[_contractAdd];
        require(
            item.exist,
            "A Partner does not exist, check the contract or create it first"
        );

        delete PartnerRegister[_contractAdd];
    }

    function configureReferSystem(
        address _contractAdd,
        uint256 _referBonusPercent,
        uint256 _referVesting,
        bool _useReferal
    ) public isPausable {
        require(
            PartnerRegister[_contractAdd].exist,
            "A Partner does not exist, check the contract or create it first"
        );
        require(
            address(msg.sender) ==
                address(PartnerRegister[_contractAdd]._OwnerAdd) ||
                address(msg.sender) == _owner,
            "You are not allowed to change this item, check Owner address"
        );
        PartnerRegister[_contractAdd]._referBonusPercent = _referBonusPercent;
        PartnerRegister[_contractAdd]._referVesting = _referVesting;
        PartnerRegister[_contractAdd]._useReferal = _useReferal;
    }

    /**
     * ----------------------
     * Set Claiming function
     * ----------------------
     */
    function setClaimingPartner(address _contractAdd) public isPausable {
        require(
            PartnerRegister[_contractAdd].exist,
            "A Partner does not exist, check the contract or create it first"
        );
        require(
            address(msg.sender) ==
                address(PartnerRegister[_contractAdd]._OwnerAdd) ||
                address(msg.sender) == _owner,
            "You are not allowed to change this item, check Owner address"
        );
        if (PartnerRegister[_contractAdd].isClaiming) {
            PartnerRegister[_contractAdd].isClaiming = false;
        } else {
            PartnerRegister[_contractAdd].isClaiming = true;
        }
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

    function setIsFeeExempt(address contractAddress, bool exempt)
        external
        onlyOwner
    {
        isFeeExempt[contractAddress] = exempt;
    }

    /*
     * @dev Update the BNB Address token
     * @param addr of the contract address
     */
    function setBnbAdress(address addr) external virtual onlyOwner {
        require(addr.isContract(), "The address entered is not valid");
        bnbAddress_ = addr;
    }

    /*
     * @dev Update the Busd Address token
     * @param addr of the contract address
     */
    function setBusdAdress(address addr) external virtual onlyOwner {
        require(addr.isContract(), "The address entered is not valid");
        busdAddress_ = addr;
    }

    /*
     * @dev Update the Reserv pair Bnb/BUSD
     * @param addr of the contract address
     */
    function setBnbReserv(address BnbReserv) external virtual onlyOwner {
        require(BnbReserv.isContract(), "The address entered is not valid");
        _bnbBusdPair = IUniswapV2Pair(BnbReserv);
    }

    /*
     * @dev Update the Evoc Address token
     * @param addr of the contract address
     */
    function setEvocAdress(address addr) external virtual onlyOwner {
        require(addr.isContract(), "The address entered is not valid");
        evocAddress_ = addr;
    }

    /*
     * @dev Update the Reserv pair Evoc/Bnb
     * @param addr of the contract address
     */
    function setEvocReserv(address EvocReserv) external virtual onlyOwner {
        require(EvocReserv.isContract(), "The address entered is not valid");
        _EvocReserv = IUniswapV2Pair(EvocReserv);
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
        uint256 _contractAdd
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
        address contractAdd,
        string launchName
    );

    /**
     * ----------------------
     * Update Launch Project Event
     * ----------------------
     */
    event UpdateLaunchpad(
        address indexed from,
        address contractAdd,
        string launchName
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
}