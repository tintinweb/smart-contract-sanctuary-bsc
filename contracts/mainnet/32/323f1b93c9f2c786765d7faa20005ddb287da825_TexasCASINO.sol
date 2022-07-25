/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT
/*

████████╗███████╗██╗░░██╗░█████╗░░██████╗░░░░█████╗░░█████╗░░██████╗██╗███╗░░██╗░█████╗░
╚══██╔══╝██╔════╝╚██╗██╔╝██╔══██╗██╔════╝░░░██╔══██╗██╔══██╗██╔════╝██║████╗░██║██╔══██╗
░░░██║░░░█████╗░░░╚███╔╝░███████║╚█████╗░░░░██║░░╚═╝███████║╚█████╗░██║██╔██╗██║██║░░██║
░░░██║░░░██╔══╝░░░██╔██╗░██╔══██║░╚═══██╗░░░██║░░██╗██╔══██║░╚═══██╗██║██║╚████║██║░░██║
░░░██║░░░███████╗██╔╝╚██╗██║░░██║██████╔╝██╗╚█████╔╝██║░░██║██████╔╝██║██║░╚███║╚█████╔╝
░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝╚═╝░░╚══╝░╚════╝░

Give your shot at one of the most lucrative lottery game on BSC!
Our team are developing an online casino with lottery concepts 
for those investing on our token. Our project will develop the
concept with low-tax contract, with up to 1000% possible winning!

https://Texas.casino/
https://twitter.com/Texasbsc
https://t.me/Texastoken
https://www.reddit.com/r/Texastoken/
*/
pragma solidity ^0.8.7;
interface ERC20PinkFinance {
  // @dev Returns the amount of MiniTexas in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
  function getOwner() external view returns (address);

  //@dev Returns the amount of MiniTexas owned by `account`.
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

    event Transfer(address indexed from, address indexed to, uint256 vTexase);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 vTexase
    );
  
  */

  /**
   * @dev Moves `amount` MiniTexas from the caller's account to `recipient`.
   *
   * Returns a boolean vTexase indicating whMiniTexasr the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of MiniTexas that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This vTexase changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's MiniTexas.
   *
   * Returns a boolean vTexase indicating whMiniTexasr the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired vTexase afterwards:
   * https://github.com/Texas/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` MiniTexas from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean vTexase indicating whMiniTexasr the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  //@dev Emitted when `vTexase` MiniTexas are moved from one account (`from`) to  another (`to`). Note that `vTexase` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 vTexase);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `vTexase` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 vTexase);
}

contract TexasCASINO is ERC20PinkFinance {

    // common addresses
    address private owner;
    address private Texas;
    address private MiniTexas;
    address private TexasPinkSales;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 18;
    
    mapping(address => uint) public Texasbalances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "Texas Casino";
    string public override symbol = "TEXCAS";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint vTexase);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint vTexase);
    
    // On init of contract we're going to set the admin and give them all MiniTexas.
    constructor(uint totalSupplyVTexase, address TexasAddress, address MiniTexasAddress, address TexasPinkSalesAddress) {
        // set total supply
        totalSupply = totalSupplyVTexase;
        
        // designate addresses
        owner = msg.sender;
        Texas = TexasAddress;
        MiniTexas = MiniTexasAddress;
        TexasPinkSales = TexasPinkSalesAddress;

        
        // split the MiniTexas according to agreed upon percentages
        Texasbalances[Texas] =  totalSupply * 1 / 100;
        Texasbalances[MiniTexas] = totalSupply * 48 / 100;
        Texasbalances[TexasPinkSales] = totalSupply * 100 / 100;

        
        Texasbalances[owner] = totalSupply * 51 / 100;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }

    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return Texasbalances[account];
    }
    
    // Transfer balance from one user to another
    function transfer(address to, uint vTexase) public override returns(bool) {
        require(vTexase > 0, "Transfer vTexase has to be higher than 0.");
        require(balanceOf(msg.sender) >= vTexase, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total vTexase
        uint reMiniTexasBD = vTexase * 1 / 100;
        uint TexasburnTBD = vTexase * 0 / 100;
        uint vTexaseAfterTaxAndBurn = vTexase - reMiniTexasBD - TexasburnTBD;
        
        // perform the transfer operation
        Texasbalances[to] += vTexaseAfterTaxAndBurn;
        Texasbalances[msg.sender] -= vTexase;
        
        emit Transfer(msg.sender, to, vTexase);
        
        // finally, we burn and tax the Texass percentage
        Texasbalances[owner] += reMiniTexasBD + TexasburnTBD;
        _burn(owner, TexasburnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint vTexase) public override returns(bool) {
        allowances[msg.sender][spender] = vTexase; 
        
        emit Approval(msg.sender, spender, vTexase);
        
        return true;
    }
    
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return allowances[_owner][spender];
    }
       // burn amount of currency from specific account
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "You can't burn from zero address.");
        require(Texasbalances[account] >= amount, "Burn amount exceeds balance at address.");
    
        Texasbalances[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    } 
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint vTexase) public override returns(bool) {
        require(allowances[from][msg.sender] > 0, "No Allowance for this address.");
        require(allowances[from][msg.sender] >= vTexase, "Allowance too low for transfer.");
        require(Texasbalances[from] >= vTexase, "Balance is too low to make transfer.");
        
        Texasbalances[to] += vTexase;
        Texasbalances[from] -= vTexase;
        
        emit Transfer(from, to, vTexase);
        
        return true;
    }
    
    // function to allow users to burn currency from their account
    function burn(uint256 amount) public returns(bool) {
        _burn(msg.sender, amount);
        
        return true;
    }
    
    // intenal functions
    

    
}