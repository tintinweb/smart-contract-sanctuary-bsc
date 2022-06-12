/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

// SPDX-Liscense-Identifier: MIT
pragma solidity ^0.8.7;

contract donation {
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    event Donate(address from, uint256 amount, string message);

    function newDonation(string memory note) public payable {
        (bool success, ) = owner.call{value: msg.value}("");
        require(success, "Failed to send money");
        emit Donate(msg.sender, msg.value, note);
    }
}