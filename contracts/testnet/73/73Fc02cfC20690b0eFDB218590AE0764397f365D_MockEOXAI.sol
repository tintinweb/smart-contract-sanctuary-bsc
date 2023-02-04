/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract MockEOXAI {
    mapping(address => uint256) public balances;

    function setBalance(address _target, uint256 _balance) external {
        balances[_target] = _balance;
    }

    function balanceOf(address _target) external view returns(uint256) {
        return balances[_target];
    }
}