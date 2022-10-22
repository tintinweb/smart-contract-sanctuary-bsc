/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


contract A2 {

    address public a1;
    address public owner;
    

    constructor(address _a1) {
        a1 = _a1;
        owner = msg.sender;
    }

    function aa() external payable {
        a1.call{value: address(this).balance / 2}("");
        owner.call{value: address(this).balance / 2}("");
    }
    
    receive() external payable  {
        
    }

}