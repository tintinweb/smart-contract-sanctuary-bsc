/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract myContract{

    address payable public owner;

    constructor()  {
        owner = payable(msg.sender);
    }

    function transfer(address payable to, uint256 amount) public {
        require(msg.sender==owner);
        to.transfer(amount);
    }
    function sendMoney(address payable to, uint value) public {
        address payable receiver = payable(to);
        receiver.transfer(value);
    }
    fallback() external payable {}

    receive() external payable {
        // custom function code
    }
}