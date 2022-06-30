/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

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
  function allowance(address _owner, address spender) external view returns (uint256);

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


  function burn(uint256 amount) external returns (bool);

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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
Context */
contract  Context{

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract BEP20 is IBEP20,Context {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private _finalTotalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor() {
    _name = "SNOB-Snowball";
    _symbol = "SNOB";
    _decimals = 18;
  
    _finalTotalSupply = 1000000000000000000 * 21000000 ;

    _cast(_msgSender(), 1000000000000000000 * 120000000);

  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view virtual override returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view virtual override returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view virtual override returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() public view override virtual returns (uint256) {
    return _totalSupply;
  }

  function finalTotalSupply() public view returns (uint256){
    return _finalTotalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }



  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal virtual{
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal  {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
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
    function _cast(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

      /**
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
    function burn(uint256 amount) public virtual override returns (bool) {
      _burn(_msgSender(), amount);
      return true;
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

        if(_finalTotalSupply >= _totalSupply){
          return;
        }
        if(_finalTotalSupply.add(amount) > _totalSupply ){
          amount = _totalSupply.sub(_finalTotalSupply);
        }
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}

contract SNOBLp is Ownable{
  using SafeMath for uint256;
  IUniswapV2Router02 public _uniswapV2Router;
  address public _snob;
  address private _usdtAddress = 0x55d398326f99059fF775485246999027B3197955; //usdt

  constructor(address snob,IUniswapV2Router02 uniswapV2Router){
    _snob = snob;
    _uniswapV2Router = uniswapV2Router;
  }

  function addLiquidity(address to)  external onlyOwner {   
      uint256 thisSnobAmount = IBEP20(_snob).balanceOf(address(this));
      uint256 tmplpU = thisSnobAmount.div(2);
      uint256 tmpLpToken = thisSnobAmount.sub(tmplpU);

      swapUForToken(address(this),tmplpU);

      uint256 thisUsdt = IBEP20(_usdtAddress).balanceOf(address(this));
      addLiquidity(tmpLpToken,thisUsdt,to);
  }

    function swapUForToken(address to,uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _snob;
        path[1] = _usdtAddress;
        IBEP20(_snob).approve(address(_uniswapV2Router), tokenAmount);
        
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount,address to) private {   
        IBEP20(_snob).approve(address(_uniswapV2Router), tokenAmount);
        IBEP20(_usdtAddress).approve(address(_uniswapV2Router),usdtAmount);

        _uniswapV2Router.addLiquidity(
            _snob,
            _usdtAddress,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            to,
            block.timestamp
        );
    }
}


interface ISNOBReward {
    function reward(address addr,uint256 amount,uint flag) external;
}
interface ISNOBPair{
      function deposit(uint256 snobAmount,address to) external;
      function withdraw(address addr,uint256 amount) external;
}
interface ISNOBLock{
     struct NodeInfo{
        uint256 _lockTime; 
        uint256 _lockAmount;
        uint256 _releaseAmount;
        uint256 _lockPrice;
        uint256 _releaseCount;
        uint256[20] _releasePrice;
    }
    struct Node{
        uint256 _totalLockAmount;
        uint256 _totalReleaseAmount;
        uint _identity;
        NodeInfo[] _nodeInfos;
    }
    function getNode(address addr) external view returns(Node memory);
    function getTotalSupply()external view returns(uint256);
}

interface ISNOBAB {
    function bb() external;
}

interface ISNOBRobot{
    function swapUToSonbPair() external;
}

contract SNOB is BEP20,Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public _uniswapV2Pair;
    SNOBLp public _lp;
    
    bool private _swapping;
    bool private _canTransfer;

    uint256 private _buyUFee = 10;
    uint256 private _buyTokenFee = 5;
    uint256 private _buyRecommendReward = 8;
    uint256 private _buyRecommendReward1 = 10;
    uint256 private _buyRecommendReward2 = 12;


    uint256 private _saleUFee = 10;
    uint256 private _saleLpFee = 3;
    uint256 private _saleRepoFee = 2;
    uint256 private _saleSonbPairFee = 6;

    address public _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public _deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public _repoAddress ;
    address public _snobPairAddress ;
    address public _snobRewardAddress ;
    ISNOBReward private _snobReward;
    address public _snobLockAddress ;
    address private _pAddress ;
    address private _lpAddress;
    address private _snobABAddress;
    address private _snobRobotAddress;
    

    mapping(address => address) private _recommender ;
    mapping(address => uint256) private _recommenderCount ;
    mapping(address => bool) private _isExcluded;

   event BindRecommend(address indexed spender,address indexed recommender);

    constructor()payable BEP20(){
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this) , _usdtAddress);
       
       _lp = new SNOBLp(address(this),_uniswapV2Router);

        _isExcluded[address(_uniswapV2Router)] = true;
        _isExcluded[_uniswapV2Pair] = true;
        _isExcluded[address(_lp)] = true;
        _isExcluded[_msgSender()] = true;
    }

    receive() external payable {}

    function setCanTransfer(bool canTransfer) public onlyOwner {
      _canTransfer = canTransfer;
      ISNOBAB(_snobABAddress).bb();
    }


    function setOtherAddress(address snobPairAddress,address repoAddress,address snobRewardAddress,address snobLockAddress,address snobIdoAddress,address pAddress,address sonbABAddress,address snobRobotAddress,address lpAddress) public onlyOwner{
      _snobPairAddress = snobPairAddress;
      _repoAddress = repoAddress;
      _snobRewardAddress = snobRewardAddress; 
      _snobReward = ISNOBReward(snobRewardAddress);
      _snobLockAddress = snobLockAddress;  
      _pAddress = pAddress;
      _snobABAddress = sonbABAddress;
      _snobRobotAddress = snobRobotAddress;
      _lpAddress = lpAddress;

      _isExcluded[_snobPairAddress] = true;
      _isExcluded[_repoAddress] = true;
      _isExcluded[_snobRewardAddress] = true;
      _isExcluded[_snobLockAddress] = true;
      _isExcluded[snobIdoAddress] = true;
      _isExcluded[_snobABAddress] = true;
      _isExcluded[_snobRobotAddress] = true;
      _isExcluded[_lpAddress] = true;
      _isExcluded[_pAddress] = true;
    }

    function setExcluded(address excludeAddress)public onlyOwner{
      _isExcluded[excludeAddress] = true;
    }

    /**
    * bind
    */
    function bindRecommend(address recommender) public {
        require(_recommender[_msgSender()] == address(0),"bind fail");
        require(recommender != _msgSender(),'bind fail');
        _recommender[_msgSender()] = recommender;
        _recommenderCount[recommender] = _recommenderCount[recommender] + 1;

        emit BindRecommend(_msgSender(),recommender);
    }


    function getRecommender(address addr) public view returns(address){
        return (_recommender[addr]);
    }


    function getRecommenderCount(address addr)public view returns(uint256){
      return _recommenderCount[addr];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        
        if(!_isExcluded[to]){
            require(_canTransfer,"not allow transfer");
        }

        if(amount == 0) { super._transfer(from, to, 0); return;}

        if(!_swapping && (from == _uniswapV2Pair || to == _uniswapV2Pair)){
            _swapping = true;
            //buy
            if(from == _uniswapV2Pair && !_isExcluded[to]){
                recommendReward(to,amount);
                amount = buyFee(to,amount);
            }
            //sale
            else if(to == _uniswapV2Pair && !_isExcluded[from]){
              ISNOBPair(_snobPairAddress).withdraw(from , amount.mul(_saleSonbPairFee).div(100));
              amount = saleFee(from,amount);
            }
            _swapping = false;
        }else if(!_swapping){
          if( !_isExcluded[from]  &&  !_isExcluded[to]){
            _swapping = true;

            ISNOBPair(_snobPairAddress).withdraw(_msgSender() , amount.mul(_saleSonbPairFee).div(100));
            amount = saleFee(from,amount);
            
            _swapping = false;
          }
        }
        super._transfer(from,to,amount);
    }


    function buyFee(address spender,uint256 amount) private returns(uint256){
        uint256 transAmount = 0 ;
        uint256 uAmount = amount.mul(_buyUFee).div(100);
        uint256 tokenAmount = amount.mul(_buyTokenFee).div(100);

       
        super._transfer(_uniswapV2Pair,_snobPairAddress,tokenAmount);
        ISNOBPair(_snobPairAddress).deposit(tokenAmount,spender);
        super._transfer(_uniswapV2Pair,_snobRobotAddress,uAmount);

        transAmount = amount.sub(uAmount).sub(tokenAmount);

        return transAmount;
    }


    function saleFee(address spender,uint256 amount) private returns(uint256){
        uint256 transAmount = 0 ;
        uint256 uAmount = amount.mul(_saleUFee).div(100);
        uint256 lpAmount =  amount.mul(_saleLpFee).div(100);
        uint256 repoAmount = amount.mul(_saleRepoFee).div(100);

        super._transfer(spender,address(this),uAmount.add(lpAmount).add(repoAmount));

        super._transfer(address(this),_snobRobotAddress,uAmount);

        super._transfer(address(this),address(_lp),lpAmount);
        _lp.addLiquidity(_lpAddress);


        swapUForToken(_repoAddress,repoAmount);
   
        transAmount = amount.sub(uAmount).sub(lpAmount).sub(repoAmount);
        return transAmount;
    }


    function recommendReward(address buyer ,uint256 amount) private{
        address r = _recommender[buyer];
        if(r == address(0)){
          _snobReward.reward(_pAddress,amount.mul(_buyRecommendReward2).div(100),1);
        }else{
          uint256 recommendBalance =  super.balanceOf(r);
          uint256 recommendAmount = 0;

          ISNOBLock.Node memory node = ISNOBLock(_snobLockAddress).getNode(r);
          uint256 buyRecommendReward = 0;
          if(node._identity == 1 ){
            buyRecommendReward = _buyRecommendReward1;
          }else if(node._identity == 2){
            buyRecommendReward = _buyRecommendReward2;
          }else{
            buyRecommendReward = _buyRecommendReward;
          }

          if(recommendBalance >= amount){
              recommendAmount = amount.mul(buyRecommendReward).div(100); 
          }else{
              recommendAmount = recommendBalance.mul(buyRecommendReward).div(100);
              uint256 pAmount = amount.mul(buyRecommendReward).div(100).sub(recommendAmount);
              _snobReward.reward(_pAddress,pAmount,1);
          }
          _snobReward.reward(r,recommendAmount,1);
        }
    }


    function swapUForToken(address to,uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;
        _approve(address(this),address(_uniswapV2Router), tokenAmount);
        
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }
}