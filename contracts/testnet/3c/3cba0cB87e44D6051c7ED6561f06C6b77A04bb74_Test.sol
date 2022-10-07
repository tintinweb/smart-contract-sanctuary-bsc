pragma solidity ^0.5.16;

contract Test {

    uint256 public synthetix;
    address public owner;

    constructor (uint256 amount) public {
        synthetix = amount;
        owner = msg.sender;
    }

    function change(uint256 changeAmount) public {
        require(owner == msg.sender, "Only owner");
        synthetix = changeAmount;
    }
}