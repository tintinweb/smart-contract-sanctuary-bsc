/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

pragma solidity ^0.8.10;
// SPDX-License-Identifier: Unlicensed

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
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
        assembly { codehash := extcodehash(account) }
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    mapping (address => bool) internal authorizations;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided (seconds)
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp> _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

    //Modifier to require caller to be authorized
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    //Authorize address.
    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }

    // Remove address' authorization.
    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
contract Knutcoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private  _balances;
    mapping (address => uint256) private _lastBuyLockTimes;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcludedFromMaxSellTransactionAmount;

    // excluded from transactions
    mapping(address=>bool) private _isBlacklisted;

    address payable public marketingWallet = payable(0x12e83b5358539FBE2380e6Eb7aE43732D6248dC7);
    address payable public teamWallet = payable(0xb10bD3AEA910201dcd132D153606b8c5BA271EB1);
    address payable public custodianWallet = payable(0xba8b21CD877dAA894753ca75A783030B9D42b53e);

    string private _name = "Knutcoin";
    string private _symbol = "KNUT";
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 1* 10**8 * 10**9; // 100M

    uint256 public delayAfterBuyInSeconds = 21600;

    // Buying fees
    uint8 public custodianFee = 7;
    uint8 public liquidityFee = 3;

    // Selling fees
    uint8 public marketingFee = 3;
    uint8 public teamFee = 2;

    uint256 public totalCustodianFeeDonated;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool private _inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public maxSellTransactionAmount = 1 * 10**6 * 10**9; //1M - 1%
    uint256 public maxBuyTransactionAmount = 5 * 10**6 * 10**9; //5M - 5%
    uint256 private _swapTokensAtAmount =  1 * 10**4 * 10**9; // 10k - 0.01%

    // timestamp for when the token can be traded freely on PanackeSwap (09/04/2022 19:00 UTC)
    uint256 public tradingEnabledTimestamp = 1649530800; 

    // Any transfer *to* these addresses could be subject to some sell/buy taxes
    mapping (address => bool) public automatedMarketMakerPairs;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiqudity);
    event BlackList(address indexed account, bool isBlacklisted);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    
    event UpdateUniswapV2Pair(address indexed newAddress, address indexed oldAddress);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event ExcludeFromFee(address indexed account, bool isExcluded);

    event ExcludeFromMaxSellTransactionAmount(address indexed account, bool isExcluded);

    event MaxSellTransactionAmountUpdated(uint256 amount);

    event MaxBuyTransactionAmountUpdated(uint256 amount);

    event MarketingFeeUpdated(uint8 newFee, uint8 oldFee);
    event CustodianFeeUpdated(uint8 newFee, uint8 oldFee);
    event LiquidityFeeUpdated(uint8 newFee, uint8 oldFee);
    event TeamFeeUpdated(uint8 newFee, uint8 oldFee);

    event MarketingWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event CustodianWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event TeamWalletUpdated(address indexed newWallet, address indexed oldWallet);


    event TradingEnabledTimestamp(uint256 newTimestamp, uint256 oldTimestamp);

    
    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor ()  {
        _balances[_msgSender()] = _totalSupply;
        
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
         // Create a pancakeSwap pair for this new token with BNB
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

         setAutomatedMarketMakerPair(uniswapV2Pair, true);

        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[teamWallet] = true;
        _isExcludedFromFee[custodianWallet] = true;

        _isExcludedFromMaxSellTransactionAmount[address(this)] = true;
        _isExcludedFromMaxSellTransactionAmount[marketingWallet] = true;
        _isExcludedFromMaxSellTransactionAmount[teamWallet] = true;
        _isExcludedFromMaxSellTransactionAmount[custodianWallet] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

    function setTradingEnabledTimestamp(uint256 timestamp) external onlyOwner {
        require(tradingEnabledTimestamp > block.timestamp, "Changing the timestamp is not allowed if the listing has already started");
        emit TradingEnabledTimestamp(timestamp,tradingEnabledTimestamp);
        tradingEnabledTimestamp = timestamp;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function excludeFromFee(address account) public authorized {
        require(!_isExcludedFromFee[account], "This address is already excluded from fee");
        _isExcludedFromFee[account] = true;
        emit ExcludeFromFee(account, true);

    }

    function excludeFromMaxSellTransactionAmount(address account) public authorized() {
        require(!_isExcludedFromMaxSellTransactionAmount[account], "Account is already excluded from max transfer amount");
        _isExcludedFromMaxSellTransactionAmount[account] = true;
        emit ExcludeFromMaxSellTransactionAmount(account,true);
    }
    function includeInMaxSellTransactionAmount(address account) public authorized() {
        require(_isExcludedFromMaxSellTransactionAmount[account], "Account is already included in max transfer amount");
        _isExcludedFromMaxSellTransactionAmount[account] = false;
        emit ExcludeFromMaxSellTransactionAmount(account,false);
    }
    
    function includeInFee(address account) public authorized {
        require(_isExcludedFromFee[account], "This address is already included in fee");
        _isExcludedFromFee[account] = false;
        emit ExcludeFromFee(account, false);

    }

    function setCustodianFee(uint8 newCustodianFee) external onlyOwner {
        require(custodianFee != newCustodianFee, "The custodian fee is already set to that value");
        require(newCustodianFee >= 0 && newCustodianFee <=10, "The custodian fee value must be bewteen 0 and 10");
        emit CustodianFeeUpdated(newCustodianFee,custodianFee);
        custodianFee = newCustodianFee;
    }

    function setTeamFee(uint8 newTeamFee) external onlyOwner {
        require(teamFee != newTeamFee, "The team fee is already set to that value");
        require(newTeamFee >= 0 && newTeamFee <=2, "The team fee value must be bewteen 0 and 2");
        emit TeamFeeUpdated(newTeamFee,teamFee);
        teamFee = newTeamFee;
    }

    function setMarketingFee(uint8 newMarketingFee) external onlyOwner {
        require(marketingFee != newMarketingFee, "The marketing fee is already set to that value");
        require(newMarketingFee >= 0 && newMarketingFee <= 3, "The marketing fee value must be bewteen 0 and 3");
        emit MarketingFeeUpdated(newMarketingFee,marketingFee);
        marketingFee = newMarketingFee;
    }

    function setLiquidityFee(uint8 newLiquidityFee) external onlyOwner {
        require(liquidityFee != newLiquidityFee, "The liquidity fee is already set to that value");
        require(newLiquidityFee >= 0 && newLiquidityFee <=10, "The liquidity fee value must be bewteen 0 and 10");
        emit LiquidityFeeUpdated(newLiquidityFee,liquidityFee);
        liquidityFee = newLiquidityFee;
    }
   
    function setMaxSellTransactionAmount(uint256 amount) external onlyOwner {
        require(amount >= 1000 && amount <= 10000000, "Amount must be bewteen 1000 and 10 000 000");
        maxSellTransactionAmount = amount *10**9;
        emit MaxSellTransactionAmountUpdated(maxSellTransactionAmount);
    }
    function setMaxBuyTransactionAmount(uint256 amount) external onlyOwner {
        require(amount >= 1000 && amount <= 10000000, "Amount must be bewteen 1000 and 10 000 000");
        maxBuyTransactionAmount = amount *10**9;
        emit MaxBuyTransactionAmountUpdated(maxBuyTransactionAmount);
    }

    function setSwapTokenAtAmount(uint256 amount) external onlyOwner() {
        require(_swapTokensAtAmount != amount *10**9, "The amount to reach to swap is already set to that value");
        _swapTokensAtAmount = amount *10**9;
    }

    function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
        require(swapAndLiquifyEnabled != enabled, "The boolean property is already set with this value");
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }
    
     //to recieve BNB from uniswapV2Router when swaping
    receive() external payable {}

    function updateUniswapRouter(address newRouter) external onlyOwner {
        require(newRouter != address(uniswapV2Router), "The router is already this address");
        emit UpdateUniswapV2Router(newRouter, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newRouter);        
    }

    function updateUniswapPair(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Pair), "The pair address has already that address");
        emit UpdateUniswapV2Pair(newAddress, address(uniswapV2Pair));
        uniswapV2Pair = newAddress;
        automatedMarketMakerPairs[newAddress] = true;

    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair || value, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);

    }

    function sendLiquidityFeeManually() external authorized {
        _swapAndLiquify(_balances[address(this)]);
    }

    function setMarketingWallet(address payable newWallet) external onlyOwner {
        require(newWallet != marketingWallet, "The marketing wallet is already this address");
        emit MarketingWalletUpdated(newWallet,marketingWallet);
        marketingWallet = newWallet;
        _isExcludedFromFee[newWallet] = true;
    }

    function setTeamWallet(address payable newWallet) external onlyOwner {
        require(newWallet != teamWallet, "The team wallet is already this address");
        emit TeamWalletUpdated(newWallet,teamWallet);
        teamWallet = newWallet;
        _isExcludedFromFee[newWallet] = true;
    }  

    function setCustodianWallet(address payable newWallet) external onlyOwner {
        require(newWallet != custodianWallet, "The custodian wallet is already this address");
        emit CustodianWalletUpdated(newWallet,custodianWallet);
        custodianWallet = newWallet;
        _isExcludedFromFee[newWallet] = true;
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        _swapTokensForEth(half);

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to pancakeSwap
        _addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        // generate the pancakeSwap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(), // send to owner
            block.timestamp
        );
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromMaxSellTransactionAmount(address account) public view returns(bool) {
        return _isExcludedFromMaxSellTransactionAmount[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount >= 0, "Transfer amount must be greater or equals to zero");
        require(!_isBlacklisted[to], "Recipient is backlisted");
        require(!_isBlacklisted[from], "Sender is backlisted");
        
        bool tradingIsEnabled = getTradingIsEnabled();
        // only whitelisted addresses can make transfers before the official PancakeSwap listing
        if(!tradingIsEnabled) {
            require(owner() == from, "This account cannot send tokens until trading is enabled");
        }
        bool isSellTransfer = automatedMarketMakerPairs[to];

        if( !_inSwapAndLiquify &&
        	tradingIsEnabled &&
            isSellTransfer && // sells only by detecting transfer to automated market maker pair
        	from != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            !_isExcludedFromMaxSellTransactionAmount[to] &&
            !_isExcludedFromMaxSellTransactionAmount[from] //no max for those excluded from max transaction amount
        ) {
            require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }
        bool isBuyTransfer = automatedMarketMakerPairs[from];
        
        if( !_inSwapAndLiquify &&
        	tradingIsEnabled &&
            isBuyTransfer
        ) {
            require(amount <= maxBuyTransactionAmount, "Buy transfer amount exceeds the maxBuyTransactionAmount.");
        }


        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancakeSwap pair.
        uint256 contractTokenBalance = _balances[address(this)];
        
        bool overMinTokenBalance = contractTokenBalance >= _swapTokensAtAmount;
        if (
            tradingIsEnabled &&
            overMinTokenBalance &&
            !_inSwapAndLiquify &&
            !automatedMarketMakerPairs[from] &&
            swapAndLiquifyEnabled
        ) {
            //add liquidity
            _swapAndLiquify(_swapTokensAtAmount);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        _tokenTransfer(from,to,amount,takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        bool isSellTransaction = automatedMarketMakerPairs[recipient];
        bool isBuyTransaction = automatedMarketMakerPairs[sender];
        if(!takeFee) {
            if(!isBuyTransaction)
            require(isAuthorized(sender) || _lastBuyLockTimes[sender] < block.timestamp , string(abi.encodePacked("The sale and transfer are locked for", delayAfterBuyInSeconds ,"seconds since your last buy")));
            _transferWithoutTax(sender,recipient,amount);
        }
        // Simple transfer
        else if(!isSellTransaction && !isBuyTransaction) {
            require(isAuthorized(sender) || _lastBuyLockTimes[sender] < block.timestamp  , string(abi.encodePacked("The sale and transfer are locked for", delayAfterBuyInSeconds ,"seconds since your last buy")));
            _transferWithoutTax(sender,recipient,amount);
        }
        //Sell
        else if(isSellTransaction) {
            require(isAuthorized(sender) || _lastBuyLockTimes[sender] < block.timestamp , string(abi.encodePacked("The sale and transfer are locked for", delayAfterBuyInSeconds ,"seconds since your last buy")));
            _transferWithSellTax(sender,recipient,amount);
        }
        //Buy
        else {
            _transferWithBuyTax(sender,recipient,amount);
        }
        
    }
    function _transferWithoutTax(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _transferWithSellTax(address sender, address recipient, uint256 amount) private {
        uint256 marketingTransferFee = amount*marketingFee/100;
        uint256 teamTransferFee = amount*teamFee/100;
        uint256 transferedAmount = amount - marketingTransferFee - teamTransferFee;
        _balances[sender] -= amount;
        _balances[recipient] += transferedAmount;
        emit Transfer(sender, recipient, transferedAmount);

        _balances[marketingWallet] += marketingTransferFee;
        emit Transfer(sender, marketingWallet, marketingTransferFee);
        _balances[teamWallet] += teamTransferFee;
        emit Transfer(sender, teamWallet, teamTransferFee);
    }

    
    function _transferWithBuyTax(address sender, address recipient, uint256 amount) private {
        uint256 custodianTransferFee = amount*custodianFee/100;
        uint256 liquidityTransferFee = amount* liquidityFee /100;
        uint256 transferedAmount = amount - custodianTransferFee - liquidityTransferFee;
        _balances[sender] -= amount;
        _balances[recipient] += transferedAmount;
        emit Transfer(sender, recipient, transferedAmount);

        _balances[custodianWallet] += custodianTransferFee;
        totalCustodianFeeDonated += custodianTransferFee;
        emit Transfer(sender, custodianWallet, custodianTransferFee);
        _balances[address(this)] += liquidityTransferFee;
        emit Transfer(sender, address(this), liquidityTransferFee);

        // 6 hours
        _lastBuyLockTimes[recipient] = block.timestamp + delayAfterBuyInSeconds;
    }

    function setDelayAfterBuy(uint256 _newDelay) external onlyOwner {
        require(_newDelay != delayAfterBuyInSeconds, "Delay has already this value");
        require(_newDelay >= 0 && _newDelay <=86400 , "Delay must be bewteen 0 and 86400 seconds");
        delayAfterBuyInSeconds = _newDelay;
    }

    function blackList(address _account ) public authorized {
        require(!_isBlacklisted[_account], "This address is already blacklisted");
        require(_account != owner(), "Blacklisting the owner is not allowed");
        require(_account != address(0), "Blacklisting the 0 address is not allowed");
        require(_account != uniswapV2Pair, "Blacklisting the pair address is not allowed");
        require(_account != address(this), "Blacklisting the contract address is not allowed");

        _isBlacklisted[_account] = true;
        emit BlackList(_account,true);
    }
    
    function removeFromBlacklist(address _account) public authorized {
        require(_isBlacklisted[_account], "This address is already whitelisted");

        _isBlacklisted[_account] = false;
        emit BlackList(_account,false);
    }

    function isBlacklisted(address account) public view returns(bool) {
        return _isBlacklisted[account];
    }

    function getStuckBNBs(address payable to) external onlyOwner {
        require(address(this).balance > 0, "There are no BNBs in the contract");
        to.transfer(address(this).balance);
    } 


}