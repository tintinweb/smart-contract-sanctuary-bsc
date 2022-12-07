/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ImplSelfDesctruct {
    uint setlen;
    function implSelfDesctruct(address payable to) external {
        // selfdestruct(to);
        setlen = 2;
    }
}

contract Factory {

    function createCon() external returns (address) {
        address con = address(new ImplSelfDesctruct());

        return con;
    }
}