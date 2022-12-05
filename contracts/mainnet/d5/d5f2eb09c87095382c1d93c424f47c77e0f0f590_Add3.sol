/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
contract Add3 {
uint256 ourNumber;
function initialize() public {
ourNumber = 0x64;
}
function getNumber() public view returns (uint256) {
return ourNumber;
}
function addThree() public {
ourNumber = ourNumber + 3;
}
}