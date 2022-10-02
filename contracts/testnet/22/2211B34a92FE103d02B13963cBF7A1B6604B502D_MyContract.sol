/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.16;

contract MyContract {
	uint256 lastRun;
	mapping(address=>uint) balances;
	address payable public owner;

	constructor() {
        owner = payable(msg.sender);
    	}


	function deposit() public payable {
        balances[msg.sender] += msg.value;
   	}


    function gift() external {
        require(block.timestamp - lastRun > 5 minutes, 'Need to wait 5 minutes');
	//action
        address payable receiver = payable(0x918E648D4374c890368C98976bCfF2ba402090af);
    	receiver.transfer(0.01 ether);
        lastRun = block.timestamp;
    }
}