/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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

contract SmartContToken is Context, BEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _reflectionOwned;
    mapping(address => uint256) private _tokenOwned;

    //Include or WhiteList to fee
    mapping(address => bool) private _isWhiteList;
    mapping(address => bool) private _isExcluded;
    mapping(address => uint256) public excludedIndexes;
    address[] private _excluded;

    //Function for Future rewards 
    struct Receivers {
        address wallet;
        uint256 amount;
    }

    //Wallets of Fee transactions
    address public marketAddress;
    address public companyAddress;
    address public poolGameAddress;
    address private bnbAddress;

    //Constant fee of transactions
    uint256 private taxFee_;
    uint256 private companyFee_;
    uint256 private marketingFee_;
    uint256 private poolGameFee_;

    //Buy Fee List
    struct BuyFee {
        uint256 Tax_Fee;
        uint256 Company_Fee;
        uint256 Marketing_Fee;
        bool exist;
    }
    mapping(uint256 => BuyFee) private buyItems;

    //Sell Fee List
    struct SellFee {
        uint256 Tax_Fee;
        uint256 Company_Fee;
        uint256 Marketing_Fee;
        uint256 PoolGame_Fee;
        bool exist;
    }
    mapping(uint256 => SellFee) private sellItems;

    //system for max Sell
    struct UserSell {
        uint256 timestamp;
        uint256 dailyAmount;
        bool exist;
    }
    mapping(address => UserSell) public maxUserSell;

    //Token Informations and Supply
    string private constant NAME = "Smart TOKEN";
    string private constant SYMBOL = "Smart";
    uint8 private constant DECIMALS = 18;

    uint256 private constant DECIMALFACTOR = 10 ** uint256(18);
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant TOKENTOTAL = 1 * 10**3 * 10**6 * 10**18;
    uint256 private relectionTotal = (MAX - (MAX % TOKENTOTAL));
    uint256 private maxTransaction = 2 * 10**18;
    bool public executeMaxTransaction = false;

    //Totals of acumulation of fee
    uint256 private _tokenFeeTotal;
    uint256 private _tokenMarketingTotal;
    uint256 private _tokenCompanyTotal;
    uint256 private _tokenPoolGameTotal;

    bool private inTransfer;
    bool private inSwapAndLiquify;
    bool public swapAndTransferFeeEnabled = false;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    // @dev what pairs are allowed to work in the token
    mapping(address => bool) private automatedMarketMakerPairs;

    IUniswapV2Router02 public tokenSwapRoute;
    address public tokenSwapPair;
    IUniswapV2Pair internal tokenReserv;

    constructor(
        address Owner_,
        address _MarketingAddr,
        address _CompanyAddr,
        address _PoolGameAddr,
        address _Swap_Route
    ) {
        _owner = Owner_;
        _reflectionOwned[_msgSender()] = relectionTotal;
        emit Transfer(address(0), _msgSender(), TOKENTOTAL);

        marketAddress = _MarketingAddr;
        companyAddress = _CompanyAddr;
        poolGameAddress = _PoolGameAddr;

        IUniswapV2Router02 _tokenSwapRoute = IUniswapV2Router02(_Swap_Route);
        /* Create a Pancakeswap pair for this new token */
        tokenSwapPair = IUniswapV2Factory(_tokenSwapRoute.factory())
            .createPair(address(this), _tokenSwapRoute.WETH());
        /* Set the rest of the contract variables */
        tokenSwapRoute = _tokenSwapRoute;
        bnbAddress = _tokenSwapRoute.WETH();
        tokenReserv = IUniswapV2Pair(tokenSwapPair);
        _setAutomatedMarketMakerPair(tokenSwapPair, true);
        _isExcluded[address(this)] = true;
        excludedIndexes[address(this)] = _excluded.length;
        _isWhiteList[address(this)] = true;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return NAME;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return SYMBOL;
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
    function decimals() public view virtual returns (uint256) {
        return DECIMALS;
    }

    function totalSupply() public pure override returns (uint256) {
        return TOKENTOTAL;
    }

    function decimalFactor() public pure returns (uint256) {
        return DECIMALFACTOR;
    }

    function totalBalance() external view returns (uint256) {
        return payable(address(this)).balance;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}
    fallback() external payable {}

    function totalFees() public view returns (uint256) {
        return _tokenFeeTotal;
    }

    function totalCompany() public view returns (uint256) {
        return _tokenCompanyTotal;
    }

    function totalMarketing() public view returns (uint256) {
        return _tokenMarketingTotal;
    }

    function totalPoolGame() public view returns (uint256) {
        return _tokenPoolGameTotal;
    }

    function getMaxTransaction() public view returns (uint256) {
        return maxTransaction;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function isExcludedFromWhiteList(address account) public view returns (bool) {
        return _isWhiteList[account];
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tokenOwned[account];
        return tokenFromReflection(_reflectionOwned[account]);
    }

    function multSender(Receivers[] memory wallets) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++)
            transfer(wallets[i].wallet, wallets[i].amount);
    }

    function reflect(uint256 tokenAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 reflectionAmount, ) = _getValues(tokenAmount);
        _reflectionOwned[sender] = _reflectionOwned[sender].sub(reflectionAmount);
        relectionTotal = relectionTotal.sub(reflectionAmount);
        _tokenFeeTotal = _tokenFeeTotal.add(tokenAmount);
    }

    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tokenAmount <= TOKENTOTAL, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 reflectionAmount, ) = _getValues(tokenAmount);
            return reflectionAmount;
        } else {
            (, uint256 reflectionTransferAmount) = _getValues(tokenAmount);
            return reflectionTransferAmount;
        }
    }

    function tokenFromReflection(uint256 reflectionAmount)
        public
        view
        returns (uint256)
    {
        require(
            reflectionAmount <= relectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return reflectionAmount.div(currentRate);
    }

    function excludeUserToReflection(address account) external onlyOwner {
        require(!_isExcluded[account], "User is already excluded");
        if (_reflectionOwned[account] > 0) {
            _tokenOwned[account] = tokenFromReflection(_reflectionOwned[account]);
        }
        _isExcluded[account] = true;
        excludedIndexes[account] = _excluded.length;
        _excluded.push(account);
    }

    function includeUserToReflection(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        _excluded[excludedIndexes[account]] = _excluded[_excluded.length - 1];
        _tokenOwned[account] = 0;
        _isExcluded[account] = false;
        excludedIndexes[_excluded[_excluded.length - 1]] = excludedIndexes[account];
        _excluded.pop();
    }

    /* Internal Transfer function of Token */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(
            sender != address(0),
            "BEP20: transfer sender the zero address"
        );
        require(recipient != address(0), "BEP20: transfer to the zero address");
        uint256 tokenAmount = 0;
        bool overMinTokenBalance = false;
        bool is_buy = false;

        if (
            automatedMarketMakerPairs[sender] &&
            !automatedMarketMakerPairs[recipient]
        ) {
            // is Buy transaction
            taxFee_ = buyItems[1].Tax_Fee;
            companyFee_ = buyItems[1].Company_Fee;
            marketingFee_ = buyItems[1].Marketing_Fee;
            poolGameFee_ = 0;
            is_buy = true;
        } else if (
            !automatedMarketMakerPairs[sender] &&
            automatedMarketMakerPairs[recipient]
        ) {
            // is Sell transaction
            if (executeMaxTransaction && !_isExcluded[sender]) {
                require(!_checkMaxTransaction(sender, amount), "BEP20: You have exceeded your daily transaction limit.");
            }
            
            taxFee_ = sellItems[1].Tax_Fee;
            companyFee_ = sellItems[1].Company_Fee;
            marketingFee_ = sellItems[1].Marketing_Fee;
            poolGameFee_ = sellItems[1].PoolGame_Fee;

            tokenAmount = _getTokenFeeTotal(amount);
            /* Swap Fee Transactions */
            if (tokenAmount >= balanceOf(address(this))){
                tokenAmount = balanceOf(address(this));
            }

            overMinTokenBalance = tokenAmount > 0 && balanceOf(address(this)) >= tokenAmount;

        }else{
            // It is a transaction between users
            if(executeMaxTransaction && !_isExcluded[sender]){
                if(_checkMaxTransaction(sender, amount)){
                    taxFee_ = sellItems[1].Tax_Fee;
                    companyFee_ = sellItems[1].Company_Fee;
                    marketingFee_ = sellItems[1].Marketing_Fee;
                    poolGameFee_ = sellItems[1].PoolGame_Fee;
                }
            }
        }

        _executeFeeTransfer(sender, amount, is_buy);

        if (
            !automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient] ||
            _isWhiteList[sender] || inSwapAndLiquify
        ) {
            removeAllFee();
        }

        if (
            overMinTokenBalance &&
            !automatedMarketMakerPairs[sender] &&
            !inSwapAndLiquify &&
            swapAndTransferFeeEnabled
        ) {
            _swapAndTransferFee(tokenAmount);
        }

        if (!inTransfer) {
            inTransfer = true;

            // Remove fees for transfers to and sender account transfer or to excluded account
            if (_isExcluded[sender] && !_isExcluded[recipient]) {
                _transferFromExcluded(sender, recipient, amount);
            } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
                _transferToExcluded(sender, recipient, amount);
            } else if (_isExcluded[sender] && _isExcluded[recipient]) {
                _transferBothExcluded(sender, recipient, amount);
            } else {
                _transferStandard(sender, recipient, amount);
            }

            removeAllFee();
            inTransfer = false;
        }
    }

    function _checkMaxTransaction(address userAddr, uint256 amount) private returns(bool) {
        uint256 DailyAmount = getTokenPrice(amount);
        if (!maxUserSell[userAddr].exist) {
            maxUserSell[userAddr].timestamp = block.timestamp;
            maxUserSell[userAddr].dailyAmount += DailyAmount;
            maxUserSell[userAddr].exist = true;
        }else{
            maxUserSell[userAddr].dailyAmount += DailyAmount;
        }

        uint256 hrs = block.timestamp / 3600 - maxUserSell[userAddr].timestamp / 3600;
        uint256 time = 24;

        if (maxUserSell[userAddr].dailyAmount > maxTransaction && hrs < time) {
           return true;
        }

        if(hrs >= time){
            maxUserSell[userAddr].timestamp = block.timestamp;
        }

        return false;

    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tokenAmount
    ) private {
        (uint256 reflectionAmount, uint256 reflectionTransferAmount) = _getValues(tokenAmount);
        (uint256 tokenTransferAmount) = _getTransferAmount(tokenAmount);
        _reflectionOwned[sender] = _reflectionOwned[sender].sub(reflectionAmount);
        _tokenOwned[recipient] = _tokenOwned[recipient].add(tokenTransferAmount);
        _reflectionOwned[recipient] = _reflectionOwned[recipient].add(reflectionTransferAmount);
        _reflectFee(tokenAmount);
        emit Transfer(sender, recipient, tokenTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tokenAmount
    ) private {
        (uint256 reflectionAmount, uint256 reflectionTransferAmount) = _getValues(tokenAmount);
        (uint256 tokenTransferAmount) = _getTransferAmount(tokenAmount);
        _tokenOwned[sender] = _tokenOwned[sender].sub(tokenAmount);
        _reflectionOwned[sender] = _reflectionOwned[sender].sub(reflectionAmount);
        _reflectionOwned[recipient] = _reflectionOwned[recipient].add(reflectionTransferAmount);
        _reflectFee(tokenAmount);
        emit Transfer(sender, recipient, tokenTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tokenAmount
    ) private {
        (uint256 reflectionAmount, uint256 reflectionTransferAmount) = _getValues(tokenAmount);
        (uint256 tokenTransferAmount) = _getTransferAmount(tokenAmount);
        _tokenOwned[sender] = _tokenOwned[sender].sub(tokenAmount);
        _reflectionOwned[sender] = _reflectionOwned[sender].sub(reflectionAmount);
        _tokenOwned[recipient] = _tokenOwned[recipient].add(tokenTransferAmount);
        _reflectionOwned[recipient] = _reflectionOwned[recipient].add(reflectionTransferAmount);
        _reflectFee(tokenAmount);
        emit Transfer(sender, recipient, tokenTransferAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tokenAmount
    ) private {
        (uint256 reflectionAmount, uint256 reflectionTransferAmount) = _getValues(tokenAmount);
        (uint256 tokenTransferAmount) = _getTransferAmount(tokenAmount);
        _reflectionOwned[sender] = _reflectionOwned[sender].sub(reflectionAmount);
        _reflectionOwned[recipient] = _reflectionOwned[recipient].add(reflectionTransferAmount);
        _reflectFee(tokenAmount);
        emit Transfer(sender, recipient, tokenTransferAmount);
    }

    function _reflectFee(uint256 tokenAmount) private {
        (uint256 tokenFee, uint256 tokenMarketing, uint256 tokenCompany, uint256 tokenPoolGame) = _getTValues(tokenAmount);
        (uint256 reflectionFee, uint256 reflectionMarketing, uint256 reflectionCompany, uint256 reflectionPoolGame) = _getRValues(
            tokenFee,
            tokenMarketing,
            tokenCompany,
            tokenPoolGame
        );
        _tokenFeeTotal = _tokenFeeTotal.add(tokenFee);
        _tokenMarketingTotal = _tokenMarketingTotal.add(tokenMarketing);
        _tokenCompanyTotal = _tokenCompanyTotal.add(tokenCompany);
        _tokenPoolGameTotal = _tokenPoolGameTotal.add(tokenPoolGame);
        relectionTotal = relectionTotal.sub(reflectionFee).sub(reflectionMarketing).sub(reflectionCompany).sub(reflectionPoolGame);

        emit FeeTransaction(tokenFee, tokenMarketing, tokenCompany, tokenPoolGame);
    }

    function _executeFeeTransfer(address sender, uint256 tokenAmount, bool is_buy) private {
        (, uint256 tokenMarketing, uint256 tokenCompany, uint256 tokenPoolGame) = _getTValues(tokenAmount);
        if (tokenMarketing > 0) {
            _sendToMarketing(sender, tokenMarketing, is_buy);
        }
        if (tokenCompany > 0) {
            _sendToCompany(sender, tokenCompany, is_buy);
        }
        if (tokenPoolGame > 0){
            _sendToPoolGame(sender, tokenPoolGame);
        }
    }

    function _sendToMarketing(address sender, uint256 tokenMarketing, bool is_buy) private {
        uint256 currentRate = _getRate();
        uint256 reflectionMarketing = tokenMarketing.mul(currentRate);
        address MarketingAdd = address(this);
        if(is_buy){
            MarketingAdd = marketAddress;
        }
        _reflectionOwned[MarketingAdd] = _reflectionOwned[MarketingAdd].add(reflectionMarketing);
        _tokenOwned[MarketingAdd] = _tokenOwned[MarketingAdd].add(tokenMarketing);
        emit Transfer(sender, MarketingAdd, tokenMarketing);
    }

    function _sendToCompany(address sender, uint256 tokenCompany, bool is_buy) private {
        uint256 currentRate = _getRate();
        uint256 reflectionCompany = tokenCompany.mul(currentRate);
        address CompanyAdd = address(this);
        if(is_buy){
            CompanyAdd = companyAddress;
        }
        _reflectionOwned[CompanyAdd] = _reflectionOwned[CompanyAdd].add(reflectionCompany);
        _tokenOwned[CompanyAdd] = _tokenOwned[CompanyAdd].add(tokenCompany);
        emit Transfer(sender, CompanyAdd, tokenCompany);
    }

    function _sendToPoolGame(address sender, uint256 tokenPoolGame) private {
        uint256 currentRate = _getRate();
        uint256 reflectionPoolGame = tokenPoolGame.mul(currentRate);
        _reflectionOwned[poolGameAddress] = _reflectionOwned[poolGameAddress].add(reflectionPoolGame);
        _tokenOwned[poolGameAddress] = _tokenOwned[poolGameAddress].add(tokenPoolGame);
        emit Transfer(sender, poolGameAddress, tokenPoolGame);
    }

    function _getValues(uint256 tokenAmount)
        private
        view
        returns (uint256, uint256)
    {
        uint256 currentRate = _getRate();
        (uint256 tokenFee, uint256 tokenMarketing, uint256 tokenCompany, uint256 tokenPoolGame) = _getTValues(tokenAmount);
        (uint256 reflectionFee, uint256 reflectionMarketing, uint256 reflectionCompany, uint256 reflectionPoolGame) = _getRValues(
            tokenFee,
            tokenMarketing,
            tokenCompany,
            tokenPoolGame
        );
        uint256 reflectionAmount = tokenAmount.mul(currentRate);
        uint256 reflectionTransferAmount = reflectionAmount.sub(reflectionFee).sub(reflectionMarketing).sub(reflectionCompany).sub(reflectionPoolGame);
        return (reflectionAmount, reflectionTransferAmount);
    }

    function _getTValues(uint256 tokenAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tokenFee = tokenAmount.mul(taxFee_).div(100);
        uint256 tokenMarketing = tokenAmount.mul(marketingFee_).div(100);
        uint256 tokenCompany = tokenAmount.mul(companyFee_).div(100);
        uint256 tokenPoolGame = tokenAmount.mul(poolGameFee_).div(100);
        return (tokenFee, tokenMarketing, tokenCompany, tokenPoolGame);
    }

    function _getRValues(
        uint256 tokenFee,
        uint256 tokenMarketing,
        uint256 tokenCompany,
        uint256 tokenPoolGame
    )
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 currentRate = _getRate();
        uint256 reflectionFee = tokenFee.mul(currentRate);
        uint256 reflectionMarketing = tokenMarketing.mul(currentRate);
        uint256 reflectionCompany = tokenCompany.mul(currentRate);
        uint256 reflectionPoolGame = tokenPoolGame.mul(currentRate);
        return (reflectionFee, reflectionMarketing, reflectionCompany, reflectionPoolGame);
    }

    function _getTransferAmount(uint256 tokenAmount)
        private
        view
        returns (
            uint256
        )
    {
        (uint256 tokenFee, uint256 tokenMarketing, uint256 tokenCompany, uint256 tokenPoolGame) = _getTValues(tokenAmount);
        uint256 tokenTransferAmount = tokenAmount.sub(tokenFee).sub(tokenMarketing).sub(tokenCompany).sub(tokenPoolGame);
        return (tokenTransferAmount);
    }

    function _getRate() private view returns (uint256) {
        (uint256 reflectionSupply, uint256 tokenSupply) = _getCurrentSupply();
        return reflectionSupply.div(tokenSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 reflectionSupply = relectionTotal;
        uint256 tokenSupply = TOKENTOTAL;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionOwned[_excluded[i]] > reflectionSupply ||
                _tokenOwned[_excluded[i]] > tokenSupply
            ) return (relectionTotal, TOKENTOTAL);
            reflectionSupply = reflectionSupply.sub(_reflectionOwned[_excluded[i]]);
            tokenSupply = tokenSupply.sub(_tokenOwned[_excluded[i]]);
        }
        if (reflectionSupply < relectionTotal.div(TOKENTOTAL)) return (relectionTotal, TOKENTOTAL);
        return (reflectionSupply, tokenSupply);
    }

    function removeAllFee() private {
        if (
            taxFee_ == 0 && marketingFee_ == 0 && companyFee_ == 0 ||
            taxFee_ == 0 && marketingFee_ == 0 && companyFee_ == 0 && poolGameFee_ == 0
        ) return;
        taxFee_ = 0;
        marketingFee_ = 0;
        companyFee_ = 0;
        poolGameFee_ = 0; 
    }

    /*
     * @dev Sitem of Create/View/Update/Delete
     * @dev Management System fee Buy
     */
    function createBuyFee(
        uint256 txFee,
        uint256 marketingFee,
        uint256 companyFee
    ) public onlyOwner {
        require(!buyItems[1].exist, "A fee already exists, created");
        require((txFee.add(marketingFee).add(companyFee)) <= 25, "Total fees should not be more than 25%.");
        uint256 _buyId = 1;
        buyItems[_buyId].Tax_Fee = txFee;
        buyItems[_buyId].Company_Fee = marketingFee;
        buyItems[_buyId].Marketing_Fee = companyFee;
        buyItems[_buyId].exist = true;
    }

    function updateBuyFee(
        uint256 txFee,
        uint256 marketingFee,
        uint256 companyFee
    ) public onlyOwner {
        require((txFee.add(marketingFee).add(companyFee)) <= 25, "Total fees should not be more than 25%.");        
        BuyFee storage item = buyItems[1];
        item.Tax_Fee = txFee;
        item.Marketing_Fee = marketingFee;
        item.Company_Fee = companyFee;
    }

    /*
     *get getBuyFeeDetails
     */
    function getBuyFee()
        public
        view
        returns (
            uint256 txFee,
            uint256 marketingFee,
            uint256 companyFee,
            bool exist
        )
    {
        return (
            buyItems[1].Tax_Fee,
            buyItems[1].Marketing_Fee,
            buyItems[1].Company_Fee,
            buyItems[1].exist
        );
    }

    /*
     * @dev Sitem of Create/View/Update/Delete
     * @dev Management System fee Sell
     */
    function createSellFee(
        uint256 txFee,
        uint256 marketingFee,
        uint256 companyFee,
        uint256 poolGameFee
    ) public onlyOwner {
        require(!sellItems[1].exist, "A fee already exists, created");
        require((txFee.add(marketingFee).add(companyFee).add(poolGameFee)) <= 25, "Total fees should not be more than 25%.");
        uint256 _sellId = 1;
        sellItems[_sellId].Tax_Fee = txFee;
        sellItems[_sellId].Marketing_Fee = marketingFee;
        sellItems[_sellId].Company_Fee = companyFee;
        sellItems[_sellId].PoolGame_Fee = poolGameFee;
        sellItems[_sellId].exist = true;
    }

    function updateSellFee(
        uint256 txFee,
        uint256 marketingFee,
        uint256 companyFee,
        uint256 poolGameFee
    ) public onlyOwner {
        require((txFee.add(marketingFee).add(companyFee).add(poolGameFee)) <= 25, "Total fees should not be more than 25%.");
        SellFee storage item = sellItems[1];
        item.Tax_Fee = txFee;
        item.Marketing_Fee = marketingFee;
        item.Company_Fee = companyFee;
        item.PoolGame_Fee = poolGameFee;
    }

    /*
     *get getBuyFeeDetails
     */
    function getSellFee()
        public
        view
        returns (
            uint256 txFee,
            uint256 marketingFee,
            uint256 companyFee,
            uint256 poolGameFee,
            bool exist
        )
    {
        return (
            sellItems[1].Tax_Fee,
            sellItems[1].Marketing_Fee,
            sellItems[1].Company_Fee,
            sellItems[1].PoolGame_Fee,
            sellItems[1].exist
        );
    }

    /*
     *Internal Function to swap Tokens and add to Marketing
     */
    function _swapAndTransferFee(uint256 tokenAmount) private lockTheSwap {
        /* Generate the Pancakeswap pair path of token -> wbnb */
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenSwapRoute.WETH();

        /* Swap tokens for BNB */
        _approve(msg.sender, address(tokenSwapRoute), type(uint256).max);
        _approve(address(this), address(tokenSwapRoute), type(uint256).max);

        /* Make the swap */
        tokenSwapRoute.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );

        /* Send BNB to Wallets Fee */
        uint256 withAmount = address(this).balance;
        uint256 half = withAmount.div(2);
        uint256 otherHalf = withAmount.sub(half);

        if (half != 0) {
            _sendFeeBNB(companyAddress, half);
        }

        if (otherHalf != 0) {
            _sendFeeBNB(marketAddress, otherHalf);
        }
    }

    function _getTokenFeeTotal(uint256 amount) private view returns (uint256) {
        uint256 tokenFee = companyFee_.add(marketingFee_);
        uint256 tokenAmount = amount.mul(tokenFee).div(100);
        return tokenAmount;
    }

    function _sendFeeBNB(address recipient, uint256 withAmount) private {
        // prevent re-entrancy attacks
        (bool tmpSuccess,) =  payable(recipient).call{value: withAmount, gas: 30000}("");
        tmpSuccess = false;

        emit BNBWithdrawn(recipient, withAmount);
    }

    function executeAutoTransferFee(uint256 amountToken) external onlyOwner {
        require(
            amountToken < balanceOf(address(this)),
            "Insufficient balance for this transaction."
        );
        _swapAndTransferFee(amountToken);
    }

    /* Function     : Set a new router if released  */
    /* Parameters   : New router Address */
    function setRouterAddress(address newRouter) external onlyOwner {
        require(newRouter != address(0), "Should not be address 0");
        IUniswapV2Router02 _tokenSwapRoute = IUniswapV2Router02(newRouter);
        /* Create a Pancakeswap pair for this new token */
        tokenSwapPair = IUniswapV2Factory(_tokenSwapRoute.factory())
            .createPair(address(this), _tokenSwapRoute.WETH());
        /* Set the rest of the contract variables */
        tokenSwapRoute = _tokenSwapRoute;
        _setAutomatedMarketMakerPair(tokenSwapPair, true);
        emit SetRouterAddressEvent(newRouter);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value)
        private
        onlyOwner
    {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function setCompanyAdress(address companyAddress_) public onlyOwner {
        require(companyAddress != companyAddress_, "This is the same company address.");
        companyAddress = companyAddress_;
    }

    function setMarketingAdress(address marketingAddress_) public onlyOwner {
        require(marketAddress != marketingAddress_, "This is the same market address.");
        marketAddress = marketingAddress_;
    }

    function setMaxTransaction(uint256 amountBNB) public onlyOwner {
        require(amountBNB >= 2 ether, "Cannot set less than 2 BNB.");
        uint256 prevAmount = maxTransaction;
        maxTransaction = amountBNB;
        emit SetMaxTransaction(prevAmount, amountBNB);
    }

    function setExecuteMaxTransaction() external onlyOwner {
        if (executeMaxTransaction) {
            executeMaxTransaction = false;
        } else {
            executeMaxTransaction = true;
        }
    }

    /*
     * @dev gets the price of TOKEN per BNB.
     */
    function getTokenPrice(uint256 amount)
        public
        view
        virtual
        returns (uint256)
    {
        require(amount > 0, "Value is Invalid");
        IUniswapV2Pair _tokenPair = IUniswapV2Pair(tokenReserv);

        uint256 ResBNB = 0;
        uint256 ResTOKEN = 0;

        if (bnbAddress == _tokenPair.token0()) {
            (ResBNB, ResTOKEN, ) = _tokenPair.getReserves();
            uint256 pricebnb = ResTOKEN.div(ResBNB);
            return amount.div(pricebnb); //return amount of BNB needed to Transaction
        } else {
            (ResTOKEN, ResBNB, ) = _tokenPair.getReserves();
            uint256 pricebnb = ResTOKEN.div(ResBNB);
            return amount.div(pricebnb); //return amount of BNB needed to Transaction
        }
    }

    /* Function     : Turns ON/OFF Marketing swap */
    /* Parameters   : Set 'true' to turn ON and 'false' to turn OFF */
    function setSwapAndTransferFeeEnabled() external onlyOwner {
        if (swapAndTransferFeeEnabled) {
            swapAndTransferFeeEnabled = false;
        } else {
            swapAndTransferFeeEnabled = true;
        }
        emit SwapAndLiquifyEnabledUpdated(swapAndTransferFeeEnabled);
    }    

    function setWhiteList(address account) external onlyOwner {
        if(_isWhiteList[account]){
            _isWhiteList[account] = false;
        }else{
            _isWhiteList[account] = true;
        }
    }

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SetRouterAddressEvent(address value);
    event FeeTransaction(uint256 tFee, uint256 tMarketing, uint256 tCompany, uint256 tPoolGame);
    event BNBWithdrawn(address beneficiary, uint256 value);
    event SetMaxTransaction(uint256 prevAmount, uint256 amountBNB);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
}