/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

/**
 *Submitted for verification at BscScan.com on 2021-05-14
*/

// File: contracts/libs/zeppelin/token/BEP20/IBEP20.sol

pragma solidity 0.4.25;

contract IBEP20 {
    function totalSupply() public view returns (uint256);
    function decimals() public view returns (uint8);
    function symbol() public view returns (string memory);
    function name() public view returns (string memory);
    function balanceOf(address account) public view returns (uint256);
    function transfer(address recipient, uint256 amount) public returns (bool);
    function allowance(address _owner, address spender) public view returns (uint256);
    function approve(address spender, uint256 amount) public returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/libs/zeppelin/math/SafeMath.sol

pragma solidity 0.4.25;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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

// File: contracts/libs/goldpegas/Context.sol

pragma solidity 0.4.25;

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
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/KARGold.sol

pragma solidity 0.4.25;

contract TokenAuth is Context {

  address internal owner;
  mapping (address => bool) public farmAddresses;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

  constructor(
    address _owner
  ) internal {
    owner = _owner;
  }

  modifier onlyOwner() {
    require(isOwner(), 'onlyOwner');
    _;
  }

  modifier onlyFarmContract() {
    require(isOwner() || isFarmContract(), 'Ownable: invalid caller');
    _;
  }

  function _transferOwnership(address _newOwner) onlyOwner internal {
    require(_newOwner != address(0), 'Ownable: invalid new owner');
    owner = _newOwner;
    emit OwnershipTransferred(_msgSender(), _newOwner);
  }

  function setFarmAddress(address _farmAddress, bool _status) public onlyOwner {
    require(_farmAddress != address(0), 'Ownable: farm address is the zero address');
    farmAddresses[_farmAddress] = _status;
  }

  function isOwner() public view returns (bool) {
    return _msgSender() == owner;
  }

  function isFarmContract() public view returns (bool) {
    return farmAddresses[_msgSender()];
  }
}

contract GOLDPEGASTOKEN is IBEP20, TokenAuth {
  using SafeMath for uint256;

  string public constant _name = 'TESTKAR';
  string public constant _symbol = 'TKAR';
  uint8 public constant _decimals = 18;
  uint256 public _totalSupply = 700e6 * (10 ** uint256(_decimals));
  uint256 public constant airdropAllocation = 3e6 * (10 ** uint256(_decimals));
  uint256 public constant farmingAllocation = 645e6 * (10 ** uint256(_decimals));
  uint256 public constant liquidityPoolAllocation = 7e6 * (10 ** uint256(_decimals));
  uint256 public constant privateSaleAllocation = 35e6 * (10 ** uint256(_decimals));
  uint256 public constant stakingAllocation = 10e6 * (10 ** uint256(_decimals));

  uint private farmingReleased = 0;

  bool releaseAirdrop;
  bool releaseLiquidityPool;
  bool releasePrivateSale;
  bool releaseStaking;

  mapping (address => uint256) internal _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  mapping (address => bool) lock;

  constructor() public TokenAuth(msg.sender) {
    _balances[address(this)] = _totalSupply;
    emit Transfer(address(0), address(this), _totalSupply);
  }

  function releaseAirdropAllocation(address _contract) public onlyOwner {
    require(!releaseAirdrop, 'Airdrop Allocation had released!!!');
    releaseAirdrop = true;
    _transfer(address(this), _contract, airdropAllocation);
  }

  function releaseFarmAllocation(address _farmerAddress, uint256 _amount) public onlyFarmContract {
    require(farmingReleased.add(_amount) <= farmingAllocation, 'Max farming allocation had released!!!');
    _transfer(address(this), _farmerAddress, _amount);
    farmingReleased = farmingReleased.add(_amount);
  }

  function releaseLiquidityPoolAllocation(address _contract) public onlyOwner {
    require(!releaseLiquidityPool, 'LiquidityPool Allocation had released!!!');
    releaseLiquidityPool = true;
    _transfer(address(this), _contract, liquidityPoolAllocation);
  }

  function releasePrivateSaleAllocation(address _contract) public onlyOwner {
    require(!releasePrivateSale, 'Private sale Allocation had released!!!');
    releasePrivateSale = true;
    _transfer(address(this), _contract, privateSaleAllocation);
  }

  function releaseStakingAllocation(address _contract) public onlyOwner {
    require(!releaseStaking, 'Staking Allocation had released!!!');
    releaseStaking = true;
    _transfer(address(this), _contract, stakingAllocation);
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function totalSupply() public view returns (uint) {
    return _totalSupply;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Gets the balance of the specified address.
   * @param owner The address to query the balance of.
   * @return A uint256 representing the amount owned by the passed adfunction transferdress.
   */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  /**
   * @dev Transfer token to a specified address.
   * @param to The address to transfer to.
   * @param value The amount to be transferred.
   */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    _approve(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another.
   * Note that while this function emits an Approval event, this is not required as per the specification,
   * and other compliant implementations may not emit the event.
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    _transfer(from, to, value);
    _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when _allowed[msg.sender][spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * Emits an Approval event.
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * Emits an Approval event.
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
    return true;
  }

  /**
   * @dev Transfer token for a specified addresses.
   * @param from The address to transfer from.
   * @param to The address to transfer to.
   * @param value The amount to be transferred.
   */
  function _transfer(address from, address to, uint256 value) internal {
    require(!lock[from], 'You can not do this at the moment');
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    if (to == address(0)) {
      _totalSupply = _totalSupply.sub(value);
    }
    emit Transfer(from, to, value);
  }

  /**
   * @dev Approve an address to spend another addresses' tokens.
   * @param owner The address that owns the tokens.
   * @param spender The address that will spend the tokens.
   * @param value The number of tokens that can be spent.
   */
  function _approve(address owner, address spender, uint256 value) internal {
    require(spender != address(0));
    require(owner != address(0));

    _allowed[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  function burn(uint256 _amount) external {
    _balances[msg.sender] = _balances[msg.sender].sub(_amount);
    _totalSupply = _totalSupply.sub(_amount);
    emit Transfer(msg.sender, address(0), _amount);
  }

  function updateLockStatus(address _address, bool locked) onlyOwner public {
    lock[_address] = locked;
  }

  function checkLockStatus(address _address) public view returns (bool) {
    return lock[_address];
  }

  function transferOwnership(address _newOwner) public {
    _transferOwnership(_newOwner);
  }
}