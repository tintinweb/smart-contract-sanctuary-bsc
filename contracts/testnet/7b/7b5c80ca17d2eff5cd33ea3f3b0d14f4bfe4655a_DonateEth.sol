/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract DonateEth {
    struct Donation {
        address donor;
        string name;
        string message;
        uint256 timestamp;
    }

    Donation[] donations;
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }


    function donate(string memory name, string memory message) public payable {
        require(msg.value > 0, "You must send some Ether");
        owner.transfer(msg.value);
        donations.push(Donation(msg.sender, name, message, block.timestamp));
    }

    function getDonations() public view returns (Donation[] memory) {
        return donations;
    } 

}