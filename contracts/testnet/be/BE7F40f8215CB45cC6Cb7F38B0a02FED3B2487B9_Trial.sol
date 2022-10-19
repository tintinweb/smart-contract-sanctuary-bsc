/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;



contract Trial {



    address user_address;

    address owner;

    event Address(address _useraddress);



    function initialiser(address _owner) public{

        owner = _owner;

    }

    

    function getAddress() public{

        user_address = msg.sender;

        emit Address(user_address);

    }



}