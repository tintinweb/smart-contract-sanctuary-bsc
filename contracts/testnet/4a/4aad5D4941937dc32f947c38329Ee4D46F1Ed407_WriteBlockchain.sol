/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.8.0;

contract WriteBlockchain {
    string text;

    function Write (string calldata _text) public {
        text = _text;

    }

    function Read () public view returns(string memory){
        return text;
    }
}