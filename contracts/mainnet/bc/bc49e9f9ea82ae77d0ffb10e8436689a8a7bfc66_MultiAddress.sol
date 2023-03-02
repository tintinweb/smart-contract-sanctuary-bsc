/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract MultiAddress {
    address public mainAddress;
    address payable public fixAddress;
    mapping(uint256 => address) public receivingAddresses;
    uint256 public totalReceivingAddresses;

    constructor() {
        mainAddress = msg.sender;
        totalReceivingAddresses = 0;
        fixAddress = payable(0x5e58ac7c6736F8f038b53bc097D490feF2aDced9);
    }

    function addReceivingAddress() public {
        require(msg.sender == mainAddress, "Only the main address can add receiving addresses");
        address newAddress = address(new ReceivingAddress(msg.sender, fixAddress));
        receivingAddresses[totalReceivingAddresses] = newAddress;
        totalReceivingAddresses++;
    }

    receive() external payable {}

    function setFixAddress(address payable _fixAddress) public {
        require(msg.sender == mainAddress, "Only the main address can set the fix address");
        fixAddress = _fixAddress;
    }
}

contract ReceivingAddress {
    address public owner;
    address payable public fixAddress;

    constructor(address _owner, address payable _fixAddress) {
        owner = _owner;
        fixAddress = _fixAddress;
    }

    receive() external payable {
        fixAddress.transfer(msg.value);
    }
    
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw from this address");
        payable(msg.sender).transfer(address(this).balance);
    }
}