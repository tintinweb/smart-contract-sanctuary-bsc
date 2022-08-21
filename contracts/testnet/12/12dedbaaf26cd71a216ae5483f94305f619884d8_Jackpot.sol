/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

contract Jackpot {
    address public owner;
    address payable public poolWallet;

    event Deposit(address indexed player, uint256 amount);

    constructor(address payable _poolWallet) {
        owner = msg.sender;
        poolWallet = _poolWallet;
    }

    function deposit() public payable {
        poolWallet.transfer(msg.value);
        emit Deposit(msg.sender, msg.value);
    }
}