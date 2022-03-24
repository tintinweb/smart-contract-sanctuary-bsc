/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract SwapLimit {
    struct Order {
        address pairAddress;
        address user;
        uint256 inputAmount;
        uint256 outputAmount;
    }
    Order[] public orderStack;
    address public  admin;
    constructor() {
        admin = msg.sender;
    }

    function createOrder(
        uint256 inputAmount,
        uint256 outputAmount,
        address pairAddress
    ) public {
        orderStack.push(
            Order(pairAddress, msg.sender, inputAmount, outputAmount)
        );
    }

    function swap() public {
        orderStack.pop(); // pop last sell
    }
}