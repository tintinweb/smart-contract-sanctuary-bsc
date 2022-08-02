/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

contract StakingUpp {

	struct recordX { uint256 stakeTime; }

}

interface StakingInt {

	struct record0 { uint256 staker; uint256 stakeTime; string monkey; }
	struct record1 { uint256 staker; uint256 stakeTime; string monkey; record0 ha; record0[] b; }

}


contract Staking  {

	struct record { uint256 stakeTime; }

	//This function allows the owner to specify an address that will take over ownership rights instead. Please double check the address provided as once the function is executed, only the new owner will be able to change the address back.
	function test1() pure public returns (record memory) {
		record memory xxx = record (2);
		return xxx;
	}

	function test2() pure public returns (record[] memory) {
		record memory xxx = record (2);
		record[] memory haha;
		haha[0] = xxx;
		haha[1] = xxx;
		return haha;
	}

	function test3(record memory a) pure public returns (record memory) {
		return a;
	}

	function test4(record memory a) pure public returns (record[] memory) {
		record[] memory haha;
		haha[0] = a;
		haha[1] = a;
		return haha;
	}

	function test5(StakingUpp.recordX memory a) pure public returns (StakingUpp.recordX memory) {
		return a;
	}

	function test6(StakingInt.record0 memory a) pure public returns (StakingInt.record0 memory) {
		return a;
	}

	function test7(StakingInt.record1 memory a) pure public returns (StakingInt.record1 memory) {
		return a;
	}

}