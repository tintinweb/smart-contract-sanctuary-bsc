/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract SimplekContract {
    string message;

    function setMessage(string memory _message) public {
        message=_message;
    }
}