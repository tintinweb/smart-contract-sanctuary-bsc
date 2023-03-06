//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ColdStakingv1 {
    mapping(address => uint256) _balances;

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
}