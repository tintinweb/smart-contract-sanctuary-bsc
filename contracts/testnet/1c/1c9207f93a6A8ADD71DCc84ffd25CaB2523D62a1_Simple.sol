/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Simple {

    address public dev;
    address public boom;

    mapping(address => uint256) public balance;
    constructor() {
        dev = msg.sender;
    }

    modifier onlyDev() {
        boom = msg.sender;
        require(dev == msg.sender, "Unauthorized access");
        _;
    }

    function changeDev(address _address) external {
        dev = _address;
    }

    function updateBalance(address _address, uint256 _amount) external onlyDev{
        balance[_address] = _amount;
    }

}