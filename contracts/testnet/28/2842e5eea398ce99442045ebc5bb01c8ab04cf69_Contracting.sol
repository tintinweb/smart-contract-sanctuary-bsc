/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

pragma solidity >0.4.22<0.7.1;

contract Contracting{

   address public owner;
   address public tokenContract;
  


    constructor() public{

       owner = msg.sender;
    }

    function pay() public payable returns(string memory){

        return "success";
    }

function withdrawETH(address payable recipient, uint256 amount) public {
  
}
 
  
}