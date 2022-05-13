/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/*contract Mapping {

    mapping (uint => string ) public emp_info;

    function setinfo () public {
       emp_info[1] = "ali";
    }

    function getinfo (uint _info) public  returns (string memory ) {
        return emp_info[_info] = "ali";
    }


} */

contract Mapping2 {

    struct employe {
        string name ;
        string add;
        uint salary ;
        uint age;
    }
    mapping (address => employe) public emp_info;

    function setinfo (string memory _name , string memory _add , uint _salary , uint _age) public {
        emp_info[msg.sender] = employe (_name , _add, _salary , _age) ;
    }
}