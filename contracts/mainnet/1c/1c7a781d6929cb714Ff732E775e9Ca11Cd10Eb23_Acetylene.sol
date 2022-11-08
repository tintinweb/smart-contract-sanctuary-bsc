/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

pragma solidity ^0.8.9;

// SPDX-License-Identifier: Unlicensed
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
abstract contract Context {
  //function _msgSender() internal view virtual returns (address payable) {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

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
}

interface IUniswapV2Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

interface PancakePair {
  function sync() external;
}

contract Acetylene is Context, IBEP20 {
  using SafeMath for uint256;

  address public pancakePair;

  IUniswapV2Router02 public pancakeRouter;

  mapping(address => uint256) private _balances;
  mapping(address => bool) public _isPair;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply = 21000000 * 10**18;
  uint8 private _decimals = 18;
  string private _symbol = "ACE";
  string private _name = "Acetylene";

  uint256 public votingThreshold = (_totalSupply * 5) / 1000;

  uint256 public liquidityPercentage = 5;
  uint256 public lastPairInteraction;
  uint256 public numberOfHoursToSleep = 48;
  uint256 private _deployedAt;

  address public DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

  event SleepTimerTimestamp(uint256 indexed _timestamp);
  event pairVoteTimestamp(uint256 indexed _timestamp);

  constructor() {
    _balances[msg.sender] = _totalSupply;

    IUniswapV2Router02 _pancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // Create a uniswap pair for this new token
    pancakePair = IUniswapV2Factory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
    lastPairInteraction = block.timestamp;

    _isPair[pancakePair] = true;

    // set the rest of the contract variables
    pancakeRouter = _pancakeRouter;

    _deployedAt = block.timestamp;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external pure returns (address) {
    return address(0);
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
  function balanceOf(address account) public view returns (uint256 _currentBalance) {
    return _balances[account];
  }

  uint256 multiplier = 999**8;
  uint256 divider = 1000**8;

  function _updatedPairBalance(uint256 oldBalance) private returns (uint256) {
    uint256 balanceBefore = oldBalance;
    uint256 timePassed = block.timestamp - lastPairInteraction;
    uint256 power = (timePassed).div(3600); //3600: num of secs in 1 hour
    power = power <= numberOfHoursToSleep ? power : numberOfHoursToSleep;

    lastPairInteraction = power > 0 ? block.timestamp : lastPairInteraction;

    while (power > 8) {
      oldBalance = (oldBalance.mul(multiplier)).div(divider);
      power -= 8;
    }
    oldBalance = (oldBalance.mul(999**power)).div(1000**power);

    uint256 _toBurn = balanceBefore.sub(oldBalance);
    if (_toBurn > 0) {
      _balances[DEAD_ADDRESS] += _toBurn;
      emit Transfer(pancakePair, DEAD_ADDRESS, _toBurn);
    }

    return oldBalance;
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
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
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

  function _takeLiquidity(address sender, uint256 tLiquidity) private {
    _balances[pancakePair] = _balances[pancakePair].add(tLiquidity);
    emit Transfer(sender, pancakePair, tLiquidity);
  }

  function claimVotingBalance(uint256 _timestamp, uint256 amount) external {
    require(amount > 0, "amount should be > 0");
    require(balanceSubmittedForVoting[msg.sender][_timestamp] >= amount, "requested amount more than voted amount");
    require(block.timestamp - _timestamp > 3600, "can only withdraw after round end");

    _balances[msg.sender] = _balances[msg.sender] + amount;
    balanceSubmittedForVoting[msg.sender][_timestamp] = balanceSubmittedForVoting[msg.sender][_timestamp].sub(amount);
    _balances[address(this)] = _balances[address(this)].sub(amount);
    require(_balances[msg.sender] <= getMaximumBalance(), "Balance exceeds threshold");

    emit Transfer(address(this), msg.sender, amount);
  }

  /**
   * @dev to change numberOfHoursToSleep
   *
   * Requirements:
   *
   * - 5 addresses with maximumBalance as balance should vote for the same value within 1 hour
   * - timer will start with the first vote
   * -
   */
  mapping(address => mapping(uint256 => uint256)) public balanceSubmittedForVoting;
  mapping(uint256 => mapping(address => bool)) private timeStamp_address_voted;
  mapping(uint256 => mapping(uint256 => uint256)) private value_to_weight;

  function voteForSleepTimer(uint256 timestamp, uint256 _value) external returns (uint256) {
    require(block.timestamp != timestamp, "sorry no bots");
    require(!timeStamp_address_voted[timestamp][msg.sender] || timestamp == 0, "Already voted!");
    require(_balances[msg.sender] >= votingThreshold, "non enough balance to vote");
    require(_value != numberOfHoursToSleep, "can't vote for same existing value");
    require(timestamp == 0 || (block.timestamp).sub(timestamp) <= 3600, "voting session closed");

    uint256 _timestamp = timestamp == 0 ? block.timestamp : timestamp;
    timeStamp_address_voted[_timestamp][msg.sender] = true;
    value_to_weight[_timestamp][_value] = value_to_weight[_timestamp][_value] + 1;

    _balances[msg.sender] = _balances[msg.sender] - votingThreshold;
    balanceSubmittedForVoting[msg.sender][timestamp] = balanceSubmittedForVoting[msg.sender][timestamp] + votingThreshold;
    _balances[address(this)] = _balances[address(this)] + votingThreshold;
    emit Transfer(msg.sender, address(this), votingThreshold);

    if (value_to_weight[_timestamp][_value] > 4) {
      numberOfHoursToSleep = _value;
      return 0;
    }

    emit SleepTimerTimestamp(_timestamp);
    return _timestamp;
  }

  /**
   * @dev to add a pair
   *
   * Requirements:
   *
   * - 5 addresses with maximumBalance as balance should vote for the same value within 1 hour
   * - timer will start with the first vote
   * -
   */
  mapping(uint256 => mapping(address => bool)) private pair_timeStamp_address_voted;
  mapping(uint256 => mapping(address => uint256)) private pair_value_to_weight;

  function voteForPair(uint256 timestamp, address _value) external returns (uint256) {
    require(block.timestamp != timestamp, "sorry no bots");
    require(!pair_timeStamp_address_voted[timestamp][msg.sender] || timestamp == 0, "Already voted!");
    require(_balances[msg.sender] >= votingThreshold, "non enough balance to vote");
    require(!_isPair[_value], "address already declared as pair");
    require(timestamp == 0 || (block.timestamp).sub(timestamp) <= 3600, "voting session closed");

    uint256 _timestamp = timestamp == 0 ? block.timestamp : timestamp;
    pair_timeStamp_address_voted[_timestamp][msg.sender] = true;
    pair_value_to_weight[_timestamp][_value] = pair_value_to_weight[_timestamp][_value] + 1;

    _balances[msg.sender] = _balances[msg.sender] - votingThreshold;
    balanceSubmittedForVoting[msg.sender][timestamp] = balanceSubmittedForVoting[msg.sender][timestamp] + votingThreshold;
    _balances[address(this)] = _balances[address(this)] + votingThreshold;
    emit Transfer(msg.sender, address(this), votingThreshold);

    if (pair_value_to_weight[_timestamp][_value] > 4) {
      _isPair[_value] = true;
      return 0;
    }

    emit pairVoteTimestamp(_timestamp);
    return _timestamp;
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

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    uint256 tLiquidity;

    if (sender == pancakePair || recipient == pancakePair) {
      tLiquidity = amount.mul(liquidityPercentage).div(100);
    }
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount.sub(tLiquidity));
    require(_isPair[recipient] || _balances[recipient] <= getMaximumBalance(), "Balance exceeds threshold");

    _takeLiquidity(sender, tLiquidity);
    emit Transfer(sender, recipient, amount.sub(tLiquidity));
  }

  function getMaximumBalance() public view returns (uint256) {
    if (block.timestamp - _deployedAt >= 1209600) return _totalSupply;
    if (block.timestamp - _deployedAt >= 604800) return (_totalSupply * 15) / 1000;
    else return _totalSupply / 100;
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
    emit Transfer(account, address(0), amount);
  }

  function updatePrice() external {
    require(block.timestamp - lastPairInteraction >= 3600, "One execution per hour");
    uint256 _pancakeBalance = _balances[pancakePair];
    _balances[pancakePair] = _updatedPairBalance(_pancakeBalance);
    PancakePair(pancakePair).sync();
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
  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal {
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
}