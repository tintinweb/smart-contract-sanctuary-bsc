/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Encode {
    function encode(string memory _string1) public pure returns (bytes memory) {
        return (abi.encode(_string1));
    }
    function decode(bytes memory data) public pure returns (string memory _str1) {
        (_str1) = abi.decode(data, (string));  
        return _str1;     
    }
}