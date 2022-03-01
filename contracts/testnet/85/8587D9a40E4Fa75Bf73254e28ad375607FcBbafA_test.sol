/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

pragma solidity ^0.8.0;

contract test {
    event Message(string message);
    function wMessage(string memory message) external {
        emit Message(message);
    }
}