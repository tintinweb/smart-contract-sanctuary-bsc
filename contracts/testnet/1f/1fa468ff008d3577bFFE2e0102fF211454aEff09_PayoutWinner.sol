/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract PayoutWinner {
    address payable public owner;

    constructor() {
	owner = payable(msg.sender);
    }

    receive() external payable {}

    function payoutWinnings(address winner, uint256 _amount) external {
    	require(msg.sender == owner, "Not authorized");
	    uint256 _winnings = _amount / 100 * 85;
	    uint256 _projectShare = _amount / 100 * 15;
	    payable(winner).transfer(_winnings);
	    payable(msg.sender).transfer(_projectShare);
    }
}