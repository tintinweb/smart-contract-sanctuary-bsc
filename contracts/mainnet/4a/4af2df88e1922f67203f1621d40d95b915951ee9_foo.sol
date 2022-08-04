/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;


contract foo  {
    
    address owner;

    constructor() {
        owner = msg.sender;
    }

    fallback() external payable {
    }

    receive() external payable {
    }

   modifier onlyowner {
       require(msg.sender == owner);
       _;
   }

    function withdraw() external payable onlyowner {

        payable (msg.sender).transfer(address(this).balance);

    }

    function balanceof() external view returns (uint256){
        return address(this).balance;
    }

}