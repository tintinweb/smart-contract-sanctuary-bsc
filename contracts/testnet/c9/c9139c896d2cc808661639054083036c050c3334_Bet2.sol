/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bet2 {

    event userRecharge(address from, uint256 amount, string inoviceid);

    function recharge(string memory inoviceid) public payable returns (uint256) {
        //require(false);
        if (msg.value > 0) {
            emit userRecharge(msg.sender, msg.value, inoviceid);
            return 1;
        } else {
            require(false);
            return 0;
        }
    }

  
}