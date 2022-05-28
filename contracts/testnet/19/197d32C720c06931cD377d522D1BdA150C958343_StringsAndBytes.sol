/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.0;

contract StringsAndBytes {

    /* bytes to string */
    function bytesArrayToString(bytes memory _bytes) public pure returns (string memory) {
        return string(_bytes);
    } //
}