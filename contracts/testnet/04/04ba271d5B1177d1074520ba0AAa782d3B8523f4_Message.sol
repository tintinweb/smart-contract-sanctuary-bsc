/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

pragma solidity ^0.8.0;
//SPDX-License-Identifier: UNLICENSED
contract Message {
    string public message;

    function setMessage(string memory _message) public {
        message = _message;
    }

    function getMessage() public view returns (string memory) {
        return message;
    }
}