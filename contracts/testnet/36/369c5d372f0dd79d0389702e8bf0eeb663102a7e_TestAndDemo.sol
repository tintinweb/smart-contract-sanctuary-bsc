/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

pragma solidity ^0.8.0;
interface ERC20
{
      function totalSupply() external returns (uint);
      function balanceOf(address tokenOwner) external returns (uint balance);
      function allowance(address tokenOwner, address spender) external returns (uint remaining);
      function transfer(address to, uint tokens) external returns (bool success);
      function approve(address spender, uint tokens) external returns (bool success);
      function transferFrom(address from, address to, uint tokens) external returns (bool success);
      event Transfer(address indexed from, address indexed to, uint tokens);
      event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract TestAndDemo
{
  
    ERC20 erc20;
    function InvestorWithdrawApprove(uint amttokens) public returns (uint approved)
     { 
         erc20 = ERC20(0x513F1663d961Fd8BC6d5Bfa0a72363CbDbF542C3);
         erc20.approve(msg.sender,amttokens);
         return erc20.allowance(address(this),msg.sender);
     }

     function InvestorWithdrawTransferFrom() public returns (uint Sent)
     {
         erc20.transferFrom(address(this),msg.sender,1);
         return 1;
     }

}