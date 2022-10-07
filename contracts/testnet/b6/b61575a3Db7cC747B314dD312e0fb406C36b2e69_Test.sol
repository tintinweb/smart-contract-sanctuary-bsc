pragma solidity >=0.5.16;

contract Test {

    uint256 public synthetix;

    constructor (uint256 amount) public {
        synthetix = amount;
    }

    function change(uint256 changeAmount) public {
        synthetix = changeAmount;
    }
}