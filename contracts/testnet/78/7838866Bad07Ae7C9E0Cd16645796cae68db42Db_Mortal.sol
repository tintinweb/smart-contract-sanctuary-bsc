/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Owned {
    address payable owner;
    constructor() {
        owner = payable(msg.sender);
    }

    function setOwner(address _owner) public virtual {
        owner = payable(_owner);
    }
}
pragma solidity ^0.8.4;

contract Mortal is Owned {
    event SetOwner(address indexed owner);

    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
    function setOwner(address _owner) public override {
        super.setOwner(_owner);
        emit SetOwner(_owner);
    }
}