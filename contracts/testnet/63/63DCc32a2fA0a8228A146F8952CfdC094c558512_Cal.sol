/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Cal{

uint num1 = 20;
uint num2 = 5;
    // +
    function adding() public view returns(uint ans){
        ans = num1 + num2 ;
        return ans;

    }

  // -
    function subtracting() public view returns(uint ans){
        ans = num1 - num2 ;
        return ans;

    }

  // *
    function multiplying() public view returns(uint ans){
        ans = num1 * num2 ;
        return ans;

    }

      // /
    function dividing() public view returns(uint ans){
        ans = num1 / num2 ;
        return ans;

    }

}