/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

contract SimpleContract {
    string message;

    function setMessage(string memory _message) public {
        message = _message;
    }
}