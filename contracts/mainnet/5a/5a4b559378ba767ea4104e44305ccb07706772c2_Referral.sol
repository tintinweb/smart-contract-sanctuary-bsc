/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract Referral {
    mapping(address => address) public _referral; 
    address public _owner;

    constructor() {
        _referral[msg.sender] = msg.sender;
        _owner = msg.sender;
    }

    function Registration(address referral_) public payable returns(string memory) {
        if(_referral[referral_] == address(0)) {
            require(0>1, "The referral not exists");
        }
        _referral[msg.sender] = referral_;
        return "Success!";
    }

}