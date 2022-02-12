/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

pragma solidity >0.4.22<0.7.1;

contract Contracting{

   address public owner;
   address public richest;
   uint public mostSent;

   mapping (address => uint) pendingWithdrawals;
  

constructor() public payable {
      richest = msg.sender;
      mostSent = msg.value;

   }
function becomeRichest() public payable returns (bool) {
      if (msg.value > mostSent) {
         pendingWithdrawals[richest] += msg.value;
         richest = msg.sender;
         mostSent = msg.value;
         return true;
      } else {
         return false;
      }
   }
   function withdraw() public {
      uint amount = pendingWithdrawals[msg.sender];
      pendingWithdrawals[msg.sender] = 0;
      msg.sender.transfer(amount);
   }

    function pay() public payable returns(string memory){

        return "success";
    }

  
 
  
}