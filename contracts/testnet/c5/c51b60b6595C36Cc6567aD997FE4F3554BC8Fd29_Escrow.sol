/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
        function burn(address account, uint256 amount) external returns (bool);
        function mint(address account, uint256 amount) external returns (bool);
}
interface ICOIN {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
contract Escrow
{
    ICOIN coin;
    IERC20 token;
    address payable public escrowOwner;
    uint256 TotalTokens;
    uint256 public totalCoins;
    uint256 public token_per_user;
    address payable claimer;
    bool sendtokensescrow ;
       mapping(address => bool) result;
    modifier onlyowner{
      require (msg.sender == escrowOwner);
      _;
  }
      modifier onlyclaimer{
      require (msg.sender == claimer);
      _;
  }
constructor (IERC20 _token,ICOIN _coin)
    {
        token = _token;
        coin = _coin;
        escrowOwner = payable(msg.sender);
        TotalTokens = 10;
        totalCoins =300;        
        token_per_user =1;
        token.transferFrom(msg.sender, address(this),TotalTokens);
    }
  
       function sendcoinstoescrow(uint256 coins) external 
      {
          claimer = payable(msg.sender);
         require (msg.sender !=  escrowOwner);
          token_per_user =coins/totalCoins ;
         require(
        token.balanceOf(address(this)) >= token_per_user,
        "balance must be greater than require amount"
        );
         require( coins >=  totalCoins,"you have atleast required coins");
        coin.transferFrom(msg.sender, address(this),  totalCoins);
         result[msg.sender] = true;



      }
      function claimtoken() external onlyclaimer {
      //    require(claimtoken == true );

//         require(sendtokensescrow  == true, " it should be active");
        require(result[msg.sender] == true, "you have already taken");
 
             token.transferFrom(address(this), msg.sender,token_per_user);
                    result[msg.sender] = false;


      }
      function update_Coins(uint256 coins)external onlyowner 
      {
          totalCoins = coins;
      }
      function update_token_PerUser(uint256 newTokens)external onlyowner 
      {
            token_per_user = newTokens;
      }
      
       function changeTokenAdres(IERC20 newTokenAdres) external onlyowner 
       {
           token = newTokenAdres;     
       }
    function claimCoin(uint256 amount)  public onlyowner 
    {
            uint256 _amount = 300;
            require (amount >= _amount,"");
           coin.transferFrom(address(this),msg.sender, amount);
    }
      function update_Coins_token(uint256 coins,uint256 newTokens)external onlyowner 
      {
          totalCoins = coins;
           token_per_user = newTokens;
      }
}