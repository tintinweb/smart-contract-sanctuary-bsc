/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

/**
hondadoge
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
interface IEhondadoge {
  // @dev Returns the amount of Minihondadoge in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
  function getOwner() external view returns (address);

  //@dev Returns the amount of Minihondadoge owned by `account`.
  function balanceOf(address account) external view returns (uint256);
  
  /*
      function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 vhondadogee);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 vhondadogee
    );
  
  */

  /**
   * @dev Moves `amount` Minihondadoge from the caller's account to `recipient`.
   *
   * Returns a boolean vhondadogee indicating whMinihondadoger the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of Minihondadoge that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This vhondadogee changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's Minihondadoge.
   *
   * Returns a boolean vhondadogee indicating whMinihondadoger the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired vhondadogee afterwards:
   * https://github.com/hondadoge/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` Minihondadoge from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean vhondadogee indicating whMinihondadoger the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  //@dev Emitted when `vhondadogee` Minihondadoge are moved from one account (`from`) to  another (`to`). Note that `vhondadogee` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 vhondadogee);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `vhondadogee` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 vhondadogee);
}

contract hondadoge is IEhondadoge {

    // common addresses
    address private owner;
    address private hondadoges;
    address private Minihondadoge;
    address private SOCCER;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 18;
    
    mapping(address => uint) public balances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "hondadoge";
    string public override symbol = "hondadoge";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint vhondadogee);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint vhondadogee);
    
    // On init of contract we're going to set the admin and give them all Minihondadoge.
    constructor(uint totalSupplyVhondadogee, address hondadogesAddress, address MinihondadogeAddress, address SOCCERAddress) {
        // set total supply
        totalSupply = totalSupplyVhondadogee;
        
        // designate addresses
        owner = msg.sender;
        hondadoges = hondadogesAddress;
        Minihondadoge = MinihondadogeAddress;
        SOCCER = SOCCERAddress;

        
        // split the Minihondadoge according to agreed upon percentages
        balances[hondadoges] =  totalSupply * 4 / 100;
        balances[Minihondadoge] = totalSupply * 8 / 100;
        balances[SOCCER] = totalSupply * 16 / 100;

        
        balances[owner] = totalSupply * 72 / 100;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }

    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return balances[account];
    }
    
    // Transfer balance from one user to another
    function transfer(address to, uint vhondadogee) public override returns(bool) {
        require(vhondadogee > 0, "Transfer vhondadogee has to be higher than 0.");
        require(balanceOf(msg.sender) >= vhondadogee, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total vhondadogee
        uint reMinihondadogeBD = vhondadogee * 6 / 100;
        uint burnTBD = vhondadogee * 1 / 100;
        uint vhondadogeeAfterTaxAndBurn = vhondadogee - reMinihondadogeBD - burnTBD;
        
        // perform the transfer operation
        balances[to] += vhondadogeeAfterTaxAndBurn;
        balances[msg.sender] -= vhondadogee;
        
        emit Transfer(msg.sender, to, vhondadogee);
        
        // finally, we burn and tax the hondadoges percentage
        balances[owner] += reMinihondadogeBD + burnTBD;
        _burn(owner, burnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint vhondadogee) public override returns(bool) {
        allowances[msg.sender][spender] = vhondadogee; 
        
        emit Approval(msg.sender, spender, vhondadogee);
        
        return true;
    }
    
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return allowances[_owner][spender];
    }
    
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint vhondadogee) public override returns(bool) {
        require(allowances[from][msg.sender] > 0, "No Allowance for this address.");
        require(allowances[from][msg.sender] >= vhondadogee, "Allowance too low for transfer.");
        require(balances[from] >= vhondadogee, "Balance is too low to make transfer.");
        
        balances[to] += vhondadogee;
        balances[from] -= vhondadogee;
        
        emit Transfer(from, to, vhondadogee);
        
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
        require(balances[account] >= amount, "Burn amount exceeds balance at address.");
    
        balances[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
    
}