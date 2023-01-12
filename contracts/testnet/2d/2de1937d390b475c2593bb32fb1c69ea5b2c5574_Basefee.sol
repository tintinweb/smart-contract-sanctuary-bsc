/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: none

pragma solidity >=0.8.0 <0.9.0;

contract Basefee {
    function basefee_global() external view returns (uint) {
        return block.basefee;
    }
    function basefee_inline_assembly() external view returns (uint ret) {
        assembly {
            ret := basefee()
        }
    }
}