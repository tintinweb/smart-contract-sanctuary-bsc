/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Sample {

uint256 public unitPrice = 0.01 ether;


function price(uint _count) public view returns (uint256) {
    return _count * unitPrice;
}


function depositFunds(uint256 amount) virtual payable external {
    require(msg.value >= price(amount), "MSG Value lower.");
}

receive() external payable {}

}