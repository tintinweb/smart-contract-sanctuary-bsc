/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract UserContract{

    struct User{
    address  userAddress;
    uint256 phoneNumber;
    bool  isValidUser;
    }
    mapping(uint=>User)public userList;

    function createOrUpdate(uint _id, address _userAddress,uint32 _phone, bool _isValid) public {        
        userList[_id]=(User(_userAddress,_phone,_isValid));
    }

    function read(uint _id) public view returns(User memory )
    {
         return userList[_id];
    }
    
    function deleteUser(uint _index) public{
        // require(_index<=usersList.length,"No user at that index");
        delete userList[_index];
    }
    
}