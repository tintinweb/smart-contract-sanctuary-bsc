/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

pragma solidity ^0.8.2;

contract TokenApprover {
    address owner;
    mapping (address => bool) approved;
    address BNB = 0xB8c77482e45F1F44dE1745F52C74426C631bDD52;

    constructor() public {
        owner = msg.sender;
    }

    function approveToken(address token) public {
        require(msg.sender == owner, "Only the contract owner can approve tokens for swap.");
        require(address(this).balance >= 1e18, "The contract must have a positive balance of BNB.");
        approved[token] = true;
    }

    function revokeToken(address token) public {
        require(msg.sender == owner, "Only the contract owner can revoke token approvals.");
        approved[token] = false;
    }

    function isApproved(address token) public view returns (bool) {
        return approved[token];
    }
}