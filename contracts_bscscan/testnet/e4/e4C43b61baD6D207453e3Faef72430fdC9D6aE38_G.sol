// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./Stakeable.sol";
/**
* @notice G is a GameFi token for Cloud Castle world
* And G.sol is a BEP20 Token solidity on Binance Smart Chain
*/
contract G is Ownable, Stakeable{
  
  /**
  * @notice Variables for contract, private variables are named with _prefix
  */
  uint private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  /**
  * @notice 
  * _balances is a  mapping of an account address <> available balances
  * _freezes is a mapping of an account address <> frozen balances
  * _allowances is a nested mapping for an account address <> (spender address <> approved amounts can be drew from the owner account) 
  */
  mapping (address => uint256) private _balances;
  mapping (address => uint256) private _freezes;
  mapping (address => mapping (address => uint256)) private _allowances;

  /**
  * @notice Events are created below.
  * Transfer event is a event that notify the blockchain that a Transfer or Approval action is happened
  *
  */
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Freeze(address indexed from, uint256 value);
  event Unfreeze(address indexed from, uint256 value);

  /**
  * @notice constructor will be triggered when we create the Smart contract
  * _name = name of the token
  * _short_symbol = Short Symbol name for the token
  * token_decimals = The decimal precision of the Token, defaults 18
  * _totalSupply is how much Tokens there are totally 
  */
  constructor(string memory token_name, string memory short_symbol, uint8 token_decimals, uint256 token_totalSupply){
      _name = token_name;
      _symbol = short_symbol;
      _decimals = token_decimals;
      _totalSupply = token_totalSupply;

      // Add all the tokens created to the creator of the token
      _balances[msg.sender] = _totalSupply;

      // Emit an Transfer event to notify the blockchain that an Transfer has occured
      emit Transfer(address(0), msg.sender, _totalSupply);
	  
  }
  /**
  * @notice decimals will return the number of decimal precision the Token is deployed with
  */
  function decimals() external view returns (uint8) {
    return _decimals;
  }
  /**
  * @notice symbol will return the Token's symbol 
  */
  function symbol() external view returns (string memory){
    return _symbol;
  }
  /**
  * @notice name will return the Token's symbol 
  */
  function name() external view returns (string memory){
    return _name;
  }
  /**
  * @notice totalSupply will return the tokens total supply of tokens
  */
  function totalSupply() external view returns (uint256){
    return _totalSupply;
  }
  /**
  * @notice balanceOf will return the account balance for the given account
  */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }
  /**
  * @notice freezeOf will return the account balance for the given account
  */
  function freezeOf(address account) external view returns (uint256) {
    return _freezes[account];
  }
  /**
  * @notice getOwner just calls Ownables owner function. 
  * returns owner of the token
  * 
  */
  function getOwner() external view returns (address) {
    return owner();
  }
  /**
  * @notice allowance is used view how much allowance an spender has
  */
  function allowance(address owner, address spender) external view returns(uint256){
    return _allowances[owner][spender];
  }
//***********************PUBLIC FUNCTION*************************************//
  /**
  * @notice mint is used to create tokens and assign them to msg.sender
  * 
  * See {_mint}
  * Requires
  *   - msg.sender must be the token owner
  *
   */
  function mint(address account, uint256 amount) public onlyOwner returns(bool){
    _mint(account, amount);
    return true;
  }
  /**
  * @notice burn is used to destroy tokens on an address
  * 
  * See {_burn}
  * Requires
  *   - msg.sender must be the token owner
  *
  */
  function burn(address account, uint256 amount) public onlyOwner returns(bool) {
    _burn(account, amount);
    return true;
  }
  /**
  * @notice transfer is used to transfer funds from the sender to the recipient
  * This function is only callable from outside the contract. For internal usage see 
  * _transfer
  *
  * Requires
  * - Caller cannot be zero
  * - Caller must have a balance = or bigger than amount
  *
  */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }
  /**
  * @notice approve will use the senders address and allow the spender to use X amount of tokens on his behalf
  */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }
  /**
  * @notice freeze is used to freeze tokens on an address
  * 
  * See {_freeze}
  * Requires
  *   - msg.sender must be the token owner
  *
  */
  function freeze(address account, uint256 amount) public onlyOwner returns(bool) {
    _freeze(account, amount);
    return true;
  }
  /**
  * @notice unfreeze is used to unfreeze tokens on an address
  * 
  * See {_unfreeze}
  * Requires
  *   - msg.sender must be the token owner
  *
  */
  function unfreeze(address account, uint256 amount) public onlyOwner returns(bool) {
    _unfreeze(account, amount);
    return true;
  }
//***********************PRIVATE FUNCTION*************************************//
  /**
  * @notice _mint will create tokens on the address inputted and then increase the total supply
  *
  * It will also emit an Transfer event, with sender set to zero address (adress(0))
  * 
  * Requires that the address that is recieveing the tokens is not zero address
  */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "G: cannot mint to zero address");
	require(amount >= 0, "G: cannot mint a negative amount");

    // Increase total supply
    _totalSupply = _totalSupply + (amount);
    // Add amount to the account balance using the balance mapping
    _balances[account] = _balances[account] + amount;
    // Emit our event to log the action
    emit Transfer(address(0), account, amount);
  }
  /**
  * @notice _burn will destroy tokens from an address inputted and then decrease total supply
  * An Transfer event will emit with receiever set to zero address
  * 
  * Requires 
  * - Account cannot be zero address
  * - Account balance has to be bigger or equal to amount
  * - Amount cannot be negative
  */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "G: cannot burn from zero address");
    require(_balances[account] >= amount, "G: Cannot burn more than the account owns");
	require(amount >= 0, "G: Cannot burn a negative amount");

    // Remove the amount from the account balance
    _balances[account] = _balances[account] - amount;
    // Decrease totalSupply
    _totalSupply = _totalSupply - amount;
    // Emit event, use zero address as reciever
    emit Transfer(account, address(0), amount);
  } 
  /**
  * @notice _transfer is used for internal transfers
  * 
  * Events
  * - Transfer
  * 
  * Requires
  *  - Sender cannot be zero address
  *  - recipient cannot be zero address
  *  - sender balance most be = or bigger than amount
  *  - amount cannot be negative
  */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "G: transfer from zero address");
    require(recipient != address(0), "G: transfer to zero address");
    require(_balances[sender] >= amount, "G: cant transfer more than your account holds");
	require(amount >= 0, "G: cant transfer a negative amount");
    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;

    emit Transfer(sender, recipient, amount);
  }
  /**
  * @notice _approve is used to add a new Spender to a Owners account
  * 
  * Events
  *   - {Approval}
  * 
  * Requires
  *   - owner and spender cannot be zero address
  *   - cannot approve a negative amount
  */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "G: approve cannot be done from zero address");
    require(spender != address(0), "G: approve cannot be to zero address");
	require(amount >= 0, "G: cannot approve a negative amount");
    // Set the allowance of the spender address at the Owner mapping over accounts to the amount
    _allowances[owner][spender] = amount;

    emit Approval(owner,spender,amount);
  }
  /**
  * @notice _freeze is used to freeze tokens on an address
  * 
  * Requires
  *   - Account cannot be zero address
  *   - Account balance has to be bigger or equal to amount
  *   - Amount cannot be negative
  */
  function _freeze(address account, uint256 amount) internal {
	require(account != address(0), "G: cannot freeze zero address");
	require(_balances[account] >= amount, "G: Cannot freeze more than the account owns");
	require(amount >= 0, "G: Cannot freeze a negative amount");
	       
    // Subtract from the account
    _balances[account] = _balances[account] - amount;
    // Updates _freezes                    
    _freezes[account] = _freezes[account] + amount;    
                            
    emit Freeze(account, amount);
  }
  /**
  * @notice _unfreeze is used to unfreeze tokens on an address
  * 
  * Requires
  *   - Account cannot be zero address
  *   - freeze balance has to be bigger or equal to amount
  *   - amount cannot be negative
  */
  function _unfreeze(address account, uint256 amount) internal {
	require(account != address(0), "G: cannot freeze zero address");
	require(_freezes[account] >= amount, "G: Cannot unfreeze more than the freezes amount");
	require(amount >= 0, "G: Cannot unfreeze a negative amount");
	      
    // Updates _unfreezes                    
    _freezes[account] = _freezes[account] - amount;  		  
    // Add to the account
    _balances[account] = _balances[account] + amount;
                            
    emit Unfreeze(account, amount);
  }
  /**
  * @notice transferFrom is uesd to transfer Tokens from a Accounts allowance
  * Spender address should be the token holder
  *
  * Requires
  * - Sender cannot be zero address
  * - recipient cannot be zero address
  * - The caller must have a allowance = or bigger than the amount spending
  * - amount cannot be negative
  */
  function transferFrom(address spender, address recipient, uint256 amount) external returns(bool){
	require(spender != address(0), "G: spender cannot be a zero address");
    require(recipient != address(0), "G: recipient cannot be a zero address");  
    // Make sure spender is allowed the amount 
    require(_allowances[spender][msg.sender] >= amount, "G: You cannot spend that much on this account");
	require(amount >= 0, "G: cant transfer a negative amount");
	
    // Transfer first
    _transfer(spender, recipient, amount);
    // Reduce current allowance so a user cannot respend
    _approve(spender, msg.sender, _allowances[spender][msg.sender] - amount);
    return true;
  }
  /**
  * @notice increaseAllowance
  * Adds allowance to a account from the function caller address
  */
  function increaseAllowance(address spender, uint256 amount) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender]+amount);
    return true;
  }
  /**
    * @notice decreaseAllowance
    * Decrease the allowance on the account inputted from the caller address
    */
  function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender]-amount);
    return true;
  }
  /**
    * Add functionality like burn to the _stake afunction
    *
     */
  function stake(uint256 _amount) public {
    // Make sure staker actually is good for it
    require(_amount < _balances[msg.sender], "G: Cannot stake more than you own");
    _stake(_amount);
    // Burn the amount of tokens on the sender
    _burn(msg.sender, _amount);
  }
  /**
  * @notice withdrawStake is used to withdraw stakes from the account holder
  */
  function withdrawStake(uint256 amount, uint256 stake_index)  public {
    uint256 amount_to_mint = _withdrawStake(amount, stake_index);
    // Return staked tokens to user
    _mint(msg.sender, amount_to_mint);
  }
}