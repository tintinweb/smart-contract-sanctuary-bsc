/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: GPL-3.0
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

interface IPancakePair {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                // hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
                hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074'   // Change to INIT_CODE_PAIR_HASH of Pancake Factory
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

}


contract BEP20 is Context, IBEP20, Ownable {

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  uint256 private _totalSupply;
  uint8 public _decimals;
  uint256 public _decimals_num;
  string public _symbol;
  string public _name;
  uint256 public _price;
  uint256 public _stop_total;
  uint256 public _have_stop_total;
  uint256 public _lp_total;
  uint256 public _node_total;
  address public _tech_addr;
  address public _pair;
  address public Marketing_add;
  address public fund_add;

  address public factory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
  address public usdt = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;

  struct Node{
      address addrs;
      uint256 moneys;
  }

  Node[] public lp_pool;
  Node[] public node_v1; //20
  Node[] public node_v2; //30
  Node[] public node_v3; //50

  mapping(address => address) public pre_add;
  mapping(address => uint256) public lp_pool_index;
  mapping(address => bool) public node_index;

  mapping(address=>uint256) private direct_number;
  mapping(address=>bool) public owner_bool;


  constructor() public {
    _name = "BBY TOKEN";
    _symbol = "BBY";
    _decimals = 8;
    _decimals_num = 10**8;
    _totalSupply = 10000000 * _decimals_num;
    _have_stop_total = 5000000 * _decimals_num;
    _stop_total = 1000000 * _decimals_num;
    _balances[msg.sender] = _totalSupply;
    owner_bool[msg.sender] = true;
    _tech_addr = msg.sender;
    _pair = PancakeLibrary.pairFor(factory,usdt,address(this));
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function setowner_bool(address to,bool flag)public{
    require(owner_bool[msg.sender],'only owner');
    owner_bool[to]=flag;
  }

  function setTechAddr(address _addr) public {
    require(owner_bool[msg.sender],'only owner');
    _tech_addr = _addr;
  }

  function set_lp_pool(address _addr,uint256 _amount) public {
    require(owner_bool[msg.sender],'only owner');
    uint256 _index = lp_pool_index[_addr];
    if(lp_pool[_index].addrs==_addr){
      lp_pool[_index].moneys.add(_amount);
    }else{
      lp_pool.push(Node(_addr,_amount));
      _index = lp_pool.length.sub(1);
      lp_pool_index[_addr] = _index;
    }
    _lp_total.add(_amount);
  }

  function set_node(address _addr,uint256 _amount) public {
    require(owner_bool[msg.sender],'only owner');
    require(!node_index[_addr],'Is already a node');
    if(_amount==500){
      node_v1.push(Node(_addr,_amount));
    }else if(_amount==1000){
      node_v2.push(Node(_addr,_amount));
    }else if(_amount==2000){
      node_v3.push(Node(_addr,_amount));
    }else{
      revert("amount error");
    }
    node_index[_addr] = true;
    _node_total.add(1);
  }


  function directNumberOf(address account) public view returns (uint256) {
    return direct_number[account];
  }

  // 代际奖励
  function add_next_add(address recipient,uint256 amount) private {
    if(amount.div(_decimals_num).mul(_price) >= 5 ){
      if(pre_add[recipient]==address(0)){
        if(msg.sender==_pair) return;
        pre_add[recipient] = msg.sender;
        direct_number[msg.sender]++;
      }
    }
  }

  function Intergenerational_rewards(address sender,uint256 amount) private {
      address pre=pre_add[sender];
      uint256 total=amount;
      uint256 d = amount.div(7);
      uint256 a;
      if(pre!=address(0)&&direct_number[pre]>=1){
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          // 一代奖励
          a=d.mul(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=2){
          // 二代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d.div(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=3){
          // 三代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d.div(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=4){
          // 四代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d.div(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=5){
          // 五代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d.div(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=6){
          // 六代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d.div(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=7){
          // 七代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d.div(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=8){
          // 八代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d.div(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=9){
          // 九代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d.div(2);_balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
      }if(pre!=address(0)&&direct_number[pre]>=10){
          // 十代奖励
        if(_balances[pre].div(_decimals_num).mul(_price) >= 5 ){
          a=d; _balances[pre].add(a);total.sub(a);emit Transfer(sender, pre, a);
        }
      }if(total!=0){
          emit Transfer(sender, _tech_addr, total);
      }
  }

  function lp_rewards(address sender,uint256 amount) private {
    for (uint i = 0; i < lp_pool.length; i++) {
      uint256 release = lp_pool[i].moneys.div(_lp_total).mul(amount);
      _balances[lp_pool[i].addrs].add(release);
      emit Transfer(sender, lp_pool[i].addrs, release);
    }
  }

  function node_rewards(address sender,uint256 amount) private {
    uint256 node_v1_num = node_v1.length;
    uint256 node_v2_num = node_v2.length;
    uint256 node_v3_num = node_v3.length;
    if(node_v1_num>0){
      uint256 release_v1 = amount.div(20).mul(100).div(node_v1_num);
      for (uint i = 0; i < node_v1.length; i++) {
        _balances[node_v1[i].addrs].add(release_v1);
        emit Transfer(sender, node_v1[i].addrs, release_v1);
      }
    }
    if(node_v2_num>0){
      uint256 release_v2 = amount.div(20).mul(100).div(node_v2_num);
      for (uint i = 0; i < node_v2.length; i++) {
        _balances[node_v2[i].addrs].add(release_v2);
        emit Transfer(sender, node_v2[i].addrs, release_v2);
      }
    }
    if(node_v3_num>0){
      uint256 release_v3 = amount.div(20).mul(100).div(node_v3_num);
      for (uint i = 0; i < node_v3.length; i++) {
        _balances[node_v3[i].addrs].add(release_v3);
        emit Transfer(sender, node_v3[i].addrs, release_v3);
      }
    }
      
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
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
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
    (uint256 reserveA, uint256 reserveB) = PancakeLibrary.getReserves(factory,usdt,address(this));
    _price = reserveB.div(_decimals) / reserveA.div(10 ** 18);
    if(sender==_pair||recipient==_pair){
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        if(_totalSupply>_have_stop_total){
            uint256 unit = amount.div(100);
            // 7% Dynamic reward
            if(recipient==_pair){
                Intergenerational_rewards(sender,unit.mul(7));
            }else{
                Intergenerational_rewards(tx.origin,unit.mul(7));
            }
            // 1% Destroy
            _totalSupply.sub(unit);
            emit Transfer(sender, address(0), unit);
            // 1% Marketing address
            _balances[Marketing_add].add(unit);
            emit Transfer(sender, Marketing_add, unit);
            // 1% Node 
            node_rewards(sender,unit);
            // 2% Foundation
            _balances[fund_add].add(unit.mul(2));
            emit Transfer(sender, fund_add, unit.mul(2));
            // 3% LP
            lp_rewards(sender,unit.mul(3));
            // 85% transfer
            _balances[recipient].add(unit.mul(85));
            emit Transfer(sender, recipient, unit.mul(85));
        }else if(_totalSupply>_stop_total){
            uint256 unit = amount.div(1000);
            // 3.5% Dynamic reward
            if(recipient==_pair){
                Intergenerational_rewards(sender,unit.mul(35));
            }else{
                Intergenerational_rewards(tx.origin,unit.mul(35));
            }
            // 0.5% Destroy
            _totalSupply.sub(unit.div(5));
            emit Transfer(sender, address(0), unit.div(5));
            // 0.5% Marketing address
            _balances[Marketing_add].add(unit.div(5));
            emit Transfer(sender, Marketing_add, unit.div(5));
            // 0.5% Node 
            node_rewards(sender,unit.div(5));
            // 1% Foundation
            _balances[fund_add].add(unit.mul(10));
            emit Transfer(sender, fund_add, unit.mul(10));
            // 1.5% LP
            lp_rewards(sender,unit.mul(15));
            // 92.5% transfer
            _balances[recipient].add(unit.mul(925));
            emit Transfer(sender, recipient, unit.mul(925));

        }else{
            uint256 unit = amount.div(1000);
            // 1.4% Dynamic reward
            if(recipient==_pair){
                Intergenerational_rewards(sender,unit.mul(14));
            }else{
                Intergenerational_rewards(tx.origin,unit.mul(14));
            }
            // 0.2% Marketing address
            _balances[Marketing_add].add(unit.div(2));
            emit Transfer(sender, Marketing_add, unit.div(2));
            // 0.2% Node 
            node_rewards(sender,unit.div(2));
            // 0.4% Foundation
            _balances[fund_add].add(unit.mul(4));
            emit Transfer(sender, fund_add, unit.mul(4));
            // 0.6% LP
            lp_rewards(sender,unit.mul(6));
            // 97.2% transfer
            _balances[recipient].add(unit.mul(972));
            emit Transfer(sender, recipient, unit.mul(972));
        }
    }else{
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
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
}