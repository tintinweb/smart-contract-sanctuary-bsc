/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

contract Testing {

    address public owner;

    mapping(address => uint256) private Deposits;

    uint256 public total_pool;

    constructor() {

        owner = msg.sender;

    }

    function deposit(uint256 _amount) payable public {

        // require(msg.value >= 1, "Min deposit is 1");

        Deposits[msg.sender] = _amount;
        total_pool += _amount;

    }

    function withdraw(uint256 _amount) public {

        require(Deposits[msg.sender] > 0, "No deposits");
        require(Deposits[msg.sender] >= 100, "Min withdraw is 100");

        Deposits[msg.sender] = Deposits[msg.sender] - _amount;

        total_pool -= _amount;

    }

    function getPoolAmount() public view returns (uint256) {
        return total_pool;
    }

    function getPool() public view returns (uint256) {
        return address(this).balance;
    }

}