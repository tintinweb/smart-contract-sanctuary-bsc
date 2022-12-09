/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Test{
    address public owner = msg.sender;
    event deposit (uint amount);

    receive() external payable{
    emit deposit (msg.value);
 }

 function withdraw() external { 
    require(owner == msg.sender);
}

}