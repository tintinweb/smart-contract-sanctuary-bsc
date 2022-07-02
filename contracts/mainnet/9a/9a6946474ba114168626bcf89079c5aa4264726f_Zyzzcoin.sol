/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

pragma solidity ^0.6.12;

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
    function _msgSender() internal view virtual returns (address payable) {
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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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


contract Zyzzcoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 150000 * 10 ** 18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "Zyzzcoin";
    string private _symbol = "ZYZZ";
    uint8 private _decimals = 18;
    
    uint256 public _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 7;
    uint256 private _previousLiquidityFee = _liquidityFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public _maxTxAmount = 150000 * 10 ** 18;
    uint256 private numTokensSellToAddToLiquidity = 150000 * 10 ** 18;
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    //zyzzcoin logic:

    uint public totalRedeemed = 0;
    uint public keysUsed = 0;
	uint256 public zyzzPerRedeem = 200;

    mapping (bytes32 => bool) keys;

    constructor () public {
        
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);

        keys[0x469824297162a67fb0d1d408fe12dfeb0e28a2283ae68a3d9a5d67ca5937978c] = true;
        keys[0x405be546e45a4e9e08d15d8b1409bfd021cbf9c77273ba83f7524c381fd44849] = true;
        keys[0x2af766023ead250afaf15c895539f1721ae5b75fd65c6c1e1388f84c6d36e56e] = true;
        keys[0xe1771495ee04f5518a76e694a550b28eef434aaedc93708febde0d2bc7a6740a] = true;
        keys[0x9b3ff34c094d83db941316725e440749b89f7b3833e6be21705b912213ae83d9] = true;
        keys[0xca836f51fc29f4c5a50d60f60daadbeb5edbaf7b188a7fb36fe4bacd7cccf69d] = true;
        keys[0x6b5353531e4ba88c112c59e7fe82593d9c4de5ab37aafc5e1c23457672d78212] = true;
        keys[0xabf12c450084c35ce2e716dcc8fd677b48b1537d1b6eba5b81512e0428885684] = true;
        keys[0x84849d0e4423ff8576509ff7d6589aace2d4990641550e0e6398b878b132db21] = true;
        keys[0x4f8e69353b38f0ba68a834cd1cfc520872cecd35683705b2d486cca5ba9524b2] = true;
        keys[0xadeaa452afd05db113398bfe4a67fa9db8d435ec3a7b1f7f28ddc65547cda757] = true;
        keys[0xc3796c0cfabc46f21ca619f9992ee9eee48b053e56dfe52355815bfb53ad3f60] = true;
        keys[0xe495036b574232a9df81ef6d221129122c497ed09c2bba93b2e273ca83444f84] = true;
        keys[0x7a0f205f484d7a39de433bbd6ed0faebdb39a861603c2300aaa0886bbdacaf7a] = true;
        keys[0x7071aacc76a2032d14e33c287d17ee40ee7da4e7574d490b33867c54c42fe216] = true;
        keys[0xdd170b103adc33282f65fbf5797673eaaff71036bb09bc96726766dff67c2d65] = true;
        keys[0x34a4fac3a312e6bfb16632e2690071c0ec12e9bb7e30afc9d4bfadc9b35c5711] = true;
        keys[0x4bbbe64a632173afeca9a789adddbb7f00395b5cfd1ebd52493589433795af6f] = true;
        keys[0x969ef4f6c3e0c6cebd37f0466f334da6e0d8452b949e13056abaae69af0d8a73] = true;
        keys[0x6c80bde25e4bf82a74d229992dd15000b9f61d8374591c3a0e4b4f9591a0cc52] = true;
        keys[0x758f5dfe070536182e3caed70505713fc7d0c20186c5f9372d3c03d6469d5a8c] = true;
        keys[0x8ef2d4a2e0a7ebd706712bf35c21c4ac9db3ccb28eb0f56f333aac46527312b9] = true;
        keys[0x92284fb7231763dd93133305345a7f76fbde2a3f0132cda32d09ed9619ca4a47] = true;
        keys[0x3c746c44eb3d1951075d3292f169612d23e6dd8ec9e7ee83407dab372751d80f] = true;
        keys[0xe8e17f54c3b1b2377881042ff78c53bed0ec46c76a08b9893ebb192658d8e323] = true;
        keys[0xf74af5b2331bb03ffac2a5dd17a163d4a4e324d398a7e7574704d9b9df43a964] = true;
        keys[0x60d58dee72086f8be1991dbdfb1f406168ea7d35e1bcd32f2b286e6497b53e06] = true;
        keys[0x8ba78f9fdc8d408186c51695f5227d71b202a0632fd251adf5f03c630963ed18] = true;
        keys[0x9272c3ae3284b9fffe5166f8a648ad5b265ef0e112313a27111f8132afa6c12d] = true;
        keys[0x95e283a8220b962579890308904f11562a59f0efe63bc20901eb3b0845955000] = true;
        keys[0x0d9416d2dac226ec359c4e191110caaa82a2fa14c9bce977f6a83be31f355dfa] = true;
        keys[0x3c43c994e2ac3a38753fa67530ffc9a7f9ce5788214d75d073f2b29fafda013d] = true;
        keys[0xf70f512f1e1866dd920568922babaa0e5685a34a634e28873564f68378299384] = true;
        keys[0x9ccfbdfe7800934c46e19a49d3ca6c3e4979f0b5a11ecefe8cb501a18f89a48a] = true;
        keys[0xda349a7f1400ec922591d3cc9a80650e266b4a4fd1965ed9ad688daec6f85067] = true;
        keys[0xa9e354d278b3bd0f3ea2fbc94942666ba7fb7a6f99b0fe7a1265532a7792e1b3] = true;
        keys[0xb4f9c81b53f355523d9bba57daeb6f786882b1ead4ece2137544a3502c5e506b] = true;
        keys[0x592fa11cde480bf5a0c9c5abf7c6a41cfe7f279539da7a7e2a74baaff56b96e2] = true;
        keys[0x7c395e85a6ea06a10d7c7cef0ae7fef3c703c74f4691a0d049bdd820ef1c2c8c] = true;
        keys[0xfa848d619e244dfab900d855b92f9b4c06f32ee71aee660b7bac8c68b1cd286f] = true;
        keys[0x21818d7831a6f026c0e8cd5e0f1711f437f05487af78a64ecc9c921362244ebd] = true;
        keys[0xc7828f2e14779c1e0597b3d780472581796079ff643e9140975aa117bbde0eeb] = true;
        keys[0xd41921c9125e2cd46ff2953d0023bc2d70819a9581dadf4330e35b362af56c7f] = true;
        keys[0xe8e4b460a73f975eba3d6db246c79490310da8a34d28b86e605d14bd486190f6] = true;
        keys[0xfd7e5a5a4eb5c76d0dae3df8235b073559c1d722dc47d3b350b1cee1457284f7] = true;
        keys[0x8a9b3e318ddc1235cbaeb67fa99ed2207b85622f4aabf747b665ae5ce004ac31] = true;
        keys[0xb1846937a11e630927ee0b502876d7216720d02b5c8ad2f466e13321cb244efe] = true;
        keys[0x6b987a0b64a1704df7d2aa36b2a3a7ab9c76f733db926726268ea40125990f16] = true;
        keys[0x9e7db334cf5f3069d625943506a0c70c67561deec1156083cc01d23771a6ae43] = true;
        keys[0xb059b35de0f8adefbf9cda29fb54363f1eb572f11220c52c2b8c3dd5a0e1e2f9] = true;
        keys[0x5376ab2b5b47bf8030734492c62f85eaff2312d2ece1334d498643a5a3c42932] = true;
        keys[0xf776b2fbde0108521199c6abc861a6310d2165c7293916ef511cea89883a3107] = true;
        keys[0x6f9c7e6c5aceb44a9cb9fd403df2ba8f5e8ebd73cd3fbcd9ab1f286f3200ddd1] = true;
        keys[0x203fb950e1b51e8eb58c8ae410c26649735c3df9a724eae0108c9b6f5b20639b] = true;
        keys[0x6e2adc5b2b1c5042c6d49e7c83f76e4b34ff23872c4b8086de9b148120f2a862] = true;
        keys[0xdb075e342d63398917041e4141a140099ecf9a1aca787f3c5e41eb2b02df42e7] = true;
        keys[0x029bc60da41dd0e406886aa881eef862c3884285acfaca3d9dc3851276af088f] = true;
        keys[0x71f47d525c3bc580aea835e89e2020c1f0611442063ab609cc79ad3442655653] = true;
        keys[0x893040c5b8eed322892de59524b135978df193d36383473e9eaa034b77b1ad12] = true;
        keys[0x015e98c269d34f37d30af1282a103b08d5932c038036fe818914f15ead970771] = true;
        keys[0x8594d8792d8500324ef55fb2938c895ba29c0317d6b2e0acfbeb9a741f068bc4] = true;
        keys[0x1bdfef1d551263ec6d9a258219db3d12ff93db707b1884a541f08d8ba9dc998a] = true;
        keys[0x401b885daf8b09d1e57890e84be14d1c8d74e30a982573f9a4fb7c90da2da85f] = true;
        keys[0xc5584f212315225110c1da317189955e92d2f20173ffed184168085d2a263f5e] = true;
        keys[0x9f478ec0527d924badaf445431d25c76a1449a64d08494e0b1b24c3967800c0d] = true;
        keys[0x7d5c79d8e3f53583c76f60921269b5450f1fb164b72eedff2bf22060bf3db763] = true;
        keys[0x6717cbb6ba826d9e307ff0f9627842a3f1686a7364b929914812b200dc3ecc91] = true;
        keys[0x1d196b6bcba7b42c34119b3044a7afc7c7e13548a2f8250f32c74ce21542b584] = true;
        keys[0x4f0740e3b8d682008b9c683b552a33e54352c8839bfc328a0809c3f3f2ca3462] = true;
        keys[0xd30838d5f87af7a605524466724b55f96e2275180dbb446f41665413105638b7] = true;
        keys[0xe9f6e447dc8a95e1c7e263b4b6e19465836c52f9e863448c03b2167c99b94de4] = true;
        keys[0x3bee5076474c628a68f2901e0765cd5014fb133dd430163fa12aa135d0a4093d] = true;
        keys[0x066b22e688cdc9f7d37c25b8fc3bbfe05cdb0041b41231bddcc3d1e3a978deef] = true;
        keys[0x67de0ce9fa122c616bb3a49edd4dfb3b06334b5a1f4baace2ee126aee751fb20] = true;
        keys[0xef706b6698481aa08fc2d81d71e313fadffacb2220480f6f55829193248fbcc2] = true;
        keys[0x2fcb593676593f586c883c00db3166e4c9742273824b6dfae0f184a72d6bbd02] = true;
        keys[0xf0873dae06b4b7d6a20bb3d1d27f2dda7e194b45d0ea5104cc95c5aed161d14f] = true;
        keys[0x8db7452020cc644560c6543c9b50556867aac614f026c53ed96ffb56c2b90d27] = true;
        keys[0x2af599521de602413cd56e620a7f0f2e8a947f95456c78b91714372a553670ca] = true;
        keys[0x5c618d15809d8122a39309d2b653e79834c71af4996d3453d6fff7500d249b54] = true;
        keys[0x75c4f9c6df70ef16b9615e6e2c5d71135dbc0eb3c1344a92cc4be50cf92923b8] = true;
        keys[0x4c78ddf85f73f608774f588d8b551c20fe3622fb474962e26f43f456f58d8707] = true;
        keys[0x1c15fcbb30391945f07dc1ae06491533e5e69a36a54607f9b5cd7e8759ef52ac] = true;
        keys[0x467a96eb7e46b1f940fab876f6a2f191b0c0f5499f8d67cef240bedad8ceb75e] = true;
        keys[0xcc050d51a00061b987865da059adb56313e6beb1f9353d8721861f82cdda2ef2] = true;
        keys[0x7fd1519f722e814ea0a2c9446cf07eaf5a24132bfcbb127b39177bd11c3c3acf] = true;
        keys[0x5c99a35d7d6f68e7bb17d6f0d5c98b8711ecf63b78514431176570cbb166572c] = true;
        keys[0x08c684cdf5ba435e4a20fec7cf85c862d25cec595cecd0a9451066b4baecac2f] = true;
        keys[0xfee0d32b2ea8c2cb21173292a7e46f47be8f9421509e95e3a6fdbf8d9d5c4a1a] = true;
        keys[0x9e7b0c36705fe990442420316e92116e873c8af635bf63e024c98056b733ce32] = true;
        keys[0x564576d7c727bb4c29b4b2d3e9ef7cc81762f196c1e619f373a83ab2b81885a8] = true;
        keys[0xa571c9e184b53d19a177f92ffcb7f7e167328bdb1c8286f3219b7cbff7525717] = true;
        keys[0x04a0e563d9d650c09d8f07a93555713994d7eacf45228e30f9eaea64861ab7fb] = true;
        keys[0x108318aa345e3bbd28da90625f20649322701aec1058a17f90b21f200288999c] = true;
        keys[0x73218577a58717d13fa89d2231ced0bae682e6f708fe8caa0a0d94fed876356d] = true;
        keys[0xa0bb8ded835eef7f8e41d06571dbeda66ebc43c0aab7d46087d1dcee75cf8fa6] = true;
        keys[0x61d40d4b4eced7b3b1213c39bd9f2785a499915762857908fc73104a90ce288f] = true;
        keys[0x5136e2d409294428cd4971cb53d2bba4b21a0dbe074c5f442077f6f410ecb6d7] = true;
        keys[0x766fd8df723e6b98124787333199411282225bb510980a147069a6977e25cfc5] = true;
        keys[0xa8e0b56868eada78a924f5819f132e19bafd5534e2d8dfbd749be45f6c8305bf] = true;
        keys[0xc35618190e5f8c70a872728a07da7505702f93265dbabd608a0b6dc3b61bf145] = true;
        keys[0x18ff9f9e039b5427fad420bc77c33708e4bf96dc2a94975f335396407c32969d] = true;
        keys[0x540c78204b74c09e64713dff7b6f1d2b1ed917fe51dc77b186efb992f76fe79d] = true;
        keys[0x332098426cad4cb220ce129776e0a6069f4b02150b13ff59851a16007b81c97a] = true;
        keys[0x9211fe280c3694282d3b17b89924b07bf4c25461faac7bef1b66c7783a0b7a5a] = true;
        keys[0x6436b2ffee38818abb7f69bf2b443198d199b68a0f5a6fdbacbeb637e2ba0e93] = true;
        keys[0x7fe2e42ed47be62c1c8c00a8e7c1d4e196ac6a70605bc7b27a6a35105420f086] = true;
        keys[0xe8bacb47c6119ab831983cbb7be17e87417d5a250042703c92bd2616b5d0095b] = true;
        keys[0x9b720dd7bf3ff199bf1721bebcfc2ba5b9809679dd4bfd225ba7dbddc8338f32] = true;
        keys[0xf748c820c32f7354b837ef25f11d00b7ce07500ac2ba02fd523fa7f0c283c9b7] = true;
        keys[0x49b50956b61a9530a4f963ba833d64569539903bfb8966e887c6ab27abc79a5d] = true;
        keys[0xb8a13b28ca7adc40a35935cec11a8929bc2291226a1451ebc2291af01363cfe6] = true;
        keys[0x08771844030499373b52aa70db96e134e7e0eed583edbdec087442fc1f5e80f9] = true;
        keys[0x9bfa119ece0b85014276353c5e85ba6c0f8c8648db2e7b44b40a89870a8550be] = true;
        keys[0x95e33dcb9c205ed5ec41f24e39b7669c9104435b8b30fc731eb5cb6f1aabdc18] = true;
        keys[0xdb97507525823402ae178e5d75980a4cd323e1432913eb4914eeae92c2a1aa3e] = true;
        keys[0x9f5989b39d36896945391cdf64618b6df8d4e60776194e6b4c34980b4d094ba4] = true;
        keys[0x0304dcd30b6fcd0ed0c53e89efdec207e8ea54dec56cd026ab2269553a1f03e6] = true;
        keys[0x225c8aada3cc77c71bff595b2f2b0a56b7081a099dd6ce4e58206c6c41eb78eb] = true;
        keys[0xf250a96046a440e07c0281d06dee0796f04fecd13ea335395397bdd976cc6958] = true;
        keys[0x684399eb2c78a9a3455b944f35799cf490af23cb33ce07e0b892c9414f4898e3] = true;
        keys[0xe521d1717c13d13764bda25f9c4ada9bc324b518bae4561d43e9d306354e4cc1] = true;
        keys[0x69cb62cc90722c2d43cb391b2ace226b787917cc74e6f8d1802b493706b6fc92] = true;
        keys[0xa5b2abb9e8bc09dfeff6824554c7631247bf977226be68da07fbb0a576056097] = true;
        keys[0x5229db72471152ecd1e546d6088fb7621e073c95c559dc6ff6a0d4733ada4fa0] = true;
        keys[0x25cda41685643b1b67c3ba2cbf10f0ade70b4af2577b8173ed88df59192d25a1] = true;
        keys[0x6176ef24dcb01fc4a6377800dab321ea8a1aeaa2010387e6e335c6cce43b8b4f] = true;
        keys[0x90ff70325c07db5eac648923571c6c2bc9f625479adf00e2501c86a86f093e99] = true;
        keys[0xe97ba309bb2bdbd883e5bf847c7f8b215977abea2aee57adee7916832b136a28] = true;
        keys[0x81cc3df5ee371060bd34d32fd18d5b9f7483716fa4702d154fd383da0c80104b] = true;
        keys[0x328f9471e1e8100bc200abdb5a2db8f3b809a31daa9ffab973dfdaf2fd40553a] = true;
        keys[0x231e8f470e7737d1a4cf6c2471214444cf9179011a1bb3e0e9fe03911ac4fe27] = true;
        keys[0x60998de684e3f7c3dbd37ff95f6510ba517291f9fc7360d58538819a43a48e48] = true;
        keys[0x86436a13a73130119d0836e94a6a1152a64e777c9ba7a8c43789170343bdd94c] = true;
        keys[0xa02998a1851259a4b33ebec8a93063730bfe53221b239cdeae0bfa9e2e0f97c4] = true;
        keys[0x0c0859eb6d94e1c262dcd789c9376fc2526b0187ed7b2c8489e8bb4fbb49e34c] = true;
        keys[0xcc781a402fffbc1411c587ee215bebc47cbbb46fa78e26f67826914901d8622e] = true;
        keys[0x9df492bc2920d8451adcaf44acef715493a05801965c5d3f7421735bd4a2347d] = true;
        keys[0x5ca9b87b3920ff19d203b32d220bbd748bbcebbdbb8abfec4c26dec8876d48ff] = true;
        keys[0xc45118df37b4eefc23613557d51038112f68de408a5647919f29d5fb488b4866] = true;
        keys[0xdcdb469764693ccb6fbb62afb28bf81fef90d44f8a76dcec35b30c16d291a99b] = true;
        keys[0x4681dc79d10f131a5527cee1ed5758600816946bdd9db22895108749239808c4] = true;
        keys[0x26ffe82f89fcf7c7e7f1d3e2e67ecc04591ae7049a7e6c1aa7dc07b14a289445] = true;
        keys[0x865a639b37d3dc256e4ae96d5dedfc7365b28192cf338f5a29d2db22f87771cf] = true;
        keys[0x5d90a9a72ce95f0fee925849960b339ae7cb1641b4d4800f31baab584d453764] = true;
        keys[0x3484f241b37917bd9b0a77fecb003534e6e7b32cf7500b974e6463053414d423] = true;
        keys[0x0157dfcd7050bc98bdc84defa9afe24efcbb4bf52f251ee4a6b7294aadcc0c02] = true;
        keys[0x37ade30b3b5c5920d16cd910ab31ef4c0057599f21b600d7ea44f45502149fbe] = true;
        keys[0x6f83408e48676006ba35e54e23c701238bbfaa8a847c46c6792fc1ba787c972f] = true;
        keys[0x539ac46f4f072667e3485922a07b284f1f0038abd9eefc43d74266d75d2377a4] = true;
        keys[0x9ca4fecef17b9f32c585fe028da082f9efbff6655d72c5bc1862453d21e9bb3e] = true;
        keys[0x8fcbed59a1318b01be2d4106c2ae44ce23170f717ff491d1b0e7b89c10ad6bdd] = true;
        keys[0x0a8814d4e291e16ab4541ac6f15c64e33afcf3d156e2b60d672e900c8960279c] = true;
        keys[0x5a0ae7e5a3eb25c65e4753216381386a94f3aae0691739986c540a056b6d465f] = true;
        keys[0xde3a60dde8b86ed267a9fb65d9615614bfa9c69ffe690d47132d0732d2ac75fd] = true;
        keys[0x629800e62deb4b49b9efcec2e0b00a7a70a9ebe083adbd924f4aa2a2bcfc1b70] = true;
        keys[0x695830e8bf85f8603f2dd35ee19fed1db2ac8b61a628d45695e8971aa3e80ed5] = true;
        keys[0x4a8b0660dc1105977582f7d3c05ba4fc5f27b95813a2c3c05f8b0dacfcb4f7b3] = true;
        keys[0x246b76409914837b222bb6a6eaba0950e24de738060f6ebfe7ea3861200bc947] = true;
        keys[0xef38e386f5b86e88e96e97a24162be42d0ed949b7330485554116add70c6ca0e] = true;
        keys[0x39000bd9d3caff8d84f86f0f2fd00ccfd969de89b52860b9e116cbdfd002e879] = true;
        keys[0xeeb5f01ce24984b34ca8153c5dbad3e5f46bf11eba4fb80bc75bd245388aea01] = true;
        keys[0x33b67bf5eb3c884f8bdc729f3a3e3a675d35c3315ffb10e1de1cc1657a1bc22f] = true;
        keys[0xdeaa7b0c982a8f331640f1a87d9d1324dce13aabc53b6b6de2f37f89d76b5e61] = true;
        keys[0x4f6ee8872957dbc3dfa1c4c4976bd00b9a66c2b4d9a8570f772b713e167370f0] = true;
        keys[0x2bc36a7f5560c06226d1f3b27a27beb541e25bdab8466fe0bdb2e81c9f1cb0d6] = true;
        keys[0xb6b92df98c388331a770815e6cb725ebcbe252399c34ab2ec0196a579c84960c] = true;
        keys[0x5accc34bdbf5cd7b639fc18e2e826607e32a8e98a8d6348eab5de1d3dc950d0f] = true;
        keys[0xb68860c201d57cd64bade7a21b0d9a1bfbbde23b19526e12abb6d34c14afc70d] = true;
        keys[0x543cb288df72c8724ec698874c865552ddfc8b98c9b937fe186c2515ebce8337] = true;
        keys[0x3967e7726aeb1854ed5bbcc9da90d83d1c0b872d29a5453a52a3b7aca387116f] = true;
        keys[0xc2a3b64e67b8ec682fdb509cb599b9ecf701709eb649a14384217a04bfda5d82] = true;
        keys[0x0daaf3702b12e994cdb202b66eba4ef48dad22acd1ab72ec7c51d64bbdf6a2a7] = true;
        keys[0x767964b4af8fe79733717d707e4fa930303360a9db3ec877bffbea863a891467] = true;
        keys[0x8b760970edd45093a1e4f4e5ed50759d2d6f3feae90dd5e15f75e61dd32670a7] = true;
        keys[0x4fbe50fc2155c16bb5e2e025935a1cb8a018c8f1882d85eb36776a93938ec882] = true;
        keys[0x7e0a1b2678c74ca384070c83313e7922cb8c2a88d3cb7402f2e14b8ef1756c57] = true;
        keys[0x67b43385503dd36b9ac37251332ae00c42525267595b28af89f55753f1307af5] = true;
        keys[0x0c854e9a2b1e1810912448fccc18cc0d58bf14387624a9cb20910991ed841645] = true;
        keys[0xcef27a3f65943ffe309a05a5ba62343cbd7b130171df6b3a94406fcc6585eba4] = true;
        keys[0x821d61ac518ba71aed8cdff24c7e206ea5f2cdd9d0d7bddcc633d80f833f258a] = true;
        keys[0x61a921985aa5ec6a78c189ab2f9993315cba92c0af875d28c5386d6acccacc56] = true;
        keys[0xafbbbb3c08cafb5adb24e2bddce03d6774cb43976b8d922c7972ba0befe97d2d] = true;
        keys[0x313cae33dd64bb21485fcf055910ef84a574355878cfc8a23fd92a839cea19e9] = true;
        keys[0xf1602ee81b088527b16210aa5489442c59a70cb20bae69fcffefd40d92993385] = true;
        keys[0xd2ccbf209ccb899a2df0436a95311c3286290e31e9b088355358b304a0f6b2ab] = true;
        keys[0x61b61ca1228460b7508e6b490bd3ba2f199acfb58b04177766b1f06ff9d34858] = true;
        keys[0xcb9d167725948b93eccbe1a93024e1409d1458889b525fbfd96816b19c1da4e8] = true;
        keys[0xb83ac58a9c6c8e23f3ad17254a6c91eed2c2f2b503d8e413d6c2e129ba13a2be] = true;
        keys[0x31ecb23e3338389ebec4d18db09b3046791fdb1593d820356872cb1752bc40de] = true;
        keys[0xbffd4b6e19bd040be5e08831d0d69c7e5595cf667a7131b316c8dfc560fa15c4] = true;
        keys[0xfa386e92004514b4f2caa25ef01575f9ebb550ff30ed2cdcab5417d011ebba13] = true;
        keys[0x7cbed5a1025f92c98af9188481b71cd44b4d1ab94fe4f22689853eba8368e68e] = true;
        keys[0x8bcedc51a58d38b854861f4ab52373d24dc67b76dcc7d72ef50d85b36b0722ce] = true;
        keys[0xba03aa55bf5a7b32db998d4f95adfe552ef8627405c8e291779c161c4913b5f4] = true;
        keys[0xabbcfa3a04bed4a19390db36d14b86dec754370d2b91aaee446231e2389b6ab6] = true;
        keys[0x4c501222ba54ede737508e7bd16a224f3c28eb6831ec0274f9363c460fa16586] = true;
        keys[0x2f308cac3ad8c11b0ed460c8230ded3379616961e27b9a4f51d16c8985833574] = true;
        keys[0x17f49a9e69bfc6c9f9ae7cb3a9af78e6e239368d22967a59a57a3986e77e7e09] = true;
        keys[0xc90016cf4dcf497d94970a28e0f25eab8275672e529bf888fa8fae39f4f7312b] = true;
        keys[0x24df44877092f999cb9582d89ee51a444037299cbc3a0a3baa9c7a0881f5c8d2] = true;
        keys[0x3aa047e48ebc89e64e3d402adc60c7a11c437c1b9973ea4d8efc4ca80d533a1b] = true;
        keys[0x4e78e4473d7ef18397e9000cc39f53ab596bd9937846fad80f029751b795a6f4] = true;
        keys[0x18871ea2ad73b5e2cfbe0d22c43eb91013ef7e278bb824bd4110abf6fc76cfe4] = true;
        keys[0x37533e6839d2da867103f92f056c1a1b10da5d890acb6288c619a5520acea477] = true;
        keys[0x845780974cc6f20c2f3aa51f47c2362ec6155a6334551fc19e6f96e99dca9479] = true;
        keys[0xbe9ec86923944d06d791d4b802872a3a7eb22f32e6fd890e344afefcbfa04662] = true;
        keys[0x2b2a8e8964057c86542bcaf93f72aa74b82437c9ece19af451e95adeb0197c0e] = true;
        keys[0xefba4014688578f2090899fdbc0ea85ff08ea26f1e9993d602b7c1604e442284] = true;
        keys[0x572ec862f64bc48abb1e40baae64b506e4542166e985b39f0000b0ea162d5c74] = true;
        keys[0x2fef677f2a26f13242e21e1c8e47cfaa7a3386216ffd1007600740dc2d66b712] = true;
        keys[0x5b563d0e5040238cd9cac1326b189d5ab97d2ac83da4e46e1223f02ef4e28b21] = true;
        keys[0x115848115af9fceab9aa8cec5a4ae75fc1412c8e83d5f51449757bb9d1c51a5b] = true;
        keys[0x4f6ecf309eed549956bd3454da4fcc94300e828744f61a755aed1705a07849d0] = true;
        keys[0x711055858aee5864db3658a0e7d9c974573ade1402349ad84e1e98423c4d4c08] = true;
        keys[0x65694ca1209d3e6a49033ceb7e0acc267d7e665d17b6152a028d7c9bea495192] = true;
        keys[0xcaeb83dc7d673155a7655c5a24bf6cb1e173c9ef89e05f2ad070c46b8bffda30] = true;
        keys[0x7a5dce51d11e3b44796ef2aa104ca37e2f5c60ba0b646981199592168ab4251d] = true;
        keys[0xa02eb745b4f74f8199a761956019e40d5e00f6e18fc7430a5f8805f4cb5910b8] = true;
        keys[0x59efc15a045bdc6cf1ac062a43b406c1ece5b64049e39e85058662651fc235f7] = true;
        keys[0xb53dee37d1eab8f167a8acda5d71068fb514f74c7606de4c5138dc865e760de9] = true;
        keys[0x14ccbcab6f080067e68bd1cf2ecd672af26fdc07516ffe5501e97a8f8ac6bc93] = true;
        keys[0x4a963835fef1b01663c7cef6f0c65eaba0df3be89f8e748e8e4d0385fc2040c7] = true;
        keys[0x0c1a43545cb38881d0e41dc9a612b3081d39a95aea7e7ab4e2b040ea6b6a45a6] = true;
        keys[0xb7a3238e8708867448ae073ffa3338eb0a14c3b30910bdf09076724794a67af9] = true;
        keys[0x5c72ed98a106d92ace3d9abd2c88e70df5de92072920b8316beaf0df63c518f0] = true;
        keys[0x36b70b686d8b6c0e124ecc370f13fc77db0bc5ca7de3cfcb13fc1350d36e9c59] = true;
        keys[0xc53cbb28df8d2671aa5481374f371860b2e3b62e386c14885830eec6c5f9db17] = true;
        keys[0xc3886e7ca752d5f666e81f1283a85c4d2037f5dc9235a95565a678f0a171674e] = true;
        keys[0xcfca142c7e8b5e2eb2fa91372f76183445435373893cc9fb449b360a8a469e1d] = true;
        keys[0xb83fed340b576be6c991b9dfcbe8f971219ee5d2a0152e5af00d6ba89d1d9b91] = true;
        keys[0x25df9ee7b939f970c77bcd4461cac943203dd446ec83b41e4e33c30bc2185d5a] = true;
        keys[0xc62dc477e88bed3cba8c2825ed180e9c44c944e94dbeae05c479c3a85c5d3978] = true;
        keys[0x8b9ace7840ea8328e21d4ff845d34c73538fcb2ceabc1e8164f3d5f22fffb352] = true;
        keys[0xbf827c1890a225452b0b9bcabe5ee43b99f48cd587ef18bb6f33cd4e40c8b309] = true;
        keys[0x238204df1ec4435b43542ba336f3fc1ed898263cf7fae4c0a6ef2102b22da498] = true;
        keys[0x4f5a1d725c721eff235dc372766bbbec6013a4143cb8e956427835d32a0533cb] = true;
        keys[0x11220181f6cee0cb24438225a1579112f9f94c4ff4b790f27b01e4a4541349f7] = true;
        keys[0x4dec08cb456adc8c16d9f0b5c2cbf53b9d8fd5d5d139c6d31aaf58f012432f8d] = true;
        keys[0x883257b24697b242cd5828b5ced3058f29b7ea5b79bf54f735f3d7249bc1d6bb] = true;
        keys[0xeea800f3ff18709f56b84beecef96f17fde12479612383b0fb83b345a2dd6cbe] = true;
        keys[0x35a72700334a2a87d5787e1c123095c6318a170b3ae3941d1b93b2cd236acba1] = true;
        keys[0x1cdd2c2d609fa79ecba0f8a5b2f9fb8f62f418a9a03bf95b40688fb9a011efe5] = true;
        keys[0x331ab4b552ca0965381debf3b5c0032a49c71751999ad6849f502dbc9fe20c34] = true;
        keys[0xd4b4784f11211f43b8e2afd4320269d0343374245ba2c8b0405ce22c24a298ef] = true;
        keys[0xc3a2f4c7ce00231ff959ce18935bf1a1be0149471212db2cdd278ebf5466899c] = true;
        keys[0x2a87c7c527d8e3c465b93bb97f0dd0d9fbc7d612aa77cf0749d1d8fa4ea8b5a7] = true;
        keys[0xbde88bbea4e32433fab1333b6fd09e5b66dd6e5347f3f441dd50eabd1dd8a00c] = true;
        keys[0xca76e954e1013fcda1f151d225d73eead6e91dc627d6a4e1f55b72d3fea75d09] = true;
        keys[0x5dd9128e6cc68086e582ff25745aca2186eb5b14a5f25bca2de5facba2153408] = true;
        keys[0xda7f62c12ce3b59975ef9424abe6b8868438ef3669ebaf6f2c772ac6699be6df] = true;
        keys[0x7284d110a0838b51abd09c29d2c2a370bc671553fdff6ee0919b89945a93f9cc] = true;
        keys[0xb94d7a1252988224066fbe0674dc28f6b9f5614d0dc9a86dd7836969953889e3] = true;
        keys[0xab6ffd4248145a505666f3b77508a1742d2b46cb03db083edb6af765881d314e] = true;
        keys[0x254607fd06f2341be984089bf6671785a21924226e79194fa44d91500ef3f01e] = true;
        keys[0x03ca4c80d4dd20d40169cd541a4028abd512d6e6e734f3d8d5dfac30a36ba008] = true;
        keys[0x311af619d901b43b0a369634adc562346fe290bb838d82bf99a8ec0c30624250] = true;
        keys[0x2f3ac60a29485093fa32f38e0abc0c808b04431353892d9eeb080c8135cd7f42] = true;
        keys[0x7dd143dcf4e5596af7092218dd13100af15eb57126b08ad67d7429deb019dbc0] = true;
        keys[0x0627949439dfdb87a29cdc5c770a95a43e9e4fdbd7597b4f77a795662d1c8b51] = true;
        keys[0x591b61011d08331cf30b6514413de93966dbc95220bfebf85b916deb75f693a3] = true;
        keys[0x9ab4614527f5b6dc1fa8c3730356c9681c2346ca93abd03a536102b6d632fecb] = true;
        keys[0x648a23e45f74c2130d373aba2fe869ef99908bc1354a0e7bff7a561ae695c3d3] = true;
        keys[0x46e4d7d5ca191c805b45295f1c25eb365828a70e7b264cb4dc3552afcc1682ee] = true;
        keys[0x09473cb408fa4f613a801d00c53e2cafbde007d4e89de7d1c639bbf907426620] = true;
        keys[0x0a7dfb28ffab1e7622a77f597c4a0c7b1cfcc0ce810fc2fcef426de18cbe685e] = true;
        keys[0xf68869e24fc5bc6e1bba3fcb464bc429740c22642cd39a62e21dd6b3d103f67d] = true;
        keys[0x0daa822e22a635ec98cfdc36b316c67ee23d3a198be318914020860d9ed26745] = true;
        keys[0x7cde03174bf51ddfcbbb30b5fe851127171533010725555956a287e2eb9325c1] = true;
        keys[0x6b88ad5d7a0cc0d59f44f42fb80756cdb7e2b9a2ad45e1ad114a35bd9358623a] = true;
        keys[0x70582eff292265b8317f6155acdb0a420bcb3056eb7c88a7d5f40555b4f97a20] = true;
        keys[0xf133bd9d2e25097030d340481a5d148c66a30eb8cccbc0b007627d7808c8c805] = true;
        keys[0x8f9816b53c4e71baf9fe032df9c03c5aa6527ab54707c276455a42a73dd5e9a0] = true;
        keys[0x5c3724eac9239707484694e43d803be117668cb8da23d8c7ad0f40df48e430fa] = true;
        keys[0x240ee1ce4c49fbade23ccf4e95da018fd4862078e7f71638da9c2476c3cfc6ce] = true;
        keys[0x3c1af149ea9d05b5e13ed509717b976e8d2dbdaf1160c729ac1a5704280d7d82] = true;
        keys[0xaaf51662b9eca12617b1c871de61d423c3cffe193d61eeabbbf32640bd11ca05] = true;
        keys[0xc757e2fda4a3a5d7de8db8485d5c100acb943f1b771c96c965fade227581a15b] = true;
        keys[0xf8fb771b6da1f906093e21f7953d52d0d7b93cdfcc3ad82a7baf6faa24177797] = true;
        keys[0x663778ebeaedeb0e8237827e26c735ce24d024576ac4da4bf7865f871ac48745] = true;
        keys[0x87f8bb7e9dc5bcb7cd0a237164246ed45133b2aba67101976146bcd2e7d2e0b9] = true;
        keys[0xe5bbcbf2408491b2133b9c24cbc72a524cf9ee49a166c6782811ff751ddac36e] = true;
        keys[0x357b92060e1e43e7b45ea3cd0edc72190e1794f5ce1562d6407a0861bd343904] = true;
        keys[0x63b1b782c8581a3f9809d2559be58d6f7ff477d62fbced6d3867838f82e39b81] = true;
        keys[0x711230fa68c73883879a0cb6bab06a697f3a8dce70b91ea1be501703aac118c9] = true;
        keys[0x84c9593e50594ce7fca9273f72498d60b88763f0d06f7518e69f45648c656931] = true;
        keys[0xb6e5ae80c68053493dae4ceafdac510e5fe6c3f6814aec46cbff713a69e7d1e6] = true;
        keys[0x41969eec3313bbf4326a723a1bddbc0d09612229276579e84b7a75ec06560aca] = true;
        keys[0xd33ad65d485538ec8dad2e492644b50d2717282a65cd0f6b11e65823e667224d] = true;
        keys[0x1e097a7b5d7165e88b09f9f5b5d6aef7a9fd6864d226069a71f394b263341a0f] = true;
        keys[0xc02386c439c6046236c7debd807f503e854d51e5f28aa3eb469e55ddc3db8144] = true;
        keys[0x19fd7911f551da52159bab0204b8931fe2dcb24f8f43169852cf99587eeef805] = true;
        keys[0x02e93c5ae5a758fa5af57cee1993a7c18109c4a5c8791443f8934daa964f59fe] = true;
        keys[0xc94566aec1c9d978de2d58c6358843e6cd03bd05cf87330166dbfec7e20e2caa] = true;
        keys[0xcd193131afd051655a5709a6d71a1e2d4eed76d1194955b70148ab59bd34c3f6] = true;
        keys[0x2f5923e2d9a9c24f3a9fdf25ecab4d784c61f1ef4371a12454fb117f685aa294] = true;
        keys[0x72687bf4c6334378fc15290a697865977e810af8e13f325b8b45428b63ceff41] = true;
        keys[0xee17275cb996702c1d73b7491e9ddd5471371b9cb3f169841cd3fe05b0c83b2c] = true;
        keys[0x8b77a190df76faf3b2d16e093dcb60e0659ba8ee946af5f65c28b30208ed192c] = true;
        keys[0xe70a2895a83503138f8ee5007c21bf381eaf7512a51680893d2da65297bbb99e] = true;
        keys[0x987edee565a988e9a90eb17f43c2240a06f985d14e439583891930a2cee80914] = true;
        keys[0xf4bb6e848a0a91b4cfaa92e9d3e731af0b0384d5fdd448145923beeb3af7d5f5] = true;
        keys[0xb1d7797715c5d15c9bac9d5f2bcd1a836b9c390f4aa159622c6ce483d0e251e0] = true;
        keys[0x25c7ac5cf493f41c6fc0807e3ca297f9f490b199e538c420894a7e476075cca7] = true;
        keys[0x52b8fdb8c998660cf46458e9d3bdc2e44083fdec76c0a7a781b9a7ef579b25e1] = true;
        keys[0x5e45bd46b1640e44412a18a94492f019849c2419d0dd5c986869ea84da38446d] = true;
        keys[0xdadd4e42830015012ce1aeec883bc4f572c5fe0ab9681a064b2dd9bd37edf8ad] = true;
        keys[0x8325d3a109eb2dac5eaa934183a84e897c0c89aa31a33f9287d9bacbca80a74f] = true;
        keys[0x354ef7a50ecfe28a302fac626272a07cf78949dc84ecce36b595e2cb7c4c74e2] = true;
        keys[0xdb541f81498bf9800a6607d31087f1eeef8407f5acd600327135424040acf14f] = true;
        keys[0xe186e70d47f349912123665977ff2a56889682c12a28c0433c6f3af84691f497] = true;
        keys[0x5848d8c69023e4b280a1fb7207934df596a7b0b6987d3814bbeea41336d4e664] = true;
        keys[0x1d7e45482720388c948e0c51ba93ae4136f69152ba4d90e22c85b0e0ed02d338] = true;
        keys[0x62e13edf998d823b9285a818bb6e87ca16ff61cc99f61d4dc3206d3bcd67a0f0] = true;
        keys[0xe62359282d549492ed9aed6c8a5475861ef50e797adf102d9784c0b415d28ba7] = true;
        keys[0xb2d02aa3c473102d49ba06db38f25e51c3d6a96e550e4500d430143b259351db] = true;
        keys[0x8b92dfb0f65275c09a0a435a6e6289078fdb388f0ee040be327acf2aae4e6497] = true;
        keys[0x26566209842dffdf4cc4e9c50c6dc94c926703823a9614b95aadf11f6e7ab209] = true;
        keys[0x769bc30a0cd256fe7e004aa011efbc4e6b858d5f93b0483335bba583fd4139cc] = true;
        keys[0x0facdc985a3615c855c2193d62e2d32ba5fcac539ad25abab863c16851c4afbd] = true;
        keys[0x3df26fcd5632f502fdf101772b6f82b7e5fe667cea6c559c8887aa693af7ddfc] = true;
        keys[0xc040fcbf68e978d3fc7e1530fd02ca019c197b955fe44455cc3fe9749b5d0771] = true;
        keys[0x4cb4145a61924549032a98f7e76a199d7b64d24b254715c65a80dee96d8c89a0] = true;
        keys[0x7a40821e58d522c8daf9d20344b2660305f23e12d94a0337c6b5d5efa0c2f26c] = true;
        keys[0xbd9199aa393ac6a08cd9c4093b5eb770f372bceddbf4f80cfb4ff9e3abe310b9] = true;
        keys[0xe6e099cb3fd1146f0e918e553e80c1e77be0fa27553da4d33c3ef8a714c346c7] = true;
        keys[0x1ceaa140ad84755c3615ca1df2654658c43432718726a3e8c66a37450eddc850] = true;
        keys[0xa848a64bdea539c265345de72f6a0956255dc3876c520d9094c7909d1f3ef078] = true;
        keys[0x63108e536e4c41f8855d2083c92fc34badf797d6ccc50665ab0e2447637eaa26] = true;
        keys[0xd90a6f508fd7e920dd770b18571d6bb752ee2aedb9d4db4f42fda5c75833eec4] = true;
        keys[0x515a575d23f97cf6b30cc930bf689e4df9a209c8e20e1556a82df5494808c8c4] = true;
        keys[0xf6262a00bb2bfa2bcf506e84a82a1b625251f2369192e8ee23362eb093ceaa2f] = true;
        keys[0x9dd7c90a6c2cdcb756a188ae7fa682ed1d64a2563ed84f36306a33b86f5434dd] = true;
        keys[0x60c841f43b13b3d329340e9a9260a60eb0aded6a241d5b87890270bd7a1feec8] = true;
        keys[0xe2179cb475b148c120900666142c3bc73ddb25ccde9be325ca1f9cf1bb859798] = true;
        keys[0x0bb188a124ed2ff1e72565b1af8dd0e69f02fb7ad8bed516ef932af0fdde5ba2] = true;
        keys[0x238dba8b3d4b9ad63b809f835c24840e15ee31b75616b35250d1172328604382] = true;
        keys[0xb449006347d379a7da8491178f08d132759b50e051f10214534fec2692d4d819] = true;
        keys[0xcd6291bc54e75032631434ccde0d69266446fd398105e3c6d61387fb90e0a3d0] = true;
        keys[0xa2b777c667341b3df8cb7d00457360d8f6a08de6d393fbc4cf22f60ddfaeebb6] = true;
        keys[0xa711a28aa1f36f5378b9dc16e3b4773ed94b8d55825dd69a482f928830b18316] = true;
        keys[0xbb13b6570e6377011051e86855eb08ad7836437266a3d5bb9e468e60938f5cd9] = true;
        keys[0x9cc05ea316e9dd83a37f686f734036cc06c9546146ad21773adbfce9c8a943f4] = true;
        keys[0xbf401556544bc4e6dcd052f1447caabb908064f26cba4b61df1024a5ee0fe8cf] = true;
        keys[0x809955f0e109c357c312cb3d19324932f86b5a23890954cb13a1cf1062de72f2] = true;
        keys[0x631c98ed8f1b266dd6d8ce975b3f4cbb1f899a90080910fb7e62c8af896146b9] = true;
        keys[0xbd621b8c5ad5241478b0660ad9fd942cf37d877830ef96c2f8aae568bded8d47] = true;
        keys[0x652e6c0cdbf0c91b6f6f3610b1bbf973e3e2c925341fbc1fa99013371cf4c78f] = true;
        keys[0xf1f730c580c64bf243a9e023b6adb7ee7524a0e3e5988f2b9955677631ca1302] = true;
        keys[0x97f654274018ee5944009e2461074f265d2e22601d48dff5ceba79d07b7e2d71] = true;
        keys[0xc0ebe49cf41f28a5595bf8b064c3420400320ab7b70392857d6464d8c90bdd1e] = true;
        keys[0x719f8a80498829b869d7cd84b88836729a3e762ad1fafdc73f7ae1bc08bc056d] = true;
        keys[0x4e767f159a96ed9a1607b8fc8fdf340e2ea8410e70754b0427cfb253313a0237] = true;
        keys[0x1d62044f3f9f94b9fe5a77361362b500fd020b0f5af7dc855aba09f9852778de] = true;
        keys[0xa355fa9345d60de3d303337dbad6c68ddd3712111e7fe6ea17c14ff1707c7012] = true;
        keys[0x5d56a009cd832bb56b8ef4e78061b8256a51e5315c26f6286e2694656cf3975b] = true;
        keys[0x2cd874e8f0b8207f27ddefcd12501ce738440ad7506eb9a685b2269b4c9f5146] = true;
        keys[0x23e2fe423e414e14f65fa88b9c44e74e9afc40d3f3631993f0d36643b57e963a] = true;
        keys[0xcab0872f6ac837003244b1dcea9a0d166ec644a6a127d1c2258c54ee308b002c] = true;
        keys[0x5c70f9330564d04ea3edf1b74fbbe85cce14b7189c94483878d5fb467dde8747] = true;
        keys[0x229508ecf817be99dd67ebd38a4f9c3a6795535da59b34bcac330a607d4416db] = true;
        keys[0x2b264caee73ec8ea273bce1380621224d6a7f2e31c2919190691fa34c72fb83f] = true;
        keys[0xbf4b2a4ac3363164698cf54b50b801fca601f4f1b52dd38a5904d5c306882143] = true;
        keys[0xf9e4c9b1189237b87cdcddb102bc452410b6bd110f8df7a39644041c301b13eb] = true;
        keys[0xdb742b0c56cbf9f30396d42e1bf7b1e4ba46bcfc5daa8598a2a086c691915f94] = true;
        keys[0x12388b5deff9b1077b30e3bbc3fa7a6ea24f29fe04671fdecd18e19427f8a6f7] = true;
        keys[0x8ed36f964929a6b7628f919819849907de0db83e6ac6f45a4c30c8a5849a740c] = true;
        keys[0xe4b427441b2b54d7fa8e287e4963c75c52e15737ef67ae5d09748935163add90] = true;
        keys[0xb155ef4dcd1dae23e6106fa020f681d95bbf7326a447bd75678416b291ccb02c] = true;
        keys[0x4856421241b8f8a50a03db0f3f2f3569d68e78b91f647e35abced85387c2dee2] = true;
        keys[0xd30928a27c9f34ff3c042ddfc95b7a5c5845a0ae1a0faeb922c835c8ac78c3bb] = true;
        keys[0xb4af51c8f5b3db15e0d43472f1d8bd25ca28d129a2e611cb4dbcc3b6e285a898] = true;
        keys[0xe587c46a5f3be2416c253d8083a932b853c08ad63a413e53c063d1b6aabab0d9] = true;
        keys[0xb20dbe2e3fdd4aed1b35554b45878cabdac4f8fe2ff00cac47676f1144533fae] = true;
        keys[0xbf02b81ba86109b5f14ac3ab074f6a54e2b45800dc2f070e3f353cdbe0f414be] = true;
        keys[0x636a8edbb6fa8417747692b6fea29f4f7aa4f31962586087545c783aaf4a9e63] = true;
        keys[0x2a9d5bb51e7efe55f191fbe66aaaff17a67811b6eb8137df79ab158c7c21049d] = true;
        keys[0xa76e46fe5650233f5974e66a792c627c35b494d675d774c426b731b51700dc2c] = true;
        keys[0x68cec52e6869f24eedc6a6e7226565ff7a4ac1da39f3fbc3104f932e5f033df0] = true;
        keys[0x28843e862395dd9f8df6f0d92cef08d9b6a5333a055bb5a456edfb3c3fa04ac6] = true;
        keys[0xf65af0ca99c138e3b926f50b4bb274fabe3f5d3b0700756d76581ddb6f7f1fa6] = true;
        keys[0xe2c6bb716b2af259c597e84254f77ad9b7be927233ba9450a3ca0be6d29b63fb] = true;
        keys[0xc78638fd5e822f0c2276a2997ed27a89c4a081b77e7daf2f04399d182196ae0b] = true;
        keys[0xf8bc5500b1ec8d9276b151bf9c2ff3efe603d71175b7ac909ffce38a06fa789b] = true;
        keys[0x8d94fa765da3977077b65cc28d2465a8944f90a4c4071e45363389eefb004fb4] = true;
        keys[0xe63a5cd9a725c857982ff631f17674032129789fa85d29c87ed15e6ef1c636b5] = true;
        keys[0x5d19e943c59524ab3bf997ee068b40b2840243a387b7cee6a5c5df7ad1547f0e] = true;
        keys[0xae224cc97ca4ff184034e2d2b88143cb444803e1496ff62288c8cb7e24a7810e] = true;
        keys[0x2b4002eae2d8234854d75dc29ac72d3dead735967637e1f177f6851cd635be2d] = true;
        keys[0x86dca704ccc065b42cc42a25e76cc6a70a79b00309de089c2c12dcf08e9d6b44] = true;
        keys[0x5a96c7bf2e82b21aac99f8dfc36dd7883477ea3f63c2bb07f21b4c422e3bf67d] = true;
        keys[0x20343fba4b32be07538ad3784948643b1c2c76785c36d0a8d9f0e81d9fa70641] = true;
        keys[0x0015e491c990db0d0e714b72341a749265824e79e15178128ade7e8d4f6e4c3f] = true;
        keys[0x94849a4ec4f895c33a536d5d8e7475384cf93fb4e16755278ae6335b0bea1561] = true;
        keys[0xa167cc72f7f57cbc9ee52da646273bdfb1991783db08195cf271650c213e7170] = true;
        keys[0xc13fc5e380278a885b4d32e99af768e5a08636d78fefd6078fe92979e9182825] = true;
        keys[0x28777fd3a8acbebb33c67292b643df98d4138e7c8ba1e927fa2410b955f9182d] = true;
        keys[0x0c1d18068dd43a16b38c7c860277cdc1f7543acb69f18180cd29a7ac9daf2807] = true;
        keys[0xdbbe3bfcd0d4457d0c32a980845634656f7a7ff14b5603a4cee43f0dd6be3c6b] = true;
        keys[0x2dfc8bbfc8d937f7a9ebe0c8509957f5a151681fc07a4f115d5a22fdf73a978a] = true;
    }

    function _setTier() internal{
        if(keysUsed == 100){ // tier 2
            zyzzPerRedeem = 100;
        } else if(keysUsed == 300){ // tier 3
            zyzzPerRedeem = 50;
        }
    }

    function _validKey(string memory key) internal view returns(bool){
        return keys[sha256(abi.encodePacked(key))];
    }

    function validKey(string calldata key) external view returns (bool){
        return keys[sha256(abi.encodePacked(key))];
    }

    function _sendAirdrop(address recipient) internal{
        _transfer(address(this), recipient, zyzzPerRedeem * 10 ** 18);
        totalRedeemed += zyzzPerRedeem;
    }

    function _useKey(string memory key) internal{
        keysUsed++;
        keys[sha256(abi.encodePacked(key))] = false; // used key
    }

    function redeem(string calldata key1) external returns (bool) {

        require(_validKey(key1)); // key needs to be valid
        require(balanceOf(address(this)) > 0); // contract address needs funds
        require(keysUsed < 400); // all keys are used up

        _useKey(key1); // key is used
        _setTier();
        _sendAirdrop(msg.sender); // zyzz is dispatched
        

        return true;
    }

    // end of zyzzcoin functions

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
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
        function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
        function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _taxFee = taxFee;
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
    }
   
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }
    
    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        
        _taxFee = 0;
        _liquidityFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }


    

}