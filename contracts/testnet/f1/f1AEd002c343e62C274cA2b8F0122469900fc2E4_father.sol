// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract father {
    string public name = "father";

    function say() public view returns (string memory) {
        return name;
    }
}