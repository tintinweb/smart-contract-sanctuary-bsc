/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

contract Puzzle {


	function minUIntPair(uint _i, uint _j) internal pure returns (uint){
		if (_i < _j){
			return _i;
		}else{
			return _j;
		}
	}	

	function getTime() public view returns (uint256) {
        return block.timestamp;
	}

    function test() public view returns (uint256){
        return (minUIntPair(block.timestamp, ( 1659951622 + (uint256(500) * uint256(864)))) -  1659951622);
    }


}