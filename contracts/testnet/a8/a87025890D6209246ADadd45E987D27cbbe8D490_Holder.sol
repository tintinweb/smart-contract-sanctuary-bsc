/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract Holder {
    mapping (address => uint) public balances;
    constructor() {

    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function balanceOf(address user) public view returns (uint) {
        return balances[user];
    }

    error InsufficientBalance(uint requested, uint available);

    function withdraw(uint amount) public {
        if(amount > balances[msg.sender])
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}