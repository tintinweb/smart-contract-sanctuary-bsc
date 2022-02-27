/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract presaleICO {

    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    event Contribute (
        address from,
        uint256 amount,
        string messge
    );

    function newContribution(string memory note) public payable{
        (bool success,) = owner.call{value: msg.value}("");
        require(success, "Failed to send money");
        emit Contribute(
            msg.sender,
            msg.value,
            note

        );
    }
}