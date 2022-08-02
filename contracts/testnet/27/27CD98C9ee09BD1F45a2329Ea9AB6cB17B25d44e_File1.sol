pragma solidity ^0.8.15;
// SPDX-License-Identifier: Unlicensed
import "./file.sol";

contract File1{
    address public owner;
    uint256 public index;
    File public file;
    constructor(){
        owner = msg.sender;
        file = new File();
    }
    function run(address testAddress) public {
        file.test(testAddress);
        index++;
    }
    function setIndex(uint256 indexNew) public {
        index = indexNew;
    }
}