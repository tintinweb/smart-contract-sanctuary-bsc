/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

/**
 *Submitted for verification at BscScan.com on 2021-05-11
*/

/**
 *Submitted for verification at BscScan.com on 2021-02-26
*/

/**
   #PIG
   
   #LIQ+#RFI+#SHIB+#DOGE, combine together to #PIG  

    I make this #PIG to hand over it to the community.
    Create the community by yourself if you are interested.   
    I suggest a telegram group name for you to create: https://t.me/PigTokenBSC

   Great features:
   3% fee auto add to the liquidity pool to locked forever when selling
   2% fee auto distribute to all holders
   50% burn to the black hole, with such big black hole and 3% fee, the strong holder will get a valuable reward

   I will burn liquidity LPs to burn addresses to lock the pool forever.
   I will renounce the ownership to burn addresses to transfer #PIG to the community, make sure it's 100% safe.

   I will add 0.999 BNB and all the left 49.5% total supply to the pool
   Can you make #PIG 10000000X? 

   1,000,000,000,000,000 total supply
   5,000,000,000,000 tokens limitation for trade
   0.5% tokens for dev

   3% fee for liquidity will go to an address that the contract creates, 
   and the contract will sell it and add to liquidity automatically, 
   it's the best part of the #PIG idea, increasing the liquidity pool automatically, 
   help the pool grow from the small init pool.

 */

pragma solidity ^0.6.12;
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

    function decimals() external view returns (uint8);

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

interface AddLiquidityPool{
    function swapAndLiquify(uint256 tokenAmount)external;
}

contract KENDYToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 2100000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "KENDY Token";
    string private _symbol = "KENDY";
    uint8 private _decimals = 9;
    
    uint256 public _taxFee = 10;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _LPFee = 12;
    uint256 private _previousLPFee = _LPFee;
    

    uint256 public _liquidityFee = 20;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _goldCardFee=5;
    uint256 private _previousGoldCardFee= _goldCardFee;
 
    uint256 public _silverCardFee=8;
    uint256 private _previousSilverCardFee= _silverCardFee;


    uint256 public _copperCardFee=10;
    uint256 private _previousCopperCardFee= _copperCardFee;

    uint256 public _lifeCardFee=10;
    uint256 private _previousLifeCardFee= _lifeCardFee;


    uint256 public _marketingFee = 15;
    uint256 private _previousMarketingFee= _marketingFee;

    uint256 public _burnFee=10;
    uint256 private _previousBurnFee= _burnFee;

    
    uint256 private totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
    uint256 public totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
    uint256 public sellFeeProportion=totalSellFee;
    
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 private numTokensSellToAddToLiquidity = 100* 10**9;
    uint256 public  numTokensToLPDividends=100*10**9;
    bool isCreatePair;
    uint256 public startingPrice;
    uint public nextUpdateTime;
    uint public createTime;
    uint public unlockTime;
    uint public totalUnlock;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    uint256 currentIndex;  

    mapping(address => bool) private _updated;

    address public contractOwnerAddress=0xbcaC23d5A4bA8e2950CD3d6e205DBbF8BfBC7F0a;
    address public operationTeamAddress=0x2031E953980A0ecd896147dbBb7A2977f3B2Fafb;
    address public foundationAddress=0x769AB6F8A79e405115376B1d58eb123A6D69ad28;
    address public goldCardAddress=0x21AF0bA61B2779cc1856040D75F28aa4008A46b2;
    address public silverCardAddress=0xEaa3C74313f5129F8EA07aE77C642Df37833c349;
    address public copperCardAddress=0x46eD1167E1e91bda10a8815cb1Cf2E3CDCd6D3ec;
    address public lifeCardAddress=0x3930F5a9A1B208aCeBCc62d1839655912b6Af372;
    address public marketingAddress=0x9bf643cE28A329D1F0Cc107404c46EC1D7dD5b87;
    address public usdtAddress=0x55d398326f99059fF775485246999027B3197955;
    address public addLiquidityPool=0xFC896a6c1cDCBF5B49E5c9FbAB5E8139fffBf848;
    
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
    
    constructor () public {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0x8888888888888888888888888888888888888888)] = true;
        _isExcludedFromFee[contractOwnerAddress] = true;
        _isExcludedFromFee[operationTeamAddress] = true;
        _isExcludedFromFee[foundationAddress] = true;
        _isExcludedFromFee[goldCardAddress] = true;
        _isExcludedFromFee[silverCardAddress] = true;
        _isExcludedFromFee[copperCardAddress] = true;
        _isExcludedFromFee[lifeCardAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[addLiquidityPool] = true;
        _isExcluded[0x8888888888888888888888888888888888888888]=true;
        _isExcluded[address(0xdead)]=true;
        _isExcluded[addLiquidityPool]=true;
        _isExcluded[address(this)]=true;

        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
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


    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256[10] memory gtAmount) = _getValues(tAmount,recipient);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(gtAmount[9]);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(sender,gtAmount[1]);
        _takeGoldCard(sender,gtAmount[2]);
        _takeSilverCard(sender,gtAmount[3]);
        _takeCopperCard(sender,gtAmount[4]);
        _takeLifeCard(sender,gtAmount[5]);
        _takeMarketing(sender,gtAmount[6]);
        _takeBurn(sender,gtAmount[7]);
        _takeLP(sender,gtAmount[8]);
        _reflectFee(rFee, gtAmount[0]);
        emit Transfer(sender, recipient, gtAmount[9]);
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
       totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
       totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
       sellFeeProportion=totalSellFee;
    }

    function setGoldCardFeePercent(uint256 _num)public onlyOwner{
        _goldCardFee=_num;
        totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
       totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
       sellFeeProportion=totalSellFee;
    }
    function setSilverCardFeePercent(uint256 _num)public onlyOwner{
        _silverCardFee=_num;
        totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
       totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
       sellFeeProportion=totalSellFee;
    }
    function setCopperCardFeePercent(uint256 _num)public onlyOwner{
        _copperCardFee=_num;
        totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
       totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
       sellFeeProportion=totalSellFee;
    }
    function setlifeCardFeePercent(uint256 _num)public onlyOwner{
        _lifeCardFee=_num;
       totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
       totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
       sellFeeProportion=totalSellFee;
    }

    function setTaxFeePercent(uint256 _num)public onlyOwner{
        _taxFee=_num;
       totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
       totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
       sellFeeProportion=totalSellFee;
    }
    function setMarketingFeePercent(uint256 _num)public onlyOwner{
        _marketingFee=_num;
       totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
       totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
       sellFeeProportion=totalSellFee;
    }
    function setLPFeePercent(uint256 _num)public onlyOwner{
        _LPFee=_num;
       totalSellFee1=_goldCardFee.add(_silverCardFee).add(_copperCardFee).add(_lifeCardFee);
       totalSellFee=totalSellFee1.add(_marketingFee).add(_burnFee).add(_taxFee).add(_LPFee);
       sellFeeProportion=totalSellFee;
    }
    function setAddLiquidityPool(address _addLiquidityPool) external onlyOwner() {
        addLiquidityPool = _addLiquidityPool;
    }
   

    function setNumTokensToLPDividends(uint256 _num)public onlyOwner{
        numTokensToLPDividends=_num;
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

    function _getValues(uint256 tAmount,address to) private view returns (uint256, uint256, uint256, uint256[10] memory) {
        uint256[10] memory gtAmount= _getTValues(tAmount,to);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, gtAmount,_getRate());
        return (rAmount, rTransferAmount, rFee, gtAmount);
    }
    function _getTValues(uint256 tAmount,address to) private view returns (uint256[10] memory) {
        uint256[10] memory tTransferAmount;
        tTransferAmount[0]= calculateTaxFee(tAmount);
        if(to==uniswapV2Pair){
            tTransferAmount[1]= calculateLiquidityFee(tAmount);
        }else{
            tTransferAmount[1]=0;
        }
        tTransferAmount[2]= calculateGoldCardFee(tAmount);
        tTransferAmount[3]= calculateSilverCardFee(tAmount);
        tTransferAmount[4]= calculateCopperCardFee(tAmount);
        tTransferAmount[5]= calculateLifeCardFee(tAmount);
        tTransferAmount[6]= calculateMarketingFee(tAmount);
        tTransferAmount[7]= calculateBurnFee(tAmount);
        tTransferAmount[8]= calculateLPFee(tAmount);
        uint256 tTransferAmount1 = tAmount.sub(tTransferAmount[0]).sub(tTransferAmount[1]).sub(tTransferAmount[2]);
        uint256 tTransferAmount2 = tTransferAmount1.sub(tTransferAmount[3]).sub(tTransferAmount[4]).sub(tTransferAmount[5]);
        tTransferAmount[9]= tTransferAmount2.sub(tTransferAmount[6]).sub(tTransferAmount[7]).sub(tTransferAmount[8]);

        return tTransferAmount;
    }

    function _getRValues(uint256 tAmount, uint256[10] memory gtAmount,uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256[10] memory rTransferAmount;
        uint256 rAmount = tAmount.mul(currentRate);
        rTransferAmount[0]= gtAmount[0].mul(currentRate);
        rTransferAmount[1]= gtAmount[1].mul(currentRate);
        rTransferAmount[2]= gtAmount[2].mul(currentRate);
        rTransferAmount[3]= gtAmount[3].mul(currentRate);
        rTransferAmount[4]= gtAmount[4].mul(currentRate);
        rTransferAmount[5]= gtAmount[5].mul(currentRate);
        rTransferAmount[6]= gtAmount[6].mul(currentRate);
        rTransferAmount[7]= gtAmount[7].mul(currentRate);
        rTransferAmount[8]= gtAmount[8].mul(currentRate);
        uint256 rTransferAmount1 = rAmount.sub(rTransferAmount[0]).sub(rTransferAmount[1]).sub(rTransferAmount[2]);
        uint256 rTransferAmount2 = rTransferAmount1.sub(rTransferAmount[3]).sub(rTransferAmount[4]).sub(rTransferAmount[5]);
        rTransferAmount[9]= rTransferAmount2.sub(rTransferAmount[6]).sub(rTransferAmount[7]).sub(rTransferAmount[8]);
        return (rAmount, rTransferAmount[9], rTransferAmount[0]);
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
    
    function _takeLiquidity(address sender,uint256 tLiquidity) private {
        if(tLiquidity==0)return;
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(addLiquidityPool)] = _rOwned[address(addLiquidityPool)].add(rLiquidity);
        if(_isExcluded[address(addLiquidityPool)])
            _tOwned[address(addLiquidityPool)] = _tOwned[address(addLiquidityPool)].add(tLiquidity);
        emit Transfer(sender, address(addLiquidityPool), tLiquidity);
    }

    function _takeSilverCard(address sender,uint256 tSilverCard) private {
        if(tSilverCard==0)return;
        uint256 currentRate =  _getRate();
        uint256 rSilverCard = tSilverCard.mul(currentRate);
        _rOwned[silverCardAddress] = _rOwned[silverCardAddress].add(rSilverCard);
        if(_isExcluded[silverCardAddress])
            _tOwned[silverCardAddress] = _tOwned[silverCardAddress].add(tSilverCard);
        emit Transfer(sender, silverCardAddress, tSilverCard);
    }
    function _takeGoldCard(address sender,uint256 tGoldCard) private {
        if(tGoldCard==0)return;
        uint256 currentRate =  _getRate();
        uint256 rGoldCard = tGoldCard.mul(currentRate);
        _rOwned[goldCardAddress] = _rOwned[goldCardAddress].add(rGoldCard);
        if(_isExcluded[goldCardAddress])
            _tOwned[goldCardAddress] = _tOwned[goldCardAddress].add(tGoldCard);
        emit Transfer(sender, goldCardAddress, tGoldCard);
    }
    function _takeCopperCard(address sender,uint256 tCopperCard) private {
        if(tCopperCard==0)return;
        uint256 currentRate =  _getRate();
        uint256 rCopperCard = tCopperCard.mul(currentRate);
        _rOwned[copperCardAddress] = _rOwned[copperCardAddress].add(rCopperCard);
        if(_isExcluded[copperCardAddress])
            _tOwned[copperCardAddress] = _tOwned[copperCardAddress].add(tCopperCard);
        emit Transfer(sender, copperCardAddress, tCopperCard);
    }
    function _takeLifeCard(address sender,uint256 tLifeCard) private {
        if(tLifeCard==0)return;
        uint256 currentRate =  _getRate();
        uint256 rLifeCard = tLifeCard.mul(currentRate);
        _rOwned[lifeCardAddress] = _rOwned[lifeCardAddress].add(rLifeCard);
        if(_isExcluded[lifeCardAddress])
            _tOwned[lifeCardAddress] = _tOwned[lifeCardAddress].add(tLifeCard);
        emit Transfer(sender, lifeCardAddress, tLifeCard);
    }

    function _takeMarketing(address sender,uint256 tMarketing) private {
        if(tMarketing==0)return;
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[marketingAddress] = _rOwned[lifeCardAddress].add(rMarketing);
        if(_isExcluded[marketingAddress])
            _tOwned[marketingAddress] = _tOwned[marketingAddress].add(tMarketing);
        emit Transfer(sender, marketingAddress, tMarketing);
    }
    function _takeBurn(address sender,uint256 tBurn) private {
        if(tBurn==0)return;
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[address(0xdead)] = _rOwned[address(0xdead)].add(rBurn);
        if(_isExcluded[address(0xdead)])
            _tOwned[address(0xdead)] = _tOwned[address(0xdead)].add(tBurn);
        emit Transfer(sender, address(0xdead), tBurn);
    }
    function _takeLP(address sender,uint256 tLP) private {
        if(tLP==0)return;
        uint256 currentRate =  _getRate();
        uint256 rLP = tLP.mul(currentRate);
        _rOwned[address(0x8888888888888888888888888888888888888888)] = _rOwned[address(0x8888888888888888888888888888888888888888)].add(rLP);
        if(_isExcluded[address(0x8888888888888888888888888888888888888888)])
            _tOwned[address(0x8888888888888888888888888888888888888888)] = _tOwned[address(0x8888888888888888888888888888888888888888)].add(tLP);
        emit Transfer(sender, address(0x8888888888888888888888888888888888888888), tLP);
    }
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }

    function calculateSilverCardFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_silverCardFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }

    function calculateCopperCardFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_copperCardFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }
    function calculateLifeCardFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lifeCardFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }

    function calculateGoldCardFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_goldCardFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }
    function calculateLPFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_LPFee.mul(sellFeeProportion.mul(100).div(totalSellFee)).div(100)).div(
            10**3
        );
    }
    
    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0&& _goldCardFee == 0&& _silverCardFee == 0&& _copperCardFee == 0&& _lifeCardFee == 0
        && _marketingFee == 0&& _marketingFee == 0&& _LPFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousGoldCardFee= _goldCardFee;
        _previousSilverCardFee= _silverCardFee;
        _previousCopperCardFee= _copperCardFee;
        _previousLifeCardFee= _lifeCardFee;
        _previousMarketingFee= _marketingFee;
        _previousBurnFee= _marketingFee;
        _previousLPFee= _LPFee;
        _taxFee = 0;
        _liquidityFee = 0;
        _goldCardFee=0;
        _silverCardFee=0;
        _copperCardFee=0;
        _lifeCardFee=0;
        _marketingFee=0;
        _burnFee=0;
        _LPFee=0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _goldCardFee=_previousGoldCardFee;
        _silverCardFee=_previousSilverCardFee;
        _copperCardFee=_previousCopperCardFee;
        _lifeCardFee=_previousLifeCardFee;
        _marketingFee=_previousMarketingFee;
        _burnFee=_previousBurnFee;
        _LPFee=_previousLPFee;
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
        // require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(addLiquidityPool));
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        uint256 priceNow;
        if(isCreatePair){
            if(block.timestamp>=nextUpdateTime){
                nextUpdateTime=block.timestamp+(86400-block.timestamp%86400);
                startingPrice=getPriceOfUSDT();
            }
            priceNow=getPriceOfUSDT();
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]||(from!=uniswapV2Pair&&to!=uniswapV2Pair)){
            takeFee = false;
        }

        if(to==uniswapV2Pair){
            require(createTime.add(25 minutes)<block.timestamp,"No free trading time");
            if(priceNow<startingPrice){
                uint spread=startingPrice.sub(priceNow);
                if(spread.mul(10**18).div(startingPrice)>=1*10**17){
                  sellFeeProportion=200;
                }else{
                  sellFeeProportion=totalSellFee; 
                }
            }
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);

        if(!address(from).isContract() && from != address(0) ) setShare(from);
        if(!address(to).isContract() && to != address(0) ) setShare(to);


       
        if(balanceOf(address(0x8888888888888888888888888888888888888888)) >= numTokensToLPDividends) {
            process(200000);
        }

        if (to==uniswapV2Pair&&!isCreatePair){
            require(from==owner());
            nextUpdateTime=block.timestamp+(86400-block.timestamp%86400);
            isCreatePair=true;
            createTime=block.timestamp;

            startingPrice=getPriceOfUSDT();
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
         AddLiquidityPool(addLiquidityPool).swapAndLiquify(contractTokenBalance);
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256[10] memory gtAmount) = _getValues(tAmount,recipient);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(sender,gtAmount[1]);
        _takeGoldCard(sender,gtAmount[2]);
        _takeSilverCard(sender,gtAmount[3]);
        _takeCopperCard(sender,gtAmount[4]);
        _takeLifeCard(sender,gtAmount[5]);
        _takeMarketing(sender,gtAmount[6]);
        _takeBurn(sender,gtAmount[7]);
        _takeLP(sender,gtAmount[8]);
        _reflectFee(rFee, gtAmount[0]);
        emit Transfer(sender, recipient, gtAmount[9]);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
         (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256[10] memory gtAmount) = _getValues(tAmount,recipient);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(gtAmount[9]);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(sender,gtAmount[1]);
        _takeGoldCard(sender,gtAmount[2]);
        _takeSilverCard(sender,gtAmount[3]);
        _takeCopperCard(sender,gtAmount[4]);
        _takeLifeCard(sender,gtAmount[5]);
        _takeMarketing(sender,gtAmount[6]);
        _takeBurn(sender,gtAmount[7]);
        _takeLP(sender,gtAmount[8]);
        _reflectFee(rFee, gtAmount[0]);
        emit Transfer(sender, recipient, gtAmount[9]);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
         (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256[10] memory gtAmount) = _getValues(tAmount,recipient);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(sender,gtAmount[1]);
        _takeGoldCard(sender,gtAmount[2]);
        _takeSilverCard(sender,gtAmount[3]);
        _takeCopperCard(sender,gtAmount[4]);
        _takeLifeCard(sender,gtAmount[5]);
        _takeMarketing(sender,gtAmount[6]);
        _takeBurn(sender,gtAmount[7]);
        _takeLP(sender,gtAmount[8]);
        _reflectFee(rFee, gtAmount[0]);
        emit Transfer(sender, recipient, gtAmount[9]);
    }
    function  getPriceOfUSDT() public view returns (uint256 price){
        uint256 balancePath1= IERC20(usdtAddress).balanceOf(uniswapV2Pair);
        uint256 balancePath2= IERC20(address(this)).balanceOf(uniswapV2Pair);
        uint256 path1Decimals=IERC20(usdtAddress).decimals();
        uint256 path2Decimals=IERC20(address(this)).decimals();
        price=(balancePath1*10**18/10**path1Decimals)/(balancePath2/10**path2Decimals);
    }



    function process(uint256 gas) private {
        
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = balanceOf(address(0x8888888888888888888888888888888888888888));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                
            }
            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());

            if(balanceOf(address(0x8888888888888888888888888888888888888888)) < amount )return;
                distributeDividend(shareholders[currentIndex],amount);
                
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
        uint256 currentRate =  _getRate();
        uint256 rAmount = amount.mul(currentRate);
        _tOwned[address(0x8888888888888888888888888888888888888888)] = _tOwned[address(0x8888888888888888888888888888888888888888)].sub(amount);
        _rOwned[shareholder] = _rOwned[shareholder].add(rAmount);
        if(_isExcluded[shareholder])
            _tOwned[shareholder] = _tOwned[shareholder].add(amount);
        emit Transfer(address(0x8888888888888888888888888888888888888888), shareholder, amount);
    }

    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function lockToken(uint256 amount) public onlyOwner{
        IERC20(address(this)).transferFrom(msg.sender,address(this),amount);
        unlockTime=block.timestamp.add(2592000);
    }

    function unlockToken() public onlyOwner{
        uint256 monthUnLockAmount=42000*10**9;
        uint256 unlockCount=1;
        if(block.timestamp>unlockTime){
           unlockCount=unlockCount.add((block.timestamp-unlockTime).div(2592000));
        }else{
          return;
        }
        
        uint256 unlockAmount=monthUnLockAmount.mul(unlockCount);
        totalUnlock=totalUnlock.add(unlockAmount);
        if (totalUnlock>420000*10**9){
          return;
        }
        uint256 currentRate =  _getRate();
        uint256 rAmount = unlockAmount.mul(currentRate);
        _tOwned[address(this)] = _tOwned[address(this)].sub(unlockAmount);
        _rOwned[msg.sender] = _rOwned[msg.sender].add(rAmount);
        if(_isExcluded[msg.sender])
            _tOwned[msg.sender] = _tOwned[msg.sender].add(unlockAmount);
        emit Transfer(address(this), msg.sender, unlockAmount);
        
        unlockTime=unlockTime.add(unlockCount.mul(2592000));
    }

}