/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract HB {
    mapping (string => string) public messages;

    function setMessage(string memory _key, string memory _message) public {
        bytes memory _messageByKey = bytes(messages[_key]);
        require(_messageByKey.length == 0);
        messages[_key] = _message;
    }
}