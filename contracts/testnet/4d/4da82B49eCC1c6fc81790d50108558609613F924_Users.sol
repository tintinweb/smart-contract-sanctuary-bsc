/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Users {
    mapping(address => User) _user;

    struct User {
        string _username;
        // define other information
    }

    function addUser(address _userAddress, string memory _username) public {
        _user[_userAddress] = User(_username);
    }

    function getUser(address _address) view public returns(User memory) {
        return _user[_address];
    }
}