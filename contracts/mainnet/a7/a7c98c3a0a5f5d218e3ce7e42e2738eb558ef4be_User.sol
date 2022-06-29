/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract User {
   
    struct Member {
        address owner;
        string userName;
        bool isValid;
    }

    Member[] private memberList;
    mapping (address => Member) private members;

    function setAccount(string memory _userName) public returns (bool) {
        members[msg.sender] = Member(address(msg.sender), _userName, true);
        return true;
    }

    function deleteMyAccount() public returns (bool) {
        members[msg.sender] = Member(address(0), "", false);
        return true;
    }

    function getAccount() public view returns (Member memory) {
        if(members[msg.sender].owner == msg.sender) return members[msg.sender];
        else return Member(address(0), "", false);
    }

}