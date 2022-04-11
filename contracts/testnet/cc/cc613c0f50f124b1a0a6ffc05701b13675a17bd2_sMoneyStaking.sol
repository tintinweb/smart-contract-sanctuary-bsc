/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract sMoneyStaking {

    address payable owner;

    // random % array.length

    constructor() {
         owner = payable(msg.sender);
     }

     event Staking (
        address from,
        uint256 amount,
        string messge
     );

    function smartStaking() public payable{
        (bool success,) = owner.call{value: msg.value}("");
        require(success, "Failed to send money");
        string memory randSpin  = "15|8";
        
        emit Staking(
            msg.sender,
            msg.value,
            randSpin

        );
    } 

}