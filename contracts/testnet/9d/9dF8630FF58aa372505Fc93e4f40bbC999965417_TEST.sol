// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

contract TEST {

    string private a;
    uint256 private b;

    constructor(
        string memory str_,
        uint256 int_
    )public {
        a = str_;
        b = int_;
    }

    function getStr() external view returns(string memory) {
        return a;
    }

    function getInt() external view returns(uint256) {
        return b;
    }
}