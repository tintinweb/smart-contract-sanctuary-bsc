/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
contract PrivateVariable{

    string private name;

    function setName(string calldata _name) public{
        name = _name;
    }
}