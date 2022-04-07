// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "./IBEP20.sol";
import "./Ownable.sol";

contract BSCWOLF is IBEP20, Ownable{
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  // Token identify
  string private _name;     // Token name
  string private _symbol;   // Token symbol
  // Token supply
  uint8   private constant _decimals = 10;                      // Token decimals
  uint256 private constant _supplywithoutdecimals = 100000;     // Supply without decimals
  uint256 private constant _totalSupply = _supplywithoutdecimals * (10 ** _decimals); // Supply with decimals
  uint256 private constant _walletMax = _totalSupply * 4 / 100; // Max tokens cuantity per wallet
  // Token fees
  uint256 private constant _fee = 2;    // 2% fee applied when buying and sell (constat variable modification is not possible)

  constructor(string memory tokenname, string memory tokensymbol) {
    _name = tokenname;
    _symbol = tokensymbol;
    _balances[owner()] = _totalSupply;
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
  function decimals() external pure returns (uint8) {
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
   * @dev Returns the number of existing tokens created with decimals
   */
  function totalSupply() external pure returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev Returns the number of existing tokens created without decimals
   */
  function totalSupplyWithoutDecimals() external pure returns (uint256) {
    return _supplywithoutdecimals;
  }

  /**
   * @dev Returns the cuantity of tokens allowed per wallet without decimals
   */
  function getMaxTokensPerWallet() external pure returns(uint256){
    return _walletMax / (10 ** _decimals);
  }

  /**
   * @dev Returns the cuantity of tokens allowed per wallet with decimals
   */
  function getMaxTokensPerWalletWithDecimals() external pure returns(uint256){
    return _walletMax;
  }

  /**
   * @dev Returns the number of existing tokens in a wallet
   */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev Returns the amount of tokens that can be spent by an authorized wallet, 
   *      from another wallet that owns the tokens.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev Authorize another wallet to spend a specific amount of your tokens.
   *
   * Requirements:
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    require(_balances[msg.sender] >= amount, 
      "You do not have the necessary tokens for the assignment.");

    _approve(msg.sender, spender, amount);
    return true;
  }

  /**
   * @dev Make a transfer of tokens between the connected wallet and the recipient's wallet. 
   *      With the amount of the second parameter.
   *
   * Requirements:
   *  - `recipient` cannot be the zero address.
   *  - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
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
    _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
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
    require(_balances[msg.sender] >= _allowances[msg.sender][spender] + addedValue, 
      "You do not have the necessary tokens for the assignment.");

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
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent with the sender parameter
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    // Check if address are dead directions
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    // Check if recipient amount exceeds max tokens balance per wallet (4% of total supply)
    // dont check if recipient is token contract
    _checkTxLimit(recipient, _balances[recipient] + amount);

    // Calculation of transaction fees
    uint transactionfee;
    if(sender == owner() || recipient == owner())
      transactionfee = 0;                       // Owner fee exempt
    else 
      transactionfee = amount * _fee / 100;     // fee cuantity 2%
    uint finalamount = amount - transactionfee; // amount with fees applied

    // Change balances
    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + finalamount;
    _balances[address(this)] = _balances[address(this)] + transactionfee;
    _approve(address(this), owner(), _balances[address(this)]);

    emit Transfer(sender, recipient, amount);
  }

  /**
   * @dev Check if `_address` exceeds with `_amount` the cuantity of max token ammount per wallet.
   *      This will not be checked if the address is the token contract.
   *
   * Requirements:
   *  - `_address` who receive the token amount.
   *  - `_amount` cuantity of tokens in the transaction
   */
  function _checkTxLimit(address _address, uint256 _amount) internal view {
    if(_address != address(this)){
      uint walletbalance = _balances[_address] + _amount;
      require(walletbalance <= _walletMax, "Transaction exceeds the limit of 4% of total supply per wallet");
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
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

}