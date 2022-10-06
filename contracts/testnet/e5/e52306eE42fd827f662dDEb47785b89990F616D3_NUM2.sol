// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract NUM2 {
    uint256 private num;

    function update(uint256 _num) public {
        num = _num;
    }


    function get() public view returns (uint256){
        return num;
    }

    function increment() public {
        num = num + 1;
    }
}