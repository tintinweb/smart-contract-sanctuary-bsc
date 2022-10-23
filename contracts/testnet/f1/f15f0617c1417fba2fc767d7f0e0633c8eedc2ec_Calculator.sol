/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;

/**
 * @title Calculator
 * @dev Calculate arithmetic operations
 */
contract Calculator {

    uint256 public result;

    function add (uint256 a, uint256 b) public{
        result = a+b;
    }

    function sub (uint256 a, uint256 b) public{
        require (a>=b, "b is less than a");
        result = a - b;
    }

     function div (uint256 a, uint256 b) public{
         require (a > b, "the second parameter should be larger than 0");
        result = a/b;
    }

    function mul (uint256 a, uint256 b) public{
        result = a*b;
    }

    function mod (uint256 a, uint256 b) public{
        result = a%b;
    }

}