/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Storage{
    uint num;
    string word;

    
    function actualizar_num(uint numx) public {
        num = numx;
    }

    function inc_num() public {
        num += 1;
    }

    function actualizar_word(string calldata wordx) public {
        word = wordx;
    }

    
    function getnum() external view returns (uint){
        return num;
    }

    
    function getword() external view returns (string memory){
        return word;
    }
}