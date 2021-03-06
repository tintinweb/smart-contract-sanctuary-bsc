/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity 0.4.24;
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
    * 7EX - @dev Returns the amount of tokens owned by Contract.
    */
    function balanceOfContract() external view returns (uint256);
    
    /* Set how much bnb is the token */
    function setPrice(uint8 price) external returns (bool);
    
    /* Set Profit Address */
    function setProfitAddr(address addr) external returns(bool);

    /* Bank take the amount of BNB */
    function pix() external returns (bool);
    
    /* Get how much bnb is the token */
    function getPrice() external view returns (uint);
    
    /* Get the BNB Bank Balance */
    function getAmountBNB() external view returns (uint);
    
    /* Withdraw by customer plataform */
    function withdraw(uint256 amount) external returns(bool);
    
    /* Get Profit Address */
    function getProfitAddr()  external view returns (address);
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
    event Transfer(address indexed from, address indexed to, uint256 value, uint256 timestamp);

    /**
    * @dev Emitted when the allowance of a `spender` for an `owner` is set by
    * a call to {approve}. `value` is the new allowance.
    */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
    * @dev Emitted when `value` tokens are moved from one account (`from`) to
    * another (`to`).
    *
    * Note that `value` may be zero.
    */
    event Trade(address indexed from, address indexed to, uint256 value_tkn, uint256 value_bnb);

    /**
    * @dev Emitted when `value` tokens are moved from one account (`from`) to
    * another (`to`).
    *
    * Note that `value` may be zero.
    */
    event Withdraw_by_won(address indexed from, address indexed to, uint256 value_tkn);
    
    
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

  /*
  * SPDX-License-Identifier: UNLICENSED
  */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () public { }

  function _msgSender() internal view returns (address) {
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
  constructor () public {
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

contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  
  /* 7EX implementation */
  uint public _amount_bnb; // Totla de BNB depositados pelos clientes
  uint public Bank_ball_bnb; // Total de BNBs disponiveis para saque pelos clientes
  uint public Bank_ball_tax; // Total de BNBs disponiveis para saque do Banker
  uint public Bank_ball_tkn_sold; // Total de Tokens vendidos
  uint8 public token_price; // Qts BNBs valem 1 token
  uint public _sell_des; //Deprec price to sell
  
  address public _profit_addr;
  address[] public _customers;

  /* ------------------ */

  struct Customer {
      uint id;
      address wallet;   
      uint ball_bnb;
      uint tkn_bought;
      bool ativo;
  }
  mapping (address => Customer) Bank;
 
  
  constructor() public {
    _name = "7X COIN";
    _symbol = "SXC";
    _decimals = 18;
    _totalSupply = 100 * 10 ** uint(_decimals);
    _amount_bnb = 0;
    token_price = 1;
    _sell_des = 50; /* 2% */
    
    
    _balances[address(this)] = _totalSupply;
    emit Transfer(address(0), address(this), _totalSupply, block.timestamp);
    /*
    _balances[address(this)] = _totalSupply * 50 / 100;
    _balances[address(msg.sender)] = _totalSupply * 50 / 100;
    emit Transfer(address(0), address(this), _totalSupply * 50 / 100);
    */
  }


  /**
   * @dev Callback function
   */
  function () public payable {
    require(msg.value > 0, "Amount: Needs to be > 0");
    require(_balances[address(this)] > (msg.value * token_price), "Amount: Not enough Token");
    bToken(msg.sender, msg.value);
  }

  /**
   * @dev Buy 7EX Token.
   */
 function bToken(address from, uint value) internal returns (bool){
    uint tokens = value * token_price;
    _amount_bnb += value;
    _balances[address(this)] -= tokens;
    _balances[address(from)] += tokens;

    if (Bank[from].ativo) {
      Bank_ball_tkn_sold += tokens;
      Bank[from].tkn_bought += tokens;
    } else {
      _customers.push(from);
      Bank[from].id = _customers.length-1;
      Bank[from].wallet = from;
      Bank[from].ball_bnb = Bank[from].ball_bnb + 0;
      
      Bank[from].tkn_bought += tokens;
      Bank_ball_tkn_sold += tokens;
    }
    
    emit Transfer(address(this), msg.sender, tokens, block.timestamp);
    return true;
  }

  /**
   * @dev Sell SXC Token.
   */
  function withdraw(uint256 amount) public returns(bool) {    
    require(amount > 0, "Token amount: Needs to be > 0");
    require(Bank[msg.sender].ball_bnb  >= (amount / token_price), "Token amount: You han't profit token enough");
    
    uint bnbs;
    uint bnbs_liq;
    uint tax;

    bnbs = (amount/token_price);    
    tax = bnbs / _sell_des;
    bnbs_liq = bnbs - tax;

    Bank[msg.sender].ball_bnb -= bnbs;
    Bank_ball_tax += tax;
    
    _balances[address(msg.sender)] -= amount;
    _balances[address(this)] += amount;
   
    Bank_ball_bnb -= bnbs;

    msg.sender.transfer(bnbs_liq);
    emit Trade(msg.sender, address(this), amount, bnbs_liq);
    
    return true;
  }

  
  /**
   * @dev Pay Profit by _profit_addr.
   */
  function profit() external payable returns(bool) {
    require(msg.value > 0, "Profit Error: Value needs > 0");
    require(Bank_ball_tkn_sold > 0, "No one tkn solded");
    require(msg.sender == _profit_addr, "You cant do this.");
    
    address cliente;
    uint256 percent;
    uint profit_percent_vlr;

    Bank_ball_bnb += msg.value;
    for (uint pos = _customers.length; pos > 0; pos--) { 
      cliente = _customers[pos-1];
      percent = Bank[cliente].tkn_bought * 10000 / Bank_ball_tkn_sold;
      profit_percent_vlr = percent * msg.value / 10000;
      Bank[cliente].ball_bnb += profit_percent_vlr;

      uint tokens = profit_percent_vlr * token_price;
      _balances[address(this)] -= tokens;
      _balances[address(cliente)] += tokens;
      
      emit Transfer(address(this), cliente, tokens, block.timestamp);
    }
    
    return true;
  }

  

  /**
   * @dev Profit_addr get BNBs to operation.
   */
  function Get_to_operation(uint256 amount) external returns(bool) {    
    require(msg.sender == _profit_addr, "You cant do this.");
    require(amount > 0, "Amount: Needs to be > 0");
    require(_amount_bnb >= amount, "Amount: You don't have BNB enough");
    
    _amount_bnb -= amount;
    _profit_addr.transfer(amount);
    emit Withdraw_by_won(msg.sender, address(this), amount);
    return true;
  }

  

  /**
  * @dev Set Price 7EX Token.
  */
  function setPrice(uint8 price) onlyOwner public returns(bool) {
    require(price > 0, "Price: Needs to be > 0");
    token_price = price;
    return true;
    
  }

  /**
  * @dev Set Profit Address.
  */
  function setProfitAddr(address addr)  onlyOwner  public returns(bool) {
    _profit_addr = addr;
    return true;
  }  

  /**
  * @dev Set Sell tax 7EX Token.
  */
  function setSelldes(uint8 des) onlyOwner public returns(bool){
    require(des > 0, "Deprec Tax: Needs to be > 0");
    _sell_des = des;
    return true;
    
  }
  
  /**
   * @dev PIX 7EX Token.
   */
  function pix() onlyOwner public returns(bool) {
    require(Bank_ball_tax > 0, "PIX: Amount is 0");
    msg.sender.transfer(Bank_ball_tax);
    Bank_ball_tax = 0;
    return true;
  }
    
    
  /**
   * @dev Returns the Bank BNB balance.
   */
  function getBank_ball_bnb() external view returns (uint) {
    return Bank_ball_bnb;
  }


  /**
   * @dev Returns the Bank TAX BNB balance to get by PIX
   */
  function getBank_ball_tax() external view returns (uint) {
    return Bank_ball_tax;
  }

  /**
   * @dev Returns the Qtd Token Solded.
   */
  function getBank_ball_tkn_sold() external view returns (uint) {
    return Bank_ball_tkn_sold;
  }


  /**
   * @dev Returns the Customer Bank BNB ball.
   */
  function getCust_Bank_ball_bnb(address customer) external view returns (uint) {
    uint bnbs;
    uint bnbs_liq;
    uint tax;

    bnbs = Bank[customer].ball_bnb;
    tax = bnbs / _sell_des;
    bnbs_liq = bnbs - tax;
    return bnbs_liq;
  }

    /**
   * @dev Returns the Customer Bank TKN bought by customer
   */
  function getCust_Bank_tkn_bought(address customer) external view returns (uint) {
    return Bank[customer].tkn_bought;
  }

  /**
   * @dev Returns the Customer ID.
   */
  function getCust_Bank_id(address customer) external view returns (uint) {
    return Bank[customer].id;
  }

  /**
   * @dev Returns the Customer wallet.
   */
  function getCust_Bank_wallet(uint id) external view returns (address) {
    return _customers[id];
  }

  /**
   * @dev Returns the adress of profit user.
   */
  function getProfitAddr() external view returns (address) {
    return _profit_addr;
  }

 /**
   * @dev Returns the price of token.
   */
  function getPrice() external view returns (uint) {
    return token_price;
  }


  /**
   * @dev Returns the BNB Bank Balance.
   */
  function getAmountBNB() external view returns (uint) {
    return _amount_bnb;
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
   * @dev See {BEP20-balanceOfContract}.
   */
  function balanceOfContract() external view returns (uint256) {
    return _balances[address(this)];
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
    require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");

    if (recipient == address(this)){
      withdraw(amount);
    } else {
      uint bnbs;
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);  
      bnbs = amount * token_price;
      if (Bank[sender].ball_bnb >= bnbs){
        Bank[sender].ball_bnb -= bnbs;
        Bank[recipient].ball_bnb += bnbs;
      }
      emit Transfer(sender, recipient, amount, block.timestamp);
    }    
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
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
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
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount, block.timestamp);
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
    emit Transfer(account, address(0), amount, block.timestamp);
  }

}