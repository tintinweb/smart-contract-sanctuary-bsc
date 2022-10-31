/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

pragma solidity ^0.7.0;
// SPDX-License-Identifier: Unlicensed

interface OwnershipAcceptingInterface {
	function acceptOwnership() external;
}

contract RaptorOwnershipBurner {
	address public immutable raptorv2;
	bool public burned;
	
	constructor(address _raptor) {
		raptorv2 = _raptor;
	}
	
	function acceptV2Ownership() public {
		OwnershipAcceptingInterface(raptorv2).acceptOwnership();
		burned = true;
	}
}