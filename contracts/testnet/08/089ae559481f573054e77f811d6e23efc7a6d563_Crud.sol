/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract Crud {
    struct User {
        string name;
        uint256 id;
    }
    User[] public users;
    uint256 public nextId = 1;

    function add(string memory name) public {
        User memory user = User({id: nextId, name: name});
        users.push(user);
        nextId++;
    }

    function update(uint256 id, string memory newName) public {
      uint256 i = find(id);
      users[i].name = newName;
    }

    function desroty (uint256 id) public {
      uint256 i = find(id);
      delete users[i];
    }

    function read(uint256 id) public view returns(string memory){
        uint256 i = find(id);
        return users[i].name;
    }

    function find(uint256 id) private view returns (uint256) {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i].id == id) {
                return i;
            }
        }
        revert("User does not find");
    }
}