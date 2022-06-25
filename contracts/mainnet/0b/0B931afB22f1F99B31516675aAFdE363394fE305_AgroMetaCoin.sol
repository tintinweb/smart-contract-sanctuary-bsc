// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./Ownable.sol";
import "./Staking.sol";


contract AgroMetaCoin is Context, Ownable, Staking {

  /**
   * @dev Public State Variables will automatically creates getter 
   * functions instead of hard coding relative functions
   */
  string public _name;
  string public _symbol;
  uint8 public _decimals;
  uint256 public _totalSupply;

  mapping(address => uint256) private _balances;

  /**
   * @dev mapping spender address over mapping of owner address
   * so spender can spend on behalf of owner
   * and be deductible from _allowance
   */
  mapping(address => mapping(address => uint256)) private _allowances;

  /**
   * @notice emitted after each time token has been moved around
   */
  event Transfer (address indexed from, address indexed to, uint256 value);

  /**
   * @notice  emitted on each approval 
   */
  event Approval ( address indexed owner, address indexed spender, uint256 value);

  

  constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
    _totalSupply = totalSupply_;
    _balances[msg.sender] = _totalSupply;
    

    emit Transfer(address(0), msg.sender, _totalSupply);
  }


  function getOwner() external view returns (address) {
    return owner();
  }

 
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
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
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
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
    require(_allowances[sender][msg.sender] >= amount, "Agro-Meta: transfer exceeds allowance");
    _transfer(sender, recipient, amount);
    _approve( sender, msg.sender, _allowances[sender][msg.sender] - amount);
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
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
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
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   * - `msg.sender` must be the token owner
   * - `_mintable` must be true
   */
  function mint(address account, uint256 amount) public onlyOwner returns (bool) {
    _mint(account, amount);
    return true;
  }

  /**
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
  function burn(address account, uint256 amount) public onlyOwner returns (bool) {
    _burn(account, amount);
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
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "Agro-Meta: transfer from the zero address");
    require(recipient != address(0), "Agro-Meta: transfer to the zero address");
    require(_balances[sender] >= amount, "Agro-Meta: Transfer amount exceeds balance");
    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;
      
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
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "Agro-Meta: approve from the zero address");
    require(spender != address(0), "Agro-Meta: approve to the zero address");
    _allowances[owner][spender] = amount;
    
    emit Approval(owner, spender, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *  - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "Agro-Meta: mint to the zero address");
    _totalSupply = _totalSupply + amount;
    _balances[account] = _balances[account] + amount;
    
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements:
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "Agro-Meta: burn from the zero address");
    require(amount >= amount, "Agro-Meta: Burn amount excceds balance");
    _balances[account] = _balances[account] - amount;
    _totalSupply = _totalSupply - amount;
    
    emit Transfer(account, address(0), amount);
  }
}