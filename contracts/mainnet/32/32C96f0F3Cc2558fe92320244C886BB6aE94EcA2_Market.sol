/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract Market  {
    mapping(address => address) inviter;

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function setInviter(address account) external {
        require(account != address(0), "Cannot be set inviter to zero address");        
        require(inviter[msg.sender] == address(0), "Accout is owned inviter");
        require(msg.sender != account, "Accout can't be self"); //A = A
        require(inviter[account] != msg.sender, "Account can't be each other"); //A = B, B = A
        inviter[msg.sender] = account;
    }

}