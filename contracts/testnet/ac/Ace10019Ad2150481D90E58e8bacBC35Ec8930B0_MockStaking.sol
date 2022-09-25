// SPDX-License-Identifier: ISC

pragma solidity ^0.8.0;

contract MockStaking {
    mapping(address => uint256) public _balances;

    function setBalance(address addr, uint256 amount) external  {
        _balances[addr] = amount;
    }
}