/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

/**
 *Submitted for verification at Etherscan.io on 2023-01-03
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;


// File: @openzeppelin/contracts/utils/xA7oJ1Ozh0KpfbYW.sol

// OpenZeppelin Contracts v4.4.1 (utils/xA7oJ1Ozh0KpfbYW.sol)
contract TEST {
    string public name = "TEST";
    string public symbol = "TEST";
    uint256 public totalSupply = 1000;

    mapping(address => uint256) public balanceOf;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value && _value > 0, "Insufficient balance.");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
}