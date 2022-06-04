/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NameContract {

    uint256 _no;
    string _name;
    string _email;
    uint8 _age;
    string _DOB;

    constructor(uint256 no,
    string memory name,
    string memory email,
    uint8 age,
    string memory DOB){
        _no=no;
        _name=name;
        _email=email;

        _age=age;
        _DOB=DOB;
    }

    function getName() public view returns (uint256 ,
    string memory,
    string memory,
    uint8 ,
    string memory)
    {
        return (_no,_name,_email,_age,_DOB);
    }

    function setName(uint256 no,
    string memory name,
    string memory email,
    uint8 age,
    string memory DOB)public {
        _no=no;
        _name=name;
        _email=email;

        _age=age;
        _DOB=DOB;
    }

}