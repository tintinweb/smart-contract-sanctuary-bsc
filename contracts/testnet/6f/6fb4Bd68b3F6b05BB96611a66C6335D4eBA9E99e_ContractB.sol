//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract ContractB {

    constructor() {}

    uint256 public userAllowance;
    address public callerAddress;
    mapping(address => mapping(address => uint256)) public _allowances;

    function approve(address spender, uint256 amount) public returns (uint256) {
        address owner = msg.sender;
        _allowances[owner][spender] = amount;

        callerAddress = msg.sender;
        userAllowance = amount;
    }

}