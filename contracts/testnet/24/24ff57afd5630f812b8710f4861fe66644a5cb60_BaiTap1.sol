/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract BaiTap1 {
    uint256 public a;
    uint256 public b;

    constructor(uint256 _a, uint256 _b) {
        a = _a;
        b = _b;
    }

    function add() public view returns (uint256) {
        return a + b;
    }

    function sub() public view returns (uint256) {
        require(a > b, "a must be more than or equal b");
        return a - b;
    }

    function mul() public view returns (uint256) {
        return a * b;
    }

    function div() public view returns (uint256) {
        require(b != 0, "b can not be 0");
        return a / b;
    }

    function mod() public view returns (uint256) {
        require(b != 0, "b can not be 0");
        return a % b;
    }
}