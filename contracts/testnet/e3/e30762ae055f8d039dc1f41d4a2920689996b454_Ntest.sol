/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

pragma solidity 0.6.12;
// SPDX-License-Identifier: Unlicensed
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

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
library Address {}



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
contract Ownable is Context ,Initializable  {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
     function initialize1()  external initializer {
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
    function lock(uint256 time) external virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() external virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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


contract Ntest is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    IERC20 BUSD;
    address busd;
    address DEAD;
    address ZERO;
   
    mapping (address => uint256) public _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isExcludeddividend;
    mapping (address => uint256) _balances;
    address[] private _excluded;
    address[] private _excludeddividend;
    address []  investors;
    uint256 public totalHoldings;
    struct User{
        uint256 rewards;
        }

    mapping(address => User) public users;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private  _decimals;
    
    uint256 public _redistributionFee;
    uint256 public _NevisbankFee;
    uint256 public _NevisswapSellFee;
    address public _NevisbankWallet ;
    address public _NevisRewardWallet;
    
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;
    
    event widthdraw(address user, uint256 amount);
    event dividentDistribution(uint256 amount);
    event setfees(uint256 fee);
    

     function initialize( address Busd,uint256 RedistributionFee,uint256 NevisbankFee,uint256 NevisswapSellFee,address router)  external initializer {

        busd=Busd;
        BUSD = IERC20(Busd);
        _tTotal =  100000000000* 10**9;
        _name = "ntest";
        _symbol = "ntest";
        _decimals = 9;
        _redistributionFee=RedistributionFee;
        _NevisbankFee=NevisbankFee;
        _NevisswapSellFee=NevisswapSellFee;

        _tOwned[_msgSender()] = _tTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(Busd,address(this));
        DEAD = 0x000000000000000000000000000000000000dEaD;
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[uniswapV2Pair] = true;

        _isExcluded[owner()] = true;
        _isExcluded[address(this)] = true;
        _isExcluded[uniswapV2Pair] = true;
       
        _isExcludeddividend[owner()] = true;
        _isExcludeddividend[address(this)] = true;
        _isExcludeddividend[uniswapV2Pair] = true;
    
        _balances[_msgSender()] = _tTotal;
        
        emit Transfer(address(0), _msgSender(), _tTotal);

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

    function balanceOf(address account) public view override returns (uint256) 
    {
         return _tOwned[account];
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

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
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

    function isExcludedFromDividend(address account) public view returns (bool) {
        return _isExcludeddividend[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    function total_investor() public view returns (uint256 totalInvestors) {
        totalInvestors = investors.length;
        return totalInvestors;
    }
    
    function excludeFromReward(address account) external onlyOwner() {
         require(!_isExcluded[account], "Account is already excluded");
        _isExcluded[account] = true;
        _excluded.push(account);
    }

     function excludeFromDividend(address account) external onlyOwner() {
        require(!_isExcludeddividend[account], "Account is already excluded");
        _isExcludeddividend[account] = true;
        _excludeddividend.push(account);
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

 function includeInDivident(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excludeddividend.length; i++) {
            if (_excludeddividend[i] == account) {
                _excludeddividend[i] = _excludeddividend[_excludeddividend.length - 1];
                _tOwned[account] = 0;
                _isExcludeddividend[account] = false;
                _excludeddividend.pop();
                break;
            }
        }
    }
    

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 tFee) private {
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        return (tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = calculateredistributionFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }


    function _getCurrentSupply() public view returns(uint256) {
        uint256 tSupply = _tTotal;   
         for (uint256 i = 0; i < _excluded.length; i++) {
            if ( _tOwned[_excluded[i]] > tSupply) return ( _tTotal);
         
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        return tSupply;
    }

    
    function calculateredistributionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_redistributionFee).div(
            10**2
        );
    }

    function getTokenPrice(uint256 amount) public view returns(uint)
        {
            IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
            (uint Res0, uint Res1,) = pair.getReserves();
            return (amount*Res0)/Res1; 
        }

    function distributerewards(uint256 amount) external payable onlyOwner{

         totalHoldings=0;
            for(uint256 i = 0; i < investors.length; i++){
                    if (!_isExcluded[investors[i]]) {
                        totalHoldings+=balanceOf(investors[i]);
                    }
            }

        _approve(address(msg.sender),address(this), amount);
        BUSD.transferFrom(address(msg.sender),address(this), amount);

        uint256 dividentShare;
        uint256 userreward ;
        (uint256 _price)=getTokenPrice(1e9);
        uint256 holdingbusd=totalHoldings.mul(_price);
        for(uint256 i = 0; i < investors.length; i++){
            User storage user = users[investors[i]];
            if (!_isExcludeddividend[investors[i]]) {
                uint256 nevisinbusd=_tOwned[investors[i]].mul(_price);
                dividentShare = nevisinbusd.mul(100).div(holdingbusd);
                userreward=amount.mul(dividentShare).div(100);
                user.rewards+=userreward;
                  BUSD.transfer(
                        investors[i],
                        userreward
                    );
            }
        }
        emit dividentDistribution(amount);
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
        require(amount > 0, "Transfer amount must be greater than zero");
        _tokenTransfer(from,to,amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
      
                 if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
                    _transferStandard(sender, recipient, amount);
                } else if (_isExcludedFromFee[sender] && _isExcludedFromFee[recipient]) {
                    _transferBothExcluded(sender, recipient, amount);
                }else{
                    _transferToExcluded(sender, recipient, amount);
                } 
                 if(!includeIninvestor(recipient) && !_isExcludedFromFee[recipient] )
                    {
                        investors.push(recipient);
                    }
     
    }
  
    function includeIninvestor(address recipient) private view returns(bool) {
            for (uint256 i = 0; i < investors.length; i++) {
                if (investors[i] == recipient || DEAD == recipient ||  ZERO == recipient || uniswapV2Pair==recipient  ) {
                        return true;
                }
            }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        uint256 OwnerAmt;

        if(recipient!=uniswapV2Pair){
            OwnerAmt = tAmount.mul(_NevisbankFee).div(100);
            if(OwnerAmt > 0){
                _tOwned[_NevisbankWallet] = _tOwned[_NevisbankWallet].add(OwnerAmt);
                emit Transfer(sender, _NevisbankWallet, OwnerAmt);}
        }else{
            OwnerAmt = tAmount.mul(_NevisswapSellFee).div(100);
            if(OwnerAmt > 0){
                _tOwned[_NevisbankWallet] = _tOwned[_NevisbankWallet].add(OwnerAmt);
                emit Transfer(sender, _NevisbankWallet, OwnerAmt);}
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount.sub(OwnerAmt));

        _reflectFee(tFee);
        if(tFee > 0){
            _tOwned[_NevisRewardWallet] = _tOwned[_NevisRewardWallet].add(tFee);
            emit Transfer(sender, _NevisRewardWallet, tFee);
            }
        emit Transfer(sender, recipient, tTransferAmount.sub(OwnerAmt));
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        uint256 OwnerAmt;

       if(recipient!=uniswapV2Pair){
            OwnerAmt = tAmount.mul(_NevisbankFee).div(100);
            if(OwnerAmt > 0){
                 _tOwned[_NevisbankWallet] = _tOwned[_NevisbankWallet].add(OwnerAmt);
                emit Transfer(sender, _NevisbankWallet, OwnerAmt);}
        }else{
            OwnerAmt = tAmount.mul(_NevisswapSellFee).div(100);
            if(OwnerAmt > 0){
                 _tOwned[_NevisbankWallet] = _tOwned[_NevisbankWallet].add(OwnerAmt);
                emit Transfer(sender, _NevisbankWallet, OwnerAmt);}
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount.sub(OwnerAmt));
        _reflectFee(tFee);
        if(tFee > 0){
              _tOwned[_NevisRewardWallet] = _tOwned[_NevisRewardWallet].add(tFee);
            emit Transfer(sender, _NevisRewardWallet, tFee);}
        emit Transfer(sender, recipient, tTransferAmount.sub(OwnerAmt));
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        uint256 OwnerAmt;

        if(recipient!=uniswapV2Pair){
            OwnerAmt = tAmount.mul(_NevisbankFee).div(100);
            if(OwnerAmt > 0){
                msg.sender.transfer(OwnerAmt);
                emit Transfer(sender, _NevisbankWallet, OwnerAmt);}
        }else{
            OwnerAmt = tAmount.mul(_NevisswapSellFee).div(100);
            if(OwnerAmt > 0){
                msg.sender.transfer(OwnerAmt);
                emit Transfer(sender, _NevisbankWallet, OwnerAmt);}
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _reflectFee(tFee);
        if(tFee > 0){
            msg.sender.transfer(tFee);
            emit Transfer(sender, _NevisRewardWallet, tFee);}
        emit Transfer(sender, recipient, tAmount);
    }

     function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
         _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        _reflectFee(0);
        emit Transfer(sender, recipient, tAmount);
    }
    
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setBankWallet(address newWallet) external onlyOwner() {
        _NevisbankWallet = newWallet;
    }

    function setrewardWallet(address rWallet) external onlyOwner() {
        _NevisRewardWallet = rWallet;
    }
    
    
    function setTaxFeePercent(uint256 redistributionFee) external onlyOwner() {
        require(redistributionFee < 6, "Invalid Fees");
        _redistributionFee = redistributionFee;
        emit setfees(redistributionFee);

    }
    
    function setNevisbankFeePercent(uint256 NevisbankFee) external onlyOwner() {
        require(NevisbankFee < 6, "Invalid Fees");
        _NevisbankFee = NevisbankFee;
        emit setfees(NevisbankFee);
    }

    function setNeviswapFeePercent(uint256 NevisswapFee) external onlyOwner() {
        require(NevisswapFee < 21, "Invalid Fees");
        _NevisswapSellFee = NevisswapFee;
        emit setfees(NevisswapFee);
    }
    
   
    //New Pancakeswap router version?
    //No problem, just change it!
    function setRouterAddress(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(busd,address(this));
        uniswapV2Router = _newPancakeRouter;
    }

}