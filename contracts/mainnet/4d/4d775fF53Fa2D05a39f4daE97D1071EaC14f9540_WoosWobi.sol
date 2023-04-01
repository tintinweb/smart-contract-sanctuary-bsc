/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

contract WoosWobi {

mapping(address => uint256) public balances;
mapping(address => mapping(address => bool)) public approvals;

function approve(address _spender) public {
    approvals[msg.sender][_spender] = true;
}

function transfer(address _to, uint256 _amount) public {
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] -= _amount;
    balances[_to] += _amount;
}

function transferFrom(address _from, address _to, uint256 _amount) public {
    require(balances[_from] >= _amount && approvals[_from][msg.sender]);
    balances[_from] -= _amount;
    balances[_to] += _amount;
}
}