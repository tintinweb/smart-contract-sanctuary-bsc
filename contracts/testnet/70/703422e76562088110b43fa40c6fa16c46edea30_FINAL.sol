/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *  SPDX-License-Identifier: MIT
*/
pragma solidity 0.6.12;


interface IBEP20 {

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

    function getUnlockTime() public view returns (uint256) {
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


contract FINAL is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private staked ;
    mapping(address => uint256) private stakedFromTS;
    uint256 public _basicapr ; 
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isPool;
    mapping (address => bool) private _isBlock;
    
    mapping (address => uint256) private _balances;
    
    uint256 private constant MAX = uint256(100000000000 * 10**18);
    uint256 private _total = 100000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _total));

    string public _name = "FINAL";
    string public _symbol = "FINAL";
    uint8 public _decimals = 18;

    address public rewardWallet ; // 0xe15505C74B9122185bFC6a27fe3c8D8c144f2e9f
    address public stakeWallet ;  //0xF8CE659146008e5Cf7EC2386eB2FAa571eED6831
    uint256 private _stakeFee  ; 
    uint256 private _previousStakeFee ;

    uint256 private _LPFee  ; //
    uint256 private _previousLPFee ;

    uint256 private _burnFee  ; //
    uint256 private _previousBurnFee ;
    
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;
    
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    uint256 private numTokensSellToAddToLiquidity = 8000 * 10**18;
    
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
        _balances[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        //_isExcludedFromFee[address(this)] = true;        
        emit Transfer(address(0), _msgSender(), _total);
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
        return _total;
    }
    

    function balanceOf(address account) public view override returns (uint256) {
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
    
    function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
    } 

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "You can't mint to the zero address");
        require(_total.add(amount)<=MAX, "This is max supply");
        _total = _total.add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: burn from the zero address");
    _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
    _total = _total.sub(amount);
    emit Transfer(account, address(0), amount);
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function pool(address account) public onlyOwner {
        _isPool[account] = true;
    }

    function blockk(address account) public onlyOwner {
        _isBlock[account] = true;
    }
    
      function unblock(address account) public onlyOwner {
        _isBlock[account] = false;
    }
   
    function setFees( uint256 stakeFee, uint256 burnFee,  uint256 LPFee) external onlyOwner {
        _previousStakeFee = stakeFee ;
        _previousBurnFee = burnFee ;
        _previousLPFee = LPFee ;
    } 

    function removeAllFee() private {
        _stakeFee = 0;
        _burnFee=0 ;     
        _LPFee =0 ;
    }

    function blockFee() private {
        uint256 _blockburn = 1 ;
        _stakeFee = (10000 - _blockburn).div(100); //99,99%
        _burnFee = _blockburn.div(100) ; //0,01%
        _LPFee = 0 ;              
    }
    
    function restoreAllFee() private {
       _stakeFee = _previousStakeFee ;
       _burnFee = _previousBurnFee ;
       _LPFee = _previousLPFee ;
    }

    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account] ;
    }

    function isblock(address account) public view returns(bool) {
        return _isBlock[account] ;
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

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));        
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
        
        //transfer amount, it will take fee
        _tokenTransfer(from,to,amount);
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
      //  addLiquidity(otherHalf, newBalance);
        
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
    
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        require(_isBlock[recipient] != true, "This account have been lock.");
        _isExcludedFromFee[owner()]=true;
        _isExcludedFromFee[rewardWallet]=true;
        _isExcludedFromFee[stakeWallet]=true;

        if (_isBlock[sender]) 
            blockFee(); 
            else
            {
                if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) 
                removeAllFee(); else
                {
                    if (_isPool[recipient]) restoreAllFee() ; // pool sell ( all fee )
                    else if (_isPool[sender]) //pool buy ( LP fee )
                    {
                        restoreAllFee() ;
                        _burnFee = 0 ;
                        _stakeFee = 0 ;
                    }
                    else 
                    {
                     restoreAllFee () ; //transfer + stake + unstake  (stake fee)
                        _LPFee = 0 ;
                        _burnFee =0 ;
                    }   
                }
            }
        //0xd35c75C2515a319b1DBE05e0B4F9c33b5c58C48D
        //Calculate burn , stake and lp amount
        uint256 burnAmt = amount.mul(_burnFee).div(100);
        uint256 feeAmt = amount.mul(_stakeFee).div(100);
        uint256 lpAmt = amount.mul(_LPFee).div(100);
        uint256 total= amount - feeAmt - burnAmt - lpAmt;

        //if=0 dont transfer            
        if (burnAmt!=0) _transferStandard(sender, address(0), burnAmt);
        if (feeAmt!=0) 
            {   
            if (_isBlock[sender])
            _transferStandard(sender, owner(), feeAmt); //account blocked tranfer to owner
            else _transferStandard(sender, stakeWallet, feeAmt); // //account not blocked tranfer to stakewallet
            } 
        if (total!=0) _transferStandard(sender, recipient, total);
    }

    function setnewWallet( address newrewardWallet,address newstakeWallet) external onlyOwner() {
        rewardWallet = newrewardWallet;
        stakeWallet= newstakeWallet;
    }

    //New Pancakeswap router version?
    //No problem, just change it!
    function setRouterAddress(address newRouter) public onlyOwner() {
        //Thank you FreezyEx
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    //stake
    function setAPRreward(uint256 apr) public onlyOwner {
        _basicapr =apr; 
    }

    function stake(uint256 amount) public  {
        require(_isBlock[msg.sender] != true, "This account have been lock.");
        require(amount > 0, "amount is <= 0");
        require(balanceOf(msg.sender) >= amount, "balance is <= amount");
        _tokenTransfer(msg.sender, address(this), amount) ;
        if (staked[msg.sender] > 0) {
        claim();
        }
        stakedFromTS[msg.sender] = block.timestamp;
        if (_isExcludedFromFee[msg.sender]) staked[msg.sender] += amount;
        else staked[msg.sender] += amount * (100 - _stakeFee) / 100 ;
    }

    function unstake(uint256 amount) public {
        require(_isBlock[msg.sender] != true, "This account have been lock.");
        require(amount > 0, "amount is <= 0");  
        require(staked[msg.sender] >= amount, "amount is > staked");
        claim();
        staked[msg.sender] -= amount;
        _tokenTransfer(address(this),msg.sender, amount) ;
    }

    function claim() public  {
        require(_isBlock[msg.sender] != true, "This account have been lock.");
        require(staked[msg.sender] > 0, "staked is <= 0");
        uint256 myapr=_basicapr;
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        if (0<secondsStaked && secondsStaked<2592000) myapr=_basicapr ;
            if(2592000<=secondsStaked && secondsStaked<7776000) myapr=_basicapr*12/10 ; else
                if(7776000<=secondsStaked && secondsStaked<15552000) myapr=_basicapr*15/10 ; else
                    if(15552000<=secondsStaked && secondsStaked<31536000) myapr=_basicapr*20/10 ; else
                    myapr=myapr*30/10;
        uint256 reward = staked[msg.sender] * secondsStaked / 3.154e7 * myapr /100;
        _transferStandard(address(rewardWallet),msg.sender, reward) ;
        stakedFromTS[msg.sender] = block.timestamp;
    }

//web3tokeninfo
    function TotalFee() public view  returns (uint256){
        return _previousBurnFee + _previousStakeFee + _previousLPFee;
    }

    function TotalBurn() public view  returns (uint256){
        return balanceOf(address(0))/10**18;
    }

    function BasicAPR() public view  returns (uint256){
        return _basicapr;
    }

    function TotalStakingAmount() public view  returns (uint256){
        return balanceOf(address(this))/10**18;
    }

    function CirculatingSupply() public view  returns (uint256){
        return (_total - balanceOf(address(0))  - balanceOf(address(stakeWallet)) - balanceOf(address(rewardWallet)) - balanceOf(address(this)) - balanceOf(owner()))/10**18;
        //total - burn -fee - staking - owner
    }

    function TotalSupply() public view  returns (uint256){
        return (_total - balanceOf(address(0)))/10**18;
        //total-burn
    }

    function MaxSupply() public pure  returns (uint256){
    return MAX/10**18 ;
    }

//web3accountinfo
    function YourStaked(address account) public view  returns (uint256){
        return staked[account] ;
    }

    function YourTime(address account) public view  returns (uint256){
        uint256 secondsStaked = block.timestamp - stakedFromTS[account];
        if (staked[account]==0) return  0; else return secondsStaked;
    }

    function YourAPR(address account) public view  returns (uint256){
        uint256 myapr;
        uint256 secondsStaked = block.timestamp - stakedFromTS[account];
        if (staked[account]==0) return 0   ;
            if (0<secondsStaked && secondsStaked<2592000)  myapr= _basicapr  ; else //0m-1m
                if(2592000<secondsStaked && secondsStaked<7776000)  myapr=_basicapr*12/10 ; else //1m-3m
                    if(7776000<secondsStaked && secondsStaked<15552000)  myapr=_basicapr *15/10  ; else//3m-6m
                        if(15552000<secondsStaked && secondsStaked<31536000)  myapr=_basicapr *20/10; else//6m -1y
                        myapr=_basicapr *30/10; // > 1y
                        return myapr;
    }

    function YourReward(address account) public view  returns (uint256){       
        uint256 myapr;
        uint256 secondsStaked = block.timestamp - stakedFromTS[account];
        if (staked[account]==0) return myapr=0  ;
        if (0<secondsStaked && secondsStaked<2592000)   myapr= _basicapr  ; else //0m-1m
            if(2592000<secondsStaked && secondsStaked<7776000)  myapr=_basicapr*12/10 ; else //1m-3m
                if(7776000<secondsStaked && secondsStaked<15552000)  myapr=_basicapr *15/10  ; else//3m-6m
                    if(15552000<secondsStaked && secondsStaked<31536000)  myapr=_basicapr *20/10; else//6m -1y
                        myapr=_basicapr *30/10; // > 1y
        uint256 myreward=staked[account] * secondsStaked / 3.154e7 * myapr /100;
        return (myreward);
    }

//web3shareholder
    function stakewallet() public view returns (address) {
        return stakeWallet;
    }

//forbscscan
        function TokenBasicInfor() public view  returns (string memory Name,string memory Symbol,uint8 Decimals,uint256 TotalBurnt,uint256 CirculatingSupplyy,uint256 TotalSupplyy,uint256 MaxSupplyy )
    {   
        return (_name , _symbol ,_decimals, balanceOf(address(0))/10**18, (_total - balanceOf(address(0))  - balanceOf(address(stakeWallet)) - balanceOf(address(rewardWallet))-balanceOf(address(this)) - balanceOf(owner()))/10**18 , (_total - balanceOf(address(0)))/10**18 , MAX/10**18) ;
    }

       function TokenFeesAndStaking() public view  returns ( uint256 Burnfee,uint256 StakeFee,uint256 LPFee,uint256 Totalfee,uint256 BasiccAPR, uint256 TotalStakingAmountt)
    {   
        return(_previousBurnFee,_previousStakeFee,_previousLPFee,_previousBurnFee+_previousStakeFee+_previousLPFee,_basicapr,balanceOf(address(this))/10**18);
    }

   function TokenYourInfo(address account) public view  returns (uint256 YourAccount,uint256 YourStaking,uint256 YourrAPR,uint256 YourStakingTimee,uint256 YourRewardd){       
        uint256 myapr;
        uint256 secondsStaked = block.timestamp - stakedFromTS[account];
        if (staked[account]==0) return(balanceOf(account)/10**18,0,0,0,0)   ;
        if (0<secondsStaked && secondsStaked<2592000)   myapr= _basicapr  ; else //0m-1m
            if(2592000<secondsStaked && secondsStaked<7776000)  myapr=_basicapr*12/10 ; else //1m-3m
                if(7776000<secondsStaked && secondsStaked<15552000)  myapr=_basicapr *15/10  ; else//3m-6m
                    if(15552000<secondsStaked && secondsStaked<31536000)  myapr=_basicapr *20/10; else//6m -1y
                        myapr=_basicapr *30/10; // > 1y
        uint256 myreward=staked[account] * secondsStaked / 3.154e7 * myapr /100;
        return (balanceOf(account)/10**18,staked[account]/10**18,myapr,secondsStaked,myreward/10**18);
    }

}