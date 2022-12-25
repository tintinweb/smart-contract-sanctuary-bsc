/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: NONE
pragma solidity 0.8.14;

contract DonationContract {
    address payable public owner;
    uint public totalDonations;

    constructor() {
        owner = payable(msg.sender);
    }

    function donate() public payable {
        require(msg.value > 0, "Donation must be greater than zero");
        totalDonations += msg.value;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only the contract owner can withdraw funds");
        owner.transfer(totalDonations);
        totalDonations = 0;
    }
}