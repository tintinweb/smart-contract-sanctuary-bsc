/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract donationForCDS {

    address payable owner;

    constructor() {
         owner = payable(msg.sender);
     }

     event Donate (
        address from,
        uint256 amount
     );

    function newDonation() public payable{
        (bool success,) = owner.call{value: msg.value}("");
        require(success, "Failed to send money");
        emit Donate(
            msg.sender,
            msg.value / 1000000000000000000
        );
    }

}