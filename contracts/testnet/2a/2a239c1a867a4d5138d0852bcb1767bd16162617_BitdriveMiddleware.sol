/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-22
 */

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
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

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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

    uint256[49] private __gap;
}

// pragma solidity >=0.5.0;

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

// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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

interface IBiswapRouter02 {
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 swapFee
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 swapFee
    ) external pure returns (uint256 amountIn);
}

interface IBiswapPair {
    function swapFee() external view returns (uint32);
}

library BiswapLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "BiswapLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "BiswapLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"cb547f1f09d4b6da5741a72d2f382645c117cc60e70bc1273e86dda1e70e59e0" // init code hash
                    )
                )
            )
        );
    }

    function getSwapFee(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 swapFee) {
        swapFee = IBiswapPair(pairFor(factory, tokenA, tokenB)).swapFee();
    }
}

// pragma solidity >=0.6.2;

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

// File: contracts/libs/SafeBEP20.sol

pragma solidity >=0.6.0 <0.8.0;

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

// File: contracts/interfaces/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

contract BitdriveMiddleware is ContextUpgradeable, OwnableUpgradeable {
    using SafeMath for uint256;
    using Address for address;
    using SafeBEP20 for IBEP20;

    address payable adminAddress;
    address public routerAddress;

    address public bitdriverouter;
    address public pancakerouter;
    address public biswaprouter;
    address public biswapfactory;

    uint256 public bitdrivefee;
    uint256 public biswapfee;
    uint256 public pancakefee;
    uint256 public sitefee;

    event SwapValue(
        uint256 indexed adminfee,
        uint256 indexed amountin,
        uint256 indexed amountout
    );

    uint256 public test1;
    uint256 public test2;
    uint256 public test3;

    IUniswapV2Router02 public uniswapV2Router;

    struct Calculation {
        uint256 fee;
        uint256 amountIn;
        uint256 amountOut;
        uint256 adminfee;
        uint256 amountInFee;
        uint256 inputAmount;
        uint256 outputAmount;
        uint256 totalAmount;
        uint256 balance;
        address[] path;
    }
    Calculation public calculation;

    function initialize(address payable _admin) public initializer {
        biswapfee = 200000000000000000;
        pancakefee = 200000000000000000;
        bitdrivefee = 250000000000000000;
        sitefee = 300000000000000000;
        biswaprouter = 0x057aE4669A5DcdB78c335E449242E072215f4477;
        pancakerouter = 0xA120c68E2d1AfE381381a1C6CD9831eE60E4B1Df;
        bitdriverouter = 0x912A5515093E29daCF5f9975A2ab3512B01c84ec;
        biswapfactory = 0xE6DD948317d00D4B1DBA49e79EBBa4e2589f0324;
        adminAddress = _admin;
    }

    function swapExactTokensForETHMiddleware(
        address router,
        IBEP20 _tokenContract,
        address to,
        uint256 deadline,
        address inputToken,
        address pair,
        address outputToken,
        uint256 inputAmount,
        uint256 inputType
    ) public payable returns (uint256[] memory amounts) {
        require(
            router == bitdriverouter ||
                router == biswaprouter ||
                router == pancakerouter,
            "Invalid router"
        );
        require(inputAmount > 0, "Invalid amount");
        require(inputType == 1 || inputType == 2, "Invalid input");

        calculation.fee = 0;
        if (router == bitdriverouter) {
            calculation.fee = sitefee.sub(bitdrivefee);
        } else if (router == biswaprouter) {
            calculation.fee = sitefee.sub(biswapfee);
        } else if (router == pancakerouter) {
            calculation.fee = sitefee.sub(pancakefee);
        }

        if (inputType == 1) {
            calculation.adminfee = inputAmount.mul(calculation.fee).div(1e20);
            calculation.totalAmount = inputAmount.add(calculation.adminfee);
            calculation.amountIn = inputAmount.sub(calculation.adminfee);
            calculation.path = [inputToken, outputToken];
            calculation.inputAmount = inputAmount;
            calculation.outputAmount = estimategetAmountOut(
                router,
                pair,
                inputToken,
                outputToken,
                calculation.amountIn
            );
            calculation.amountOut = calculation.outputAmount;

            IBEP20 tokenContract = _tokenContract;
            calculation.balance = tokenContract.balanceOf(msg.sender);
            require(
                calculation.balance >= calculation.totalAmount,
                "Insufficient Balance"
            );
            uint256 allowanceBalance = tokenContract.allowance(
                msg.sender,
                address(this)
            );
            require(
                allowanceBalance >= calculation.totalAmount,
                "Insufficient allowance"
            );

            tokenContract.approve(router, calculation.totalAmount);
            tokenContract.transferFrom(
                msg.sender,
                address(this),
                calculation.amountIn
            );
            tokenContract.transferFrom(
                msg.sender,
                adminAddress,
                calculation.adminfee
            );

            IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(router);
            amounts = uniswapV2Router.swapExactTokensForETH(
                calculation.amountIn,
                calculation.outputAmount,
                calculation.path,
                to,
                deadline
            );
            emit SwapValue(
                calculation.adminfee,
                calculation.amountIn,
                calculation.outputAmount
            );
        } else {
            calculation.outputAmount = estimategetAmountIn(
                router,
                pair,
                inputToken,
                outputToken,
                inputAmount
            );
            calculation.adminfee = calculation
                .outputAmount
                .mul(calculation.fee)
                .div(1e20);
            calculation.totalAmount = calculation.outputAmount.add(
                calculation.adminfee
            );
            calculation.amountIn = calculation.outputAmount.sub(
                calculation.adminfee
            );
            calculation.path = [inputToken, outputToken];
            calculation.inputAmount = calculation.outputAmount;
            calculation.amountOut = inputAmount;

            IBEP20 tokenContract = _tokenContract;
            calculation.balance = tokenContract.balanceOf(msg.sender);
            require(
                calculation.balance >= calculation.totalAmount,
                "Insufficient Balance"
            );
            uint256 allowanceBalance = tokenContract.allowance(
                msg.sender,
                address(this)
            );
            require(
                allowanceBalance >= calculation.totalAmount,
                "Insufficient allowance"
            );

            tokenContract.approve(router, calculation.totalAmount);
            tokenContract.transferFrom(
                msg.sender,
                address(this),
                calculation.outputAmount
            );
            tokenContract.transferFrom(
                msg.sender,
                adminAddress,
                calculation.adminfee
            );

            IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(router);
            amounts = uniswapV2Router.swapTokensForExactETH(
                inputAmount,
                calculation.outputAmount,
                calculation.path,
                to,
                deadline
            );
            emit SwapValue(
                calculation.adminfee,
                inputAmount,
                calculation.outputAmount
            );
        }
    }

    function estimategetAmountOut(
        address router,
        address pair,
        address inputToken,
        address outputToken,
        uint256 inputAmount
    ) internal view returns (uint256 outputAmount) {
        IUniswapV2Pair paircontract = IUniswapV2Pair(pair);

        address token0;
        address token1;
        (token0, token1) = inputToken < outputToken
            ? (inputToken, outputToken)
            : (outputToken, inputToken);
        (uint112 reserve0, uint112 reserve1, ) = paircontract.getReserves();
        uint256 reserveIn;
        uint256 reserveOut;
        if (inputToken == token0) {
            reserveIn = reserve0;
            reserveOut = reserve1;
        } else {
            reserveIn = reserve1;
            reserveOut = reserve0;
        }

        if (router == biswaprouter) {
            IBiswapRouter02 routercontract = IBiswapRouter02(router);
            IBiswapPair pair = IBiswapPair(
                BiswapLibrary.pairFor(biswapfactory, inputToken, outputToken)
            );
            outputAmount = routercontract.getAmountOut(
                inputAmount,
                reserveIn,
                reserveOut,
                pair.swapFee()
            );
        } else {
            IUniswapV2Router01 routercontract = IUniswapV2Router01(router);
            outputAmount = routercontract.getAmountOut(
                inputAmount,
                reserveIn,
                reserveOut
            );
        }
    }

    function estimategetAmountIn(
        address router,
        address pair,
        address inputToken,
        address outputToken,
        uint256 outputAmount
    ) internal view returns (uint256 inputAmount) {
        IUniswapV2Pair paircontract = IUniswapV2Pair(pair);

        address token0;
        address token1;
        (token0, token1) = inputToken < outputToken
            ? (inputToken, outputToken)
            : (outputToken, inputToken);
        (uint112 reserve0, uint112 reserve1, ) = paircontract.getReserves();
        uint256 reserveIn;
        uint256 reserveOut;
        if (inputToken == token0) {
            reserveIn = reserve0;
            reserveOut = reserve1;
        } else {
            reserveIn = reserve1;
            reserveOut = reserve0;
        }
        if (router == biswaprouter) {
            IBiswapRouter02 routercontract = IBiswapRouter02(router);
            IBiswapPair pair = IBiswapPair(
                BiswapLibrary.pairFor(biswapfactory, inputToken, outputToken)
            );
            inputAmount = routercontract.getAmountIn(
                outputAmount,
                reserveIn,
                reserveOut,
                pair.swapFee()
            );
        } else {
            IUniswapV2Router01 routercontract = IUniswapV2Router01(router);
            inputAmount = routercontract.getAmountIn(
                outputAmount,
                reserveIn,
                reserveOut
            );
        }
    }

    function swapExactETHForTokensMiddleware(
        address router,
        IBEP20 _tokenContract,
        address to,
        uint256 deadline,
        address inputToken,
        address pair,
        address outputToken,
        uint256 inputAmount,
        uint256 inputType
    ) public payable returns (uint256[] memory amounts) {
        require(
            router == bitdriverouter ||
                router == biswaprouter ||
                router == pancakerouter,
            "Invalid router"
        );
        require(inputAmount > 0, "Invalid amount");
        require(inputType == 1 || inputType == 2, "Invalid input");

        calculation.fee = 0;
        if (router == bitdriverouter) {
            calculation.fee = sitefee.sub(bitdrivefee);
        } else if (router == biswaprouter) {
            calculation.fee = sitefee.sub(biswapfee);
        } else if (router == pancakerouter) {
            calculation.fee = sitefee.sub(pancakefee);
        }

        if (inputType == 1) {
            calculation.adminfee = inputAmount.mul(calculation.fee).div(1e20);
            calculation.amountIn = inputAmount.sub(calculation.adminfee);
            calculation.path = [inputToken, outputToken];
            calculation.inputAmount = inputAmount;
            calculation.outputAmount = estimategetAmountOut(
                router,
                pair,
                inputToken,
                outputToken,
                calculation.amountIn
            );
            calculation.amountOut = calculation.outputAmount;

            adminAddress.transfer(calculation.adminfee);
            IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(router);
            amounts = uniswapV2Router.swapExactETHForTokens{
                value: calculation.amountIn
            }(calculation.outputAmount, calculation.path, to, deadline);
            emit SwapValue(
                calculation.adminfee,
                calculation.amountIn,
                calculation.outputAmount
            );
        } else {
            calculation.outputAmount = estimategetAmountIn(
                router,
                pair,
                inputToken,
                outputToken,
                inputAmount
            );
            calculation.adminfee = calculation
                .outputAmount
                .mul(calculation.fee)
                .div(1e20);
            calculation.amountIn = calculation.outputAmount.sub(
                calculation.adminfee
            );
            calculation.path = [inputToken, outputToken];
            calculation.inputAmount = calculation.outputAmount;
            calculation.amountOut = inputAmount;

            adminAddress.transfer(calculation.adminfee);
            IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(router);
            amounts = uniswapV2Router.swapETHForExactTokens{
                value: calculation.outputAmount
            }(inputAmount, calculation.path, to, deadline);
            emit SwapValue(
                calculation.adminfee,
                calculation.outputAmount,
                inputAmount
            );
        }
    }

    function swapExactTokensForTokensMiddleware(
        address router,
        IBEP20 _tokenContract,
        address to,
        uint256 deadline,
        address inputToken,
        address pair,
        address outputToken,
        uint256 inputAmount
    ) public returns (uint256[] memory amounts) {
        require(
            router == bitdriverouter ||
                router == biswaprouter ||
                router == pancakerouter,
            "Invalid router"
        );
        require(inputAmount > 0, "Invalid amount");

        calculation.fee = 0;
        if (router == bitdriverouter) {
            calculation.fee = sitefee.sub(bitdrivefee);
        } else if (router == biswaprouter) {
            calculation.fee = sitefee.sub(biswapfee);
        } else if (router == pancakerouter) {
            calculation.fee = sitefee.sub(pancakefee);
        }

        calculation.adminfee = inputAmount.mul(calculation.fee).div(1e20);
        calculation.totalAmount = inputAmount.add(calculation.adminfee);
        calculation.amountIn = inputAmount.sub(calculation.adminfee);
        calculation.path = [inputToken, outputToken];

        calculation.outputAmount = estimategetAmountOut(
            router,
            pair,
            inputToken,
            outputToken,
            calculation.amountIn
        );

        IBEP20 tokenContract = _tokenContract;
        calculation.balance = tokenContract.balanceOf(msg.sender);

        require(
            calculation.balance >= calculation.totalAmount,
            "Insufficient Balance"
        );
        uint256 allowanceBalance = tokenContract.allowance(
            msg.sender,
            address(this)
        );
        require(
            allowanceBalance >= calculation.totalAmount,
            "Insufficient allowance"
        );

        tokenContract.approve(router, calculation.totalAmount);

        tokenContract.transferFrom(
            msg.sender,
            address(this),
            calculation.totalAmount
        );

        tokenContract.transferFrom(
            msg.sender,
            adminAddress,
            calculation.adminfee
        );

        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(router);

        amounts = uniswapV2Router.swapExactTokensForTokens(
            inputAmount,
            calculation.outputAmount,
            calculation.path,
            to,
            deadline
        );
        emit SwapValue(
            calculation.adminfee,
            inputAmount,
            calculation.outputAmount
        );
    }

    function swapTokensForExactTokensMiddleware(
        address router,
        IBEP20 _tokenContract,
        address to,
        uint256 deadline,
        address inputToken,
        address pair,
        address outputToken,
        uint256 outputAmount
    ) public returns (uint256[] memory amounts) {
        require(
            router == bitdriverouter ||
                router == biswaprouter ||
                router == pancakerouter,
            "Invalid router"
        );
        require(outputAmount > 0, "Invalid amount");

        calculation.fee = 0;
        if (router == bitdriverouter) {
            calculation.fee = sitefee.sub(bitdrivefee);
        } else if (router == biswaprouter) {
            calculation.fee = sitefee.sub(biswapfee);
        } else if (router == pancakerouter) {
            calculation.fee = sitefee.sub(pancakefee);
        }

        calculation.totalAmount = outputAmount.add(calculation.adminfee);
        calculation.amountOut = outputAmount.sub(calculation.adminfee);
        calculation.path = [inputToken, outputToken];

        calculation.outputAmount = estimategetAmountIn(
            router,
            pair,
            inputToken,
            outputToken,
            outputAmount
        );

        calculation.adminfee = calculation
            .outputAmount
            .mul(calculation.fee)
            .div(1e20);
        calculation.amountIn = calculation.adminfee.add(
            calculation.outputAmount
        );

        IBEP20 tokenContract = _tokenContract;
        uint256 balance = tokenContract.balanceOf(msg.sender);

        require(balance >= calculation.amountIn, "Insufficient Balance");

        uint256 allowanceBalance = tokenContract.allowance(
            msg.sender,
            address(this)
        );
        tokenContract.approve(router, calculation.amountIn);

        require(
            allowanceBalance >= calculation.amountIn,
            "Insufficient allowance"
        );

        tokenContract.transferFrom(
            msg.sender,
            address(this),
            calculation.amountIn
        );
        tokenContract.transferFrom(
            msg.sender,
            adminAddress,
            calculation.adminfee
        );
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(router);

        amounts = uniswapV2Router.swapTokensForExactTokens(
            outputAmount,
            calculation.amountIn,
            calculation.path,
            to,
            deadline
        );
        emit SwapValue(
            calculation.adminfee,
            outputAmount,
            calculation.amountIn
        );
    }

    function bitdriveSettings(
        uint256 _fee,
        address _router,
        uint256 _changetype
    ) public {
        require(msg.sender == adminAddress, "FORBIDDEN");
        require(_changetype == 1 || _changetype == 2, "FORBIDDEN");
        if (_changetype == 1) {
            bitdrivefee = _fee;
        }
        if (_changetype == 2) {
            bitdriverouter = _router;
        }
    }

    function biswapSettings(
        uint256 _fee,
        address _router,
        uint256 _changetype
    ) public {
        require(msg.sender == adminAddress, "FORBIDDEN");
        require(_changetype == 1 || _changetype == 2, "FORBIDDEN");
        if (_changetype == 1) {
            biswapfee = _fee;
        }
        if (_changetype == 2) {
            biswaprouter = _router;
        }
    }

    function pancakeSettings(
        uint256 _fee,
        address _router,
        uint256 _changetype
    ) public {
        require(msg.sender == adminAddress, "FORBIDDEN");
        require(_changetype == 1 || _changetype == 2, "FORBIDDEN");
        if (_changetype == 1) {
            pancakefee = _fee;
        }
        if (_changetype == 2) {
            pancakerouter = _router;
        }
    }

    function changesiteFee(uint256 _sitefee) public {
        require(msg.sender == adminAddress, "FORBIDDEN");
        sitefee = _sitefee;
    }

    function changeAdmin(address payable _adminAddress) public {
        require(msg.sender == adminAddress, "FORBIDDEN");
        adminAddress = _adminAddress;
    }
}