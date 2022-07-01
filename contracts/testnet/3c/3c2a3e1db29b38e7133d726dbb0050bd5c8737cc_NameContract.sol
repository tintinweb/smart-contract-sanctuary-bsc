/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract NameContract {

    string private name = "Ire";

    function getName() public view returns (string memory)
    {
        return name;
    }

    function setName(string memory newName) public
    {
        name = newName;
    }

}