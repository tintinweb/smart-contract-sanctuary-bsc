/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TestBytes {
    
    function compareTest(bytes memory data) public pure returns(bool result) {
        bytes4 value1 = 0x12345678;
        bytes4 sub = bytes4(data);
        result = (sub == value1);
    }

}