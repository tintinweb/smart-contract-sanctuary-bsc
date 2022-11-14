/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract camsiairdropcheck {
    address private owner;
    mapping(address => uint256) public airdropValue;

    constructor() {
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }


    function GetUserAirdropValue(address beneficiary)
        public
        view
        returns (uint256)
    {
        return airdropValue[beneficiary];
    }

    function SetUserAirdropValue(address beneficiary, uint256 value) public OnlyOwner{
        airdropValue[beneficiary] = value;
    }


}