// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract testOverflow {

    function testMinus() public view returns (uint) {
		uint a = 3;
		uint b = 5;
		
		return a - b;
    }
	
	function testMinus2() public view returns (uint) {
		uint a = 3;
		uint b = 5;
		
		if(a - b > 2)
		{
			return a - b;
		}
		
		return 1;
	}
}