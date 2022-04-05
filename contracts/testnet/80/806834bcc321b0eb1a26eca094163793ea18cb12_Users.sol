/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
pragma abicoder v2;

contract Users{
    struct user_data{
        address _address;
        string name;
        uint256 invested;
    }

    struct _user_data{
        user_data data;
        bool is_present;
    }

    mapping(address => _user_data) data;

    function set(address _address, string memory _name, uint256 _invested) public {
        data[msg.sender].data._address = _address;
        data[msg.sender].data.name = _name;
        data[msg.sender].data.invested = _invested;
        data[msg.sender].is_present = true;
    }

    function get() public view returns (user_data memory) {
        require(data[msg.sender].is_present, "User not registered");
        return data[msg.sender].data;
    }
}