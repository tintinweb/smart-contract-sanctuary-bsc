// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract testOverflow {

    function testMinus(uint a) public view returns (uint) {
		uint b = 5;
		
		return a - b;
    }
	
	function testMinus2(uint a) public view returns (uint) {
		uint b = 5;
		
		if(block.timestamp - a >= 7776000) //1656648261
		{
			return 2;
		}
		
		return block.timestamp;
	}
}