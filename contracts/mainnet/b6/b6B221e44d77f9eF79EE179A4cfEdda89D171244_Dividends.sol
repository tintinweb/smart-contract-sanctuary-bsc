/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed



contract Dividends  {


    constructor()
  public {


     }

     

 

  function getBNBbalance(address addres) public view  returns(uint256) {
        address payable _Manager = address(uint160(addres));

        return  address(_Manager).balance;

   }


 
    








   
}