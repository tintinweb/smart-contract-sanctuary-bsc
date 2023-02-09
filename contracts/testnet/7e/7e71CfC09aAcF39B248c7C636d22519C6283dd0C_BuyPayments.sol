/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @dev Interface of theIUniswapV2 AND Factory/Pair/Route.
 */
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

/**
 * @dev Interface of theIUniswapV2 Pair.
 */
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

/**
 * @dev Interface of theIUniswapV2 AND Route.
 */
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

/**
 * @dev Interface of theIUniswapV2 AND Factory.
 */
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

contract BuyPayments is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    //Private Address tokens and Stables
    address private bnbAddress_;
    address private stableReservAddr_;
    address private companyAddress_;
    IUniswapV2Pair internal bnbStablePair_;
    IUniswapV2Router02 public tokenSwapRoute;

    //Private values constants
    uint256 private feeTransPercent_;
    uint256 private minBalanceInBNB_;
    uint256 private reserveSwapAmount_;
    uint256 private DECIMALFACTOR_ = 10**uint256(18);
    uint256 public gasFee = 5200000000000000;

    //Mapping constants
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isBlacklisted;

    //System of Referal
    struct User_Config {
        uint256 balance;
        uint256 maxAmount;
        address referAddress;
        uint256 referReward;
        uint256 refersTotal;
        uint256 timestamp;
        bool claimTokens;
        bool exist;
    }

    // Info of each pool.
    struct tokenInfo {
        address tokenAddress;
        address contractPair;
        uint256 contractFee;
        uint256 tokenFeePercent;
        address feeReceiver;
        uint256 totalTransfered;
        uint256 totalTokenSold;
        uint256 maxUserAmount; //Maximo Amount tokens buy for Users
        mapping(address => User_Config) UserConfig;
        uint256 referBonusPercent;
        bool referActive;
        bool status;
    }
    mapping(address => tokenInfo) public TokenInfo;

    bool private inTransfer;
    bool private inSwap;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        uint256 _feeTransPercent,
        uint256 _reserveSwapAmount,
        uint256 _minBalanceInBNB,
        address _companyAddress,
        address _wBNBAddress,
        address _stableAddress,
        address _bnbStablePair,
        address _Swap_Route
    ) {
        _owner = msg.sender;
        feeTransPercent_ = _feeTransPercent;
        reserveSwapAmount_ = _reserveSwapAmount;
        minBalanceInBNB_ = _minBalanceInBNB;
        companyAddress_ = _companyAddress;
        stableReservAddr_ = _stableAddress;
        bnbAddress_ = _wBNBAddress;
        bnbStablePair_ = IUniswapV2Pair(_bnbStablePair);
        tokenSwapRoute = IUniswapV2Router02(_Swap_Route);
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}

    function totalBalance() public view returns (uint256) {
        return payable(address(this)).balance;
    }

    function balanceOf(address contractAdd_) public view returns (uint256) {
        return IBEP20(contractAdd_).balanceOf(address(this));
    }

    function getCompanyAddress() public view returns (address) {
        return companyAddress_;
    }

    function getConfgInfo()
        public
        view
        returns (
            uint256 feeTransPercent,
            uint256 minBalanceInBNB,
            uint256 reserveSwapAmount
        )
    {
        return (feeTransPercent_, minBalanceInBNB_, reserveSwapAmount_);
    }

    function buyPayments(
        address _tokenAddress,
        address _deliveryAddress,
        uint256 _amountInBNB,
        address refer
    ) external nonReentrant onlyOwner {
        require(_amountInBNB > 0, "Value entered is invalid");
        require(_tokenAddress != _deliveryAddress, "DUPLICATED_ADDRESS");
        require(
            !isBlacklisted[_tokenAddress] || !isBlacklisted[_deliveryAddress],
            "Currency or user is not allowed to transact"
        );
        
        if (!inTransfer) {
            inTransfer = true;
            if(_amountInBNB >= totalBalance()){
                uint256 _amount = getPriceInBnb(_amountInBNB);
                _swapTokensToBNB(_amount);
            }

            _process(_tokenAddress, _deliveryAddress, _amountInBNB, refer);

            if (
                balanceOf(stableReservAddr_) >= reserveSwapAmount_ &&
                totalBalance() < minBalanceInBNB_
            ) {
                uint256 totalSwap = balanceOf(stableReservAddr_).sub(reserveSwapAmount_);
                _swapTokensToBNB(totalSwap);
            }
            inTransfer = false;
        }
    }

    function BasicTransfer(
        address _tokenAddress,
        address _deliveryAddress,
        uint256 _amount
    ) external nonReentrant onlyOwner {
        require(
            !isBlacklisted[_tokenAddress] || !isBlacklisted[_deliveryAddress],
            "Currency or user is not allowed to transact"
        );

        if (_tokenAddress != bnbAddress_) {
            require(
                TokenInfo[_tokenAddress].status && balanceOf(_tokenAddress) >= _amount,
                "Token does not exist or liquidity is insufficient."
            );
            require(
                IBEP20(_tokenAddress).transfer(address(_deliveryAddress), _amount),
                "An error occurred during the transaction."
            );
        } else {
            require(
                TokenInfo[_tokenAddress].status && totalBalance() >= _amount,
                "Token does not exist or Liquidity is insufficient."
            );
            (bool tmpSuccess, ) = payable(_deliveryAddress).call{
                value: _amount,
                gas: 30000
            }("");
            tmpSuccess = false;
        }

        emit sentTokenSuccess(_deliveryAddress, _tokenAddress, _amount);
    }

    function _process(
        address _tokenAddress,
        address _deliveryAddress,
        uint256 _amountInBNB,
        address refer
    ) private {
        //CHECKS CONTRACT INFO
        tokenInfo storage token = TokenInfo[_tokenAddress];
        require(
            token.status,
            "A Token does not exist, check the contract or create it first"
        );

        //SET TRADING CONFIG
        uint256 DexBalance = balanceOf(_tokenAddress);
        uint256 tokenAmount = getTokenPrice(
            token.contractPair,
            _amountInBNB
        ); 
        uint256 amountToBeSentAfterFees = tokenAmount; //CONVERT BNB IN TOKEN AMOUNT

        uint256 BNBToTransaction = _amountInBNB;
        uint256 BnbToBeSentAfterFees = BNBToTransaction; //CONVERT BNB IN BNB AMOUNT

        //TOTAL AMOUNT TO SENT
        uint256 totalAmountSent = 0;
        uint256 totalFees = token.contractFee.add(token.tokenFeePercent).add(
            feeTransPercent_
        ); //Sum OF ALL AS FEE

        if(totalFees > 0 && !isFeeExempt[_deliveryAddress]){
            uint256 feeTransAmount = tokenAmount.mul(totalFees).div(100);
            amountToBeSentAfterFees = tokenAmount.sub(
                feeTransAmount
            );
            
            uint256 feeTransBnb = BNBToTransaction.mul(totalFees).div(100);
            BnbToBeSentAfterFees = BNBToTransaction.sub(
                feeTransBnb
            );
        }

        //Config of Users
        if (!token.UserConfig[msg.sender].exist) {
            token.UserConfig[msg.sender].maxAmount = _amountInBNB;
            token.UserConfig[msg.sender].exist = true;
        } else {
            token.UserConfig[msg.sender].maxAmount += _amountInBNB;
        }


        //Config of Referal Sistem
        if (token.referActive) {
            if (!token.UserConfig[refer].exist) {
                token.UserConfig[refer].referAddress = refer;
                token.UserConfig[refer].refersTotal++;
                token.UserConfig[refer].timestamp = block.timestamp;
                token.UserConfig[refer].exist = true;
            }

            uint256 referReward = (tokenAmount * token.referBonusPercent)
                .div(100);
            require(
                IBEP20(_tokenAddress).transfer(address(refer), referReward),
                "An error occurred during the transaction."
            );
            token.UserConfig[refer].referReward += referReward;
        }

        //SEND FEES Transactions
        if (!isFeeExempt[_deliveryAddress]) {
            if (feeTransPercent_ > 0) {
                uint256 BNBToTransactionFeeAmount = (
                    BNBToTransaction.mul(feeTransPercent_).div(100)
                ).add(gasFee);
                (bool tmpSuccess, ) = payable(companyAddress_).call{
                    value: BNBToTransactionFeeAmount,
                    gas: 30000
                }("");
                tmpSuccess = false;
            }

            if (token.tokenFeePercent > 0) {
                uint256 BNBToTransactionFeeAmount = (
                    BNBToTransaction.mul(token.tokenFeePercent).div(100)
                ).add(gasFee);
                (bool tmpSuccess, ) = payable(token.feeReceiver).call{
                    value: BNBToTransactionFeeAmount,
                    gas: 30000
                }("");
                tmpSuccess = false;
            }
        }

        //DELIVERY PROCESS STARTS HERE IF IT'S NOT BNB
        if (!inTransfer) {
            inTransfer = true;

            if (_tokenAddress != bnbAddress_) {
                if (tokenAmount > DexBalance) {
                    if (token.contractFee > 0) {
                        _amountInBNB = _amountInBNB.add(
                            _amountInBNB.mul(token.contractFee).div(100)
                        );
                    }
                    _buyTokens(_amountInBNB, _tokenAddress, address(this));
                    uint256 balanceNow = balanceOf(_tokenAddress);
                    tokenAmount = balanceNow.sub(DexBalance);
                }
                require(
                    IBEP20(_tokenAddress).transfer(
                        address(_deliveryAddress),
                        amountToBeSentAfterFees
                    ),
                    "An error occurred during the transaction."
                );
                totalAmountSent = amountToBeSentAfterFees;
                token.totalTransfered += totalAmountSent;

                // IF IT'S BNB, THE DELIVERY WILL HAPPEN HERE
            } else {
                require(
                    totalBalance() >= amountToBeSentAfterFees,
                    "Liquidity is insufficient for this transaction."
                );

                (bool tmpSuccess, ) = payable(_deliveryAddress).call{
                    value: amountToBeSentAfterFees,
                    gas: 30000
                }("");
                tmpSuccess = false;
                totalAmountSent = amountToBeSentAfterFees;
            }
            inTransfer = false;
        }
        //UPDATES TOTAL AMOUNTS BOUGHT/TRANSFERED
        token.totalTokenSold += totalAmountSent;

        emit buyTokenSuccess(_deliveryAddress, _tokenAddress, tokenAmount);
    }

    function _buyTokens(
        uint256 _bnbAmount,
        address _tokenAddress,
        address _receiverAddress
    ) private lockTheSwap {
        require(
            totalBalance() >= _bnbAmount,
            "Liquidity is insufficient for this transaction."
        );

        //SET TRADING CONFIG
        address[] memory path = new address[](2);
        path[0] = bnbAddress_;
        path[1] = _tokenAddress;
        tokenSwapRoute.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _bnbAmount
        }(0, path, _receiverAddress, block.timestamp);
    }

    function _swapTokensToBNB(
        uint256 _tokenAmount
    ) private lockTheSwap {
        //first we need to transfer the amount in tokens from the msg.sender to this contract
        //this contract will have the amount of in tokens
        uint256 initialBalance = totalBalance();

        //next we need to allow the uniswapv2 tokenSwapRoute to spend the token we just sent to this contract
        //by calling IBEP20 approve you allow the uniswap contract to spend the tokens in this contract
        if (
            IBEP20(bnbAddress_).allowance(
                address(this),
                address(tokenSwapRoute)
            ) < _tokenAmount
        ) {
            require(
                IBEP20(bnbAddress_).approve(
                    address(tokenSwapRoute),
                    type(uint256).max
                ),
                "TOKENSWAP:: Approve failed"
            );
        }

        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path = new address[](2);
        path[0] = bnbAddress_;
        path[1] = stableReservAddr_;

        //then we will call swapExactTokensForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        tokenSwapRoute.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );

        uint256 resultBNB = (totalBalance()).sub(initialBalance);

        if(totalBalance() > minBalanceInBNB_){
            uint256 amountToBeSent = (totalBalance()).sub(minBalanceInBNB_);
            tokenSwapRoute.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: amountToBeSent
            }(0, path, address(this), block.timestamp);
        }

        if(balanceOf(stableReservAddr_) < reserveSwapAmount_){
            IBEP20 ContractToken = IBEP20(stableReservAddr_);
            uint256 tkAmount = reserveSwapAmount_.sub(balanceOf(stableReservAddr_));
            require(
                ContractToken.transferFrom(msg.sender, address(this), tkAmount),
                "A transaction error has occurred. Check for approval."
            );
        }

        emit AutoLiquify(resultBNB, _tokenAmount);
    }

    function setTokenInfo(
        address _tokenAddress,
        address _contractPair,
        address _feeReceiver,
        uint256 _contractFee,
        uint256 _tokenFeePercent,
        uint256 _maxUserAmount,
        uint256 _totalTransfered,
        uint256 _referBonusPercent,
        bool _referActive
    ) public onlyOwner {
        TokenInfo[_tokenAddress].tokenAddress = _tokenAddress;
        TokenInfo[_tokenAddress].contractPair = _contractPair;
        TokenInfo[_tokenAddress].feeReceiver = _feeReceiver;
        TokenInfo[_tokenAddress].contractFee = _contractFee;
        TokenInfo[_tokenAddress].tokenFeePercent = _tokenFeePercent;
        TokenInfo[_tokenAddress].maxUserAmount = _maxUserAmount;
        TokenInfo[_tokenAddress].totalTransfered = _totalTransfered;
        TokenInfo[_tokenAddress].referBonusPercent = _referBonusPercent;
        TokenInfo[_tokenAddress].referActive = _referActive;
        TokenInfo[_tokenAddress].status = true;
    }

    function updateTokenInfo(
        address _tokenAddress,
        address _contractPair,
        address _feeReceiver,
        uint256 _contractFee,
        uint256 _tokenFeePercent,
        uint256 _maxUserAmount,
        uint256 _totalTransfered,
        uint256 _referBonusPercent,
        bool _referActive
    ) public onlyOwner {
        tokenInfo storage token = TokenInfo[_tokenAddress];
        require(
            token.status,
            "A Token does not exist, check the contract or create it first"
        );

        token.tokenAddress = _tokenAddress;
        token.contractPair = _contractPair;
        token.contractFee = _contractFee;
        token.tokenFeePercent = _tokenFeePercent;
        token.feeReceiver = _feeReceiver;
        token.maxUserAmount = _maxUserAmount;
        TokenInfo[_tokenAddress].totalTransfered += _totalTransfered;
        token.referBonusPercent = _referBonusPercent;
        token.referActive = _referActive;
    }

    function cancelTokenInfo(
        address _tokenAddress
    ) public onlyOwner {
        tokenInfo storage token = TokenInfo[_tokenAddress];
        require(
            token.status,
            "A Token does not exist, check the contract or create it first"
        );

        IBEP20 ContractAdd = IBEP20(_tokenAddress);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));

        if (dexBalance > 0) {
            ContractAdd.transfer(
                token.feeReceiver,
                dexBalance
            );
        }
        token.status = false;
    }

    /*
     * @dev gets the price of Stable Busd per BNB.
     */
    function getPriceInBusd(uint256 busdAmount)
        public view virtual returns (uint256)
    {
        require(busdAmount > 0, "Value is Invalid");
        IUniswapV2Pair _tokenPair = IUniswapV2Pair(bnbStablePair_);
        if (bnbAddress_ == _tokenPair.token0()) {
            (uint256 ResBNB, uint256 ResBUSD, ) = _tokenPair.getReserves();
            uint256 priceInBnb = ResBUSD.div(ResBNB);
            return busdAmount.div(priceInBnb); //return amount of BUSD needed to buy tokens
        } else {
            (uint256 ResBUSD, uint256 ResBNB, ) = _tokenPair.getReserves();
            uint256 priceInBnb = ResBUSD.div(ResBNB);
            return busdAmount.div(priceInBnb); //return amount of BUSD needed to buy tokens
        }
    }

    /*
     * @dev gets the price of BNB per Stable token.
     */
    function getPriceInBnb(uint256 bnbAmount)
        public view virtual returns (uint256)
    {
        require(bnbAmount > 0, "Value is Invalid");
        IUniswapV2Pair _tokenPair = IUniswapV2Pair(bnbStablePair_);
        if (bnbAddress_ == _tokenPair.token0()) {
            (uint256 ResBNB, uint256 ResBUSD, ) = _tokenPair.getReserves();
            uint256 priceInBnb = ResBUSD.div(ResBNB);
            return bnbAmount.mul(priceInBnb); //return amount of BUSD needed to buy tokens
        } else {
            (uint256 ResBUSD, uint256 ResBNB, ) = _tokenPair.getReserves();
            uint256 priceInBnb = ResBUSD.div(ResBNB);
            return bnbAmount.mul(priceInBnb); //return amount of BUSD needed to buy tokens
        }
    }

    /*
     * @dev gets the price of tokens per BNB.
     */
    function getTokenPrice(address _contractPair, uint256 bnbAmount)
        public view virtual returns (uint256)
    {
        IUniswapV2Pair _tokenPair = IUniswapV2Pair(_contractPair);
        if (bnbAddress_ == _tokenPair.token0()) {
            (uint256 ResBNB, uint256 ResToken, ) = _tokenPair.getReserves();
            uint256 priceInToken = ResToken.div(ResBNB);
            return bnbAmount.mul(priceInToken); //return amount of BNB needed to buy tokens
        } else {
            (uint256 ResToken, uint256 ResBNB, ) = _tokenPair.getReserves();
            uint256 priceInToken = ResToken.div(ResBNB);
            return bnbAmount.mul(priceInToken); //return amount of BNB needed to buy tokens
        }
    }

    /*
     * @dev Function to adjust and balance funds between stable currency and BNB.
     * @Param _amount - Enter the quantity in stable to balance
     */
    function adjustBalance(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Value entered is invalid");
        _swapTokensToBNB(_amount);
    }

    /*
     *
     * @dev This will be charged on all transactions and forwarded to the company.,
     * @paran _feeTransPercent - Percent of fee the Transaction.
     */
    function setFeeTransPercent(uint256 _feeTransPercent)
        public onlyOwner
    {
        require(
            _feeTransPercent <= 100,
            "The fee percentage cannot be more than 100"
        );
        feeTransPercent_ = _feeTransPercent;
    }

    /*
     *
     * @dev Company address for receiving and transacting funds on the contract.
     * @paran _gasFee - Amount of network fee.
     */
    function setCompanyAddress(address _companyAddress, uint256 _gasFee)
        public onlyOwner
    {
        require(_companyAddress != companyAddress_);
        companyAddress_ = _companyAddress;
        gasFee = _gasFee;
    }

    /*
     * @dev Projects or users included in the blacklist not to perform any transactions
     * @param account of the user address
     * @param _isBlacklisted of the boolean if true or false
     */
    function setBlacklist(address _account, bool _isBlacklisted)
        public onlyOwner
    {
        require(isBlacklisted[_account] != _isBlacklisted);
        isBlacklisted[_account] = _isBlacklisted;
    }

    /*
     * @dev Projects excluded from fee payments
     * @param account of the user address
     * @param _isFeeExempt of the boolean if true or false
     */
    function excludeFromFee(address account, bool _isFeeExempt)
        public onlyOwner
    {
        require(isFeeExempt[account] != _isFeeExempt);
        isFeeExempt[account] = _isFeeExempt;
    }

    /* Function     : Set a new router if released
     *
     * Parameters   : New router Address
     */
    function setNewRouterAddress(address newRouter)
        public onlyOwner
    {
        require(newRouter != address(0), "Should not be address 0");
        tokenSwapRoute = IUniswapV2Router02(newRouter);
        emit SetRouterAddressEvent(newRouter);
    }

    /*
     * @dev Update the BNB Address token
     * @param addr of the contract address
     */
    function setBnbAdress(address addr)
        public onlyOwner
    {
        require(addr.isContract(), "The address entered is not valid");
        bnbAddress_ = addr;
    }

    /*
     * @dev Update the Stable Address token
     * @param addr of the contract address
     */
    function setStableAdress(address addr)
        public onlyOwner
    {
        require(addr.isContract(), "The address entered is not valid");
        stableReservAddr_ = addr;
    }

    /*
     * @dev Update the Reserv pair Bnb/Stable Token
     * @param BnbReserv of the contract address
     */
    function setBnbReserv(address BnbReserv)
        public onlyOwner
    {
        require(BnbReserv.isContract(), "The address entered is not valid");
        bnbStablePair_ = IUniswapV2Pair(BnbReserv);
    }

    /**
     * ----------------------
     * Withdrawal of BNB from the contract
     * ----------------------
     */
    function withdToBNB(uint256 amount, address _walletAddress)
        public onlyOwner
    {
        require(
            address(this).balance > 0 && amount < address(this).balance,
            "You do not have enough balance for this withdrawal"
        );
        payable(_walletAddress).transfer(amount);

        emit WithdrawnFunds(_walletAddress, amount);
    }

    /**
     * ----------------------
     * Withdrawal of funds from the contract
     * ----------------------
     */
    function withdTokens(address contractAddr, address _walletAddress)
        public onlyOwner
    {
        require(
            _walletAddress != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        IBEP20 ContractAdd = IBEP20(contractAddr);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        require(
            dexBalance > 0,
            "You do not have enough balance for this withdrawal"
        );
        ContractAdd.transfer(_walletAddress, dexBalance);

        emit WithdrawnFunds(contractAddr, dexBalance);
    }

    /**
     * ---------------
     * Confirm Buy Event
     * ---------------
     */
    event buyTokenSuccess(
        address indexed _received,
        address _contractAdd,
        uint256 _receivedToken
    );

    /**
     * ---------------
     * Send token Event
     * ---------------
     */
    event sentTokenSuccess(
        address indexed _received,
        address _contractAdd,
        uint256 _receivedToken
    );

    /**
     * ----------------------
     * Update address of Router Dex
     * ----------------------
     */
    event SetRouterAddressEvent(address newRouter);

    /**
     * ----------------------
     * Withdrawn Funds of contract
     * ----------------------
     */
    event WithdrawnFunds(
        address indexed from,
        uint256 amount
    );

    /**
     * ----------------------
     * Restore funds of reservation stable token and BNB
     * ----------------------
     */
    event AutoLiquify(
        uint256 amountBNB,
        uint256 amountReserv
    );
}