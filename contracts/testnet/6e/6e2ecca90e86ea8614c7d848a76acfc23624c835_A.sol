/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract A {
    mapping(address => uint256) public amount;
    event RecordAmount(address indexed user, uint256 indexed amount);

    function recordAmount(address _user, uint256 _amount) public returns(address, uint256) {
        amount[_user] = _amount;
        emit RecordAmount(_user, _amount);
        return (_user, _amount);
    }
}