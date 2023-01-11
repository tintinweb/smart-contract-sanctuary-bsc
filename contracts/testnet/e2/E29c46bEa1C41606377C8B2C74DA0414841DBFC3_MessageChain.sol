/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

pragma solidity ^0.8.0;

contract MessageChain {

    address owner;

    constructor() public {
        owner = 0x23e6176CEA66213B948cA3B4eB8CFB9640899Fa8;
    }

    function write(string memory _message) public {
        require(msg.sender == owner, "Only the owner can write messages");
        emit MessageWritten(_message);
    }

    event MessageWritten(string message);
}