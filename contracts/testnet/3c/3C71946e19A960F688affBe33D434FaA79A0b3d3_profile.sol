// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Ownable.sol";

contract profile is Ownable{
	mapping(address => string) profileDetails;
	uint256 totalProfileCount;
	
	function createProfile(string memory _profileURI)public{
		if(bytes(profileDetails[msg.sender]).length == 0){
			totalProfileCount++;
		}
		profileDetails[msg.sender] = _profileURI;		
	}
	
	function viewProfile(address _profileHolder) public view returns(string memory){
		require(msg.sender == _profileHolder || msg.sender == owner(),"Not Allowed");
		return profileDetails[_profileHolder];
	}
	
	function deleteProfile(address _profileHolder) public{
		require(msg.sender == _profileHolder || msg.sender == owner(),"Not Allowed");
		delete profileDetails[_profileHolder];
		totalProfileCount--;
	}
	
	function ProfileCount()public view returns(uint256){
		return totalProfileCount;
	}
}