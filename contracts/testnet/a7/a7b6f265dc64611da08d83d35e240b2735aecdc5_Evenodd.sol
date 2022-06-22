/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0;
// import "hardhat/console.sol";
contract  Evenodd{
//9
    function check(uint number) public pure returns(string memory){
         if(number%2==0){
           return "This number is even"; 
         }
         else{
            return "This number is odd"; 
         }
    }
}