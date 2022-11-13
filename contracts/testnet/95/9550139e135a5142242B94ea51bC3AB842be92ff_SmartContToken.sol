/**
 *Submitted for verification at BscScan.com on 2022-11-13
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

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    //Include or Exclude to fee
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    //Function for Future rewards 
    struct Receivers {
        address wallet;
        uint256 amount;
    }

    //Wallets of Fee transactions
    address public MarketAddress;
    address public CompanyAddress;
    address public PoolGameAddress;
    address private WithdrawAddress;
    address private _bnb_Address;

    //Constant fee of transactions
    uint256 private _TAX_FEE;
    uint256 private _COMPANY_FEE;
    uint256 private _MARKETING_FEE;
    uint256 private _POOLGAME_FEE;

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
    struct userSell {
        uint256 timestamp;
        uint256 dailyAmount;
        bool exist;
    }
    mapping(address => userSell) public maxUserSell;

    //Token Informations and Supply
    string private _name = "Advanced Test";
    string private _symbol = "ADVCT";
    uint8 private _decimals = 18;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _DECIMALFACTOR = 10 ** uint256(18);
    uint256 private constant _tTotal = 1 * 10**3 * 10**6 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _MaxTransaction = 2 * 10**18;
    bool public executeMaxTransaction = false;

    //Totals of acumulation of fee
    uint256 private _tFeeTotal;
    uint256 private _tMarketingTotal;
    uint256 private _tCompanyTotal;
    uint256 private _tPooGameTotal;

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
    IUniswapV2Pair internal _TokenReserv;

    constructor(
        address Owner_,
        address _MarketingAddr,
        address _CompanyAddr,
        address _PoolGameAddr,
        address _WithdrawAddr,
        address _Swap_Route
    ) {
        _owner = Owner_;
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);

        MarketAddress = _MarketingAddr;
        CompanyAddress = _CompanyAddr;
        PoolGameAddress = _PoolGameAddr;
        WithdrawAddress = _WithdrawAddr;

        IUniswapV2Router02 _tokenSwapRoute = IUniswapV2Router02(_Swap_Route);
        /* Create a Pancakeswap pair for this new token */
        tokenSwapPair = IUniswapV2Factory(_tokenSwapRoute.factory())
            .createPair(address(this), _tokenSwapRoute.WETH());
        /* Set the rest of the contract variables */
        tokenSwapRoute = _tokenSwapRoute;
        _bnb_Address = _tokenSwapRoute.WETH();
        _TokenReserv = IUniswapV2Pair(tokenSwapPair);
        _setAutomatedMarketMakerPair(tokenSwapPair, true);
        _isExcluded[address(this)] = true;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint256) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function totalBalance() external view returns (uint256) {
        return payable(address(this)).balance;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function totalCompany() public view returns (uint256) {
        return _tCompanyTotal;
    }

    function totalMarketing() public view returns (uint256) {
        return _tMarketingTotal;
    }

    function totalPooGame() public view returns (uint256) {
        return _tPooGameTotal;
    }

    function getMaxTransaction() public view returns (uint256) {
        return _MaxTransaction;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function multSender(Receivers[] memory wallets) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++)
            transfer(wallets[i].wallet, wallets[i].amount);
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccountToFee(address account) external onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccountToFee(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
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
        uint256 tokenAmount = _getTokenFeeTotal(amount);
        bool overMinTokenBalance;

        if (
            automatedMarketMakerPairs[sender] &&
            !automatedMarketMakerPairs[recipient]
        ) {
            // is Buy transaction
            _TAX_FEE = buyItems[1].Tax_Fee;
            _COMPANY_FEE = buyItems[1].Company_Fee;
            _MARKETING_FEE = buyItems[1].Marketing_Fee;
            _POOLGAME_FEE = 0;
        } else if (
            !automatedMarketMakerPairs[sender] &&
            automatedMarketMakerPairs[recipient]
        ) {
            overMinTokenBalance = tokenAmount > 0;
            // is Sell transaction
            if (executeMaxTransaction) {
                require(!_checkMaxTransaction(sender, amount), "BEP20: You have exceeded your daily transaction limit.");
            }
            
            _TAX_FEE = sellItems[1].Tax_Fee;
            _COMPANY_FEE = sellItems[1].Company_Fee;
            _MARKETING_FEE = sellItems[1].Marketing_Fee;
            _POOLGAME_FEE = sellItems[1].PoolGame_Fee;
        }else{
            if(_checkMaxTransaction(sender, amount) == true){
                _TAX_FEE = sellItems[1].Tax_Fee;
                _COMPANY_FEE = sellItems[1].Company_Fee;
                _MARKETING_FEE = sellItems[1].Marketing_Fee;
                _POOLGAME_FEE = sellItems[1].PoolGame_Fee;
            }
        }

        /* Swap Fee Transactions */
        if (overMinTokenBalance && tokenAmount > balanceOf(address(this))){
            tokenAmount = balanceOf(address(this));
        }

        if (
            !automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient] ||
            _isExcluded[sender] || inSwapAndLiquify
        ) {
            removeAllFee();
        } else {
            _executeFeeTransfer(sender, amount);
        }

        if (
            overMinTokenBalance &&
            !automatedMarketMakerPairs[sender] &&
            !inSwapAndLiquify &&
            swapAndTransferFeeEnabled
        ) {
            swapAndTransferFee(tokenAmount);
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
        if (!maxUserSell[userAddr].exist) {
            maxUserSell[userAddr].timestamp = block.timestamp;
            maxUserSell[userAddr].dailyAmount += amount;
            maxUserSell[userAddr].exist = true;
        }else{
            maxUserSell[userAddr].dailyAmount += amount;
        }

        uint256 hrs = block.timestamp / 3600 - maxUserSell[userAddr].timestamp / 3600;
        uint256 time = 24;

        if (maxUserSell[userAddr].dailyAmount > _MaxTransaction && hrs < time) {
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
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount) = _getValues(tAmount);
        (uint256 tTransferAmount) = _getTransferAmount(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount) = _getValues(tAmount);
        (uint256 tTransferAmount) = _getTransferAmount(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount) = _getValues(tAmount);
        (uint256 tTransferAmount) = _getTransferAmount(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount) = _getValues(tAmount);
        (uint256 tTransferAmount) = _getTransferAmount(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 tAmount) private {
        (uint256 tFee, uint256 tMarketing, uint256 tCompany, uint256 tPoolGame) = _getTValues(tAmount);
        (uint256 rFee, uint256 rMarketing, uint256 rCompany, uint256 rPoolGame) = _getRValues(
            tFee,
            tMarketing,
            tCompany,
            tPoolGame
        );
        _tFeeTotal = _tFeeTotal.add(tFee);
        _tMarketingTotal = _tMarketingTotal.add(tMarketing);
        _tCompanyTotal = _tCompanyTotal.add(tCompany);
        _tPooGameTotal = _tPooGameTotal.add(tPoolGame);
        _rTotal = _rTotal.sub(rFee).sub(rMarketing).sub(rCompany).sub(rPoolGame);

        emit FeeTransaction(tFee, tMarketing, tCompany);
    }

    function _executeFeeTransfer(address sender, uint256 tAmount) private {
        (, uint256 tMarketing, uint256 tCompany, uint256 tPoolGame) = _getTValues(tAmount);
        _tMarketingTotal = _tMarketingTotal.add(tMarketing);
        _tCompanyTotal = _tCompanyTotal.add(tCompany);
        _tPooGameTotal = _tPooGameTotal.add(tPoolGame);
        if (tMarketing > 0) {
            _sendToMarketing(sender, tMarketing);
        }
        if (tCompany > 0) {
            _sendToCompany(sender, tCompany);
        }
    }

    function _sendToMarketing(address sender, uint256 tMarketing) private {
        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
        _tOwned[address(this)] = _tOwned[address(this)].add(tMarketing);
        emit Transfer(sender, address(this), tMarketing);
    }

    function _sendToCompany(address sender, uint256 tCompany) private {
        uint256 currentRate = _getRate();
        uint256 rCompany = tCompany.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rCompany);
        _tOwned[address(this)] = _tOwned[address(this)].add(tCompany);
        emit Transfer(sender, address(this), tCompany);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (uint256, uint256)
    {
        uint256 currentRate = _getRate();
        (uint256 tFee, uint256 tMarketing, uint256 tCompany, uint256 tPoolGame) = _getTValues(tAmount);
        (uint256 rFee, uint256 rMarketing, uint256 rCompany, uint256 rPoolGame) = _getRValues(
            tFee,
            tMarketing,
            tCompany,
            tPoolGame
        );
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rMarketing).sub(rCompany).sub(rPoolGame);
        return (rAmount, rTransferAmount);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.mul(_TAX_FEE).div(100);
        uint256 tMarketing = tAmount.mul(_MARKETING_FEE).div(100);
        uint256 tCompany = tAmount.mul(_COMPANY_FEE).div(100);
        uint256 tPoolGame = tAmount.mul(_POOLGAME_FEE).div(100);
        return (tFee, tMarketing, tCompany, tPoolGame);
    }

    function _getRValues(
        uint256 tFee,
        uint256 tMarketing,
        uint256 tCompany,
        uint256 tPoolGame
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
        uint256 rFee = tFee.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rCompany = tCompany.mul(currentRate);
        uint256 rPoolGame = tPoolGame.mul(currentRate);
        return (rFee, rMarketing, rCompany, rPoolGame);
    }

    function _getTransferAmount(uint256 tAmount)
        private
        view
        returns (
            uint256
        )
    {
        (uint256 tFee, uint256 tMarketing, uint256 tCompany, uint256 tPoolGame) = _getTValues(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tMarketing).sub(tCompany).sub(tPoolGame);
        return (tTransferAmount);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function removeAllFee() private {
        if (
            _TAX_FEE == 0 && _MARKETING_FEE == 0 && _COMPANY_FEE == 0 ||
            _TAX_FEE == 0 && _MARKETING_FEE == 0 && _COMPANY_FEE == 0 && _POOLGAME_FEE == 0
        ) return;
        _TAX_FEE = 0;
        _MARKETING_FEE = 0;
        _COMPANY_FEE = 0;
        _POOLGAME_FEE = 0; 
    }

    /*
     * @dev Sitem of Create/View/Update/Delete
     * @dev Management System fee Buy
     */
    function createBuyFee(
        uint256 _txFee,
        uint256 _MarketingFee,
        uint256 _companyFee
    ) public onlyOwner {
        require(!buyItems[1].exist, "A fee already exists, created");
        uint256 _buyId = 1;
        buyItems[_buyId].Tax_Fee = _txFee;
        buyItems[_buyId].Company_Fee = _MarketingFee;
        buyItems[_buyId].Marketing_Fee = _companyFee;
        buyItems[_buyId].exist = true;
    }

    function updateBuyFee(
        uint256 _txFee,
        uint256 _MarketingFee,
        uint256 _companyFee
    ) public onlyOwner {
        BuyFee storage item = buyItems[1];
        item.Tax_Fee = _txFee;
        item.Marketing_Fee = _MarketingFee;
        item.Company_Fee = _companyFee;
    }

    /*
     *get getBuyFeeDetails
     */
    function getBuyFee()
        public
        view
        returns (
            uint256 _txFee,
            uint256 _MarketingFee,
            uint256 _companyFee,
            bool _exist
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
        uint256 _txFee,
        uint256 _MarketingFee,
        uint256 _companyFee,
        uint256 _PooGameFee
    ) public onlyOwner {
        require(!sellItems[1].exist, "A fee already exists, created");
        uint256 _sellId = 1;
        sellItems[_sellId].Tax_Fee = _txFee;
        sellItems[_sellId].Marketing_Fee = _MarketingFee;
        sellItems[_sellId].Company_Fee = _companyFee;
        sellItems[_sellId].PoolGame_Fee = _PooGameFee;
        sellItems[_sellId].exist = true;
    }

    function updateSellFee(
        uint256 _txFee,
        uint256 _MarketingFee,
        uint256 _companyFee,
        uint256 _PooGameFee
    ) public onlyOwner {
        SellFee storage item = sellItems[1];
        item.Tax_Fee = _txFee;
        item.Marketing_Fee = _MarketingFee;
        item.Company_Fee = _companyFee;
        item.PoolGame_Fee = _PooGameFee;
    }

    /*
     *get getBuyFeeDetails
     */
    function getSellFee()
        public
        view
        returns (
            uint256 _txFee,
            uint256 _MarketingFee,
            uint256 _companyFee,
            uint256 _PooGameFee,
            bool _exist
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
    function swapAndTransferFee(uint256 tokenAmount) private lockTheSwap {
        /* Generate the Pancakeswap pair path of token -> wbnb */
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenSwapRoute.WETH();

        /* Swap tokens for BNB */
        _approve(address(this), address(tokenSwapRoute), type(uint256).max);

        /* Make the swap */
        tokenSwapRoute.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 300
        );

        /* Send BNB to Wallets Fee */
        uint256 withAmount = address(this).balance;
        uint256 half = withAmount.div(2);
        uint256 otherHalf = withAmount.sub(half);

        if (half != 0) {
            sendFeeBNB(CompanyAddress, half);
        }
        if (otherHalf != 0) {
            sendFeeBNB(MarketAddress, otherHalf);
        }
    }

    function _getTokenFeeTotal(uint256 amount) private view returns (uint256) {
        uint256 tokenFee = _COMPANY_FEE.add(_MARKETING_FEE);
        uint256 tokenAmount = amount.mul(tokenFee).div(100);
        return tokenAmount;
    }

    function sendFeeBNB(address recipient, uint256 withAmount) private {
        // prevent re-entrancy attacks
        payable(recipient).transfer(withAmount);
        emit BNBWithdrawn(recipient, withAmount);
    }

    function executeAutoTransferFee(uint256 tokemAmount) external onlyOwner {
        require(
            tokemAmount < balanceOf(address(this)),
            "Insufficient balance for this transaction."
        );
        swapAndTransferFee(tokemAmount);
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

    function setCompanyAdress(address _companyAddress) public onlyOwner {
        CompanyAddress = _companyAddress;
    }

    function setMarketingAdress(address _MarketingAddress) public onlyOwner {
        MarketAddress = _MarketingAddress;
    }

    function setWithAdress(address payable _WithdrawAddress) public onlyOwner {
        WithdrawAddress = _WithdrawAddress;
    }

    function getWithdrawAddress() public view returns (address) {
        return WithdrawAddress;
    }

    function setMaxTransaction(uint256 amount_BNB) public onlyOwner {
        _MaxTransaction = amount_BNB;
    }

    function setExecuteTransaction() external onlyOwner {
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
        IUniswapV2Pair _tokenPair = IUniswapV2Pair(_TokenReserv);
        if (_bnb_Address == _tokenPair.token0()) {
            (uint256 ResBNB, uint256 ResTOKEN, ) = _tokenPair.getReserves();
            uint256 pricebnb = ResTOKEN.div(ResBNB);
            return amount.div(pricebnb); //return amount of BNB needed to Transaction
        } else {
            (uint256 ResTOKEN, uint256 ResBNB, ) = _tokenPair.getReserves();
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

    function withdToBNB() public onlyOwner {
        require(
            WithdrawAddress != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        require(
            this.totalBalance() > 0,
            "You do not have enough balance for this withdrawal"
        );
        payable(WithdrawAddress).transfer(this.totalBalance());
    }

    function withdTokens(address _contractAdd) public onlyOwner {
        require(
            WithdrawAddress != address(0),
            "To make the withdrawal, you need to register a valid address."
        );
        IBEP20 ContractAdd = IBEP20(_contractAdd);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        require(
            dexBalance > 0,
            "You do not have enough balance for this withdrawal"
        );
        ContractAdd.transfer(WithdrawAddress, dexBalance);
    }

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SetRouterAddressEvent(address value);
    event FeeTransaction(uint256 tFee, uint256 tMarketing, uint256 tCompany);
    event BNBWithdrawn(address beneficiary, uint256 value);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
}