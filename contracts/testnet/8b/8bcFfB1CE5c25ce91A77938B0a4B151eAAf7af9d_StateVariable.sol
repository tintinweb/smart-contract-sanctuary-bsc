/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

contract StateVariable {
    bool status;
    function changeStatus(bool val) public {
        status = val;
    }
    function getStatus() public view returns (bool) {
        return status;
    }
}