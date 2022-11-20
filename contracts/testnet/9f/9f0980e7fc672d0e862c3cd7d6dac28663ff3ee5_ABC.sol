/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

pragma solidity ^0.8.7;

// SPDX-License-Identifier: GPL-3.0

contract ABC {

address payable b = payable(0x9997aBff396d699FBFCEcbC17d69Bbe9343bD13e);

uint amount= 1000000000000000000;

function make_a_transfer(bool success) public  payable returns (bool){
   
      

     payable(b).transfer(amount);

     return  success;

    }

}