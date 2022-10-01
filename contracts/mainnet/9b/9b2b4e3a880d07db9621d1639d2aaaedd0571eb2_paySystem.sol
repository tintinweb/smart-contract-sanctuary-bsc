/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT
contract paySystem{

    mapping(address => string) public passwordSign;

    //config
    uint public _signLength = 100;
    
    function setPasswordSign(string memory _passwordSign) public{
        require(bytes(_passwordSign).length < _signLength, "ERC20: _passwordSign.length The length of the abnormal");
        passwordSign[msg.sender] = _passwordSign;
    }

}