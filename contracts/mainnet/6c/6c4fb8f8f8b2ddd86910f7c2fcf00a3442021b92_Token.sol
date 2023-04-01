/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

pragma solidity 0.5.16;

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
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
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

  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? b : a;
  }

  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? a : b;
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

interface IPancakePair {
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

interface IPancakeRouter {
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

contract Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _baseCoin;
  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  uint256[] private _fee = [50, 50, 50, 100, 100, 100, 150, 150, 150, 150];
  uint256 private _feeMax = 150;
  address private _feeAddress;
  uint256 private _feeAmount;
  address private _nftAddress = 0x2688fF6B6784985CD1E564DC9628085940589810;
  uint256 private _nftFee = 100;
  uint256 private _burnFee = 100;

  struct FeeList{
    bool open;
    uint256 fee;
  }
  mapping (address => FeeList) public _feelist;
  mapping (address => bool) public _blacklist;

  mapping (address => address) public _shareAccount;
  mapping (address => bool) _shareAccountTop;
  uint256[] public _shareFee = [50, 30, 20];
  address public _shareAddress = 0x2688fF6B6784985CD1E564DC9628085940589810;

  IPancakeRouter _router;
  IPancakeFactory _factory;
  address public _pair;
  address public _pairUSDT;

  uint256 _rewardFee = 700;
  uint256 public _rewardDraw;
  uint256 public _rewardAmount;
  uint256 public _rewardMaxBlock = 28800;
  uint256 public _rewardPerShare;
  uint256[] public _rewardBlock = [block.number, block.number];
  mapping(address => uint256) public _rewardAccount;

  event RewardWithdraw(address account, uint256 amount);

  constructor() public {
    _name = "test BTG";
    _symbol = "test BTG";
    _decimals = 18;
    _totalSupply = 2100000 * 1e18;
    _baseCoin = 10 ** 15;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);

    _router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // 0x10ED43C718714eb63d5aA57B78B54704E256024E
    _factory = IPancakeFactory(_router.factory());
    _pairUSDT = address(IPancakePair(_factory.createPair(address(this), 0x55d398326f99059fF775485246999027B3197955)));
    _pair = address(IPancakePair(_factory.createPair(address(this), 0xeD6C4a4b73F5988912c6505BB8F3bfd4eC8e0B36)));
    _shareAccountTop[address(this)] = true;
    _shareAccountTop[0x000000000000000000000000000000000000dEaD] = true;
    setFeeList(msg.sender, true, 0);
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
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    if(account == address(this)) {
      return _balances[account].sub(_notRewardAmount());
    }

    return _balances[account].add(_getReward(account));
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
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BTG: transfer amount exceeds allowance")); 
    return true;
  }

  /**
   * @dev Set blacklist status
   */
  function setBlacklist(address sender, bool status) external onlyOwner {
    _blacklist[sender] = status;
  }

  /**
   * @dev Set the address of fee receipt.
   */
  function setNftAddress(address account, uint256 fee) external onlyOwner {
    _nftAddress = account;
    _nftFee = fee;
  }

  /**
   * @dev The cost of setting up the address
   */
  function setFeeList(address account, bool open, uint256 fee) public onlyOwner {
    _feelist[account] = FeeList({
      open: open,
      fee: fee
    });
  }

  /**
   * @dev Set Tax collection
   */
  function setFee(uint256[] calldata fee, uint256 feeMax) external onlyOwner {
    _fee = fee;
    _feeMax = feeMax;
  }

  /**
   * @dev Set push relationship dividend
   */
  function setShareFee(uint256[] calldata fee, address account) external onlyOwner {
    _shareFee = fee;
    _shareAddress = account;
  }

  /**
   * @dev Set Reward Fee
   */
  function setRewardFee(uint256 fee, uint256 max) external onlyOwner {
    _rewardMaxBlock = max;
    _rewardFee = fee;
  }

  /**
   * @dev Set Burn Fee
   */
  function setBurnFee(uint256 fee) external onlyOwner {
    _burnFee = fee;
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
    require(sender != address(0), "BTG: transfer from the zero address");
    require(recipient != address(0), "BTG: transfer to the zero address");
    require(!_blacklist[sender], "BTG: sender is on the blacklist");

    _updateReward();
    _withdrawReward(sender);
    _withdrawReward(recipient);
    _withdrawFee();
    _transferShare(sender, recipient, amount);

    _balances[sender] = _balances[sender].sub(amount, "BTG: transfer amount exceeds balance");

    uint256 amountFee = _transferFee(sender, recipient, amount);

    _updateRewardAmount();

    amount = amount.sub(amountFee);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /**
   * @dev Generate tax revenue
   */
  function _transferFee(address sender, address recipient, uint256 amount) internal returns(uint256 feeAmount) {
    if(sender != _pair && recipient != _pair && sender != _pairUSDT && recipient != _pairUSDT) {
      return 0;
    }
    uint256 fee = _fee[block.number % 10];
    uint256 feeMax = _feeMax - fee;
  
    if(_feelist[sender].open && _feelist[sender].fee < fee) {
      fee = _feelist[sender].fee;
      feeMax = 0;
    }
    if(_feelist[recipient].open && _feelist[recipient].fee < fee) {
      fee = _feelist[recipient].fee;
      feeMax = 0;
    }

    // Receive fee
    if(fee > 0) {
      feeAmount = amount.div(1000).mul(fee);
      uint256 nftAmount = feeAmount.div(1000).mul(_nftFee);
      _balances[_nftAddress] = _balances[_nftAddress].add(nftAmount);
      emit Transfer(sender, _nftAddress, nftAmount);

      uint256 burnAmount = feeAmount.div(1000).mul(_burnFee);
      _balances[0x000000000000000000000000000000000000dEaD] = _balances[0x000000000000000000000000000000000000dEaD].add(burnAmount);
      emit Transfer(sender, 0x000000000000000000000000000000000000dEaD, burnAmount);

      _transferShareFee(recipient, feeAmount);
      _addReward(sender, feeAmount.div(1000).mul(_rewardFee));

      if(feeMax > 0) {
        uint256 feeMaxAmount = amount.div(1000).mul(feeMax);
        _feeAddress = recipient;
        _feeAmount = feeMaxAmount;

        feeAmount = feeAmount.add(feeMaxAmount);
      }
    }
  }

  /**
   * @dev withdraw Fee
   */
  function _withdrawFee() internal {
    if(_feeAmount > 0) {
      address recipient = (_feeAddress == _pair || _feeAddress == _pairUSDT) ? _shareAddress : _feeAddress;
      _balances[recipient] = _balances[recipient].add(_feeAmount);
      emit Transfer(address(0), recipient, _feeAmount);
      _feeAmount = 0;
    }
  }

  /**
   * @dev Recommendation relationship
   */
  function _transferShare(address sender, address recipient, uint256 amount) internal {
    if(
      sender != recipient && 
      sender != _pair && 
      recipient != _pair && 
      sender != _pairUSDT && 
      recipient != _pairUSDT && 
      _shareAccount[recipient] == address(0) && 
      !_shareAccountTop[recipient] && 
      amount == 1 * 1e17
    ) {
      _shareAccount[recipient] = sender;
      
      if(!_shareAccountTop[sender] && _shareAccount[sender] == address(0)) {
        _shareAccountTop[sender] = true;
      }
    }
  }

  /**
   * @dev Push relationship dividend
   */
  function _transferShareFee(address account, uint256 amount) internal {
    if(amount == 0) {
      return;
    }
    uint256 fee;
    uint256 feeAmount;
    address shareAddress = _shareAccount[account];
    for(uint256 i; i < _shareFee.length; i++) {
      if(shareAddress != address(0)) {
        feeAmount = amount.div(1000).mul(_shareFee[i]);
        _balances[shareAddress] = _balances[shareAddress].add(feeAmount);
        emit Transfer(account, shareAddress, feeAmount);
      } else {
        fee += _shareFee[i];
      }
      shareAddress = _shareAccount[shareAddress];
    }

    if(fee > 0) {
      feeAmount = amount.div(1000).mul(fee);
      _balances[_shareAddress] = _balances[_shareAddress].add(feeAmount);
      emit Transfer(account, _shareAddress, feeAmount);
    }
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
    require(owner != address(0), "BTG: approve from the zero address");
    require(spender != address(0), "BTG: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Add reward and update block amount
   */
  function _addReward(address sender, uint256 amount) internal {
    if(amount > 0) {
      _balances[address(this)] = _balances[address(this)].add(amount);
      emit Transfer(sender, address(this), amount);
    }
  }

  /**
   * @dev Get the sum of the prices for the blocks
   */
  function _notRewardAmount() view internal returns(uint256 amount){
    if (block.number > _rewardBlock[0] && _rewardAmount > 0) {
      uint256 multiplier = block.number.min(_rewardBlock[1]).sub(_rewardBlock[0]);
      amount = multiplier.mul(_rewardAmount);
    }
  }

  /**
   * @dev update pool and price per share
   */
  function _updateReward() internal {
    _rewardDraw = _notRewardAmount();
    _rewardPerShare = _rewardPerShare.add(_cakeReward());
    _rewardBlock[0] = block.number;
  }

  /**
   * @dev update pool and price per share
   */
  function _updateRewardAmount() internal {
    if(_rewardDraw > 0) {
      _balances[address(this)] = _balances[address(this)].sub(_rewardDraw);
      emit Transfer(address(this), address(0), _rewardDraw);
    }
    

    _rewardBlock[1] = block.number + _rewardMaxBlock;
    _rewardAmount = _balances[address(this)].div(_rewardMaxBlock);
  }

  /**
   * @dev Figure out the price per share
   */
  function _cakeReward() public view returns(uint256 cake) {
    uint256 reward = _notRewardAmount();
    uint256 total = totalSupply().sub(_balances[_pair]).sub(_balances[_pairUSDT]).sub(_balances[address(this)]);
    if(total > 0 && reward > 0) {
      cake = reward.div(total.div(_baseCoin));
    }
  }

  /**
   * @dev Get rewards that the user has not claimed
   */
  function _getReward(address account) public view returns (uint256) {    
    if(account == _pair || account == _pairUSDT || account == address(this)) {
      return 0;
    }

    uint256 reward = _rewardPerShare.add(_cakeReward()).sub(_rewardAccount[account]);
    return _balances[account].div(_baseCoin).mul(reward);  
  }

  /**
   * @dev Receive the reward and record the price per share
   */
  function _withdrawReward(address account) internal {
    if (account != address(0)) {
      uint256 reward = _getReward(account);
      if (reward > 0) {
        _balances[account] = _balances[account].add(reward);
      }

      _rewardAccount[account] = _rewardPerShare;
    }
  }
}