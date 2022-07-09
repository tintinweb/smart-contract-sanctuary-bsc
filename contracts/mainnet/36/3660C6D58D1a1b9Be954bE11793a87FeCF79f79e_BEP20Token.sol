// SPDX-License-Identifier: Unlicensed
import "./VRFConsumerBaseV2.sol";
import "./VRFCoordinatorV2Interface.sol";

pragma solidity ^0.8.14;

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
 */
contract Context {
  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
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

/*
* PancakeSwap interfaces
* We use uniswap libraries here but pancakeswap is pretty much the same, so we get all the functions we need from uniswap, but importing pancakeswap is broken right now
* which is a fuck up on their part, it's sad that such a huge dex copies another huge dex nearly 1 to 1 and they still manage to fuck something up 
*/

interface IPancakeFactory {
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

interface IPancakeRouter01 {
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

// File: contracts\interfaces\IPancakeRouter02.sol

interface IPancakeRouter02 is IPancakeRouter01 {
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

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



contract BEP20Token is Context, IBEP20, Ownable, VRFConsumerBaseV2 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  bytes32 internal keyHash;

  uint burnFee = 1;
  uint reflectionFee = 2;
  uint lotteryPoolFee = 2;
  uint liquidityFee = 5;

  bool isLaunched = false; // will be set to true after we launch

  uint64 s_subscriptionId;
  address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
  bytes32 s_keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;
  uint32 callbackGasLimit = 500000; 
  uint16 requestConfirmations = 3;
  VRFCoordinatorV2Interface COORDINATOR;
  address s_owner;
  uint lotteryDrawTime = 1657558800; // time to draw the first lottery 

  // Reflection variables:
  mapping (address => uint256) private _totalReflectionsOnLastReflection; // amount of total reflections on the last reflection of funds from totalreflections to balance
  uint256 totalReflections;
  uint256 private _totalSupplyWithoutExcluded = 7777777777 * (10 ** 9); // initially it's same as total supply
  mapping (address => bool) private _isExcluded;
  uint256 transferredRewardsForBalance; 

  uint256 liquidityFeeTotal; // funds from fees waiting to be added to the liquidity pool
  bool inSwap; // checks if the contract is right now swapping 
  event SwappedAndAddedLiquidity(uint256 tokensSwapped, uint256 bnbRecieved, uint256 tokensInLiquidity);

  // goes into variables:
  IPancakeRouter02 public immutable pancakeRouter;
  address public immutable pancakePair;

  modifier lockTheSwap {
    inSwap = true;
    _;
    inSwap = false;
  }

  constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
    _name = "Fortuna";
    _symbol = "LUCK";
    _decimals = 9;
    _totalSupply = 7777777777 * (10 ** 9); // 7.7 billion
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);

    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;

    IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // we set the router address to pancakeswap's
    pancakePair = IPancakeFactory(_pancakeRouter.factory()) // to avoid bugs we use uniswap interfaces, but to avoid confusion we change the naming here to pancakeswap
    // same as WETH is actually WBNB here, but we can't change this
      .createPair(address(this), _pancakeRouter.WETH()); // create a pair for this token: BEP20 <-> WBNB
    pancakeRouter = _pancakeRouter;
  }

   /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) public override view returns (uint256) {
    if (_isExcluded[account]) return _balances[account];
    return _balances[account].add(totalReflections.mul(_balances[account]).div(_totalSupplyWithoutExcluded)).sub(_totalReflectionsOnLastReflection[account].mul(_balances[account]).div(_totalSupplyWithoutExcluded));
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
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
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
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
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
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
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount >= 1000 * (10 ** 9)); // this is to discourage people from transacting every few minutes just to get reflections on thier reflections
    if (sender != owner()) {
      require(amount <= 37777777 * (10 ** 9)); // require that one transnaction is less than around 0.5% of the total supply
    }
    if (lotteryDrawTime < block.timestamp) { // initiate the draw if a transaction happens over two days after last draw 
      requestRandomNumber();
      lotteryDrawTime = block.timestamp.add(172800); // leap seconds don't matter as we don't need to be exactly precise here, thus it is sufficient to measure time using block.timestamp, here we add two days until the next draw
    }
    if (recipient == address(this)) { // if the sender is entering the lottery
      enterThroughTransfer(amount);
    }
    else {
      uint256 originalAmount = amount;
      amount = amount.mul(9).div(10); // take the fee, 2% will go for reflection, 2% for lottery pool, 1% will be left untouched (burned basically) and 5% for liquidity pool
      /*
      reflection rewards are transferred back to the main balance on a transaction, you don't get reflections on your reflections until you transact. With the 2% of each
      transaction being reflected, it starts to make slight difference to get reflections on reflections when you hold over 0.1% of the total supply and the whole 
      supply of the token gets moved, but then rewards you make on reflections on reflections will be less than the gas fees you spend on the transaction, so the problem
      with users transacting to get reflections on reflections gaining unfair advantage naturally resolves itself.
      */
      if (_isExcluded[sender]) {
        _totalSupplyWithoutExcluded = _totalSupplyWithoutExcluded.add(originalAmount);
      }
      else {
        _totalReflectionsOnLastReflection[sender] = totalReflections;
        _balances[sender] = _balances[sender].add(totalReflections.mul(_balances[sender]).div(_totalSupplyWithoutExcluded)).sub(_totalReflectionsOnLastReflection[sender].mul(_balances[sender]).div(_totalSupplyWithoutExcluded)); 
      }
      if (_isExcluded[recipient]) {
        _totalSupplyWithoutExcluded = _totalSupplyWithoutExcluded.sub(amount);
      }
      else {
        _totalReflectionsOnLastReflection[recipient] = totalReflections;
        _balances[recipient] = _balances[recipient].add(totalReflections.mul(_balances[recipient]).div(_totalSupplyWithoutExcluded)).sub(_totalReflectionsOnLastReflection[recipient].mul(_balances[recipient]).div(_totalSupplyWithoutExcluded)); 
      }
      _balances[address(this)] = _balances[address(this)].add(originalAmount.div(50)); // add 2% of the amount to the lottery pool
      _totalSupplyWithoutExcluded = _totalSupplyWithoutExcluded.sub(originalAmount.div(10)); // make sure that the whole fee gets excluded from the supply without reflections
      totalReflections = totalReflections.add(originalAmount.div(50)); // reflect 2% of the amount
      liquidityFeeTotal = liquidityFeeTotal.add(originalAmount.div(20)); // add 5% of the amount to the liquidity pool
      if (liquidityFeeTotal > 7777777 * (10 ** 9)) {
        if (!lotteryClosed) {
          if (isLaunched) {
            if (!inSwap) {
              swapAndAddLiquidity(liquidityFeeTotal);
            }
          }
        }
      }
      _balances[sender] = _balances[sender].sub(originalAmount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }
  }

  function _transferWithoutFee(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    // check only sender because contract address is always excluded
    if (!_isExcluded[sender]) {
      _totalReflectionsOnLastReflection[sender] = totalReflections;
      _balances[sender] = _balances[sender].add(totalReflections.mul(_balances[sender]).div(_totalSupplyWithoutExcluded)).sub(_totalReflectionsOnLastReflection[sender].mul(_balances[sender]).div(_totalSupplyWithoutExcluded)); 
      _totalSupplyWithoutExcluded = _totalSupplyWithoutExcluded.sub(amount);
    }

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _transferWinningsWithoutFee(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    // check only recipient because contract address is always excluded
    if (!_isExcluded[recipient]) {
      _totalReflectionsOnLastReflection[recipient] = totalReflections;
      _balances[recipient] = _balances[recipient].add(totalReflections.mul(_balances[recipient]).div(_totalSupplyWithoutExcluded)).sub(_totalReflectionsOnLastReflection[recipient].mul(_balances[recipient]).div(_totalSupplyWithoutExcluded)); 
      _totalSupplyWithoutExcluded = _totalSupplyWithoutExcluded.add(amount);
    }

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** 
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    _totalSupplyWithoutExcluded = _totalSupplyWithoutExcluded.sub(amount);
    emit Transfer(account, address(0), amount);
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
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }

  function launched() public onlyOwner {
    isLaunched = true;
  }

  /**
  Starting with the lottery part
  */

  mapping (address => uint256) p_ticketAmount; // Pitfall: the mapping is referencing to the ticketsArray, each player is assigned an ID not their ticket amount here
  mapping (uint256 => address) p_ids; // Same mapping as p_ticketAmount but flipped
  uint256[] ticketsArray;
  uint256 totalTicketAmount;
  uint256 public lotteryId = 1;
  uint256 playerId;
  uint256 playersAmount;
  uint256 randomNumber;
  uint256 basicRandomNumber;
  bool lotteryClosed;
  uint256[] public s_randomWords;
  uint256 public s_requestId;
  uint32 numWords;
  
  event RequestedRandomNumber(uint indexed requestId);

  function requestRandomNumber() internal returns (uint256 requestId) {
    if (balanceOf(address(this)) > 77777777 * (10 ** 9)) {
      numWords = uint32(balanceOf(address(this)).div(7777777 * (10 ** 9)) - 8); // get the number of random numbers to get for the different winners if the pool is over 1% of the total supply
      // notice: since the max number of random numbers we can request per one request is 500, this part of code will revert after over 50.8(9)% of the total supply is in the pool,
      // but it's too much for one draw and this won't likely happen ever. We implement a fix though by not selecting more than 500 winners and leave the rest of money for next lottery. 
      // This situation is purely hypothetical and it is very unlikely it will happen
      if (numWords >= 500) {
        numWords = 500;
      }
    }
    else {
      numWords = 1;
    }
    lotteryClosed = true;
    requestId = COORDINATOR.requestRandomWords(
      s_keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
    emit RequestedRandomNumber(requestId);
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
    s_randomWords = randomWords;
  }

  function changeCallBackGasLimit(uint32 callBackGas) public onlyOwner {
    callbackGasLimit = callBackGas;
  }

  function enterThroughTransfer(uint256 transactionAmount) internal { // This function is for normal entering through transfer as per buying tickets guide on our website
    require(!lotteryClosed);
    _transferWithoutFee(msg.sender, address(this), transactionAmount); // transfer the ticket amount to the smart contract's balance (1 ticket = 1000 LUCK), no fee on lottery tickets
    totalTicketAmount = totalTicketAmount.add(transactionAmount.div(1000 * (10 ** 9))); 
    if (p_ticketAmount[msg.sender] != 0) { // check if player previously had any tickets by checking if entry in mapping with the particular player isn't default
      playerId = p_ticketAmount[msg.sender];
      ticketsArray[playerId] = ticketsArray[playerId].add(transactionAmount.div(1000 * (10 ** 9))); // assign the tickets amount to the player's address 
    }
    else {
      p_ticketAmount[msg.sender] = playersAmount;
      p_ids[playersAmount] = msg.sender;
      ticketsArray.push(transactionAmount.div(1000 * (10 ** 9))); 
      playersAmount++;
    }
  }

  function enter(uint256 ticketAmount) public payable { // This function is for entering directly calling the enter function, mostly reserved for the web3 app which we will develop in Phase 2
    require(!lotteryClosed);
    require(ticketAmount != 0);
    _transferWithoutFee(msg.sender, address(this), ticketAmount.mul(1000 * (10 ** 9))); // transfer the ticket amount to the smart contract's escrow (1 ticket = 1000 LUCK), no fee on lottery tickets
    totalTicketAmount = totalTicketAmount.add(ticketAmount); 
    if (p_ticketAmount[msg.sender] != 0) { // check if player previously had any tickets by checking if entry in mapping with the particular player isn't default
      playerId = p_ticketAmount[msg.sender];
      ticketsArray[playerId] = ticketsArray[playerId].add(ticketAmount); // assign the tickets amount to the player's address 
    }
    else {
      p_ticketAmount[msg.sender] = playersAmount;
      p_ids[playersAmount] = msg.sender;
      ticketsArray.push(ticketAmount); 
      playersAmount++;
    }
  }

  function weightedRandom(uint256 randomWordNumber) internal returns (uint256) {
    randomNumber = s_randomWords[randomWordNumber].mod(totalTicketAmount); // get the random number
    for (uint256 i = 0; i < playersAmount; i++) {
      if (randomNumber < ticketsArray[i]) {
        return i; // return the location at which the player's address is 
      }
      randomNumber -= ticketsArray[i];
    }
    return 0; // The algorithm does not return the winning ticket if the winning ticket is the first one purchased. If it goes through the whole loop
              // and doesn't select anybody, it means the winning ticket is the first one purchased so we return the ID of the first ticket.
  }
  
  function draw() public { // anyone can draw the lottery if they want, but i will be always there to draw it in case nobody does it.
    require(lotteryClosed);
    require(s_randomWords[0] != 0); // require that we already got the values of the random number back 
    address winner = p_ids[weightedRandom(0)];
    if (balanceOf(address(this)) > 77777777 * (10 ** 9)) { // if the amount is greater than roughly 1% of the total supply, one winner hits jackpot and rest is distributed between other people
      _transferWinningsWithoutFee(address(this), winner, 77777777 * (10 ** 9)); // give the main award
      _transferWinningsWithoutFee(address(this), p_ids[weightedRandom(1)], balanceOf(address(this)).mod(7777777 * (10 ** 9))); // give the extra award
      for (uint256 i = 2; i < numWords; i++) {
        _transferWinningsWithoutFee(address(this), p_ids[weightedRandom(i)], 7777777 * (10 ** 9)); // give all secondary awards
      }
    }
    else {
      _transferWinningsWithoutFee(address(this), winner, balanceOf(address(this))); // winnings are not taxed 
    }
    for (uint256 i = 0; i < playersAmount; i++) {
      delete p_ticketAmount[p_ids[i]]; // delete the mapping entries to make place for the new lottery
      delete p_ids[i];
    }
    delete ticketsArray; // delete the array with ticket weights
    delete totalTicketAmount; // delete other variables related to one episode of lottery
    delete playersAmount;
    delete s_randomWords;
    lotteryClosed = false;
  }

  function getLotteryPool() public view returns (uint256) {
    return _balances[address(this)]; // we will multiply the ticket amount by 1000 to get our lottery pool in our web3 app
  }

  function getNextLotteryTime() public view returns (uint256) {
    return lotteryDrawTime;
  }

  function revertLottery() public onlyOwner { // this function is to make sure that we don't get stuck in a forever loop of lotteries when something with Chainlink VRF fails. The function returns everyone the tokens they purchased tickets with.
    for (uint i = 0; i < playersAmount; i++) {
      _balances[p_ids[i]] = _balances[p_ids[i]].add(ticketsArray[i].mul(1000 * (10 ** 9)));
      delete p_ticketAmount[p_ids[i]]; // delete the mapping entries to make place for the new lottery
      delete p_ids[i];
    }
    delete ticketsArray; // delete the array with ticket weights
    delete totalTicketAmount; // delete other variables related to one episode of lottery
    delete playersAmount;
    delete s_randomWords;
    lotteryClosed = false;
  }

  /**
  Reflection functionality
  Most of it is implemented upwards, check _transfer() and balanceOf()
  */

  function isExcluded(address account) public view returns (bool) {
    return _isExcluded[account];
  }

  function excludeAccount(address account) public onlyOwner returns (bool) {
    require(!_isExcluded[account], "Account is already excluded");
    _isExcluded[account] = true;
    return true;
  }

  // this function treats the included in reward as if they just got their rewards reflected back to their actual balance, but instead of them going to thier
  // actual balance, they get back to the total reflections pool to avoid including a whale lowering the rate of rewards for every user. The included user again
  // must start collecting their reflections from scratch, but reflections that he would have gained get distributed between all other users.
  function includeInReward(address account) public onlyOwner {
    require(_isExcluded[account]);
    totalReflections = _balances[account].add(totalReflections.mul(_balances[account]).div(_totalSupplyWithoutExcluded)).sub(_totalReflectionsOnLastReflection[account].mul(_balances[account]).div(_totalSupplyWithoutExcluded)); 
    _totalReflectionsOnLastReflection[account] = totalReflections;
    _isExcluded[account] = false;
  }

  /**
  Automated Liquidity Acquisition and PancakeSwap 
  */
  receive() external payable {}

  function swapAndAddLiquidity(uint256 liquidityBalance) private lockTheSwap {
    uint256 tokenToBeLeft = liquidityBalance.div(2); 
    uint256 tokenToBeSold = liquidityBalance.sub(tokenToBeLeft);

    uint256 contractBalance = address(this).balance; // capture contract's balance to make sure that only what gets swapped here gets added to LP

    _balances[address(this)] = _balances[address(this)].add(liquidityBalance); // add all the liquidity balance to the smart contract's balance. 
    // We make sure that lottery is not currently being drawn while this happens so that the winner of the lottery will not additionally get this. 
    swapTokensForBNB(tokenToBeSold);

    uint256 BNBFromSwap = address(this).balance.sub(contractBalance); // how much BNB have we recieved 

    addLiquidity(tokenToBeLeft, BNBFromSwap); // adds liquidity

    emit SwappedAndAddedLiquidity(tokenToBeLeft, BNBFromSwap, tokenToBeSold);
  }

  function swapTokensForBNB(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = pancakeRouter.WETH();

    _approve(address(this), address(pancakeRouter), tokenAmount); // approve pancakeswap to swap our tokens
      
    // swap the tokens, the fee will be taken as to ensure trustlessness there is no function to exclude from fee. 50% will anyways back to the liquidity amount, and rest will reward users
    pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp); 
  }

  function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
    _approve(address(this), address(pancakeRouter), tokenAmount);

    pancakeRouter.addLiquidityETH{value: bnbAmount}(
      address(this),
      tokenAmount,
      0, // slippage is unavoidable
      0, // same here
      address(this),
      block.timestamp
    );
  }
}