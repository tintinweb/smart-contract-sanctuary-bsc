/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

  interface IERC20 
  { 
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns(uint256); 
  function transfer(address recipiant , uint256 amount ) external returns(bool);
  function allowence(address owner, address spender ) external  returns (uint256);
  function approve(address spender , uint amount ) external returns(bool);
  function transferfrom(address sender, address receiver, uint256 amount ) external returns(bool);
}
contract ico_cal{
    IERC20 public token;
    address  public owner;
    uint256 public  decimal=10e18;
    uint256 public total_Supply=500000000*decimal;
    uint256 public  rate = 1000000000000000;
    mapping (address=> uint256 )  balances;
        modifier onlyowner{
            require( owner==msg.sender , "only owner can deposite ether"); 
                    _;               }
 constructor (IERC20 _token )
 {
     token = _token;
     owner = msg.sender;
     
 }
  function balanceOf(address receiver ) public view returns(uint256){
      return token.balanceOf( receiver);
  }
  function check_tokenValue(uint256 amount ) public view returns( uint256){
       return (amount*decimal)/rate;
  }
    function check_bnbValue(uint256 amount ) public view returns( uint256){
       return (amount*rate);
    }

function BuyToken() public payable {
   // require(msg.value>200000000000000000 ,"value must be greater than 0.2 bnb");
    uint256 a = check_tokenValue(msg.value);
    
    token.transfer( msg.sender , a);
}
function SaleToken( uint256 amount ) public   
{
    uint256 a = check_bnbValue(amount);
    payable(msg.sender).transfer(a);
    token.transferfrom(msg.sender , address(this), amount);
}
function MinimumBuyTokn( ) public  pure returns(uint256 Minimum_value){
    return 200000000000000000;
}
function pricePrToken( ) public  pure returns(uint256 Minimum_value){
    return 100000000000000;
    }

}