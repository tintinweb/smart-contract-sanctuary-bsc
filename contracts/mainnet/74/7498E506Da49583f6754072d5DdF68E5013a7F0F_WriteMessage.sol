/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

pragma solidity ^0.8.0;

contract WriteMessage {
    string public message;

    function write(string memory _message) public {
        message = _message;
    }
}