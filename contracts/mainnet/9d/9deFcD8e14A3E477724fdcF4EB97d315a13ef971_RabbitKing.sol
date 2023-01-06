/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
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
    function allowance(address owner, address spender)
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
    address private _previousOwner;
    uint256 private _lockTime;

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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

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

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract RabbitKing is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    struct FeeTier {
        uint256 taxFee;
        uint256 ownerFee;
        uint256 burnFee;
        address owner;
        uint256 totalFee;
    }

    struct FeeValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tOwner;
        uint256 tBurn;
    }

    struct tFeeValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tOwner;
        uint256 tBurn;
    }

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _defaultExcluded;
    mapping(address => uint256) private _accountsTier;
    enum CHECK {
        NOTCHECKED,
        CHECKEDANDNOTNEED,
        ISNEED
    }
    mapping(address => CHECK) public _isRouter;
    mapping(address => CHECK) public _isPair;
    mapping(address => bool) public whitelist;
    address[] public whitelistAddress;
    mapping(uint256 => uint256) public whitelistReleaseTime;
    uint256 public start;
    uint256 private totalPresaleNum;
    uint256 private whitelistPresaleAmount;

    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 private _maxFee;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    FeeTier public _defaultFees;
    FeeTier private _previousFees;
    FeeTier private _emptyFees;
    uint256 private feeDivide = 10**4;
    uint256 private minNumForReward;
    bool public checkReward;
    uint256 private whitelistMaxNum;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public WBNB;
    address private _walletManager;
    address private _burnAddress;
    address private _ownerFeeManager;
    address private _whitelistManager;
    address private _echosystem;

    modifier checkIsRouter(address _sender) {
        {
            if (_isRouter[_sender] == CHECK.NOTCHECKED) {
                if (address(_sender).isContract()) {
                    IUniswapV2Router02 _routerCheck = IUniswapV2Router02(
                        _sender
                    );
                    try _routerCheck.WETH() returns (address) {
                        try _routerCheck.factory() returns (address) {
                            _isRouter[_sender] = CHECK.ISNEED;
                        } catch {
                            _isRouter[_sender] = CHECK.CHECKEDANDNOTNEED;
                        }
                    } catch {
                        _isRouter[_sender] = CHECK.CHECKEDANDNOTNEED;
                    }
                } else {
                    _isRouter[_sender] = CHECK.CHECKEDANDNOTNEED;
                }
            }
        }

        _;
    }

    modifier checkIsPair(address _sender) {
        {
            if (_isPair[_sender] == CHECK.NOTCHECKED) {
                if (_sender.isContract()) {
                    IUniswapV2Pair _pairCheck = IUniswapV2Pair(_sender);
                    try _pairCheck.token0() returns (address) {
                        try _pairCheck.token1() returns (address) {
                            try _pairCheck.factory() returns (address) {
                                address _token0 = _pairCheck.token0();
                                address _token1 = _pairCheck.token1();
                                address this_token = address(this) == _token0
                                    ? _token0
                                    : address(this) == _token1
                                    ? _token1
                                    : address(0);
                                if (this_token != address(0)) {
                                    _isPair[_sender] == CHECK.ISNEED;
                                } else {
                                    _isPair[_sender] == CHECK.CHECKEDANDNOTNEED;
                                }
                            } catch {
                                _isPair[_sender] == CHECK.CHECKEDANDNOTNEED;
                            }
                        } catch {
                            _isPair[_sender] == CHECK.CHECKEDANDNOTNEED;
                        }
                    } catch {
                        _isPair[_sender] == CHECK.CHECKEDANDNOTNEED;
                    }
                } else {
                    _isPair[_sender] == CHECK.CHECKEDANDNOTNEED;
                }
            }
        }

        _;
    }

    /**
     * @dev
     * We create 2 variables _rTotalExcluded and _tTotalExcluded that store total t and r excluded
     * So for any actions such as add, remove exclude wallet or increase, decrease exclude amount, we will update
     * _rTotalExcluded and _tTotalExcluded
     * and in _getCurrentSupply() function, we remove for loop by using _rTotalExcluded and _tTotalExcluded
     * But this contract using proxy pattern, so when we upgrade contract,
     *  we need to call updateTotalExcluded() to init value of _rTotalExcluded and _tTotalExcluded
     */
    uint256 private _rTotalExcluded;
    uint256 private _tTotalExcluded;

    constructor() {
        _name = "RabbitKing";
        _symbol = "RabbitKing";
        _decimals = 18;

        _tTotal = 1e10 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        _maxFee = 1000;

        _burnAddress = address(0x000000000000000000000000000000000000dEaD);

        _walletManager = address(0x434B3E7FD1Aaf31E2aDc9e6Ea8f9640E31C4a4ef);
        _ownerFeeManager = address(0x41F6a7E9C09A49Ffa32D968FD1C8def4F799cB2C);
        _whitelistManager = address(0x60a82f6E1c7850FA162e52d1dC30cCb95e2D7aDD);
        _echosystem = _msgSender();
        address _router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uint256 _walletManagerPercent = 30;
        uint256 _presalePercent = 30;
        uint256 _burnPercent = 40;
        uint256 _baseDivide = 100;
        minNumForReward = 1e6 * 10**_decimals;
        checkReward = true;
        totalPresaleNum = _tTotal.div(_baseDivide).mul(_presalePercent);
        start = uint256(1673006400);

        _rOwned[_walletManager] = _rTotal.div(_baseDivide).mul(
            _walletManagerPercent
        );
        emit Transfer(
            address(0),
            _walletManager,
            _tTotal.div(_baseDivide).mul(_walletManagerPercent)
        );
        _rOwned[address(this)] = _rTotal.div(_baseDivide).mul(
            _presalePercent.add(_burnPercent)
        );
        emit Transfer(
            address(0),
            address(this),
            _tTotal.div(_baseDivide).mul(_presalePercent.add(_burnPercent))
        );

        _whitelist_release_time_init();
        _routerAndpair_init(_router);
        _exclude_init();
        _tiers_init();
        _burn(address(this), _tTotal.div(_baseDivide).mul(_burnPercent));
    }

    function _whitelist_release_time_init() internal {
        whitelistPresaleAmount = 1e8 * 10**_decimals;
        whitelistMaxNum = 30;
        require(
            whitelistMaxNum.mul(whitelistPresaleAmount) <= totalPresaleNum,
            "Whitelist: presale nums  execced max amount"
        );

        whitelistReleaseTime[0] = uint256(1673056800);
        whitelistReleaseTime[1] = uint256(1674316800);
        whitelistReleaseTime[2] = uint256(1675526400);
        whitelistReleaseTime[3] = uint256(1677600000);
    }

    function _routerAndpair_init(address _router) internal {
        uniswapV2Router = IUniswapV2Router02(_router);
        WBNB = uniswapV2Router.WETH();
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                WBNB
            );
        _isRouter[_router] = CHECK.ISNEED;
        _isPair[uniswapV2Pair] = CHECK.ISNEED;

        _isRouter[address(0)] = CHECK.CHECKEDANDNOTNEED;
        _isPair[address(0)] = CHECK.CHECKEDANDNOTNEED;
        _isRouter[address(this)] = CHECK.CHECKEDANDNOTNEED;
        _isPair[address(this)] = CHECK.CHECKEDANDNOTNEED;
        _isRouter[_burnAddress] = CHECK.CHECKEDANDNOTNEED;
        _isPair[_burnAddress] = CHECK.CHECKEDANDNOTNEED;
        _isRouter[owner()] = CHECK.CHECKEDANDNOTNEED;
        _isPair[owner()] = CHECK.CHECKEDANDNOTNEED;
        _isRouter[_walletManager] = CHECK.CHECKEDANDNOTNEED;
        _isPair[_walletManager] = CHECK.CHECKEDANDNOTNEED;
        _isRouter[_ownerFeeManager] = CHECK.CHECKEDANDNOTNEED;
        _isPair[_ownerFeeManager] = CHECK.CHECKEDANDNOTNEED;
        _isRouter[_whitelistManager] = CHECK.CHECKEDANDNOTNEED;
        _isPair[_whitelistManager] = CHECK.CHECKEDANDNOTNEED;
    }

    function _exclude_init() internal {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_walletManager] = true;
        _isExcludedFromFee[_ownerFeeManager] = true;
        _isExcludedFromFee[_whitelistManager] = true;
        _isExcludedFromFee[address(this)] = true;

        _excludeFromReward(address(this));
        _defaultExcluded[address(this)] = true;
        _excludeFromReward(owner());
        _defaultExcluded[owner()] = true;
        _excludeFromReward(_walletManager);
        _defaultExcluded[_walletManager] = true;
        _excludeFromReward(_ownerFeeManager);
        _defaultExcluded[_ownerFeeManager] = true;
        _excludeFromReward(_whitelistManager);
        _defaultExcluded[_whitelistManager] = true;
        _excludeFromReward(_burnAddress);
        _defaultExcluded[_burnAddress] = true;
    }

    function _tiers_init() internal {
        _defaultFees = _addTier(300, 200, 300, _ownerFeeManager);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];

        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        checkIsPair(msg.sender)
        checkIsPair(recipient)
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        checkIsRouter(spender)
        checkIsPair(spender)
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        override
        checkIsPair(msg.sender)
        checkIsPair(sender)
        checkIsPair(recipient)
        returns (bool)
    {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromTokenInTiers(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            FeeValues memory _values = _getValues(tAmount);
            return _values.rAmount;
        } else {
            FeeValues memory _values = _getValues(tAmount);
            return _values.rTransferAmount;
        }
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        return reflectionFromTokenInTiers(tAmount, deductTransferFee);
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

    function excludeFromReward(address account) public {
        require(
            msg.sender == _echosystem || msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        require(!_isExcluded[account], "Account is already excluded");
        _excludeFromReward(account);
    }

    function includeInReward(address account) external {
        require(
            msg.sender == _echosystem || msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        require(_isExcluded[account], "Account is already included");
        _includeInReward(account);
    }

    function excludeFromFee(address account) public {
        require(
            msg.sender == _echosystem || msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public {
        require(
            msg.sender == _echosystem || msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        _isExcludedFromFee[account] = false;
    }

    function whitelistNums() public view returns (uint256) {
        return whitelistAddress.length;
    }

    function isWhitelist(address _account) public view returns (bool) {
        return whitelist[_account];
    }

    function checkWhiteLockNums(address account)
        internal
        view
        returns (uint256 lockNum)
    {
        if (whitelist[account]) {
            if (block.timestamp < whitelistReleaseTime[0]) {
                lockNum = whitelistPresaleAmount;
            } else if (block.timestamp >= whitelistReleaseTime[0]) {
                lockNum = whitelistPresaleAmount.div(100).mul(80);
            } else if (block.timestamp >= whitelistReleaseTime[1]) {
                lockNum = whitelistPresaleAmount.div(100).mul(50);
            } else if (block.timestamp >= whitelistReleaseTime[2]) {
                lockNum = whitelistPresaleAmount.div(100).mul(20);
            } else if (block.timestamp >= whitelistReleaseTime[3]) {
                lockNum = 0;
            }
        }
    }

    function _excludeFromReward(address account) internal {
        if (_isExcluded[account]) {
            return;
        }
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
            _tTotalExcluded = _tTotalExcluded.add(_tOwned[account]);
            _rTotalExcluded = _rTotalExcluded.add(_rOwned[account]);
        }

        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function _includeInReward(address account) internal {
        if (!_isExcluded[account]) {
            return;
        }
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tTotalExcluded = _tTotalExcluded.sub(_tOwned[account]);
                _rTotalExcluded = _rTotalExcluded.sub(_rOwned[account]);
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _addWhitelist(address account) internal {
        for (uint256 i = 0; i < whitelistAddress.length; i++) {
            if (whitelistAddress[i] == account) {
                whitelist[account] = true;
                return;
            }
        }
        whitelistAddress.push(account);
        whitelist[account] = true;
    }

    function _removeWhitelist(address account) internal {
        address[] memory temp;
        for (uint256 i = 0; i < whitelistAddress.length; i++) {
            if (whitelistAddress[i] == account) {
                whitelist[account] = false;
            } else {
                temp[temp.length] = whitelistAddress[i];
            }
        }
        whitelistAddress = temp;
    }

    function checkFees(FeeTier memory _tier)
        internal
        view
        returns (FeeTier memory)
    {
        uint256 _fees = _tier.taxFee.add(_tier.ownerFee).add(_tier.burnFee);
        require(_fees <= _maxFee, "Fees: Fees exceeded max limitation");

        return _tier;
    }

    function addWhitelist(address[] memory accounts) external {
        require(
            msg.sender == _echosystem || msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        require(
            accounts.length.add(whitelistAddress.length) <= whitelistMaxNum,
            "Whitelist: accounts num exceed max num!"
        );
        require(
            balanceOf(address(this)) >=
                whitelistPresaleAmount.mul(accounts.length),
            "Whitelist: Amounts exceed balance!"
        );

        for (uint8 i = 0; i < accounts.length; i++) {
            if (balanceOf(address(this)) < whitelistPresaleAmount) {
                return;
            }

            _tokenTransfer(
                address(this),
                accounts[i],
                whitelistPresaleAmount,
                false
            );
            _addWhitelist(accounts[i]);
        }
    }

    function removeWhilist(address account) external {
        require(
            msg.sender == _echosystem || msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        _removeWhitelist(account);
    }

    function _addTier(
        uint256 _taxFee,
        uint256 _ownerFee,
        uint256 _burnFee,
        address _owner
    ) internal returns (FeeTier memory) {
        FeeTier memory _newTier = checkFees(
            FeeTier(
                _taxFee,
                _ownerFee,
                _burnFee,
                _owner,
                _taxFee.add(_ownerFee.add(_burnFee))
            )
        );
        _excludeFromReward(_owner);
        return _newTier;
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (FeeValues memory)
    {
        tFeeValues memory tValues = _getTValues(tAmount);
        uint256 tTransferFee = tValues.tOwner.add(tValues.tBurn);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tValues.tFee,
            tTransferFee,
            _getRate()
        );
        return
            FeeValues(
                rAmount,
                rTransferAmount,
                rFee,
                tValues.tTransferAmount,
                tValues.tFee,
                tValues.tOwner,
                tValues.tBurn
            );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (tFeeValues memory)
    {
        FeeTier memory tier = _defaultFees;
        tFeeValues memory tValues = tFeeValues(
            0,
            calculateFee(tAmount, tier.taxFee),
            calculateFee(tAmount, tier.ownerFee),
            calculateFee(tAmount, tier.burnFee)
        );

        tValues.tTransferAmount = tAmount
            .sub(tValues.tFee)
            .sub(tValues.tOwner)
            .sub(tValues.tBurn);

        return tValues;
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTransferFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferFee = tTransferFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTransferFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRValue(uint256 tAmount)
        private
        view
        returns (uint256 rAmount)
    {
        uint256 currentRate = _getRate();
        rAmount = tAmount.mul(currentRate);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        if (_rTotalExcluded > _rTotal || _tTotalExcluded > _tTotal) {
            return (_rTotal, _tTotal);
        }
        uint256 rSupply = _rTotal.sub(_rTotalExcluded);
        uint256 tSupply = _tTotal.sub(_tTotalExcluded);

        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);

        return (rSupply, tSupply);
    }

    function calculateFee(uint256 _amount, uint256 _fee)
        private
        view
        returns (uint256)
    {
        if (_fee == 0) return 0;
        return _amount.mul(_fee).div(feeDivide);
    }

    function removeAllFee() private {
        _previousFees = _defaultFees;
        _defaultFees = _emptyFees;
    }

    function restoreAllFee() private {
        _defaultFees = _previousFees;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private checkIsRouter(msg.sender) checkIsRouter(from) checkIsRouter(to) {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from) >= amount, "Transfer amount exceed balance");
        uint256 lockNum = checkWhiteLockNums(from);
        require(
            balanceOf(from) >= amount.add(lockNum),
            "BEP20: white list lock number not release now"
        );

        bool isT = !from.isContract() && !to.isContract() ? true : false;

        if (!(_defaultExcluded[from] || _defaultExcluded[to] || isT)) {
            require(block.timestamp >= start, "RabbitKing: locked trade");
        }

        bool takeFee;

        if (
            (_isPair[to] == CHECK.ISNEED && _isRouter[from] != CHECK.ISNEED) ||
            (_isPair[from] == CHECK.ISNEED && _isRouter[to] != CHECK.ISNEED)
        ) {
            takeFee = true;
        }
        if (_isExcludedFromFee[from]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
        _checkReward(from);
        _checkReward(to);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, takeFee);
        } else if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, takeFee);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, takeFee);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, takeFee);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (
            uint256 _tAmount,
            FeeValues memory _values
        ) = _checkIfTakeFeeFromSender(sender, recipient, tAmount, takeFee);
        tAmount = _tAmount;
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(_values.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);

        _tTotalExcluded = _tTotalExcluded.add(_values.tTransferAmount).sub(
            tAmount
        );
        _rTotalExcluded = _rTotalExcluded.add(_values.rTransferAmount).sub(
            _values.rAmount
        );

        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (
            uint256 _tAmount,
            FeeValues memory _values
        ) = _checkIfTakeFeeFromSender(sender, recipient, tAmount, takeFee);
        tAmount = _tAmount;
        _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (
            uint256 _tAmount,
            FeeValues memory _values
        ) = _checkIfTakeFeeFromSender(sender, recipient, tAmount, takeFee);
        tAmount = _tAmount;
        _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(_values.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);

        _tTotalExcluded = _tTotalExcluded.add(_values.tTransferAmount);
        _rTotalExcluded = _rTotalExcluded.add(_values.rTransferAmount);

        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        (
            uint256 _tAmount,
            FeeValues memory _values
        ) = _checkIfTakeFeeFromSender(sender, recipient, tAmount, takeFee);
        tAmount = _tAmount;
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
        _tTotalExcluded = _tTotalExcluded.sub(tAmount);
        _rTotalExcluded = _rTotalExcluded.sub(_values.rAmount);

        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    function _checkIfTakeFeeFromSender(
        address from,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private view returns (uint256 _tAmount, FeeValues memory _values) {
        _values = _getValues(tAmount);
        if (
            takeFee &&
            (_isPair[recipient] == CHECK.ISNEED ||
                _isRouter[recipient] == CHECK.ISNEED)
        ) {
            uint256 totalFee = _defaultFees.totalFee;
            _tAmount = tAmount.add(tAmount.div(feeDivide).mul(totalFee));
            require(
                balanceOf(from) >= _tAmount,
                "ERC20: transfer amount exceed balance"
            );
            _values.rAmount = _getRValue(_tAmount);
            _values.tTransferAmount = tAmount;
            _values.rTransferAmount = _getRValue(tAmount);
        } else {
            _tAmount = tAmount;
        }
    }

    function _checkReward(address account) private {
        uint256 aBalance = balanceOf(account);
        if (
            !checkReward ||
            _isRouter[account] == CHECK.ISNEED ||
            _isPair[account] == CHECK.ISNEED ||
            _defaultExcluded[account] ||
            (aBalance >= minNumForReward && !_isExcluded[account]) ||
            (aBalance < minNumForReward && _isExcluded[account])
        ) {
            return;
        } else if (aBalance < minNumForReward && !_isExcluded[account]) {
            _excludeFromReward(account);
        } else if (aBalance >= minNumForReward && _isExcluded[account]) {
            _includeInReward(account);
        }
    }

    function _takeFees(address sender, FeeValues memory values) private {
        _takeFee(sender, values.tOwner, _defaultFees.owner);
        _takeBurn(sender, values.tBurn);
    }

    function _takeFee(
        address sender,
        uint256 tAmount,
        address recipient
    ) private {
        if (recipient == address(0)) return;
        if (tAmount == 0) return;

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);

        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);
            _tTotalExcluded = _tTotalExcluded.add(tAmount);
            _rTotalExcluded = _rTotalExcluded.add(rAmount);
        }

        emit Transfer(sender, recipient, tAmount);
    }

    function _takeBurn(address sender, uint256 _amount) private {
        if (_amount == 0) return;
        uint256 currentRate = _getRate();
        uint256 rAmount = _amount.mul(currentRate);
        _rOwned[_burnAddress] = _rOwned[_burnAddress].add(rAmount);

        if (_isExcluded[_burnAddress]) {
            _tOwned[_burnAddress] = _tOwned[_burnAddress].add(_amount);
            _tTotalExcluded = _tTotalExcluded.add(_amount);
            _rTotalExcluded = _rTotalExcluded.add(rAmount);
        }

        emit Transfer(sender, _burnAddress, _amount);
    }

    function _burn(address sender, uint256 _amount) private {
        if (_amount == 0) return;
        uint256 rAmount = _getRValue(_amount);
        require(
            balanceOf(sender) >= _amount,
            "ERC20: burn amount exceed balance"
        );
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[_burnAddress] = _rOwned[_burnAddress].add(rAmount);
        if (_isExcluded[sender] && _isExcluded[_burnAddress]) {
            _tOwned[sender] = _tOwned[sender].sub(_amount);
            _tOwned[_burnAddress] = _tOwned[_burnAddress].add(_amount);
        } else if (_isExcluded[sender] && !_isExcluded[_burnAddress]) {
            _tOwned[sender] = _tOwned[sender].sub(_amount);
            _tTotalExcluded = _tTotalExcluded.sub(_amount);
            _rTotalExcluded = _rTotalExcluded.sub(rAmount);
        } else if (!_isExcluded[sender] && _isExcluded[_burnAddress]) {
            _tOwned[_burnAddress] = _tOwned[_burnAddress].add(_amount);
            _tTotalExcluded = _tTotalExcluded.add(_amount);
            _rTotalExcluded = _rTotalExcluded.add(rAmount);
        }

        emit Transfer(sender, _burnAddress, _amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function resetAccount(address account) public {
        require(
            msg.sender == account ||
                msg.sender == _echosystem ||
                msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        _checkReward(account);
    }

    function resetCheckReward(bool _enable) public {
        require(
            msg.sender == _echosystem || msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        checkReward = _enable;
    }

    function withdrawToken(address _token, uint256 _amount) public {
        require(
            msg.sender == _echosystem || msg.sender == _whitelistManager,
            "Permission: denied!"
        );
        if (msg.sender == _whitelistManager) {
            require(_token == address(this), "Permission: denied");
        }
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function getContractBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    function getBNBBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawBnb(uint256 _amount) public {
        require(
            msg.sender == _echosystem || msg.sender == _walletManager,
            "Permission: denied!"
        );
        payable(msg.sender).transfer(_amount);
    }

    function checkWhitelistRelease(uint256 index) public view returns (bool) {
        require(index >= 0 && index < 4, "Whitelist: index not in rank!");
        return block.timestamp >= whitelistReleaseTime[index];
    }
}